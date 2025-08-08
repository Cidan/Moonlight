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

--------------------------------------------------------------------------------
-- List View Architecture
--------------------------------------------------------------------------------

--- ListRowContainer is the drawable unit for the row itself. It is a simple frame that acts
--- as a parent for all the individual cell drawables in the row. It also holds the data
--- associated with the row.
--- This is considered an internal implementation detail of the list view and not configured directly.
---@class ListRowContainer: Drawable
---@field children Drawable[] An ordered list of the cell drawables that make up this row.
---@field RowData any The raw data for this row, retrieved from the DataProvider.
---@field IsDirty boolean If true, the row needs to be redrawn with the latest data.

--- ListColumn defines the properties and behavior of a single column in the list. It specifies
--- the column's size and, most importantly, the functions for creating, updating, and releasing
--- the visual cell (`Drawable`) for that column. This is the core of the declarative UI.
---@class ListColumn
---@field Name string A unique identifier for the column.
---@field Width number | "FILL" The width of the column. Can be a fixed number or "FILL" to have it expand to take up the remaining available space.
---@field CreateCell fun(rowData: any): Drawable A factory function that creates a new drawable for this column based on the row's data. This is called when a new cell needs to be created.
---@field UpdateCell fun(cell: Drawable, rowData: any) A function that updates an existing cell's drawable with new data. This is essential for view recycling/pooling, as it avoids the cost of creating new objects.
---@field ReleaseCell fun(cell: Drawable) A function to release a cell's drawable, preparing it to be returned to an object pool.

--- ListConfig is the top-level configuration object for a list view. It brings together the data provider
--- and column definitions into a single, declarative blueprint that defines an entire list view.
---@class ListConfig
---@field DataProvider DataProviderMixin The provider for the list's data, conforming to Blizzard's DataProviderMixin interface.
---@field Columns ListColumn[] An ordered list of column definitions, from left to right.
---@field RowHeight number The fixed height of each row in the list.