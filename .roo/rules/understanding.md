# Moonlight Project Understanding

This document provides a comprehensive overview of the Moonlight World of Warcraft addon, its architecture, modules, and development tools.

## High-Level Overview

Moonlight is an inventory management addon for World of Warcraft, written in Lua 5.1. It is designed with a strong emphasis on correctness, performance, and maintainability. Key architectural principles include:

- **No Third-Party Libraries:** All code is self-contained within the addon, with the rare exception of `LibStub` if needed for compatibility. This ensures full control over the codebase.
- **Strict Annotations:** Every function, parameter, and module is meticulously annotated using EmmyLua syntax. This aids in static analysis and reduces runtime errors.
- **Modular Design:** The addon is broken down into a collection of cohesive, reusable modules, each with a specific responsibility.
- **Object Pooling:** A generic object pooling system is used extensively to minimize garbage collection and improve performance.
- **Declarative UI:** UIs are built by composing modules and configuring them with tables of options, rather than imperative sequences of calls.
- **Custom CLI Tool:** A Go-based command-line tool, `moonlight`, is provided to automate common development tasks like module creation and annotation generation.

## Key Architectural Patterns

Beyond the core modules, Moonlight employs several key architectural patterns to ensure a smooth and performant user experience.

### Deferred Grid Rendering

A common challenge in inventory addons is the "jumping" or "shifting" of item grids when an item is added or removed. This can lead to a frustrating user experience and accidental clicks. Moonlight solves this with a deferred rendering system.

- **The Problem:** When a user sells an item or an item is otherwise removed from their bags, the `BAG_UPDATE` event fires. A naive implementation would immediately redraw the entire bag, causing all subsequent items in the grid to shift, which is visually jarring.

- **The Solution:** Moonlight's backpack uses a "dirty flag" pattern to defer the grid compaction.
    1. When an item is removed while the backpack window is visible, the item's icon is simply hidden using `Grid:RemoveChildWithoutRedraw`. The grid itself is not immediately re-rendered, so no "jumping" occurs.
    2. A flag, `Backpack.isDirty`, is set to `true`, indicating that the visual state of the grid no longer matches the data model and a redraw is required later.
    3. The full redraw, which compacts the grid and removes empty spaces, is postponed until the backpack window is closed. The `Backpack:Hide` method checks the `isDirty` flag. If it is true, it triggers a full layout recalculation before the hide animation plays.

This approach provides a stable and predictable UI during rapid inventory changes while ensuring the layout is correctly updated in a non-intrusive way. The core logic for this pattern resides in `bag/backpack.lua`, specifically within the `FigureOutWhereAnItemGoes`, `ABagHasBeenUpdated`, and `Hide` methods.

## Core Modules and Systems

### Boot Process (`boot/`)

The addon's startup sequence is managed by the files in the `boot/` directory.

- **`boot/boot.lua`**: This is the first Lua file loaded. It creates the global `Moonlight` object, which serves as the central service locator and namespace for the entire addon. It provides:
    - `Moonlight:NewClass(name)`: A function to register a new module (class) with the system.
    - `Moonlight:Get<ModuleName>()`: A series of getter functions to access the various modules.
    - `Moonlight:Start()`: The main initialization function that is called after the addon has been loaded by the game. It sets up the initial state, hooks into game events, and creates the main UI.
- **`boot/init.lua`**: This is the last file loaded, as defined in `Moonlight.toc`. Its sole purpose is to call `moonlight:Load()`, which registers the `ADDON_LOADED` event to then call `moonlight:Start()`.

### Windowing System (`window/`, `decorate/`, `container/`)

Moonlight features a custom windowing system that is flexible and themeable.

- **`window/window.lua`**: The core of the windowing system. It provides the `Window` class, which represents a top-level frame. Key features include:
    - Sizing and positioning.
    - Showing and hiding, with support for animations.
    - Integration with decorations and containers.
- **`decorate/decorate.lua`**: This module is responsible for the visual appearance of a window. A `Decorate` object can be applied to a `Window` to add:
    - A background texture.
    - A border.
    - A close button.
    - A draggable title bar/handle.
    - Insets that define the content area within the window.
- **`decorate/types.lua`**: Defines the data structures (`CloseButtonDecoration`, `BackgroundDecoration`, etc.) used to configure a `Decorate` object.
- **`container/container.lua`**: Provides a scrollable container for window content. It uses the built-in `WowScrollBox` and `MinimalScrollBar` to create a scrollable area.
- **`container/tab.lua`**: A placeholder for a future tabbing system within containers. Currently unimplemented.

### UI Components (`grid/`, `section/`, `template/`)

