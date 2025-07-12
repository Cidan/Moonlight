local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class pool
local pool = moonlight:NewClass("Pool")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Pool
local Pool = {}

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Pool
function pool:New()
  local instance = {}
  return setmetatable(instance, {
    __index = Pool
  })
end


function Pool:TakeOne()
end

function Pool:GiveBack()
end