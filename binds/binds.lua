local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class binds
local binds = moonlight:NewClass("binds")

---@param fn function
function binds:OnBagShow(fn)
  hooksecurefunc('ToggleAllBags', fn)
end

function binds:HideBlizzardBags()
  local sneaky = CreateFrame("Frame")
  sneaky:Hide()
  ContainerFrameCombinedBags:SetParent(sneaky)
  for i = 1, 13 do
    _G["ContainerFrame"..i]:SetParent(sneaky)
  end
end