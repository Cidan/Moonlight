local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class bagdata
---@field pool Pool
local bagdata = moonlight:NewClass("bagdata")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Bagdata
local Bagdata = {}

---@return Bagdata
local bagdataConstructor = function()
  local instance = {
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Bagdata
  })
end

---@param w Bagdata
local bagdataDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Bagdata
function bagdata:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(bagdataConstructor, bagdataDeconstructor)
  end

  return self.pool:TakeOne("Bagdata")
end
