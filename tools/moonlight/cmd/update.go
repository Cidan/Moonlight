package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/Cidan/Moonlight/tools/moonlight/util"
	"github.com/spf13/cobra"
)

// updateCmd represents the update command
var updateCmd = &cobra.Command{
	Use:   "update",
	Short: "Update the moonlight helper tool",
	Long: `This command finds the repository root and runs 'go install' 
to update the moonlight helper tool to the latest version from the source.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("Finding repository root...")
		repoRoot, err := util.FindRepoRoot()
		if err != nil {
			fmt.Printf("Error finding repository root: %v\n", err)
			os.Exit(1)
		}
		fmt.Printf("Repository root found at: %s\n", repoRoot)

		installPath := filepath.Join(repoRoot, "tools", "moonlight")
		fmt.Printf("Running 'go install' on: %s\n", installPath)

		goCmd := exec.Command("go", "install", installPath)
		goCmd.Stdout = os.Stdout
		goCmd.Stderr = os.Stderr

		err = goCmd.Run()
		if err != nil {
			fmt.Printf("Error running 'go install': %v\n", err)
			os.Exit(1)
		}

		fmt.Println("Moonlight helper tool updated successfully!")
	},
}

func init() {
	rootCmd.AddCommand(updateCmd)
}
