
--[[
    INFINITE CARNAGE V1
    DELTA / MOBILE / PC
    Single-file GitHub script

    GOJO: Purple Infinity domain
    SUKUNA: Red slashing domain
    BOXING: Cursed Energy Zero
    ALL: Combined domain

    Client-side visual effects only.
    Does not damage or freeze other players.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local env = getgenv and getgenv() or _G

if type(env.CarnageStop) == "function" then
    pcall(env.CarnageStop)
end

local connections = {}
local arena
local running = false
local mode = "ALL"
local target
local elapsed = 0
local effects = {}

local PURPLE = Color3.fromRGB(145, 65, 255)
local RED = Color3.fromRGB(255, 40, 65)
local WHITE = Color3.fromRGB(230, 230, 255)

local function connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(connections, c)
    return c
end

local function make(class, props, parent)
    local obj = Instance.new(class)
    for key, value in pairs(props) do
        obj[key] = value
    end
    obj.Parent = parent
    return obj
end

local function corner(obj)
    make("UICorner", {
        CornerRadius = UDim.new(0, 9)
    }, obj)
end

local old = pg:FindFirstChild("InfiniteCarnage")
if old then old:Destroy() end

local gui = make("ScreenGui", {
    Name = "InfiniteCarnage",
    ResetOnSpawn = false,
    DisplayOrder = 999
}, pg)

local main = make("Frame", {
    Size = UDim2.fromOffset(300, 368),
    Position = UDim2.new(0.5, -150, 0.5, -184),
    BackgroundColor3 = Color3.fromRGB(18, 14, 29),
    BorderSizePixel = 0,
    Active = true,
    Draggable = true
}, gui)
corner(main)

make("UIStroke", {
    Color = PURPLE,
    Thickness = 2
}, main)

make("TextLabel", {
    Size = UDim2.fromOffset(260, 36),
    Position = UDim2.fromOffset(9, 4),
    BackgroundTransparency = 1,
    Text = "DOMAIN: INFINITE CARNAGE",
    TextColor3 = WHITE,
    TextSize = 14,
    Font = Enum.Font.GothamBold
}, main)

local function button(text, x, y, width, height)
    local b = make("TextButton", {
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = Color3.fromRGB(59, 43, 88),
        TextColor3 = WHITE,
        Text = text,
        TextSize = 12,
        Font = Enum.Font.GothamBold
    }, main)
    corner(b)
    return b
end

local close = button("X", 270, 7, 23, 27)

local selector = button(
    "TARGET: SELECT PLAYER", 10, 45, 280, 34
)

local gojo = button("GOJO", 10, 87, 135, 38)
local sukuna = button("SUKUNA", 155, 87, 135, 38)
local boxing = button("MY BOXING", 10, 133, 135, 38)
local all = button("ALL DOMAINS", 155, 133, 135, 38)

local activate = button(
    "EXPAND DOMAIN", 10, 183, 280, 42
)
activate.BackgroundColor3 = Color3.fromRGB(120, 44, 175)

local punch = button("PUNCH", 10, 234, 135, 39)
punch.BackgroundColor3 = Color3.fromRGB(165, 45, 65)

local endButton = button("END DOMAIN", 155, 234, 135, 39)

local status = make("TextLabel", {
    Size = UDim2.fromOffset(280, 43),
    Position = UDim2.fromOffset(10, 283),
    BackgroundTransparency = 1,
    Text = "READY | SELECT A DOMAIN",
    TextColor3 = Color3.fromRGB(204, 180, 255),
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextWrapped = true
}, main)

make("TextLabel", {
    Position = UDim2.fromOffset(10, 337),
    Size = UDim2.fromOffset(280, 18),
    BackgroundTransparency = 1,
    Text = "CLIENT VISUAL DOMAIN | UNLIMITED USE",
    TextColor3 = Color3.fromRGB(147, 140, 168),
    Font = Enum.Font.Gotham,
    TextSize = 9
}, main)

local function getRoot(plr)
    local char = plr and plr.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function part(name, size, cf, color, transparency)
    return make("Part", {
        Name = name,
        Size = size,
        CFrame = cf,
        Color = color,
        Transparency = transparency or 0,
        Material = Enum.Material.Neon,
        Anchored = true,
        CanCollide = false,
        CanTouch = false,
        CanQuery = false,
        CastShadow = false
    }, arena)
end

local function stopDomain()
    running = false
    effects = {}
    elapsed = 0

    if arena then
        arena:Destroy()
        arena = nil
    end

    activate.Text = "EXPAND DOMAIN"

    if gui.Parent then
        status.Text = "DOMAIN ENDED | READY AGAIN"
    end
end

local function makeRing(center, radius, height, color)
    local pieces = 40

    for i = 1, pieces do
        local a = (i - 1) * math.pi * 2 / pieces
        local b = i * math.pi * 2 / pieces

        local p1 = center + Vector3.new(
            math.cos(a) * radius,
            height,
            math.sin(a) * radius
        )

        local p2 = center + Vector3.new(
            math.cos(b) * radius,
            height,
            math.sin(b) * radius
        )

        local midpoint = (p1 + p2) / 2
        local length = (p2 - p1).Magnitude

        part(
            "DomainRing",
            Vector3.new(0.45, 0.45, length),
            CFrame.lookAt(midpoint, p2),
            color,
            0.08
        )
    end
end

local function boxingArena(center)
    local floor = part(
        "BoxingFloor",
        Vector3.new(40, 0.4, 40),
        CFrame.new(center - Vector3.new(0, 3, 0)),
        Color3.fromRGB(25, 25, 38),
        0.16
    )

    floor.Material = Enum.Material.SmoothPlastic

    for _, h in ipairs({-1, 1, 3}) do
        for _, z in ipairs({-16, 16}) do
            part(
                "BoxingRope",
                Vector3.new(33, 0.25, 0.25),
                CFrame.new(center + Vector3.new(0, h, z)),
                RED,
                0
            )
        end

        for _, x in ipairs({-16, 16}) do
            part(
                "BoxingRope",
                Vector3.new(0.25, 0.25, 33),
                CFrame.new(center + Vector3.new(x, h, 0)),
                PURPLE,
                0
            )
        end
    end

    for _, x in ipairs({-16, 16}) do
        for _, z in ipairs({-16, 16}) do
            part(
                "RingPost",
                Vector3.new(1, 8, 1),
                CFrame.new(center + Vector3.new(x, 0, z)),
                WHITE,
                0
            )
        end
    end
end

local function makeOrb(center, color, index)
    local orb = part(
        "OrbitingEnergy",
        Vector3.new(2, 2, 2),
        CFrame.new(center),
        color,
        0.14
    )

    orb.Shape = Enum.PartType.Ball

    table.insert(effects, {
        object = orb,
        index = index,
        center = center,
        style = "orb"
    })
end

local function makeSlash(center, index)
    local slash = part(
        "MalevolentSlash",
        Vector3.new(0.18, 11, 0.7),
        CFrame.new(center),
        RED,
        0.1
    )

    table.insert(effects, {
        object = slash,
        index = index,
        center = center,
        style = "slash"
    })
end

local function expandDomain()
    stopDomain()

    local root = getRoot(player)
    if not root then
        status.Text = "CHARACTER NOT READY"
        return
    end

    local center = root.Position

    arena = Instance.new("Folder")
    arena.Name = "LOCAL_INFINITE_CARNAGE"
    arena.Parent = workspace

    running = true

    local color = PURPLE

    if mode == "SUKUNA" then
        color = RED
    elseif mode == "BOXING" then
        color = WHITE
    end

    makeRing(center, 20, -2.5, color)
    makeRing(center, 20, 8, color)
    makeRing(center, 24, 16, color)

    local isGojo = mode == "GOJO" or mode == "ALL"
    local isSukuna = mode == "SUKUNA" or mode == "ALL"
    local isBoxing = mode == "BOXING" or mode == "ALL"

    if isBoxing then
        boxingArena(center)
    end

    if isGojo then
        for i = 1, 18 do
            makeOrb(center, PURPLE, i)
        end
    end

    if isSukuna then
        for i = 1, 16 do
            makeSlash(center, i)
        end
    end

    activate.Text = "DOMAIN ACTIVE"
    status.Text = mode .. " EXPANSION ACTIVATED!"

    if target and getRoot(target) then
        local highlight = make("Highlight", {
            Name = "DomainTarget",
            FillColor = color,
            OutlineColor = WHITE,
            FillTransparency = 0.75,
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
            Adornee = target.Character
        }, arena)
    end
end

local function choose(newMode)
    mode = newMode
    status.Text = "SELECTED: " .. mode

    for _, b in ipairs({
        gojo, sukuna, boxing, all
    }) do
        b.BackgroundColor3 = Color3.fromRGB(59, 43, 88)
    end

    local chosen = ({
        GOJO = gojo,
        SUKUNA = sukuna,
        BOXING = boxing,
        ALL = all
    })[newMode]

    if chosen then
        chosen.BackgroundColor3 = Color3.fromRGB(145, 47, 175)
    end
end

local targetIndex = 0

local function selectTarget()
    local list = {}

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(list, p)
        end
    end

    table.sort(list, function(a, b)
        return a.Name < b.Name
    end)

    if #list == 0 then
        target = nil
        status.Text = "NO OTHER PLAYERS"
        return
    end

    targetIndex = (targetIndex % #list) + 1
    target = list[targetIndex]

    selector.Text = "TARGET: " .. target.Name
    status.Text = "SELECTED " .. target.Name
end

local lastPunch = 0

local function punchEffect()
    if os.clock() - lastPunch < 0.18 then
        return
    end

    lastPunch = os.clock()

    local root = getRoot(player)
    if not root then return end

    local targetRoot = getRoot(target)

    local startPos = root.Position
        + root.CFrame.LookVector * 3
        + Vector3.new(0, 1, 0)

    local endPos

    if targetRoot
        and (targetRoot.Position - root.Position).Magnitude < 80 then
        endPos = targetRoot.Position
    else
        endPos = startPos + root.CFrame.LookVector * 8
    end

    local orb = Instance.new("Part")
    orb.Name = "LocalPunchImpact"
    orb.Shape = Enum.PartType.Ball
    orb.Size = Vector3.new(1.5, 1.5, 1.5)
    orb.Material = Enum.Material.Neon
    orb.Color = mode == "SUKUNA" and RED or PURPLE
    orb.Anchored = true
    orb.CanCollide = false
    orb.CanTouch = false
    orb.CanQuery = false
    orb.Position = startPos
    orb.Parent = workspace

    local tween = TweenService:Create(
        orb,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad),
        {
            Position = endPos,
            Size = Vector3.new(4, 4, 4),
            Transparency = 1
        }
    )

    tween:Play()
    Debris:AddItem(orb, 0.3)

    if target then
        status.Text = "VISUAL PUNCH: " .. target.Name
    else
        status.Text = "VISUAL PUNCH!"
    end
end

connect(RunService.RenderStepped, function(dt)
    if not running or not arena then return end

    elapsed = elapsed + dt

    for _, effect in ipairs(effects) do
        local obj = effect.object
        if obj and obj.Parent then
            local i = effect.index
            local center = effect.center

            if effect.style == "orb" then
                local angle = elapsed * 0.7
                    + i * math.pi * 2 / 18

                obj.Position = center + Vector3.new(
                    math.cos(angle) * 14,
                    6 + math.sin(elapsed * 2 + i) * 5,
                    math.sin(angle) * 14
                )

            elseif effect.style == "slash" then
                local angle = elapsed * 1.5 + i
                local radius = 5 + i * 0.8

                obj.CFrame = CFrame.new(
                    center + Vector3.new(
                        math.cos(angle) * radius,
                        2 + math.sin(elapsed * 2 + i) * 5,
                        math.sin(angle) * radius
                    )
                ) * CFrame.Angles(
                    angle,
                    angle * 0.6,
                    math.rad(35)
                )
            end
        end
    end
end)

connect(selector.Activated, selectTarget)
connect(gojo.Activated, function()
    choose("GOJO")
end)
connect(sukuna.Activated, function()
    choose("SUKUNA")
end)
connect(boxing.Activated, function()
    choose("BOXING")
end)
connect(all.Activated, function()
    choose("ALL")
end)
connect(activate.Activated, expandDomain)
connect(punch.Activated, punchEffect)
connect(endButton.Activated, stopDomain)

connect(player.CharacterRemoving, stopDomain)

local function cleanup()
    stopDomain()

    for _, c in ipairs(connections) do
        c:Disconnect()
    end

    if gui then
        gui:Destroy()
    end

    if env.CarnageStop == cleanup then
        env.CarnageStop = nil
    end
end

env.CarnageStop = cleanup
connect(close.Activated, cleanup)

choose("ALL")

print("INFINITE CARNAGE DELTA LOADED")
