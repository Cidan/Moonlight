local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class list
---@field pool Pool
local list = moonlight:NewClass("list")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class List: Drawable
---@field frame_Container Frame
---@field frame_ScrollBox WowScrollBox
---@field frame_ScrollBar MinimalScrollBar
---@field provider DataProviderMixin
---@field dragBehavior ScrollBoxDragBehavior
---@field frame_View ScrollBoxListViewMixin
local List = {}

---@return List
local listConstructor = function()
  local instance = setmetatable({}, {
    __index = List
  })
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

  scrollBox:SetUseShadowsForEdgeFade(true)
  scrollBox:SetEdgeFadeLength(32)
  
  local view = CreateScrollBoxListLinearView()
  view:SetPanExtent(50)
  view:SetPadding(4, 4, 8, 4, 0)
  view:SetExtent(20)
  --TODO(lobato): implement SetElementExtentCalculator and use drawable's for getting height

  local provider = CreateDataProvider()
  ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view)
  local dragBehavior = ScrollUtil.InitDefaultLinearDragBehavior(scrollBox)
  scrollBox:SetDataProvider(provider)

  instance.dragBehavior = dragBehavior
  instance.frame_ScrollBar = scrollBar --[[@as MinimalScrollBar]]
  instance.frame_ScrollBox = scrollBox
  instance.frame_View = view
  instance.frame_Container = frame

  return instance
end

---@param w List
local listDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return List
function list:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(listConstructor, listDeconstructor)
  end

  return self.pool:TakeOne("List")
end

---@generic T
---@param fn fun(f: Frame, data: T)
function List:SetNewElementFunction(fn)
  self.frame_View:SetElementInitializer("Frame", fn)
end

---@generic T
---@param fn fun(f: Frame, data: T)
function List:SetReleaseElementFunction(fn)
  self.frame_View:SetElementResetter(fn)
end