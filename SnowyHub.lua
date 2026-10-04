-- =====================================================================
-- Snowy Hub v1.0 — Rivals (Roblox)
-- Made By Crscx
-- Entry point: loadstring(game:HttpGet("<raw url>"))()
-- Target client only. Visual + input helpers. Educational.
-- =====================================================================

if _G.SnowyHubRunning then
    pcall(function() _G.SnowyHubRunning:Destroy() end)
    _G.SnowyHubRunning = nil
end

local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local Lighting           = game:GetService("Lighting")
local Workspace          = game:GetService("Workspace")
local HttpService        = game:GetService("HttpService")
local CoreGui            = game:GetService("CoreGui")
local StarterGui         = game:GetService("StarterGui")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()
local function Camera() return Workspace.CurrentCamera end

-- =====================================================================
-- Executor compat
-- =====================================================================
local function safe_type(v) return type(v) end

local function pick_hidden()
    local ok, res
    ok, res = pcall(function() if gethui then return gethui() end end)
    if ok and res then return res end
    ok, res = pcall(function() if get_hidden_gui then return get_hidden_gui() end end)
    if ok and res then return res end
    ok, res = pcall(function() return game:GetService("CoreGui") end)
    if ok and res then return res end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function parent_gui(g)
    local target = pick_hidden()
    local ok1 = pcall(function()
        if syn and syn.protect_gui then syn.protect_gui(g) end
    end)
    local ok2 = pcall(function() g.Parent = target end)
    if not ok2 then
        pcall(function() g.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end
end

-- =====================================================================
-- Theme
-- =====================================================================
local Theme = {
    Background     = Color3.fromRGB(10, 6, 20),
    Panel          = Color3.fromRGB(20, 14, 36),
    Panel2         = Color3.fromRGB(28, 20, 48),
    PanelHi        = Color3.fromRGB(38, 28, 64),
    Border         = Color3.fromRGB(70, 44, 120),
    Accent         = Color3.fromRGB(170, 100, 255), -- hollow purple
    AccentDeep     = Color3.fromRGB(110, 60, 220),
    AccentGlow     = Color3.fromRGB(200, 140, 255),
    Text           = Color3.fromRGB(235, 225, 255),
    TextDim        = Color3.fromRGB(150, 140, 180),
    Success        = Color3.fromRGB(120, 240, 170),
    Danger         = Color3.fromRGB(255, 90, 130),
    Warn           = Color3.fromRGB(255, 190, 110),
    FontBold       = Enum.Font.GothamBold,
    FontReg        = Enum.Font.Gotham,
    FontMono       = Enum.Font.Code,
}

-- =====================================================================
-- CUSTOM IMAGE SLOTS — paste your own Roblox asset IDs here
-- =====================================================================
-- HOW TO USE YOUR OWN IMAGE:
--   1. Save the image you want (wolf, gojo, anything) to your computer
--   2. Go to https://create.roblox.com/dashboard/creations/decals
--   3. Click "Upload Asset", pick your file, wait ~30s for moderation
--   4. Click the uploaded decal, the URL ends in /decals/XXXXXXXXXX
--   5. Replace the number below with your XXXXXXXXXX
--   6. Re-run the loadstring, your image appears
--
-- Leave the ID empty ("") to fall back to the emoji glyph instead.
-- =====================================================================
local CUSTOM_LOGO_ID      = ""   104398111865283
local CUSTOM_BANNER_ID    = ""   92711086204941
local LOGO_TINT           = Color3.fromRGB(255, 255, 255) -- white = show image's own colors; purple = tint it

local HOLLOW_PURPLE_IMAGE = "rbxassetid://136481529993647"
local INTRO_SOUND_ID      = "rbxassetid://104910706944537"

-- =====================================================================
-- Root ScreenGui
-- =====================================================================
local Root = Instance.new("ScreenGui")
Root.Name = "SnowyHub_" .. tostring(math.random(100000, 999999))
Root.ResetOnSpawn = false
Root.IgnoreGuiInset = true
Root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Root.DisplayOrder = 2147483647
parent_gui(Root)
_G.SnowyHubRunning = Root

-- =====================================================================
-- UI helpers
-- =====================================================================
local UI = {}

function UI.new(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then o[k] = v end
    end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

function UI.corner(parent, r)
    return UI.new("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = parent })
end

function UI.stroke(parent, color, thickness, trans)
    return UI.new("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Transparency = trans or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

function UI.pad(parent, t, r, b, l)
    return UI.new("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingRight  = UDim.new(0, r or t or 0),
        PaddingBottom = UDim.new(0, b or t or 0),
        PaddingLeft   = UDim.new(0, l or r or t or 0),
        Parent = parent,
    })
end

function UI.list(parent, dir, pad, align)
    return UI.new("UIListLayout", {
        FillDirection = dir or Enum.FillDirection.Vertical,
        Padding = UDim.new(0, pad or 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
        Parent = parent,
    })
end

function UI.gradient(parent, colorseq, rot, trans)
    return UI.new("UIGradient", {
        Color = colorseq,
        Rotation = rot or 0,
        Transparency = trans or NumberSequence.new(0),
        Parent = parent,
    })
end

function UI.tween(obj, time, props, style, dir)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end
local function lerp(a, b, t) return a + (b - a) * t end

-- =====================================================================
-- Notifications
-- =====================================================================
local NotifyHolder = UI.new("Frame", {
    Name = "Notify",
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -16, 1, -16),
    Size = UDim2.new(0, 300, 1, -40),
    Parent = Root,
})
UI.list(NotifyHolder, Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Right).VerticalAlignment = Enum.VerticalAlignment.Bottom

local function notify(title, text, kind, dur)
    dur = dur or 4
    local col = Theme.Accent
    if kind == "good"  then col = Theme.Success end
    if kind == "warn"  then col = Theme.Warn end
    if kind == "bad"   then col = Theme.Danger end

    local f = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Theme.Panel,
        BackgroundTransparency = 0.1,
        Parent = NotifyHolder,
    })
    UI.corner(f, 8)
    UI.stroke(f, col, 1, 0.3)

    local bar = UI.new("Frame", {
        Size = UDim2.new(0, 3, 1, -12),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundColor3 = col,
        BorderSizePixel = 0,
        Parent = f,
    })
    UI.corner(bar, 2)

    UI.new("TextLabel", {
        Position = UDim2.new(0, 20, 0, 6),
        Size = UDim2.new(1, -28, 0, 20),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = title or "snowy hub",
        Parent = f,
    })
    UI.new("TextLabel", {
        Position = UDim2.new(0, 20, 0, 28),
        Size = UDim2.new(1, -28, 0, 22),
        BackgroundTransparency = 1,
        Font = Theme.FontReg,
        TextSize = 12,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Text = text or "",
        Parent = f,
    })

    f.BackgroundTransparency = 1
    for _, c in ipairs(f:GetChildren()) do
        if c:IsA("GuiObject") then c.BackgroundTransparency = 1 end
    end
    UI.tween(f, 0.25, { BackgroundTransparency = 0.1 })
    UI.tween(bar, 0.25, { BackgroundTransparency = 0 })

    task.delay(dur, function()
        if not f.Parent then return end
        UI.tween(f, 0.25, { BackgroundTransparency = 1 })
        task.wait(0.3)
        f:Destroy()
    end)
end

-- =====================================================================
-- INTRO CUTSCENE
-- Procedural hollow-purple orb (no external assets).
-- Loading screen -> loading bar -> shatter -> hollow purple reveal.
-- =====================================================================
local Intro = {}

-- Logo: uses CUSTOM_LOGO_ID if set, otherwise falls back to wolf emoji glyph.
-- Add soft neon halo + optional pulse animation around whichever is used.
function Intro.makeWolf(parent, size, opts)
    opts = opts or {}
    local line     = opts.line   or Color3.fromRGB(210, 160, 255)
    local showHalo = opts.halo ~= false
    local animate  = opts.animate ~= false
    local zbase    = opts.z or 100
    local customId = opts.imageId or CUSTOM_LOGO_ID

    local wrap = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1,
        ZIndex = zbase,
        Parent = parent,
    })

    -- outer soft neon halo
    local halo
    if showHalo then
        halo = UI.new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1.4, 0, 1.4, 0),
            BackgroundColor3 = line,
            BackgroundTransparency = 0.75,
            BorderSizePixel = 0,
            ZIndex = zbase,
            Parent = wrap,
        })
        UI.corner(halo, 999)
        UI.new("UIGradient", {
            Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0.5),
                NumberSequenceKeypoint.new(1, 1),
            },
            Parent = halo,
        })
    end

    -- If user supplied a custom decal ID, use it as an ImageLabel.
    -- Otherwise fall back to the wolf emoji glyph.
    if customId and customId ~= "" then
        local idStr = tostring(customId)
        -- strip "rbxassetid://" prefix if user pasted the full URL
        idStr = idStr:gsub("rbxassetid://", "")
        UI.new("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0.95, 0, 0.95, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://" .. idStr,
            ScaleType = Enum.ScaleType.Fit,
            ImageColor3 = LOGO_TINT,
            ZIndex = zbase + 2,
            Parent = wrap,
        })
    else
        UI.new("TextLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBlack,
            TextSize = size * 0.85,
            TextColor3 = line,
            Text = "🐺",
            TextScaled = false,
            ZIndex = zbase + 2,
            Parent = wrap,
        })
    end

    -- animate halo pulse
    if animate and halo then
        task.spawn(function()
            local t = 0
            while wrap.Parent do
                local dt = RunService.RenderStepped:Wait()
                t = t + dt
                halo.BackgroundTransparency = 0.7 + 0.1 * math.sin(t * 2.5)
                halo.Size = UDim2.new(1.4 + 0.08 * math.sin(t * 2), 0, 1.4 + 0.08 * math.sin(t * 2), 0)
            end
        end)
    end

    return wrap
