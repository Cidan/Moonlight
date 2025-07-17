local moonlight = GetMoonlight()

--- A module for dealing with debugging and other test functionality.
---@class debug
local debug = moonlight:NewClass("debug")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Debug
local Debug = {}

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Debug
function debug:New()
  local instance = {}
  return setmetatable(instance, {
    __index = Debug
  })
end

---@type table<BagID, table<SlotID, MoonlightItem>>
local itemsByBagAndSlot = {}

---@param bagID BagID
---@param slotID SlotID
---@return MoonlightItem
local function GetItemByBagAndSlot(bagID, slotID)
  local item = moonlight:GetItem()
  if itemsByBagAndSlot[bagID] == nil then
    itemsByBagAndSlot[bagID] = {}
  else
    if itemsByBagAndSlot[bagID][slotID] ~= nil then
      return itemsByBagAndSlot[bagID][slotID]
    end
  end
  local mitem = item:New()
  itemsByBagAndSlot[bagID][slotID] = mitem
  return mitem
end

---@param f Frame
---@param c Color
---@param mouseOver boolean
function Debug:DrawBorder(f, c, mouseOver)
  local border = CreateFrame(
    "Frame",
    nil,
    f,
    ---@diagnostic disable-next-line: generic-constraint-mismatch
    "MoonlightDebugFrameTemplate"
  )

  border:SetAllPoints(f)
  for _, tex in pairs({"TopLeft", "TopRight", "BottomLeft", "BottomRight", "Top", "Bottom", "Left", "Right"}) do
    border[tex]:SetVertexColor(c.R, c.G, c.B, c.A)
  end
  border:SetFrameStrata("HIGH")
  if mouseOver then
    f:HookScript("OnEnter", function() border:Show() end)
    f:HookScript("OnLeave", function() border:Hide() end)
    border:Hide()
  else
    border:Show()
  end
end

---@param f Frame
function Debug:DrawRedBorder(f)
  self:DrawBorder(f, {
    R = 1,
    G = 0,
    B = 0,
    A = 1
  }, false)
end

---@param f Frame
function Debug:DrawGreenBorder(f)
  self:DrawBorder(f, {
    R = 0,
    G = 1,
    B = 0,
    A = 1
  }, false)
end

---@param f Frame
function Debug:DrawBlueBorder(f)
  self:DrawBorder(f, {
    R = 0,
    G = 0,
    B = 1,
    A = 1
  }, false)
end

--- Creates a new test window for debugging.
function Debug:NewTestWindow()
  local loader = moonlight:GetLoader()
  local window = moonlight:GetWindow()
  local engine = moonlight:GetSonataEngine()
  local w = window:New()
  local barWidth = 300
  w:SetSize(barWidth, 300)
  w:SetHeightToScreen()
  w:SetPoint({
    Point = "LEFT",
    RelativeTo = UIParent,
    RelativePoint = "RIGHT"
  })
  w:SetStrata("FULLSCREEN")

  engine:RegisterWindow(w)
  engine:ApplyTheme("default")

  -- Create a container for the window.
  local c = moonlight:GetContainer():New()
  --c:SetScrollbarOutsideOfContainer(true)
  c:Apply(w)

  local showAnimation = moonlight:GetAnimation():New()
  local hideAnimation = moonlight:GetAnimation():New()

  showAnimation:Slide({
    Direction = SlideDirection.LEFT,
    Duration = 0.2,
    Distance = barWidth,
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
    Distance = barWidth,
    ApplyFinalPosition = true
  })

  hideAnimation:Alpha({
    Start = 1.0,
    End = 0.0,
    Duration = 0.10
  })

  showAnimation:ApplyOnShow(w)
  hideAnimation:ApplyOnHide(w)

  local section = moonlight:GetSection()
  local sectionSet = moonlight:GetSectionset()
  local set = sectionSet:New()
  set:SetSortFunction(function(a, b)
    return a:GetTitle() < b:GetTitle()
  end)

  c:SetChild(set)

  ---@type table<string, Section>
  local allSectionsByName = {}

  ---@type table<MoonlightItem, Section>
  local allSectionsByItem = {}

  ---@type table<MoonlightItem, MoonlightItemButton>
  local itemFrames = {}

  ---@param i MoonlightItem
  local adder = function(i)
    local itemButton = moonlight:GetItembutton()
    if i == nil then
      error("i is nil")
    end
    local data = i:GetItemData()

    -- If the item is empty, we need to find its old section and remove its frame.
    if data.Empty then
      local s = allSectionsByItem[i]
      if s ~= nil then
        local frame = itemFrames[i]
        if frame ~= nil then
          s:RemoveItem(frame)
          itemFrames[i] = nil
        end
        allSectionsByItem[i] = nil
        if s:GetNumberOfChildren() == 0 then
          set:RemoveSection(s)
          allSectionsByName[s:GetTitle()] = nil
          s:Release()
        end
      end
      return
    end

    local category = i:GetMoonlightCategory()
    -- Get the section for this item's type.
    local s = allSectionsByName[category]
    if s == nil then
      s = section:New()
      s:SetTitle(category)
      set:AddSection(s)
      allSectionsByName[category] = s
    end

    -- Check if the item has changed sections.
    local oldSection = allSectionsByItem[i]
    if oldSection and oldSection ~= s then
      local frame = itemFrames[i]
      if frame ~= nil then
        oldSection:RemoveItem(frame)
      end
    end

    -- Update the item's current section.
    allSectionsByItem[i] = s

    -- Get or create the frame for the item.
    local frame = itemFrames[i]
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
      itemFrames[i] = frame
    end

  end

  w:SetTitle("Cidan's Bags")
  local binds = moonlight:GetBinds()
  binds:OnBagShow(function()
    if w:IsVisible() then
      C_Timer.After(0, function()
        w:Hide()
      end) 
    else
      C_Timer.After(0, function()
        w:Show()
      end)
    end
  end)

  loader:TellMeWhenABagIsUpdated(function(bagID, mixins)
    for _, mixin in pairs(mixins) do
      local itemLocation = mixin:GetItemLocation()
      ---@diagnostic disable-next-line: need-check-nil
      ---@type any, SlotID
      local _, slotID = itemLocation:GetBagAndSlot()
      local mitem = GetItemByBagAndSlot(bagID, slotID)
      mitem:SetItemMixin(mixin)
      mitem:ReadItemData()
      adder(mitem)
    end
    c:RecalculateHeight()
  end)
  loader:FullRefreshAllBagData()
  w:Hide(true)
end
