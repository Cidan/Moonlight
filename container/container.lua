local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class container
---@field pool Pool
local container = moonlight:NewClass("container")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Container
---@field frame_Container Frame
local Container = {}

---@return Container
local containerConstructor = function()
  local instance = {
    frame_Container = CreateFrame("Frame")
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Container
  })
end

---@param w Container
local containerDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Container
function container:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(containerConstructor, containerDeconstructor)
  end

  return self.pool:TakeOne("Container")
end

---@param w Window
function Container:Apply(w)
end