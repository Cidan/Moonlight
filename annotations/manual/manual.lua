---@meta

---@type Frame
ContainerFrameCombinedBags = {}

---@class Frame
---@field scrollable boolean

---@class WowScrollBox
---@field SetDataProvider fun(self: WowScrollBox, provider: DataProviderMixin)

---@class ItemButton: Frame, ItemButtonMixin

---@class ContainerFrameItemButton: Frame, ContainerFrameItemButtonMixin, ItemButton
---@field ClearNormalTexture function
---@field IconBorder Texture
---@field NewItemTexture Texture
---@field IconQuestTexture Texture
---@field IconOverlay Texture

---@type SimpleFrame
UIParent = {}

Enum.BagIndex.Characterbanktab = -2
Enum.BagIndex.CharacterBankTab_1 = 6
Enum.BagIndex.CharacterBankTab_2 = 7
Enum.BagIndex.CharacterBankTab_3 = 8
Enum.BagIndex.CharacterBankTab_4 = 9
Enum.BagIndex.CharacterBankTab_5 = 10
Enum.BagIndex.CharacterBankTab_6 = 12