local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class backpack
local backpack = moonlight:NewClass("backpack")

---@class (exact) Backpack: Bag
---@field container Container
---@field sectionSet Sectionset
---@field bagWidth number
---@field data Bagdata
local Backpack = {}

--- Boot creates the backpack bag.
function backpack:Boot()
  Backpack.bagWidth = 300
  local window = moonlight:GetWindow()
  local engine = moonlight:GetSonataEngine()
  local container = moonlight:GetContainer()
  local bagData = moonlight:GetBagdata()

  Backpack.window = window:New()

  Backpack.data = bagData:New()

  Backpack.data:RegisterCallbackWhenItemsChange(function(fullRedraw)
    if Backpack.window:IsVisible() and not fullRedraw then
      return
    end
    Backpack.container:RecalculateHeight()
  end)
  Backpack.sectionSet = Backpack.data:GetMySectionSet()
  Backpack.container = container:New()

  Backpack.container:Apply(Backpack.window)
  Backpack.container:SetChild(Backpack.data:GetMySectionSet())

  Backpack.window:SetWidth(Backpack.bagWidth)
  Backpack.window:SetHeightToScreen()
  Backpack.window:SetPoint({
    Point = "LEFT",
    RelativeTo = UIParent,
    RelativePoint = "RIGHT"
  })
  Backpack.window:SetStrata("FULLSCREEN")
  Backpack.window:SetTitle(
    format(
      "%s's Backpack",
      UnitName("player")
    )
  )
  engine:RegisterBag(Backpack)

  Backpack:SetupShowAndHideAnimations()
  Backpack:SetSectionSortFunction()
  Backpack:BindBagShowAndHideEvents()

--  loader:TellMeWhenABagIsUpdated(function(bagid, mixins)
--    Backpack:ABagHasBeenUpdated(bagid, mixins)
--  end)

  Backpack.container:RecalculateHeight()
  Backpack.window:Hide(true)
end

function Backpack:SetupShowAndHideAnimations()
  local showAnimation = moonlight:GetAnimation():New()
  local hideAnimation = moonlight:GetAnimation():New()

  showAnimation:Slide({
    Direction = SlideDirection.LEFT,
    Duration = 0.2,
    Distance = self.bagWidth,
    ApplyFinalPosition = true
  })

  showAnimation:Alpha({
    Start = 0.0,
    End = 1.0,
    Duration = 0.15
  })

  hideAnimation:Slide({
    Direction = SlideDirection.RIGHT,
    Duration = 0.2,
    Distance = self.bagWidth,
    ApplyFinalPosition = true
  })

  hideAnimation:Alpha({
    Start = 1.0,
    End = 0.0,
    Duration = 0.10
  })

  showAnimation:ApplyOnShow(self.window)
  hideAnimation:ApplyOnHide(self.window)
end

function Backpack:SetSectionSortFunction()
  self.sectionSet:SetSortFunction(function(a, b)
    return a:GetTitle() < b:GetTitle()
  end)
end

function Backpack:BindBagShowAndHideEvents()
  local binds = moonlight:GetBinds()
  binds:OnBagShow(function()
    if self.window:IsVisible() then
      C_Timer.After(0, function()
        self:Hide()
      end)
    else
      C_Timer.After(0, function()
        self:Show()
      end)
    end
  end)
end

function Backpack:GetFrame()
  return self.window:GetFrame()
end

---@param b SonataBag
function Backpack:SetDecoration(b)
  self.window:SetDecoration(b)
end

function Backpack:Redraw()
  self.container:RecalculateHeight()
  self.isDirty = false
end

function Backpack:Hide(doNotAnimate)
  self:Redraw()
  self.window:Hide(doNotAnimate)
end

function Backpack:Show(doNotAnimate)
  self.window:Show(doNotAnimate)
end

function Backpack:GetTitle()
  return self.window:GetTitle()
end
function Backpack:GetWindow()
  return self.window
end