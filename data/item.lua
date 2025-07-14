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

---@param w MoonlightItem
local itemDeconstructor = function(w)
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
--- within Moonlight, and stores that data.
function MoonlightItem:ReadItemData()
  if self.mixin == nil then
    error("no item mixin attached to this item, can't read data!")
  end
  local mixin = self.mixin
  -- Delete all the old data.
  wipe(self.itemData)
  if mixin:IsItemEmpty() then
    self.itemData.Empty = true
    return
  end
  self.itemData.ItemID = mixin:GetItemID()
  self.itemData.ItemIcon = mixin:GetItemIcon()
  self.itemData.ItemName = mixin:GetItemName()
  self.itemData.ItemLink = mixin:GetItemLink()
  self.itemData.ItemGUID = mixin:GetItemGUID()
  self.itemData.ItemQuality = mixin:GetItemQuality()
end