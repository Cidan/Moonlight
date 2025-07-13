---@diagnostic disable-next-line: unbalanced-assignments
---@type string, table
local _name, space = ...

---@class Moonlight
---@field space table
---@field classes table<string, table>
local Moonlight = {
  space = space,
  classes = {}
}

---@param name string
---@return table
function Moonlight:NewClass(name)
  self.classes[name] = {}
  return self.classes[name]
end

function Moonlight:Start()
  local d = self:GetDebug():New()
  d:NewTestWindow()
  -- All modules are loaded via the .toc file now.
  -- We can access them via their Get methods.
end

---@return window
function Moonlight:GetWindow()
  return self.classes.window
end

---@return debug
function Moonlight:GetDebug()
  return self.classes.debug
end

---@return decorate
function Moonlight:GetDecorate()
  return self.classes.decorate
end

---@return context
function Moonlight:GetContext()
  return self.classes.context
end

---@return Moonlight
function GetMoonlight()
  return Moonlight
end

---@return pool
function Moonlight:GetPool()
  return self.classes.pool
end
---@return container
function Moonlight:GetContainer()
  return self.classes.container
end
---@return animation
function Moonlight:GetAnimation()
  return self.classes.animation
end
---@return binds
function Moonlight:GetBinds()
  return self.classes.binds
end