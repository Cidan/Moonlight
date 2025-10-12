local moonlight = GetMoonlight()

--- Placeholder button that occupies space in the grid but renders nothing visible.
--- Used to preserve empty item slots when items are removed, until the bag is closed.
---@class placeholderbutton
---@field pool Pool
local placeholderbutton = moonlight:NewClass("placeholderbutton")

--- Placeholder button instance - an invisible drawable that maintains grid spacing.
---@class PlaceholderButton: Drawable
---@field frame_Container Frame
local PlaceholderButton = {}

---@return PlaceholderButton
local placeholderbuttonConstructor = function()
  local drawable = moonlight:GetDrawable()
  ---@type PlaceholderButton
  local instance = drawable:Create(PlaceholderButton)

  -- Create an invisible, non-interactive frame
  local f = CreateFrame("Frame")
  f:SetAlpha(0)
  f:EnableMouse(false)
  f:EnableKeyboard(false)

  instance.frame_Container = f

  return instance
end

---@param w PlaceholderButton
local placeholderbuttonDeconstructor = function(w)
  w.frame_Container:SetAlpha(0)
  w.frame_Container:EnableMouse(false)
  w.frame_Container:EnableKeyboard(false)
  w:ClearAllPoints()
  w:SetParent(nil)
  w:Hide()
  -- Reset sortKey per object pooling patterns (defensive programming)
  w.sortKey = nil
end

--- Creates a new placeholder button instance from the pool.
---@return PlaceholderButton
function placeholderbutton:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(placeholderbuttonConstructor, placeholderbuttonDeconstructor)
  end

  return self.pool:TakeOne("PlaceholderButton")
end

--- Releases the placeholder button back to the pool.
function PlaceholderButton:ReleaseBackToPool()
  placeholderbutton.pool:GiveBack("PlaceholderButton", self)
end
