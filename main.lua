--// NOVA - main.lua (ДИАГНОСТИКА)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local BASE = "https://cdn.jsdelivr.net/gh/fdghfdghdfgrfdcg/novacode@main/"

print("[NOVA] === СТАРТ ===")

local function loadModule(path)
    print("[NOVA] Грузим: " .. path)
    local src = game:HttpGet(BASE .. path)
    print("[NOVA]   скачано, " .. #src .. " байт")

    local chunk, err = loadstring(src)
    if not chunk then
        warn("[NOVA]   ошибка компиляции: " .. tostring(err))
        return nil
    end

    local ok, mod = pcall(chunk)
    if not ok then
        warn("[NOVA]   ошибка выполнения: " .. tostring(mod))
        return nil
    end

    print("[NOVA]   OK")
    return mod
end

local COLORS       = loadModule("ui/colors.lua")
local CreateColumn = loadModule("ui/column.lua")
local Loading      = loadModule("ui/loading.lua")

loadModule("features/skeleton_esp.lua")

print("[NOVA] COLORS:", COLORS)
print("[NOVA] CreateColumn:", CreateColumn)
print("[NOVA] Loading:", Loading)
print("[NOVA] SkeletonESP:", _G.SkeletonESP)

if not COLORS or not CreateColumn or not Loading then
    warn("[NOVA] КРИТИЧНО: модули не загрузились, выходим")
    return
end

print("[NOVA] Создаём ScreenGui...")

local GUI = Instance.new("ScreenGui")
GUI.Name = "NOVA_Menu"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true

local ok, err = pcall(function() GUI.Parent = gethui() end)
print("[NOVA] gethui(): ", ok, err)

if not GUI.Parent then
    GUI.Parent = Player:WaitForChild("PlayerGui")
    print("[NOVA] Fallback на PlayerGui")
end

print("[NOVA] GUI.Parent =", GUI.Parent)

print("[NOVA] Создаём Main...")

local Main = Instance.new("Frame")
Main.Parent = GUI
Main.Size = UDim2.fromOffset(840, 450)
Main.Position = UDim2.new(0.5, -420, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 40)  -- временно видимый!
Main.BackgroundTransparency = 0                    -- временно видимый!
Main.Visible = true                                -- временно видимый!

print("[NOVA] Main создан. Visible =", Main.Visible, "Size =", Main.Size)

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

local function Round(obj, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = obj
end

print("[NOVA] Создаём колонки...")

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

print("[NOVA] Создаём Search...")

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

print("[NOVA] Search создан")

print("[NOVA] Вызываем Loading.Show...")

local okLoad, errLoad = pcall(function()
    Loading.Show(COLORS, Round, TweenService, Player, GUI, Main, function()
        print("[NOVA] Callback загрузки сработал — показываем меню")
        Main.Visible = true
    end)
end)

print("[NOVA] Loading.Show:", okLoad, errLoad)

print("[NOVA] Main.Visible =", Main.Visible)
print("[NOVA] Main.Parent =", Main.Parent)
print("[NOVA] GUI.Parent =", GUI.Parent)
print("[NOVA] Main.AbsoluteSize =", Main.AbsoluteSize)
print("[NOVA] Main.AbsolutePosition =", Main.AbsolutePosition)

print("[NOVA] === ГОТОВО ===")

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
