local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class animation
---@field pool Pool
local animation = moonlight:NewClass("animation")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class MoonAnimation
---@field slides Slide[]
---@field group AnimationGroup
---@field pauseProgress number[]
local MoonAnimation = {}

---@return MoonAnimation
local animationConstructor = function()
  local instance = {
    slides = {},
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

---@param s Slide
function MoonAnimation:Slide(s)
  table.insert(self.slides, s)
end

function MoonAnimation:Fade()
end

---@param r Region
---@param onPlayCallback function
---@param onFinishedCallback function
function MoonAnimation:generateSlide(r, onPlayCallback, onFinishedCallback)
  ---@type AnimationGroup
  local group = r:CreateAnimationGroup()
  ---@type number, number
  local totalXOffset, totalYOffset = 0, 0
  
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
    totalXOffset = totalXOffset + xof
    totalYOffset = totalYOffset + yof

    ani:SetDuration(slide.Duration)
  end
  
  group:SetScript('OnPlay', onPlayCallback)
  group:SetScript('OnFinished', onFinishedCallback)

  group:SetScript("OnPause", function()
  end)
  group:SetScript('OnStop', function()
  end)
  self.group = group
end

---@param w Window
function MoonAnimation:ApplyOnShow(w)
  self:generateSlide(
    w:GetFrame(),
    function()
      w:Show(true)
    end,
    function()
    end
  )
  w:SetShowAnimation(self)
end

---@param w Window
function MoonAnimation:ApplyOnHide(w)
    self:generateSlide(
    w:GetFrame(),
    function()
    end,
    function()
      w:Hide(true)
    end
  )
  w:SetHideAnimation(self)
end

---@param inverseAnimation MoonAnimation
function MoonAnimation:Play(inverseAnimation)
  self.group:Play()
end