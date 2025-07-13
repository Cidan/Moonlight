local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class grid
---@field pool Pool
local grid = moonlight:NewClass("grid")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Grid
---@field frame_Frame Frame
local Grid = {}

---@return Grid
local gridConstructor = function()
  local instance = {
    frame_Frame = CreateFrame("Frame")
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Grid
  })
end

---@param w Grid
local gridDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Grid
function grid:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(gridConstructor, gridDeconstructor)
  end

  return self.pool:TakeOne("Grid")
end