end

-- Build a hollow-purple orb visual from pure Frames + gradients + strokes.
-- Returns the wrapping Frame so caller can tween/position it.
function Intro.makeHollowPurple(parent, size, zbase)
    zbase = zbase or 100
    local wrap = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, size, 0, size),
        BackgroundTransparency = 1,
        ZIndex = zbase,
        Parent = parent,
    })

    -- outer soft glow (big transparent circle with radial gradient)
    local outerGlow = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1.8, 0, 1.8, 0),
        BackgroundColor3 = Color3.fromRGB(170, 90, 255),
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        ZIndex = zbase,
        Parent = wrap,
    })
    UI.corner(outerGlow, 999)
    UI.new("UIGradient", {
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(0.6, 0.85),
            NumberSequenceKeypoint.new(1, 1),
        },
        Parent = outerGlow,
    })

    -- mid glow
    local midGlow = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1.3, 0, 1.3, 0),
        BackgroundColor3 = Color3.fromRGB(200, 130, 255),
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = zbase + 1,
        Parent = wrap,
    })
    UI.corner(midGlow, 999)
    UI.new("UIGradient", {
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(1, 1),
        },
        Parent = midGlow,
    })

    -- main orb body (purple sphere look)
    local orb = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(180, 110, 255),
        BorderSizePixel = 0,
        ZIndex = zbase + 2,
        Parent = wrap,
    })
    UI.corner(orb, 999)
    UI.new("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(240, 200, 255)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(190, 120, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 30, 160)),
        },
        Rotation = 90,
        Parent = orb,
    })
    UI.stroke(orb, Color3.fromRGB(240, 220, 255), 2, 0.3)

    -- highlight shine (top-left)
    local shine = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.33, 0, 0.28, 0),
        Size = UDim2.new(0.4, 0, 0.22, 0),
        BackgroundColor3 = Color3.fromRGB(255, 240, 255),
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        ZIndex = zbase + 3,
        Parent = orb,
    })
    UI.corner(shine, 999)
    UI.new("UIGradient", {
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(1, 1),
        },
        Parent = shine,
    })

    -- darker core (bottom-right swirl)
    local core = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.62, 0, 0.68, 0),
        Size = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(80, 30, 160),
        BackgroundTransparency = 0.45,
        BorderSizePixel = 0,
        ZIndex = zbase + 3,
        Parent = orb,
    })
    UI.corner(core, 999)
    UI.new("UIGradient", {
        Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(1, 1),
        },
        Parent = core,
    })

    -- orbit ring (dashed look via rotating stroked ellipse)
    local ringContainer = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1.25, 0, 0.55, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = zbase + 4,
        Parent = wrap,
    })
    local ringEllipse = UI.new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = zbase + 4,
        Parent = ringContainer,
    })
    UI.corner(ringEllipse, 999)
    UI.stroke(ringEllipse, Color3.fromRGB(150, 220, 255), 2, 0.1)

    -- lightning bolts (thin frames at random angles, flicker)
    local bolts = {}
    local numBolts = 10
    for i = 1, numBolts do
        local bolt = UI.new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 2, 0, size * 0.9),
            BackgroundColor3 = Color3.fromRGB(220, 200, 255),
            BorderSizePixel = 0,
            Rotation = (i / numBolts) * 360,
            BackgroundTransparency = 0.3,
            ZIndex = zbase + 5,
            Parent = wrap,
        })
        UI.corner(bolt, 1)
        UI.new("UIGradient", {
            Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0.1),
                NumberSequenceKeypoint.new(0.3, 0.6),
                NumberSequenceKeypoint.new(0.5, 0.2),
                NumberSequenceKeypoint.new(0.7, 0.7),
                NumberSequenceKeypoint.new(1, 0.1),
            },
            Parent = bolt,
        })
        table.insert(bolts, bolt)
    end

    -- animate everything in one coroutine
    local alive = true
    wrap.AncestryChanged:Connect(function(_, p)
        if not p then alive = false end
    end)
    task.spawn(function()
        local t = 0
        while alive and wrap.Parent do
            local dt = RunService.RenderStepped:Wait()
            t = t + dt
            outerGlow.BackgroundTransparency = 0.5 + 0.15 * math.sin(t * 2.5)
            midGlow.BackgroundTransparency  = 0.35 + 0.12 * math.sin(t * 3 + 0.5)
            orb.Rotation = math.sin(t * 1.3) * 4
            ringContainer.Rotation = (t * 70) % 360
            for i, bolt in ipairs(bolts) do
                bolt.Rotation = (i / numBolts) * 360 + math.sin(t * 5 + i) * 10
                bolt.BackgroundTransparency = 0.2 + math.random() * 0.55
            end
        end
    end)

    return wrap
end

