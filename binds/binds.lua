local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class binds
local binds = moonlight:NewClass("binds")

---@param fn function
function binds:OnBagToggle(fn)
  ToggleAllBags = fn
end

function binds:Boot()
  local event = moonlight:GetEvent()
  local backpack = moonlight:GetBackpack():GetBackpack()

  -- Hide the Blizzard bags.
  binds:HideBlizzardBags()

  -- Close special frames when demanded (i.e. escape)
  hooksecurefunc("CloseSpecialWindows", function(f)
    self:CloseSpecialWindows(f)
  end)

  -- Register the backpack as a special frame.
  table.insert(UISpecialFrames, backpack:GetName())

  -- Register for interaction open and close events
  event:ListenForEvent(
    "PLAYER_INTERACTION_MANAGER_FRAME_SHOW", 
    function(...)
      self:OpenInteractionWindow(...)
    end
  )

  event:ListenForEvent(
    "PLAYER_INTERACTION_MANAGER_FRAME_HIDE", 
    function(...)
      self:CloseInteractionWindow(...)
    end
  )
end

function binds:HideBlizzardBags()
  local sneaky = CreateFrame("Frame")
  sneaky:Hide()
  ContainerFrameCombinedBags:SetParent(sneaky)
  for i = 1, 6 do
    _G["ContainerFrame"..i]:SetParent(sneaky)
  end
end

---@param interaction Enum.PlayerInteractionType
function binds:OpenInteractionWindow(interaction)
  local const = moonlight:GetConst()
  local backpack = moonlight:GetBackpack():GetBackpack()
  if const.EVENTS_THAT_OPEN_BACKPACK[interaction] ~= true then
    return
  end
  if GameMenuFrame:IsShown() then
    return
  end
  backpack:Show(false)
end

---@param interaction Enum.PlayerInteractionType
function binds:CloseInteractionWindow(interaction)
  local const = moonlight:GetConst()
  local backpack = moonlight:GetBackpack():GetBackpack()
  if const.EVENTS_THAT_OPEN_BACKPACK[interaction] == nil then
    return
  end
  backpack:Hide(false)
end

---@param interactingFrame Frame
function binds:CloseSpecialWindows(interactingFrame)
  if interactingFrame ~= nil then return end
  local backpack = moonlight:GetBackpack():GetBackpack()
  backpack:Hide(false)
end