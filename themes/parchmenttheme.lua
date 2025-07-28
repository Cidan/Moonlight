local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class parchmenttheme
local parchmenttheme = moonlight:NewClass("parchmenttheme")

function parchmenttheme:Boot()
  local engine = moonlight:GetSonataEngine()

  engine:RegisterTheme({
    Name = "parchment",
    BagTheme = {
      ResizeDecoration = {
        Corner = "BOTTOMRIGHT"
      },
      ExtraTextures = {
        Textures = {
          [1] = {
            Point = {
              Point = "BOTTOM",
              RelativePoint = "TOP",
              YOffset = -40,
              XOffset = 0
            },
            SliceMargins = {
              Right = 24,
              Bottom = 24,
              Top = 24,
              Left = 24
            },
            VertexColor = {
              R = 1,
              G = 1,
              B = 1,
              A = 1
            },
            Inset = {
              Bottom = 0,
              Left = 0,
              Top = 0,
              Right = 0
            },
            Texture = [[interface/addons/moonlight/assets/textures/parchment-ribbon.png]],
            SliceMode = Enum.UITextureSliceMode.Stretched
          }
        }
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
        Texture = [[interface/addons/moonlight/assets/textures/parchment.png]],
        SliceMode = Enum.UITextureSliceMode.Stretched,
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
          Point = "BOTTOM",
          RelativePoint = "TOP",
          XOffset = 0,
          YOffset = -15
        },
        Width = 100,
        Height = 24,
        Color = {
          R = 1,
          G = 1,
          B = 1,
          A = 1
        }
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
