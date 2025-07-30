---@meta

---@class MoonAnimationScale
---@field ScaleX number
---@field ScaleY number

---@class MoonAnimationOrigin
---@field Point FramePoint
---@field OriginX number
---@field OriginY number

---@class MoonAnimationOffsets
---@field OffsetX number
---@field OffsetY number

---@class MoonAnimationConfig
---@field type string
---@field duration number
---@field origin MoonAnimationOrigin | nil
---@field ScaleFrom MoonAnimationScale | nil
---@field ScaleTo MoonAnimationScale | nil
---@field Smoothing SmoothingType | nil
---@field FromAlpha number | nil
---@field ToAlpha number | nil
---@field Children MoonAnimationConfig[] | nil
---@field OnFinished function | nil
---@field Offsets MoonAnimationOffsets | nil