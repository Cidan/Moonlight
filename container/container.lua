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
---@field children table<string, ContainerChild>
---@field activeChild string | nil
---@field attachedTo Window
---@field tab Tab
local Container = {}

---@return Container
local containerConstructor = function()
  local drawable = moonlight:GetDrawable()

  ---@type Container
  local instance = drawable:Create(Container)
  instance.frame_Container = CreateFrame("Frame")
  instance.children = {}
  instance.activeChild = nil

  return instance
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
    RelativeTo = self.frame_Container
  })
  child.Drawable:SetPoint({
    Point = "BOTTOMRIGHT",
    RelativeTo = self.frame_Container
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
    self.children[name].Drawable:SetParent(self.frame_Container)
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

function Container:GetRenderPlan()
  ---@type RenderPlan
  local plan = {
    Plan = {
      [1] = {
        step = "RENDER_DEP",
        target = self:GetActiveChild().Drawable
      },
    }
  }
  return plan
end