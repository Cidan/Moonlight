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
---@field container Container
---@field tabs table<string, Tabbutton>
---@field config TabConfig
local Tab = {}

---@return Tab
local tabConstructor = function()
  local frame_Container = CreateFrame("Frame")
  local instance = {
    frame_Container = frame_Container,
    tabs = {},
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Tab
  })
end

---@param w Tab
local tabDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Tab
function tab:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(tabConstructor, tabDeconstructor)
  end
  local t = self.pool:TakeOne("Tab")
  local debug = moonlight:GetDebug():New()
  debug:DrawBlueBorder(t.frame_Container)
  return t
end

---@param config TabConfig
function Tab:SetConfig(config)
  self.config = config
end

function Tab:Redraw(width)
  ---@type number
  local totalHeight = 0

  ---@type Tabbutton[]
  local sortedTabs = {}
  for name, t in pairs(self.tabs) do
    local children = self.container:GetAllChildren()
    local tabData = children[name]
    t:SetTexture(tabData.Icon)
    t:SetTooltipPosition(self.config.TooltipAnchor)
    t:SetTooltipText(tabData.Name)
    table.insert(sortedTabs, t)
  end
  if self.config.Orientation == "VERTICAL" then
    for i, t in ipairs(sortedTabs) do
      if i == 1 then
        t:SetPoint({
          Point = "TOPLEFT",
          RelativeTo = self.frame_Container
        })
      else
        local previousTab = sortedTabs[i-1] --[[@as Tabbutton]]
        t:SetPoint({
          Point = "TOPLEFT",
          RelativeTo = previousTab:GetFrame(),
          YOffset = -self.config.Spacing * (i - 1)
        })
      end
      totalHeight = totalHeight + t:GetHeight()
    end
    self:SetHeight(totalHeight)
    self:SetWidth(24)
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

function Tab:SetParent(parent)
  self.frame_Container:SetParent(parent)
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
end