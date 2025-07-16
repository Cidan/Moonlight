# Development

Moonlight is developed slightly differently than most other World of Warcraft addons, as it has self-imposed restrictions on what is and is not allowed in the development of the addon.

* Absolutely no third party libraries. This means Ace, LibStub, etc are all explicitly disallowed. All code must be directly sourced within the addon itself. The goal is to be able to checkout this repo directly into the World of Warcraft addon folder and it "just works".

* Annotations are **required** for every facet of the code. This means all functions, parameters, modules -- everything. No exceptions.

* Code should be largely declaritive when interfacing with it externally. That means modules should accept configuration properties, then apply those properties to another module.

* Program defensively. This means use a liberal amount of error checking via if-then statements and error() calls. Do not use assert -- be explicit and use if-then-error.

## Requirements

* Golang 1.24 or greater
* VSCode
* [Rust EmmyLua VSCode Plugin](https://github.com/xuhuanzy/VSCode-EmmyLua-Luals)
* World of Warcraf Retail
* **Do not install Ketho's WoW VSCode Plugin (see below)**

## Moonlight CLI

Moonlight comes packaged with a small helper CLI that automates parts of the development workflow. Install it with:

```bash
go install ./tools/moonlight/.
```

You must have your `$GOPATH/bin` folder in your path. Please see the Go documentation for more information. Once installed, you can run the moonlight command by typing 'moonlight' at the terminal. If you make any changes or additions to 'moonlight' in the repo, simply run `moonlight update` to update your install based on the latest local checkout.

The moonlight command will only work if you are in the moonlight directory.

## Document Generation

Because Moonlight has strict annotation requirements, time has been invested in automating the creation of annotation's based off of the World of Warcraft source and Ketho's WoW documentation annotations.

After cloning, run:

```bash
moonlight anno update
```

to automatically generate and update annotations for the entire World of Warcraft API. This process should only take a few seconds, at which point annotations will be stored in the `annotations` folder. No other configuration is required, and the EmmyLua plugin should pick up everything.

## Module Creation

Moonlight follows a strict module based development flow and naming system. Module creation has been automated via the `moonlight` tool:

```bash
moonlight module create //module/module.lua
```

In the above example, `//` means "repo root". This command would make a new module in the form of `./module/module.lua` in the repo. The module does not get added to Moonlight.toc automatically, and you must do so yourself.

To load your module from another module in Lua, simply use:

```lua
local myModule = moonlight:GetMyModule()
```

Note the name of `GetMyModule()` is whatever you named your lua file, with an uppercase for the first letter, i.e. `//data/data.lua` would produce `moonlight:GetData()`. This construct returns a typed reference to your module.

Module's have a package space (returned by the Get function above), then a module instance space, which is obtained by called New on the module package space:

```lua
local data = moonlight:GetData()

local d = data:New()
```

`New()` returns an instance of data, which is pooled and can optionally be recycled. If desired, a static package can also be created, though this is not automated at the time. 