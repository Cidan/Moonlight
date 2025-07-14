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
  self.children[f] = true
end

---@return number
function Grid:GetMaxItemsPerRow()
  assert(self.options ~= nil, "you must set options before you can render anything")
  local opts = self.options

  local maxItemsPerRow = 0
  ---@type uiUnit?
  local frameWidth = 0
  ---@type Frame?
  local parent = self.frame_Frame:GetParent()

  -- Figure out our base width.
  if opts.DynamicWidth == true and parent ~= nil then
    frameWidth = parent:GetWidth()
  elseif opts.Width ~= nil then
    frameWidth = opts.Width
  else
    error("frame width can not be calculated. is either Width or DynamicWidth with a parent set?")
  end

  -- Adjust for insets.
  frameWidth = frameWidth - opts.Inset.Left - opts.Inset.Right

  -- Adjust for item width and gaps.
  local oneItemWidth = opts.ItemWidth + opts.ItemGapX

  maxItemsPerRow = math.floor(frameWidth / oneItemWidth)
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

---@return Frame
function Grid:GetFrame()
  return self.frame_Frame
end