package anno

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	"github.com/Cidan/Moonlight/tools/moonlight/util"
	"github.com/go-git/go-git/v5"
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
	URL     string
	Name    string
	SubDirs []string
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
					destDir := filepath.Join(reporoot, "annotations", repo.Name)

					if _, err := os.Stat(destDir); !os.IsNotExist(err) {
						if err := os.RemoveAll(destDir); err != nil {
							return fmt.Errorf("failed to remove existing destination directory: %w", err)
						}
					}

					if err := os.MkdirAll(filepath.Dir(destDir), 0755); err != nil {
						return fmt.Errorf("failed to create destination directory: %w", err)
					}

					if err := util.CopyDir(sourceDir, destDir); err != nil {
						return fmt.Errorf("failed to copy files: %w", err)
					}

					err = filepath.Walk(destDir, func(path string, info fs.FileInfo, err error) error {
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
					if err != nil {
						return err
					}
				}
			}
			return nil
		},
	}
	return cmd
}
