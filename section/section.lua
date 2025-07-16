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
---@field text_Title SimpleFontString
---@field calculatedHeaderOffset number
local Section = {}

---@return Section
local sectionConstructor = function()
  local debug = moonlight:GetDebug():New()

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
      return a:GetID() > b:GetID()
    end
  })
  local f = CreateFrame("Frame")
  
  -- Create the title text
  local titleFont = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  titleFont:SetTextColor(1, 1, 1)
  titleFont:SetJustifyH("LEFT")
  titleFont:SetText("Untitled")

  local frame_Underline = CreateFrame("Frame", nil, f)
  local white = CreateColor(1, 1, 1, 1)
  local faded = CreateColor(1, 1, 1, 0.2)

  local left = frame_Underline:CreateTexture(nil, "ARTWORK")
  left:SetColorTexture(1, 1, 1, 1)
  left:SetHeight(1)

  local right = frame_Underline:CreateTexture(nil, "ARTWORK")
  right:SetGradient("HORIZONTAL", white, faded)
  right:SetColorTexture(1, 1, 1, 1)
  right:SetHeight(1)
  right:SetWidth(100)

  left:SetPoint("LEFT", frame_Underline, "LEFT")
  right:SetPoint("LEFT", left, "RIGHT")
  right:SetPoint("RIGHT", frame_Underline, "RIGHT")

  frame_Underline:SetHeight(3)

  -- Assemble it all
  titleFont:SetPoint("TOPLEFT", f, "TOPLEFT", 4, -4)
  frame_Underline:SetPoint("TOPLEFT", titleFont, "BOTTOMLEFT", 0, -2)
  frame_Underline:SetPoint("RIGHT", f, "RIGHT", -4, -2)

  local calculatedHeaderOffset = frame_Underline:GetHeight() + titleFont:GetHeight() + 8

  g:SetParent(f)
  g:SetPoint({
    Point = "TOPLEFT",
    RelativeTo = f,
    RelativePoint = "TOPLEFT",
    XOffset = 0,
    YOffset = -calculatedHeaderOffset
  })
  local instance = {
    grid = g,
    frame_Container = f,
    frame_Underline = frame_Underline,
    text_Title = titleFont,
    calculatedHeaderOffset = calculatedHeaderOffset
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Section
  })
end

---@param w Section
local sectionDeconstructor = function(w)
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

---@param title string
function Section:SetTitle(title)
  self.text_Title:SetText(title)
end

function Section:Expand()
end

function Section:Shrink()
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

function Section:Redraw(width)
  local h = self.grid:Redraw(width)
  h = h + self.calculatedHeaderOffset
  self.frame_Container:SetHeight(h)
  return h
end