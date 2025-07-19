---@meta

---@class TabConfig
---@field Point Point
---@field Spacing number
---@field Orientation "HORIZONTAL" | "VERTICAL"
---@field GrowDirection "LEFT" | "RIGHT" | "UP" | "DOWN"
---@field TooltipAnchor TooltipAnchor

---@class ContainerChild
---@field Name string
---@field Drawable Drawable
---@field Icon fileID | string
---@field Title? string

---@class Drawable
---@field Redraw fun(self: Drawable, width: number): number
---@field ClearAllPoints function
---@field SetParent fun(self: Drawable, parent: SimpleFrame?)
---@field SetPoint fun(self: Drawable, point: Point)
---@field SetSize fun(self: Drawable, width: number, height: number)
---@field Hide function
---@field Show function
---@field GetID fun(self: Drawable): number
---@field SetMyParentDrawable fun(self: Drawable, d: Drawable)
---@field RemoveMyParentDrawable fun()
---@field RecalculateHeightWithoutDrawing fun(self: Drawable)
---@field GetHeight fun(): number