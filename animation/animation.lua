local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class animation
---@field pool Pool
local animation = moonlight:NewClass("animation")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class (exact) MoonAnimation
---@field slides MoonAnimationSlide[]
---@field alpha MoonAnimationAlpha
---@field group AnimationGroup
---@field totalTranslationX number
---@field totalTranslationY number
local MoonAnimation = {}

---@return MoonAnimation
local animationConstructor = function()
  local instance = {
    slides = {},
    totalTranslationX = 0,
    totalTranslationY = 0
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = MoonAnimation
  })
end

---@param w MoonAnimation
local animationDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return MoonAnimation
function animation:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(animationConstructor, animationDeconstructor)
  end

  return self.pool:TakeOne("MoonAnimation")
end

---@param s MoonAnimationSlide
function MoonAnimation:Slide(s)
  table.insert(self.slides, s)
end

---@param a MoonAnimationAlpha
function MoonAnimation:Alpha(a)
  self.alpha = a
end

---@param r Region
function MoonAnimation:generateSlide(r)
  local group = self.group
  ---@type number, number
  for _, slide in pairs(self.slides) do
    local ani = group:CreateAnimation("Translation")
    ani:SetSmoothing("OUT")

    ---@type number, number
    local xof, yof = 0, 0
    if slide.Direction == SlideDirection.LEFT then
      xof = -slide.Distance
    elseif slide.Direction == SlideDirection.RIGHT then
      xof = slide.Distance
    elseif slide.Direction == SlideDirection.UP then
      yof = slide.Distance
    elseif slide.Direction == SlideDirection.DOWN then
      yof = -slide.Distance
    end
    ani:SetOffset(xof, yof)
    if slide.ApplyFinalPosition then
      self.totalTranslationX = self.totalTranslationX + xof
      self.totalTranslationY = self.totalTranslationY + yof
    end

    ani:SetDuration(slide.Duration)
  end

end

---@param r Region
function MoonAnimation:generateAlpha(r)
  if self.alpha == nil then
    return
  end
  local group = self.group
  local ani = group:CreateAnimation("Alpha")
  ani:SetFromAlpha(self.alpha.Start)
  ani:SetToAlpha(self.alpha.End)
  ani:SetSmoothing("OUT")
  ani:SetDuration(self.alpha.Duration)
end

---@param w Window
function MoonAnimation:ApplyOnShow(w)
  assert(self.group == nil, "an animation can only apply to one object")
  local group = w:GetFrame():CreateAnimationGroup()
  self.group = group
  group:SetScript("OnPlay", function()
    w:Show(true)
  end)
  group:SetScript("OnFinished", function()
    local point, relativeTo, relativePoint, xof, yof = w:GetFrame():GetPoint()
    w:GetFrame():SetPoint(
      point,
      relativeTo,
      relativePoint,
      xof + self.totalTranslationX,
      yof + self.totalTranslationY
    )
  end)

  self:generateSlide(w:GetFrame())
  self:generateAlpha(w:GetFrame())

  w:SetShowAnimation(self)
end

---@param w Window
function MoonAnimation:ApplyOnHide(w)
  assert(self.group == nil, "an animation can only apply to one object")
  local group = w:GetFrame():CreateAnimationGroup()
  self.group = group
  group:SetScript("OnFinished", function()
    local point, relativeTo, relativePoint, xof, yof = w:GetFrame():GetPoint()
    w:GetFrame():SetPoint(
      point,
      relativeTo,
      relativePoint,
      xof + self.totalTranslationX,
      yof + self.totalTranslationY
    )
    w:Hide(true)
  end)

  self:generateSlide(w:GetFrame())
  self:generateAlpha(w:GetFrame())

  w:SetHideAnimation(self)
end

---@param inverseAnimation MoonAnimation | nil
function MoonAnimation:Play(inverseAnimation)
  if self:IsPlaying() or (inverseAnimation ~= nil and inverseAnimation:IsPlaying()) then
    return
  end
  self.group:Play()
end

---@return boolean
function MoonAnimation:IsPlaying()
  return self.group:IsPlaying()
end

function MoonAnimation:Stop()
  self.group:Stop()
end

function MoonAnimation:Pause()
  self.group:Pause()
end

---@return number
function MoonAnimation:GetElapsed()
  return self.group:GetElapsed()
end