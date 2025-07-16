local moonlight = GetMoonlight()
local context = moonlight:GetContext()

--- Window is a display window for Moonlight. A window
--- can have multiple properties for interaction, such as
--- dragging, closing, key binds, events, scrolling, tabs
--- and more.
---@class window
---@field pool Pool
local window = moonlight:NewClass("window")

---@class Window
---@field title string
---@field baseFrame Frame
---@field decoration Decorate | nil
---@field container Container | nil
---@field showAnimation MoonAnimation | nil
---@field hideAnimation MoonAnimation | nil
local Window = {}

---@return Window
local windowConstructor = function()
  local instance = {
    baseFrame = CreateFrame("Frame"),
    title = ""
  }
  return setmetatable(instance, {
    __index = Window
  })
end

---@param w Window
local windowDeconstructor = function(w)
end

---@return Window
function window:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(windowConstructor, windowDeconstructor)
  end

  return self.pool:TakeOne("Window")
end

--- Sets the point of the window.
---@param point Point
function Window:SetPoint(point)
  self.baseFrame:SetPoint(
    point.Point,
    point.RelativeTo,
    point.RelativePoint,
    point.XOffset, 
    point.YOffset
  )
end

--- Sets the size of the window.
---@param width number
---@param height number
function Window:SetSize(width, height)
  self.baseFrame:SetSize(width, height)
end

---@param width number
function Window:SetWidth(width)
  self.baseFrame:SetWidth(width)
end

function Window:SetHeightToScreen()
  self.baseFrame:SetHeight(GetScreenHeight())
end

---@param f fun(ctx: Context, w: Window)
function Window:SetOnShow(f)
  self.baseFrame:SetScript("OnShow", 
    function(...)
      local ctx = context:New()
      f(ctx, self)
    end
  )
end

---@return Frame
function Window:GetFrame()
  return self.baseFrame
end

---@param doNotAnimate boolean | nil
function Window:Show(doNotAnimate)
  if doNotAnimate then
    self.baseFrame:Show()
    return
  end
  if self.hideAnimation == nil then
    error("attempting to show window without animation attached")
  end
  if self.showAnimation == nil then
    error("attempting to show window without animation attached")
  end

  self.showAnimation:Play(self.hideAnimation)
end

---@param doNotAnimate boolean | nil
function Window:Hide(doNotAnimate)
  if doNotAnimate then
    self.baseFrame:Hide()
    return
  end
  if self.hideAnimation == nil then
    error("attempting to hide window without animation attached")
  end
  if self.showAnimation == nil then
    error("attempting to hide window without animation attached")
  end

  self.hideAnimation:Play(self.showAnimation)
end

---@return boolean
function Window:IsVisible()
  return self.baseFrame:IsVisible()
end

function Window:UpdateInsets()
  if self.container ~= nil then
    self.container:UpdateInsets()
  end
end

---@param d Decorate | nil
function Window:SetDecoration(d)
  self.decoration = d
  self:UpdateInsets()
end

---@return Decorate | nil
function Window:GetDecoration()
  return self.decoration
end

---@return Insets | nil
function Window:GetInsets()
  if self.decoration ~= nil then
    return self.decoration:GetInsets()
  end
end

---@param a MoonAnimation
function Window:SetShowAnimation(a)
  self.showAnimation = a
end

---@param a MoonAnimation
function Window:SetHideAnimation(a)
  self.hideAnimation = a
end

---@param title string
function Window:SetTitle(title)
  self.title = title
  local decoration = self:GetDecoration()
  if decoration ~= nil then  
    decoration.text_Title:SetText(title)
  end
end

---@return string
function Window:GetTitle()
  return self.title
end

---@param strata FrameStrata
function Window:SetStrata(strata)
  self:GetFrame():SetFrameStrata(strata)
end