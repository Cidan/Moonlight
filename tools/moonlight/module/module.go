package module

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"text/template"
	"unicode"

	"github.com/Cidan/Moonlight/tools/moonlight/util"
	"github.com/spf13/cobra"
)

// NewModuleCmd creates and returns the module command with its subcommands.
func NewModuleCmd() *cobra.Command {
	// moduleCmd represents the module command
	var moduleCmd = &cobra.Command{
		Use:   "module",
		Short: "Manage Moonlight modules",
		Long:  `A parent command to manage Moonlight modules, such as creating or deleting them.`,
	}

	// createCmd represents the create command
	var createCmd = &cobra.Command{
		Use:   "create [path]",
		Short: "Create a new Moonlight module",
		Long:  `Creates a new, empty Moonlight module at the specified repo URI path (e.g. //folder/MyModule.lua).`,
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			uriPath := args[0]
			if !strings.HasSuffix(uriPath, ".lua") {
				return fmt.Errorf("path must end with a .lua extension")
			}

			filePath, err := util.GetRepoPath(uriPath)
			if err != nil {
				return fmt.Errorf("invalid repo path: %w", err)
			}

			if _, err := os.Stat(filePath); !os.IsNotExist(err) {
				return fmt.Errorf("file already exists at: %s", filePath)
			}

			baseName := strings.TrimSuffix(filepath.Base(filePath), ".lua")
			if baseName == "" {
				return fmt.Errorf("could not determine module name from path")
			}

			// Create ModuleName (e.g. newBag -> NewBag)
			var moduleName string
			if r := rune(baseName[0]); unicode.IsLower(r) {
				moduleName = string(unicode.ToUpper(r)) + baseName[1:]
			} else {
				moduleName = baseName
			}

			// Create moduleNameLower (e.g. NewBag -> newBag)
			var moduleNameLower string
			if r := rune(moduleName[0]); unicode.IsUpper(r) {
				moduleNameLower = string(unicode.ToLower(r)) + moduleName[1:]
			} else {
				moduleNameLower = moduleName
			}

			tmpl, err := template.New("module").Parse(ModuleTemplate)
			if err != nil {
				return fmt.Errorf("failed to parse module template: %w", err)
			}

			// Ensure the directory exists
			if err := os.MkdirAll(filepath.Dir(filePath), os.ModePerm); err != nil {
				return fmt.Errorf("failed to create directory: %w", err)
			}

			file, err := os.Create(filePath)
			if err != nil {
				return fmt.Errorf("failed to create module file: %w", err)
			}
			defer file.Close()

			data := struct {
				ModuleName      string
				ModuleNameLower string
			}{
				ModuleName:      moduleName,
				ModuleNameLower: moduleNameLower,
			}

			err = tmpl.Execute(file, data)
			if err != nil {
				return fmt.Errorf("failed to execute template: %w", err)
			}

			fmt.Printf("Module '%s' created at %s\n", moduleName, filePath)
			return nil
		},
	}

	// deleteCmd represents the delete command
	var deleteCmd = &cobra.Command{
		Use:   "delete",
		Short: "Delete a Moonlight module",
		Long:  `Deletes an existing Moonlight module by name.`,
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Println("module delete called (noop)")
		},
	}

	moduleCmd.AddCommand(createCmd)
	moduleCmd.AddCommand(deleteCmd)
	return moduleCmd
}
