local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class sectionset
---@field pool Pool
local sectionset = moonlight:NewClass("sectionset")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class Sectionset: Drawable
---@field frame_Container Frame
---@field sortFunction fun(a: Section, b: Section): boolean
---@field sections table<Section, boolean>
local Sectionset = {}

---@return Sectionset
local sectionsetConstructor = function()
  local instance = {
    sections = {},
    frame_Container = CreateFrame("Frame")
    -- Define your instance variables here
  }
  return setmetatable(instance, {
    __index = Sectionset
  })
end

---@param w Sectionset
local sectionsetDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return Sectionset
function sectionset:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(sectionsetConstructor, sectionsetDeconstructor)
  end

  return self.pool:TakeOne("Sectionset")
end

---@param s Section
function Sectionset:AddSection(s)
  if self.sections[s] == true then
    error("attempted to add a section to a section set when it's already in the set")
  end
  s:SetParent(self.frame_Container)
  self.sections[s] = true
end

---@param s Section
function Sectionset:RemoveSection(s)
  if self.sections[s] ~= true then
    error("attempted to remove a section from a section set when it's not in the section")
  end
  s:ClearAllPoints()
  s:SetParent(nil)
  self.sections[s] = nil
end

---@param width number
---@return number
function Sectionset:Render(width)
  if self.sortFunction == nil then
    error("attempted to render without a sort function on a sectionset -- did you call SetSortFunction?")
  end
  ---@type Section[]
  local sortedSections = {}
  for section in pairs(self.sections) do
    table.insert(sortedSections, section)
  end
  table.sort(sortedSections, self.sortFunction)
  ---@type number
  local totalHeight = 0
  for i, section in ipairs(sortedSections) do
    totalHeight = totalHeight + section:Redraw(width)
    if i == 1 then
      section:SetPoint({
        Point = "TOPLEFT",
        RelativeTo = self.frame_Container
      })
      section:SetPoint({
        Point = "TOPRIGHT",
        RelativeTo = self.frame_Container
      })
    else
      section:SetPoint({
        Point = "TOPLEFT",
        RelativeTo = sortedSections[i-1].frame_Container,
        RelativePoint = "BOTTOMLEFT"
      })
      section:SetPoint({
        Point = "TOPRIGHT",
        RelativeTo = sortedSections[i-1].frame_Container,
        RelativePoint = "BOTTOMRIGHT"
      })
    end
  end
  self.frame_Container:SetHeight(totalHeight)
  return totalHeight
end

function Sectionset:ClearAllPoints()
  self.frame_Container:ClearAllPoints()
end

function Sectionset:SetParent(parent)
  self.frame_Container:SetParent(parent)
end

function Sectionset:SetPoint(point)
  self.frame_Container:SetPoint(
    point.Point,
    point.RelativeTo,
    point.RelativePoint,
    point.XOffset,
    point.YOffset
  )
end

function Sectionset:Redraw(width)
  if self.sortFunction == nil then
    error("attempted to redraw without a sort function on a sectionset -- did you call SetSortFunction?")
  end
  return self:Render(width)
end

---@param f fun(a: Section, b: Section): boolean
function Sectionset:SetSortFunction(f)
  self.sortFunction = f
end