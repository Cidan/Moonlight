local moonlight = GetMoonlight()
local pool = moonlight:GetPool()

--- Applies decorations to a window.
---@class sonataBag
---@field pool Pool
local sonataBag = moonlight:NewClass("sonataBag")

--- This is the instance of a decorator, and where the module
--- functionality actually is.
---@class (exact) SonataBag: SonataWindow
local SonataBag = {}