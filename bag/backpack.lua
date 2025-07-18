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
---@field isDirty boolean
local Backpack = {}

--- Boot creates the backpack bag.
function backpack:Boot()
  local loader = moonlight:GetLoader()

  Backpack.isDirty = false
  Backpack.bagWidth = 300
  local window = moonlight:GetWindow()
  local engine = moonlight:GetSonataEngine()
  local container = moonlight:GetContainer()
  local sectionSet = moonlight:GetSectionset()
  local bagData = moonlight:GetBagdata()

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
---@return "REDRAW" | "DEFERRED" | "NO_OP"
function Backpack:FigureOutWhereAnItemGoes(i)
  local section = moonlight:GetSection()
  local itemButton = moonlight:GetItembutton()
  if i == nil then
    error("i is nil")
  end
  local data = i:GetItemData()
  local oldSection = self.allSectionsByItem[i]

  -- If the item is empty, we need to find its old section and remove its frame.
  if data.Empty then
    if oldSection == nil then
      -- This item was already gone, nothing to do.
      return "NO_OP"
    end

    -- Item is now empty, so remove it.
    local frame = self.allItemButtonsByItem[i]
    if frame ~= nil then
      oldSection:RemoveItem(frame)
      self.allItemButtonsByItem[i] = nil
    end
    self.allSectionsByItem[i] = nil

    if oldSection:GetNumberOfChildren() == 0 then
      self.sectionSet:RemoveSection(oldSection)
      self.allSectionsByName[oldSection:GetTitle()] = nil
      oldSection:Release()
      return "REDRAW" -- Section was removed, must redraw.
    end

    if self.window:IsVisible() then
      self.isDirty = true
      return "DEFERRED" -- Item removed, but defer redraw.
    end

    return "REDRAW" -- Window not visible, so redraw now.
  end

  -- Item is NOT empty.
  local category = i:GetMoonlightCategory()
  local newSection = self.allSectionsByName[category]
  if newSection == nil then
    newSection = section:New()
    newSection:SetTitle(category)
    self.sectionSet:AddSection(newSection)
    self.allSectionsByName[category] = newSection
  end

  local frame = self.allItemButtonsByItem[i]

  if oldSection == newSection then
    -- Item didn't move sections. Just update its frame.
    if frame ~= nil then
      frame:Update()
    else
      -- This case is weird, item exists but has no frame. Create it.
      frame = itemButton:New()
      frame:SetItem(i)
      newSection:AddItem(frame)
      self.allItemButtonsByItem[i] = frame
      return "REDRAW" -- A frame was added.
    end
    return "NO_OP"
  end

  -- Item moved sections or is new.
  if oldSection ~= nil then
    -- It moved.
    if frame ~= nil then
      oldSection:RemoveItem(frame)
    end
  end

  -- Add to new section.
  if frame == nil then
    frame = itemButton:New()
    frame:SetItem(i)
    self.allItemButtonsByItem[i] = frame
  end
  newSection:AddItem(frame)
  frame:Update()
  self.allSectionsByItem[i] = newSection

  return "REDRAW"
end

---@param bagID BagID
---@param mixins ItemMixin[]
function Backpack:ABagHasBeenUpdated(bagID, mixins)
  local forceRedraw = false
  for _, mixin in pairs(mixins) do
    local itemLocation = mixin:GetItemLocation()
    ---@diagnostic disable-next-line: need-check-nil
    ---@type any, SlotID
    local _, slotID = itemLocation:GetBagAndSlot()
    local mitem = self:GetItemByBagAndSlot(bagID, slotID)
    mitem:SetItemMixin(mixin)
    mitem:ReadItemData()
    local status = self:FigureOutWhereAnItemGoes(mitem)
    if status == "REDRAW" then
      forceRedraw = true
    end
  end

  if forceRedraw then
    self.container:RecalculateHeight()
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
  if self.isDirty then
    self:Redraw()
  end
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