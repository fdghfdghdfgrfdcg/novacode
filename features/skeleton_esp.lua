local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Module = {}
Module.Name = "Skeleton ESP"
Module.Enabled = false

local settings = {
    colorInnocent = Color3.fromRGB(255, 255, 255),
    colorMurderer = Color3.fromRGB(255, 60, 60),
    colorSheriff  = Color3.fromRGB(60, 130, 255),
    thickness = 2,
    headOffset = 0.72
}

local R15_BONES = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local function getRole(plr)
    local char = plr.Character
    if not char then return "Innocent" end

    local function hasItem(name)
        if char:FindFirstChild(name) then return true end
        local bp = plr:FindFirstChildOfClass("Backpack")
        if bp and bp:FindFirstChild(name) then return true end
        return false
    end

    if hasItem("Knife") then
        return "Murderer"
    elseif hasItem("Gun") then
        return "Sheriff"
    else
        return "Innocent"
    end
end

local function getRoleColor(plr)
    local role = getRole(plr)
    if role == "Murderer" then
        return settings.colorMurderer
    elseif role == "Sheriff" then
        return settings.colorSheriff
    else
        return settings.colorInnocent
    end
end

local function getR6Bones(char)
    local head = char:FindFirstChild("Head")
    local torso = char:FindFirstChild("Torso")
    local lArm = char:FindFirstChild("Left Arm")
    local rArm = char:FindFirstChild("Right Arm")
    local lLeg = char:FindFirstChild("Left Leg")
    local rLeg = char:FindFirstChild("Right Leg")

    if not (head and torso and lArm and rArm and lLeg and rLeg) then
        return nil
    end

    local neck = torso.CFrame * Vector3.new(0, 0.8, 0)
    local hip = torso.CFrame * Vector3.new(0, -0.8, 0)

    local lShoulder = lArm.CFrame * Vector3.new(0, 0.8, 0)
    local lElbow = lArm.Position
    local lHand = lArm.CFrame * Vector3.new(0, -0.8, 0)

    local rShoulder = rArm.CFrame * Vector3.new(0, 0.8, 0)
    local rElbow = rArm.Position
    local rHand = rArm.CFrame * Vector3.new(0, -0.8, 0)

    local lHip = lLeg.CFrame * Vector3.new(0, 0.8, 0)
    local lKnee = lLeg.Position
    local lFoot = lLeg.CFrame * Vector3.new(0, -0.8, 0)

    local rHip = rLeg.CFrame * Vector3.new(0, 0.8, 0)
    local rKnee = rLeg.Position
    local rFoot = rLeg.CFrame * Vector3.new(0, -0.8, 0)

    return {
        {from = head.Position, to = neck, isHead = true},
        {from = neck, to = hip, isHead = false},

        {from = neck, to = lShoulder, isHead = false},
        {from = lShoulder, to = lElbow, isHead = false},
        {from = lElbow, to = lHand, isHead = false},

        {from = neck, to = rShoulder, isHead = false},
        {from = rShoulder, to = rElbow, isHead = false},
        {from = rElbow, to = rHand, isHead = false},

        {from = hip, to = lHip, isHead = false},
        {from = lHip, to = lKnee, isHead = false},
        {from = lKnee, to = lFoot, isHead = false},

        {from = hip, to = rHip, isHead = false},
        {from = rHip, to = rKnee, isHead = false},
        {from = rKnee, to = rFoot, isHead = false}
    }
end

local function getR15Bones(char)
    local bones = {}
    for _, pair in ipairs(R15_BONES) do
        local p1 = char:FindFirstChild(pair[1])
        local p2 = char:FindFirstChild(pair[2])
        if p1 and p2 then
            table.insert(bones, {
                from = p1.Position,
                to = p2.Position,
                isHead = (pair[1] == "Head")
            })
        else
            return nil
        end
    end
    return bones
end

local cache = {}

local function removeESP(plr)
    local data = cache[plr]
    if not data then return end
    for _, line in ipairs(data.lines) do
        line:Remove()
    end
    data.circle:Remove()
    cache[plr] = nil
end

local function createESP(plr, char)
    removeESP(plr)

    local circle = Drawing.new("Circle")
    circle.Thickness = settings.thickness
    circle.Color = settings.colorInnocent
    circle.Filled = false
    circle.NumSides = 20
    circle.Transparency = 1
    circle.Visible = false

    local lines = {}
    for i = 1, 14 do
        local line = Drawing.new("Line")
        line.Thickness = settings.thickness
        line.Color = settings.colorInnocent
        line.Transparency = 1
        line.Visible = false
        lines[i] = line
    end

    cache[plr] = {
        char = char,
        lines = lines,
        circle = circle
    }
end

RunService.RenderStepped:Connect(function()
    if not Module.Enabled then
        for _, data in pairs(cache) do
            data.circle.Visible = false
            for _, l in ipairs(data.lines) do
                l.Visible = false
            end
        end
        return
    end

    for _, data in pairs(cache) do
        data.circle.Visible = false
        for _, l in ipairs(data.lines) do
            l.Visible = false
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local head = char and char:FindFirstChild("Head")

            if char and hum and hum.Health > 0 and head then
                local data = cache[plr]
                if not data or data.char ~= char then
                    createESP(plr, char)
                    data = cache[plr]
                end

                local roleColor = getRoleColor(plr)
                data.circle.Color = roleColor
                for _, l in ipairs(data.lines) do
                    l.Color = roleColor
                end

                local headPos, vis = Camera:WorldToViewportPoint(head.Position)

                if vis and headPos.Z > 0 then
                    local top = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, head.Size.Y / 2, 0))
                    local bot = Camera:WorldToViewportPoint(head.Position - Vector3.new(0, head.Size.Y / 2, 0))
                    local radius = math.max(math.abs(top.Y - bot.Y) / 2, 2)

                    data.circle.Position = Vector2.new(headPos.X, headPos.Y)
                    data.circle.Radius = radius
                    data.circle.Visible = true

                    local isR15 = char:FindFirstChild("UpperTorso") ~= nil
                    local segments = isR15 and getR15Bones(char) or getR6Bones(char)

                    if segments then
                        for i, seg in ipairs(segments) do
                            local line = data.lines[i]
                            if not line then break end

                            local p1, v1 = Camera:WorldToViewportPoint(seg.from)
                            local p2, v2 = Camera:WorldToViewportPoint(seg.to)

                            if v1 and v2 and p1.Z > 0 and p2.Z > 0 then
                                local from = Vector2.new(p1.X, p1.Y)
                                local to = Vector2.new(p2.X, p2.Y)

                                if seg.isHead then
                                    local dir = to - from
                                    local dist = dir.Magnitude
                                    local offset = radius * settings.headOffset

                                    if dist > offset then
                                        from = from + (dir / dist) * offset
                                    else
                                        line.Visible = false
                                        continue
                                    end
                                end

                                line.From = from
                                line.To = to
                                line.Visible = true
                            end
                        end
                    end
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(removeESP)

function Module.SetEnabled(state)
    Module.Enabled = state
    if not state then
        for _, data in pairs(cache) do
            data.circle.Visible = false
            for _, l in ipairs(data.lines) do
                l.Visible = false
            end
        end
    end
end

function Module.Toggle()
    Module.SetEnabled(not Module.Enabled)
    return Module.Enabled
end

_G.SkeletonESP = Module

return Module
