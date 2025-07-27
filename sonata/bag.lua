local moonlight = GetMoonlight()
local pool = moonlight:GetPool()

--- Applies decorations to a window.
---@class sonataBag
---@field pool Pool
local sonataBag = moonlight:NewClass("sonataBag")

--- This is the instance of a decorator, and where the module
--- functionality actually is.
---@class (exact) SonataBag: SonataDecoration
---@field name string
---@field attachedTo Bag
---@field frame_CloseButton Button
---@field frame_Border MoonlightSimpleFrameTemplate
---@field frame_Background MoonlightSimpleFrameTemplate
---@field frame_Title Frame
---@field text_Title SimpleFontString
---@field decoration_CloseButton CloseButtonDecoration | nil
---@field decoration_Border BorderDecoration | nil
---@field decoration_Background BackgroundDecoration | nil
---@field decoration_Handle HandleDecoration | nil
---@field decoration_Insets Insets
---@field decoration_Title TitleDecoration | nil
local SonataBag = {}

---@return SonataBag
local decorateConstructor = function()
  local instance = {
    frame_Border = CreateFrame(
      "Frame",
      nil,
      nil,
      "MoonlightSimpleFrameTemplate"
    ),
    frame_CloseButton = CreateFrame(
      "Button",
      nil,
      nil,
      "MoonlightSimpleButtonTemplate"
    ),
    frame_Background = CreateFrame(
      "Frame",
      nil,
      nil,
      "MoonlightSimpleFrameTemplate"
    ),
    frame_Title = CreateFrame(
      "Frame"
    ),
  }
  return setmetatable(instance, {
    __index = SonataBag
  })
end

---@param d SonataBag
local decorateDeconstructor = function(d)
  if d.attachedTo == nil then
    error("attempted to release an unattached decoration")
  end

  d.frame_CloseButton:ClearAllPoints()
  d.frame_CloseButton:SetParent(nil)
  d.frame_CloseButton:SetScript("OnClick", nil)
  d.frame_CloseButton:Hide()

  d.frame_Border:ClearAllPoints()
  d.frame_Border:SetParent(nil)
  d.frame_Border:Hide()

  d.frame_Background:ClearAllPoints()
  d.frame_Background:SetParent(nil)
  d.frame_Background:Hide()

  d.frame_Title:ClearAllPoints()
  d.frame_Title:SetParent(nil)
  d.frame_Title:Hide()

  d.name = nil

  d.attachedTo:GetFrame():SetMovable(false)
  d.attachedTo:SetDecoration(nil)
  d.attachedTo = nil
end

--- This creates a new instance of a decorator.
---@param name string
---@return SonataBag
function sonataBag:New(name)
  if self.pool == nil then
    self.pool = pool:New(decorateConstructor, decorateDeconstructor)
  end

  local d = self.pool:TakeOne("SonataBag")
  d.name = name
  return d
end


