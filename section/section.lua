local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class section
---@field pool Pool
local section = moonlight:NewClass("section")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Section
local Section = {}

---@return Section
local sectionConstructor = function()
  local instance = {
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Section
  })
end

---@param w Section
local sectionDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Section
function section:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(sectionConstructor, sectionDeconstructor)
  end

  return self.pool:TakeOne("Section")
end
