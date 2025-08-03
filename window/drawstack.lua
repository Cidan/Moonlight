local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class drawstack
---@field pool Pool
local drawstack = moonlight:NewClass("drawstack")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Drawstack
---@field head Drawable
---@field stack table<number, Drawable[]>
---@field drawableToLayer table<Drawable, number>
local Drawstack = {}

---@return Drawstack
local drawstackConstructor = function()
  local instance = {
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Drawstack
  })
end

---@param w Drawstack
local drawstackDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Drawstack
function drawstack:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(drawstackConstructor, drawstackDeconstructor)
  end

  return self.pool:TakeOne("Drawstack")
end

---@param d Drawable
function Drawstack:Initialize(d)
  self:validateDrawable(d)
  self.head = d
  self.stack = {}
  self.drawableToLayer = {}
  self.drawableToLayer[d] = 1
end

---@param layer number
---@param d Drawable
function Drawstack:AddAtLayer(layer, d)
  self:validateDrawable(d)
  if self.stack[layer] == nil then
    self.stack[layer] = {}
  end
  table.insert(self.stack[layer], d)
  self.drawableToLayer[d] = layer
  d:SetDrawstack(self)
end

---@param currentDrawable Drawable
---@param child Drawable
function Drawstack:AddToNextLayer(currentDrawable, child)
  local layer = self.drawableToLayer[currentDrawable]
  if layer == nil then
    error("current drawable is not a part of the stack, did you add it?")
  end
  self:AddAtLayer(layer + 1, child)
end

---@param d Drawable
function Drawstack:validateDrawable(d)
  if d.SetDrawstack == nil then
    error("attempted to add a non-drawable to a draw stack")
  end
end

---@param d Drawable
function Drawstack:RemoveFromStack(d)
  local layer = self.drawableToLayer[d]
  if layer == nil then
    error("drawable removed from stack when it wasn't in the stack to begin with")
  end

  for idx, toRemove in pairs(self.stack[layer]) do
    if toRemove == d then
      table.remove(self.stack[layer], idx)
      return
    end
  end
  error("drawable not found in stack at any layer. something broke.")
end

---@param d Drawable
function Drawstack:DrawEveryoneAboveMe(d)
  local layer = self.drawableToLayer[d]
  if layer == nil then
    error("drawable not found in stack")
  end
  -- TODO(lobato): walk up the draw stack.
end