---@param w Bag
function SonataBag:Apply(w)
  if self.attachedTo ~= nil then
    error("unable to attach a decoration that is already attached")
  end

  self.attachedTo = w

  local parent = w:GetFrame()
  local cbd = self.closeButtonDecoration
  local borderDecoration = self.decoration_Border
  local backgroundDecoration = self.decoration_Background
  local titleDecoration = self.decoration_Title

  if cbd ~= nil then
    self.frame_CloseButton:SetParent(parent)
    self.frame_CloseButton:SetText(cbd.Text)
    self.frame_CloseButton:SetSize(cbd.Width, cbd.Height)
    self.frame_CloseButton:SetPoint(
      "TOPRIGHT",
      parent,
      "TOPRIGHT",
      cbd.XOffset,
      cbd.YOffset
    )
    self.frame_CloseButton:SetScript("OnClick", function()
      w:Hide()
    end)
    self.frame_CloseButton:Show()
  end

  if borderDecoration ~= nil then
    self.frame_Border:SetParent(parent)
    self.frame_Border:ClearAllPoints()
    self.frame_Border.Texture:SetTexture(borderDecoration.Texture)
    self.frame_Border.Texture:SetTextureSliceMargins(
      borderDecoration.SliceMargins.Left,
      borderDecoration.SliceMargins.Top,
      borderDecoration.SliceMargins.Right,
      borderDecoration.SliceMargins.Bottom
    )
    self.frame_Border.Texture:SetTextureSliceMode(borderDecoration.SliceMode)
    self.frame_Border.Texture:SetVertexColor(
      borderDecoration.VertexColor.R,
      borderDecoration.VertexColor.G,
      borderDecoration.VertexColor.B,
      borderDecoration.VertexColor.A
    )
    local insets = borderDecoration.Inset
    self.frame_Border:SetPoint(
      "TOPLEFT", 
      parent,
      "TOPLEFT",
      insets.Left,
      -insets.Top
    )
    self.frame_Border:SetPoint(
      "TOPRIGHT", 
      parent,
      "TOPRIGHT",
      -insets.Right,
      -insets.Top
    )
    self.frame_Border:SetPoint(
      "BOTTOMLEFT", 
      parent,
      "BOTTOMLEFT",
      insets.Left,
      insets.Bottom
    )
    self.frame_Border:SetPoint(
      "BOTTOMRIGHT", 
      parent,
      "BOTTOMRIGHT",
      -insets.Right,
      insets.Bottom
    )
    self.frame_Border.Texture:SetAllPoints()
    self.frame_Border:SetFrameLevel(2)
    self.frame_Border:Show()
  end

  if backgroundDecoration ~= nil then
    self.frame_Background:SetParent(parent)
    self.frame_Background:ClearAllPoints()
    self.frame_Background.Texture:SetTexture(backgroundDecoration.Texture)
    self.frame_Background.Texture:SetTextureSliceMargins(
      backgroundDecoration.SliceMargins.Left,
      backgroundDecoration.SliceMargins.Top,
      backgroundDecoration.SliceMargins.Right,
      backgroundDecoration.SliceMargins.Bottom
    )
    self.frame_Background.Texture:SetTextureSliceMode(backgroundDecoration.SliceMode)
    self.frame_Background.Texture:SetVertexColor(
      backgroundDecoration.VertexColor.R,
      backgroundDecoration.VertexColor.G,
      backgroundDecoration.VertexColor.B,
      backgroundDecoration.VertexColor.A
    )

    local insets = backgroundDecoration.Inset
    self.frame_Background:SetPoint(
      "TOPLEFT", 
      parent,
      "TOPLEFT",
      insets.Left,
      -insets.Top
    )
    self.frame_Background:SetPoint(
      "TOPRIGHT", 
      parent,
      "TOPRIGHT",
      -insets.Right,
      -insets.Top
    )
    self.frame_Background:SetPoint(
      "BOTTOMLEFT", 
      parent,
      "BOTTOMLEFT",
      insets.Left,
      insets.Bottom
    )
        self.frame_Background:SetPoint(
      "BOTTOMRIGHT", 
      parent,
      "BOTTOMRIGHT",
      -insets.Right,
      insets.Bottom
    )
    self.frame_Background.Texture:SetAllPoints()
    self.frame_Background:SetFrameLevel(1)
    self.frame_Background:Show()
  end

  if titleDecoration ~= nil then
    local titleText = self.frame_Title:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("TOPLEFT")
    self.frame_Title:SetParent(w:GetFrame())
    self.frame_Title:SetPoint(
      titleDecoration.Point.Point,
      w:GetFrame(),
      titleDecoration.Point.RelativePoint,
      titleDecoration.Point.XOffset,
      titleDecoration.Point.YOffset
    )
    self.text_Title = titleText
    self.frame_Title:SetSize(titleDecoration.Width, titleDecoration.Height)
  end

  local title = w:GetTitle()
  if self.text_Title ~= nil then
    self.text_Title:SetText(title)
  end
  w:SetDecoration(self)
end

---@param c? CloseButtonDecoration
function SonataBag:SetCloseButton(c)
  if self.attachedTo ~= nil then
    error("you can not change decoration properties after it has been applied")
  end
  self.closeButtonDecoration = c
end

---@param b? BorderDecoration
function SonataBag:SetBorder(b)
  if self.attachedTo ~= nil then
    error("you can not change decoration properties after it has been applied")
  end
  self.decoration_Border = b
end

---@param b? BackgroundDecoration
function SonataBag:SetBackground(b)
  if self.attachedTo ~= nil then
    error("you can not change decoration properties after it has been applied")
  end
  self.decoration_Background = b
end

---@param h? HandleDecoration
function SonataBag:SetHandle(h)
  if self.attachedTo ~= nil then
    error("you can not change decoration properties after it has been applied")
  end
  self.decoration_Handle = h
end

--- SetInsets sets the window insets for this window,
--- making sure that content is rendered within the insets.
---@param i Insets
function SonataBag:SetInsets(i)
  if self.attachedTo ~= nil then
    error("you can not change decoration properties after it has been applied")
  end
  self.decoration_Insets = i
end

---@param t? TitleDecoration
function SonataBag:SetTitle(t)
  if self.attachedTo ~= nil then
    error("you can not change decoration properties after it has been applied")
  end
  self.decoration_Title = t
end

---@return Insets
function SonataBag:GetInsets()
  return self.decoration_Insets
end

function SonataBag:Release()
  sonataBag.pool:GiveBack("SonataBag", self)
end