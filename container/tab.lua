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
---@field selectedTabName string | nil
local Tab = {}

---@return Tab
local tabConstructor = function()
  local frame_Container = CreateFrame("Frame")
  local frame_HoverZone = CreateFrame("Frame")
  local instance = {
    frame_Container = frame_Container,
    frame_HoverZone = frame_HoverZone,
    tabs = {},
    selectedTabName = nil,
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
  ---@type number
  local totalWidth = 0

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

  ---@type FramePoint
  local anchorPoint
  ---@type number
  local buttonSize = 24  -- Standard tab button size

  -- Determine anchor point based on orientation and grow direction
  if self.config.Orientation == "VERTICAL" then
    if self.config.GrowDirection == "UP" then
      anchorPoint = "BOTTOMLEFT"
    elseif self.config.GrowDirection == "DOWN" then
      anchorPoint = "TOPLEFT"
    end
  else
    if self.config.GrowDirection == "RIGHT" then
      anchorPoint = "TOPLEFT"
    elseif self.config.GrowDirection == "LEFT" then
      anchorPoint = "TOPRIGHT"
    end
  end

  -- Position each button independently relative to the container
  -- Calculate cumulative offset for each button
  ---@type number
  local cumulativeOffset = 0

  for i, t in ipairs(sortedTabs) do
    -- All buttons anchor to the container, not to each other
    if self.config.Orientation == "VERTICAL" then
      if self.config.GrowDirection == "UP" then
        -- Growing upward: positive Y offset
        t:SetPoint({
          Point = anchorPoint,
          RelativeTo = self.frame_Container,
          RelativePoint = anchorPoint,
          YOffset = cumulativeOffset,
          XOffset = 0
        })
      else  -- DOWN
        -- Growing downward: negative Y offset
        t:SetPoint({
          Point = anchorPoint,
          RelativeTo = self.frame_Container,
          RelativePoint = anchorPoint,
          YOffset = -cumulativeOffset,
          XOffset = 0
        })
      end
      totalHeight = totalHeight + buttonSize
      if i < #sortedTabs then
        totalHeight = totalHeight + self.config.Spacing
        cumulativeOffset = cumulativeOffset + buttonSize + self.config.Spacing
      end
    else  -- HORIZONTAL
      if self.config.GrowDirection == "RIGHT" then
        -- Growing rightward: positive X offset
        t:SetPoint({
          Point = anchorPoint,
          RelativeTo = self.frame_Container,
          RelativePoint = anchorPoint,
          YOffset = 0,
          XOffset = cumulativeOffset
        })
      else  -- LEFT
        -- Growing leftward: negative X offset
        t:SetPoint({
          Point = anchorPoint,
          RelativeTo = self.frame_Container,
          RelativePoint = anchorPoint,
          YOffset = 0,
          XOffset = -cumulativeOffset
        })
      end
      totalWidth = totalWidth + buttonSize
      if i < #sortedTabs then
        totalWidth = totalWidth + self.config.Spacing
        cumulativeOffset = cumulativeOffset + buttonSize + self.config.Spacing
      end
    end
  end
  if self.config.Orientation == "VERTICAL" then
    self:SetHeight(totalHeight)
    self:SetWidth(24)
  else
    self:SetHeight(24)
    self:SetWidth(totalWidth)
  end
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
  -- Tabs are now always visible - no container-level animations
end

function Tab:setupHoverScripts()
  -- Hover zone not needed - individual buttons handle their own hover animations
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
    local childData = children[name]
    b:SetCallbackOnClick(function()
      -- Handle tab selection animation
      if self.selectedTabName ~= nil and self.selectedTabName ~= name then
        -- Deselect previous tab
        local previousTab = self.tabs[self.selectedTabName]
        if previousTab ~= nil then
          previousTab:Deselect()
        end
      end

      -- Select this tab
      if self.selectedTabName ~= name then
        b:Select()
        self.selectedTabName = name
      end

      -- Call optional OnTabClick callback before switching
      if childData.OnTabClick ~= nil then
        childData.OnTabClick()
      end
      self.container:SwitchToChild(name)
    end)
    b:SetParent(self.frame_Container)
    b:SetSize(24, 24)
    -- Set animation config (use defaults if not specified)
    local animDistance = self.config.HoverAnimationDistance or 3
    local animDuration = self.config.HoverAnimationDuration or 0.1
    local selectedDistance = self.config.SelectedAnimationDistance or 7
    b:SetAnimationConfig(animDistance, animDuration, selectedDistance)
    -- Set tooltip container so tooltip stays anchored to tab container
    b:SetTooltipContainer(self.frame_Container)
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