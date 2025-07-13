---@enum SlideDirection
SlideDirection = {
  LEFT = 1,
  RIGHT = 2,
  UP = 3,
  DOWN = 4
}

---@class Slide
---@field Direction SlideDirection
---@field Duration number
---@field Distance number

---@class ActiveAnimation
---@field Animation Animation
---@field SmoothProgress number