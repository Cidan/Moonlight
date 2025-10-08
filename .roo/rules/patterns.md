# Patterns

This document captures implementation patterns discovered and refined through development feedback cycles.

## Meta Instructions

**IMPORTANT**: When the user provides feedback requiring modifications after initial edits (especially in back-and-forth refinement), document the final working pattern here. This helps capture lessons learned and avoid repeating mistakes.

---

## UI Patterns

### Auto-hiding Elements with Hover Detection

**Problem**: Need UI elements (like tabs) to hide when not in use but show on hover, with reliable click-through behavior.

**Solution**: Use a static invisible hover zone frame separate from the animated content.

**Implementation**:
1. **Create two frames**:
   - Content frame: Contains the actual UI elements (buttons, tabs, etc.)
   - Hover zone frame: Invisible frame for detecting mouse enter/leave

2. **Position hover zone at final visible position**:
   ```lua
   self.frame_HoverZone:SetParent(parent)
   self.frame_HoverZone:SetSize(width, height)
   self.frame_HoverZone:SetPoint(...) -- Where visible content will be
   ```

3. **Enable mouse detection but propagate clicks**:
   ```lua
   self.frame_HoverZone:EnableMouse(true)
   self.frame_HoverZone:SetPropagateMouseClicks(true) -- Critical!
   self.frame_HoverZone:SetFrameLevel(contentFrame:GetFrameLevel() + 10)
   ```

4. **Use alpha animations with final state locking**:
   ```lua
   local fadeInGroup = contentFrame:CreateAnimationGroup()
   local fadeIn = fadeInGroup:CreateAnimation("Alpha")
   fadeIn:SetFromAlpha(0)
   fadeIn:SetToAlpha(1)
   fadeIn:SetDuration(0.2)
   fadeIn:SetSmoothing("IN_OUT")
   fadeInGroup:SetScript("OnFinished", function()
     contentFrame:SetAlpha(1) -- Lock final state
   end)
   ```

5. **Attach hover scripts to static zone**:
   ```lua
   self.frame_HoverZone:SetScript("OnEnter", function()
     if self.isHidden and not self.fadeInAnimation:IsPlaying() then
       self.fadeOutAnimation:Stop()
       self.fadeInAnimation:Play()
       self.isHidden = false
     end
   end)
   ```

**Why this works**:
- Static hover zone remains interactable at all times (no missed hover events)
- `SetPropagateMouseClicks(true)` passes clicks through to buttons beneath
- Alpha animations make content truly disappear (not just offset)
- `OnFinished` scripts prevent animation reset issues
- Higher frame level ensures hover detection priority

**Example**: Sidebar tabs that fade out when not hovered (see `container/tab.lua`)

---

### Independent Button Animations in Lists

**Problem**: When animating individual buttons in a list (like tab buttons), naive anchoring causes cascading animation effects where animating one button drags all subsequent buttons with it.

**Why this happens**:
- Buttons anchored to each other (Button2 → Button1, Button3 → Button2) create a dependency chain
- When Button1 animates, its frame moves, causing Button2's anchor point to move
- This cascade effect propagates through all buttons
- Rapid hover events cause position drift when using `GetPoint()` math on animated frames

**Solution**: Use independent anchoring with stored original positions.

**Implementation**:

1. **Anchor all buttons independently to the container**:
   ```lua
   -- BAD: Chained anchoring causes cascade
   for i, button in ipairs(buttons) do
     if i == 1 then
       button:SetPoint("TOPLEFT", container)
     else
       button:SetPoint("TOPLEFT", buttons[i-1], "TOPRIGHT", spacing, 0)  -- Anchored to previous!
     end
   end

   -- GOOD: Independent anchoring with calculated offsets
   local cumulativeOffset = 0
   for i, button in ipairs(buttons) do
     button:SetPoint("TOPLEFT", container, "TOPLEFT", cumulativeOffset, 0)
     cumulativeOffset = cumulativeOffset + buttonSize + spacing
   end
   ```

2. **Store original anchor position on each button**:
   ```lua
   function Button:SetPoint(point)
     -- Store original position for animation reference
     self.originalPoint = {
       Point = point.Point,
       RelativeTo = point.RelativeTo,
       RelativePoint = point.RelativePoint,
       XOffset = point.XOffset,
       YOffset = point.YOffset
     }
     self.frame:SetPoint(point.Point, point.RelativeTo, point.RelativePoint,
                         point.XOffset, point.YOffset)
   end
   ```

3. **Use stored positions in animation callbacks**:
   ```lua
   -- BAD: Using GetPoint() causes drift on rapid animations
   animGroup:SetScript("OnFinished", function()
     local point, rel, relPoint, x, y = self.frame:GetPoint()
     self.frame:SetPoint(point, rel, relPoint, x, y - 3)  -- Compounds errors!
   end)

   -- GOOD: Use stored original position for exact placement
   animGroup:SetScript("OnFinished", function()
     if self.originalPoint ~= nil then
       self.frame:ClearAllPoints()
       self.frame:SetPoint(
         self.originalPoint.Point,
         self.originalPoint.RelativeTo,
         self.originalPoint.RelativePoint,
         self.originalPoint.XOffset or 0,
         (self.originalPoint.YOffset or 0) - 3  -- Exact offset from known position
       )
     end
   end)
   ```

4. **Snap to known position before reverse animations**:
   ```lua
   -- When interrupting an animation mid-flight, snap to target position first
   self.frame:SetScript("OnLeave", function()
     if self.slideDownGroup:IsPlaying() == true then
       self.slideDownGroup:Stop()
       -- Snap to "down" position before sliding back up
       self.frame:ClearAllPoints()
       self.frame:SetPoint(
         self.originalPoint.Point,
         self.originalPoint.RelativeTo,
         self.originalPoint.RelativePoint,
         self.originalPoint.XOffset or 0,
         (self.originalPoint.YOffset or 0) - self.distance
       )
     end
     self.slideUpGroup:Play()
   end)
   ```

