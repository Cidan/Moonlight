local moonlight = GetMoonlight()

--- A module for dealing with debugging and other test functionality.
---@class debug
local debug = moonlight:NewClass("debug")

---@param f Frame
---@param c Color
---@param mouseOver boolean
function debug:DrawBorder(f, c, mouseOver)
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

---@param f Frame
function debug:DrawRedBorder(f)
  self:DrawBorder(f, {
    R = 1,
    G = 0,
    B = 0,
    A = 1
  }, false)
end

---@param f Frame
function debug:DrawGreenBorder(f)
  self:DrawBorder(f, {
    R = 0,
    G = 1,
    B = 0,
    A = 1
  }, false)
end

---@param f Frame
function debug:DrawBlueBorder(f)
  self:DrawBorder(f, {
    R = 0,
    G = 0,
    B = 1,
    A = 1
  }, false)
end

---@param tag string
---@param value any
---@param nocopy? boolean
function debug:Inspect(tag, value, nocopy)
  if _G.DevTool ~= nil then
    if type(value) == "table"  and not nocopy then
      _G.DevTool:AddData(CopyTable(value), tag)
    else
      _G.DevTool:AddData(value, tag)
    end
  end
end