local moonlight = GetMoonlight()

--- Save module manages cross-session data persistence using MoonlightDB SavedVariables.
---@class save
local save = moonlight:NewClass("save")

function save:Boot()
  -- Initialize MoonlightDB if it doesn't exist
  if MoonlightDB == nil then
    MoonlightDB = {}
  end
end
