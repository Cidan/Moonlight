local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class drawable
local drawable = moonlight:NewClass("drawable")

---@diagnostic disable-next-line: missing-fields
---@type Drawable
local mixinProto = {}

---@return any
function drawable:Mixin(...)
  return Mixin({}, mixinProto, ...)
end

---@param parent SimpleFrame?
function mixinProto:SetParent(parent)
  self.frame_Container:SetParent(parent)
end

function mixinProto:ClearAllPoints()
  self.frame_Container:ClearAllPoints()
end

function mixinProto:SetPoint(point)
  self.frame_Container:SetPoint(
    point.Point,
    point.RelativeTo,
    point.RelativePoint,
    point.XOffset, 
    point.YOffset
  )
end

function mixinProto:Hide()
  self.frame_Container:Hide()
end

function mixinProto:Show()
  self.frame_Container:Show()
end

--- Sets the size of the window.
---@param width number
---@param height number
function mixinProto:SetSize(width, height)
  self.frame_Container:SetSize(width, height)
end

---@param width number
function mixinProto:SetWidth(width)
  self.frame_Container:SetWidth(width)
end

---@param height number
function mixinProto:SetHeight(height)
  self.frame_Container:SetHeight(height)
end

---@return Frame
function mixinProto:GetFrame()
  return self.frame_Container
end
