local moonlight = GetMoonlight()

--- A module for dealing with debugging and other test functionality.
---@class debug
local debug = moonlight:NewClass("debug")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Debug
local Debug = {}

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Debug
function debug:New()
  local instance = {}
  return setmetatable(instance, {
    __index = Debug
  })
end

---@param f Frame
---@param c Color
---@param mouseOver boolean
function Debug:DrawBorder(f, c, mouseOver)
  local border = CreateFrame(
    "Frame",
    nil,
    f,
    ---@diagnostic disable-next-line: generic-constraint-mismatch
    "MoonlightDebugFrameTemplate"
  )

  border:SetAllPoints(f)
  for _, tex in pairs({"TopLeft", "TopRight", "BottomLeft", "BottomRight", "Top", "Bottom", "Left", "Right"}) do
    border[tex]:SetVertexColor(c.R, c.G, c.B, c.A)
  end
  border:SetFrameStrata("HIGH")
  if mouseOver then
    f:HookScript("OnEnter", function() border:Show() end)
    f:HookScript("OnLeave", function() border:Hide() end)
    border:Hide()
  else
    border:Show()
  end
end

--- Creates a new test window for debugging.
function Debug:NewTestWindow()
  local window = moonlight:GetWindow()
  local w = window:New()
  w:SetSize(450, 300)
  w:SetHeightToScreen()
  w:SetPoint({
    Point = "LEFT",
    RelativeTo = UIParent,
    RelativePoint = "RIGHT"
  })
  w:SetStrata("FULLSCREEN")

  local d = moonlight:GetDecorate():New("default")

  d:SetCloseButton({
    Width = 32,
    Height = 32,
    Text = "X",
  })

  d:SetBackground({
    Texture = [[interface/framegeneral/ui-background-marble]],
    SliceMode = Enum.UITextureSliceMode.Tiled,
    VertexColor = {
      A = 0.8,
      R = 1,
      G = 1,
      B = 1,
    },
    SliceMargins = {
      Left = 24,
      Right = 24,
      Top = 24,
      Bottom = 24
    }
  })

  --[[
  d:SetHandle({
    Points = {
      {
        Point = "TOPLEFT",
        RelativePoint = "TOPLEFT",
        YOffset = -20
      },
      {
        Point = "TOPRIGHT",
        RelativePoint = "TOPRIGHT",
        YOffset = -20
      }
    },
    Height = 20,
    Width = 0,
  })
  ]]--
  d:SetInsets({
    Left = 6,
    Right = 6,
    Bottom = 6,
    Top = 24
  })

  d:SetTitle({
    Point = {
      RelativePoint = "TOPLEFT",
      Point = "TOPLEFT",
      XOffset = 10,
      YOffset = -5
    },
    Width = 100,
    Height = 24
  })
  d:Apply(w)

  -- Create a container for the window.
  local c = moonlight:GetContainer():New()
  c:Apply(w)

  local bigFrame = CreateFrame("Frame")
  bigFrame:SetHeight(1000)
  c:SetChild(bigFrame)

  local showAnimation = moonlight:GetAnimation():New()
  local hideAnimation = moonlight:GetAnimation():New()

  showAnimation:Slide({
    Direction = SlideDirection.LEFT,
    Duration = 0.2,
    Distance = 300,
    ApplyFinalPosition = true
  })

  showAnimation:Alpha({
    Start = 0.0,
    End = 1.0,
    Duration = 0.15
  })

  hideAnimation:Slide({
    Direction = SlideDirection.RIGHT,
    Duration = 0.2,
    Distance = 300,
    ApplyFinalPosition = true
  })

  hideAnimation:Alpha({
    Start = 1.0,
    End = 0.0,
    Duration = 0.10
  })

  showAnimation:ApplyOnShow(w)
  hideAnimation:ApplyOnHide(w)

  w:SetTitle("Cidan's Bags")
  local binds = moonlight:GetBinds()
  binds:OnBagShow(function()
    if w:IsVisible() then
      w:Hide()
    else
      w:Show()
    end
  end)
  w:Hide(true)
end