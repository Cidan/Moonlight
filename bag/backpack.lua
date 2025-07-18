local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class backpack
local backpack = moonlight:NewClass("backpack")

---@class (exact) Backpack: Bag
---@field container Container
---@field sectionSet Sectionset
---@field bagWidth number
---@field allSectionsByName table<string, Section>
---@field allSectionsByItem table<MoonlightItem, Section>
---@field allItemButtonsByItem table<MoonlightItem, MoonlightItemButton>
---@field allItemsByBagAndSlot table<BagID, table<SlotID, MoonlightItem>>
local Backpack = {}

--- Boot creates the backpack bag.
function backpack:Boot()
  local loader = moonlight:GetLoader()

  Backpack.bagWidth = 300
  local window = moonlight:GetWindow()
  local engine = moonlight:GetSonataEngine()
  local container = moonlight:GetContainer()
  local sectionSet = moonlight:GetSectionset()

  Backpack.allSectionsByItem = {}
  Backpack.allSectionsByName = {}
  Backpack.allItemButtonsByItem = {}
  Backpack.allItemsByBagAndSlot = {}

  Backpack.window = window:New()
  Backpack.sectionSet = sectionSet:New()
  Backpack.container = container:New()

  Backpack.container:Apply(Backpack.window)
  Backpack.container:SetChild(Backpack.sectionSet)

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

  loader:TellMeWhenABagIsUpdated(function(bagid, mixins)
    Backpack:ABagHasBeenUpdated(bagid, mixins)
  end)

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

---@param bagID BagID
---@param slotID SlotID
---@return MoonlightItem
function Backpack:GetItemByBagAndSlot(bagID, slotID)
  local item = moonlight:GetItem()
  if self.allItemsByBagAndSlot[bagID] == nil then
    self.allItemsByBagAndSlot[bagID] = {}
  else
    if self.allItemsByBagAndSlot[bagID][slotID] ~= nil then
      return self.allItemsByBagAndSlot[bagID][slotID]
    end
  end
  local mitem = item:New()
  self.allItemsByBagAndSlot[bagID][slotID] = mitem
  return mitem
end

---@param i MoonlightItem
function Backpack:FigureOutWhereAnItemGoes(i)
  local section = moonlight:GetSection()
  local itemButton = moonlight:GetItembutton()
  if i == nil then
    error("i is nil")
  end
  local data = i:GetItemData()

  -- If the item is empty, we need to find its old section and remove its frame.
  if data.Empty then
    local s = self.allSectionsByItem[i]
    if s ~= nil then
      local frame = self.allItemButtonsByItem[i]
      if frame ~= nil then
        s:RemoveItem(frame)
        self.allItemButtonsByItem[i] = nil
      end
      self.allSectionsByItem[i] = nil
      if s:GetNumberOfChildren() == 0 then
        self.sectionSet:RemoveSection(s)
        self.allSectionsByName[s:GetTitle()] = nil
        s:Release()
      end
    end
    return
  end

  local category = i:GetMoonlightCategory()
  -- Get the section for this item's type.
  local s = self.allSectionsByName[category]
  if s == nil then
    s = section:New()
    s:SetTitle(category)
    self.sectionSet:AddSection(s)
    self.allSectionsByName[category] = s
  end

  -- Check if the item has changed sections.
  local oldSection = self.allSectionsByItem[i]
  if oldSection and oldSection ~= s then
    local frame = self.allItemButtonsByItem[i]
    if frame ~= nil then
      oldSection:RemoveItem(frame)
    end
  end

  -- Update the item's current section.
  self.allSectionsByItem[i] = s

  -- Get or create the frame for the item.
  local frame = self.allItemButtonsByItem[i]
  if frame ~= nil then
    -- The frame already exists, just make sure it's in the right section and update it.
    if s:HasItem(frame) == false then
      s:AddItem(frame)
    end
    frame:Update()
  else
    -- The frame doesn't exist, create it.
    frame = itemButton:New()
    frame:SetItem(i)
    s:AddItem(frame)
    self.allItemButtonsByItem[i] = frame
  end
end

---@param bagID BagID
---@param mixins ItemMixin[]
function Backpack:ABagHasBeenUpdated(bagID, mixins)
  for _, mixin in pairs(mixins) do
    local itemLocation = mixin:GetItemLocation()
    ---@diagnostic disable-next-line: need-check-nil
    ---@type any, SlotID
    local _, slotID = itemLocation:GetBagAndSlot()
    local mitem = self:GetItemByBagAndSlot(bagID, slotID)
    mitem:SetItemMixin(mixin)
    mitem:ReadItemData()
    self:FigureOutWhereAnItemGoes(mitem)
  end
  self.container:RecalculateHeight()
end

function Backpack:BindBagShowAndHideEvents()
  local binds = moonlight:GetBinds()
  binds:OnBagShow(function()
    if self.window:IsVisible() then
      self.window:Hide()
    else
      self.window:Show()
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

function Backpack:Hide(doNotAnimate)
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