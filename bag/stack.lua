local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class stack
---@field pool Pool
local stack = moonlight:NewClass("stack")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Stack
local Stack = {}

---@return Stack
local stackConstructor = function()
  local instance = {
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Stack
  })
end

---@param w Stack
local stackDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Stack
function stack:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(stackConstructor, stackDeconstructor)
  end

  return self.pool:TakeOne("Stack")
end

function Stack:Release()
  stack.pool:GiveBack("Stack", self)
end
