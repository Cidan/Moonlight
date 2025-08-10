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
  local drawable = moonlight:GetDrawable()
  
  ---@type Sectionset
  local instance = drawable:Create(Sectionset)


  instance.sections = {}
  instance.frame_Container = CreateFrame("Frame")
  instance.config = {
    Columns = 2,
    SectionOffset = 4
  }

  return instance
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
  self.sections[s] = true
end

---@param s Section
function Sectionset:RemoveSection(s)
  if self.sections[s] ~= true then
    error("attempted to remove a section from a section set when it's not in the section")
  end
  s:ClearAllPoints()
  s:SetParent(nil)
  self.sections[s] = nil
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

---@param f fun(a: Section, b: Section): boolean
function Sectionset:SetSortFunction(f)
  self.sortFunction = f
end

---@param c SectionsetConfig
function Sectionset:SetConfig(c)
  self.config = c
end

--function Sectionset:RecalculateHeightWithoutDrawing()
--  local sectionOffset = self.config.SectionOffset
--  local numColumns = self.config.Columns
--
--  ---@type Section[]
--  local sortedSections = {}
--  for section in pairs(self.sections) do
--    table.insert(sortedSections, section)
--  end
--  -- We need a consistent order to calculate height correctly
--  if self.sortFunction then
--    table.sort(sortedSections, self.sortFunction)
--  else
--    table.sort(sortedSections, function(a, b) return a:GetTitle() < b:GetTitle() end)
--  end
--
--  ---@type number
--  local totalHeight = 0
--  if #sortedSections > 0 then
--    ---@type table<number, number>
--    local columnHeights = {}
--    for i = 1, numColumns do
--      columnHeights[i] = 0
--    end
--
--    for i, section in ipairs(sortedSections) do
--      local colIndex = ((i - 1) % numColumns) + 1
--      columnHeights[colIndex] = (columnHeights[colIndex] or 0) + section:GetHeight() + sectionOffset
--    end
--
--    for i = 1, numColumns do
--      local colHeight = columnHeights[i] or 0
--      if colHeight > totalHeight then
--        totalHeight = colHeight
--      end
--    end
--  end
--
--  self.frame_Container:SetHeight(totalHeight)
--  if self.parent and self.parent.RecalculateHeightWithoutDrawing then
--    self.parent:RecalculateHeightWithoutDrawing()
--  end
--end

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

function Sectionset:PreRender(parentResults, options)
  if parentResults == nil then 
    error("no parent results on prerender")
  end
  local sectionOffset = self.config.SectionOffset
  local numColumns = self.config.Columns
  local columnWidth = (parentResults.Width - (sectionOffset * (numColumns - 1))) / numColumns
  return {
    Width = columnWidth,
    Height = 0
  }
end

