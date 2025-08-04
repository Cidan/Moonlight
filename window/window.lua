local moonlight = GetMoonlight()

--- Window is a display window for Moonlight. A window
--- can have multiple properties for interaction, such as
--- dragging, closing, key binds, events, scrolling, tabs
--- and more.
---@class window
---@field pool Pool
---@field windowCounter number
local window = moonlight:NewClass("window")

---@class Window
---@field title string
---@field baseFrame Frame
---@field decoration SonataDecoration | nil
---@field container Container | nil
---@field showAnimation MoonAnimation | nil
---@field hideAnimation MoonAnimation | nil
---@field eventer Eventer
local Window = {}

---@return Window
local windowConstructor = function()
  local event = moonlight:GetEvent()
  if window.windowCounter == nil then
    window.windowCounter = 1
  else
    window.windowCounter = window.windowCounter + 1
  end
  local instance = {
    baseFrame = CreateFrame(
      "Frame", 
      format("MoonWindow_%d", 
      window.windowCounter)
    ),
    title = "",
    eventer = event:New()
  }

  return setmetatable(instance, {
    __index = Window
  })
end

---@param w Window
local windowDeconstructor = function(w)
  w.eventer:Clear()
end

---@return Window
function window:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(windowConstructor, windowDeconstructor)
  end
  local w = self.pool:TakeOne("Window") 
  w:GetFrame():EnableMouse(true)
  return w
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

---@param height number
function Window:SetHeight(height)
  self.baseFrame:SetHeight(height)
end

function Window:SetHeightToScreen()
  self.baseFrame:SetHeight(GetScreenHeight())
end

---@param f fun(w: Window)
function Window:SetOnShow(f)
  self.baseFrame:SetScript("OnShow", 
    function(...)
      f(self)
    end
  )
end

---@return Frame
function Window:GetFrame()
  return self.baseFrame
end

---@param doNotAnimate boolean | nil
function Window:Show(doNotAnimate)
  if doNotAnimate == true then
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
  if doNotAnimate == true then
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

---@param d SonataDecoration | nil
function Window:SetDecoration(d)
  self.decoration = d
  self:UpdateInsets()
end

---@param c Container
function Window:SetContainer(c)
  self.container = c
end

---@return Container | nil
function Window:GetContainer()
  return self.container
end

---@return SonataWindow | nil
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

---@return Eventer
function Window:GetEventer()
  return self.eventer
end
