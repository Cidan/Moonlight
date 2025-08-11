local moonlight = GetMoonlight()
local const = moonlight:GetConst()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class loader
---@field attached boolean
---@field ItemMixinsBySlotKey table<SlotKey, ItemMixin>
---@field ItemMixinsByBag table<number, ItemMixin[]>
---@field bagUpdateCallbacks fun(bagid: BagID, mixins: ItemMixin[])[]
local loader = moonlight:NewClass("loader")

---@param mixin ItemMixin
---@return SlotKey
function loader:GenerateSlotKeyFromItemMixin(mixin)
  local loc = mixin:GetItemLocation()
  if loc == nil then
    error("item mixin has an invalid location")
  end
  if loc.GetBagAndSlot == nil then
    error("no item location in mixin")
  end
  local bagID, slotID = loc:GetBagAndSlot()

  return self:GenerateSlotKeyFromBagAndSlot(bagID, slotID)
end

---@param bagID BagID
---@param slotID SlotID
---@return SlotKey
function loader:GenerateSlotKeyFromBagAndSlot(bagID, slotID)
  return format("%d_%d", bagID, slotID)
end

-- This forces a full refresh of the item database.
-- Generally, this is pretty expensive and should be avoided.
function loader:FullRefreshAllBagData()
  self:ScanAllBagsAndUpdateItemMixins()
  for bagID in pairs(self.ItemMixinsByBag) do
    self:RefreshSpecificBagDataAndTellEveryone(bagID)
  end
end

---@param bagID BagID
function loader:RefreshSpecificBagDataAndTellEveryone(bagID)
  if self.ItemMixinsByBag[bagID] == nil then
    error("reloading an invalid bag")
  end
  self:LoadTheseItemsAndCallbackToMe(
    self.ItemMixinsByBag[bagID],
    function(mixins)
      for _, callback in pairs(self.bagUpdateCallbacks) do
        callback(bagID, mixins)
      end
    end
  )
end

function loader:Boot()
  self.ItemMixinsBySlotKey = {}
  self.ItemMixinsByBag = {}
  self.bagUpdateCallbacks = {}

  self:AttachToEvents()
end

function loader:ScanAllBagsAndUpdateItemMixins()
  -- We need to loop through all available bags and create mixins.
  for bagID in pairs(const.BACKPACK_BAGS) do
    -- Get the number of slots in the container.
    local totalSlots = C_Container.GetContainerNumSlots(bagID)
    for slotID=1, totalSlots do
      local slotKey = self:GenerateSlotKeyFromBagAndSlot(bagID, slotID)
      if self.ItemMixinsBySlotKey[slotKey] == nil then
        local itemMixin = Item:CreateFromBagAndSlot(bagID, slotID)
        self.ItemMixinsBySlotKey[slotKey] = itemMixin
        self.ItemMixinsByBag[bagID] = self.ItemMixinsByBag[bagID] or {}
        table.insert(self.ItemMixinsByBag[bagID], itemMixin)
      end
    end
  end
end

function loader:AttachToEvents()
  local event = moonlight:GetEvent()
  if self.attached == true then
    error("item loader is already attached")
  end
  self.attached = true
  event:ListenForEvent("BAG_UPDATE_DELAYED", function(...)
  end)

  event:ListenForEvent("BAG_UPDATE", function(...)
    local bagID = ...
    local bagMixins = self.ItemMixinsByBag[bagID]
    if bagMixins == nil then
      return
    end
    self:LoadTheseItemsAndCallbackToMe(bagMixins, function(resultMixins)
      for _, callback in pairs(self.bagUpdateCallbacks) do
        callback(bagID, resultMixins)
      end
    end)
  end)
end

---@param mixins ItemMixin[]
---@param callback fun(mixins: ItemMixin[])
function loader:LoadTheseItemsAndCallbackToMe(mixins, callback)
  local continue = ContinuableContainer:Create()
  for _, mixin in pairs(mixins) do
    if mixin:IsItemEmpty() == false then
      continue:AddContinuable(mixin)
    end      
  end
  continue:ContinueOnLoad(function()
    callback(mixins)
  end)
end

---@param callback fun(bagid: BagID, mixins: ItemMixin[])
function loader:TellMeWhenABagIsUpdated(callback)
  table.insert(self.bagUpdateCallbacks, callback)
end

---@param slotKey string
---@return ItemMixin?
function loader:GetItemMixinFromSlotKey(slotKey)
  return self.ItemMixinsBySlotKey[slotKey]
end