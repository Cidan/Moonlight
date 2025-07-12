local moonlight = GetMoonlight()

--- Applies decorations to a window.
---@class decorate
local decorate = moonlight:NewClass("decorate")

--- This is the instance of a decorator, and where the module
--- functionality actually is.
---@class Decorate
---@field borderFrame Frame
---@field closeButton Button
---@field closeButtonDecoration CloseButtonDecoration
local Decorate = {}

--- This creates a new instance of a decorator.
---@param name string
---@return Decorate
function decorate:New(name)
  -- TODO(lobato): Store this decorator, recycle in a pool.
  local instance = {
    borderFrame = CreateFrame("Frame"),
    closeButton = CreateFrame("Button", nil, nil, "ButtonFrameTemplate")
  }
  return setmetatable(instance, {
    __index = Decorate
  })
end

---@class CloseButtonDecoration
---@field Width uiUnit
---@field Height uiUnit
---@field XOffset? uiUnit
---@field YOffset? uiUnit
---@field Text string

---@param w Window
function Decorate:Apply(w)
  local parent = w:GetFrame()
  local cbd = self.closeButtonDecoration
  if cbd ~= nil then
    self.closeButton:SetParent(parent)
    self.closeButton:SetText(cbd.Text)
    self.closeButton:SetSize(cbd.Width, cbd.Height)
    self.closeButton:SetPoint(
      "TOPRIGHT",
      parent,
      "TOPRIGHT",
      cbd.XOffset,
      cbd.YOffset
    )
    self.closeButton:Show()
  end

end

---@param c CloseButtonDecoration
function Decorate:SetCloseButton(c)
  self.closeButtonDecoration = c
end

function Decorate:SetBorder()
end

function Decorate:SetBackground()
end

function Decorate:Release() 
  self.closeButton:ClearAllPoints()
  self.closeButton:SetParent(nil)
  self.closeButton:Hide()

  self.borderFrame:ClearAllPoints()
  self.borderFrame:SetParent(nil)
  self.borderFrame:Hide()
end