return function()
    local Loading = {}

    function Loading.Show(COLORS, Round, TweenService, Player, GUI, Main, callback)
        -- Пока пустышка: сразу запускаем callback
        if callback then callback() end
    end

    return Loading
end
