# Section Package

The section package provides organizational containers that group items into titled sections with grids. Sections are the building blocks for organizing items visually within bags.

## Modules

### section

The `section` module creates titled sections that contain grids of items. Each section has a header with title text and underline, plus a grid container for item buttons.

**Key Features:**

- **Grid-based Layout**: Uses the Grid module for automatic item positioning
- **Collapsible**: Sections can be expanded/shrunk by clicking the header
- **Placeholder System**: Preserves empty item slots when items are removed during gameplay
- **Flexible Width**: Sections can span full width (for headers/footers) or column width (for regular sections)
- **Title Customization**: Each section displays a customizable title

**Core Methods:**

- `section:New()` - Creates a new section instance from the pool
- `Section:SetTitle(title)` - Sets the section's title text
- `Section:AddItem(button)` - Adds an item button to the section's grid
- `Section:RemoveItem(button)` - Removes an item button from the grid
- `Section:HasItem(button)` - Checks if a button exists in the section
- `Section:ToggleVisibility()` - Expands or shrinks the section
- `Section:GetChildren()` - Returns array of all item buttons in the section

**Placeholder Management:**

Sections maintain grid spacing when items are removed during redraw cycles by replacing removed items with invisible placeholders.

- `Section:RemoveItemButKeepSpace(button)` - Removes item from grid and creates placeholder with same sort key
- `Section:TryReplacePlaceholder(newButton)` - Finds and replaces a placeholder if available, returns true if replaced
- `Section:ForceFullRedraw()` - Removes all placeholders and triggers render (called when bag closes)

**Placeholder Lifecycle:**

1. **Item Removed**: When an item becomes empty during redraw, `RemoveItemButKeepSpace` is called
2. **Placeholder Created**: An invisible PlaceholderButton is created with the same sort key as the removed item
3. **Space Preserved**: The grid maintains the same size and layout across multiple redraws
4. **New Item Added**: When a new item is added, `TryReplacePlaceholder` is called first to fill empty spaces
5. **Bag Closed**: When the bag window closes, `ForceFullRedraw` removes all placeholders to start fresh on next open

**Usage Example:**

```lua
local section = moonlight:GetSection()
local sec = section:New()
sec:SetTitle("Consumables")
sec:SetParent(parentFrame)
sec:SetPoint(point)

-- Add items
local itemButton = moonlight:GetItembutton()
local button = itemButton:New()
button:SetItem(moonlightItem)
sec:AddItem(button)

-- Remove item but preserve space
sec:RemoveItemButKeepSpace(button)

-- Add new item, filling placeholder if available
if not sec:TryReplacePlaceholder(newButton) then
  sec:AddItem(newButton)
end

-- Clean up all placeholders when bag closes
sec:ForceFullRedraw()
```

**Layout Details:**

- Header height: Calculated from title font height + underline (3px) + spacing (8px)
- Grid positioned below header with offset
- Section height auto-calculated based on grid content
- Hidden sections only show header (grid hidden)

### sectionset

The `sectionset` module manages collections of sections and arranges them into multi-column layouts with optional header and footer sections.

**Key Features:**

- **Multi-column Layout**: Automatically distributes sections across configurable number of columns
- **Height Balancing**: Distributes sections to balance column heights
- **Header/Footer Sections**: Supports full-width sections at top and bottom
- **Dynamic Sorting**: Sections can be sorted with custom sort functions
- **Flexible Configuration**: Column count, spacing, and special section placement configurable

**Core Methods:**

- `sectionset:New()` - Creates a new sectionset instance from the pool
- `Sectionset:AddSection(section)` - Adds a section to the set
- `Sectionset:RemoveSection(section)` - Removes a section from the set
- `Sectionset:SetSortFunction(func)` - Sets custom sort function for regular sections
- `Sectionset:SetConfig(config)` - Configures columns, spacing, and special sections
- `Sectionset:GetAllSections()` - Returns array of all sections in the set

**Configuration:**

```lua
{
  Columns = 2,                    -- Number of columns for regular sections
  SectionOffset = 4,              -- Spacing between sections (pixels)
  HeaderSections = {"New Items"}, -- Section titles to show as full-width headers
  FooterSections = {}             -- Section titles to show as full-width footers
}
```

**Layout Algorithm:**

1. Sections separated into headers, footers, and regular sections
2. Headers positioned at top (full-width, stacked vertically)
3. Regular sections distributed across columns with height balancing
4. Footers positioned at bottom (full-width, below tallest column)
5. Column count adjusted to number of sections (never more columns than sections)

**Usage Example:**

```lua
local sectionset = moonlight:GetSectionset()
local set = sectionset:New()

set:SetConfig({
  Columns = 2,
  SectionOffset = 4,
  HeaderSections = {"New Items"},
  FooterSections = {}
})

set:SetSortFunction(function(a, b)
  return a:GetTitle() < b:GetTitle()
end)

local section1 = moonlight:GetSection():New()
section1:SetTitle("Consumables")
set:AddSection(section1)

local section2 = moonlight:GetSection():New()
section2:SetTitle("Equipment")
set:AddSection(section2)

-- Trigger render to position sections
local render = moonlight:GetRender()
render:NewRenderChain(set)
```

**Render Integration:**

Sectionsets participate in Moonlight's render system:
- `PreRender`: Calculates column width and passes to child sections
- `Render`: Positions all sections and calculates total height
- `GetRenderPlan`: Specifies render dependencies (all sections must render first)

## Integration with BetterBags

The Section and Sectionset modules are core to BetterBags' organization system:

1. **Bagdata**: Creates sections for each category and manages item placement
2. **Item Removal**: Calls `RemoveItemButKeepSpace` to maintain grid layout during gameplay
3. **Item Addition**: Calls `TryReplacePlaceholder` to fill empty spaces before expanding grid
4. **Bag Close**: Calls `ForceFullRedraw` on all sections to clean up placeholders

This creates a smooth user experience where:
- Empty item slots remain visible during gameplay (items removed → placeholders created)
- New items fill existing empty spaces first (placeholders replaced)
- Bags start fresh on each open (placeholders cleared on close)
