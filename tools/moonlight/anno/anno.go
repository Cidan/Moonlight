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
	xmlFiles := []string{}

	fmt.Println("Scanning for mixins in XML files...")
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

	xmlPool := pool.New().WithErrors()
	for _, path := range xmlFiles {
		path := path
		xmlPool.Go(func() error {
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
					}
				}
			}
			return nil
		})
	}
	if err := xmlPool.Wait(); err != nil {
		return err
	}

	luaFiles := &sync.Map{}
	allLuaMixins := &sync.Map{} // mixinVar -> path
	fmt.Println("Loading Lua files into memory...")
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

			reMixin := regexp.MustCompile(`(?m)^([\w\d_]+)\s*=\s*(?:CreateFromMixins\(([\w\d_\.]+)\)|{)`)
			matches := reMixin.FindAllStringSubmatch(string(content), -1)
			for _, match := range matches {
				allLuaMixins.Store(match[1], path)
			}
		}
		return nil
	})
	if err != nil {
		return err
	}

	fmt.Println("Annotating mixins...")
	for pass := 0; ; pass++ {
		changesMadeInPass := false
		luaFiles.Range(func(pathKey, contentKey interface{}) bool {
			path := pathKey.(string)
			originalContent := contentKey.([]byte)
			reMixin := regexp.MustCompile(`(?m)^([\w\d_]+)\s*=\s*(?:CreateFromMixins\(([\w\d_\.]+)\)|{)`)
			reAnnotation := regexp.MustCompile(`---@class`)

			lines := strings.Split(string(originalContent), "\n")
			var newLines []string
			madeChangeInFile := false

			for i := 0; i < len(lines); i++ {
				line := lines[i]
				matches := reMixin.FindStringSubmatch(line)

				if len(matches) > 0 {
					isAnnotated := i > 0 && reAnnotation.MatchString(lines[i-1])

					if !isAnnotated {
						mixinVar := matches[1]
						parentVar := ""
						if len(matches) > 2 {
							parentVar = matches[2]
						}

						className, isXmlMixin := mixinToName.Load(mixinVar)
						if !isXmlMixin {
							className = mixinVar
						}

						var annotation string
						if parentVar != "" {
							parentClassName, isParentInXml := mixinToName.Load(parentVar)
							if !isParentInXml {
								parentClassName = parentVar
							}
							annotation = fmt.Sprintf("---@class %s: %s", className, parentClassName)
						} else {
							annotation = fmt.Sprintf("---@class %s", className)
						}

						newLines = append(newLines, annotation)
						madeChangeInFile = true
					}
				}
				newLines = append(newLines, line)
			}

			if madeChangeInFile {
				newContent := strings.Join(newLines, "\n")
				luaFiles.Store(path, []byte(newContent))
				changesMadeInPass = true
			}
			return true
		})

		if !changesMadeInPass {
			break
		}

		if pass > 15 {
			fmt.Println("Warning: Exceeded max annotation passes, check for circular dependencies.")
			break
		}
	}

	fmt.Println("Verifying annotations...")
	allLuaMixins.Range(func(mixinKey, pathKey interface{}) bool {
		mixinVar := mixinKey.(string)
		path := pathKey.(string)

		finalContentBytes, _ := luaFiles.Load(path)
		finalContent := string(finalContentBytes.([]byte))
		lines := strings.Split(finalContent, "\n")

		isAnnotated := false
		for i, line := range lines {
			reDef := regexp.MustCompile(`^` + regexp.QuoteMeta(mixinVar) + `\s*=\s*`)
			if reDef.MatchString(line) {
				if i > 0 && strings.HasPrefix(lines[i-1], "---@class") {
					isAnnotated = true
					break
				}
			}
		}

		if !isAnnotated {
			fmt.Printf("Warning: Could not find annotation for mixin variable %s in %s\n", mixinVar, path)
		}

		return true
	})

	fmt.Println("Writing changes to disk...")
	luaFiles.Range(func(key, value interface{}) bool {
		path := key.(string)
		content := value.([]byte)
		info, _ := os.Stat(path)
		os.WriteFile(path, content, info.Mode())
		return true
	})

	return nil
}
