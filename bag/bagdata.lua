local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class bagdata
---@field pool Pool
local bagdata = moonlight:NewClass("bagdata")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Bagdata
---@field sectionSet Sectionset
---@field allSectionsByName table<string, Section>
---@field allSectionsByItem table<MoonlightItem, Section>
---@field allItemButtonsByItem table<MoonlightItem, MoonlightItemButton>
---@field allItemsByBagAndSlot table<BagID, table<SlotID, MoonlightItem>>
---@field drawCallback fun(fullRedraw: boolean)
---@field config BagDataConfig
local Bagdata = {}

---@return Bagdata
local bagdataConstructor = function()
  local sectionSet = moonlight:GetSectionset()
  local instance = {
    allSectionsByItem = {},
    allSectionsByName = {},
    allItemButtonsByItem = {},
    allItemsByBagAndSlot = {},
    sectionSet = sectionSet:New()
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Bagdata
  })
end

---@param w Bagdata
local bagdataDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Bagdata
function bagdata:New()
  local loader = moonlight:GetLoader()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(bagdataConstructor, bagdataDeconstructor)
  end
  local d = self.pool:TakeOne("Bagdata")
  loader:TellMeWhenABagIsUpdated(function(bagid, mixins)
    if d.drawCallback == nil then
      error("a draw callback was not set for bag data, did you call RegisterCallbackWhenItemsChange?")
    end
    if d.config == nil then
      error("there is no config for this bag data, did yo call SetConfig?")
    end
    d:aBagHasBeenUpdated(bagid, mixins)
  end)

  return d
end

---@param c BagDataConfig
function Bagdata:SetConfig(c)
  self.config = c
end

function Bagdata:GetMySectionSet()
  return self.sectionSet
end

---@param f fun(fullRedraw: boolean)
function Bagdata:RegisterCallbackWhenItemsChange(f)
  self.drawCallback = f
end

---@param bagID BagID
---@param slotID SlotID
---@return MoonlightItem
function Bagdata:getItemByBagAndSlot(bagID, slotID)
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
---@return "REDRAW" | "REMOVED" | "NO_OP"
function Bagdata:figureOutWhereAnItemGoes(i)
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
    return "REMOVED" -- Item removed, but defer redraw.
  end

  -- Item is NOT empty.
  ---@type string
  local category
  if self.config.BagNameAsSections == true then
    category = i:GetItemData().BagName
  else
    category = i:GetMoonlightCategory()
  end
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
function Bagdata:aBagHasBeenUpdated(bagID, mixins)
  local forceRedraw = false
  for _, mixin in pairs(mixins) do
    local itemLocation = mixin:GetItemLocation()
    ---@diagnostic disable-next-line: need-check-nil
    ---@type any, SlotID
    local _, slotID = itemLocation:GetBagAndSlot()
    local mitem = self:getItemByBagAndSlot(bagID, slotID)
    mitem:SetItemMixin(mixin)
    mitem:ReadItemData()
    local status = self:figureOutWhereAnItemGoes(mitem)
    if status == "REDRAW" then
      forceRedraw = true
    end
  end

  self.drawCallback(forceRedraw)
end