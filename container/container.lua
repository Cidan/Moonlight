local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class container
---@field pool Pool
local container = moonlight:NewClass("container")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Container
---@field frame_Container Frame
---@field frame_ScrollBox WowScrollBox
---@field frame_ScrollBar MinimalScrollBar
---@field attachedTo Window
local Container = {}

---@return Container
local containerConstructor = function()
  local frame = CreateFrame("Frame")

  local scrollBox = CreateFrame("Frame", nil, frame, "WowScrollBox")
  scrollBox:SetPoint("TOPLEFT", frame, "TOPLEFT")
  scrollBox:SetPoint("BOTTOM")

  local scrollBar = CreateFrame("EventFrame", nil, scrollBox, "MinimalScrollBar")
  scrollBar:SetPoint("TOPLEFT", frame, "TOPRIGHT", -16, 0)
  scrollBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -16, 0)

  scrollBar:SetHideIfUnscrollable(true)
  scrollBar:SetInterpolateScroll(true)
  scrollBox:SetInterpolateScroll(true)

  local instance = {
    frame_Container = frame,
    frame_ScrollBox = scrollBox,
    frame_ScrollBar = scrollBar
  }
  return setmetatable(instance, {
    __index = Container
  })
end

---@param w Container
local containerDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Container
function container:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(containerConstructor, containerDeconstructor)
  end

  return self.pool:TakeOne("Container")
end

---@param w Window
function Container:Apply(w)
  assert(self.attachedTo == nil, "attempted to apply a container to a window twice")
  self.attachedTo = w

  self.frame_Container:SetParent(w:GetFrame())
  self:UpdateInsets()
  self.frame_Container:Show()
end

function Container:UpdateInsets()
  if self.attachedTo == nil then
    return
  end

  local insets = self.attachedTo:GetInsets()
  if insets == nil then
    return
  end

  self.frame_Container:ClearAllPoints()
  self.frame_Container:SetPoint(
    "TOPLEFT",
    self.attachedTo:GetFrame(),
    "TOPLEFT",
    insets.Left,
    -insets.Top
  )

  self.frame_Container:SetPoint(
    "BOTTOMRIGHT",
    self.attachedTo:GetFrame(),
    "BOTTOMRIGHT",
    -insets.Right,
    insets.Bottom
  )

end