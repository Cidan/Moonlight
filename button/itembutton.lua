local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class itembutton
---@field pool Pool
local itembutton = moonlight:NewClass("itembutton")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class MoonlightItemButton: Drawable
---@implements Drawable
---@field frame_Button ContainerFrameItemButton
local MoonlightItemButton = {}

---@return MoonlightItemButton
local itembuttonConstructor = function()
  local b = CreateFrame("ItemButton", nil, nil, "ContainerFrameItemButtonTemplate")
  local instance = {
    frame_Button = b
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = MoonlightItemButton
  })
end

---@param w MoonlightItemButton
local itembuttonDeconstructor = function(w)
  w.frame_Button:Reset()
  w:SetParent(UIParent)
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
  local data = mitem:GetItemData()
  local b = self.frame_Button
  if data.Empty then
    b:Hide()
    return
  end

  b:SetBagID(data.BagID)
  b:SetID(data.SlotID)
  b:UpdateExtended()
  b:UpdateQuestItem(false)
  b:SetItem(data.ItemLink)
  b:SetHasItem(data.ItemIcon)
  b:SetItemButtonTexture(data.ItemIcon)
  b:SetItemButtonCount(1)
  SetItemButtonQuality(b, 1, data.ItemLink, false, false)
  b:UpdateCooldown(data.ItemIcon)
  b:UpdateNewItem(1)
  ClearItemButtonOverlay(b)
  b:ClearNormalTexture()
end

---@param width number
---@return number
function MoonlightItemButton:Redraw(width)
  self.frame_Button:SetSize(width, width)
  return width
end

function MoonlightItemButton:ClearAllPoints()
  self.frame_Button:ClearAllPoints()
end

---@param parent SimpleFrame?
function MoonlightItemButton:SetParent(parent)
  self.frame_Button:SetParent(parent)
end

---@param point Point
function MoonlightItemButton:SetPoint(point)
  self.frame_Button:SetPoint(
   point.Point,
   point.RelativeTo,
   point.RelativePoint,
   point.XOffset,
   point.YOffset 
  )
end

---@param width number
---@param height number
function MoonlightItemButton:SetSize(width, height)
  self.frame_Button:SetSize(width, height)
  self.frame_Button.IconBorder:SetSize(width, height)
end

function MoonlightItemButton:Hide()
  self.frame_Button:Hide()
end

function MoonlightItemButton:GetID()
  return self.frame_Button:GetID()
end

function MoonlightItemButton:Show()
  self.frame_Button:Show()
end

function MoonlightItemButton:ReleaseBackToPool()
  itembutton.pool:GiveBack("MoonlightItemButton", self)
end