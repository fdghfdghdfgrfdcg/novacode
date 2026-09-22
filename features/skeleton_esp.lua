local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local Module = {}
Module.Name = "Skeleton ESP"
Module.Enabled = false

-- ... весь код ESP ...

function Module.Toggle()
    Module.Enabled = not Module.Enabled
    return Module.Enabled
end

-- Регистрируем себя в общий реестр
_G.NOVA_Features = _G.NOVA_Features or {}
_G.NOVA_Features[Module.Name] = Module

return Module
