---@meta

---@type Frame
ContainerFrameCombinedBags = {}

---@class Frame
---@field scrollable boolean


---@class ItemButton: Frame, ItemButtonMixin

---@class ContainerFrameItemButton: Frame, ContainerFrameItemButtonMixin, ItemButton
---@field ClearNormalTexture function
---@field IconBorder Texture
---@field NewItemTexture Texture
---@field IconQuestTexture Texture
---@field IconOverlay Texture

---@type SimpleFrame
UIParent = {}