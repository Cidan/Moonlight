local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class tabbutton
---@field pool Pool
local tabbutton = moonlight:NewClass("tabbutton")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Tabbutton
---@field frame_Button Button
---@field tooltipText string
---@field tooltipPosition TooltipAnchor
local Tabbutton = {}

---@return Tabbutton
local tabbuttonConstructor = function()
  local instance = {
    frame_Button = CreateFrame("Button")
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Tabbutton
  })
end

---@param w Tabbutton
local tabbuttonDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Tabbutton
function tabbutton:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(tabbuttonConstructor, tabbuttonDeconstructor)
  end
  local b = self.pool:TakeOne("Tabbutton")
  b.frame_Button:SetScript("OnEnter", function()
    GameTooltip:SetOwner(b.frame_Button, b.tooltipPosition)
    GameTooltip:SetText(b.tooltipText)
    GameTooltip:Show()
  end)

  b.frame_Button:SetScript("OnLeave", function()
    GameTooltip:Hide()
  end)
  return b
end

---@param parent Frame
function Tabbutton:SetParent(parent)
  self.frame_Button:SetParent(parent)
end

---@param fn function
function Tabbutton:SetCallbackOnClick(fn)
  self.frame_Button:SetScript("OnClick", fn)
end

---@param width number
---@param height number
function Tabbutton:SetSize(width, height)
  self.frame_Button:SetSize(width, height)
end

---@param point Point
function Tabbutton:SetPoint(point)
  self.frame_Button:SetPoint(
    point.Point,
    point.RelativeTo,
    point.RelativePoint,
    point.XOffset,
    point.YOffset
  )
end

---@return number
function Tabbutton:GetHeight()
  return self.frame_Button:GetHeight()
end

---@return Button
function Tabbutton:GetFrame()
  return self.frame_Button
end

---@param texture fileID | string
function Tabbutton:SetTexture(texture)
  self.frame_Button:SetNormalTexture(texture)
end

---@param text string
function Tabbutton:SetTooltipText(text)
  self.tooltipText = text
end

---@param anchor TooltipAnchor
function Tabbutton:SetTooltipPosition(anchor)
  self.tooltipPosition = anchor
end

function Tabbutton:Release()
  tabbutton.pool:GiveBack("Tabbutton", self)
end