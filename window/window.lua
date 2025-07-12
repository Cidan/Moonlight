local moonlight = GetMoonlight()

--- Window is a display window for Moonlight. A window
--- can have multiple properties for interaction, such as
--- dragging, closing, key binds, events, scrolling, tabs
--- and more.
---@class window
local window = moonlight:NewClass("window")

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

--- Sets the point of the window.
---@param point FramePoint
---@param relativeTo Frame | string
---@param relativePoint? FramePoint
---@param xOfs? number | nil
---@param yOfs? number | nil
function Window:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
  self.baseFrame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
end

--- Sets the size of the window.
---@param width number
---@param height number
function Window:SetSize(width, height)
  self.baseFrame:SetSize(width, height)
end