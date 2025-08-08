local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class listrow
---@field pool Pool
local listrow = moonlight:NewClass("listrow")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Listrow: Drawable
---@field children Drawable[] An ordered list of the cell drawables that make up this row.
---@field RowData any The raw data for this row, retrieved from the DataProvider.
---@field IsDirty boolean If true, the row needs to be redrawn with the latest data.
local Listrow = {}

---@return Listrow
local listrowConstructor = function()
  local instance = {
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Listrow
  })
end

---@param w Listrow
local listrowDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Listrow
function listrow:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(listrowConstructor, listrowDeconstructor)
  end

  return self.pool:TakeOne("Listrow")
end

function Listrow:Release()
  listrow.pool:GiveBack("Listrow", self)
end