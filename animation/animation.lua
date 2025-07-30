local moonlight = GetMoonlight()

---@enum MoonAnimationType
MoonAnimationType = {
  SLIDE = "slide",
  ALPHA = "alpha",
  SCALE = "scale",
}

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class animation
---@field pool Pool
local animation = moonlight:NewClass("animation")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case.
---@class (exact) MoonAnimation
---@field group AnimationGroup
---@field config MoonAnimationConfig[]
---@field totalTranslationX number
---@field totalTranslationY number
local MoonAnimation = {}

---@return MoonAnimation
local animationConstructor = function()
  local instance = {
    totalTranslationX = 0,
    totalTranslationY = 0
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = MoonAnimation
  })
end

---@param _w MoonAnimation
local animationDeconstructor = function(_w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return MoonAnimation
function animation:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(animationConstructor, animationDeconstructor)
  end

  return self.pool:TakeOne("MoonAnimation")
end

---@param config MoonAnimationConfig[]
function MoonAnimation:SetConfig(config)
  self.config = config
end

---@param parentGroup AnimationGroup
---@param configs MoonAnimationConfig[]
local function generateAnimations(parentGroup, configs)
  for _, config in ipairs(configs) do
    local ani
    if config.type == MoonAnimationType.SLIDE then
      ani = parentGroup:CreateAnimation("Translation")
      if config.Offsets then
        ani:SetOffset(config.Offsets.OffsetX, config.Offsets.OffsetY)
      end
    elseif config.type == MoonAnimationType.ALPHA then
      ani = parentGroup:CreateAnimation("Alpha")
      if config.FromAlpha and config.ToAlpha then
        ani:SetFromAlpha(config.FromAlpha)
        ani:SetToAlpha(config.ToAlpha)
      end
    elseif config.type == MoonAnimationType.SCALE then
      ani = parentGroup:CreateAnimation("Scale")
      if config.ScaleFrom and config.ScaleTo then
        ani:SetScaleFrom(config.ScaleFrom.ScaleX, config.ScaleFrom.ScaleY)
        ani:SetScaleTo(config.ScaleTo.ScaleX, config.ScaleTo.ScaleY)
      end
      if config.origin then
        ani:SetOrigin(config.origin.Point, config.origin.OriginX, config.origin.OriginY)
      end
    end

    if ani then
      ani:SetDuration(config.duration)
      if config.Smoothing then
        ani:SetSmoothing(config.Smoothing)
      end

      if config.Children and #config.Children > 0 then
        local childGroup = parentGroup:GetParent():CreateAnimationGroup()
        generateAnimations(childGroup, config.Children)
        ani:SetScript("OnFinished", function()
          childGroup:Play()
        end)
      end

      if config.OnFinished then
        local existingOnFinished = ani:GetScript("OnFinished")
        ani:SetScript("OnFinished", function(...)
          if existingOnFinished ~= nil then
            existingOnFinished(...)
          end
          config.OnFinished(...)
        end)
      end
    end
  end
end

---@param w Window
function MoonAnimation:ApplyShowToWindow(w)
  if self.group ~= nil then
    error("an animation can only apply to one object")
  end
  local group = w:GetFrame():CreateAnimationGroup()
  self.group = group
  group:SetScript("OnPlay", function()
    w:Show(true)
  end)
  group:SetScript("OnFinished", function()
    if self.totalTranslationX ~= 0 or self.totalTranslationY ~= 0 then
      local point, relativeTo, relativePoint, xof, yof = w:GetFrame():GetPoint()
      w:GetFrame():SetPoint(
        point,
        relativeTo,
        relativePoint,
        xof + self.totalTranslationX,
        yof + self.totalTranslationY
      )
    end
  end)

  generateAnimations(self.group, self.config)

  w:SetShowAnimation(self)
end

---@param w Window
function MoonAnimation:ApplyHideToWindow(w)
  if self.group ~= nil then
    error("an animation can only apply to one object")
  end
  local group = w:GetFrame():CreateAnimationGroup()
  self.group = group
  group:SetScript("OnFinished", function()
    if self.totalTranslationX ~= 0 or self.totalTranslationY ~= 0 then
      local point, relativeTo, relativePoint, xof, yof = w:GetFrame():GetPoint()
      w:GetFrame():SetPoint(
        point,
        relativeTo,
        relativePoint,
        xof + self.totalTranslationX,
        yof + self.totalTranslationY
      )
    end
    w:Hide(true)
  end)

  generateAnimations(self.group, self.config)

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