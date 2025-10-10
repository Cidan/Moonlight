local moonlight = GetMoonlight()
local grid = moonlight:GetGrid()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class section
---@field pool Pool
local section = moonlight:NewClass("section")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Section: Drawable
---@field grid Grid
---@field frame_Container Frame
---@field frame_Underline Frame
---@field frame_Header Frame
---@field text_Title SimpleFontString
---@field calculatedHeaderOffset number
---@field hidden boolean
---@field storedHeight number
---@field parent Drawable|Sectionset
---@field useFullWidth boolean
---@field placeholders table<PlaceholderButton, boolean>
local Section = {}

---@return Section
local sectionConstructor = function()
  local drawable = moonlight:GetDrawable()
  ---@type Section
  local instance = drawable:Create(Section)

  local g = grid:New()
  g:SetOptions({
    ItemHeight = 24,
    ItemWidth = 24,
    ItemGapX = 4,
    ItemGapY = 4,
    Inset = {
      Top = 0,
      Bottom = 0,
      Left = 4,
      Right = 0
    },
    Width = 240,
    SortFunction = function(a, b)
      return a:GetSortKey() > b:GetSortKey()
    end
  })
  local f = CreateFrame("Frame")
  local header = CreateFrame("Frame", nil, f)

  -- Create the title text
  local titleFont = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  titleFont:SetTextColor(1, 1, 1)
  titleFont:SetJustifyH("LEFT")
  titleFont:SetText("Untitled")

  ---@type Frame
  local frame_Underline = CreateFrame("Frame", nil, f)
  local white = CreateColor(1, 1, 1, 1)
  local faded = CreateColor(1, 1, 1, 0.2)

  local left = frame_Underline:CreateTexture(nil, "ARTWORK")
  left:SetColorTexture(1, 1, 1, 1)
  left:SetHeight(1)

  local right = frame_Underline:CreateTexture(nil, "ARTWORK")
  right:SetGradient("HORIZONTAL", white --[[@as colorRGBA]], faded --[[@as colorRGBA]])
  right:SetColorTexture(1, 1, 1, 1)
  right:SetHeight(1)
  right:SetWidth(100)

  left:SetPoint("LEFT", frame_Underline, "LEFT")
  right:SetPoint("LEFT", left, "RIGHT")
  right:SetPoint("RIGHT", frame_Underline, "RIGHT")

  frame_Underline:SetHeight(3)

  -- Assemble it all
  titleFont:SetPoint("TOPLEFT", header, "TOPLEFT")
  frame_Underline:SetPoint("TOPLEFT", titleFont, "BOTTOMLEFT", 0, -2)
  frame_Underline:SetPoint("RIGHT", header, "RIGHT", 0, -2)

  header:SetPoint("TOPLEFT", f, "TOPLEFT")
  header:SetPoint("RIGHT", f, "RIGHT")
  header:SetHeight(frame_Underline:GetHeight() + titleFont:GetHeight())
  header:EnableMouse(true)
  ---@type number
  local calculatedHeaderOffset = header:GetHeight() + 8

  g:SetParent(f)
  g:SetPoint({
    Point = "TOPLEFT",
    RelativeTo = f,
    RelativePoint = "TOPLEFT",
    XOffset = 0,
    YOffset = -calculatedHeaderOffset
  })

  header:SetScript("OnMouseDown", function()
    instance:ToggleVisibility()
  end)

  instance.grid = g
  instance.frame_Container = f
  instance.frame_Underline = frame_Underline
  instance.text_Title = titleFont
  instance.calculatedHeaderOffset = calculatedHeaderOffset
  instance.hidden = false
  instance.useFullWidth = false
  instance.placeholders = {}

  return instance
end

---@param w Section
local sectionDeconstructor = function(w)
  w.grid:DeleteEverything()
  w:ClearAllPoints()
  w:SetParent(nil)
  w.parent = nil
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Section
function section:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(sectionConstructor, sectionDeconstructor)
  end

  return self.pool:TakeOne("Section")
end

---@param b MoonlightItemButton
function Section:AddItem(b)
  self.grid:AddChild(b)
end

---@param b MoonlightItemButton
function Section:RemoveItem(b)
  self.grid:RemoveChildWithoutRedraw(b)
end

---@param b MoonlightItemButton
---@return boolean
function Section:HasItem(b)
  return self.grid:HasChild(b)
end

---@param b MoonlightItemButton
function Section:RemoveItemButKeepSpace(b)
  -- Remove the item from the grid
  self.grid:RemoveChildWithoutRedraw(b)

  -- Create a placeholder to occupy the same space
  local placeholderbutton = moonlight:GetPlaceholderbutton()
  local placeholder = placeholderbutton:New()

  -- Preserve the sort key from the removed item
  placeholder:SetSortKey(b:GetSortKey())

  -- Add placeholder to grid and track it
  self.grid:AddChild(placeholder)
  self.placeholders[placeholder] = true
end

