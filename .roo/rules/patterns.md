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