function Sectionset:Render(parentResults, options, results)
  if self.sortFunction == nil then
    error("attempted to render without a sort function on a sectionset -- did you call SetSortFunction?")
  end

  if parentResults == nil then
    error("rendering for the section set did not include parent results")
  end

  ---@type Section[]
  local sortedSections = {}
  for section in pairs(self.sections) do
    table.insert(sortedSections, section)
  end
  table.sort(sortedSections, self.sortFunction)

  local sectionOffset = self.config.SectionOffset
  local numColumns = self.config.Columns
  local columnWidth = (parentResults.Width - (sectionOffset * (numColumns - 1))) / numColumns

  ---@type number[]
  local potentialHeights = {}
  for i, section in ipairs(sortedSections) do
    local result = results.Results[section]
    potentialHeights[i] = result.Height
    section:ClearAllPoints()
  end

  if numColumns == 2 and #sortedSections > 1 then
    -- New logic for 2 columns, top-to-bottom
    ---@type number
    local totalContentHeight = 0
    for _, height in ipairs(potentialHeights) do
      totalContentHeight = totalContentHeight + (height or 0) + sectionOffset
    end

    local midPoint = totalContentHeight / 2
    local splitIndex = 1
    ---@type number
    local currentHeight = 0
    for i, height in ipairs(potentialHeights) do
      local nextHeight = currentHeight + (height or 0) + sectionOffset
      if nextHeight > midPoint and i > 1 then
        if (nextHeight - midPoint) > (midPoint - currentHeight) then
          break
        end
      end
      currentHeight = nextHeight
      splitIndex = i
      if currentHeight >= midPoint then
        break
      end
    end

    -- Position first column
    ---@type number
    local col1Height = 0
    for i = 1, splitIndex do
      local section = sortedSections[i]
      if section ~= nil then
        if i == 1 then
          section:SetPoint({ Point = "TOPLEFT", RelativeTo = self.frame_Container, RelativePoint = "TOPLEFT", XOffset = 0, YOffset = -sectionOffset })
          section:SetPoint({ Point = "TOPRIGHT", RelativeTo = self.frame_Container, RelativePoint = "TOPLEFT", XOffset = columnWidth, YOffset = -sectionOffset })
        else
          local anchorSection = sortedSections[i - 1]
          if anchorSection ~= nil then
            section:SetPoint({ Point = "TOPLEFT", RelativeTo = anchorSection.frame_Container, RelativePoint = "BOTTOMLEFT", XOffset = 0, YOffset = -sectionOffset })
            section:SetPoint({ Point = "TOPRIGHT", RelativeTo = anchorSection.frame_Container, RelativePoint = "BOTTOMRIGHT", XOffset = 0, YOffset = -sectionOffset })
          end
        end
        col1Height = col1Height + (potentialHeights[i] or 0) + sectionOffset
      end
    end

    -- Position second column
    ---@type number
    local col2Height = 0
    local xOffsetLeft = columnWidth + sectionOffset
    for i = splitIndex + 1, #sortedSections do
      local section = sortedSections[i]
      if section ~= nil then
        if i == splitIndex + 1 then
          section:SetPoint({ Point = "TOPLEFT", RelativeTo = self.frame_Container, RelativePoint = "TOPLEFT", XOffset = xOffsetLeft, YOffset = -sectionOffset })
          section:SetPoint({ Point = "TOPRIGHT", RelativeTo = self.frame_Container, RelativePoint = "TOPLEFT", XOffset = xOffsetLeft + columnWidth, YOffset = -sectionOffset })
        else
          local anchorSection = sortedSections[i - 1]
          if anchorSection ~= nil then
            section:SetPoint({ Point = "TOPLEFT", RelativeTo = anchorSection.frame_Container, RelativePoint = "BOTTOMLEFT", XOffset = 0, YOffset = -sectionOffset })
            section:SetPoint({ Point = "TOPRIGHT", RelativeTo = anchorSection.frame_Container, RelativePoint = "BOTTOMRIGHT", XOffset = 0, YOffset = -sectionOffset })
          end
        end
        col2Height = col2Height + (potentialHeights[i] or 0) + sectionOffset
      end
    end

    local totalHeight = math.max(col1Height, col2Height)
    self.frame_Container:SetHeight(totalHeight)
    return {
      Width = self.frame_Container:GetWidth(),
      Height = totalHeight
    }
  else
    -- Original logic for 1 or 3+ columns
    for i, section in ipairs(sortedSections) do
      local colIndex = (i - 1) % numColumns
      if i <= numColumns then
        -- First row
        local xOffsetLeft = colIndex * (columnWidth + sectionOffset)
        section:SetPoint({ Point = "TOPLEFT", RelativeTo = self.frame_Container, RelativePoint = "TOPLEFT", XOffset = xOffsetLeft, YOffset = -sectionOffset })
        section:SetPoint({ Point = "TOPRIGHT", RelativeTo = self.frame_Container, RelativePoint = "TOPLEFT", XOffset = xOffsetLeft + columnWidth, YOffset = -sectionOffset })
      else
        -- Subsequent rows
        local anchorSection = sortedSections[i - numColumns]
        if anchorSection ~= nil then
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
    return {
      Width = self.frame_Container:GetWidth(),
      Height = totalHeight
    }
  end
end

function Sectionset:GetRenderPlan()
  ---@type RenderPlan
  local plan = {
    Plan = {
      [1] = {
        step = "RENDER_PRE"
      },
    }
  }

  -- Insert all sections for rendering.

  for section in pairs(self.sections) do
    ---@type RenderStep
    local step = {
      step = "RENDER_DEP",
      target = section
    }
    table.insert(plan.Plan, step)
  end

  table.insert(plan.Plan, {
    step = "RENDER_SELF"
  })
  return plan
end