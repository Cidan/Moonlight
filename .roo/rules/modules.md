# Modules

All modules in Moonlight are single file. Under no circumstance should module methods be spread across more than one file.

New module initialization looks like this (note the comments and pay attention to them closely, replace the text in the comments to fit the new module):

```lua
--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class moduleName
local modulename = {}

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class ModuleName
---@field APublicString string
---@field aPrivateString string
local ModuleName = {}

--- This creates a new instance of a module, and optionally, initializes the module.
---@return ModuleName
function moduleName:New()
  local instance = {}
  return setmetatable(instance, ModuleName)
end
```