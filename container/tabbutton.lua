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
---@field slideAwayGroup AnimationGroup
---@field slideBackGroup AnimationGroup
---@field isAway boolean
---@field originalPoint Point | nil
---@field animationDistance number
---@field animationDuration number
local Tabbutton = {}

---@return Tabbutton
local tabbuttonConstructor = function()
  local instance = {
    frame_Button = CreateFrame("Button"),
    isAway = false,
    originalPoint = nil,
    animationDistance = 3,  -- Default value
    animationDuration = 0.3  -- Default value
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Tabbutton
  })
end

---@param w Tabbutton
local tabbuttonDeconstructor = function(w)
  -- Stop and clean up animations
  if w.slideAwayGroup ~= nil then
    w.slideAwayGroup:Stop()
    w.slideAwayGroup = nil
  end
  if w.slideBackGroup ~= nil then
    w.slideBackGroup:Stop()
    w.slideBackGroup = nil
  end
  -- Reset state
  w.isAway = false
  w.originalPoint = nil
  -- Clean up frame
  w.frame_Button:SetParent(nil)
  w.frame_Button:ClearAllPoints()
  w.frame_Button:Hide()
  w.tooltipPosition = nil
  w.tooltipText = nil
  w.frame_Button:ClearNormalTexture()
  w.frame_Button:SetScript("OnClick", nil)
  w.frame_Button:SetScript("OnEnter", nil)
  w.frame_Button:SetScript("OnLeave", nil)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Tabbutton
function tabbutton:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(tabbuttonConstructor, tabbuttonDeconstructor)
  end
  local b = self.pool:TakeOne("Tabbutton")

  b.isAway = false
  b:Show()
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
  -- Store the original point for animation reference
  self.originalPoint = {
    Point = point.Point,
    RelativeTo = point.RelativeTo,
    RelativePoint = point.RelativePoint,
    XOffset = point.XOffset,
    YOffset = point.YOffset
  }

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

---@param distance number
---@param duration number
function Tabbutton:SetAnimationConfig(distance, duration)
  self.animationDistance = distance
  self.animationDuration = duration
  -- Recreate animations with new values
  self:setupAnimations()
end

function Tabbutton:setupAnimations()
  -- Clean up existing animation groups if they exist
  if self.slideAwayGroup ~= nil then
    self.slideAwayGroup:Stop()
  end
  if self.slideBackGroup ~= nil then
    self.slideBackGroup:Stop()
  end

  -- Create animation group for sliding away from frame (on hover)
  self.slideAwayGroup = self.frame_Button:CreateAnimationGroup()
  local slideAway = self.slideAwayGroup:CreateAnimation("Translation")
  slideAway:SetOffset(0, -self.animationDistance)
  slideAway:SetDuration(self.animationDuration)
  slideAway:SetSmoothing("OUT")
  self.slideAwayGroup:SetScript("OnFinished", function()
    if self.originalPoint ~= nil then
      self.frame_Button:ClearAllPoints()
      self.frame_Button:SetPoint(
        self.originalPoint.Point,
        self.originalPoint.RelativeTo,
        self.originalPoint.RelativePoint,
        self.originalPoint.XOffset or 0,
        (self.originalPoint.YOffset or 0) - self.animationDistance
      )
    end
  end)

  -- Create animation group for sliding back to frame (on mouse leave)
  self.slideBackGroup = self.frame_Button:CreateAnimationGroup()
  local slideBack = self.slideBackGroup:CreateAnimation("Translation")
  slideBack:SetOffset(0, self.animationDistance)
  slideBack:SetDuration(self.animationDuration)
  slideBack:SetSmoothing("OUT")
  self.slideBackGroup:SetScript("OnFinished", function()
    if self.originalPoint ~= nil then
      self.frame_Button:ClearAllPoints()
      self.frame_Button:SetPoint(
        self.originalPoint.Point,
        self.originalPoint.RelativeTo,
        self.originalPoint.RelativePoint,
        self.originalPoint.XOffset or 0,
        self.originalPoint.YOffset or 0
      )
    end
  end)

  -- Set up hover scripts for both tooltip and animation
  self.frame_Button:SetScript("OnEnter", function()
    -- Show tooltip
    GameTooltip:SetOwner(self.frame_Button, self.tooltipPosition)
    GameTooltip:SetText(self.tooltipText)
    GameTooltip:Show()

    -- Play slide away animation
    if self.isAway == false and self.slideAwayGroup:IsPlaying() == false then
      -- If slideBack is playing mid-animation, stop it and snap to home position
      if self.slideBackGroup:IsPlaying() == true then
        self.slideBackGroup:Stop()
        -- Snap to home position before starting slideAway
        if self.originalPoint ~= nil then
          self.frame_Button:ClearAllPoints()
          self.frame_Button:SetPoint(
            self.originalPoint.Point,
            self.originalPoint.RelativeTo,
            self.originalPoint.RelativePoint,
            self.originalPoint.XOffset or 0,
            self.originalPoint.YOffset or 0
          )
        end
      end
      self.slideAwayGroup:Play()
      self.isAway = true
    end
  end)

  self.frame_Button:SetScript("OnLeave", function()
    -- Hide tooltip
    GameTooltip:Hide()

    -- Play slide back animation
    if self.isAway == true and self.slideBackGroup:IsPlaying() == false then
      -- If slideAway is playing mid-animation, stop it and snap to away position
      if self.slideAwayGroup:IsPlaying() == true then
        self.slideAwayGroup:Stop()
        -- Snap to away position before starting slideBack
        if self.originalPoint ~= nil then
          self.frame_Button:ClearAllPoints()
          self.frame_Button:SetPoint(
            self.originalPoint.Point,
            self.originalPoint.RelativeTo,
            self.originalPoint.RelativePoint,
            self.originalPoint.XOffset or 0,
            (self.originalPoint.YOffset or 0) - self.animationDistance
          )
        end
      end
      self.slideBackGroup:Play()
      self.isAway = false
    end
  end)
end

function Tabbutton:Show()
  self.frame_Button:Show()
end

function Tabbutton:Hide()
  self.frame_Button:Hide()
end

function Tabbutton:Release()
  tabbutton.pool:GiveBack("Tabbutton", self)
end