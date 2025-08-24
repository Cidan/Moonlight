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
---@field child Drawable
local Scrollbox = {}

---@return Scrollbox
local scrollboxConstructor = function()
  local drawable = moonlight:GetDrawable()
  ---@type Scrollbox
  local instance = drawable:Create(Scrollbox)

  local frame = CreateFrame("Frame")

  local scrollBox = CreateFrame("Frame", nil, frame, "WowScrollBox")
  scrollBox:SetPoint("TOPLEFT", frame, "TOPLEFT")
  scrollBox:SetPoint("BOTTOM")

  local scrollBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")
  scrollBar:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, 0)
  scrollBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 4, 0)

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
  instance.frame_Container = frame
  instance.frame_ScrollBox = scrollBox
  instance.frame_ScrollBar = scrollBar --[[@as MinimalScrollBar]]
  instance.frame_ScrollArea = scrollArea
  instance.frame_View = view --[[@as Frame]]

  return instance
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

---@param child Drawable
function Scrollbox:SetChild(child)
  child:SetParent(self.frame_ScrollArea)
  child:ClearAllPoints()
  -- Parent is set to nil to work around hide/show slowness
  -- when there are a lot of children.
  child:SetPoint({
    Point = "TOPLEFT",
    RelativeTo = self.frame_ScrollArea
  })
  child:SetPoint({
    Point = "TOPRIGHT",
    RelativeTo = self.frame_ScrollArea
  })
  child:Hide()
  self.child = child
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

function Scrollbox:ClearAllPoints()
  self.frame_Container:ClearAllPoints()
end

function Scrollbox:SetParent(parent)
  self.frame_Container:SetParent(parent)
end

function Scrollbox:SetPoint(point)
  self.frame_Container:SetPoint(
    point.Point,
    point.RelativeTo,
    point.RelativePoint,
    point.XOffset,
    point.YOffset
  )
end

function Scrollbox:GetHeight()
  return self.frame_Container:GetHeight()
end

function Scrollbox:Hide()
  self.frame_Container:Hide()
end

function Scrollbox:Show()
  self.frame_Container:Show()
end

function Scrollbox:Render(parentResults, options, results)
  local result = results.Results[self.child]
  self.frame_ScrollArea:SetHeight(result.Height)
  self.child:Show()
end

function Scrollbox:GetRenderPlan()
  ---@type RenderPlan
  local plan = {
    Plan = {
      [1] = {
        step = "RENDER_PRE"
      },
      [2] = {
        step = "RENDER_DEP",
        target = self.child
      },
      [3] = {
        step = "RENDER_SELF"
      }
    }
  }
  return plan
end