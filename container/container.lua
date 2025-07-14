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
---@field frame_ScrollArea Frame
---@field frame_View Frame
---@field child Frame
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

  local scrollArea = CreateFrame("Frame", nil, scrollBox)
  scrollArea:SetPoint("TOPLEFT", scrollBox)
  scrollArea:SetPoint("TOPRIGHT", scrollBox)
  scrollArea.scrollable = true

  scrollBar:SetHideIfUnscrollable(true)
  scrollBar:SetInterpolateScroll(true)
  scrollBox:SetInterpolateScroll(true)

  scrollBox:SetUseShadowsForEdgeFade(true)
  scrollBox:SetEdgeFadeLength(10)
  local view = CreateScrollBoxLinearView()
  view:SetPanExtent(10)

  ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, view)
  local instance = {
    frame_Container = frame,
    frame_ScrollBox = scrollBox,
    frame_ScrollBar = scrollBar,
    frame_ScrollArea = scrollArea,
    frame_View = view,
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

---@param f Frame | nil
function Container:SetChild(f)
  if f == nil then
    if self.child ~= nil then
      self.child:ClearAllPoints()
      self.child:SetParent(nil)
      self.child = nil
    end
    return
  end

  f:ClearAllPoints()
  f:SetParent(self.frame_ScrollArea)
  f:SetPoint("TOPLEFT")
  f:SetPoint("TOPRIGHT")
  self.child = f
  self:RecalculateHeight()
end

---@return Frame
function Container:GetChild()
  return self.child
end

function Container:RecalculateHeight()
  if self.child ~= nil then
    self.frame_ScrollArea:SetHeight(self.child:GetHeight())
  else
    self.frame_ScrollArea:SetHeight(0)
  end
  self.frame_ScrollBox:FullUpdate(true)
end

---@param outside boolean
function Container:SetScrollbarOutsideOfContainer(outside)
  local scrollBar = self.frame_ScrollBar
  local frame = self.frame_Container
  scrollBar:ClearAllPoints()

  if outside then
    scrollBar:SetPoint("TOPLEFT", frame, "TOPRIGHT", 16, 0)
    scrollBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 16, 0)
  else
    scrollBar:SetPoint("TOPLEFT", frame, "TOPRIGHT", -16, 0)
    scrollBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -16, 0)
  end
end