local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class bank
local bank = moonlight:NewClass("bank")

---@class (exact) Bank: Bag
---@field bagWidth number
local Bank = {}

function bank:Boot()
  Bank.bagWidth = 300
end