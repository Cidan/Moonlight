---@meta

---@enum RenderStepType
RenderStepType = {
  RENDER_PRE = "RENDER_PRE",
  RENDER_DEP = "RENDER_DEP",
  RENDER_SELF = "RENDER_SELF"
}

---@class RenderResults
---@field Results table<Drawable, RenderResult>

---@class RenderResult
---@field Width number
---@field Height number
---@field FullWidth? number

---@class RenderStep
---@field step RenderStepType
---@field target? Drawable

---@class RenderOptions
---@field OnlyRedraw boolean

---@class RenderPlan
---@field Plan RenderStep[]
