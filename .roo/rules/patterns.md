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
