local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class sonataEngine
---@field object_Windows table<Window, boolean>
---@field themes table<string, Theme>
local sonataEngine = moonlight:NewClass("sonataEngine")

---@type table<Window, boolean>
sonataEngine.object_Windows = {}

---@type table<string, Theme>
sonataEngine.themes = {}

---@param w Window
function sonataEngine:RegisterWindow(w)
  if self.object_Windows[w] == true then
    error("attempt to register a window in sonata twice")
  end
  self.object_Windows[w] = true
end

---@param t Theme
function sonataEngine:RegisterTheme(t)
  if sonataEngine.themes[t.Name] ~= nil then
    error("a theme with this name has already been registered")
  end
  sonataEngine.themes[t.Name] = t
end

---@param name string
function sonataEngine:ApplyTheme(name)
  if sonataEngine.themes[name] == nil then
    error("attempted to apply a theme that is not registered")
  end

  local sonataWindow = moonlight:GetSonataWindow()

  local theme = sonataEngine.themes[name]
  local windowTheme = theme.WindowTheme

  if windowTheme ~= nil then
    -- Apply window themes.
    for w in pairs(self.object_Windows) do
      local previousDecoration = w:GetDecoration()
      if previousDecoration ~= nil then
        previousDecoration:Release()
      end
  
      local d = sonataWindow:New(name)
      d:SetTitle(windowTheme.TitleDecoration)
      d:SetBackground(windowTheme.BackgroundDecoration)
      d:SetBorder(windowTheme.BorderDecoration)
      d:SetCloseButton(windowTheme.CloseButtonDecoration)
      d:SetHandle(windowTheme.HandleDecoration)
      d:SetInsets(windowTheme.Inset)
  
      d:Apply(w)
    end
  end
end