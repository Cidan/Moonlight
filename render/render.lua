local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class render
local render = moonlight:NewClass("render")


---@param d Drawable
---@param parentResult? RenderResult
---@param options RenderOptions
---@param results RenderResults
function render:execute(d, parentResult, options, results)
  if d.GetRenderPlan == nil then
    error("invalid rendering chain, there is no GetRenderPlan on an object in the chain")
  end

  local plan = d:GetRenderPlan()

  ---@type RenderResult?
  local preResult

  for _, step in ipairs(plan.Plan) do
    if step.step == "RENDER_PRE" then
      preResult = d:PreRender(parentResult, options)
    end

    if step.step == "RENDER_DEP" then
      if step.target == nil then
        error("a render dep has no target -- did you set the target field in your render plan?")
      end
      self:execute(step.target, preResult, options, results)
    end

    if step.step == "RENDER_SELF" then
      local res = d:Render(parentResult, options, results)
      results.Results[d] = res
    end
  end
end

---@param d Drawable
---@param options RenderOptions
function render:NewRenderChain(d, options)
  ---@type RenderResults
  local results = {
    Results = {}
  }

  self:execute(d, nil, options, results)
end