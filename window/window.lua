local moonlight = GetMoonlight()
local context = moonlight:GetContext()

--- Window is a display window for Moonlight. A window
--- can have multiple properties for interaction, such as
--- dragging, closing, key binds, events, scrolling, tabs
--- and more.
---@class window
---@field pool Pool
local window = moonlight:NewClass("window")

---@class Window
---@field baseFrame Frame
local Window = {}

---@return Window
local windowConstructor = function()
  local instance = {
    baseFrame = CreateFrame("Frame")
  }
  return setmetatable(instance, {
    __index = Window
  })
end

---@param w Window
local windowDeconstructor = function(w)
end

---@return Window
function window:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(windowConstructor, windowDeconstructor)
  end

  return self.pool:TakeOne("Window")
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

---@param f fun(ctx: Context, w: Window)
function Window:SetOnShow(f)
  self.baseFrame:SetScript("OnShow", 
    function(...)
      local ctx = context:New()
      f(ctx, self)
    end
  )
end

---@return Frame
function Window:GetFrame()
  return self.baseFrame
end

function Window:Show()
  self.baseFrame:Show()
end

function Window:Hide()
  self.baseFrame:Hide()
end