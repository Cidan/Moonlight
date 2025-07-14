local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class loader
---@field attached boolean
local loader = moonlight:NewClass("loader")

function loader:FullRefreshAllBags()
end

function loader:RefreshSpecificBag()
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