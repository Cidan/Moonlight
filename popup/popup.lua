local moonlight = GetMoonlight()

--- Popup module provides context menu functionality that appears at the mouse cursor position.
---@class popup: Drawable
---@field window Window
---@field container Container
---@field list List
---@field itemPool Pool
---@field labelPool Pool
---@field dividerPool Pool
---@field activeElements (PopupItem|PopupLabel|PopupDivider)[]
---@field currentConfig PopupConfig | nil
local popup = moonlight:NewClass("popup")

---@class PopupItem
---@field Type "item"
---@field button Button
---@field text FontString
---@field highlight Texture
---@field checkbox Texture
---@field arrow Texture

---@class PopupLabel
---@field Type "label"
---@field frame Frame
---@field text FontString

---@class PopupDivider
---@field Type "divider"
---@field frame Frame
---@field line Texture

---@return PopupItem
local function itemConstructor()
  ---@type Button
  local b = CreateFrame("Button")
  b:SetHeight(24)
  b:SetWidth(200)

  local h = b:CreateTexture(nil, "HIGHLIGHT")
  h:SetColorTexture(1, 1, 1, 0.2)
  h:SetAllPoints(b)

  local t = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  t:SetPoint("LEFT", 24, 0)
  t:SetText("an item")
  t:SetJustifyH("LEFT")
  
  -- Checkbox texture for toggle items
  local checkbox = b:CreateTexture(nil, "ARTWORK")
  checkbox:SetSize(16, 16)
  checkbox:SetPoint("LEFT", 4, 0)
  checkbox:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
  checkbox:Hide()
  
  -- Arrow texture for submenus
  local arrow = b:CreateTexture(nil, "ARTWORK")
  arrow:SetSize(8, 8)
  arrow:SetPoint("RIGHT", -4, 0)
  arrow:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
  arrow:Hide()

  b:SetHighlightTexture(h)

  ---@type PopupItem
  local item = {
    Type = "item",
    button = b,
    text = t,
    highlight = h,
    checkbox = checkbox,
    arrow = arrow
  }
  return item
end

---@param item PopupItem
local function itemDeconstructor(item)
  item.button:Hide()
  item.button:ClearAllPoints()
  item.button:SetParent(nil)
  item.button:SetScript("OnClick", nil)
  item.button:SetScript("OnEnter", nil)
  item.button:SetScript("OnLeave", nil)
  item.checkbox:Hide()
  item.arrow:Hide()
  item.text:SetText("")
end

---@return PopupLabel
local function labelConstructor()
  local f = CreateFrame("Frame")
  f:SetHeight(20)
  f:SetWidth(200)
  
  local t = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  t:SetPoint("LEFT", 8, 0)
  t:SetText("a label")
  t:SetJustifyH("LEFT")
  t:SetTextColor(0.7, 0.7, 0.7, 1)

  ---@type PopupLabel
  local label = {
    Type = "label",
    frame = f,
    text = t
  }
  return label
end

---@param label PopupLabel
local function labelDeconstructor(label)
  label.frame:Hide()
  label.frame:ClearAllPoints()
  label.frame:SetParent(nil)
  label.text:SetText("")
end

---@return PopupDivider
local function dividerConstructor()
  local f = CreateFrame("Frame")
  f:SetHeight(7)
  f:SetWidth(200)

  local line = f:CreateTexture(nil, "ARTWORK")
  line:SetColorTexture(1, 1, 1, 0.2)
  line:SetHeight(1)
  line:SetPoint("LEFT", f, "LEFT", 8, 0)
  line:SetPoint("RIGHT", f, "RIGHT", -8, 0)

  ---@type PopupDivider
  local divider = {
    Type = "divider",
    frame = f,
    line = line
  }
  return divider
end

---@param divider PopupDivider
local function dividerDeconstructor(divider)
  divider.frame:Hide()
  divider.frame:ClearAllPoints()
  divider.frame:SetParent(nil)
end

