-- PlayerESP.lua | Luau, Roblox client, executor script
-- Boxes, names, distance, health bars, tracers and chams on other players.
-- Toggle: RightShift. Live tuning: getgenv().PlayerESP.Config.<Option> = value
-- Unload: getgenv().PlayerESP.Destroy()

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local env = (getgenv and getgenv()) or _G

if env.PlayerESP and env.PlayerESP.Destroy then
    pcall(env.PlayerESP.Destroy)
end

local Config = {
    Enabled = true,
    ToggleKey = Enum.KeyCode.RightShift,
    TeamCheck = true,
    MaxDistance = 2500,
    Box = true,
    Name = true,
    Distance = true,
    Health = true,
    Tracers = true,
    TracerOrigin = "Bottom", -- "Bottom" | "Center" | "Mouse"
    Chams = true,
    ChamFillTransparency = 0.6,
    ChamOutlineTransparency = 0,
    VisibleCheck = true,
    VisibleColor = Color3.fromRGB(80, 255, 140),
    HiddenColor = Color3.fromRGB(255, 80, 110),
    TeamColor = Color3.fromRGB(90, 170, 255),
}

local BLACK = Color3.new(0, 0, 0)
local WHITE = Color3.new(1, 1, 1)
local TOP_OFFSET = Vector3.new(0, 2.9, 0)
local BOTTOM_OFFSET = Vector3.new(0, 3.1, 0)
local BOX_ASPECT = 0.55

local gui = Instance.new("ScreenGui")
gui.Name = "PlayerESP"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local function mount(g)
    if gethui then
        local ok = pcall(function() g.Parent = gethui() end)
        if ok and g.Parent then return end
    end
    local ok = pcall(function() g.Parent = game:GetService("CoreGui") end)
    if ok and g.Parent then return end
    g.Parent = LocalPlayer:WaitForChild("PlayerGui")
end
mount(gui)

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local entries = {}
local connections = {}

local function make(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    inst.Parent = parent
    return inst
end

local function addStroke(parent, color, thickness)
    return make("UIStroke", { Color = color, Thickness = thickness }, parent)
end

local function makeText(parent, size)
    return make("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = size,
        TextColor3 = WHITE,
        TextStrokeColor3 = BLACK,
        TextStrokeTransparency = 0,
        Size = UDim2.fromOffset(200, size + 2),
        Visible = false,
    }, parent)
end

local function createEntry(player)
    local root = make("Frame", {
        Name = player.Name,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
    }, gui)

    local outline = make("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false }, root)
    addStroke(outline, BLACK, 3)
    local box = make("Frame", { BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false }, root)
    local boxStroke = addStroke(box, WHITE, 1)

    local name = makeText(root, 13)
    name.AnchorPoint = Vector2.new(0.5, 1)
    name.Text = player.DisplayName

    local dist = makeText(root, 12)
    dist.AnchorPoint = Vector2.new(0.5, 0)

    local hpBg = make("Frame", { BackgroundColor3 = BLACK, BorderSizePixel = 0, Visible = false }, root)
    local hpFill = make("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(2, 0),
    }, hpBg)

    local tracer = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0,
        Visible = false,
    }, root)

    local cham = make("Highlight", {
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        Enabled = false,
    }, gui)

    entries[player] = {
        root = root, outline = outline, box = box, boxStroke = boxStroke,
        name = name, dist = dist, hpBg = hpBg, hpFill = hpFill,
        tracer = tracer, cham = cham,
    }
end

local function removeEntry(player)
    local e = entries[player]
    if not e then return end
    e.root:Destroy()
    e.cham:Destroy()
    entries[player] = nil
end

local function sameTeam(player)
    local mine = LocalPlayer.Team
    return mine ~= nil and player.Team == mine
end

local function isVisible(origin, targetPos, char)
    local hit = Workspace:Raycast(origin, targetPos - origin, rayParams)
    return hit == nil or hit.Instance:IsDescendantOf(char)
end

local function setLine(frame, a, b)
    local d = b - a
    frame.Size = UDim2.fromOffset(d.Magnitude, 1)
    frame.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
    frame.Rotation = math.deg(math.atan2(d.Y, d.X))
end

local function hideEntry(e)
    e.root.Visible = false
    e.cham.Enabled = false
end

