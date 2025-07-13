---@enum SlideDirection
SlideDirection = {
  LEFT = 1,
  RIGHT = 2,
  UP = 3,
  DOWN = 4
}

---@class MoonAnimationSlide
---@field Direction SlideDirection
---@field Duration number
---@field Distance number
---@field ApplyFinalPosition boolean If true, when this animation is done, the region will permanently move to this new position.

---@class MoonAnimationAlpha
---@field Start number
---@field End number
---@field Duration number

---@class ActiveAnimation
---@field Animation Animation
---@field SmoothProgress number