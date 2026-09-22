return function(COLORS, Round, TweenService, Player)
    local Loading = {}

    function Loading.Show(callback)
        -- сюда позже полный код загрузочного экрана
        if callback then callback() end
    end

    return Loading
end
