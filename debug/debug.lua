local moonlight = GetMoonlight()

--- A module for dealing with debugging and other test functionality.
---@class debug
local debug = moonlight:NewClass("debug")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Debug
local Debug = {}

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Debug
function debug:New()
  local instance = {}
  return setmetatable(instance, Debug)
end

--- Creates a new test window for debugging.
function Debug:NewTestWindow()
  local window = moonlight:GetWindow()
  local w = window:New()
  w:SetSize(100, 100)
  w:SetPoint("CENTER", UIParent)
end