function popup:Boot()
  local window = moonlight:GetWindow()
  local container = moonlight:GetContainer()
  local list = moonlight:GetList()
  local engine = moonlight:GetSonataEngine()
  local pool = moonlight:GetPool()

  self.window = window:New("popup")
  self.container = container:New()
  self.container:Apply(self.window)
  self.list = list:New()
  self.container:AddChild({
    Icon = 1234,
    Title = "Popup",
    Name = "Popup",
    Drawable = self.list
  })
  
  -- Initialize object pools
  self.itemPool = pool:New(itemConstructor, itemDeconstructor)
  self.labelPool = pool:New(labelConstructor, labelDeconstructor)
  self.dividerPool = pool:New(dividerConstructor, dividerDeconstructor)
  self.activeElements = {}
  
  -- Set window properties
  self.window:SetStrata("TOOLTIP")
  self.window:GetFrame():SetClampedToScreen(true)
  self.window:GetFrame():EnableMouse(true)
  
  -- Hide initially
  self.window:Hide(true)
  
  -- Register with Sonata for theming
  engine:RegisterPopup(self)
end

---@return Window
function popup:GetWindow()
  return self.window
end

--- Clear all active elements and return them to their pools
function popup:_clearElements()
  for _, element in ipairs(self.activeElements) do
    if element.Type == "item" then
      self.itemPool:GiveBack("PopupItem", element)
    elseif element.Type == "label" then
      self.labelPool:GiveBack("PopupLabel", element)
    elseif element.Type == "divider" then
      self.dividerPool:GiveBack("PopupDivider", element)
    end
  end
  table.wipe(self.activeElements)
end

--- Calculate the total height needed for all popup elements
---@param config PopupConfig
---@return number
function popup:_calculateTotalHeight(config)
  local totalHeight = 8 -- Top padding
  
  for _, elementConfig in ipairs(config.Elements) do
    if elementConfig.Type == "item" then
      totalHeight = totalHeight + 24
    elseif elementConfig.Type == "label" then
      totalHeight = totalHeight + 20
    elseif elementConfig.Type == "divider" then
      totalHeight = totalHeight + 7
    end
  end
  
  totalHeight = totalHeight + 8 -- Bottom padding
  return totalHeight
end

--- Build the popup elements from the configuration
---@param config PopupConfig
function popup:_buildElements(config)
  local parentFrame = self.window:GetFrame()
  local yOffset = -8 -- Start with top padding
  
  for _, elementConfig in ipairs(config.Elements) do
    if elementConfig.Type == "item" then
      ---@type PopupItem
      local item = self.itemPool:TakeOne("PopupItem")
      item.button:SetParent(parentFrame)
      item.button:ClearAllPoints()
      item.button:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, yOffset)
      item.button:SetPoint("TOPRIGHT", parentFrame, "TOPRIGHT", 0, yOffset)
      item.text:SetText(elementConfig.Title)
      
      -- Handle checkbox for toggle items
      if elementConfig.CanToggle == true then
        item.checkbox:Show()
        if elementConfig.IsChecked ~= nil and elementConfig.IsChecked() == true then
          item.checkbox:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
        else
          item.checkbox:SetTexture("")
        end
        item.text:SetPoint("LEFT", 24, 0)
      else
        item.checkbox:Hide()
        item.text:SetPoint("LEFT", 8, 0)
      end
      
      -- Handle submenu arrow
      if elementConfig.SubMenu ~= nil then
        item.arrow:Show()
      else
        item.arrow:Hide()
      end
      
      -- Always set up click handler to handle CloseOnClick
      item.button:SetScript("OnClick", function()
        -- Call the provided handler if it exists
        if elementConfig.OnClick ~= nil then
          elementConfig.OnClick()
        end
        -- Always check CloseOnClick
        if elementConfig.CloseOnClick == true then
          self:Hide()
        end
      end)
      
      -- Handle submenu on hover (future implementation)
      if elementConfig.SubMenu ~= nil then
        item.button:SetScript("OnEnter", function()
          -- TODO: Show submenu
        end)
        item.button:SetScript("OnLeave", function()
          -- TODO: Hide submenu after delay
        end)
      end
      
      item.button:Show()
      table.insert(self.activeElements, item)
      yOffset = yOffset - 24
      
    elseif elementConfig.Type == "label" then
      ---@type PopupLabel
      local label = self.labelPool:TakeOne("PopupLabel")
      label.frame:SetParent(parentFrame)
      label.frame:ClearAllPoints()
      label.frame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, yOffset)
      label.frame:SetPoint("TOPRIGHT", parentFrame, "TOPRIGHT", 0, yOffset)
      label.text:SetText(elementConfig.Title)
      label.frame:Show()
      table.insert(self.activeElements, label)
      yOffset = yOffset - 20
      
    elseif elementConfig.Type == "divider" then
      ---@type PopupDivider
      local divider = self.dividerPool:TakeOne("PopupDivider")
      divider.frame:SetParent(parentFrame)
      divider.frame:ClearAllPoints()
      divider.frame:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", 0, yOffset)
      divider.frame:SetPoint("TOPRIGHT", parentFrame, "TOPRIGHT", 0, yOffset)
      divider.frame:Show()
      table.insert(self.activeElements, divider)
      yOffset = yOffset - 7
    end
  end
