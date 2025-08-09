local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class drawable
local drawable = moonlight:NewClass("drawable")

---@diagnostic disable-next-line: missing-fields
---@type Drawable
local mixinProto = {}

---@param a any
function drawable:Mixin(a)
  if a.frame_Container == nil then
    error("a drawable must have a frame_Container frame")
  end
  Mixin(a, mixinProto)
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