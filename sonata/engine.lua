local moonlight = GetMoonlight()

--- Describe in a comment what this module does. Note the lower case starting letter -- this denotes a module package accessor.
---@class sonataEngine
---@field object_Windows table<Window, boolean>
---@field object_Bags table<Bag, boolean>
---@field themes table<string, Theme>
---@field currentTheme string
local sonataEngine = moonlight:NewClass("sonataEngine")

---@type table<Window, boolean>
sonataEngine.object_Windows = {}

---@type table<Bag, boolean>
sonataEngine.object_Bags = {}

---@type table<string, Theme>
sonataEngine.themes = {}

---@param w Window
function sonataEngine:RegisterWindow(w)
  if self.object_Windows[w] == true then
    error("attempt to register a window in sonata twice")
  end
  self.object_Windows[w] = true
  if self.currentTheme ~= nil then
    self:ApplyToWindow(w, self.themes[self.currentTheme])
  end
end

---@param b Bag
function sonataEngine:RegisterBag(b)
  if self.object_Bags[b] == true then
    error("attempt to register a bag in sonata twice")
  end
  self.object_Bags[b] = true
  if self.currentTheme ~= nil then
    self:ApplyToBag(b, self.themes[self.currentTheme])
  end
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

  local theme = sonataEngine.themes[name]

  if theme.WindowTheme ~= nil then
    -- Apply window themes.
    for w in pairs(self.object_Windows) do
      self:ApplyToWindow(w, theme)
    end
  end

  if theme.BagTheme ~= nil then
    for b in pairs(self.object_Bags) do
      self:ApplyToBag(b, theme)
    end
  end
  self.currentTheme = name
end

---@param w Window
---@param theme Theme
function sonataEngine:ApplyToWindow(w, theme)
  if theme.WindowTheme == nil then
    return
  end
  local sonataWindow = moonlight:GetSonataWindow()
  local previousDecoration = w:GetDecoration()
  if previousDecoration ~= nil then
    previousDecoration:Release()
  end
  
  local d = sonataWindow:New(theme.Name)
  d:SetTitle(theme.WindowTheme.TitleDecoration)
  d:SetBackground(theme.WindowTheme.BackgroundDecoration)
  d:SetBorder(theme.WindowTheme.BorderDecoration)
  d:SetCloseButton(theme.WindowTheme.CloseButtonDecoration)
  d:SetHandle(theme.WindowTheme.HandleDecoration)
  d:SetInsets(theme.WindowTheme.Inset)
  
  d:Apply(w)
end

---@param b Bag
---@param theme Theme
function sonataEngine:ApplyToBag(b, theme)
  if theme.BagTheme == nil then
    return
  end
  local w = b:GetWindow()
  local sonataWindow = moonlight:GetSonataWindow()
  local previousDecoration = w:GetDecoration()
  if previousDecoration ~= nil then
    previousDecoration:Release()
  end
  
  local d = sonataWindow:New(theme.Name)
  d:SetTitle(theme.BagTheme.TitleDecoration)
  d:SetBackground(theme.BagTheme.BackgroundDecoration)
  d:SetBorder(theme.BagTheme.BorderDecoration)
  d:SetCloseButton(theme.BagTheme.CloseButtonDecoration)
  d:SetInsets(theme.BagTheme.Inset)
  
  d:Apply(w)
end

function sonataEngine:Boot()
  self:ApplyTheme("default")
end