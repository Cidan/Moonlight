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
---@field headerSectionNames table<string, number>
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
  instance.headerSectionNames = {}

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
  -- Update header sections when config changes
  if c.HeaderSections ~= nil then
    self.headerSectionNames = {}
    for index, name in ipairs(c.HeaderSections) do
      self.headerSectionNames[name] = index
    end
  end
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
  local allSections = {}
  for section in pairs(self.sections) do
    table.insert(allSections, section)
  end

  -- Separate header sections from regular sections
  ---@type Section[]
  local headerSections = {}
  ---@type Section[]
  local regularSections = {}

  for _, section in ipairs(allSections) do
    local sectionTitle = section:GetTitle()
    if self.headerSectionNames[sectionTitle] ~= nil then
      table.insert(headerSections, section)
    else
      table.insert(regularSections, section)
    end
  end

  -- Sort header sections by their index in the config
  table.sort(headerSections, function(a, b)
    local indexA = self.headerSectionNames[a:GetTitle()] or 0
    local indexB = self.headerSectionNames[b:GetTitle()] or 0
    return indexA < indexB
  end)

  -- Sort regular sections normally
  table.sort(regularSections, self.sortFunction)

  if #allSections == 0 then
    self.frame_Container:SetHeight(0)
    return { Width = self.frame_Container:GetWidth(), Height = 0 }
  end

  local sectionOffset = self.config.SectionOffset
  local numColumns = self.config.Columns
  local columnWidth = (parentResults.Width - (sectionOffset * (numColumns - 1))) / numColumns

  -- Clear all points first
  for _, section in ipairs(allSections) do
    section:ClearAllPoints()
  end

  -- Render header sections first (full width, stacked vertically)
  ---@type number
  local totalHeaderHeight = 0
  for i, section in ipairs(headerSections) do
    local result = results.Results[section]
    if i == 1 then
      section:SetPoint({ Point = "TOPLEFT", RelativeTo = self.frame_Container, RelativePoint = "TOPLEFT", XOffset = 0, YOffset = -sectionOffset })
      section:SetPoint({ Point = "TOPRIGHT", RelativeTo = self.frame_Container, RelativePoint = "TOPRIGHT", XOffset = 0, YOffset = -sectionOffset })
    else
      local anchorSection = headerSections[i - 1]
      if anchorSection == nil then
        error("anchorSection is nil, but it shouldn't be -- please report this error!")
      end
      section:SetPoint({ Point = "TOPLEFT", RelativeTo = anchorSection.frame_Container, RelativePoint = "BOTTOMLEFT", XOffset = 0, YOffset = -sectionOffset })
      section:SetPoint({ Point = "TOPRIGHT", RelativeTo = anchorSection.frame_Container, RelativePoint = "BOTTOMRIGHT", XOffset = 0, YOffset = -sectionOffset })
    end
    totalHeaderHeight = totalHeaderHeight + result.Height + sectionOffset
  end

  -- If there are no regular sections, just return header height
  if #regularSections == 0 then
    self.frame_Container:SetHeight(totalHeaderHeight)
    return { Width = self.frame_Container:GetWidth(), Height = totalHeaderHeight }
  end

  -- Calculate heights for regular sections
  ---@type number[]
  local potentialHeights = {}
  for i, section in ipairs(regularSections) do
    local result = results.Results[section]
    potentialHeights[i] = result.Height
  end

  -- This logic now handles any number of columns with top-to-bottom, height-balanced layout for regular sections.
  ---@type number
  local totalContentHeight = 0.0
  for _, height in ipairs(potentialHeights) do
    totalContentHeight = totalContentHeight + (height or 0)
  end
  totalContentHeight = totalContentHeight + (#regularSections * sectionOffset)

  ---@type table<integer, Section[]>
  local columnsContent = {}
  if #regularSections > 0 then
    local _idealHeightPerColumn = totalContentHeight / numColumns
    local currentSectionIndex = 1
    ---@type number
    local accumulatedHeight = 0.0

    for col = 1, numColumns do
      columnsContent[col] = {}
      if currentSectionIndex > #regularSections then break end

      ---@type number
      local currentColumnHeight = 0.0
      local remainingColumns = numColumns - col + 1
      local remainingHeight = totalContentHeight - accumulatedHeight
      local targetHeight = remainingHeight / remainingColumns

      for i = currentSectionIndex, #regularSections do
        local section = regularSections[i]
        local sectionHeight = (potentialHeights[i] or 0) + sectionOffset
        local heightIfAdded = currentColumnHeight + sectionHeight

        if i > currentSectionIndex and col < numColumns then
          if math.abs(heightIfAdded - targetHeight) > math.abs(currentColumnHeight - targetHeight) then
            break -- Adding this section makes the column balance worse, so break to next column
          end
        end

        table.insert(columnsContent[col], section)
        currentColumnHeight = heightIfAdded
        currentSectionIndex = i + 1

        if currentColumnHeight >= targetHeight and col < numColumns then
          break
        end
      end
      accumulatedHeight = accumulatedHeight + currentColumnHeight
    end
  end

  -- Position all regular sections in columns below the header sections
  ---@type number
  local maxColumnHeight = 0
  for colIndex, sectionsInColumn in ipairs(columnsContent) do
    local xOffset = (colIndex - 1) * (columnWidth + sectionOffset)
    ---@type number
    local currentColumnHeight = 0
    for i, section in ipairs(sectionsInColumn) do
      if i == 1 then
        -- First section in column: position below headers
        if #headerSections > 0 then
          local lastHeaderSection = headerSections[#headerSections]
          if lastHeaderSection ~= nil then
            section:SetPoint({ Point = "TOPLEFT", RelativeTo = lastHeaderSection.frame_Container, RelativePoint = "BOTTOMLEFT", XOffset = xOffset, YOffset = -sectionOffset })
            section:SetPoint({ Point = "TOPRIGHT", RelativeTo = lastHeaderSection.frame_Container, RelativePoint = "BOTTOMLEFT", XOffset = xOffset + columnWidth, YOffset = -sectionOffset })
          end
        else
          section:SetPoint({ Point = "TOPLEFT", RelativeTo = self.frame_Container, RelativePoint = "TOPLEFT", XOffset = xOffset, YOffset = -sectionOffset })
          section:SetPoint({ Point = "TOPRIGHT", RelativeTo = self.frame_Container, RelativePoint = "TOPLEFT", XOffset = xOffset + columnWidth, YOffset = -sectionOffset })
        end
      else
        local anchorSection = sectionsInColumn[i - 1]
        if anchorSection ~= nil then
          section:SetPoint({ Point = "TOPLEFT", RelativeTo = anchorSection.frame_Container, RelativePoint = "BOTTOMLEFT", XOffset = 0, YOffset = -sectionOffset })
          section:SetPoint({ Point = "TOPRIGHT", RelativeTo = anchorSection.frame_Container, RelativePoint = "BOTTOMRIGHT", XOffset = 0, YOffset = -sectionOffset })
        end
      end
      local result = results.Results[section]
      currentColumnHeight = currentColumnHeight + (result.Height or 0) + sectionOffset
    end
    if currentColumnHeight > maxColumnHeight then
      maxColumnHeight = currentColumnHeight
    end
  end

  local totalHeight = totalHeaderHeight + maxColumnHeight
  self.frame_Container:SetHeight(totalHeight)
  return {
    Width = self.frame_Container:GetWidth(),
    Height = totalHeight
  }
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