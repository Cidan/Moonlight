local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class scrollbox
---@field pool Pool
local scrollbox = moonlight:NewClass("scrollbox")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Scrollbox: Drawable
---@field frame_Container Frame
---@field frame_ScrollBox WowScrollBox
---@field frame_ScrollBar MinimalScrollBar
---@field frame_ScrollArea Frame
---@field frame_View Frame
local Scrollbox = {}

---@return Scrollbox
local scrollboxConstructor = function()

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
  scrollBox:SetEdgeFadeLength(32)
  local view = CreateScrollBoxLinearView()
  view:SetPanExtent(50)

  ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, view)
  local instance = {
    frame_Container = frame,
    frame_ScrollBox = scrollBox,
    frame_ScrollBar = scrollBar,
    frame_ScrollArea = scrollArea,
    frame_View = view,
  }
  return setmetatable(instance, {
    __index = Scrollbox
  })
end

---@param w Scrollbox
local scrollboxDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Scrollbox
function scrollbox:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(scrollboxConstructor, scrollboxDeconstructor)
  end

  return self.pool:TakeOne("Scrollbox")
end

function Scrollbox:Release()
  scrollbox.pool:GiveBack("Scrollbox", self)
end

function Scrollbox:PreRender()
  self.frame_ScrollBox:FullUpdate(true)

  ---@type RenderResult
  local result = {
    Width = self.frame_ScrollBox:GetWidth(),
    Height = self.frame_ScrollBox:GetHeight()
  }

  return result
end

function Scrollbox:GetRenderPlan()
  ---@type RenderPlan
  local plan = {
    Plan = {
      [1] = {
        step = "RENDER_PRE"
      },
    }
  }
  return plan
end