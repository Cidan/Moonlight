# Moonlight Rendering System

## The Challenge: Non-Reactive UI in World of Warcraft

The World of Warcraft UI API does not provide true reactive display elements. When a UI element, such as a window, is resized, its child elements do not automatically adjust their positions or sizes. Developers must manually recalculate and redraw all affected elements down the display hierarchy. For example, to make a grid of icons shrink or grow, one must manually call down to the grid component, telling it how many items to render per row.

This manual process becomes increasingly complex with nested components. A parent element needs to know the dimensions of its children to correctly size itself (e.g., a scroll area), and children need to know the dimensions of their parent to correctly position themselves. This often leads to a messy and complicated system of passing object references up and down the hierarchy to communicate layout changes.

## The Solution: A Declarative, 3-Step Rendering Pipeline

To solve this, Moonlight implements a declarative, multi-phase rendering system that standardizes how drawable UI components handle layout and rendering. This system breaks the rendering process for each component into three distinct, ordered steps: `PRE`, `DEPS`, and `SELF`.

This approach eliminates the need to manually pass frame references between components. Instead, data flows cleanly down the hierarchy, and layout results flow cleanly back up, allowing each component to be self-contained and only worry about its own rendering logic.

### The Three Rendering Steps

1.  **`PRE` (Pre-Render):** In this initial step, a component calculates any layout information it needs to pass down to its children. For example, a container might calculate its available width, which its children will need to constrain their own rendering.

2.  **`DEPS` (Dependencies/Children):** The component then triggers the rendering process for its children (dependencies), passing down the data calculated in the `PRE` step. Each child, in turn, executes its own rendering pipeline and returns its final calculated dimensions (width and height).

3.  **`SELF` (Self-Render):** After all children have finished rendering, the component executes its own final render. In this step, it has access to the layout results from its children, allowing it to correctly size itself to fit its contents. For instance, a scroll container can now set its height based on the collective height of the child elements it contains.

This entire process chains infinitely down the UI component hierarchy, creating a predictable and maintainable rendering flow.

## Implementation

To be part of this rendering system, a UI component must be a "Drawable" unit. This means it must implement three key methods: `GetRenderPlan`, `PreRender` (if needed), and `Render`.

### 1. The Render Plan (`GetRenderPlan`)

Every drawable unit must define a `GetRenderPlan` method. This function returns a `RenderPlan` table that specifies the sequence of rendering operations for that component.

Here is an example of a `Container`'s render plan. It first runs its pre-render step, then renders its active child, and finally runs its own self-render step.

```lua
-- This is a Container's rendering plan. Every drawable unit must have a render plan.
-- Note "RENDER_DEP" has a child -- that child must implement its own render plan, and so on.
function Container:GetRenderPlan()
  ---@type RenderPlan
  local plan = {
    Plan = {
      [1] = {
        step = "RENDER_PRE"
      },
      [2] = {
        step = "RENDER_DEP",
        target = self:GetActiveChild().Drawable
      },
      [3] = {
        step = "RENDER_SELF"
      }
    }
  }
  return plan
end
```

### 2. The Pre-Render Function (`PreRender`)

If a component's render plan includes a `RENDER_PRE` step, it must define a `PreRender` function. This function calculates and returns a `RenderResult` table containing data to be passed down to its children.

In this example, the `Container` calculates the available width and height of its scrollable area.

```lua
-- This is the Container's pre-render function. If you have a pre render, you must define this function.
function Container:PreRender()
  local child = self:GetActiveChild()
  if child == nil then
    self.frame_ScrollArea:SetHeight(0)
    return
  end
  self.frame_ScrollBox:FullUpdate(true)

  ---@type RenderResult
  local result = {
    Width = self.frame_ScrollBox:GetWidth(),
    Height = self.frame_ScrollBox:GetHeight()
  }
  -- Note that I return a result here with height info. This will be passed down to children.
  return result
end
```

### 3. The Self-Render Function (`Render`)

Every drawable unit must define a `Render` function. This function is executed during the `RENDER_SELF` step. It receives two optional tables:
*   `parentResult`: The `RenderResult` from its parent's `PreRender` step.
*   `results`: A table containing the `RenderResult` from each of its children.

The component uses this data to perform its final layout adjustments. Here, the `Container` uses the height returned by its child to set the height of its scroll area.

```lua
-- This is the container's own render call. Note that if any parent passes down info, that's in parentResult
-- and there is also the results table which gives you the results of all your children.
function Container:Render(parentResult, options, results)
  if results == nil then
    error("child did not return any results, can't render this container")
  end

  local result = results.Results[self:GetActiveChild().Drawable]

  if result == nil then
    error("the current child did not have any results, did you set the results in the render function?")
  end

  self.frame_ScrollArea:SetHeight(result.Height)
  self.frame_ScrollBox:FullUpdate(true)
end
```

## Triggering a Render

With this system, triggering a full, top-down render of a component and its children is simple. You just need a reference to a drawable unit and the global render service.

```lua
  local render = moonlight:GetRender()
  render:NewRenderChain(self, {OnlyRedraw = false})
```

In this call, `self` is any drawable unit (i.e., an object that implements `GetRenderPlan`, `PreRender`, and `Render`). The `NewRenderChain` function will automatically execute the entire rendering pipeline for that component and all of its descendants.