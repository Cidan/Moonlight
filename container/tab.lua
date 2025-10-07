local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class tab
---@field pool Pool
local tab = moonlight:NewClass("tab")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case.
---@class Tab: Drawable
---@field frame_Container Frame
---@field frame_HoverZone Frame
---@field container Container
---@field tabs table<string, Tabbutton>
---@field config TabConfig
---@field fadeInAnimation MoonAnimation
---@field fadeOutAnimation MoonAnimation
---@field isHidden boolean
local Tab = {}

---@return Tab
local tabConstructor = function()
  local frame_Container = CreateFrame("Frame")
  local frame_HoverZone = CreateFrame("Frame")
  local instance = {
    frame_Container = frame_Container,
    frame_HoverZone = frame_HoverZone,
    tabs = {},
    isHidden = true,
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Tab
  })
end

---@param _w Tab
local tabDeconstructor = function(_w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Tab
function tab:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(tabConstructor, tabDeconstructor)
  end
  local t = self.pool:TakeOne("Tab")
  return t
end

---@param config TabConfig
function Tab:SetConfig(config)
  self.config = config
end

function Tab:Redraw(_width)
  ---@type number
  local totalHeight = 0

  -- Build list of tabs with their sort keys
  local tabsWithKeys = {}
  for name, t in pairs(self.tabs) do
    local children = self.container:GetAllChildren()
    local tabData = children[name]
    t:SetTexture(tabData.Icon)
    t:SetTooltipPosition(self.config.TooltipAnchor)
    -- Use Tooltip field if provided, otherwise fall back to Title or Name
    local tooltipText = tabData.Tooltip or tabData.Title or tabData.Name
    t:SetTooltipText(tooltipText)
    table.insert(tabsWithKeys, {tab = t, sortKey = tabData.SortKey or 0})
  end

  -- Sort tabs by SortKey
  table.sort(tabsWithKeys, function(a, b) return a.sortKey < b.sortKey end)

  -- Extract sorted tabs
  ---@type Tabbutton[]
  local sortedTabs = {}
  for _, entry in ipairs(tabsWithKeys) do
    table.insert(sortedTabs, entry.tab)
  end

  ---@type FramePoint, FramePoint
  local firstPoint, otherPoint
  ---@type number
  local yOffset
  if self.config.Orientation == "VERTICAL" then
    if self.config.GrowDirection == "UP" then
      firstPoint = "BOTTOMLEFT"
      otherPoint = "TOPLEFT"
      yOffset = self.config.Spacing
    elseif self.config.GrowDirection == "DOWN" then
      firstPoint = "TOPLEFT"
      otherPoint = "BOTTOMLEFT"
      yOffset = self.config.Spacing
    end
  end
  for i, t in ipairs(sortedTabs) do
    if i == 1 then
      t:SetPoint({
        Point = firstPoint,
        RelativeTo = self.frame_Container
      })
    else
      local previousTab = sortedTabs[i-1] --[[@as Tabbutton]]
      totalHeight = totalHeight + yOffset
      t:SetPoint({
        Point = firstPoint,
        RelativeTo = previousTab:GetFrame(),
        RelativePoint = otherPoint,
        YOffset = yOffset,
        XOffset = 0
      })
    end
    totalHeight = totalHeight + t:GetHeight()
  end
  self:SetHeight(totalHeight)
  self:SetWidth(24)
  return 0
end

function Tab:SetPoint(point)
  self.frame_Container:SetPoint(
    point.Point,
    point.RelativeTo,
    point.RelativePoint,
    point.XOffset,
    point.YOffset
  )
end

---@param h number
function Tab:SetHeight(h)
  self.frame_Container:SetHeight(h)
end

---@param w number
function Tab:SetWidth(w)
  self.frame_Container:SetWidth(w)
end

---@return number
function Tab:GetWidth()
  return self.frame_Container:GetWidth()
end

---@return number
function Tab:GetHeight()
  return self.frame_Container:GetHeight()
end

function Tab:SetParent(parent)
  self.frame_Container:SetParent(parent)
end

function Tab:setupAnimations()
  -- Tabs are now always visible - no hover animations needed
  self.frame_Container:SetAlpha(1)
  self.isHidden = false
end

function Tab:setupHoverScripts()
  -- Hover scripts disabled - tabs are always visible
  -- Hide hover zone so it doesn't block tooltips
  self.frame_HoverZone:Hide()
  self.frame_HoverZone:EnableMouse(false)
end

function Tab:Update()
  if self.container == nil then
    error("this tab has yet to been attached to a container, call Apply first!")
  end
  if self.config == nil then
    error("the tab handler is not configured -- did you call SetConfig?")
  end

  -- Clear all the tabs first.
  for _, b in pairs(self.tabs) do
    b:Release()
  end
  wipe(self.tabs)

  -- Redraw!
  self:createTabsFromScratch()
end

---@param c Container
function Tab:Apply(c)
  if self.container ~= nil then
    error("tab handler is already attached to a container -- did you call apply twice?")
  end
  if self.config == nil then
    error("the tab handler is not configured -- did you call SetConfig?")
  end
  self.container = c
  self:createTabsFromScratch()
end

function Tab:createTabsFromScratch()
  local tabbutton = moonlight:GetTabbutton()
  children = self.container:GetAllChildren()
  for name in pairs(children) do
    local b = tabbutton:New()
    b:SetCallbackOnClick(function()
      self.container:SwitchToChild(name)
    end)
    b:SetParent(self.frame_Container)
    b:SetSize(24, 24)
    -- TODO(lobato): configure tabs
    self.tabs[name] = b
  end
  self:SetParent(self.container:GetFrame())
  self:Redraw(1)
  self:SetPoint(self.config.Point)

  -- Set up hover zone - static invisible frame for hover detection
  self.frame_HoverZone:SetParent(self.container:GetFrame())
  self.frame_HoverZone:SetSize(self:GetWidth(), self:GetHeight())
  self.frame_HoverZone:SetPoint(
    self.config.Point.Point,
    self.config.Point.RelativeTo,
    self.config.Point.RelativePoint,
    self.config.Point.XOffset,
    self.config.Point.YOffset
  )
  -- Make hover zone invisible but interactable for hover only (clicks pass through)
  self.frame_HoverZone:EnableMouse(true)
  self.frame_HoverZone:SetPropagateMouseClicks(true)
  self.frame_HoverZone:SetFrameLevel(self.frame_Container:GetFrameLevel() + 10)

  -- Set up animations and hover detection
  self:setupAnimations()
  self:setupHoverScripts()
end