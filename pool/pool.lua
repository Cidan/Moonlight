local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class pool
local pool = moonlight:NewClass("pool")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@generic T
---@class Pool
---@field objs any[]
---@field constructor fun(): T
---@field deconstructor fun(o: T)
local Pool = {}

--- This creates a new instance of a module, and optionally, initializes the module.
---@generic T
---@param constructor fun(): T
---@param deconstructor fun(o: T)
---@return Pool
function pool:New(constructor, deconstructor)
  local instance = {
    constructor = constructor,
    deconstructor = deconstructor,
    objs = {}
  }
  return setmetatable(instance, {
    __index = Pool
  })
end

---@generic T
---@param _class `T`
---@return T
function Pool:TakeOne(_class)
  if #self.objs > 0 then
    return table.remove(self.objs)
  end
  return self.constructor()
end

---@generic T
---@param _class `T`
---@param o T
function Pool:GiveBack(_class, o)
  self.deconstructor(o)
  table.insert(self.objs, o)
end