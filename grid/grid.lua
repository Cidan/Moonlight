local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class grid
---@field pool Pool
local grid = moonlight:NewClass("grid")

--- Grid is a container for equal sized items, organized in a grid fashion. Grid's always organized
--- from left to right, top to bottom, and can be configured with various options.
---@class Grid: Drawable
---@field options GridOptions
---@field frame_Container Frame
---@field children table<Drawable, boolean>
local Grid = {}

---@return Grid
local gridConstructor = function()
  local instance = {
    frame_Container = CreateFrame("Frame"),
    children = {}
    -- Define your instance variables here
  }
  instance.frame_Container:SetSize(1, 1)
  return setmetatable(instance, {
    __index = Grid
  })
end

---@param w Grid
local gridDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Grid
function grid:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(gridConstructor, gridDeconstructor)
  end

  return self.pool:TakeOne("Grid")
end

---@param opts GridOptions
function Grid:SetOptions(opts)
  self.options = opts
end

---@param f Drawable
function Grid:AddChild(f)
  if self.options == nil then
    error("attempted to add a child to an unconfigured grid -- did you SetOptions?")
  end
  if self.children[f] == true then
    error("attempted to add a child to the grid that was already there")
  end
  f:SetSize(self.options.ItemWidth, self.options.ItemHeight)
  f:SetParent(self.frame_Container)
  f:Show()
  self.children[f] = true
end

---@param f Drawable
---@return boolean
function Grid:HasChild(f)
  return self.children[f] or false
end

---@return number
function Grid:GetMaxItemsPerRow()
  if self.options == nil then
    error("you must set options before you can render anything")
  end
  local opts = self.options

  -- Step 1: Determine the total width available for the grid from the parent or a fixed width option.
  ---@type uiUnit
  local totalWidth = opts.Width

  -- Step 2: Calculate the usable width by subtracting the left and right insets.
  -- This is the total space available for items and the gaps between them.
  local usableWidth = totalWidth - opts.Inset.Left - opts.Inset.Right
  if usableWidth <= 0 then
    return 0
  end

  -- Step 3: Define the space required for a single item and a single gap.
  local itemWidth = opts.ItemWidth
  local itemGapX = opts.ItemGapX
  if itemWidth <= 0 then
    return 0 -- Cannot have items with no width.
  end

  -- Step 4: Calculate the maximum number of items (n) that can fit.
  -- The total width consumed by 'n' items is: n * itemWidth
  -- The total width consumed by the gaps between 'n' items is: (n - 1) * itemGapX
  -- The total consumed width must be less than or equal to the usable width:
  -- n * itemWidth + (n - 1) * itemGapX <= usableWidth
  --
  -- To solve for n, we rearrange the inequality:
  -- n * itemWidth + n * itemGapX - itemGapX <= usableWidth
  -- n * (itemWidth + itemGapX) <= usableWidth + itemGapX
  -- n <= (usableWidth + itemGapX) / (itemWidth + itemGapX)
  --
  -- We use math.floor to get the largest integer n that satisfies the condition.
  local spacePerItemBlock = itemWidth + itemGapX
  if spacePerItemBlock <= 0 then
    -- Avoid division by zero or negative numbers if item width/gap are unusual.
    return 0
  end

  local maxItemsPerRow = math.floor((usableWidth + itemGapX) / spacePerItemBlock)

  return maxItemsPerRow
end

---@param width uiUnit
function Grid:SetWidth(width)
  if self.options == nil then
    error("you must set options before you can set a width")
  end
  self.options.Width = width
end

function Grid:Render()
  if self.options == nil then
    error("you must set options before you can render anything")
  end
  local opts = self.options

  local maxItemsPerRow = self:GetMaxItemsPerRow()

  ---@type Drawable[]
  local sortedChildren = {}
  for child in pairs(self.children) do
    table.insert(sortedChildren, child)
  end
  table.sort(sortedChildren, self.options.SortFunction)

  -- We need to place each cell within a point in self.frame_Container.
  -- Each cell should be ordered from left to right, with a new row
  -- when we've hit the maxItemsPerRow.
  --
  -- We can set the child's position via child:SetPoint("TOPLEFT", self.frame_Container, "TOPLEFT", xoffset, yoffset).
  -- We need to calculate these offsets correctly, taking into account the spacing in the opts variable for
  -- X and Y.
  if maxItemsPerRow > 0 then
    for i, child in ipairs(sortedChildren) do
      local col = (i - 1) % maxItemsPerRow
      local row = math.floor((i - 1) / maxItemsPerRow)

      local xoffset = opts.Inset.Left + (col * (opts.ItemWidth + opts.ItemGapX))
      -- yoffset is negative because we are offsetting from the top.
      local yoffset = -(opts.Inset.Top + (row * (opts.ItemHeight + opts.ItemGapY)))

      child:ClearAllPoints()
      child:SetPoint({
        Point = "TOPLEFT",
        RelativeTo = self.frame_Container,
        RelativePoint = "TOPLEFT",
        XOffset = xoffset,
        YOffset = yoffset
      })
      child:Show()
    end
  end

  local numChildren = #sortedChildren
  local numRows = 0
  if maxItemsPerRow > 0 then
    numRows = math.ceil(numChildren / maxItemsPerRow)
  end

  local newHeight = opts.Inset.Top + opts.Inset.Bottom
  if numRows > 0 then
    newHeight = newHeight + (numRows * opts.ItemHeight) + (math.max(0, numRows - 1) * opts.ItemGapY)
  end
  self.frame_Container:SetHeight(newHeight)
  self.frame_Container:SetWidth(self.options.Width)
end

---@return Frame
function Grid:GetFrame()
  return self.frame_Container
end

---@param f Drawable
function Grid:RemoveChildWithoutRedraw(f)
  if self.children[f] == nil then
    error("attempted to remove a child from grid that is not there")
  end
  self.children[f] = nil
  f:Hide()
end

---@param width number
---@return number
function Grid:Redraw(width)
  if self.options == nil then
    error("attempt to redraw a grid without options set -- did you call SetOptions?")
  end
  self.options.Width = width
  self:Render()
  return self.frame_Container:GetHeight()
end

function Grid:ClearAllPoints()
  self.frame_Container:ClearAllPoints()
end

---@param parent? SimpleFrame
function Grid:SetParent(parent)
  self.frame_Container:SetParent(parent)
end

---@param point Point
function Grid:SetPoint(point)
  self.frame_Container:SetPoint(
    point.Point,
    point.RelativeTo,
    point.RelativePoint,
    point.XOffset,
    point.YOffset
  )
end

function Grid:Hide()
  self.frame_Container:Hide()
end

function Grid:Show()
  self.frame_Container:Show()
end