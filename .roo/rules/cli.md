# Moonlight CLI

The `moonlight` command-line interface (CLI) is a helper tool for Moonlight addon development. It provides several commands to assist with common development tasks.

## The Reporoot URI

The `moonlight` tool uses a `reporoot` URI convention to refer to paths within the repository. This convention allows for specifying a path relative to the repository root, which is identified by the presence of a `go.work` file.

A `reporoot` URI begins with `//`. For example, to refer to the path `tools/moonlight` from anywhere within the repository, you would use the URI `//tools/moonlight`. The tool translates this to the correct absolute path.

## Commands

The `moonlight` tool provides the following commands.

### `module`

This command is used to manage Moonlight modules.

#### `module create [path]`

This command creates a new, empty Moonlight module at the specified `reporoot` URI path. The path must end with a `.lua` extension.

For example, to create a new module named `MyNewModule` in the `modules` directory, run the following command from anywhere in the repository:

```bash
moonlight module create //modules/MyNewModule.lua
```

#### `module delete`

This command is intended to delete a module, but its implementation is not yet complete. It currently performs no action.

### `update`

This command updates the `moonlight` tool to the latest version from the source code. It locates the repository root and runs `go install` on the tool's source directory.