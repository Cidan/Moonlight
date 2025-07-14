local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class grid
---@field pool Pool
local grid = moonlight:NewClass("grid")

--- Grid is a container for equal sized items, organized in a grid fashion. Grid's always organized
--- from left to right, top to bottom, and can be configured with various options.
---@class Grid
---@field options GridOptions
---@field frame_Frame Frame
---@field children table<Frame, boolean>
local Grid = {}

---@return Grid
local gridConstructor = function()
  local instance = {
    frame_Frame = CreateFrame("Frame"),
    children = {}
    -- Define your instance variables here
  }
  instance.frame_Frame:SetSize(1, 1)
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
  if opts.Width == nil then
    if opts.DynamicWidth == false then
      error("you must either set a width, or dynamic width for a grid")
    end
  else
    if opts.DynamicWidth == true then
      error("you can not set both dynamic width and static width for a grid")
    end
    self.frame_Frame:SetWidth(opts.Width)
  end
  self.options = opts
end

---@param f Frame
function Grid:AddChild(f)
  assert(self.options ~= nil, "you must set options before you can render anything")
  f:SetSize(self.options.ItemWidth, self.options.ItemHeight)
  f:SetParent(self.frame_Frame)
  self.children[f] = true
end

---@return number
function Grid:GetMaxItemsPerRow()
  assert(self.options ~= nil, "you must set options before you can render anything")
  local opts = self.options

  -- Step 1: Determine the total width available for the grid from the parent or a fixed width option.
  ---@type uiUnit
  local totalWidth = 0
  local parent = self.frame_Frame:GetParent()
  if opts.DynamicWidth == true and parent ~= nil then
    totalWidth = parent:GetWidth()
  elseif opts.Width ~= nil then
    totalWidth = opts.Width
  else
    error("frame width can not be calculated. Is either Width or DynamicWidth with a parent set?")
  end

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

function Grid:Render()
  assert(self.options ~= nil, "you must set options before you can render anything")
  local opts = self.options
  if opts.DynamicWidth == true and self.frame_Frame:GetParent() == nil then
    error("attempted to render a dynamic grid width without a parent")
  end
  if opts.DynamicWidth == true and opts.Width ~= nil then
    error("attempted to render a grid with both dynamic width and static width")
  end

  local maxItemsPerRow = self:GetMaxItemsPerRow()

  local sortedChildren = {}
  for child in pairs(self.children) do
    table.insert(sortedChildren, child)
  end
  table.sort(sortedChildren, self.options.SortFunction)

  -- We need to place each cell within a point in self.frame_Frame.
  -- Each cell should be ordered from left to right, with a new row
  -- when we've hit the maxItemsPerRow.
  --
  -- We can set the child's position via child:SetPoint("TOPLEFT", self.frame_Frame, "TOPLEFT", xoffset, yoffset).
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
      child:SetPoint("TOPLEFT", self.frame_Frame, "TOPLEFT", xoffset, yoffset)
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
  self.frame_Frame:SetHeight(newHeight)
end

---@return Frame
function Grid:GetFrame()
  return self.frame_Frame
end

---@param f Frame
function Grid:RemoveChildWithoutRedraw(f)
  if self.children[f] == nil then
    error("attempted to remove child that does not exist on this grid")
  end
  f:SetParent(nil)
  f:ClearAllPoints()
  f:Hide()
  self.children[f] = nil
end