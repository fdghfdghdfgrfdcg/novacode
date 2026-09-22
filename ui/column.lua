local TweenService = game:GetService("TweenService")

return function(Main, COLORS, Round, title, x, items, callbacks)

    local COLUMN_WIDTH = 158
    local COLUMN_HEIGHT = 365

    local Column = Instance.new("Frame")

    Column.Parent = Main
    Column.Size = UDim2.fromOffset(COLUMN_WIDTH, COLUMN_HEIGHT)
    Column.Position = UDim2.fromOffset(x, 25)

    Column.BackgroundColor3 = COLORS.Panel
    Column.BackgroundTransparency = 0.08
    Column.BorderSizePixel = 0

    Round(Column, 13)

    local Stroke = Instance.new("UIStroke")
    Stroke.Parent = Column
    Stroke.Color = Color3.fromRGB(55, 56, 70)
    Stroke.Transparency = 0.55
    Stroke.Thickness = 1

    -- HEADER

    local Header = Instance.new("TextLabel")
    Header.Parent = Column
    Header.Size = UDim2.new(1, 0, 0, 38)
    Header.Position = UDim2.fromOffset(0, 3)
    Header.BackgroundTransparency = 1
    Header.Text = title
    Header.TextColor3 = COLORS.Text
    Header.TextSize = 14
    Header.Font = Enum.Font.GothamBold

    -- LIST

    local List = Instance.new("Frame")
    List.Parent = Column
    List.Position = UDim2.fromOffset(7, 42)
    List.Size = UDim2.new(1, -14, 1, -49)
    List.BackgroundTransparency = 1

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = List
    Layout.Padding = UDim.new(0, 3)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- ITEMS

    for index, item in ipairs(items) do

        local Row = Instance.new("TextButton")
        Row.Parent = List
        Row.Size = UDim2.new(1, 0, 0, 24)
        Row.BackgroundColor3 = COLORS.Row
        Row.BackgroundTransparency = 0.15
        Row.BorderSizePixel = 0
        Row.Text = ""
        Row.AutoButtonColor = false

        Round(Row, 5)

        local Text = Instance.new("TextLabel")
        Text.Parent = Row
        Text.Position = UDim2.fromOffset(9, 0)
        Text.Size = UDim2.new(1, -35, 1, 0)
        Text.BackgroundTransparency = 1
        Text.Text = item
        Text.TextColor3 = COLORS.SubText
        Text.TextSize = 11
        Text.Font = Enum.Font.GothamMedium
        Text.TextXAlignment = Enum.TextXAlignment.Left

        local Dots = Instance.new("TextLabel")
        Dots.Parent = Row
        Dots.Position = UDim2.new(1, -27, 0, 0)
        Dots.Size = UDim2.fromOffset(22, 24)
        Dots.BackgroundTransparency = 1
        Dots.Text = "•••"
        Dots.TextColor3 = COLORS.Muted
        Dots.TextSize = 8
        Dots.Font = Enum.Font.GothamBold

        -- HOVER

        Row.MouseEnter:Connect(function()
            if Row:GetAttribute("Active") then return end

            TweenService:Create(
                Row,
                TweenInfo.new(.12),
                { BackgroundColor3 = COLORS.RowHover }
            ):Play()

            TweenService:Create(
                Text,
                TweenInfo.new(.12),
                { TextColor3 = COLORS.Text }
            ):Play()
        end)

        Row.MouseLeave:Connect(function()
            if Row:GetAttribute("Active") then return end

            TweenService:Create(
                Row,
                TweenInfo.new(.12),
                { BackgroundColor3 = COLORS.Row }
            ):Play()

            TweenService:Create(
                Text,
                TweenInfo.new(.12),
                { TextColor3 = COLORS.SubText }
            ):Play()
        end)

        -- CLICK

        Row.MouseButton1Click:Connect(function()
            if callbacks and callbacks[item] then
                callbacks[item](Row, Text)
            end
        end)

    end

    return Column
end
