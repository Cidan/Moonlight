local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class popup: Drawable
---@field window Window
---@field container Container
---@field list List
local popup = moonlight:NewClass("popup")

---@class PopupItem
---@field Type "item"
---@field button Button
---@field text FontString
---@field highlight Texture

---@class PopupLabel
---@field Type "label"
---@field frame Frame
---@field text FontString

---@class PopupDivider
---@field Type "divider"
---@field frame Frame

local function itemConstructor()
  ---@type Button
  local b = CreateFrame("Button")
  b:SetHeight(24)
  b:SetWidth(180)

  local h = b:CreateTexture(nil, "HIGHLIGHT")
  h:SetColorTexture(1, 1, 1, 0.2)
  h:SetAllPoints(b)

  local t = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  t:SetPoint("LEFT", 4, 0)
  t:SetText("an item")

  b:SetHighlightTexture(h)

  ---@type PopupItem
  local item = {
    Type = "item",
    button = b,
    text = t,
    highlight = h
  }
  return item
end

---@param item PopupItem
local function itemDeconstructor(item)
  item.button:Hide()
  item.button:ClearAllPoints()
  item.button:SetParent(nil)
  item.button:SetScript("OnClick", nil)
end

local function labelConstructor()
  local f = CreateFrame("Frame")
  f:SetHeight(24)
  f:SetWidth(180)
  local t = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  t:SetPoint("LEFT", 4, 0)
  t:SetText("a label")

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
end

local function dividerConstructor()
  local f = CreateFrame("Frame")
  f:SetHeight(3)
  f:SetWidth(180)

  local white = CreateColor(1, 1, 1, 1)
  local faded = CreateColor(1, 1, 1, 0.2)

  local left = f:CreateTexture(nil, "ARTWORK")
  left:SetColorTexture(1, 1, 1, 1)
  left:SetHeight(1)

  local right = f:CreateTexture(nil, "ARTWORK")
  right:SetGradient("HORIZONTAL", white --[[@as colorRGBA]], faded --[[@as colorRGBA]])
  right:SetColorTexture(1, 1, 1, 1)
  right:SetHeight(1)
  right:SetWidth(100)

  left:SetPoint("LEFT", f, "LEFT")
  right:SetPoint("LEFT", left, "RIGHT")
  right:SetPoint("RIGHT", f, "RIGHT")

  ---@type PopupDivider
  local divider = {
    Type = "divider",
    frame = f
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

  engine:RegisterPopup(self)
end

---@return Window
function popup:GetWindow()
  return self.window
end

---@param config PopupConfig
function popup:Show(config)
end

function popup:ClearAllPoints()
  self.window:ClearAllPoints()
end

--[[
function popup:_clear()
  for _, element in ipairs(self.activeElements) do
    if element.Type == "item" then
      self.itemPool:GiveBack("PopupItem", element)
    elseif element.Type == "label" then
      self.labelPool:GiveBack("PopupLabel", element)
    elseif element.Type == "divider" then
      self.dividerPool:GiveBack("PopupDivider", element)
    end
  end
  self.activeElements = {}
end

---@param config PopupConfig
function popup:Show(config)
  if self.window:IsVisible() then
    self.window:Hide(true)
  end

  self:_clear()

  local totalHeight = 0.0
  for _, elementConfig in ipairs(config.Elements) do
    local yOffset = -totalHeight
    if elementConfig.Type == "item" then
      ---@type PopupItem
      local item = self.itemPool:TakeOne("PopupItem")
      item.button:SetParent(self.window:GetFrame())
      item.button:ClearAllPoints()
      item.button:SetPoint("TOPLEFT", self.window:GetFrame(), "TOPLEFT", 0, yOffset)
      item.text:SetText(elementConfig.Title)
      if elementConfig.OnClick ~= nil then
        item.button:SetScript("OnClick", function()
          elementConfig.OnClick()
          if elementConfig.CloseOnClick == true then
            self.window:Hide(true)
          end
        end)
      end
      item.button:Show()
      table.insert(self.activeElements, item)
      totalHeight = totalHeight + item.button:GetHeight()
    elseif elementConfig.Type == "label" then
      ---@type PopupLabel
      local label = self.labelPool:TakeOne("PopupLabel")
      label.frame:SetParent(self.window:GetFrame())
      label.frame:ClearAllPoints()
      label.frame:SetPoint("TOPLEFT", self.window:GetFrame(), "TOPLEFT", 0, yOffset)
      label.text:SetText(elementConfig.Title)
      label.frame:Show()
      table.insert(self.activeElements, label)
      totalHeight = totalHeight + label.frame:GetHeight()
    elseif elementConfig.Type == "divider" then
      ---@type PopupDivider
      local divider = self.dividerPool:TakeOne("PopupDivider")
      divider.frame:SetParent(self.window:GetFrame())
      divider.frame:ClearAllPoints()
      divider.frame:SetPoint("TOPLEFT", self.window:GetFrame(), "TOPLEFT", 0, yOffset)
      divider.frame:Show()
      table.insert(self.activeElements, divider)
      totalHeight = totalHeight + divider.frame:GetHeight()
    end
  end

  self.window:SetHeight(totalHeight + 12)
  self.window:SetWidth(180)
  self.window:GetFrame():SetParent(UIParent)

  self.window:GetFrame():ClearAllPoints()
  local x, y = GetCursorPosition()
  local eff_x = x / UIParent:GetEffectiveScale()
  local eff_y = y / UIParent:GetEffectiveScale()
  self.window:SetPoint({
    Point = "TOPLEFT",
    RelativeTo = UIParent,
    RelativePoint = "BOTTOMLEFT",
    XOffset = eff_x,
    YOffset = eff_y
  })
  self.window:SetTitle(config.Title)
  self.window:Show(true)
end
]]--