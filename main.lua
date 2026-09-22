local BASE = "https://cdn.jsdelivr.net/gh/fdghfdghdfgrfdcg/novacode@main/"

local function loadModule(path)
    local src = game:HttpGet(BASE .. path)
    local chunk = loadstring(src)
    if not chunk then
        error("Не удалось загрузить: " .. path)
    end
    return chunk()
end

-- Загружаем модули
local COLORS       = loadModule("ui/colors.lua")
local CreateColumn = loadModule("ui/column.lua")
local Loading      = loadModule("ui/loading.lua")

-- Функции
loadModule("features/skeleton_esp.lua")

-- Дальше — построение меню (Main, DragArea, колонки, поиск и т.д.)
