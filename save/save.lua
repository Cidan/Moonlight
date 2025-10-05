local moonlight = GetMoonlight()

--- Save module manages cross-session data persistence using MoonlightDB SavedVariables.
---@class save
local save = moonlight:NewClass("save")

function save:Boot()
  -- Initialize MoonlightDB if it doesn't exist
  if MoonlightDB == nil then
    MoonlightDB = {}
  end

  -- Initialize window positions table
  if MoonlightDB.windowPositions == nil then
    MoonlightDB.windowPositions = {}
  end
end

---@param window Window
function save:SaveWindowPosition(window)
  local name = window:GetName()
  local frame = window:GetFrame()

  -- Get the current position of the window
  local numPoints = frame:GetNumPoints()
  if numPoints == 0 then
    return -- Window has no position set
  end

  -- Get the first anchor point
  local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint(1)

  -- Store position data
  MoonlightDB.windowPositions[name] = {
    point = point,
    relativePoint = relativePoint,
    xOfs = xOfs,
    yOfs = yOfs
  }
end
