local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class backpack
local backpack = moonlight:NewClass("backpack")

---@class (exact) Backpack: Bag
---@field container Container
---@field sectionSet Sectionset
local Backpack = {}

--- Boot creates the backpack bag.
function backpack:Boot()
  local window = moonlight:GetWindow()
  local engine = moonlight:GetSonataEngine()
  local container = moonlight:GetContainer()
  local sectionSet = moonlight:GetSectionset()

  Backpack.window = window:New()
  Backpack.container = container:New()
  Backpack.sectionSet = sectionSet:New()
  Backpack.container:SetChild(Backpack.sectionSet)

  
  engine:RegisterBag(Backpack)
end

function Backpack:GetFrame()
  return self.window:GetFrame()
end

---@param b SonataBag
function Backpack:SetDecoration(b)
  self.window:SetDecoration(b)
end

function Backpack:Hide(doNotAnimate)
  self.window:Hide(doNotAnimate)
end

function Backpack:Show(doNotAnimate)
  self.window:Show(doNotAnimate)
end

function Backpack:GetTitle()
  return self.window:GetTitle()
end