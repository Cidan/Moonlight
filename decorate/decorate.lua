local moonlight = GetMoonlight()
local pool = moonlight:GetPool()

--- Applies decorations to a window.
---@class decorate
---@field pools table<string, Pool>
local decorate = moonlight:NewClass("decorate")

--- This is the instance of a decorator, and where the module
--- functionality actually is.
---@class (exact) Decorate
---@field name string
---@field attachedTo Window
---@field frame_CloseButton Button
---@field frame_Border Frame
---@field decoration_CloseButton CloseButtonDecoration
---@field decoration_Border BorderDecoration
---@field manual_Create fun(w: Window)
---@field manual_Destroy fun(w: Window)
local Decorate = {}

---@return Decorate
local decorateConstructor = function()
  local instance = {
    frame_Border = CreateFrame("Frame", nil, nil, "MoonlightSimpleFrameTemplate"),
    frame_CloseButton = CreateFrame("Button", nil, nil, "UIPanelButtonTemplate")
  }
  return setmetatable(instance, {
    __index = Decorate
  })
end

---@param d Decorate
local decorateDeconstructor = function(d)
  d:Release()
  table.insert(decorate.pools[d.name], d)
end

--- This creates a new instance of a decorator.
---@param name string
---@return Decorate
function decorate:New(name)
  if self.pools == nil then
    self.pools = {}
  end
  if self.pools[name] == nil then
    self.pools[name] = pool:New(decorateConstructor, decorateDeconstructor)
  end
  d = self.pools[name]:TakeOne("Decorate")
  d.name = name
  return d
end


---@param w Window
function Decorate:Apply(w)
  self.attachedTo = w
  if self.manual_Create ~= nil then
    self.manual_Create(w)
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

---@param create fun(w: Window)
---@param destroy fun(w: Window)
function Decorate:SetManual(create, destroy)
  self.manual_Create = create
  self.manual_Destroy = destroy
end

function Decorate:Release()
  if self.manual_Destroy ~= nil then
    self.manual_Destroy(self.attachedTo)
    self.attachedTo = nil
    return
  end
  self.frame_CloseButton:ClearAllPoints()
  self.frame_CloseButton:SetParent(nil)
  self.frame_CloseButton:Hide()

  self.frame_Border:ClearAllPoints()
  self.frame_Border:SetParent(nil)
  self.frame_Border:Hide()

  self.attachedTo = nil
end