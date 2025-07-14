local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class item
---@field pool Pool
local item = moonlight:NewClass("item")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Item
local Item = {}

---@return Item
local itemConstructor = function()
  local instance = {
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Item
  })
end

---@param w Item
local itemDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Item
function item:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(itemConstructor, itemDeconstructor)
  end

  return self.pool:TakeOne("Item")
end
