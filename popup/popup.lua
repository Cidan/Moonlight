local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class popup
---@field pool Pool
local popup = moonlight:NewClass("popup")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Popup
local Popup = {}

---@return Popup
local popupConstructor = function()
  local instance = {
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Popup
  })
end

---@param w Popup
local popupDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Popup
function popup:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(popupConstructor, popupDeconstructor)
  end

  return self.pool:TakeOne("Popup")
end
