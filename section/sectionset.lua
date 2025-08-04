local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class sectionset
---@field pool Pool
local sectionset = moonlight:NewClass("sectionset")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Sectionset: Drawable
---@field frame_Container Frame
---@field sortFunction? fun(a: Section, b: Section): boolean
---@field sections table<Section, boolean>
---@field parent? Drawable
---@field config SectionsetConfig
local Sectionset = {}

---@return Sectionset
local sectionsetConstructor = function()
  local instance = {
    sections = {},
    frame_Container = CreateFrame("Frame"),
    -- Define your instance variables here
    config = {
      Columns = 2,
      SectionOffset = 4
    }
  }
  return setmetatable(instance, {
    __index = Sectionset
  })
end

---@param _w Sectionset
local sectionsetDeconstructor = function(_w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Sectionset
function sectionset:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(sectionsetConstructor, sectionsetDeconstructor)
  end

  return self.pool:TakeOne("Sectionset")
end

---@param s Section
function Sectionset:AddSection(s)
  if self.sections[s] == true then
    error("attempted to add a section to a section set when it's already in the set")
  end
  s:SetParent(self.frame_Container)
  s:SetMyParentDrawable(self)
  self.sections[s] = true
end

---@param s Section
function Sectionset:RemoveSection(s)
  if self.sections[s] ~= true then
    error("attempted to remove a section from a section set when it's not in the section")
  end
  s:ClearAllPoints()
  s:SetParent(nil)
  s:RemoveMyParentDrawable()
  self.sections[s] = nil
end

---@param width number
---@return number
function Sectionset:Render(width)
  if self.sortFunction == nil then
    error("attempted to render without a sort function on a sectionset -- did you call SetSortFunction?")
  end
  ---@type Section[]
  local sortedSections = {}
  for section in pairs(self.sections) do
    table.insert(sortedSections, section)
  end
  table.sort(sortedSections, self.sortFunction)

  local sectionOffset = self.config.SectionOffset
  local numColumns = self.config.Columns
  local columnWidth = (width - (sectionOffset * (numColumns - 1))) / numColumns

  ---@type number[]
  local potentialHeights = {}

  for i, section in ipairs(sortedSections) do
    potentialHeights[i] = section:Redraw(columnWidth)
    section:ClearAllPoints()

    local colIndex = (i - 1) % numColumns

    if i <= numColumns then
      -- First row
      local xOffsetLeft = colIndex * (columnWidth + sectionOffset)
      section:SetPoint({ Point = "TOPLEFT", RelativeTo = self.frame_Container, RelativePoint = "TOPLEFT", XOffset = xOffsetLeft, YOffset = -sectionOffset })
      section:SetPoint({ Point = "TOPRIGHT", RelativeTo = self.frame_Container, RelativePoint = "TOPLEFT", XOffset = xOffsetLeft + columnWidth, YOffset = -sectionOffset })
    else
      -- Subsequent rows
      local anchorSection = sortedSections[i - numColumns]
      if anchorSection then
        section:SetPoint({ Point = "TOPLEFT", RelativeTo = anchorSection.frame_Container, RelativePoint = "BOTTOMLEFT", XOffset = 0, YOffset = -sectionOffset })
        section:SetPoint({ Point = "TOPRIGHT", RelativeTo = anchorSection.frame_Container, RelativePoint = "BOTTOMRIGHT", XOffset = 0, YOffset = -sectionOffset })
      end
    end
  end

  ---@type number
  local totalHeight = 0
  if #sortedSections > 0 then
    ---@type table<number, number>
    local columnHeights = {}
    for i = 1, numColumns do
      columnHeights[i] = 0
    end

    for i, _ in ipairs(sortedSections) do
      local colIndex = ((i - 1) % numColumns) + 1
      columnHeights[colIndex] = (columnHeights[colIndex] or 0) + (potentialHeights[i] or 0) + sectionOffset
    end

    for i = 1, numColumns do
      local colHeight = columnHeights[i] or 0
      if colHeight > totalHeight then
        totalHeight = colHeight
      end
    end
  end

  self.frame_Container:SetHeight(totalHeight)
  return totalHeight
end

function Sectionset:ClearAllPoints()
  self.frame_Container:ClearAllPoints()
end

function Sectionset:SetParent(parent)
  self.frame_Container:SetParent(parent)
end

function Sectionset:SetPoint(point)
  self.frame_Container:SetPoint(
    point.Point,
    point.RelativeTo,
    point.RelativePoint,
    point.XOffset,
    point.YOffset
  )
end

function Sectionset:Redraw(width)
  if self.sortFunction == nil then
    error("attempted to redraw without a sort function on a sectionset -- did you call SetSortFunction?")
  end
  return self:Render(width)
end

---@param f fun(a: Section, b: Section): boolean
function Sectionset:SetSortFunction(f)
  self.sortFunction = f
end

---@param c SectionsetConfig
function Sectionset:SetConfig(c)
  self.config = c
end

function Sectionset:SetMyParentDrawable(d)
  self.parent = d
end

function Sectionset:RemoveMyParentDrawable()
  self.parent = nil
end

function Sectionset:RecalculateHeightWithoutDrawing()
  local sectionOffset = self.config.SectionOffset
  local numColumns = self.config.Columns

  ---@type Section[]
  local sortedSections = {}
  for section in pairs(self.sections) do
    table.insert(sortedSections, section)
  end
  -- We need a consistent order to calculate height correctly
  if self.sortFunction then
    table.sort(sortedSections, self.sortFunction)
  else
    table.sort(sortedSections, function(a, b) return a:GetTitle() < b:GetTitle() end)
  end

  ---@type number
  local totalHeight = 0
  if #sortedSections > 0 then
    ---@type table<number, number>
    local columnHeights = {}
    for i = 1, numColumns do
      columnHeights[i] = 0
    end

    for i, section in ipairs(sortedSections) do
      local colIndex = ((i - 1) % numColumns) + 1
      columnHeights[colIndex] = (columnHeights[colIndex] or 0) + section:GetHeight() + sectionOffset
    end

    for i = 1, numColumns do
      local colHeight = columnHeights[i] or 0
      if colHeight > totalHeight then
        totalHeight = colHeight
      end
    end
  end

  self.frame_Container:SetHeight(totalHeight)
  if self.parent and self.parent.RecalculateHeightWithoutDrawing then
    self.parent:RecalculateHeightWithoutDrawing()
  end
end

function Sectionset:GetHeight()
  return self.frame_Container:GetHeight()
end

function Sectionset:Hide()
  self.frame_Container:Hide()
end

function Sectionset:Show()
  self.frame_Container:Show()
end

---@return Section[]
function Sectionset:GetAllSections()
  ---@type Section[]
  local sections = {}
  for section in pairs(self.sections) do
    table.insert(sections, section)
  end
  return sections
end