function Intro.build(onDone)
    local screen = UI.new("Frame", {
        Name = "Intro",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ZIndex = 100,
        Parent = Root,
    })

    -- radial haze: pure Frame + gradient, no asset
    local haze = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(40, 15, 75),
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        ZIndex = 101,
        Parent = screen,
    })
    UI.new("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 20, 100)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 2, 15)),
        },
        Rotation = 90,
        Parent = haze,
    })

    -- center stack
    local center = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 540, 0, 420),
        BackgroundTransparency = 1,
        ZIndex = 110,
        Parent = screen,
    })

    -- hollow purple orb slot
    local orbSlot = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 20),
        Size = UDim2.new(0, 180, 0, 180),
        BackgroundTransparency = 1,
        ZIndex = 111,
        Parent = center,
    })
    Intro.makeWolf(orbSlot, 140, { z = 111 })

    -- Chinese title: 雪 云 枢 纽 (snowy cloud hub)
    UI.new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 210),
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 32,
        TextColor3 = Theme.Text,
        Text = "雪  云  枢  纽",
        ZIndex = 112,
        Parent = center,
    })

    -- Snowy Hub wordmark (purple themed, gradient)
    local wordmark = UI.new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 258),
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 16,
        TextColor3 = Theme.AccentGlow,
        Text = "S N O W Y   H U B",
        ZIndex = 112,
        Parent = center,
    })
    UI.new("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.AccentDeep),
            ColorSequenceKeypoint.new(0.5, Theme.AccentGlow),
            ColorSequenceKeypoint.new(1, Theme.AccentDeep),
        },
        Parent = wordmark,
    })

    -- loading bar
    local barBg = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 300),
        Size = UDim2.new(0, 320, 0, 4),
        BackgroundColor3 = Color3.fromRGB(40, 30, 70),
        BorderSizePixel = 0,
        ZIndex = 112,
        Parent = center,
    })
    UI.corner(barBg, 2)
    local barFill = UI.new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 113,
        Parent = barBg,
    })
    UI.corner(barFill, 2)
    UI.new("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.AccentDeep),
            ColorSequenceKeypoint.new(1, Theme.AccentGlow),
        },
        Parent = barFill,
    })

    local status = UI.new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 316),
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Font = Theme.FontReg,
        TextSize = 12,
        TextColor3 = Theme.TextDim,
        Text = "checking integrity",
        ZIndex = 112,
        Parent = center,
    })

    -- Made By Crscx at the very bottom
    local credit = UI.new("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -24),
        Size = UDim2.new(0, 300, 0, 22),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 14,
        TextColor3 = Theme.AccentGlow,
        Text = "Made By Crscx",
        ZIndex = 110,
        Parent = screen,
    })
    UI.new("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.Accent),
            ColorSequenceKeypoint.new(0.5, Theme.AccentGlow),
            ColorSequenceKeypoint.new(1, Theme.AccentDeep),
        },
        Parent = credit,
    })

    -- intro sound
    -- intro sound: parent to SoundService so it survives screen:Destroy()
    pcall(function()
        local sound = Instance.new("Sound")
        sound.Name = "SnowyIntroSound"
        sound.SoundId = INTRO_SOUND_ID
        sound.Volume = 2.5
        sound.PlayOnRemove = false
        sound.Parent = SoundService
        -- preload then play so it doesn't start on an unloaded buffer
        pcall(function()
            local cp = game:GetService("ContentProvider")
            cp:PreloadAsync({ sound })
        end)
        sound:Play()
        sound.Ended:Connect(function() pcall(function() sound:Destroy() end) end)
        -- hard cleanup after 15s in case Ended never fires
        task.delay(15, function()
            if sound and sound.Parent then pcall(function() sound:Destroy() end) end
        end)
    end)

    print("[SnowyHub] intro built, starting bar fill")

    -- status rotator (faster cycle)
    local alive = true
    local statuses = { "checking integrity", "linking modules", "warming the orb", "sync complete" }
    task.spawn(function()
        local i = 1
        while alive and status.Parent do
            status.Text = statuses[i]
            i = (i % #statuses) + 1
            task.wait(0.6)
        end
    end)

    -- fill the bar over 2.3s (fast)
    pcall(function()
        UI.tween(barFill, 2.3, { Size = UDim2.new(1, 0, 1, 0) }, Enum.EasingStyle.Quart)
    end)
    task.wait(2.4)
    alive = false
    pcall(function() status.Text = "unsealing" end)
    task.wait(0.2)
    print("[SnowyHub] bar done, shattering")

    local ok1, err1 = pcall(function() Intro.shatter(screen) end)
    if not ok1 then
        warn("[SnowyHub] shatter err:", err1)
        pcall(function() screen:Destroy() end)
    end
    print("[SnowyHub] shatter done, revealing")

    local ok2, err2 = pcall(function() Intro.hollowPurpleReveal() end)
    if not ok2 then
        warn("[SnowyHub] reveal err:", err2)
        pcall(function()
            for _, c in ipairs(Root:GetChildren()) do
                if c.Name == "HollowReveal" then c:Destroy() end
            end
        end)
    end
    print("[SnowyHub] reveal done, calling onDone")

    if onDone then
        local ok3, err3 = pcall(onDone)
        if not ok3 then warn("[SnowyHub] onDone err:", err3) end
    end
end

function Intro.shatter(screen)
    local shardHost = UI.new("Frame", {
        Name = "ShardHost",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 120,
        Parent = Root,
    })

    local vp = Camera().ViewportSize
    local cols, rows = 10, 7
    local cellW, cellH = vp.X / cols, vp.Y / rows

    local flash = UI.new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(240, 220, 255),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 125,
        Parent = shardHost,
    })
    UI.tween(flash, 0.08, { BackgroundTransparency = 0.1 })
    task.wait(0.08)
    UI.tween(flash, 0.4, { BackgroundTransparency = 1 })

    pcall(function() screen.Visible = false end)

    for r = 0, rows - 1 do
        for c = 0, cols - 1 do
            local shard = UI.new("Frame", {
                Size = UDim2.new(0, cellW + 2, 0, cellH + 2),
                Position = UDim2.new(0, c * cellW, 0, r * cellH),
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 0,
                ZIndex = 121,
                Parent = shardHost,
            })
            UI.stroke(shard, Theme.Accent, 1, 0.4)
            local dx = (c - cols / 2) * (120 + math.random(0, 80)) + math.random(-40, 40)
            local dy = (r - rows / 2) * (120 + math.random(0, 80)) + math.random(-40, 40) - 200
            local rot = math.random(-180, 180)
            TweenService:Create(shard, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0, c * cellW + dx, 0, r * cellH + dy),
                Rotation = rot,
                BackgroundTransparency = 1,
            }):Play()
        end
    end

    task.wait(0.5)
    pcall(function() screen:Destroy() end)
    pcall(function() shardHost:Destroy() end)
end

