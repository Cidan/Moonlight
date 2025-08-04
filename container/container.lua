local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class container
---@field pool Pool
local container = moonlight:NewClass("container")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Container: Drawable
---@field frame_Container Frame
---@field frame_ScrollBox WowScrollBox
---@field frame_ScrollBar MinimalScrollBar
---@field frame_ScrollArea Frame
---@field frame_View Frame
---@field children table<string, ContainerChild>
---@field activeChild string | nil
---@field attachedTo Window
---@field tab Tab
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
    children = {},
    activeChild = nil,
  }
  return setmetatable(instance, {
    __index = Container
  })
end

---@param _w Container
local containerDeconstructor = function(_w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Container
function container:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(containerConstructor, containerDeconstructor)
  end
  local c = self.pool:TakeOne("Container")
  return c
end

---@param w Window
function Container:Apply(w)
  if self.attachedTo ~= nil then
    error("attempted to apply a container to a window twice")
  end
  self.attachedTo = w
  w:SetContainer(self)
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

---@param child ContainerChild
function Container:AddChild(child)
  
  child.Drawable:ClearAllPoints()
  -- Parent is set to nil to work around hide/show slowness
  -- when there are a lot of children.
  child.Drawable:SetParent(nil)
  child.Drawable:SetPoint({
    Point = "TOPLEFT",
    RelativeTo = self.frame_ScrollArea
  })
  child.Drawable:SetPoint({
    Point = "TOPRIGHT",
    RelativeTo = self.frame_ScrollArea
  })
  self.children[child.Name] = child
  child.Drawable:Hide()
  if self.tab ~= nil then
    self:UpdateContainerTabs()
  end
end

---@param name string
function Container:SwitchToChild(name)
  for _, child in pairs(self.children) do
    child.Drawable:Hide()
    child.Drawable:SetParent(nil)
  end

  if self.children[name] ~= nil then
    self.children[name].Drawable:SetParent(self.frame_ScrollArea)
    self.children[name].Drawable:Show()
    self.activeChild = name
    if self.children[name].Title ~= nil then
      self.attachedTo:SetTitle(self.children[name].Title)
    end
  else
    self.activeChild = nil
  end
  local render = moonlight:GetRender()
  render:NewRenderChain(self, {OnlyRedraw = false})
end

---@return ContainerChild
function Container:GetActiveChild()
  if self.activeChild == nil then
    error("attempted to get a child when no child was set or created in this container.")
  end
  return self.children[self.activeChild]
end

---@return table<string, ContainerChild>
function Container:GetAllChildren()
  return self.children
end

--function Container:RecalculateHeight()
--  local child = self:GetActiveChild()
--  if child == nil then
--    self.frame_ScrollArea:SetHeight(0)
--    return
--  end
--  self.frame_ScrollBox:FullUpdate(true)
--  local w = self.frame_ScrollBox:GetWidth()
--  local h = child.Drawable:Redraw(w)
--  self.frame_ScrollArea:SetHeight(h)
--  self.frame_ScrollBox:FullUpdate(true)
--end
--
--function Container:RecalculateHeightWithoutDrawing()
--  local child = self:GetActiveChild()
--  if child == nil then
--    self.frame_ScrollArea:SetHeight(0)
--    return
--  end
--  local h = child.Drawable:GetHeight()
--  self.frame_ScrollArea:SetHeight(h)
--  self.frame_ScrollBox:FullUpdate(true)
--end

function Container:SetScrollbarOutsideOfContainer()
  local scrollBar = self.frame_ScrollBar
  local frame = self.frame_Container
  scrollBar:ClearAllPoints()

  scrollBar:SetPoint("TOPLEFT", frame, "TOPRIGHT", 16, 0)
  scrollBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 16, 0)
end

function Container:SetScrollbarInsideOfContainer()
  local scrollBar = self.frame_ScrollBar
  local frame = self.frame_Container
  scrollBar:ClearAllPoints()

  scrollBar:SetPoint("TOPLEFT", frame, "TOPRIGHT", -16, 0)
  scrollBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -16, 0)
end

function Container:UpdateContainerTabs()
  if self.tab == nil then
    error("tabs have not been configured for this container, nothing to update!")
  end
  self.tab:Update()
end

---@param config TabConfig
function Container:CreateTabsForThisContainer(config)
  if self.tab ~= nil then
    error("tabs have already been created for this container")
  end
  local tab = moonlight:GetTab()
  local t = tab:New()
  self.tab = t
  t:SetConfig(config)
  t:Apply(self)
end

---@return Frame
function Container:GetFrame()
  return self.frame_Container
end

---@return string?
function Container:GetActiveChildName()
  return self.activeChild
end

function Container:PreRender()
  local child = self:GetActiveChild()
  if child == nil then
    self.frame_ScrollArea:SetHeight(0)
    return
  end
  self.frame_ScrollBox:FullUpdate(true)

  ---@type RenderResult
  local result = {
    Width = self.frame_ScrollBox:GetWidth(),
    Height = self.frame_ScrollBox:GetHeight()
  }

  return result
end

function Container:Render(parentResult, options, results)
  if results == nil then
    error("child did not return any results, can't render this container")
  end

  local result = results.Results[self:GetActiveChild().Drawable]

  if result == nil then
    error("the current child did not have any results, did you set the results in the render function?")
  end

  self.frame_ScrollArea:SetHeight(result.Height)
  self.frame_ScrollBox:FullUpdate(true)
end

function Container:GetRenderPlan()
  ---@type RenderPlan
  local plan = {
    Plan = {
      [1] = {
        step = "RENDER_PRE"
      },
      [2] = {
        step = "RENDER_DEP",
        target = self:GetActiveChild().Drawable
      },
      [3] = {
        step = "RENDER_SELF"
      }
    }
  }
  return plan
end