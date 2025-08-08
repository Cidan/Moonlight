---@meta

--------------------------------------------------------------------------------
-- List View Architecture
--------------------------------------------------------------------------------

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
