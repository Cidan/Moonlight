local moonlight = GetMoonlight()
local const = moonlight:GetConst()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class loader
---@field attached boolean
local loader = moonlight:NewClass("loader")

---@param mixin ItemMixin
---@return SlotKey
function loader:GenerateSlotKeyFromMixin(mixin)
  ---@type ItemLocation
  local loc = mixin:GetItemLocation()
  if loc == nil then
    error("item mixin has an invalid location")
  end
  --local bagID, slotID = loc:GetBagAndSlot()
  return ""
end

-- This forces a full refresh of the item database.
-- Generally, this is pretty expensive and should be avoided.
function loader:FullRefreshAllBagData()
end

function loader:RefreshSpecificBagData()
end

function loader:Boot()
  -- We need to loop through all available bags and create mixins.
  for bagID in pairs(const.BACKPACK_BAGS) do
    -- Get the number of slots in the container.
    local totalSlots = C_Container.GetContainerNumSlots(bagID)
    for slotID=1, totalSlots do
      local itemMixin = Item:CreateFromBagAndSlot(bagID, slotID)
    end
  end

  self:AttachToEvents()
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
    local bagid = ...
    print("bag updated:", ...)
  end)
end

---@param mixins ItemMixin[]
---@param callback fun(mixins: ItemMixin[])
function loader:LoadTheseItemsAndCallback(mixins, callback)
end