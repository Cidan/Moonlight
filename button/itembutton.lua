local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class itembutton
---@field pool Pool
---@field MasqueGroup MasqueGroup
local itembutton = moonlight:NewClass("itembutton")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class MoonlightItemButton: Drawable
---@field frame_Button ContainerFrameItemButton
---@field Item MoonlightItem
local MoonlightItemButton = {}

---@return MoonlightItemButton
local itembuttonConstructor = function()
  local b = CreateFrame("ItemButton", nil, nil, "ContainerFrameItemButtonTemplate")
  local instance = {
    frame_Button = b
    -- Define your instance variables here
  }

  --- Masque intergration
  local Masque = moonlight:GetStub():GetAddon("Masque", "Masque")
  if Masque ~= nil then
    if itembutton.MasqueGroup == nil then
      itembutton.MasqueGroup = Masque:Group("Moonlight")
    end
    itembutton.MasqueGroup:AddButton(b, nil, "Item")
  end

  return setmetatable(instance, {
    __index = MoonlightItemButton
  })
end

---@param w MoonlightItemButton
local itembuttonDeconstructor = function(w)
  local b = w.frame_Button
  b:SetBagID(0)
  b:SetID(0)
  b:UpdateExtended()
  b:UpdateQuestItem(false)
  b:SetItem(nil)
  b:SetHasItem(nil)
  b:SetItemButtonTexture(nil)
  b:SetItemButtonCount(1)
  b:UpdateCooldown(nil)
  b:UpdateNewItem(1)
  ClearItemButtonOverlay(b)
  b:ClearNormalTexture()
  --w.frame_Button:Reset()
  w:SetParent(nil)
  w:Hide()
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return MoonlightItemButton
function itembutton:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(itembuttonConstructor, itembuttonDeconstructor)
  end

  return self.pool:TakeOne("MoonlightItemButton")
end

---@param mitem MoonlightItem
function MoonlightItemButton:SetItem(mitem)
  if self.Item ~= nil then
    error("MoonlightItemButton is immutable and can not be set twice. did you mean to update?")
  end
  self.Item = mitem
  self:Update()
end

function MoonlightItemButton:Update()
  if self.Item == nil then
    error("MoonlightItemButton does not have an item set. Did you mean to SetItem?")
  end
  local data = self.Item:GetItemData()
  local b = self.frame_Button

  -- Properties for both empty and not empty item slots.
  b:SetBagID(data.BagID)
  b:SetID(data.SlotID)
  b:UpdateExtended()
  b:UpdateQuestItem(false)
  b:UpdateNewItem(1)
  ClearItemButtonOverlay(b)
  b:ClearNormalTexture()

  if data.Empty then
    b:SetItem(nil)
    b:SetHasItem(nil)
    b:SetItemButtonTexture(nil)
    b:SetItemButtonCount(1)
    b:Show()
    return
  end

  b:SetItem(data.ItemLink)
  b:SetHasItem(data.ItemIcon)
  b:SetItemButtonTexture(data.ItemIcon)
  b:SetItemButtonCount(data.ItemStackedCount)
  SetItemButtonQuality(b, data.ItemQuality, data.ItemLink, false, false)
  b:UpdateCooldown(data.ItemIcon)

  b:Show()
end

---@param width number
---@return number
function MoonlightItemButton:Redraw(width)
  return width
end

function MoonlightItemButton:ClearAllPoints()
  self.frame_Button:ClearAllPoints()
end

---@param parent? SimpleFrame
function MoonlightItemButton:SetParent(parent)
  self.frame_Button:SetParent(parent)
end

---@param point Point
function MoonlightItemButton:SetPoint(point)
  PixelUtil.SetPoint(
    self.frame_Button,
    point.Point,
    point.RelativeTo,
    point.RelativePoint,
    point.XOffset,
    point.YOffset,     
    point.XOffset,
    point.YOffset     
  )
end

---@param width number
---@param height number
function MoonlightItemButton:SetSize(width, height)
  PixelUtil.SetSize(self.frame_Button, width, height, width, height)
  ---@diagnostic disable-next-line: param-type-not-match
  self.frame_Button.IconBorder:SetTexelSnappingBias(0)
  self.frame_Button.IconBorder:SetSnapToPixelGrid(false)
  PixelUtil.SetSize(self.frame_Button.IconBorder, width, height, width, height)
  PixelUtil.SetSize(self.frame_Button.NewItemTexture, width, height, width, height)
  PixelUtil.SetSize(self.frame_Button.IconQuestTexture, width, height, width, height)
  PixelUtil.SetSize(self.frame_Button.IconOverlay, width, height, width, height)
  if itembutton.MasqueGroup ~= nil then
    itembutton.MasqueGroup:ReSkin(self.frame_Button)
  end
end

function MoonlightItemButton:Hide()
  self.frame_Button:Hide()
end

function MoonlightItemButton:GetID()
  return self.frame_Button:GetID()
end

function MoonlightItemButton:GetSortKey()
  if self.sortKey == nil then
    error("attempted to get a sort key when the sort key was not set. did you call SetSortKey?")
  end
  return self.sortKey
end

function MoonlightItemButton:SetSortKey(key)
  self.sortKey = key
end

function MoonlightItemButton:Show()
  self.frame_Button:Show()
end

---@return MoonlightItem
function MoonlightItemButton:GetItemData()
  return self.Item
end

function MoonlightItemButton:ReleaseBackToPool()
  itembutton.pool:GiveBack("MoonlightItemButton", self)
end