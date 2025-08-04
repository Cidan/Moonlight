local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class event
---@field handlers table<string, EventHandler>
---@field globalEventHandler Eventer
local event = moonlight:NewClass("event")

---@class Eventer
---@field messageToCallbacks table<string, table<string, fun(...:any)>>
local Eventer = {}

function event:Boot()
  event.globalEventHandler = event:New()
end

---@param message string
---@param id string
---@param callback fun(...: any)
function event:TellMeWhen(message, id, callback)
  self.globalEventHandler:TellMeWhen(message, id, callback)
end

---@param message string
---@param id string The ID of the sender. This sender will not receive the message.
---@param ... any
function event:SendMessageToEveryoneButMe(message, id, ...)
  self.globalEventHandler:SendMessageToEveryoneButMe(message, id, ...)
end

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

---@return Eventer
function event:New()
  local e = {
    messageToCallbacks = {},
  }
  return setmetatable(e, {
    __index = Eventer
  })
end

---@param message string
---@param id string
---@param callback fun(...: any)
function Eventer:TellMeWhen(message, id, callback)
  if self.messageToCallbacks[message] == nil then
    self.messageToCallbacks[message] = {}
  end
  if self.messageToCallbacks[message][id] ~= nil then
    error("a handler with this message and id pair has already been registered")
  end
  self.messageToCallbacks[message][id] = callback
end

---@param message string
---@param id string The ID of the sender. This sender will not receive the message.
---@param ... any
function Eventer:SendMessageToEveryoneButMe(message, id, ...)
  if self.messageToCallbacks[message] == nil then
    error("there is no message registered by that name")
  end
  for mid, callback in pairs(self.messageToCallbacks[message]) do
    if mid ~= id then
      callback(...)
    end
  end
end

function Eventer:Clear()
  self.messageToCallbacks = {}
end
