---@meta

---@class Masque
---@field Group fun(self: Masque, name: string): MasqueGroup

---@class MasqueGroup
---@field AddButton fun(self: MasqueGroup, button: ItemButton|table|ContainerFrameItemButtonTemplate, regions?: table, type: string)
---@field ReSkin fun(self: MasqueGroup, button?: ContainerFrameItemButton)