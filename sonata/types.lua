---@meta

---@class SonataDecoration
---@field GetInsets fun(): Insets

---@class BagTheme: WindowTheme

---@class PopupTheme
---@field BorderDecoration? BorderDecoration
---@field BackgroundDecoration? BackgroundDecoration
---@field TitleDecoration? TitleDecoration
---@field Animations? ThemeAnimationSet
---@field Inset Insets

---@class WindowTheme
---@field CloseButtonDecoration? CloseButtonDecoration
---@field BorderDecoration? BorderDecoration
---@field BackgroundDecoration? BackgroundDecoration
---@field HandleDecoration? HandleDecoration
---@field TitleDecoration? TitleDecoration
---@field ResizeDecoration? ResizeDecoration
---@field ExtraTextures? ExtraTexturesDecoration
---@field Animations? ThemeAnimationSet
---@field Inset Insets

---@class TabTheme
---@field UseIcon boolean
---@field Width number
---@field Height number
---@field BackgroundDecoration? BackgroundDecoration
---@field BorderDecoration? BorderDecoration
---@field MaskTexture? string

---@class Theme
---@field Name string
---@field BagTheme? BagTheme
---@field WindowTheme? WindowTheme
---@field PopupTheme? PopupTheme

---@class ThemeAnimationSet
---@field Show MoonAnimationConfig[]
---@field Hide MoonAnimationConfig[]

---@class Insets
---@field Top number
---@field Bottom number
---@field Left number
---@field Right number

---@class Color
---@field R number
---@field G number
---@field B number
---@field A number

---@class CloseButtonDecoration
---@field Width uiUnit
---@field Height uiUnit
---@field XOffset? uiUnit
---@field YOffset? uiUnit
---@field Text string
---@field Point? HandlePoint

---@class BorderDecoration
---@field Texture string
---@field SliceMode Enum.UITextureSliceMode
---@field SliceMargins Insets
---@field VertexColor Color
---@field Inset Insets

---@class BackgroundDecoration
---@field Texture string
---@field SliceMode Enum.UITextureSliceMode
---@field SliceMargins Insets
---@field VertexColor Color
---@field Inset Insets

---@class HandleDecoration
---@field Points HandlePoint[]
---@field Width? number
---@field Height? number

---@class ResizeDecoration
---@field Corner FramePoint

---@class TitleDecoration
---@field Point HandlePoint
---@field Width number
---@field Height number
---@field Color Color

---@class ExtraTexturesDecoration
---@field Textures ExtraTexture[]

---@class ExtraTexture
---@field Point HandlePoint
---@field Texture string
---@field SliceMode Enum.UITextureSliceMode
---@field SliceMargins Insets
---@field VertexColor Color
---@field Inset Insets

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

---@class SonataBag: SonataWindow
