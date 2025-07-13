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
local MoonAnimation = {}

---@return MoonAnimation
local animationConstructor = function()
  local instance = {
    slides = {}
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

---@param w Window
function MoonAnimation:ApplyOnShow(w)
  ---@type AnimationGroup
  local group = w:GetFrame():CreateAnimationGroup()
  for _, slide in pairs(self.slides) do
    local ani = group:CreateAnimation("Translation")
    ani:SetSmoothing("OUT")
    ani:SetOffset(-slide.Distance, 0)
    ani:SetDuration(slide.Duration)
    ani:SetScript('OnPlay', function()
      w:GetFrame():Show()
    end)
    ani:SetScript('OnFinished', function()
      local point, relativeTo, relativePoint, xOfs, yOfs = w:GetFrame():GetPoint()
      w:GetFrame():SetPoint(point, relativeTo, relativePoint, xOfs + -slide.Distance, yOfs + 0)
    end)
  end
  self.group = group
  w:SetShowAnimation(self)
end

---@param w Window
function MoonAnimation:ApplyOnHide(w)
end

function MoonAnimation:Play()
  self.group:Play()
end