# Modules

All modules in Moonlight are single file. Under no circumstance should module methods be spread across more than one file.

New module initialization looks like this, but don't actually copy these comments and fields. Just the general class structure, and apply comments that fit the module being made:

```lua
local moonline = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class moduleName
local modulename = moonlight:NewClass("moduleName")

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
  return setmetatable(instance, {
    __index = ModuleName
  })
end
```