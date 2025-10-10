# Button Package

The button package provides reusable item button functionality for the Moonlight framework.

## Modules

### itembutton

The `itembutton` module creates and manages item buttons based on Blizzard's `ContainerFrameItemButtonTemplate`. It provides pooled item buttons that can be efficiently reused throughout the UI.

**Key Features:**

- **Object Pooling**: Uses Moonlight's pool system to efficiently reuse button instances, seeding 700 buttons on initialization
- **Masque Integration**: Optional support for the Masque addon for custom button skinning
- **Template-Based**: Uses Blizzard's `ContainerFrameItemButtonTemplate` which includes:
  - Icon display and quality borders
  - Stack count display
  - Cooldown frame with swipe animation
  - Quest item overlay
  - New item glow effects
  - Upgrade indicators
  - Extended slot support

**Core Methods:**

- `itembutton:New()` - Creates or retrieves a pooled button instance
- `MoonlightItemButton:SetItem(mitem)` - Sets the item data (immutable, can only be set once)
- `MoonlightItemButton:Update()` - Updates button display based on current item data
- `MoonlightItemButton:SetSize(width, height)` - Resizes the button and all child elements including:
  - IconBorder
  - NewItemTexture
  - IconQuestTexture
  - IconOverlay
  - **Cooldown frame** - Critical for proper cooldown text scaling
- `MoonlightItemButton:ReleaseBackToPool()` - Returns button to pool for reuse

**Important Implementation Details:**

**Cooldown Text Sizing:**
When buttons are created, the constructor sets a smaller font for cooldown countdown text:
```lua
b.Cooldown:SetCountdownFont("SystemFont_Shadow_Med1")
```

This is critical because:
- The default `ContainerFrameItemButtonTemplate` is designed for 37x37 buttons
- Moonlight uses 24x24 buttons (configured in section.lua)
- While the Cooldown frame automatically resizes with `setAllPoints="true"`, **the cooldown text font does not scale automatically**
- Without setting a smaller font, cooldown text appears too large and spills outside the 24x24 button boundaries
- `SystemFont_Shadow_Med1` provides appropriately sized text for small buttons

**Usage Example:**

```lua
local itembutton = moonlight:GetItembutton()
local button = itembutton:New()
button:SetItem(moonlightItem)
button:SetSize(32, 32)
button:SetParent(parentFrame)
button:SetPoint(point)
button:Show()

-- When done with button
button:ReleaseBackToPool()
```

**Pooling Behavior:**

When released back to the pool, buttons are cleaned up via the deconstructor which:
- Resets bag and slot IDs to 0
- Clears item data and textures
- Resets stack count to 1
- Clears cooldown display
- Updates quest item and new item states
- Clears button overlays and normal texture
- Hides the button

### placeholderbutton

The `placeholderbutton` module creates invisible placeholder frames that occupy space in grids without rendering any visible content. These are used to preserve empty item slots when items are removed during gameplay.

**Key Features:**

- **Invisible**: Frame alpha set to 0, completely transparent
- **Non-interactive**: Mouse and keyboard events disabled
- **Object Pooling**: Uses Moonlight's pool system for efficient reuse
- **Drawable Interface**: Implements the full Drawable interface for seamless grid integration
- **Space Preservation**: Maintains grid layout by occupying space without visual presence

**Core Methods:**

- `placeholderbutton:New()` - Creates or retrieves a pooled placeholder instance
- `PlaceholderButton:ReleaseBackToPool()` - Returns placeholder to pool for reuse

**Usage:**

Placeholders are managed automatically by the Section module. When items are removed from sections during redraw cycles, they are replaced with placeholders to maintain grid spacing. Placeholders are removed when:
1. A new item needs to fill that space (placeholder is replaced)
2. The bag window closes (all placeholders cleared via `Section:ForceFullRedraw()`)

**Implementation:**

```lua
local placeholderbutton = moonlight:GetPlaceholderbutton()
local placeholder = placeholderbutton:New()
placeholder:SetSortKey(sortKey) -- Preserve position
placeholder:SetSize(24, 24)
placeholder:SetParent(gridFrame)
placeholder:SetPoint(point)
-- Placeholder is invisible and non-interactive

-- When done
placeholder:ReleaseBackToPool()
```

**Integration with Sections:**

Sections use placeholders via three methods:
- `Section:RemoveItemButKeepSpace(button)` - Replaces removed item with placeholder
- `Section:TryReplacePlaceholder(newButton)` - Replaces placeholder with new item if available
- `Section:ForceFullRedraw()` - Removes all placeholders and triggers layout update
