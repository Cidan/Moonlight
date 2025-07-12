local moonlight = GetMoonlight()

--- Applies decorations to a window.
---@class decorate
local decorate = moonlight:NewClass("decorate")

--- This is the instance of a decorator, and where the module
--- functionality actually is.
---@class Decorate
---@field frame_CloseButton Button
---@field frame_Border Frame
---@field decoration_CloseButton CloseButtonDecoration
---@field decoration_Border BorderDecoration
---@field manualFunction fun(w: Window)
local Decorate = {}

--- This creates a new instance of a decorator.
---@param name string
---@return Decorate
function decorate:New(name)
  -- TODO(lobato): Store this decorator, recycle in a pool.
  local instance = {
    borderFrame = CreateFrame("Frame", nil, nil, "MoonlightSimpleFrameTemplate"),
    closeButton = CreateFrame("Button", nil, nil, "UIPanelButtonTemplate")
  }
  return setmetatable(instance, {
    __index = Decorate
  })
end


---@param w Window
function Decorate:Apply(w)
  if self.manualFunction ~= nil then
    self.manualFunction(w)
    return
  end

  local parent = w:GetFrame()
  local cbd = self.closeButtonDecoration
  local borderDecoration = self.decoration_Border

  if cbd ~= nil then
    self.frame_CloseButton:SetParent(parent)
    self.frame_CloseButton:SetText(cbd.Text)
    self.frame_CloseButton:SetSize(cbd.Width, cbd.Height)
    self.frame_CloseButton:SetPoint(
      "TOPRIGHT",
      parent,
      "TOPRIGHT",
      cbd.XOffset,
      cbd.YOffset
    )
    self.frame_CloseButton:Show()
  end

  if borderDecoration ~= nil then
    self.frame_Border:SetParent(parent)
    self.frame_Border:SetAllPoints()
    self.frame_Border:Show()
  end

end

---@param c CloseButtonDecoration
function Decorate:SetCloseButton(c)
  self.closeButtonDecoration = c
end

---@param b BorderDecoration
function Decorate:SetBorder(b)

end

function Decorate:SetBackground()
end

---@param f fun(w: Window)
function Decorate:SetManual(f)
  self.manualFunction = f
end

function Decorate:Release() 
  self.frame_CloseButton:ClearAllPoints()
  self.frame_CloseButton:SetParent(nil)
  self.frame_CloseButton:Hide()

  self.frame_Border:ClearAllPoints()
  self.frame_Border:SetParent(nil)
  self.frame_Border:Hide()
end