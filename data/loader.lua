local moonlight = GetMoonlight()
local const = moonlight:GetConst()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class loader
---@field attached boolean
---@field ItemMixinsBySlotKey table<SlotKey, ItemMixin>
---@field ItemMixinsByBag table<number, ItemMixin[]>
---@field BagItemMixins table<BagID, ItemMixin>
---@field BagNamesCache table<BagID, string>
---@field bagUpdateCallbacks fun(t: table<BagID, ItemMixin[]>)[]
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

  local bagSet = {}
  bagSet[bagID] = bagID

  -- Phase 1: Create and load bag items themselves
  self:CreateBagItemMixinsForBagSet(bagSet)
  self:LoadBagNamesForBagSet(bagSet, function()
    -- Phase 2: Load bag contents (now that bag names are cached)
    local mixinTable = {}
    mixinTable[bagID] = self.ItemMixinsByBag[bagID]
    self:LoadTheseItemsAndCallbackToMe(
      self.ItemMixinsByBag[bagID],
      function(_mixins)
        for _, callback in pairs(self.bagUpdateCallbacks) do
          callback(mixinTable)
        end
      end
    )
  end)
end

function loader:Boot()
  self.ItemMixinsBySlotKey = {}
  self.ItemMixinsByBag = {}
  self.BagItemMixins = {}
  self.BagNamesCache = {}
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

---@param bagSet table<BagID, BagID>
function loader:ScanSpecificBagSet(bagSet)
  -- Scan a specific set of bags and create/update item mixins.
  for bagID in pairs(bagSet) do
    local totalSlots = C_Container.GetContainerNumSlots(bagID --[[@as Enum.BagIndex]])
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

-- Scan character bank bags (bags 6-12 + main bank -1).
function loader:ScanBankBags()
  self:ScanSpecificBagSet(const.BANK_BAGS)
end

-- Scan account-wide bank bags (bags 13-17).
function loader:ScanAccountBankBags()
  self:ScanSpecificBagSet(const.ACCOUNT_BANK_BAGS)
end

-- Scan all bank bags (character + account).
function loader:ScanAllBankBags()
  self:ScanBankBags()
  self:ScanAccountBankBags()
end

---@param bagSet table<BagID, BagID>
function loader:CreateBagItemMixinsForBagSet(bagSet)
  for bagID in pairs(bagSet) do
    -- Don't create mixins for special bags that don't have items
    if bagID ~= Enum.BagIndex.Backpack and bagID ~= Enum.BagIndex.Reagentbank then
      if self.BagItemMixins[bagID] == nil then
        -- Bags themselves are stored in equipment slots
        local bagSlotIndex = C_Container.ContainerIDToInventoryID(bagID)
        if bagSlotIndex ~= nil then
          local itemLocation = ItemLocation:CreateFromEquipmentSlot(bagSlotIndex)
          if C_Item.DoesItemExist(itemLocation) then
            local bagMixin = Item:CreateFromItemLocation(itemLocation)
            self.BagItemMixins[bagID] = bagMixin
          end
        end
      end
    end
  end
end

---@param bagSet table<BagID, BagID>
---@param callback fun()
function loader:LoadBagNamesForBagSet(bagSet, callback)
  local bagMixinsToLoad = {}

  for bagID in pairs(bagSet) do
    if self.BagItemMixins[bagID] ~= nil then
      table.insert(bagMixinsToLoad, self.BagItemMixins[bagID])
    end
  end

  -- If no bags to load, call callback immediately
  if #bagMixinsToLoad == 0 then
    -- Still need to cache names for special bags
    for bagID in pairs(bagSet) do
      if self.BagNamesCache[bagID] == nil then
        local name = C_Container.GetBagName(bagID --[[@as Enum.BagIndex]])
        if name ~= nil then
          self.BagNamesCache[bagID] = name
        else
          self.BagNamesCache[bagID] = self:GetFallbackBagName(bagID)
        end
      end
    end
    callback()
    return
  end

  -- Load bag items asynchronously
  local continue = ContinuableContainer:Create()
  for _, mixin in pairs(bagMixinsToLoad) do
    continue:AddContinuable(mixin)
  end

  continue:ContinueOnLoad(function()
    -- Cache bag names after they're loaded
    for bagID in pairs(bagSet) do
      if self.BagNamesCache[bagID] == nil then
        local name = C_Container.GetBagName(bagID --[[@as Enum.BagIndex]])
        if name ~= nil then
          self.BagNamesCache[bagID] = name
        else
          self.BagNamesCache[bagID] = self:GetFallbackBagName(bagID)
        end
      end
    end
    callback()
  end)
end

---@param bagID BagID
---@return string
function loader:GetFallbackBagName(bagID)
  if bagID == Enum.BagIndex.Backpack then
    return BAG_NAME_BACKPACK or "Backpack"
  elseif bagID == Enum.BagIndex.ReagentBag then
    return "Reagent Bag"
  elseif bagID == Enum.BagIndex.Reagentbank then
    return "Reagent Bank"
  elseif bagID >= Enum.BagIndex.CharacterBankTab_1 and bagID <= Enum.BagIndex.CharacterBankTab_6 then
    local tabNum = bagID - Enum.BagIndex.CharacterBankTab_1 + 1
    return format("Bank Bag %d", tabNum)
  elseif bagID >= Enum.BagIndex.AccountBankTab_1 and bagID <= Enum.BagIndex.AccountBankTab_5 then
    local tabNum = bagID - Enum.BagIndex.AccountBankTab_1 + 1
    return format("Account Bank Tab %d", tabNum)
  else
    return format("Bag %d", bagID + 1)
  end
end

---@param bagID BagID
---@return string
function loader:GetBagName(bagID)
  return self.BagNamesCache[bagID] or self:GetFallbackBagName(bagID)
end

function loader:AttachToEvents()
  ---@type table<number, boolean>
  local bagUpdateBucket = {}
  local event = moonlight:GetEvent()
  if self.attached == true then
    error("item loader is already attached")
  end
  self.attached = true
  event:ListenForEvent("BAG_UPDATE_DELAYED", function(...)
    ---@type table<BagID, ItemMixin[]>
    local bagIDToMixins = {}

    ---@type ItemMixin[]
    local allMixins = {}
    for bagID, x in pairs(bagUpdateBucket) do
      if self.ItemMixinsByBag[bagID] ~= nil then
        bagIDToMixins[bagID] = self.ItemMixinsByBag[bagID]
        for _, m in pairs(self.ItemMixinsByBag[bagID]) do
          table.insert(allMixins, m)
        end
      end
    end

    self:LoadTheseItemsAndCallbackToMe(allMixins, function(_resultMixins)
      for _, callback in pairs(self.bagUpdateCallbacks) do
        callback(bagIDToMixins)
      end
    end)

    wipe(bagUpdateBucket)
  end)

  -- TODO(lobato): add a failsafe where if a BAG_UPDATE_DELAYED
  -- call isn't made after a certain amount of time, we force an update.
  event:ListenForEvent("BAG_UPDATE", function(...)
    local bagID = ...
    bagUpdateBucket[bagID] = true
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

---@param callback fun(t: table<BagID, ItemMixin[]>)
function loader:TellMeWhenABagIsUpdated(callback)
  table.insert(self.bagUpdateCallbacks, callback)
end

---@param slotKey string
---@return ItemMixin?
function loader:GetItemMixinFromSlotKey(slotKey)
  return self.ItemMixinsBySlotKey[slotKey]
end