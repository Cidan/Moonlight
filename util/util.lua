local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class util
---@field pool Pool
local util = moonlight:NewClass("util")

---@param slotKey SlotKey
---@return BagID, number
function util:GetBagAndSlotFromSlotkey(slotKey)
  ---@diagnostic disable-next-line: undefined-field
  local bagid, slotid = string.split('_', slotKey)
  return tonumber(bagid) --[[@as BagID]], tonumber(slotid) --[[@as number]]
end
