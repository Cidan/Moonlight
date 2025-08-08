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

--- ListRowContainer is the drawable unit for the row itself.
--- It contains a single frame to which all items in the row must
--- parent to. The ListRowContainer will render it's children as
--- it comes into view.
---@class ListRowContainer: Drawable
---@field children Drawable

--- ListColumn is a single column definition for a list.
---@class ListColumn
---@field Name string

---@class ListRow
---@field RowData table

---@class ListConfig
---@field Columns ListColumn[] An ordered list of columns, from left to right.
---@field RowRenderer fun(row: ListRow): Drawable
---@field RowReleaser fun(row: ListRow, d: Drawable)