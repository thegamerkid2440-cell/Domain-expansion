
--[[
    INFINITE CARNAGE V3
    FULL DOMAIN EXPANSION HUB

    REPOSITORY:
    thegamerkid2440-cell/Domain-expansion

    FILES:
    gojo.lua
    sukuna.lua
    mydomain.lua
    all.lua
    combine.lua

    PLATFORM: Delta / Mobile / PC
    CLIENT-SIDE VISUAL EFFECTS
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")
local env = getgenv and getgenv() or _G

-- CLEAN UP PREVIOUS VERSION

if type(env.CarnageV3Stop) == "function" then
    pcall(env.CarnageV3Stop)
end

-- YOUR NEW GITHUB REPOSITORY

local BASE =
    "https://raw.githubusercontent.com/" ..
    "thegamerkid2440-cell/" ..
    "Domain-expansion/main/"

local URLS = {
    GOJO = BASE .. "gojo.lua",
    SUKUNA = BASE .. "sukuna.lua",
    BOXING = BASE .. "mydomain.lua",
    ALL = BASE .. "all.lua"
}

local modules = {}
local errors = {}

-- LOAD ALL FOUR FILES

for name, url in pairs(URLS) do
    local success, result = pcall(function()
        local source = game:HttpGet(url)

        local compiled, compileError = loadstring(source)
        assert(compiled, compileError or "Compilation failed")

        local module = compiled()
        assert(type(module) == "function", "Module must return a function")

        return module
    end)

    if success then
        modules[name] = result
        print("LOADED DOMAIN:", name)
    else
        errors[#errors + 1] = name
        warn("FAILED DOMAIN:", name, result)
    end
end

-- STATE

local connections = {}
local effects = {}
local arena = nil

local running = false
local selectedMode = "ALL"
local selectedTarget = nil
local targetIndex = 0
local elapsed = 0
local lastPunch = 0
local destroyed = false

-- HELPERS

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    connections[#connections + 1] = connection
    return connection
end

local function create(class, properties, parent)
    local object = Instance.new(class)

    for key, value in pairs(properties) do
        object[key] = value
    end

    object.Parent = parent
    return object
end

local function round(object)
    create("UICorner", {
        CornerRadius = UDim.new(0, 9)
    }, object)
end

local function getRoot(targetPlayer)
    local character = targetPlayer and targetPlayer.Character

    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
end

-- GUI

local existing = pg:FindFirstChild("InfiniteCarnageV3")

if existing then
    existing:Destroy()
end

local gui = create("ScreenGui", {
    Name = "InfiniteCarnageV3",
    ResetOnSpawn = false,
    DisplayOrder = 999
}, pg)

local main = create("Frame", {
    Size = UDim2.fromOffset(300, 365),
    Position = UDim2.new(0.5, -150, 0.5, -182),
    BackgroundColor3 = Color3.fromRGB(18, 13, 30),
    BorderSizePixel = 0,
    Active = true,
    Draggable = true
}, gui)

round(main)

create("UIStroke", {
    Color = Color3.fromRGB(160, 70, 255),
    Thickness = 2
}, main)

create("TextLabel", {
    Position = UDim2.fromOffset(10, 5),
    Size = UDim2.fromOffset(245, 34),
    BackgroundTransparency = 1,
    Text = "INFINITE CARNAGE V3",
    TextColor3 = Color3.fromRGB(220, 185, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 16
}, main)

local function button(text, x, y, width, height)
    local object = create("TextButton", {
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = Color3.fromRGB(67, 42, 105),
        TextColor3 = Color3.new(1, 1, 1),
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 12
    }, main)

    round(object)
    return object
end

local close = button("X", 262, 7, 29, 28)

local selector = button(
    "SELECT PLAYER",
    10, 45, 280, 35
)

local gojoButton = button(
    "GOJO",
    10, 89, 135, 35
)

local sukunaButton = button(
    "SUKUNA",
    155, 89, 135, 35
)

local boxingButton = button(
    "MY BOXING DOMAIN",
    10, 133, 135, 35
)

local allButton = button(
    "ALL COMBINED",
    155, 133, 135, 35
)

local expandButton = button(
    "EXPAND DOMAIN",
    10, 180, 280, 40
)

expandButton.BackgroundColor3 =
    Color3.fromRGB(145, 40, 175)

local punchButton = button(
    "PUNCH",
    10, 230, 135, 39
)

punchButton.BackgroundColor3 =
    Color3.fromRGB(175, 42, 65)

local endButton = button(
    "END DOMAIN",
    155, 230, 135, 39
)

local status = create("TextLabel", {
    Position = UDim2.fromOffset(10, 282),
    Size = UDim2.fromOffset(280, 48),
    BackgroundTransparency = 1,
    Text = "LOADING...",
    TextColor3 = Color3.fromRGB(215, 190, 255),
    TextSize = 11,
    TextWrapped = true,
    Font = Enum.Font.Gotham
}, main)

create("TextLabel", {
    Position = UDim2.fromOffset(10, 338),
    Size = UDim2.fromOffset(280, 18),
    BackgroundTransparency = 1,
    Text = "UNLIMITED VISUAL DOMAIN ACTIVATIONS",
    TextColor3 = Color3.fromRGB(150, 139, 175),
    TextSize = 9
}, main)

-- DOMAIN STOP

local function stopDomain()
    running = false
    elapsed = 0
    table.clear(effects)

    if arena then
        arena:Destroy()
        arena = nil
    end

    if not destroyed and gui.Parent then
        expandButton.Text = "EXPAND DOMAIN"
        status.Text = "DOMAIN ENDED | READY AGAIN"
    end
end

-- CONTEXT FOR ALL MODULES

local function createContext(center)
    local ctx = {}

    ctx.center = center
    ctx.target = selectedTarget

    function ctx.part(name, size, cf, color, transparency)
        assert(arena, "Domain arena unavailable")

        return create("Part", {
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

    function ctx.effect(callback)
        if type(callback) == "function" then
            effects[#effects + 1] = callback
        end
    end

    function ctx.message(message)
        if gui.Parent then
            status.Text = tostring(message)
        end
    end

    function ctx.run(domainName)
        local module = modules[domainName]

        assert(
            type(module) == "function",
            "Domain unavailable: " .. tostring(domainName)
        )

        module(ctx)
    end

    return ctx
end

-- DOMAIN EXPANSION

local function expandDomain()
    if destroyed then
        return
    end

    if not modules[selectedMode] then
        status.Text = "MISSING MODULE: " .. selectedMode
        return
    end

    local root = getRoot(player)

    if not root then
        status.Text = "CHARACTER NOT READY"
        return
    end

    stopDomain()

    arena = Instance.new("Folder")
    arena.Name = "LocalInfiniteCarnage"
    arena.Parent = workspace

    running = true

    local center = root.Position
    local ctx = createContext(center)

    local success, errorMessage = pcall(function()
        ctx.run(selectedMode)

        if selectedTarget and selectedTarget.Character then
            create("Highlight", {
                Name = "SelectedDomainTarget",
                Adornee = selectedTarget.Character,
                FillColor = Color3.fromRGB(180, 60, 255),
                OutlineColor = Color3.new(1, 1, 1),
                FillTransparency = 0.75,
                DepthMode =
                    Enum.HighlightDepthMode.AlwaysOnTop
            }, arena)
        end
    end)

    if not success then
        stopDomain()

        status.Text =
            "DOMAIN FAILED: " ..
            tostring(errorMessage):sub(1, 90)

        return
    end

    expandButton.Text = "DOMAIN ACTIVE"
end

-- DOMAIN SELECTION

local modeButtons = {
    GOJO = gojoButton,
    SUKUNA = sukunaButton,
    BOXING = boxingButton,
    ALL = allButton
}

local function chooseMode(newMode)
    selectedMode = newMode

    for _, object in pairs(modeButtons) do
        object.BackgroundColor3 =
            Color3.fromRGB(67, 42, 105)
    end

    modeButtons[newMode].BackgroundColor3 =
        Color3.fromRGB(155, 50, 190)

    status.Text = "SELECTED: " .. newMode
end

-- PLAYER SELECTION

local function selectPlayer()
    local available = {}

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            available[#available + 1] = other
        end
    end

    table.sort(available, function(a, b)
        return a.Name < b.Name
    end)

    if #available == 0 then
        selectedTarget = nil
        selector.Text = "NO OTHER PLAYERS"
        status.Text = "NO TARGET AVAILABLE"
        return
    end

    targetIndex = (targetIndex % #available) + 1
    selectedTarget = available[targetIndex]

    selector.Text = "TARGET: " .. selectedTarget.Name
    status.Text = "TARGET SELECTED"
end

-- PUNCH VISUAL

local function punchEffect()
    if not running then
        status.Text = "EXPAND A DOMAIN FIRST"
        return
    end

    if os.clock() - lastPunch < 0.2 then
        return
    end

    lastPunch = os.clock()

    local root = getRoot(player)

    if not root then
        return
    end

    local startPosition =
        root.Position +
        root.CFrame.LookVector * 4 +
        Vector3.new(0, 1, 0)

    local endPosition =
        startPosition + root.CFrame.LookVector * 8

    local targetRoot = getRoot(selectedTarget)

    if targetRoot and
        (targetRoot.Position - root.Position).Magnitude <= 60 then
        endPosition = targetRoot.Position
    end

    local color = Color3.fromRGB(170, 65, 255)

    if selectedMode == "SUKUNA" then
        color = Color3.fromRGB(255, 40, 70)
    elseif selectedMode == "BOXING" then
        color = Color3.fromRGB(245, 245, 255)
    end

    local impact = create("Part", {
        Name = "LocalCarnagePunch",
        Shape = Enum.PartType.Ball,
        Size = Vector3.new(1.5, 1.5, 1.5),
        Position = startPosition,
        Material = Enum.Material.Neon,
        Color = color,
        Transparency = 0,
        Anchored = true,
        CanCollide = false,
        CanTouch = false,
        CanQuery = false
    }, workspace)

    TweenService:Create(
        impact,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad),
        {
            Position = endPosition,
            Transparency = 1,
            Size = Vector3.new(4, 4, 4)
        }
    ):Play()

    Debris:AddItem(impact, 0.3)

    status.Text = "PUNCH IMPACT!"
end

-- ANIMATION ENGINE

connect(RunService.RenderStepped, function(dt)
    if not running or not arena then
        return
    end

    elapsed += dt

    for _, update in ipairs(effects) do
        local ok, err = pcall(update, elapsed)

        if not ok then
            warn("Domain animation error:", err)
        end
    end
end)

-- BUTTON EVENTS

connect(selector.Activated, selectPlayer)

connect(gojoButton.Activated, function()
    chooseMode("GOJO")
end)

connect(sukunaButton.Activated, function()
    chooseMode("SUKUNA")
end)

connect(boxingButton.Activated, function()
    chooseMode("BOXING")
end)

connect(allButton.Activated, function()
    chooseMode("ALL")
end)

connect(expandButton.Activated, expandDomain)
connect(punchButton.Activated, punchEffect)
connect(endButton.Activated, stopDomain)

connect(player.CharacterRemoving, stopDomain)

-- FULL CLEANUP

local function cleanup()
    if destroyed then
        return
    end

    destroyed = true
    stopDomain()

    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end

    table.clear(connections)

    gui:Destroy()

    if env.CarnageV3Stop == cleanup then
        env.CarnageV3Stop = nil
    end
end

env.CarnageV3Stop = cleanup

connect(close.Activated, cleanup)

-- STARTUP

chooseMode("ALL")

if #errors == 0 then
    status.Text = "ALL FOUR DOMAINS LOADED!"
else
    status.Text =
        "MISSING MODULES: " ..
        table.concat(errors, ", ")
end

print("INFINITE CARNAGE V3 READY")
