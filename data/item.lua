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
  _sellPrice, _classID, _subclassID, _bindType, _expacID,
  _setID = C_Item.GetItemInfo(self.itemData.ItemLink)
  self.itemData.ItemType = itemType

  if self.itemData.ItemID == 82800 then
    self.itemData.Cage = true
  else
    self.itemData.Cage = false
  end

  self.itemData.IsNewItem = C_NewItems.IsNewItem(self.itemData.BagID --[[@as Enum.BagIndex]], self.itemData.SlotID)

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
end

--- GetMoonlightCategory returns the category an item is in.
--- This category is used for display in the bag and in section sorting.
---@return string
function MoonlightItem:GetMoonlightCategory()
  return self.itemData.MoonlightCategory
end