end

---@param config PopupConfig
function popup:Display(config)
  -- Hide if already visible
  if self.window:IsVisible() == true then
    self.window:Hide(true)
  end
  
  -- Clear existing elements
  self:_clearElements()
  
  -- Store config
  self.currentConfig = config
  
  -- Calculate dimensions
  local totalHeight = self:_calculateTotalHeight(config)
  self.window:SetSize(200, totalHeight)
  
  -- Build elements
  self:_buildElements(config)
  
  -- Position at mouse cursor
  local x, y = GetCursorPosition()
  ---@diagnostic disable-next-line: undefined-field
  local scale = UIParent:GetEffectiveScale()
  local effectiveX = x / scale
  local effectiveY = y / scale
  
  -- Adjust position to ensure popup stays on screen
  local screenWidth = GetScreenWidth()
  local screenHeight = GetScreenHeight()
  
  -- Offset slightly from cursor
  effectiveX = effectiveX + 10
  effectiveY = effectiveY - 10
  
  -- Clamp to screen bounds
  if effectiveX + 200 > screenWidth then
    effectiveX = screenWidth - 200
  end
  if effectiveY - totalHeight < 0 then
    effectiveY = totalHeight
  end
  
  self.window:GetFrame():ClearAllPoints()
  self.window:GetFrame():SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", effectiveX, effectiveY)
  
  -- Set title if provided
  if config.Title ~= nil then
    self.window:SetTitle(config.Title)
  else
    self.window:SetTitle("")
  end
  
  -- Show the window
  self.window:Show(true)
  
  -- Start render chain
  local render = moonlight:GetRender()
  render:NewRenderChain(self, {OnlyRedraw = false})
end

function popup:Hide()
  if self.window:IsVisible() == true then
    self.window:Hide(true)
    self:_clearElements()
    self.currentConfig = nil
  end
end

-- Implement Drawable interface for rendering system

function popup:GetRenderPlan()
  ---@type RenderPlan
  local plan = {
    Plan = {
      [1] = {
        step = "RENDER_SELF"
      }
    }
  }
  return plan
end

---@param parentResult RenderResult?
---@param options RenderOptions
---@param results RenderResults
---@return RenderResult
function popup:Render(parentResult, options, results)
  -- Popup manages its own layout, just return current dimensions
  ---@type RenderResult
  local result = {
    Width = 200,
    Height = self.window:GetFrame():GetHeight()
  }
  return result
end

---@return Frame
function popup:GetFrame()
  return self.window:GetFrame()
end

function popup:SetParent(parent)
  self.window:GetFrame():SetParent(parent)
end

function popup:ClearAllPoints()
  self.window:GetFrame():ClearAllPoints()
end

function popup:SetPoint(point)
  self.window:GetFrame():SetPoint(
    point.Point,
    point.RelativeTo,
    point.RelativePoint,
    point.XOffset,
    point.YOffset
  )
end

function popup:SetSize(width, height)
  self.window:SetSize(width, height)
end

function popup:SetWidth(width)
  self.window:SetWidth(width)
end

function popup:SetHeight(height)
  self.window:SetHeight(height)
end

function popup:IsVisible()
  return self.window:IsVisible()
end

function popup:Show()
  self.window:Show()
end