function Intro.hollowPurpleReveal()
    local layer = UI.new("Frame", {
        Name = "HollowReveal",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 130,
        Parent = Root,
    })
    UI.tween(layer, 0.25, { BackgroundTransparency = 0.3 })

    local slot = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = 131,
        Parent = layer,
    })
    Intro.makeWolf(slot, 300, { z = 132 })

    -- grow in
    UI.tween(slot, 0.4, { Size = UDim2.new(0, 360, 0, 360) },
        Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.wait(0.7)

    -- shoot to top-left corner, shrink
    UI.tween(slot, 0.4, {
        Position = UDim2.new(0, 48, 0, 48),
        Size = UDim2.new(0, 36, 0, 36),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut)
    UI.tween(layer, 0.4, { BackgroundTransparency = 1 })
    task.wait(0.45)

    pcall(function() layer:Destroy() end)
end

-- =====================================================================
-- Flags (shared state)
-- =====================================================================
local Flags = {
    -- Aimbot
    AimbotEnabled   = false,
    AimKey          = Enum.UserInputType.MouseButton2,
    AimPart         = "Head",
    AimFOV          = 90,
    AimSmooth       = 0.18,
    AimTeamCheck    = true,
    AimVisibleCheck = true,
    AimWallbang     = false,
    AimPrediction   = 0.14,
    AimShowFOV      = true,

    -- ESP
    ESPEnabled      = false,
    ESPBox          = true,
    ESPName         = true,
    ESPDistance     = true,
    ESPHealth       = true,
    ESPTracers      = false,
    ESPTeamCheck    = true,
    ESPMaxDistance  = 2000,
    ESPColor        = Theme.Accent,
    ESPEnemyColor   = Color3.fromRGB(255, 90, 130),

    -- Movement
    Bhop            = false,
    InfJump         = false,
    Noclip          = false,
    JumpPower       = 50,
    Gravity         = 196.2,

    -- Combat
    HitboxEnabled   = false,
    HitboxSize      = 6,
    HitboxTarget    = "Head",

    -- Skin
    SkinName        = "",
}

-- =====================================================================
-- Main Hub Window
-- =====================================================================
local Hub = {}

function Hub.build()
    local win = UI.new("Frame", {
        Name = "Hub",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 760, 0, 500),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ZIndex = 50,
        Parent = Root,
    })
    UI.corner(win, 12)
    UI.stroke(win, Theme.Border, 1, 0.3)
    Hub.window = win

    -- animated entry
    win.Size = UDim2.new(0, 0, 0, 0)
    UI.tween(win, 0.4, { Size = UDim2.new(0, 760, 0, 500) },
        Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- top floating header bar (like 5th image)
    local topbar = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, -42),
        Size = UDim2.new(0, 320, 0, 30),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 51,
        Parent = win,
    })
    UI.corner(topbar, 15)
    UI.stroke(topbar, Theme.Border, 1, 0.4)

    local topList = UI.new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = topbar,
    })

    -- mini wolf head on the top pill
    local pillLogoHost = UI.new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 22, 0, 22),
        LayoutOrder = 1,
        Parent = topbar,
    })
    Intro.makeWolf(pillLogoHost, 22, { z = 60, animate = false, halo = false, strokeWidth = 1 })
    local tTitle = UI.new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 90, 1, 0),
        Font = Theme.FontBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        Text = "SNOWY HUB",
        LayoutOrder = 2,
        Parent = topbar,
    })
    local tGame = UI.new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 1, 0),
        Font = Theme.FontBold,
        TextSize = 12,
        TextColor3 = Theme.AccentGlow,
        Text = "RIVALS",
        LayoutOrder = 3,
        Parent = topbar,
    })
    local tFPS = UI.new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 1, 0),
        Font = Theme.FontMono,
        TextSize = 12,
        TextColor3 = Theme.TextDim,
        Text = "--- FPS",
        LayoutOrder = 4,
        Parent = topbar,
    })
    local tPing = UI.new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 1, 0),
        Font = Theme.FontMono,
        TextSize = 12,
        TextColor3 = Theme.TextDim,
        Text = "--- MS",
        LayoutOrder = 5,
        Parent = topbar,
    })

    task.spawn(function()
        local frames, acc = 0, 0
        local last = tick()
        while topbar.Parent do
            local dt = RunService.RenderStepped:Wait()
            frames = frames + 1
            acc = acc + dt
            if tick() - last > 0.5 then
                tFPS.Text = string.format("%d FPS", math.floor(frames / acc + 0.5))
                frames, acc = 0, 0
                last = tick()
                local ok, ping = pcall(function()
                    return LocalPlayer:GetNetworkPing() * 1000
                end)
                tPing.Text = string.format("%dMS", ok and ping or 0)
            end
        end
    end)

    -- sidebar
    local sidebar = UI.new("Frame", {
        Size = UDim2.new(0, 220, 1, 0),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 51,
        Parent = win,
    })
    UI.corner(sidebar, 12)
    -- cover right rounded corners
    UI.new("Frame", {
        Position = UDim2.new(1, -12, 0, 0),
        Size = UDim2.new(0, 12, 1, 0),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 51,
        Parent = sidebar,
    })

    -- sidebar top BANNER: gradient panel with hollow purple centerpiece
    local banner = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 140),
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        ZIndex = 52,
        Parent = sidebar,
    })
    UI.corner(banner, 12)
    -- cover rounded bottom to keep sharp divider with content below
    UI.new("Frame", {
        Position = UDim2.new(0, 0, 1, -12),
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        ZIndex = 52,
        Parent = banner,
    })
    UI.new("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 30, 110)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 20, 80)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 12, 42)),
        },
        Rotation = 135,
        Parent = banner,
    })

    -- banner backdrop: if CUSTOM_BANNER_ID is set, fill the whole banner with it;
    -- otherwise show a centered logo (wolf emoji or CUSTOM_LOGO_ID)
    if CUSTOM_BANNER_ID and CUSTOM_BANNER_ID ~= "" then
        local idStr = tostring(CUSTOM_BANNER_ID):gsub("rbxassetid://", "")
        UI.new("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Image = "rbxassetid://" .. idStr,
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 53,
            Parent = banner,
        })
        -- dark gradient overlay for text readability
        local overlay = UI.new("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, 0),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(15, 8, 30),
            BorderSizePixel = 0,
            ZIndex = 54,
            Parent = banner,
        })
        UI.new("UIGradient", {
            Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.55, 0.5),
                NumberSequenceKeypoint.new(1, 0.1),
            },
            Rotation = 90,
            Parent = overlay,
        })
    else
        -- no banner image set — show centered logo (wolf emoji or CUSTOM_LOGO_ID)
        local bannerLogoSlot = UI.new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.42, 0),
            Size = UDim2.new(0, 90, 0, 90),
            BackgroundTransparency = 1,
            ZIndex = 53,
            Parent = banner,
        })
        Intro.makeWolf(bannerLogoSlot, 90, { z = 53, animate = false })
    end

    -- small circular glyph + name sitting at the bottom of the banner
    local bannerBottom = UI.new("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 14, 1, -10),
        Size = UDim2.new(1, -28, 0, 44),
        BackgroundTransparency = 1,
        ZIndex = 55,
        Parent = banner,
    })

    -- mini wolf next to the name (replacing the purple orb)
    local nameWolfSlot = UI.new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 22, 0, 22),
        BackgroundTransparency = 1,
        ZIndex = 56,
        Parent = bannerBottom,
    })
    Intro.makeWolf(nameWolfSlot, 22, { z = 56, animate = false, halo = false, strokeWidth = 1 })

    local bannerName = UI.new("TextLabel", {
        Position = UDim2.new(0, 30, 0, 0),
        Size = UDim2.new(1, -30, 0, 24),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "Snowy Hub",
        ZIndex = 56,
        Parent = bannerBottom,
    })
    UI.new("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 240, 255)),
            ColorSequenceKeypoint.new(1, Theme.AccentGlow),
        },
        Rotation = 0,
        Parent = bannerName,
    })
    UI.new("TextLabel", {
        Position = UDim2.new(0, 30, 0, 24),
        Size = UDim2.new(1, -30, 0, 14),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        TextSize = 11,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "雪 云 枢 纽",
        ZIndex = 56,
        Parent = bannerBottom,
    })

    -- sidebar tabs (Home with left accent bar) — tabs start right after the banner now
    local tabsHolder = UI.new("Frame", {
        Position = UDim2.new(0, 0, 0, 156),
        Size = UDim2.new(1, 0, 1, -224),
        BackgroundTransparency = 1,
        ZIndex = 52,
        Parent = sidebar,
    })
    UI.pad(tabsHolder, 4, 10, 4, 0)
    UI.list(tabsHolder, Enum.FillDirection.Vertical, 4)

    -- Home tab row
    local homeTab = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        ZIndex = 53,
        Parent = tabsHolder,
    })
    UI.new("Frame", {
        Position = UDim2.new(0, 0, 0.5, -8),
        Size = UDim2.new(0, 3, 0, 16),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 54,
        Parent = homeTab,
    })
    UI.new("TextLabel", {
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -14, 1, 0),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "Home",
        ZIndex = 54,
        Parent = homeTab,
    })

    -- user card at bottom
    local userCard = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -14),
        Size = UDim2.new(1, -20, 0, 50),
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        ZIndex = 52,
        Parent = sidebar,
    })
    UI.corner(userCard, 8)
    UI.stroke(userCard, Theme.Border, 1, 0.5)

    local avatar = UI.new("ImageLabel", {
        Position = UDim2.new(0, 6, 0.5, -17),
        Size = UDim2.new(0, 34, 0, 34),
        BackgroundTransparency = 1,
        BackgroundColor3 = Theme.PanelHi,
        ZIndex = 53,
        Parent = userCard,
    })
    UI.corner(avatar, 17)
    pcall(function()
        avatar.Image = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size48x48
        )
    end)
    UI.new("TextLabel", {
        Position = UDim2.new(0, 46, 0, 6),
        Size = UDim2.new(1, -50, 0, 18),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = LocalPlayer.DisplayName or LocalPlayer.Name,
        ZIndex = 53,
        Parent = userCard,
    })
    UI.new("TextLabel", {
        Position = UDim2.new(0, 46, 0, 24),
        Size = UDim2.new(1, -50, 0, 16),
        BackgroundTransparency = 1,
        Font = Theme.FontReg,
        TextSize = 11,
        TextColor3 = Theme.AccentGlow,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "MEMBER",
        ZIndex = 53,
        Parent = userCard,
    })

    -- content area (right side)
    local content = UI.new("Frame", {
        Position = UDim2.new(0, 220, 0, 0),
        Size = UDim2.new(1, -220, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 51,
        Parent = win,
    })

    -- header strip
    local header = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundTransparency = 1,
        ZIndex = 52,
        Parent = content,
    })
    UI.pad(header, 0, 14, 0, 20)
    local hTitle = UI.new("TextLabel", {
        Size = UDim2.new(1, -140, 1, 0),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 20,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Text = "Home",
        ZIndex = 53,
        Parent = header,
    })
    local hSub = UI.new("TextLabel", {
        Position = UDim2.new(0, 0, 1, -16),
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Font = Theme.FontReg,
        TextSize = 11,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "aim · esp · movement · combat · skins",
        ZIndex = 53,
        Parent = header,
    })

    local close = UI.new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.new(0, 24, 0, 24),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 18,
        TextColor3 = Theme.TextDim,
        Text = "X",
        ZIndex = 53,
        Parent = header,
    })
    close.MouseButton1Click:Connect(function()
        Root:Destroy()
        _G.SnowyHubRunning = nil
    end)

    local recdot = UI.new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -46, 0.5, 0),
        Size = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Theme.Danger,
        BorderSizePixel = 0,
        ZIndex = 53,
        Parent = header,
    })
    UI.corner(recdot, 4)
    task.spawn(function()
        while recdot.Parent do
            recdot.BackgroundTransparency = 0
            task.wait(0.6)
            recdot.BackgroundTransparency = 0.6
            task.wait(0.6)
        end
    end)

    -- scrollable panel content
    local scroll = UI.new("ScrollingFrame", {
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(1, 0, 1, -70),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 52,
        Parent = content,
    })
    UI.pad(scroll, 4, 14, 10, 14)
    local scrollList = UI.list(scroll, Enum.FillDirection.Vertical, 10)

    Hub.content = scroll

    -- bottom footer
    local footer = UI.new("Frame", {
        Position = UDim2.new(0, 0, 1, -20),
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        ZIndex = 52,
        Parent = content,
    })
    UI.new("TextLabel", {
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 11,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "SNOWY HUB · RIVALS V1.0",
        ZIndex = 53,
        Parent = footer,
    })
    local fRS = UI.new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 53,
        Parent = footer,
    })
    UI.new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 7, 0, 7),
        BackgroundColor3 = Theme.Success,
        BorderSizePixel = 0,
        ZIndex = 54,
        Parent = fRS,
    }).Name = "dot"
    UI.corner(fRS:FindFirstChild("dot"), 4)
    UI.new("TextLabel", {
        Position = UDim2.new(0, 14, 0, 0),
        Size = UDim2.new(1, -14, 1, 0),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 11,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = "RSHIFT TO HIDE",
        ZIndex = 54,
        Parent = fRS,
    })

    -- draggable
    Hub.makeDraggable(win, header)
    Hub.makeDraggable(win, topbar)

    return scroll, hTitle
end

function Hub.makeDraggable(frame, grip)
    local dragging, dragStart, startPos = false
    grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    grip.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and
           input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end)
