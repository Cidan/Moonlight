local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class stub
local stub = moonlight:NewClass("stub")

---@generic T
---@param _class `T`
---@param name string
---@return T | nil
function stub:GetAddon(_class, name)
  local LibStub = _G["LibStub"]
  if LibStub == nil then
    return nil
  end
  if LibStub.libs == nil then
    return nil
  end
  return LibStub.libs[name] --[[@as T]]
end