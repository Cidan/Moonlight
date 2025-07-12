local moonlight = GetMoonlight()

--- Applies decorations to a window.
---@class decorate
local decorate = moonlight:NewClass("decorate")

--- This is the instance of a decorator, and where the module
--- functionality actually is.
---@class Decorate
---@field borderFrame Frame
---@field closeButton Button
local Decorate = {}

--- This creates a new instance of a decorator.
---@return Decorate
function decorate:New()
  local instance = {
    borderFrame = CreateFrame("Frame"),
    closeButton = CreateFrame("Button")
  }
  return setmetatable(instance, Decorate)
end

---@class Decoration

---@param d Decoration
function decorate:Apply(d)
end