5. **Make animation parameters configurable**:
   ```lua
   ---@class ButtonConfig
   ---@field AnimationDistance number | nil  -- Default: 3
   ---@field AnimationDuration number | nil  -- Default: 0.1

   function Button:SetAnimationConfig(distance, duration)
     self.animationDistance = distance
     self.animationDuration = duration
     self:setupAnimations()  -- Recreate animations with new values
   end
   ```

6. **Handle initial state for selection animations**:
   ```lua
   -- Use deferred timer to ensure active child is set before selecting tab
   C_Timer.After(0, function()
     local activeChildName = self.container:GetActiveChildName()
     if activeChildName ~= nil then
       local activeTab = self.tabs[activeChildName]
       if activeTab ~= nil then
         activeTab:Select()
         self.selectedTabName = activeChildName
       end
     end
   end)
   ```

**Critical Guidelines**:
1. **Independent positioning** - Every button anchors to container, not siblings
2. **Store original positions** - Never rely on `GetPoint()` during animations
3. **Snap before reverse** - Always set known position before playing reverse animation
4. **Clear then set points** - Use `ClearAllPoints()` before `SetPoint()` in callbacks
5. **Deferred initialization** - Use `C_Timer.After(0, ...)` for state-dependent setup

**When to Apply**:
- Tab systems with individual button hover animations
- List items that animate independently
- Any UI where multiple sibling elements have their own animations
- Situations requiring precise position control during rapid user interaction

**Example**: Tab hover and selection animations (see `container/tabbutton.lua`, `container/tab.lua`)

---

## Module Patterns

### Creating a New Module

**Problem**: Need a consistent pattern for adding new modules to the Moonlight addon that integrates properly with the boot sequence and can be accessed globally.

**Solution**: Follow the standardized module registration, initialization, and access pattern.

**Implementation**:

1. **Create module directory and files**:
   ```
   modulename/
   ├── modulename.lua    # Main module implementation
   └── types.lua         # Type annotations (optional but recommended)
   ```

2. **Module file structure** (`modulename/modulename.lua`):
   ```lua
   local moonlight = GetMoonlight()

   --- Brief description of what this module does.
   ---@class modulename
   ---@field property1 Type
   ---@field property2 Type
   local modulename = moonlight:NewClass("modulename")

   function modulename:Boot()
     -- Initialize the module
     -- This runs during addon startup, after SavedVariables are loaded
   end

   -- Additional module functions...
   ```

3. **Add to load order** (`Moonlight.toc`):
   - Add `modulename/modulename.lua` before `boot/init.lua`
   - Position based on dependencies (modules it depends on must load first)

4. **Register getter** in `boot/boot.lua`:
   ```lua
   ---@return modulename
   function Moonlight:GetModulename()
     return self.classes.modulename
   end
   ```

5. **Initialize in boot sequence** (`boot/boot.lua` `Start()` function):
   ```lua
   function Moonlight:Start()
     -- Get module reference
     local modulename = self:GetModulename()

     -- Boot in appropriate order
     modulename:Boot()
   end
   ```

**Boot Order Considerations**:
- `save` boots first (initializes SavedVariables)
- `event` boots early (provides event system to other modules)
- Themes boot before windows that use them
- Data loaders boot before UI that displays data
- Binds boot last (registers keybindings after everything is ready)

**Why this works**:
- `NewClass()` registers the module in the global class registry
- Getter functions provide type-safe access via LuaLS annotations
- `Boot()` centralizes initialization logic at the right time
- Separation of registration (module load) and initialization (Boot) allows proper dependency ordering
- All SavedVariables are guaranteed available in `Boot()` functions

**Example**: The `save` module (see `save/save.lua`, `boot/boot.lua:209`, `boot/boot.lua:48`)

## UI Widget Sizing

### Pattern: Set Cooldown Font When Using Non-Default Button Sizes
**Problem**: Cooldown timer text appears too large and spills outside item button boundaries when buttons are sized differently from the default 37x37.

**Why**: The `ContainerFrameItemButtonTemplate` includes a Cooldown frame with `setAllPoints="true"`, which means the frame itself resizes automatically with the button. However, **the cooldown countdown text font does not scale automatically** - it uses a fixed font size designed for 37x37 buttons. When using smaller buttons (e.g., 24x24), the default font is too large.

**Solution Pattern**: Call `Cooldown:SetCountdownFont(fontName)` after creating the button:

```lua
---@return MoonlightItemButton
local itembuttonConstructor = function()
  local b = CreateFrame("ItemButton", nil, nil, "ContainerFrameItemButtonTemplate")

  -- Set appropriate font for your button size
  -- SystemFont_Shadow_Med1 works well for 24x24 buttons
  b.Cooldown:SetCountdownFont("SystemFont_Shadow_Med1")

  -- Rest of initialization...
end
```

**Font recommendations by button size:**
- **37x37 (default)**: No change needed, uses default font
- **24-32px**: `SystemFont_Shadow_Med1` or `SystemFont_Shadow_Small`
- **16-23px**: `SystemFont_Shadow_Small` or `SystemFont_Tiny`
- **Custom sizes**: Test fonts to find the right balance

**When to Apply**:
- Any time you create item buttons from `ContainerFrameItemButtonTemplate` at non-default sizes
- When resizing action buttons or similar cooldown-enabled widgets
- When debugging cooldown text sizing issues on custom buttons
- In the button constructor/creation function, not in SetSize() (font doesn't need to change when resizing)
