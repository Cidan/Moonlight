local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class backpack
local backpack = moonlight:NewClass("backpack")

---@class (exact) Backpack: Bag
---@field container Container
---@field bagWidth number
---@field views table<string, Bagdata>
local Backpack = {}

--- Boot creates the backpack bag.
function backpack:Boot()
  Backpack.bagWidth = 300
  local window = moonlight:GetWindow()
  local engine = moonlight:GetSonataEngine()
  local container = moonlight:GetContainer()
  local bagData = moonlight:GetBagdata()
  Backpack.views = {}
  Backpack.window = window:New()

  local sectionView = bagData:New()
  local bagView = bagData:New()
  local oneView = bagData:New()

  Backpack.views["SectionView"] = sectionView
  Backpack.views["BagView"] = bagView
  Backpack.views["OneView"] = oneView

  sectionView:SetConfig({
    BagNameAsSections = false,
    ShowEmptySlots = false,
    CombineAllItems = false
  })

  bagView:SetConfig({
    BagNameAsSections = true,
    ShowEmptySlots = true,
    CombineAllItems = false
  })

  oneView:SetConfig({
    BagNameAsSections = false,
    ShowEmptySlots = true,
    CombineAllItems = true
  })

  sectionView:RegisterCallbackWhenItemsChange(function(fullRedraw)
    if Backpack.window:IsVisible() and not fullRedraw then
      return
    end
    Backpack.container:RecalculateHeight()
  end)

  bagView:RegisterCallbackWhenItemsChange(function(fullRedraw)
    if Backpack.window:IsVisible() and not fullRedraw then
      return
    end
    Backpack.container:RecalculateHeight()
  end)

  oneView:RegisterCallbackWhenItemsChange(function(fullRedraw)
    if Backpack.window:IsVisible() and not fullRedraw then
      return
    end
    Backpack.container:RecalculateHeight()
  end)

  Backpack.container = container:New()
  Backpack.container:SetScrollbarOutsideOfContainer()
  Backpack.container:Apply(Backpack.window)
  Backpack.container:AddChild({
    Name = "Backpack",
    Drawable = sectionView:GetMySectionSet(),
    Icon = [[interface/icons/inv_misc_bag_08.blp]],
    Title = format(
      "%s's Backpack",
      UnitName("player")
    )
  })

  Backpack.container:AddChild({
    Name = "Bags",
    Drawable = bagView:GetMySectionSet(),
    Icon = [[interface/icons/inv_misc_bag_08.blp]],
    Title = format(
      "All Bags"
    )
  })

  Backpack.container:AddChild({
    Name = "Everything",
    Drawable = oneView:GetMySectionSet(),
    Icon = [[interface/icons/inv_misc_bag_08.blp]],
    Title = "All Items"
  })

  Backpack.container:CreateTabsForThisContainer({
    Point = {
      Point = "BOTTOMRIGHT",
      RelativeTo = Backpack.window:GetFrame(),
      RelativePoint = "BOTTOMLEFT",
      XOffset = -15,
      YOffset = 60
    },
    Spacing = 4,
    Orientation = "VERTICAL",
    GrowDirection = "UP",
    TooltipAnchor = "ANCHOR_LEFT"
  })

  Backpack.window:SetWidth(Backpack.bagWidth)
  Backpack.window:SetHeightToScreen()
  Backpack.window:SetPoint({
    Point = "RIGHT",
    RelativeTo = UIParent,
    RelativePoint = "RIGHT"
  })
  Backpack.window:SetStrata("FULLSCREEN")

  engine:RegisterBag(Backpack)

  Backpack:SetupShowAndHideAnimations()
  Backpack:SetSectionSortFunction()
  Backpack:BindBagShowAndHideEvents()

  Backpack.container:SwitchToChild("Backpack")
  Backpack.window:Hide(true)
end

function Backpack:SetupShowAndHideAnimations()
  local showAnimation = moonlight:GetAnimation():New()
  local hideAnimation = moonlight:GetAnimation():New()

  showAnimation:Alpha({
    Start = 0.0,
    End = 1.0,
    Duration = 0.15
  })

  hideAnimation:Alpha({
    Start = 1.0,
    End = 0.0,
    Duration = 0.10
  })

  showAnimation:ApplyShowToWindow(self.window)
  hideAnimation:ApplyHideToWindow(self.window)
end

function Backpack:SetSectionSortFunction()
  --TODO(lobato): Change this at some point since not every child
  -- is a sectionset.
  for _, view in pairs(self.views) do
    view:GetMySectionSet():SetSortFunction(function(a, b)
      return a:GetTitle() < b:GetTitle()
    end)
  end
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