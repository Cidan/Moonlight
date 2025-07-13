---@meta

---@class Color
---@field R number
---@field G number
---@field B number
---@field A number

---@class SliceMargins
---@field Left number
---@field Top number
---@field Right number
---@field Bottom number

---@class CloseButtonDecoration
---@field Width uiUnit
---@field Height uiUnit
---@field XOffset? uiUnit
---@field YOffset? uiUnit
---@field Text string
---@field Point? HandlePoint

---@class BorderDecoration
---@field test boolean

---@class BackgroundDecoration
---@field Texture string
---@field SliceMode Enum.UITextureSliceMode
---@field SliceMargins SliceMargins
---@field VertexColor Color

---@class HandleDecoration
---@field Points HandlePoint[]
---@field Width number
---@field Height number

---@class Point
---@field Point FramePoint
---@field RelativeTo Frame | string | GlueParent
---@field RelativePoint? FramePoint
---@field XOffset? number | nil
---@field YOffset? number | nil

---@class HandlePoint
---@field Point FramePoint
---@field RelativePoint? FramePoint
---@field XOffset? number | nil
---@field YOffset? number | nil