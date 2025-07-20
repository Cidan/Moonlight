---@meta

---@class (exact) Bag
---@field window Window
---@field GetFrame fun(): Frame
---@field SetDecoration fun(self: Bag, b?: SonataBag)
---@field Hide fun(self: Bag, doNotAnimate?: boolean)
---@field Show fun(self: Bag, doNotAnimate?: boolean)
---@field GetTitle fun(): string
---@field GetWindow fun(): Window

---@class (exact) BagDataConfig
---@field BagNameAsSections boolean
---@field ShowEmptySlots boolean
---@field CombineAllItems boolean