local moonlight = GetMoonlight()
local context = moonlight:GetContext()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class backpack
local backpack = moonlight:NewClass("backpack")

---@class (exact) Backpack: Bag
local Backpack = {}

--- Boot creates the backpack bag.
function backpack:Boot()
  local window = moonlight:GetWindow()
  local engine = moonlight:GetSonataEngine()
  Backpack.window = window:New()
  
  engine:RegisterBag(Backpack)
end