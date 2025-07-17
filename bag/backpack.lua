local moonlight = GetMoonlight()
local context = moonlight:GetContext()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class backpack
local backpack = moonlight:NewClass("backpack")

---@class Backpack: Bag
local Backpack = {}

--- Boot creates the backpack bag.
function backpack:Boot()
  local engine = moonlight:GetSonataEngine()
  Backpack.baseFrame = CreateFrame("Frame")
  Backpack.title = ""

  engine:RegisterBag(Backpack)
end

--- Sets the point of the window.
---@param point Point
function Backpack:SetPoint(point)
  self.baseFrame:SetPoint(
    point.Point,
    point.RelativeTo,
    point.RelativePoint,
    point.XOffset, 
    point.YOffset
  )
end

--- Sets the size of the window.
---@param width number
---@param height number
function Backpack:SetSize(width, height)
  self.baseFrame:SetSize(width, height)
end

---@param width number
function Backpack:SetWidth(width)
  self.baseFrame:SetWidth(width)
end

function Backpack:SetHeightToScreen()
  self.baseFrame:SetHeight(GetScreenHeight())
end

---@param f fun(ctx: Context, w: Backpack)
function Backpack:SetOnShow(f)
  self.baseFrame:SetScript("OnShow", 
    function(...)
      local ctx = context:New()
      f(ctx, self)
    end
  )
end

---@return Frame
function Backpack:GetFrame()
  return self.baseFrame
end

---@param doNotAnimate boolean | nil
function Backpack:Show(doNotAnimate)
  if doNotAnimate then
    self.baseFrame:Show()
    return
  end
  if self.hideAnimation == nil then
    error("attempting to show window without animation attached")
  end
  if self.showAnimation == nil then
    error("attempting to show window without animation attached")
  end

  self.showAnimation:Play(self.hideAnimation)
end

---@param doNotAnimate boolean | nil
function Backpack:Hide(doNotAnimate)
  if doNotAnimate then
    self.baseFrame:Hide()
    return
  end
  if self.hideAnimation == nil then
    error("attempting to hide window without animation attached")
  end
  if self.showAnimation == nil then
    error("attempting to hide window without animation attached")
  end

  self.hideAnimation:Play(self.showAnimation)
end

---@return boolean
function Backpack:IsVisible()
  return self.baseFrame:IsVisible()
end

function Backpack:UpdateInsets()
  if self.container ~= nil then
    self.container:UpdateInsets()
  end
end

---@param d SonataBag | nil
function Backpack:SetDecoration(d)
  self.decoration = d
  self:UpdateInsets()
end

---@return SonataBag | nil
function Backpack:GetDecoration()
  return self.decoration
end

---@return Insets | nil
function Backpack:GetInsets()
  if self.decoration ~= nil then
    return self.decoration:GetInsets()
  end
end

---@param a MoonAnimation
function Backpack:SetShowAnimation(a)
  self.showAnimation = a
end

---@param a MoonAnimation
function Backpack:SetHideAnimation(a)
  self.hideAnimation = a
end

---@param title string
function Backpack:SetTitle(title)
  self.title = title
  local decoration = self:GetDecoration()
  if decoration ~= nil then  
    decoration.text_Title:SetText(title)
  end
end

---@return string
function Backpack:GetTitle()
  return self.title
end

---@param strata FrameStrata
function Backpack:SetStrata(strata)
  self:GetFrame():SetFrameStrata(strata)
end