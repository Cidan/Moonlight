---@meta

---@class PopupElement
---@field Type "divider" | "label" | "item"
---@field Title string
---@field OnClick fun()?
---@field IsChecked fun():boolean
---@field CloseOnClick boolean
---@field SubMenu PopupElement[]

---@class PopupConfig
---@field Title string
---@field Elements PopupElement[]