- **`grid/grid.lua`**: A powerful and flexible module for creating grids of items. It's used to display inventory items. Key features:
    - Supports both fixed-width and dynamic-width layouts.
    - Configurable item sizes, gaps, and insets.
    - Custom sorting function for grid items.
- **`grid/types.lua`**: Defines the `GridOptions` class for configuring a `Grid`.
- **`section/section.lua`**: Represents a collapsible section containing a grid. This is likely intended for organizing items into categories (e.g., "Armor", "Consumables"). Currently, it's a basic skeleton.
- **`template/`**: Contains simple, reusable XML and Lua templates for UI elements.
    - `simple_button`: A basic button.
    - `simple_frame`: A basic frame with a background texture.

### Animation System (`animation/`)

- **`animation/animation.lua`**: A system for creating and managing animations on UI elements. It supports:
    - **Slide animations**: Moving a frame in a given direction.
    - **Alpha animations**: Fading a frame in or out.
    - Animation groups that can be applied to a `Window`'s `OnShow` and `OnHide` events.
- **`animation/types.lua`**: Defines the types used by the animation system, such as `SlideDirection` and `MoonAnimationSlide`.

### Data Management (`data/`, `constants/`)

- **`data/loader.lua`**: This module is responsible for loading and caching item data from the player's bags. It scans all bags on startup, creates `ItemMixin` objects, and listens for `BAG_UPDATE` events to keep the data current. It uses a callback system to notify other modules of changes.
- **`data/item.lua`**: A placeholder for an `Item` class, which would likely wrap the `ItemMixin` and provide additional functionality.
- **`data/types.lua`**: Defines type aliases for `SlotKey`, `BagID`, and `SlotID`.
- **`constants/const.lua`**: A central place for defining constants, primarily tables of `BagID`s for various bag locations (backpack, bank, etc.).

### Core Utilities (`pool/`, `event/`, `binds/`, `context/`)

- **`pool/pool.lua`**: A generic object pooling implementation. This is a critical utility for performance, as it allows the addon to reuse tables and other objects instead of creating new ones, which helps to reduce the frequency of garbage collection.
- **`event/event.lua`**: A simple event bus that allows for multiple modules to listen to a single game event without each needing to create its own `Frame`.
- **`binds/binds.lua`**: Manages interaction with the default game UI and keybindings. It includes functionality to hide the default Blizzard bags and to hook the `ToggleAllBags` function.
- **`context/context.lua`**: A placeholder module, likely intended for future use in managing state or context across different parts of the addon.

### Debugging (`debug/`)

- **`debug/debug.lua`**: Contains tools for debugging the addon.
    - `DrawBorder`: A function to draw a colored border around any frame, which is useful for visualizing layout and positioning.
    - `NewTestWindow`: A function that creates a complex test window demonstrating many of the addon's features, including windows, decorations, containers, grids, and animations.
- **`debug/debug.xml`**: Defines the XML template for the debug border.

## Development Tooling (`tools/`)

Moonlight includes a custom command-line tool, `moonlight`, written in Go, to aid in development.

- **`tools/moonlight/main.go`**: The main entry point for the CLI.
- **`tools/moonlight/cmd/`**: Contains the definitions for the CLI commands, using the `cobra` library.
    - `root.go`: The root command.
    - `update.go`: The `moonlight update` command, which recompiles and reinstalls the CLI tool.
- **`tools/moonlight/module/`**:
    - `module.go`: Implements the `moonlight module create` command, which generates a new Lua module from a template, including the class file and the necessary entry in `boot/boot.lua`.
    - `template.go`: Contains the Go text templates for the new module files.
- **`tools/moonlight/anno/`**:
    - `anno.go`: Implements the `moonlight anno update` command. This is a crucial part of the development workflow. It clones the `Ketho/vscode-wow-api` and `Gethe/wow-ui-source` repositories, extracts EmmyLua annotations and FrameXML `mixin` information, and generates a comprehensive set of annotations for the entire WoW API. This enables the strict annotation policy of the project.
- **`tools/moonlight/util/`**:
    - `repo.go`: Provides utility functions for finding the repository root (by locating the `go.work` file) and resolving `//` prefixed paths.
    - `fs.go`: Provides filesystem utilities, such as `CopyDir`.

## Root Files

- **`Moonlight.toc`**: The Table of Contents file for the addon. It defines metadata like the title, author, and version, and most importantly, it specifies the order in which the Lua files should be loaded by the game.
- **`.emmyrc.json`**: Configuration file for the EmmyLua VSCode extension, ensuring that it's configured correctly for the project (e.g., using Lua 5.1).
- **`README.md`**: The main documentation for developers, explaining the project's philosophy, setup instructions, and how to use the `moonlight` CLI tool.
- **`go.work`**, **`go.work.sum`**: Go workspace files that define the Go modules included in the project (in this case, just the `moonlight` tool).