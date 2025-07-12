package util

import (
	"io"
	"os"
	"path/filepath"
)

// CopyDir recursively copies a directory from src to dst.
func CopyDir(src, dst string) error {
	return filepath.Walk(src, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		// calculate the new path
		relPath, err := filepath.Rel(src, path)
		if err != nil {
			return err
		}
		newPath := filepath.Join(dst, relPath)

		if info.IsDir() {
			return os.MkdirAll(newPath, info.Mode())
		}

		// copy the file
		srcFile, err := os.Open(path)
		if err != nil {
			return err
		}
		defer srcFile.Close()

		dstFile, err := os.Create(newPath)
		if err != nil {
			return err
		}
		defer dstFile.Close()

		if _, err := io.Copy(dstFile, srcFile); err != nil {
			return err
		}

		return nil
	})
}
