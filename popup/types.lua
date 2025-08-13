---@meta

---@class PopupElement
---@field Type "divider" | "label" | "item" Type is the type of element this is in the popup.
---@field Title string Title is the title of this item or label.
---@field OnClick fun()? On click is an optional function that is called when this item is clicked. Only valid for item types.
---@field CanToggle boolean CanToggle denotes that this item has an on and off state denoted by a checkbox drawn next to the item on the left.
---@field IsChecked? fun():boolean IsChecked is a function that should be called when rendering a CanToggle box, that returns the state of the checkbox.
---@field CloseOnClick boolean CloseOnClick tells the popup window to close when this item is clicked.
---@field SubMenu? PopupElement[] SubMenu is a list of optional sub elements for creating nested popup windows.

---@class PopupConfig
---@field Title string
---@field Elements PopupElement[]