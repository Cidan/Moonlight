package module

const ModuleTemplate = `local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class {{.ModuleNameLower}}
local {{.ModuleNameLower}} = moonlight:NewClass("{{.ModuleNameLower}}")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class {{.ModuleName}}
local {{.ModuleName}} = {}

--- This creates a new instance of a module, and optionally, initializes the module.
---@return {{.ModuleName}}
function {{.ModuleNameLower}}:New()
  local instance = {}
  return setmetatable(instance, {
    __index = {{.ModuleName}}
  })
end
`

const BootTemplate = `---@return {{.ModuleNameLower}}
function Moonlight:Get{{.ModuleName}}()
  return self.classes.{{.ModuleNameLower}}
end`
