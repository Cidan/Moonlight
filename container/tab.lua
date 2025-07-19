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

  return self.pool:TakeOne("Tab")
end

---@param c Container
function Tab:Apply(c)
  if self.container ~= nil then
    error("tab handler is already attached to a container -- did you call apply twice?")
  end
  local tabbutton = moonlight:GetTabbutton()
  children = c:GetAllChildren()
  for name, child in pairs(children) do
    local b = tabbutton:New()
    -- TODO(lobato): configure tabs
    self.tabs[name] = b
  end
  self.container = c
end