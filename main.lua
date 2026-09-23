--// NOVA - main.lua (Xeno-совместимый, v2)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local BASE = "https://raw.githubusercontent.com/fdghfdghdfgrfdcg/novacode/main/"

print("[NOVA] === Старт загрузки ===")

local function loadModule(path)
    print("[NOVA] Грузим: " .. path)

    local ok, src = pcall(function()
        return game:HttpGet(BASE .. path)
    end)

    if not ok or not src or #src == 0 then
        warn("[NOVA] Не скачалось: " .. path)
        return nil
    end

    local chunk, err = loadstring(src)
    if not chunk then
        warn("[NOVA] Ошибка компиляции " .. path .. ": " .. tostring(err))
        return nil
    end

    local ok2, mod = pcall(chunk)
    if not ok2 then
        warn("[NOVA] Ошибка выполнения " .. path .. ": " .. tostring(mod))
        return nil
    end

    print("[NOVA]   OK (" .. #src .. " байт)")
    return mod
end

local COLORS       = loadModule("ui/colors.lua")
local CreateColumn = loadModule("ui/column.lua")
local Loading      = loadModule("ui/loading.lua")

loadModule("features/skeleton_esp.lua")

print("[NOVA] COLORS:", COLORS)
print("[NOVA] CreateColumn:", CreateColumn)
print("[NOVA] Loading:", Loading)

if not COLORS or not CreateColumn then
    warn("[NOVA] КРИТИЧНО: не хватает модулей, выходим")
    return
end

--==================================================
-- GUI
--==================================================

local GUI = Instance.new("ScreenGui")
GUI.Name = "NOVA_Menu"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parented = false

if gethui then
    pcall(function()
        GUI.Parent = gethui()
        parented = true
    end)
end

if not parented then
    pcall(function()
        GUI.Parent = game:GetService("CoreGui")
        parented = true
    end)
end

if not parented then
    GUI.Parent = Player:WaitForChild("PlayerGui")
end

print("[NOVA] GUI.Parent =", GUI.Parent)

--==================================================
-- MAIN
--==================================================

local Main = Instance.new("Frame")
Main.Parent = GUI
Main.Size = UDim2.fromOffset(840, 450)
Main.Position = UDim2.new(0.5, -420, 0.5, -225)
Main.BackgroundTransparency = 1
Main.Visible = false

--==================================================
-- DRAG
--==================================================

local DragArea = Instance.new("Frame")
DragArea.Parent = Main
DragArea.Size = UDim2.new(1, 0, 0, 25)
DragArea.BackgroundTransparency = 1

local dragging = false
local dragStart
local startPos

DragArea.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

DragArea.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--==================================================
-- ROUND
--==================================================

local function Round(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
end

--==================================================
-- COLUMNS
--==================================================

local okCol, errCol = pcall(function()
    CreateColumn(Main, COLORS, Round, "Combat", 0, {})
    CreateColumn(Main, COLORS, Round, "Movement", 168, {})
    CreateColumn(Main, COLORS, Round, "Visuals", 336, {
        "Skeleton ESP"
    }, {
        ["Skeleton ESP"] = function(Row, Text)
            local esp = _G.SkeletonESP
            if not esp then return end

            esp.SetEnabled(not esp.Enabled)

            if esp.Enabled then
                Row:SetAttribute("Active", true)
                Row.BackgroundColor3 = COLORS.Accent
                Row.BackgroundTransparency = 0
                Text.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                Row:SetAttribute("Active", false)
                Row.BackgroundColor3 = COLORS.Row
                Row.BackgroundTransparency = 0.15
                Text.TextColor3 = COLORS.SubText
            end
        end
    })
    CreateColumn(Main, COLORS, Round, "Player", 504, {})
    CreateColumn(Main, COLORS, Round, "Miscellaneous", 672, {})
end)

print("[NOVA] Колонки:", okCol, errCol)

--==================================================
-- SEARCH
--==================================================

local Search = Instance.new("TextBox")
Search.Parent = Main
Search.Size = UDim2.fromOffset(160, 32)
Search.Position = UDim2.new(0.5, -80, 1, -45)
Search.BackgroundColor3 = COLORS.Panel
Search.BackgroundTransparency = 0.05
Search.BorderSizePixel = 0
Search.Text = ""
Search.PlaceholderText = "Поиск"
Search.PlaceholderColor3 = COLORS.Muted
Search.TextColor3 = COLORS.Text
Search.TextSize = 11
Search.Font = Enum.Font.Gotham
Search.ClearTextOnFocus = false

Round(Search, 8)

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Parent = Search
SearchStroke.Color = Color3.fromRGB(55, 56, 70)
SearchStroke.Transparency = 0.45

--==================================================
-- LOADING
--==================================================

if Loading and Loading.Show then
    pcall(function()
        Loading.Show(COLORS, Round, TweenService, Player, GUI, Main, function()
            Main.Visible = true
            TweenService:Create(
                Main,
                TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Size = UDim2.fromOffset(840, 450) }
            ):Play()
        end)
    end)
end

-- Жёсткий fallback — если ничего не показало
task.delay(0.5, function()
    if not Main.Visible then
        Main.Visible = true
    end
end)

--==================================================
-- KEYBINDS
--==================================================

local isOpen = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.RightShift then
        isOpen = not isOpen
        for _, child in ipairs(Main:GetChildren()) do
            if child ~= DragArea then
                child.Visible = isOpen
            end
        end
    end

    if input.KeyCode == Enum.KeyCode.Delete then
        GUI:Destroy()
    end
end)

print("[NOVA] Запуск завершён. Main.Visible =", Main.Visible)
