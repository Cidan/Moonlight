local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class (exact) popup
---@field window Window
local popup = moonlight:NewClass("popup")

function popup:Boot()
  local window = moonlight:GetWindow()
  self.window = window:New()
end

---@return Window
function popup:GetWindow()
  return self.window
end