---@diagnostic disable-next-line: unbalanced-assignments
---@type string, table
local _name, space = ...

---@class Moonlight
---@field globalFrame Frame
---@field space table
---@field classes table<string, table>
local Moonlight = {
  globalFrame = CreateFrame("Frame"),
  space = space,
  classes = {}
}

---@param name string
---@return table
function Moonlight:NewClass(name)
  self.classes[name] = {}
  return self.classes[name]
end

function Moonlight:Load()
  self.globalFrame:RegisterEvent("ADDON_LOADED")
  self.globalFrame:SetScript("OnEvent", function(_, event)
    if event == "ADDON_LOADED" then
      self.globalFrame:UnregisterAllEvents()
      self.globalFrame:SetScript("OnEvent", nil)
      self:Start()
    end
  end)

end

function Moonlight:Start()
  -- All modules and saved variables are loaded from this point on.
  local d = self:GetDebug():New()
  local b = self:GetBinds()
  local loader = self:GetLoader()
  local backpack = self:GetBackpack()

  loader:Boot()
  b:HideBlizzardBags()

  backpack:Boot()
  d:NewTestWindow()
end

---@return window
function Moonlight:GetWindow()
  return self.classes.window
end

---@return debug
function Moonlight:GetDebug()
  return self.classes.debug
end

---@return sonataWindow
function Moonlight:GetSonataWindow()
  return self.classes.sonataWindow
end

---@return context
function Moonlight:GetContext()
  return self.classes.context
end

---@return Moonlight
function GetMoonlight()
  return Moonlight
end

---@return pool
function Moonlight:GetPool()
  return self.classes.pool
end
---@return container
function Moonlight:GetContainer()
  return self.classes.container
end
---@return animation
function Moonlight:GetAnimation()
  return self.classes.animation
end
---@return binds
function Moonlight:GetBinds()
  return self.classes.binds
end
---@return tab
function Moonlight:GetTab()
  return self.classes.tab
end
---@return grid
function Moonlight:GetGrid()
  return self.classes.grid
end
---@return section
function Moonlight:GetSection()
  return self.classes.section
end
---@return item
function Moonlight:GetItem()
  return self.classes.item
end
---@return loader
function Moonlight:GetLoader()
  return self.classes.loader
end
---@return event
function Moonlight:GetEvent()
  return self.classes.event
end
---@return const
function Moonlight:GetConst()
  return self.classes.const
end
---@return itembutton
function Moonlight:GetItembutton()
  return self.classes.itembutton
end
---@return sectionset
function Moonlight:GetSectionset()
  return self.classes.sectionset
end
---@return sonataEngine
function Moonlight:GetSonataEngine()
  return self.classes.sonataEngine
end
---@return backpack
function Moonlight:GetBackpack()
  return self.classes.backpack
end
---@return bank
function Moonlight:GetBank()
  return self.classes.bank
end