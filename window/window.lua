local moonlight = GetMoonlight()

--- Window is a display window for Moonlight. A window
--- can have multiple properties for interaction, such as
--- dragging, closing, key binds, events, scrolling, tabs
--- and more.
---@class window
local window = {}

---@class Window
---@field baseFrame Frame
local Window = {}

---@return Window
function window:New()
  local instance = {
    baseFrame = CreateFrame("Frame")
  }
  return setmetatable(instance, Window)
end