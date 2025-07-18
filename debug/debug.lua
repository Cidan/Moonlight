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