local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class list
---@field pool Pool
local list = moonlight:NewClass("list")

--- This is the instance of a module, and where the module
--- functionality actually is. Note the upper case starting letter -- this denotes a module instance.
--- Make sure to define all instance variables here. Private variables start with a lower case, public variables start with an upper case. 
---@class List: Drawable
---@field frame_Container Frame
---@field frame_ScrollBox WowScrollBoxList
---@field frame_ScrollBar MinimalScrollBar
---@field provider DataProviderMixin
---@field dragBehavior ScrollBoxDragBehavior
---@field frame_View ScrollBoxListViewMixin
---@field config ListConfig
---@field frameToListRow table<Frame, Listrow>
local List = {}

---@return List
local listConstructor = function()
  local instance = setmetatable({}, {
    __index = List
  })
  local frame = CreateFrame("Frame")

  local scrollBox = CreateFrame("Frame", nil, frame, "WowScrollBoxList")
  scrollBox:SetPoint("TOPLEFT", frame, "TOPLEFT")
  scrollBox:SetPoint("BOTTOM")

  local scrollBar = CreateFrame("EventFrame", nil, scrollBox, "MinimalScrollBar")
  scrollBar:SetPoint("TOPLEFT", frame, "TOPRIGHT", -16, 0)
  scrollBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", -16, 0)

  scrollBar:SetHideIfUnscrollable(true)
  scrollBar:SetInterpolateScroll(true)
  scrollBox:SetInterpolateScroll(true)

  scrollBox:SetUseShadowsForEdgeFade(true)
  scrollBox:SetEdgeFadeLength(32)
  
  local view = CreateScrollBoxListLinearView()
  view:SetPanExtent(50)
  view:SetPadding(4, 4, 8, 4, 0)
  view:SetExtent(20)
  --TODO(lobato): implement SetElementExtentCalculator and use drawable's for getting height
  -- ScrollUtil.AddManagedScrollBarVisibilityBehavior also use this for autohide

  ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view)
  local dragBehavior = ScrollUtil.InitDefaultLinearDragBehavior(scrollBox)

  instance.dragBehavior = dragBehavior
  instance.frame_ScrollBar = scrollBar --[[@as MinimalScrollBar]]
  instance.frame_ScrollBox = scrollBox
  instance.frame_View = view
  instance.frame_Container = frame
  instance.frameToListRow = {}

  return instance
end

---@param w List
local listDeconstructor = function(w)
end

--- This creates a new instance of a module, and optionally, initializes the module.
---@return List
function list:New()
  if self.pool == nil then
    self.pool = moonlight:GetPool():New(listConstructor, listDeconstructor)
  end

  return self.pool:TakeOne("List")
end

---@param config ListConfig
function List:SetConfig(config)
  if self.config ~= nil then
    error("List is already configured.")
  end

  self.config = config
  self.frame_ScrollBox:SetDataProvider(config.DataProvider)

  ---@param rawFrame Frame
  ---@param rowData any
  local elementInitializer = function(rawFrame, rowData)
    local row = moonlight:GetListrow():New()
    row.frame_Container = rawFrame
    row.RowData = rowData
    row.children = {}

    -- If we are creating for the first time
    if #row.children == 0 then
      for _, column in ipairs(config.Columns) do
        local cell = column.CreateCell(rowData)
        cell:SetParent(row.frame_Container)
        table.insert(row.children, cell)
      end
    end

    -- Now, layout the children
    local lastAnchor = { "TOPLEFT", row.frame_Container, "TOPLEFT" }
    for _, cell in ipairs(row.children) do
      cell:ClearAllPoints()
      cell:SetPoint(lastAnchor, lastAnchor, lastAnchor)
      lastAnchor = { "TOPLEFT", cell, "TOPRIGHT" }
    end
    row.frame_Container:SetHeight(config.RowHeight)
    self.frameToListRow[row.frame_Container] = row
  end

  ---@param rawFrame Frame
  ---@param rowData any
  local elementResetter = function(rawFrame, rowData)
    local row = self.frameToListRow[rawFrame]
    if row == nil then
      error("row is missing during reset, that's a big ol bug")
    end
    if row.children ~= nil then
      for i, column in ipairs(config.Columns) do
        local cell = row.children[i]
        if cell ~= nil then
          column.ReleaseCell(cell)
        end
      end
      wipe(row.children)
    end
    row.RowData = nil
    self.frameToListRow[rawFrame] = nil
  end

  self.frame_View:SetElementExtent(config.RowHeight)
  self.frame_View:SetElementInitializer("Frame", elementInitializer)
  self.frame_View:SetElementResetter(elementResetter)
end