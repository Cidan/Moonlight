---@diagnostic disable-next-line: unbalanced-assignments
---@type string, table
local _name, space = ...

---@class Moonlight
---@field space table
local Moonlight = {
  space = space
}

function Moonlight:Start()
  print("hi")
end

---@return Moonlight
function GetMoonlight()
  return Moonlight
end
