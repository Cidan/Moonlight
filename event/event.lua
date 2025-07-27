local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class event
---@field handlers table<string, EventHandler>
local event = moonlight:NewClass("event")

---@param eventName string
---@param callback fun(...)
function event:ListenForEvent(eventName, callback)
  if not self.handlers then
    ---@type table<string, EventHandler>
    self.handlers = {}
  end

  if self.handlers[eventName] == nil then
    ---@type EventHandler
    local handler = {
      Event = eventName,
      Frame = CreateFrame("Frame"),
      Callbacks = {}
    }
    handler.Frame:RegisterEvent(eventName)
    handler.Frame:SetScript("OnEvent", function(_, _, ...)
      for _, fn in pairs(handler.Callbacks) do
        fn(...)
      end
    end)
    table.insert(handler.Callbacks, callback)
    self.handlers[eventName] = handler
  else
    table.insert(self.handlers[eventName].Callbacks, callback)
  end
end