end

-- =====================================================================
-- Widget library (sections, toggles, sliders, inputs, dropdowns)
-- =====================================================================
local Widgets = {}

function Widgets.section(parent, title, note)
    local f = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 53,
        Parent = parent,
    })
    UI.corner(f, 10)
    UI.stroke(f, Theme.Border, 1, 0.55)
    UI.pad(f, 12, 14, 12, 14)
    UI.list(f, Enum.FillDirection.Vertical, 8)

    local head = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        ZIndex = 54,
        Parent = f,
    })
    local dot = UI.new("Frame", {
        Position = UDim2.new(0, 0, 0.5, -4),
        Size = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Rotation = 45,
        ZIndex = 55,
        Parent = head,
    })
    UI.new("TextLabel", {
        Position = UDim2.new(0, 18, 0, 0),
        Size = UDim2.new(0.7, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = string.upper(title or ""),
        ZIndex = 55,
        Parent = head,
    })
    if note then
        UI.new("TextLabel", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.new(0, 180, 0, 16),
            BackgroundTransparency = 1,
            Font = Theme.FontReg,
            TextSize = 11,
            TextColor3 = Theme.Warn,
            TextXAlignment = Enum.TextXAlignment.Right,
            Text = note,
            ZIndex = 55,
            Parent = head,
        })
    end
    return f
end

function Widgets.toggle(parent, label, hint, default, tag, onChange)
    local f = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        ZIndex = 55,
        Parent = parent,
    })
    UI.corner(f, 8)

    -- title row: label + optional tag, auto-flowing horizontally so they can't overlap
    local titleRow = UI.new("Frame", {
        Position = UDim2.new(0, 12, 0, 4),
        Size = UDim2.new(1, -80, 0, 18),
        BackgroundTransparency = 1,
        ZIndex = 56,
        Parent = f,
    })
    UI.new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = titleRow,
    })

    UI.new("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = label,
        LayoutOrder = 1,
        ZIndex = 57,
        Parent = titleRow,
    })

    if tag then
        UI.new("TextLabel", {
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Theme.FontReg,
            TextSize = 11,
            TextColor3 = Theme.Danger,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = tag,
            LayoutOrder = 2,
            ZIndex = 57,
            Parent = titleRow,
        })
    end

    UI.new("TextLabel", {
        Position = UDim2.new(0, 12, 0, 24),
        Size = UDim2.new(1, -80, 0, 16),
        BackgroundTransparency = 1,
        Font = Theme.FontReg,
        TextSize = 11,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = hint or "",
        ZIndex = 56,
        Parent = f,
    })

    local btn = UI.new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 54, 0, 24),
        BackgroundColor3 = Color3.fromRGB(60, 40, 100),
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
        ZIndex = 56,
        Parent = f,
    })
    UI.corner(btn, 12)
    local knob = UI.new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.new(0, 18, 0, 18),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        ZIndex = 57,
        Parent = btn,
    })
    UI.corner(knob, 9)
    local lbl = UI.new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 10,
        TextColor3 = Theme.Text,
        Text = "OFF",
        ZIndex = 57,
        Parent = btn,
    })

    local state = false
    local function set(v)
        state = v and true or false
        if state then
            UI.tween(btn, 0.2, { BackgroundColor3 = Theme.Accent })
            UI.tween(knob, 0.2, { Position = UDim2.new(1, -21, 0.5, 0) })
            lbl.Text = "ON"
        else
            UI.tween(btn, 0.2, { BackgroundColor3 = Color3.fromRGB(60, 40, 100) })
            UI.tween(knob, 0.2, { Position = UDim2.new(0, 3, 0.5, 0) })
            lbl.Text = "OFF"
        end
        if onChange then onChange(state) end
    end
    btn.MouseButton1Click:Connect(function() set(not state) end)
    if default then set(true) end
    return set
end

function Widgets.slider(parent, label, min, max, default, dp, suffix, onChange)
    local f = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 54),
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        ZIndex = 55,
        Parent = parent,
    })
    UI.corner(f, 8)

    UI.new("TextLabel", {
        Position = UDim2.new(0, 12, 0, 4),
        Size = UDim2.new(1, -80, 0, 18),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = label,
        ZIndex = 56,
        Parent = f,
    })
    local val = UI.new("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 4),
        Size = UDim2.new(0, 80, 0, 18),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 13,
        TextColor3 = Theme.AccentGlow,
        TextXAlignment = Enum.TextXAlignment.Right,
        Text = tostring(default),
        ZIndex = 56,
        Parent = f,
    })

    local track = UI.new("Frame", {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 12, 1, -12),
        Size = UDim2.new(1, -24, 0, 6),
        BackgroundColor3 = Color3.fromRGB(40, 28, 70),
        BorderSizePixel = 0,
        ZIndex = 56,
        Parent = f,
    })
    UI.corner(track, 3)
    local fill = UI.new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 57,
        Parent = track,
    })
    UI.corner(fill, 3)
    UI.gradient(fill, ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.AccentDeep),
        ColorSequenceKeypoint.new(1, Theme.AccentGlow),
    }, 0)
    local nub = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        ZIndex = 58,
        Parent = track,
    })
    UI.corner(nub, 7)

    local function fmt(v)
        if dp and dp > 0 then
            return string.format("%." .. dp .. "f%s", v, suffix or "")
        end
        return string.format("%d%s", math.floor(v + 0.5), suffix or "")
    end

    local current = default
    local function set(v, silent)
        v = clamp(v, min, max)
        current = v
        local alpha = (v - min) / (max - min)
        fill.Size = UDim2.new(alpha, 0, 1, 0)
        nub.Position = UDim2.new(alpha, 0, 0.5, 0)
        val.Text = fmt(v)
        if not silent and onChange then onChange(v) end
    end

    local dragging = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            set(min + rel * (max - min))
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and
           input.UserInputType ~= Enum.UserInputType.Touch then return end
        local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        set(min + rel * (max - min))
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    set(default, true)
    return set
end

function Widgets.dropdown(parent, label, options, default, onChange)
    local f = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        ZIndex = 55,
        Parent = parent,
    })
    UI.corner(f, 8)

    UI.new("TextLabel", {
        Position = UDim2.new(0, 12, 0, 4),
        Size = UDim2.new(1, -140, 0, 18),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = label,
        ZIndex = 56,
        Parent = f,
    })

    local btn = UI.new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 150, 0, 28),
        BackgroundColor3 = Theme.PanelHi,
        AutoButtonColor = false,
        Font = Theme.FontBold,
        TextSize = 12,
        TextColor3 = Theme.AccentGlow,
        Text = tostring(default) .. "  v",
        BorderSizePixel = 0,
        ZIndex = 56,
        Parent = f,
    })
    UI.corner(btn, 6)
    UI.stroke(btn, Theme.Border, 1, 0.5)

    local open = false
    local popup
    local function close()
        if popup then popup:Destroy() popup = nil end
        open = false
    end
    btn.MouseButton1Click:Connect(function()
        if open then close() return end
        open = true
        popup = UI.new("Frame", {
            Position = UDim2.new(0, 0, 1, 4),
            Size = UDim2.new(1, 0, 0, #options * 26 + 4),
            BackgroundColor3 = Theme.Panel,
            BorderSizePixel = 0,
            ZIndex = 999,
            Parent = btn,
        })
        UI.corner(popup, 6)
        UI.stroke(popup, Theme.Border, 1, 0.3)
        UI.pad(popup, 2)
        UI.list(popup, Enum.FillDirection.Vertical, 2)
        for _, opt in ipairs(options) do
            local b = UI.new("TextButton", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundColor3 = Theme.Panel2,
                AutoButtonColor = false,
                Font = Theme.FontReg,
                TextSize = 12,
                TextColor3 = Theme.Text,
                Text = tostring(opt),
                BorderSizePixel = 0,
                ZIndex = 999,
                Parent = popup,
            })
            UI.corner(b, 4)
            b.MouseEnter:Connect(function() b.BackgroundColor3 = Theme.PanelHi end)
            b.MouseLeave:Connect(function() b.BackgroundColor3 = Theme.Panel2 end)
            b.MouseButton1Click:Connect(function()
                btn.Text = tostring(opt) .. "  v"
                if onChange then onChange(opt) end
                close()
            end)
        end
    end)
    return btn
end

