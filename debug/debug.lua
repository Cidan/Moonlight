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

--- Creates a new test window for debugging.
function Debug:NewTestWindow()
  local window = moonlight:GetWindow()
  local w = window:New()
  w:SetSize(300, 300)
  w:SetPoint("CENTER", UIParent)

  local d = moonlight:GetDecorate():New("default")
  d:SetCloseButton({
    Width = 32,
    Height = 32,
    Text = "X",
  })
  d:SetBackground({
    Texture = [[interface/soulbinds/soulbindsconduitpendinganimationmask]],
    SliceMode = Enum.UITextureSliceMode.Tiled,
    VertexColor = {
      A = 1,
      R = 0,
      G = 0,
      B = 0,
    },
    SliceMargins = {
      Left = 24,
      Right = 24,
      Top = 24,
      Bottom = 24
    }
  })
  d:Apply(w)
  w:Show()
end