package cmd

import (
	"fmt"
	"os"

	"github.com/Cidan/Moonlight/tools/moonlight/module"
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "moonlight",
	Short: "A helper tool for Moonlight addon development",
	Long: `A helper tool for Moonlight addon development.
This tool provides various commands to help with common tasks.`,
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	rootCmd.AddCommand(module.NewModuleCmd())
}