function Widgets.input(parent, label, placeholder, onSubmit)
    local f = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        ZIndex = 55,
        Parent = parent,
    })
    UI.corner(f, 8)

    UI.new("TextLabel", {
        Position = UDim2.new(0, 12, 0, 4),
        Size = UDim2.new(1, -220, 0, 18),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = label,
        ZIndex = 56,
        Parent = f,
    })

    local box = UI.new("TextBox", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -78, 0.5, 0),
        Size = UDim2.new(0, 140, 0, 28),
        BackgroundColor3 = Theme.PanelHi,
        BorderSizePixel = 0,
        Font = Theme.FontReg,
        TextSize = 12,
        TextColor3 = Theme.Text,
        PlaceholderText = placeholder or "",
        PlaceholderColor3 = Theme.TextDim,
        Text = "",
        ClearTextOnFocus = false,
        ZIndex = 56,
        Parent = f,
    })
    UI.corner(box, 6)
    UI.stroke(box, Theme.Border, 1, 0.5)
    UI.pad(box, 0, 8, 0, 8)

    local btn = UI.new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 60, 0, 28),
        BackgroundColor3 = Theme.Accent,
        AutoButtonColor = false,
        Font = Theme.FontBold,
        TextSize = 12,
        TextColor3 = Theme.Text,
        Text = "APPLY",
        BorderSizePixel = 0,
        ZIndex = 56,
        Parent = f,
    })
    UI.corner(btn, 6)

    btn.MouseButton1Click:Connect(function()
        if onSubmit then onSubmit(box.Text) end
    end)
    box.FocusLost:Connect(function(enter)
        if enter and onSubmit then onSubmit(box.Text) end
    end)
    return box
end

function Widgets.colorPicker(parent, label, default, onChange)
    local palette = {
        Color3.fromRGB(255,255,255), Color3.fromRGB(210,210,210), Color3.fromRGB(170,170,170),
        Color3.fromRGB(130,130,130), Color3.fromRGB(90,90,90),   Color3.fromRGB(60,60,60),
        Color3.fromRGB(35,35,35),    Color3.fromRGB(15,15,15),
        Color3.fromRGB(255,60,60),   Color3.fromRGB(255,140,60), Color3.fromRGB(255,210,60),
        Color3.fromRGB(170,255,60),  Color3.fromRGB(60,240,120), Color3.fromRGB(60,220,220),
        Color3.fromRGB(60,140,255),  Color3.fromRGB(90,70,255),
        Color3.fromRGB(170,100,255), Color3.fromRGB(255,60,240), Color3.fromRGB(255,90,150),
        Color3.fromRGB(200,120,60),  Color3.fromRGB(130,200,80), Color3.fromRGB(70,180,140),
        Color3.fromRGB(80,120,200),  Color3.fromRGB(140,100,200),
        Color3.fromRGB(80,255,255),  Color3.fromRGB(140,170,255), Color3.fromRGB(170,120,255),
        Color3.fromRGB(255,130,230),
    }

    local f = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 150),
        BackgroundColor3 = Theme.Panel2,
        BorderSizePixel = 0,
        ZIndex = 55,
        Parent = parent,
    })
    UI.corner(f, 8)
    UI.pad(f, 10, 12, 10, 12)

    local header = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        ZIndex = 56,
        Parent = f,
    })
    UI.new("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = label,
        ZIndex = 57,
        Parent = header,
    })
    local swatch = UI.new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.new(0, 64, 0, 16),
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        ZIndex = 57,
        Parent = header,
    })
    UI.corner(swatch, 8)
    UI.stroke(swatch, Theme.Border, 1, 0.3)

    local grid = UI.new("Frame", {
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 1, -30),
        BackgroundTransparency = 1,
        ZIndex = 56,
        Parent = f,
    })
    UI.new("UIGridLayout", {
        CellSize = UDim2.new(0, 28, 0, 22),
        CellPadding = UDim2.new(0, 6, 0, 6),
        FillDirectionMaxCells = 7,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Parent = grid,
    })

    for i, c in ipairs(palette) do
        local b = UI.new("TextButton", {
            BackgroundColor3 = c,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = i,
            ZIndex = 57,
            Parent = grid,
        })
        UI.corner(b, 5)
        b.MouseEnter:Connect(function() UI.stroke(b, Theme.AccentGlow, 2, 0) end)
        b.MouseLeave:Connect(function()
            local s = b:FindFirstChildOfClass("UIStroke")
            if s then s:Destroy() end
        end)
        b.MouseButton1Click:Connect(function()
            swatch.BackgroundColor3 = c
            if onChange then onChange(c) end
        end)
    end

    return function(c) swatch.BackgroundColor3 = c end
end

-- =====================================================================
-- Player helpers
-- =====================================================================
local function getHRP(player)
    local c = player.Character
    if not c then return nil end
    return c:FindFirstChild("HumanoidRootPart")
end

local function getPart(player, name)
    local c = player.Character
    if not c then return nil end
    return c:FindFirstChild(name) or c:FindFirstChild("HumanoidRootPart")
end

local function isTeammate(player)
    if not Flags.AimTeamCheck and not Flags.ESPTeamCheck then return false end
    local me = LocalPlayer
    if not me.Team or not player.Team then return false end
    return me.Team == player.Team
end

local function alive(player)
    local c = player.Character
    if not c then return false end
    local h = c:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function visible(fromPos, toPart)
    if not toPart then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, Camera() }
    local r = Workspace:Raycast(fromPos, (toPart.Position - fromPos), params)
    if not r then return true end
    return r.Instance:IsDescendantOf(toPart.Parent)
end

-- =====================================================================
-- AIMBOT
-- =====================================================================
local Aim = {}
Aim.FOVCircle = nil

local function makeFOV()
    local f = UI.new("Frame", {
        Name = "FOVCircle",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 180, 0, 180),
        ZIndex = 20,
        Parent = Root,
    })
    local ring = UI.new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 20,
        Parent = f,
    })
    UI.corner(ring, 999)
    UI.stroke(ring, Theme.Accent, 2, 0.2)
    f.Visible = false
    return f
end

function Aim.init()
    Aim.FOVCircle = makeFOV()

    local function updateFOV()
        if not Aim.FOVCircle then return end
        if Flags.AimbotEnabled and Flags.AimShowFOV then
            Aim.FOVCircle.Visible = true
            local vp = Camera().ViewportSize
            Aim.FOVCircle.Position = UDim2.new(0, vp.X / 2, 0, vp.Y / 2)
            Aim.FOVCircle.Size = UDim2.new(0, Flags.AimFOV * 2, 0, Flags.AimFOV * 2)
        else
            Aim.FOVCircle.Visible = false
        end
    end
    RunService.RenderStepped:Connect(updateFOV)

    local aiming = false
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Flags.AimKey then aiming = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Flags.AimKey then aiming = false end
    end)

    RunService.RenderStepped:Connect(function()
        if not Flags.AimbotEnabled then return end
        if not aiming then return end
        local target = Aim.findTarget()
        if not target then return end
        local part = getPart(target, Flags.AimPart)
        if not part then return end

        local predict = Vector3.new(0,0,0)
        if Flags.AimPrediction > 0 and part.AssemblyLinearVelocity then
            predict = part.AssemblyLinearVelocity * Flags.AimPrediction
        end
        local aimAt = part.Position + predict

        local cam = Camera()
        local lookCF = cam.CFrame
        local targetCF = CFrame.new(cam.CFrame.Position, aimAt)
        local smooth = clamp(Flags.AimSmooth, 0.05, 1)
        cam.CFrame = lookCF:Lerp(targetCF, 1 - math.pow(1 - smooth, 2))
    end)
end

function Aim.findTarget()
    local best, bestDist = nil, math.huge
    local vp = Camera().ViewportSize
    local center = Vector2.new(vp.X / 2, vp.Y / 2)
    local camPos = Camera().CFrame.Position

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and alive(p) and not isTeammate(p) then
            local part = getPart(p, Flags.AimPart)
            if part then
                local screen, onScreen = Camera():WorldToViewportPoint(part.Position)
                if onScreen then
                    local d = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                    if d <= Flags.AimFOV then
                        local ok = true
                        if Flags.AimVisibleCheck and not Flags.AimWallbang then
                            ok = visible(camPos, part)
                        end
                        if ok and d < bestDist then
                            bestDist = d
                            best = p
                        end
                    end
                end
            end
        end
    end
    return best
end

-- =====================================================================
-- ESP
-- =====================================================================
local ESP = {}
ESP.cache = {}