---@param newButton MoonlightItemButton
---@return boolean
function Section:TryReplacePlaceholder(newButton)
  -- Find the first placeholder
  local placeholderToReplace = nil
  for placeholder in pairs(self.placeholders) do
    placeholderToReplace = placeholder
    break
  end

  if placeholderToReplace == nil then
    return false
  end

  -- Remove placeholder from grid and tracking
  self.grid:RemoveChildWithoutRedraw(placeholderToReplace)
  self.placeholders[placeholderToReplace] = nil
  placeholderToReplace:ReleaseBackToPool()

  -- Add new button with the placeholder's sort key
  newButton:SetSortKey(placeholderToReplace:GetSortKey())
  self.grid:AddChild(newButton)

  return true
end

function Section:ForceFullRedraw()
  -- Remove all placeholders from grid
  for placeholder in pairs(self.placeholders) do
    self.grid:RemoveChildWithoutRedraw(placeholder)
    placeholder:ReleaseBackToPool()
  end

  -- Clear the placeholders table
  self.placeholders = {}

  -- Trigger a render to update the layout
  local render = moonlight:GetRender()
  render:NewRenderChain(self, {OnlyRedraw = true})
end

---@param title string
function Section:SetTitle(title)
  self.text_Title:SetText(title)
end

---@return string
function Section:GetTitle()
  return self.text_Title:GetText()
end

function Section:Expand()
  local render = moonlight:GetRender()
  if self.hidden == false then
    return
  end
  self.grid:Show()
  self.frame_Container:SetHeight(self.storedHeight)
  self.hidden = false
  render:NewRenderChain(self, {OnlyRedraw = true})
end

function Section:Shrink()
  if self.hidden == true then
    return
  end
  self.grid:Hide()
  self.hidden = true
  self.frame_Container:SetHeight(self.calculatedHeaderOffset)
  local render = moonlight:GetRender()
  render:NewRenderChain(self, {OnlyRedraw = true})
end

function Section:ToggleVisibility()
  if self.hidden then
    self:Expand()
  else
    self:Shrink()
  end
end

--- Drawable implementation
function Section:ClearAllPoints()
  self.frame_Container:ClearAllPoints()
end

function Section:SetParent(frame)
  self.frame_Container:SetParent(frame)
end

function Section:SetPoint(point)
  self.frame_Container:SetPoint(
    point.Point,
    point.RelativeTo,
    point.RelativePoint,
    point.XOffset,
    point.YOffset
  )
end

---@return number
function Section:GetNumberOfChildren()
  return self.grid:GetNumberOfChildren()
end

function Section:Release()
  section.pool:GiveBack("Section", self)
end

---@return MoonlightItemButton[]
function Section:GetChildren()
  ---@type MoonlightItemButton[]
  local allChildren = self.grid:GetChildren()

  -- Filter out placeholders - only return actual item buttons
  ---@type MoonlightItemButton[]
  local itemButtons = {}
  for _, child in ipairs(allChildren) do
    if self.placeholders[child] == nil then
      table.insert(itemButtons, child)
    end
  end

  return itemButtons
end

function Section:GetHeight()
  return self.frame_Container:GetHeight()
end

function Section:PreRender(parentResult, _options)
  -- Check if this section is a header or footer by checking the parent sectionset
  local isHeaderOrFooter = false
  if self.parent ~= nil and self.parent.headerSectionNames ~= nil and self.parent.footerSectionNames ~= nil then
    local myTitle = self:GetTitle()
    if self.parent.headerSectionNames[myTitle] ~= nil or self.parent.footerSectionNames[myTitle] ~= nil then
      isHeaderOrFooter = true
    end
  end

  -- If this section is a header/footer, use the full width from parent
  if isHeaderOrFooter and parentResult ~= nil and parentResult.FullWidth ~= nil then
    return {
      Width = parentResult.FullWidth,
      Height = parentResult.Height or 0
    }
  end

  -- Use the actual frame width if available and larger than parent result
  -- This ensures header/footer sections (which span full width) use their full width for layout
  local frameWidth = self.frame_Container:GetWidth()

  if parentResult ~= nil then
    -- If frame has been sized (via anchors) and is wider than parent result, use frame width
    if frameWidth > 0 and frameWidth > parentResult.Width then
      return {
        Width = frameWidth,
        Height = parentResult.Height or 0
      }
    end
    return parentResult
  end

  return {
    Width = frameWidth,
    Height = self.frame_Container:GetHeight()
  }
end

---@return RenderResult
function Section:Render(_parentResult, _options, results)
  local gridResult = results.Results[self.grid]
  if gridResult == nil then
    error("grid did not set a result during it's render")
  end

  local h = gridResult.Height
  h = h + self.calculatedHeaderOffset
  self.storedHeight = h

  if self.hidden == false then
    self.frame_Container:SetHeight(h)
  end

  return {
    Height = h,
    Width = self.frame_Container:GetWidth()
  }
end

function Section:GetRenderPlan()
  ---@type RenderPlan
  local plan = {
    Plan = {
      [1] = {
        step = "RENDER_PRE"
      },
      [2] = {
        step = "RENDER_DEP",
        target = self.grid
      },
      [3] = {
        step = "RENDER_SELF"
      }
    }
  }
  return plan
end