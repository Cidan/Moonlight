local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class darktheme
local darktheme = moonlight:NewClass("darktheme")

function darktheme:Boot()
  local engine = moonlight:GetSonataEngine()

  engine:RegisterTheme({
    Name = "dark",
    BagTheme = {
      ResizeDecoration = {
        Corner = "BOTTOMRIGHT"
      },
      CloseButtonDecoration = {
        Width = 32,
        Height = 32,
        Text = "X",
      },
      HandleDecoration = {
        Points = {
          {
            Point = "TOPLEFT",
            RelativePoint = "TOPLEFT" 
          },
          {
            Point = "TOPRIGHT",
            RelativePoint = "TOPRIGHT"
          }
        },
        Height = 25
      },
      BackgroundDecoration = {
        Texture = [[interface/addons/moonlight/assets/textures/dark-frame.png]],
        SliceMode = Enum.UITextureSliceMode.Tiled,
        VertexColor = {
          A = 1,
          R = 1,
          G = 1,
          B = 1,
        },
        SliceMargins = {
          Left = 24,
          Right = 24,
          Top = 24,
          Bottom = 24
        },
        Inset = {
          Left = 0,
          Right = 0,
          Top = 0,
          Bottom = 0
        }
      },
      TitleDecoration = {
        Point = {
          RelativePoint = "TOPLEFT",
          Point = "TOPLEFT",
          XOffset = 20,
          YOffset = -15
        },
        Width = 100,
        Height = 24
      },
      Inset = {
        Left = 18,
        Right = 24,
        Bottom = 12,
        Top = 32
      }
    }
  })
end