function ESP.create(player)
    if ESP.cache[player] then return end
    local gui = UI.new("BillboardGui", {
        Name = "SH_ESP_" .. player.Name,
        AlwaysOnTop = true,
        LightInfluence = 0,
        Size = UDim2.new(0, 120, 0, 150),
        MaxDistance = Flags.ESPMaxDistance,
        Parent = Root,
    })
    local box = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = gui,
    })
    UI.stroke(box, Theme.Accent, 2, 0)

    local nameLbl = UI.new("TextLabel", {
        Position = UDim2.new(0, 0, 0, -22),
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Theme.FontBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextStrokeTransparency = 0.4,
        Text = player.DisplayName or player.Name,
        Parent = gui,
    })
    local distLbl = UI.new("TextLabel", {
        Position = UDim2.new(0, 0, 1, 2),
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Font = Theme.FontReg,
        TextSize = 11,
        TextColor3 = Theme.TextDim,
        TextStrokeTransparency = 0.4,
        Text = "0m",
        Parent = gui,
    })
    local hpBg = UI.new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(0, -4, 0.5, 0),
        Size = UDim2.new(0, 3, 1, -8),
        BackgroundColor3 = Color3.fromRGB(30, 20, 40),
        BorderSizePixel = 0,
        Parent = gui,
    })
    local hpFill = UI.new("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Success,
        BorderSizePixel = 0,
        Parent = hpBg,
    })

    ESP.cache[player] = {
        gui = gui, box = box, name = nameLbl, dist = distLbl,
        hpBg = hpBg, hpFill = hpFill,
    }

    local function bind(char)
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp then gui.Adornee = hrp end
    end
    if player.Character then bind(player.Character) end
    player.CharacterAdded:Connect(bind)
end

function ESP.destroy(player)
    local e = ESP.cache[player]
    if not e then return end
    e.gui:Destroy()
    ESP.cache[player] = nil
end

function ESP.init()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then ESP.create(p) end
    end
    Players.PlayerAdded:Connect(function(p) if p ~= LocalPlayer then ESP.create(p) end end)
    Players.PlayerRemoving:Connect(function(p) ESP.destroy(p) end)

    local function updateOne(p, e, camPos)
        if not p.Character or not alive(p) then
            e.gui.Enabled = false
            return
        end
        local vis = Flags.ESPEnabled
        if Flags.ESPTeamCheck and isTeammate(p) then vis = false end
        e.gui.Enabled = vis
        if not vis then return end

        local part = getHRP(p)
        if not part then return end
        local d = (camPos - part.Position).Magnitude
        if d > Flags.ESPMaxDistance then
            e.gui.Enabled = false
            return
        end

        e.box.Visible  = Flags.ESPBox
        e.name.Visible = Flags.ESPName
        e.dist.Visible = Flags.ESPDistance
        e.hpBg.Visible = Flags.ESPHealth
        e.dist.Text = string.format("%dm", math.floor(d))

        local col = isTeammate(p) and Flags.ESPColor or Flags.ESPEnemyColor
        local stroke = e.box:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = col end

        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local pct = hum.Health / math.max(1, hum.MaxHealth)
            e.hpFill.Size = UDim2.new(1, 0, pct, 0)
            e.hpFill.BackgroundColor3 = Color3.fromRGB(
                math.floor(255 * (1 - pct)),
                math.floor(220 * pct),
                math.floor(120 * pct)
            )
        end
    end

    RunService.RenderStepped:Connect(function()
        local camPos = Camera().CFrame.Position
        for p, e in pairs(ESP.cache) do
            updateOne(p, e, camPos)
        end
    end)
end

-- =====================================================================
-- MOVEMENT: Bhop / InfJump / Noclip / JumpPower / Gravity
-- =====================================================================
local Movement = {}

function Movement.init()
    -- Bhop
    RunService.RenderStepped:Connect(function()
        if not Flags.Bhop then return end
        local c = LocalPlayer.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if hum:GetState() ~= Enum.HumanoidStateType.Jumping then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)

    -- InfJump
    UserInputService.JumpRequest:Connect(function()
        if not Flags.InfJump then return end
        local c = LocalPlayer.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)

    -- Noclip
    RunService.Stepped:Connect(function()
        if not Flags.Noclip then return end
        local c = LocalPlayer.Character
        if not c then return end
        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)

    -- Apply JumpPower & Gravity when character spawns + on change
    local function applyMovement()
        pcall(function() Workspace.Gravity = Flags.Gravity end)
        local c = LocalPlayer.Character
        if not c then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = Flags.JumpPower
        end
    end
    Movement.applyMovement = applyMovement
    LocalPlayer.CharacterAdded:Connect(function() task.wait(0.3) applyMovement() end)
end

-- =====================================================================
-- HITBOX EXPANDER (visual client-side scale, head/HRP)
-- =====================================================================
local Hitbox = {}
Hitbox.saved = setmetatable({}, { __mode = "k" })

function Hitbox.scalePart(part, size)
    if not Hitbox.saved[part] then
        Hitbox.saved[part] = {
            Size = part.Size,
            Transparency = part.Transparency,
            Material = part.Material,
        }
    end
    part.Size = Vector3.new(size, size, size)
    part.Transparency = 0.6
    part.Material = Enum.Material.ForceField
    part.CanCollide = false
    part.Massless = true
end

function Hitbox.restore(part)
    local s = Hitbox.saved[part]
    if s then
        part.Size = s.Size
        part.Transparency = s.Transparency
        part.Material = s.Material
    end
end

function Hitbox.init()
    RunService.Heartbeat:Connect(function()
        if not Flags.HitboxEnabled then
            for part, _ in pairs(Hitbox.saved) do
                if part and part.Parent then Hitbox.restore(part) end
                Hitbox.saved[part] = nil
            end
            return
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and alive(p) and not isTeammate(p) then
                local part = getPart(p, Flags.HitboxTarget)
                if part then Hitbox.scalePart(part, Flags.HitboxSize) end
            end
        end
    end)
end

-- =====================================================================
-- VISUAL SKIN CHANGER
-- Resolves a skin name against ReplicatedStorage asset trees commonly used
-- by Rivals-style games, clones a template, and visually swaps the handle
-- of the player's currently equipped tool. Local-only, cosmetic.
-- =====================================================================
local Skin = {}
Skin.active = nil
Skin.inventory = {}

local function searchForSkin(name)
    name = string.lower(name)
    local candidates = {}
    for _, root in ipairs({ ReplicatedStorage, Workspace }) do
        for _, inst in ipairs(root:GetDescendants()) do
            if (inst:IsA("Tool") or inst:IsA("Model")) and
               string.find(string.lower(inst.Name), name, 1, true) then
                table.insert(candidates, inst)
                if #candidates >= 6 then return candidates end
            end
        end
    end
    return candidates
end

function Skin.add(name)
    if name == "" then return nil end
    local hits = searchForSkin(name)
    if #hits == 0 then
        notify("skin changer", "no match for \"" .. name .. "\"", "warn")
        return nil
    end
    local best = hits[1]
    local entry = {
        name = best.Name,
        source = best,
    }
    table.insert(Skin.inventory, entry)
    notify("skin changer", "added: " .. best.Name, "good")
    return entry
end

function Skin.equip(entry)
    if not entry then return end
    local c = LocalPlayer.Character
    if not c then return end
    local tool = c:FindFirstChildOfClass("Tool")
    if not tool then
        notify("skin changer", "equip a tool first", "warn")
        return
    end
    local handle = tool:FindFirstChild("Handle")
    if not handle then
        notify("skin changer", "tool has no handle", "warn")
        return
    end

    local src = entry.source
    local srcHandle
    if src:IsA("Tool") then
        srcHandle = src:FindFirstChild("Handle")
    else
        srcHandle = src:FindFirstChildWhichIsA("BasePart", true)
    end
    if not srcHandle then
        notify("skin changer", "source has no mesh", "warn")
        return
    end

    for _, child in ipairs(handle:GetChildren()) do
        if child:IsA("SpecialMesh") or child:IsA("MeshPart") or
           child:IsA("Decal") or child:IsA("Texture") then
            child:Destroy()
        end
    end

    for _, child in ipairs(srcHandle:GetChildren()) do
        if child:IsA("SpecialMesh") or child:IsA("Decal") or child:IsA("Texture") then
            child:Clone().Parent = handle
        end
    end
    handle.Color = srcHandle.Color
    handle.Material = srcHandle.Material

    Skin.active = entry
    notify("skin changer", "equipped visually: " .. entry.name, "good")
end

