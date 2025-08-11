local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class stack
---@field pool Pool
---@field hashToStack table<string, Stack>
---@field slotKeyToStack table<string, Stack>
local stack = moonlight:NewClass("stack")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Stack
---@field itemHash string
---@field sortedSlotKeys string[]
local Stack = {}

---@return Stack
local stackConstructor = function()
  local instance = {
    sortedSlotKeys = {}
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Stack
  })
end

---@param w Stack
local stackDeconstructor = function(w)
  stack.hashToStack[w.itemHash] = nil
  wipe(w.sortedSlotKeys)
  w.itemHash = nil
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Stack
function stack:new()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(stackConstructor, stackDeconstructor)
  end

  return self.pool:TakeOne("Stack")
end

function Stack:Release()
  stack.pool:GiveBack("Stack", self)
end

---@param data ItemData?
---@return Stack?
function stack:GetStack(data)
  if self.hashToStack == nil then
    return nil
  end

  if data == nil or data.ItemHash == nil then
    return nil
  end

  local st = self.hashToStack[data.ItemHash]
  if st == nil then
    return nil
  end

  return st
end

function stack:SortAllStacks()
  for _, st in pairs(self.slotKeyToStack) do
    st:Sort()
  end
end

---@param data ItemData?
function stack:UpdateStack(data)
  local debug = moonlight:GetDebug()
  if self.hashToStack == nil then
    ---@type table<string, Stack>
    self.hashToStack = {}
  end

  if self.slotKeyToStack == nil then
    ---@type table<string, Stack>
    self.slotKeyToStack = {}
  end

  if data == nil then
    return
  end

  -- If the slot is now empty, find the previous stack and remove the item.
  if data.Empty == true then
    local previousStack = self.slotKeyToStack[data.SlotKey]
    if previousStack ~= nil then
      previousStack:RemoveItem(data)
    end
    return
  end

  -- There is an item in the slot.
  local st = self.hashToStack[data.ItemHash]
  local previousStack = self.slotKeyToStack[data.SlotKey]

  -- If there was a different item here before, remove it from its old stack.
  if previousStack ~= nil and previousStack ~= st then
    previousStack:RemoveItem(data)
  end

  -- If this is the first time we've seen this item type, create a new stack for it.
  if st == nil then
    st = stack:new()
  end

  -- If the item isn't already in the correct stack, add it.
  if st:HasItem(data) == false then
    st:InsertItem(data)
  end
end

---@param data ItemData
---@return boolean
function Stack:HasItem(data)
  if data == nil then
    return false
  end
  if stack.slotKeyToStack[data.SlotKey] == self then
    return true
  end
  return false
end

---@param data ItemData
function Stack:InsertItem(data)
  if stack.slotKeyToStack[data.SlotKey] ~= nil then
    error("attempted to add an item to a stack when it's already in a stack")
  end

  if self.itemHash ~= nil and data.ItemHash ~= self.itemHash then
    error("attempted to add an item to a stack that does not have the same hash")
  end

  self.itemHash = data.ItemHash
  stack.slotKeyToStack[data.SlotKey] = self
  stack.hashToStack[data.ItemHash] = self
  table.insert(self.sortedSlotKeys, data.SlotKey)
end

function Stack:Sort()
  local loader = moonlight:GetLoader()
  table.sort(self.sortedSlotKeys, function(a, b)
    local aMix = loader:GetItemMixinFromSlotKey(a)
    local bMix = loader:GetItemMixinFromSlotKey(b)
    if aMix == nil or bMix == nil then
      error("slotkey has no item mixin, which should not be possible. huge bug :)")
    end
    local aStack = C_Item.GetStackCount(aMix:GetItemLocation())
    local bStack = C_Item.GetStackCount(bMix:GetItemLocation())
    return aStack < bStack
  end)
end

---@return number
function Stack:GetItemCount()
  return #self.sortedSlotKeys
end

---@param data ItemData
function Stack:RemoveItem(data)
  for idx, slotKey in ipairs(self.sortedSlotKeys) do
    if data.SlotKey == slotKey then
      stack.slotKeyToStack[slotKey] = nil
      table.remove(self.sortedSlotKeys, idx)
      if self:GetItemCount() == 0 then
        self:Release()
      end
      return
    end
  end
  error("attempted to remove an item from a stack, but the item was not found in the stack")
end