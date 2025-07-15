package anno

import (
	"encoding/xml"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"sync"

	"github.com/Cidan/Moonlight/tools/moonlight/util"
	"github.com/go-git/go-git/v5"
	"github.com/go-git/go-git/v5/plumbing"
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
	Branch        string
	Tag           string
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
					Branch:        "live",
					Tag:           "11.1.7",
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

				cloneOptions := &git.CloneOptions{
					URL:      repo.URL,
					Progress: os.Stdout,
					Depth:    1,
				}

				if repo.Tag != "" {
					cloneOptions.ReferenceName = plumbing.NewTagReferenceName(repo.Tag)
				} else if repo.Branch != "" {
					cloneOptions.ReferenceName = plumbing.NewBranchReferenceName(repo.Branch)
				}

				_, err = git.PlainClone(tempDir, false, cloneOptions)
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
						if err := processMixinAnnotations(destDir, reporoot); err != nil {
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

func processMixinAnnotations(destDir string, reporoot string) error {
	kethoClasses := make(map[string]bool)
	kethoDir := filepath.Join(reporoot, "annotations", "vscode-wow-api", "Annotations/Core")
	if _, err := os.Stat(kethoDir); !os.IsNotExist(err) {
		fmt.Println("Scanning Ketho annotations for existing classes...")
		err := filepath.Walk(kethoDir, func(path string, info fs.FileInfo, err error) error {
			if err != nil {
				return err
			}
			if !info.IsDir() && strings.HasSuffix(info.Name(), ".lua") {
				content, err := os.ReadFile(path)
				if err != nil {
					return err
				}
				reClass := regexp.MustCompile(`---@class\s+([\w\d_]+)`)
				matches := reClass.FindAllStringSubmatch(string(content), -1)
				for _, match := range matches {
					kethoClasses[match[1]] = true
				}
			}
			return nil
		})
		if err != nil {
			return fmt.Errorf("failed to scan ketho annotations: %w", err)
		}
	}

	mixinToName := &sync.Map{}
	nameToInherits := &sync.Map{}
	isFrame := &sync.Map{}
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
					var name, mixin, inherits string
					for _, attr := range se.Attr {
						if attr.Name.Local == "name" {
							name = attr.Value
						}
						if attr.Name.Local == "mixin" {
							mixin = attr.Value
						}
						if attr.Name.Local == "inherits" {
							inherits = attr.Value
						}
					}
					if name != "" && (se.Name.Local == "Frame" || se.Name.Local == "EventFrame") {
						isFrame.Store(name, true)
					}
					if name != "" && mixin != "" {
						mixinToName.Store(mixin, name)
					}
					if name != "" && inherits != "" {
						nameToInherits.Store(name, inherits)
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

			reMixin := regexp.MustCompile(`(?m)^([\w\d_]+)\s*=\s*\n?(?:CreateFromMixins\(([^)]+)\);?|{)`)
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
			content := contentKey.([]byte)

			reMixin := regexp.MustCompile(`(?m)^([\w\d_]+)\s*=\s*\n?(?:CreateFromMixins\(([^)]+)\);?|{)`)
			reAnnotation := regexp.MustCompile(`---@class`)

			matches := reMixin.FindAllSubmatchIndex(content, -1)
			if len(matches) == 0 {
				return true
			}

			fileChanged := false
			for i := len(matches) - 1; i >= 0; i-- {
				match := matches[i]
				matchStart := match[0]

				lineStart := 0
				if j := strings.LastIndex(string(content[:matchStart]), "\n"); j != -1 {
					lineStart = j + 1
				}

				isAnnotated := false
				if lineStart > 0 {
					prevLineStart := 0
					if k := strings.LastIndex(string(content[:lineStart-1]), "\n"); k != -1 {
						prevLineStart = k + 1
					}
					prevLine := content[prevLineStart:lineStart]
					if reAnnotation.Match(prevLine) {
						isAnnotated = true
					}
				}

				if !isAnnotated {
					mixinVar := string(content[match[2]:match[3]])
					if _, exists := kethoClasses[mixinVar]; exists {
						continue
					}
					parentsStr := ""
					if match[4] != -1 && match[5] != -1 {
						parentsStr = string(content[match[4]:match[5]])
					}

					var annotation string
					if parentsStr != "" {
						parentsList := strings.Split(parentsStr, ",")
						var cleanedParents []string
						for _, p := range parentsList {
							cleanedParents = append(cleanedParents, strings.TrimSpace(p))
						}
						annotation = fmt.Sprintf("---@class %s: %s\n", mixinVar, strings.Join(cleanedParents, ", "))
					} else {
						annotation = fmt.Sprintf("---@class %s\n", mixinVar)
					}

					newContent := make([]byte, 0, len(content)+len(annotation))
					newContent = append(newContent, content[:lineStart]...)
					newContent = append(newContent, []byte(annotation)...)
					newContent = append(newContent, content[lineStart:]...)
					content = newContent
					fileChanged = true
				}
			}

			if fileChanged {
				luaFiles.Store(path, content)
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
		content := finalContentBytes.([]byte)

		reMixin := regexp.MustCompile(`(?m)^` + regexp.QuoteMeta(mixinVar) + `\s*=\s*\n?(?:CreateFromMixins\([^)]+\);?|{)`)
		reAnnotation := regexp.MustCompile(`---@class`)

		match := reMixin.FindIndex(content)
		if match == nil {
			return true
		}

		matchStart := match[0]
		lineStart := 0
		if j := strings.LastIndex(string(content[:matchStart]), "\n"); j != -1 {
			lineStart = j + 1
		}

		isAnnotated := false
		if lineStart > 0 {
			prevLineStart := 0
			if k := strings.LastIndex(string(content[:lineStart-1]), "\n"); k != -1 {
				prevLineStart = k + 1
			}
			prevLine := content[prevLineStart:lineStart]
			if reAnnotation.Match(prevLine) {
				isAnnotated = true
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

	fmt.Println("Generating mixin inheritance file...")
	var generatedContent strings.Builder
	generatedContent.WriteString("---@meta\n\n")

	nameToParents := make(map[string][]string)
	mixinToName.Range(func(key, value interface{}) bool {
		mixin := key.(string)
		name := value.(string)
		nameToParents[name] = append(nameToParents[name], mixin)
		return true
	})
	nameToInherits.Range(func(key, value interface{}) bool {
		name := key.(string)
		inheritsStr := value.(string)
		inheritsList := strings.Split(inheritsStr, ",")
		for _, p := range inheritsList {
			trimmed := strings.TrimSpace(p)
			if trimmed != "" {
				nameToParents[name] = append(nameToParents[name], trimmed)
			}
		}
		return true
	})
	isFrame.Range(func(key, value interface{}) bool {
		name := key.(string)
		if value.(bool) {
			nameToParents[name] = append(nameToParents[name], "Frame")
		}
		return true
	})

	resolvedHierarchies := make(map[string][]string)
	var getFullHierarchy func(name string, path map[string]bool) []string
	getFullHierarchy = func(name string, path map[string]bool) []string {
		if cached, ok := resolvedHierarchies[name]; ok {
			return cached
		}
		if path[name] {
			fmt.Printf("Warning: Circular dependency detected for %s\n", name)
			return nil
		}
		path[name] = true

		allParentsSet := make(map[string]bool)
		if directParents, ok := nameToParents[name]; ok {
			for _, parent := range directParents {
				allParentsSet[parent] = true
				grandParents := getFullHierarchy(parent, path)
				for _, gp := range grandParents {
					allParentsSet[gp] = true
				}
			}
		}

		delete(path, name)

		allParentsList := make([]string, 0, len(allParentsSet))
		for p := range allParentsSet {
			allParentsList = append(allParentsList, p)
		}
		sort.Strings(allParentsList)
		resolvedHierarchies[name] = allParentsList
		return allParentsList
	}

	allNames := make(map[string]bool)
	mixinToName.Range(func(key, value interface{}) bool {
		allNames[value.(string)] = true
		return true
	})
	nameToInherits.Range(func(key, value interface{}) bool {
		allNames[key.(string)] = true
		return true
	})

	sortedNames := make([]string, 0, len(allNames))
	for name := range allNames {
		sortedNames = append(sortedNames, name)
	}
	sort.Strings(sortedNames)

	for _, name := range sortedNames {
		if strings.HasPrefix(name, "$") {
			continue
		}
		if _, exists := kethoClasses[name]; exists {
			continue
		}
		parents := getFullHierarchy(name, make(map[string]bool))
		if len(parents) > 0 {
			generatedContent.WriteString(fmt.Sprintf("---@class %s: %s\n\n", name, strings.Join(parents, ", ")))
		}
	}

	generatedPath := filepath.Join(reporoot, "annotations", "generated", "generated.lua")
	if err := os.WriteFile(generatedPath, []byte(generatedContent.String()), 0644); err != nil {
		return fmt.Errorf("failed to write generated annotations file: %w", err)
	}

	return nil
}
