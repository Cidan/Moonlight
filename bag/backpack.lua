local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class backpack
local backpack = moonlight:NewClass("backpack")

---@class Backpack: Bag
local Backpack = {}

--- Boot creates the backpack bag.
function backpack:Boot()
  local engine = moonlight:GetSonataEngine()
  engine:RegisterBag(Backpack)
end