-- =====================================================================
-- BUILD HUB CONTENT
-- =====================================================================
local function buildHub()
    local scroll, title = Hub.build()

    -- AIMBOT section
    local sAim = Widgets.section(scroll, "Aimbot", "(detectable)")
    Widgets.toggle(sAim, "Enabled", "silent-ish camera lock, hold aim key", false, nil,
        function(v) Flags.AimbotEnabled = v end)
    Widgets.toggle(sAim, "Show FOV Circle", "overlay the fov radius", true, nil,
        function(v) Flags.AimShowFOV = v end)
    Widgets.toggle(sAim, "Team Check", "skip teammates", true, nil,
        function(v) Flags.AimTeamCheck = v end)
    Widgets.toggle(sAim, "Visible Check", "require line of sight", true, nil,
        function(v) Flags.AimVisibleCheck = v end)
    Widgets.toggle(sAim, "Wallbang", "ignore line of sight", false, "(very detectable)",
        function(v) Flags.AimWallbang = v end)
    Widgets.slider(sAim, "FOV Radius", 20, 400, Flags.AimFOV, 0, "px",
        function(v) Flags.AimFOV = v end)
    Widgets.slider(sAim, "Smoothness", 0.05, 1, Flags.AimSmooth, 2, "",
        function(v) Flags.AimSmooth = v end)
    Widgets.slider(sAim, "Prediction", 0, 0.5, Flags.AimPrediction, 2, "s",
        function(v) Flags.AimPrediction = v end)
    Widgets.dropdown(sAim, "Target Part", { "Head", "Torso", "HumanoidRootPart" }, Flags.AimPart,
        function(v) Flags.AimPart = v end)
    Widgets.dropdown(sAim, "Aim Key",
        { "RightMouse", "LeftMouse", "MiddleMouse", "LeftShift", "E", "C" },
        "RightMouse",
        function(v)
            local map = {
                RightMouse  = Enum.UserInputType.MouseButton2,
                LeftMouse   = Enum.UserInputType.MouseButton1,
                MiddleMouse = Enum.UserInputType.MouseButton3,
                LeftShift   = Enum.KeyCode.LeftShift,
                E = Enum.KeyCode.E,
                C = Enum.KeyCode.C,
            }
            Flags.AimKey = map[v] or Enum.UserInputType.MouseButton2
        end)

    -- ESP section
    local sESP = Widgets.section(scroll, "Player ESP", "(client-side, undetectable)")
    Widgets.toggle(sESP, "Enabled", "box + name + distance + health", false, nil,
        function(v) Flags.ESPEnabled = v end)
    Widgets.toggle(sESP, "Boxes", "", true, nil, function(v) Flags.ESPBox = v end)
    Widgets.toggle(sESP, "Names", "", true, nil, function(v) Flags.ESPName = v end)
    Widgets.toggle(sESP, "Distance", "", true, nil, function(v) Flags.ESPDistance = v end)
    Widgets.toggle(sESP, "Health Bar", "", true, nil, function(v) Flags.ESPHealth = v end)
    Widgets.toggle(sESP, "Team Check", "hide teammates", true, nil,
        function(v) Flags.ESPTeamCheck = v end)
    Widgets.slider(sESP, "Max Distance", 100, 5000, Flags.ESPMaxDistance, 0, "",
        function(v) Flags.ESPMaxDistance = v end)
    Widgets.colorPicker(sESP, "Box Color (enemy)", Flags.ESPEnemyColor,
        function(c) Flags.ESPEnemyColor = c end)
    Widgets.colorPicker(sESP, "Box Color (team)", Flags.ESPColor,
        function(c) Flags.ESPColor = c end)

    -- MOVEMENT section
    local sMov = Widgets.section(scroll, "Movement", "(server-replicated — detectable)")
    Widgets.toggle(sMov, "Bunnyhop", "auto-jump while space held", false, nil,
        function(v) Flags.Bhop = v end)
    Widgets.toggle(sMov, "Infinite Jump", "jump mid-air forever", false, "(very detectable)",
        function(v) Flags.InfJump = v end)
    Widgets.toggle(sMov, "No Clip", "ignore collisions", false, "(very detectable)",
        function(v) Flags.Noclip = v end)
    Widgets.slider(sMov, "Jump Power", 10, 500, Flags.JumpPower, 0, "",
        function(v) Flags.JumpPower = v; Movement.applyMovement() end)
    Widgets.slider(sMov, "Gravity", 0, 400, Flags.Gravity, 1, "",
        function(v) Flags.Gravity = v; Movement.applyMovement() end)

    -- COMBAT section
    local sCom = Widgets.section(scroll, "Combat", "(detectable)")
    Widgets.toggle(sCom, "Hitbox Expander", "scale target part client-side", false, nil,
        function(v) Flags.HitboxEnabled = v end)
    Widgets.slider(sCom, "Hitbox Size", 2, 25, Flags.HitboxSize, 0, " studs",
        function(v) Flags.HitboxSize = v end)
    Widgets.dropdown(sCom, "Hitbox Target", { "Head", "HumanoidRootPart" }, Flags.HitboxTarget,
        function(v) Flags.HitboxTarget = v end)

    -- SKIN CHANGER section
    local sSkin = Widgets.section(scroll, "Visual Skin Changer", "(cosmetic · local only)")
    Widgets.input(sSkin, "Skin / Weapon Name", "e.g. Katana, M4A1, Ice Dragon",
        function(txt)
            Flags.SkinName = txt
            Skin.add(txt)
            buildInventory() -- re-render list
        end)

    local invHolder = UI.new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = sSkin,
    })
    UI.list(invHolder, Enum.FillDirection.Vertical, 4)

    function buildInventory()
        for _, c in ipairs(invHolder:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        if #Skin.inventory == 0 then
            UI.new("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Font = Theme.FontReg,
                TextSize = 11,
                TextColor3 = Theme.TextDim,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "inventory empty — add a skin above",
                Parent = invHolder,
            })
            return
        end
        for _, entry in ipairs(Skin.inventory) do
            local row = UI.new("Frame", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = Theme.PanelHi,
                BorderSizePixel = 0,
                Parent = invHolder,
            })
            UI.corner(row, 6)
            UI.new("TextLabel", {
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -170, 1, 0),
                BackgroundTransparency = 1,
                Font = Theme.FontReg,
                TextSize = 12,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = entry.name,
                Parent = row,
            })
            local eq = UI.new("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -80, 0.5, 0),
                Size = UDim2.new(0, 64, 0, 22),
                BackgroundColor3 = Theme.Accent,
                AutoButtonColor = false,
                Font = Theme.FontBold,
                TextSize = 11,
                TextColor3 = Theme.Text,
                Text = "EQUIP",
                BorderSizePixel = 0,
                Parent = row,
            })
            UI.corner(eq, 5)
            eq.MouseButton1Click:Connect(function() Skin.equip(entry) end)

            local del = UI.new("TextButton", {
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -10, 0.5, 0),
                Size = UDim2.new(0, 64, 0, 22),
                BackgroundColor3 = Theme.Danger,
                AutoButtonColor = false,
                Font = Theme.FontBold,
                TextSize = 11,
                TextColor3 = Theme.Text,
                Text = "DROP",
                BorderSizePixel = 0,
                Parent = row,
            })
            UI.corner(del, 5)
            del.MouseButton1Click:Connect(function()
                for i, e in ipairs(Skin.inventory) do
                    if e == entry then table.remove(Skin.inventory, i); break end
                end
                buildInventory()
            end)
        end
    end
    buildInventory()

    -- MISC section
    local sMisc = Widgets.section(scroll, "Misc")
    Widgets.toggle(sMisc, "Hide Hub", "press RSHIFT instead", false, nil,
        function(v) Hub.window.Visible = not v end)
    local unloadBtn = UI.new("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Theme.Danger,
        AutoButtonColor = false,
        Font = Theme.FontBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        Text = "UNLOAD SNOWY HUB",
        BorderSizePixel = 0,
        Parent = sMisc,
    })
    UI.corner(unloadBtn, 6)
    unloadBtn.MouseButton1Click:Connect(function()
        Root:Destroy()
        _G.SnowyHubRunning = nil
    end)
end

-- =====================================================================
-- HOTKEY
-- =====================================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if Hub.window then
            Hub.window.Visible = not Hub.window.Visible
        end
    end
end)

-- =====================================================================
-- BOOT
-- =====================================================================
local function safe_call(name, fn)
    local ok, err = pcall(fn)
    if not ok then
        warn("[SnowyHub] " .. name .. " failed: " .. tostring(err))
    end
end

safe_call("Aim.init",      function() Aim.init() end)
safe_call("ESP.init",      function() ESP.init() end)
safe_call("Movement.init", function() Movement.init() end)
safe_call("Hitbox.init",   function() Hitbox.init() end)

print("[SnowyHub] boot — v1.1, commit pending")

local hubShown = false
local function showHub()
    if hubShown then return end
    hubShown = true
    print("[SnowyHub] showing hub")
    safe_call("buildHub", function() buildHub() end)
    pcall(function()
        notify("snowy hub", "loaded — right shift to hide", "good", 5)
        notify("made by crscx", "aim · esp · movement · combat · skins", "", 6)
    end)
    print("[SnowyHub] hub up")
end

-- watchdog: if cutscene hangs or errors, force the hub up after 6s
task.delay(6, function()
    if not hubShown then
        warn("[SnowyHub] watchdog fired — cutscene stalled, forcing hub")
        showHub()
    end
end)

task.spawn(function()
    safe_call("Intro.build", function()
        Intro.build(showHub)
    end)
end)