local function updateEntry(player, e, cam, camPos, tracerFrom)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not (Config.Enabled and hum and hrp and hum.Health > 0) then
        return hideEntry(e)
    end

    local mate = sameTeam(player)
    local distance = (hrp.Position - camPos).Magnitude
    if distance > Config.MaxDistance or (Config.TeamCheck and mate) then
        return hideEntry(e)
    end

    local color
    if mate then
        color = Config.TeamColor
    else
        local head = char:FindFirstChild("Head") or hrp
        local seen = not Config.VisibleCheck or isVisible(camPos, head.Position, char)
        color = seen and Config.VisibleColor or Config.HiddenColor
    end

    local cham = e.cham
    if cham.Adornee ~= char then cham.Adornee = char end
    cham.FillColor = color
    cham.OutlineColor = color
    cham.FillTransparency = Config.ChamFillTransparency
    cham.OutlineTransparency = Config.ChamOutlineTransparency
    cham.Enabled = Config.Chams

    local center = cam:WorldToViewportPoint(hrp.Position)
    if center.Z <= 0 then
        e.root.Visible = false
        return
    end
    local top = cam:WorldToViewportPoint(hrp.Position + TOP_OFFSET)
    local bottom = cam:WorldToViewportPoint(hrp.Position - BOTTOM_OFFSET)

    local h = math.floor(math.max(bottom.Y - top.Y, 4) + 0.5)
    local w = math.floor(h * BOX_ASPECT + 0.5)
    local x = math.floor(center.X - w / 2 + 0.5)
    local y = math.floor(top.Y + 0.5)

    e.root.Visible = true

    local boxPos, boxSize = UDim2.fromOffset(x, y), UDim2.fromOffset(w, h)
    e.outline.Visible = Config.Box
    e.outline.Position, e.outline.Size = boxPos, boxSize
    e.box.Visible = Config.Box
    e.box.Position, e.box.Size = boxPos, boxSize
    e.boxStroke.Color = color

    e.name.Visible = Config.Name
    e.name.Position = UDim2.fromOffset(x + w / 2, y - 2)

    e.dist.Visible = Config.Distance
    e.dist.Position = UDim2.fromOffset(x + w / 2, y + h + 2)
    e.dist.Text = string.format("%dm", math.floor(distance + 0.5))

    e.hpBg.Visible = Config.Health
    e.hpBg.Position = UDim2.fromOffset(x - 6, y)
    e.hpBg.Size = UDim2.fromOffset(4, h)
    local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
    e.hpFill.Position = UDim2.fromOffset(1, h - 1)
    e.hpFill.Size = UDim2.fromOffset(2, math.max(0, math.floor((h - 2) * pct + 0.5)))
    e.hpFill.BackgroundColor3 = Color3.fromHSV(pct * 0.33, 1, 1)

    e.tracer.Visible = Config.Tracers
    e.tracer.BackgroundColor3 = color
    setLine(e.tracer, tracerFrom, Vector2.new(center.X, y + h))
end

local function step()
    local cam = Workspace.CurrentCamera
    if not cam then return end

    local ignore = { cam }
    if LocalPlayer.Character then ignore[2] = LocalPlayer.Character end
    rayParams.FilterDescendantsInstances = ignore

    local vp = cam.ViewportSize
    local tracerFrom
    if Config.TracerOrigin == "Center" then
        tracerFrom = vp / 2
    elseif Config.TracerOrigin == "Mouse" then
        tracerFrom = UserInputService:GetMouseLocation()
    else
        tracerFrom = Vector2.new(vp.X / 2, vp.Y)
    end

    local camPos = cam.CFrame.Position
    for player, e in pairs(entries) do
        updateEntry(player, e, cam, camPos, tracerFrom)
    end
end

local function destroy()
    RunService:UnbindFromRenderStep("PlayerESP")
    for _, c in ipairs(connections) do c:Disconnect() end
    for player in pairs(entries) do removeEntry(player) end
    gui:Destroy()
    if env.PlayerESP and env.PlayerESP.Destroy == destroy then
        env.PlayerESP = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then createEntry(p) end
end

connections[#connections + 1] = Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then createEntry(p) end
end)
connections[#connections + 1] = Players.PlayerRemoving:Connect(removeEntry)
connections[#connections + 1] = UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Config.ToggleKey then
        Config.Enabled = not Config.Enabled
    end
end)

RunService:BindToRenderStep("PlayerESP", Enum.RenderPriority.Last.Value, step)

env.PlayerESP = { Config = Config, Destroy = destroy }
