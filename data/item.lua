local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class item
---@field pool Pool
---@field mixinToItem table<ItemMixin, Item>
local item = moonlight:NewClass("item")
item.mixinToItem = {}

--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class MoonlightItem
---@field mixin ItemMixin
---@field itemData ItemData
local MoonlightItem = {}

---@return MoonlightItem
local itemConstructor = function()
  local instance = {
    itemData = {}
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = MoonlightItem
  })
end

---@param _w MoonlightItem
local itemDeconstructor = function(_w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return MoonlightItem
function item:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(itemConstructor, itemDeconstructor)
  end

  return self.pool:TakeOne("MoonlightItem")
end

---@param mixin ItemMixin
function MoonlightItem:SetItemMixin(mixin)
  if self.mixin ~= nil then
    if self.mixin ~= mixin then
      error("item mixins on moonlight items are immutable")
    end
    return
  end
  self.mixin = mixin
end

--- ReadItemData reads all the properties needed for this item to function
--- within Moonlight, and stores that data. This function must always be
--- declarative such that it represents the absoulte state of the item.
function MoonlightItem:ReadItemData()
  if self.mixin == nil then
    error("no item mixin attached to this item, can't read data!")
  end
  local mixin = self.mixin
  -- Delete all the old data.
  wipe(self.itemData)

  local location = mixin:GetItemLocation()
  if location.GetBagAndSlot == nil then
    --TODO(lobato): Fix this annotation bug.
    error("TODO: Fix this annotation bug")
  end

  self.itemData.BagID, self.itemData.SlotID = location:GetBagAndSlot() 

  -- Properties we set on all item data, even if it's empty.
  self.itemData.BagName = C_Container.GetBagName(self.itemData.BagID --[[@as Enum.BagIndex]])

  if mixin:IsItemEmpty() then
    self.itemData.Empty = true
    return
  end

  -- Only items that have actual items in them are processed here.
  self.itemData.ItemID = mixin:GetItemID()
  self.itemData.ItemIcon = mixin:GetItemIcon()
  self.itemData.ItemName = mixin:GetItemName()
  self.itemData.ItemLink = mixin:GetItemLink()
  self.itemData.ItemGUID = mixin:GetItemGUID()
  self.itemData.ItemQuality = mixin:GetItemQuality()
  self.itemData.ItemStackedCount = C_Item.GetStackCount(location --[[@as ItemLocation]])

  local _itemName, _, _,
  _itemLevel, _itemMinLevel, itemType, _itemSubType,
  _itemStackCount, _itemEquipLoc, _itemTexture,
  _sellPrice, _classID, _subclassID, bindType, _expacID,
  _setID = C_Item.GetItemInfo(self.itemData.ItemLink)
  self.itemData.ItemType = itemType

  if self.itemData.ItemID == 82800 then
    self.itemData.Cage = true
  else
    self.itemData.Cage = false
  end

  self.itemData.IsNewItem = C_NewItems.IsNewItem(self.itemData.BagID --[[@as Enum.BagIndex]], self.itemData.SlotID)
  self.itemData.ItemLinkInfo = self:parseItemLink(self.itemData.ItemLink)
  self.itemData.CurrentItemLevel = C_Item.GetCurrentItemLevel(location) --[[@as number]]
  self.itemData.BindingInfo = self:getItemBinding(location, bindType --[[@as Enum.ItemBind]])
  self.itemData.ItemHash = self:generateItemHash(self.itemData)

  self:CalculateMoonlightCategory()
end

---@return ItemData
function MoonlightItem:GetItemData()
  return self.itemData
end

--- CalculateMoonlightCategory calculates a the category
--- an item should be in, and sets it on the item.
function MoonlightItem:CalculateMoonlightCategory()
  local data = self.itemData
  local t = data.ItemType

  if t == "Weapon" or t == "Armor" then
    data.MoonlightCategory = "Armor and Weapons"
  elseif t == "Tradeskill" or t == "Reagent" then
    data.MoonlightCategory = "Tradeskill"
  elseif data.ItemType ~= nil then
    data.MoonlightCategory = data.ItemType
  else
    data.MoonlightCategory = "Miscellaneous"
  end

  if data.IsNewItem == true then
    data.DisplayCategory = "New Items"
  else
    data.DisplayCategory = data.MoonlightCategory
  end
end

--- GetMoonlightCategory returns the category an item is in.
---@return string
function MoonlightItem:GetMoonlightCategory()
  return self.itemData.MoonlightCategory
end

--- GetDisplayCategory is the display category for an item, which might
--- be different than a Moonlight category, i.e. new items.
--- This category is used for display in the bag and in section sorting.
---@return string
function MoonlightItem:GetDisplayCategory()
  return self.itemData.DisplayCategory
end

---@param link string
---@return ItemLinkInfo
function MoonlightItem:parseItemLink(link)
	-- Parse the first elements that have no variable length
	local _, _, itemID, enchantID, gemID1, gemID2, gemID3, gemID4,
	suffixID, uniqueID, linkLevel, specializationID, modifiersMask,
	itemContext, rest = strsplit(":", link, 15) --[[@as string]]

  ---@type string, string
	local crafterGUID, extraEnchantID
  ---@type string, string[]
	local numBonusIDs, bonusIDs
  ---@type string, string[]
  local numModifiers, modifierIDs
  ---@type string, string[]
	local relic1NumBonusIDs, relic1BonusIDs
  ---@type string, string[]
	local relic2NumBonusIDs, relic2BonusIDs
  ---@type string, string[]
	local relic3NumBonusIDs, relic3BonusIDs

  if rest ~= nil then
	  numBonusIDs, rest = strsplit(":", rest, 2) --[[@as string]]

	  if numBonusIDs ~= "" then
	  	local splits = (self:mustConvertToNumber(numBonusIDs))+1
	  	bonusIDs = strsplittable(":", rest, splits)
	  	rest = table.remove(bonusIDs, splits --[[@as integer]])
	  end

	  numModifiers, rest = strsplit(":", rest, 2) --[[@as string]]
	  if numModifiers ~= "" then
	  	local splits = (self:mustConvertToNumber(numModifiers)*2)+1
	  	modifierIDs = strsplittable(":", rest, splits)
	  	rest = table.remove(modifierIDs, splits --[[@as integer]])
	  end

	  relic1NumBonusIDs, rest = strsplit(":", rest, 2) --[[@as string]]
	  if relic1NumBonusIDs ~= "" then
	  	local splits = (self:mustConvertToNumber(relic1NumBonusIDs))+1
	  	relic1BonusIDs = strsplittable(":", rest, splits)
	  	rest = table.remove(relic1BonusIDs, splits --[[@as integer]])
	  end

	  relic2NumBonusIDs, rest = strsplit(":", rest, 2) --[[@as string]]
	  if relic2NumBonusIDs ~= "" then
	  	local splits = (self:mustConvertToNumber(relic2NumBonusIDs))+1
	  	relic2BonusIDs = strsplittable(":", rest, (self:mustConvertToNumber(relic2NumBonusIDs))+1)
	  	rest = table.remove(relic2BonusIDs, splits --[[@as integer]])
	  end

	  relic3NumBonusIDs, rest = strsplit(":", rest, 2) --[[@as string]]
	  if relic3NumBonusIDs ~= "" then
	  	local splits = (self:mustConvertToNumber(relic3NumBonusIDs))+1
	  	relic3BonusIDs = strsplittable(":", rest, (self:mustConvertToNumber(relic3NumBonusIDs))+1)
	  	rest = table.remove(relic3BonusIDs, splits --[[@as integer]])
	  end

    ---@type string, string
	  crafterGUID, extraEnchantID = strsplit(":", rest, 3)
  end

	return {
		ItemID = self:mustConvertToNumber(itemID),
		EnchantID = enchantID,
		GemID1 = gemID1,
		GemID2 = gemID2,
		GemID3 = gemID3,
		GemID4 = gemID4,
		SuffixID = suffixID,
		UniqueID = uniqueID,
		LinkLevel = linkLevel,
		SpecializationID = specializationID,
		ModifiersMask = modifiersMask,
		ItemContext = itemContext,
		BonusIDs = bonusIDs or {},
		ModifierIDs = modifierIDs or {},
		Relic1BonusIDs = relic1BonusIDs or {},
		Relic2BonusIDs = relic2BonusIDs or {},
		Relic3BonusIDs = relic3BonusIDs or {},
		CrafterGUID = crafterGUID or "",
		ExtraEnchantID = extraEnchantID or ""
	}
end

---@param str string
---@return number
function MoonlightItem:mustConvertToNumber(str)
  local result = tonumber(str)
  if result == nil then
    error("could not convert string to number")
  end
  return result
end

---@param data ItemData
---@return string
function MoonlightItem:generateItemHash(data)
  --local stackOpts = database:GetStackingOptions(data.kind)
  local hash = format("%d%s%s%s%s%s%s%s%s%s%s%s%d%d",
    data.ItemLinkInfo.ItemID,
    data.ItemLinkInfo.EnchantID,
    data.ItemLinkInfo.GemID1,
    data.ItemLinkInfo.GemID2,
    data.ItemLinkInfo.GemID3,
    data.ItemLinkInfo.SuffixID,
    table.concat(data.ItemLinkInfo.BonusIDs, ","),
    --table.concat(data.ItemLinkInfo.modifierIDs, ","),
    table.concat(data.ItemLinkInfo.Relic1BonusIDs, ","),
    table.concat(data.ItemLinkInfo.Relic2BonusIDs, ","),
    table.concat(data.ItemLinkInfo.Relic3BonusIDs, ","),
    data.ItemLinkInfo.CrafterGUID or "",
    data.ItemLinkInfo.ExtraEnchantID or "",
    data.BindingInfo.Binding,
    data.CurrentItemLevel
  )
  return hash
end

---@param itemLocation ItemLocationMixin
---@param bindType Enum.ItemBind
---@return BindingInfo
function MoonlightItem:getItemBinding(itemLocation, bindType)
  local const = moonlight:GetConst()

  if itemLocation.GetBagAndSlot == nil then
    error("fix this annotation in ketho's lib")
  end

  local bagID, slotID = itemLocation:GetBagAndSlot()
  ---@type BindingInfo
  local bindinginfo = {
    Binding = const.BINDING_SCOPE.UNKNOWN,
    Bound = false
  }

  if not C_Item.IsBound(itemLocation) then
    if (bindType == 0) then
      bindinginfo.Binding = const.BINDING_SCOPE.NONBINDING
    elseif (bindType == 2) then
      bindinginfo.Binding = const.BINDING_SCOPE.BOE
    elseif (bindType == 3) then
      bindinginfo.Binding = const.BINDING_SCOPE.BOU
    elseif (bindType == 8) then -- only Hoard of Draconic Delicacies uses this
      bindinginfo.Binding = const.BINDING_SCOPE.BNET
    end

    if C_Item.IsBoundToAccountUntilEquip(itemLocation) then
      bindinginfo.Bound = true
      bindinginfo.Binding = const.BINDING_SCOPE.WUE
    end
  else -- Item is bound in some way, figure out what.
    bindinginfo.Bound = true
    bindinginfo.Binding = const.BINDING_SCOPE.SOULBOUND

    if C_Bank.IsItemAllowedInBankType(Enum.BankType.Account, itemLocation) then
      bindinginfo.Binding = const.BINDING_SCOPE.ACCOUNT
    end

    if C_Container.GetContainerItemPurchaseInfo(bagID --[[@as Enum.BagIndex]], slotID, false) == true then
      bindinginfo.Binding = const.BINDING_SCOPE.REFUNDABLE
    end

    if (bindType == 4) then
      bindinginfo.Binding = const.BINDING_SCOPE.QUEST
    end
  end -- isBound

  return bindinginfo
end
