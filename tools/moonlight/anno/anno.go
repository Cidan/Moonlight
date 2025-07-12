package anno

import (
	"encoding/xml"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"sync"

	"github.com/Cidan/Moonlight/tools/moonlight/util"
	"github.com/go-git/go-git/v5"
	"github.com/sourcegraph/conc/pool"
	"github.com/spf13/cobra"
)

func NewAnnoCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "anno",
		Short: "Manage annotations",
	}

	cmd.AddCommand(newUpdateCmd())

	return cmd
}

type repoInfo struct {
	URL           string
	Name          string
	SubDirs       []string
	AnnotateMixin bool
}

type mixinInfo struct {
	Name  string
	Mixin string
}

func newUpdateCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "update",
		Short: "Update annotations from a git repository",
		RunE: func(cmd *cobra.Command, args []string) error {
			repos := []repoInfo{
				{
					URL:     "https://github.com/Ketho/vscode-wow-api",
					Name:    "vscode-wow-api",
					SubDirs: []string{"Annotations/Core"},
				},
				{
					URL:           "https://github.com/Gethe/wow-ui-source",
					Name:          "wow-ui-source",
					SubDirs:       []string{"Interface/AddOns"},
					AnnotateMixin: true,
				},
			}

			reporoot, err := util.FindRepoRoot()
			if err != nil {
				return err
			}

			for _, repo := range repos {
				tempDir, err := os.MkdirTemp("", "wow-api-repo-")
				if err != nil {
					return fmt.Errorf("failed to create temp dir: %w", err)
				}
				defer os.RemoveAll(tempDir)

				_, err = git.PlainClone(tempDir, false, &git.CloneOptions{
					URL:      repo.URL,
					Progress: os.Stdout,
					Depth:    1,
				})
				if err != nil {
					return fmt.Errorf("failed to clone repo: %w", err)
				}

				for _, subDir := range repo.SubDirs {
					sourceDir := filepath.Join(tempDir, subDir)
					destDir := filepath.Join(reporoot, "annotations", repo.Name, subDir)

					if _, err := os.Stat(destDir); !os.IsNotExist(err) {
						if err := os.RemoveAll(destDir); err != nil {
							return fmt.Errorf("failed to remove existing destination directory: %w", err)
						}
					}

					if err := os.MkdirAll(destDir, 0755); err != nil {
						return fmt.Errorf("failed to create destination directory: %w", err)
					}

					if err := util.CopyDir(sourceDir, destDir); err != nil {
						return fmt.Errorf("failed to copy files: %w", err)
					}

					if err := processMetaAnnotations(destDir); err != nil {
						return fmt.Errorf("failed to process meta annotations: %w", err)
					}

					if repo.AnnotateMixin {
						if err := processMixinAnnotations(destDir); err != nil {
							return fmt.Errorf("failed to process mixin annotations: %w", err)
						}
					}
				}
			}
			return nil
		},
	}
	return cmd
}

func processMetaAnnotations(destDir string) error {
	return filepath.Walk(destDir, func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if !info.IsDir() && strings.HasSuffix(info.Name(), ".lua") {
			content, err := os.ReadFile(path)
			if err != nil {
				return err
			}

			if !strings.HasPrefix(string(content), "---@meta") {
				newContent := append([]byte("---@meta\n"), content...)
				if err := os.WriteFile(path, newContent, info.Mode()); err != nil {
					return err
				}
			}
		}
		return nil
	})
}

