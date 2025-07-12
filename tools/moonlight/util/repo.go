package util

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// FindRepoRoot walks the tree upwards until a go.work file is found,
// and returns the absolute path to the dir the go.work file is in.
func FindRepoRoot() (string, error) {
	dir, err := os.Getwd()
	if err != nil {
		return "", fmt.Errorf("failed to get current directory: %w", err)
	}

	for {
		// Check if go.work exists in the current directory
		goWorkPath := filepath.Join(dir, "go.work")
		if _, err := os.Stat(goWorkPath); err == nil {
			return dir, nil
		}

		// Move up one directory
		parentDir := filepath.Dir(dir)
		if parentDir == dir {
			// Reached the root of the filesystem
			return "", fmt.Errorf("go.work file not found in any parent directory")
		}
		dir = parentDir
	}
}

// GetRepoPath translates any URI path starting with "//" to an absolute location
// relative to the repo root. for example, "//tools/moonlight" would return
// the absolute path to tools/moonlight
func GetRepoPath(path string) (string, error) {
	if !strings.HasPrefix(path, "//") {
		return path, nil
	}

	repoRoot, err := FindRepoRoot()
	if err != nil {
		return "", fmt.Errorf("failed to find repo root: %w", err)
	}

	relativePath := strings.TrimPrefix(path, "//")
	return filepath.Join(repoRoot, relativePath), nil
}
