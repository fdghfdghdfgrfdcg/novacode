return function(...)  -- ничего не нужно при загрузке модуля, только при Show
    local Loading = {}

    function Loading.Show(COLORS, Round, TweenService, Player, GUI, Main, callback)
        if callback then callback() end
    end

    return Loading
end