func processMixinAnnotations(destDir string) error {
	mixinToName := &sync.Map{}
	nameToMixin := &sync.Map{}
	xmlFiles := []string{}

	fmt.Println("Scanning for mixins...")

	err := filepath.Walk(destDir, func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && strings.HasSuffix(info.Name(), ".xml") {
			xmlFiles = append(xmlFiles, path)
		}
		return nil
	})
	if err != nil {
		return err
	}

	p := pool.New().WithErrors()
	for _, path := range xmlFiles {
		path := path
		p.Go(func() error {
			file, err := os.Open(path)
			if err != nil {
				return err
			}
			defer file.Close()

			decoder := xml.NewDecoder(file)
			for {
				token, _ := decoder.Token()
				if token == nil {
					break
				}

				if se, ok := token.(xml.StartElement); ok {
					var name, mixin string
					for _, attr := range se.Attr {
						if attr.Name.Local == "name" {
							name = attr.Value
						}
						if attr.Name.Local == "mixin" {
							mixin = attr.Value
						}
					}
					if name != "" && mixin != "" {
						mixinToName.Store(mixin, name)
						nameToMixin.Store(name, mixin)
					}
				}
			}
			return nil
		})
	}

	if err := p.Wait(); err != nil {
		return err
	}

	var mixins []mixinInfo
	mixinToName.Range(func(key, value interface{}) bool {
		mixins = append(mixins, mixinInfo{Name: value.(string), Mixin: key.(string)})
		return true
	})

	fmt.Printf("Found %d mixins to process.\n", len(mixins))

	luaFiles := &sync.Map{}
	err = filepath.Walk(destDir, func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && strings.HasSuffix(info.Name(), ".lua") {
			content, err := os.ReadFile(path)
			if err != nil {
				return err
			}
			luaFiles.Store(path, content)
		}
		return nil
	})
	if err != nil {
		return err
	}

	foundMixins := &sync.Map{}
	p = pool.New().WithErrors()
	for _, mixin := range mixins {
		mixin := mixin
		p.Go(func() error {
			luaFiles.Range(func(key, value interface{}) bool {
				path := key.(string)
				content := value.([]byte)

				// Inheritance
				reInherit := regexp.MustCompile(`\b` + regexp.QuoteMeta(mixin.Mixin) + `\s*=\s*CreateFromMixins\(([\w\.]+)\);?`)
				matches := reInherit.FindSubmatch(content)
				if len(matches) > 1 {
					parentMixinName := string(matches[1])
					if parentClassName, ok := mixinToName.Load(parentMixinName); ok {
						fmt.Printf("Found inherited mixin %s in %s, annotating.\n", mixin.Mixin, path)
						annotation := fmt.Sprintf("---@class %s: %s\n", mixin.Name, parentClassName.(string))
						newContent := reInherit.ReplaceAll(content, []byte(annotation+"$0"))
						luaFiles.Store(path, newContent)
						foundMixins.Store(mixin.Mixin, true)
						return true // Continue to next file
					}
				}

				// Simple
				reSimple := regexp.MustCompile(`\b` + regexp.QuoteMeta(mixin.Mixin) + `\s*=\s*{`)
				if reSimple.Match(content) {
					fmt.Printf("Found mixin %s in %s, annotating.\n", mixin.Mixin, path)
					annotation := fmt.Sprintf("---@class %s\n", mixin.Name)
					newContent := reSimple.ReplaceAll(content, []byte(annotation+"$0"))
					luaFiles.Store(path, newContent)
					foundMixins.Store(mixin.Mixin, true)
				}
				return true
			})
			return nil
		})
	}

	if err := p.Wait(); err != nil {
		return err
	}

	luaFiles.Range(func(key, value interface{}) bool {
		path := key.(string)
		content := value.([]byte)
		info, err := os.Stat(path)
		if err != nil {
			fmt.Printf("Error getting file info for %s: %v\n", path, err)
			return true
		}
		if err := os.WriteFile(path, content, info.Mode()); err != nil {
			fmt.Printf("Error writing file %s: %v\n", path, err)
		}
		return true
	})

	for _, mixin := range mixins {
		if _, ok := foundMixins.Load(mixin.Mixin); !ok {
			fmt.Printf("Warning: Could not find mixin variable for %s (name: %s)\n", mixin.Mixin, mixin.Name)
		}
	}

	return nil
}
