-- Safe cleanup loop
for _,o in pairs(game.CoreGui:GetChildren()) do 
    if o.Name == "NexusRadar" then 
        o:Destroy() 
    end 
end

local P = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local LP = P.LocalPlayer

local Settings = {
    RadarRange = 150,
    DotSize = 8,
    ShowNames = true,
    ShowDist = true,
    Minimized = false,
    ESPEnabled = false,
}

local Th = {
    BG = Color3.fromRGB(10,10,20),
    RadarBG = Color3.fromRGB(12,18,12),
    RadarRing = Color3.fromRGB(0,180,80),
    RadarGrid = Color3.fromRGB(0,80,30),
    RadarCenter = Color3.fromRGB(100,255,160),
    NpcDot = Color3.fromRGB(255,60,60),
    NpcName = Color3.fromRGB(255,180,180),
    Bar = Color3.fromRGB(15,22,15),
    Acc = Color3.fromRGB(0,200,80),
    AccG = Color3.fromRGB(100,255,160),
    Sub = Color3.fromRGB(120,160,120),
    BtnN = Color3.fromRGB(20,35,20),
    Panel = Color3.fromRGB(15,25,15),
    Warn = Color3.fromRGB(255,180,60),
    Err = Color3.fromRGB(255,80,80),
}

local RADAR_SIZE = 200
local RADAR_RADIUS = RADAR_SIZE / 2
local isDestroyed = false

-- Safe UI Creator (No pcall loops that crash L8 executors)
local function Create(cls, props, parent)
    local inst = Instance.new(cls)
    for k, v in next, props do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local function AddCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function TweenObj(obj, props, duration)
    TS:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- Main GUI Setup
local SG = Create("ScreenGui", {Name = "NexusRadar", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, game.CoreGui)

local Main = Create("Frame", {
    Size = UDim2.new(0, RADAR_SIZE+20, 0, RADAR_SIZE+70),
    Position = UDim2.new(1, -(RADAR_SIZE+30), 0, 10),
    BackgroundColor3 = Th.BG,
    BorderSizePixel = 0,
    ClipsDescendants = true
}, SG)
AddCorner(Main, 12)

local Top = Create("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Th.Bar, BorderSizePixel = 0, ZIndex = 20}, Main)
AddCorner(Top, 12)
Create("Frame", {Size = UDim2.new(1, 0, 0.5, 0), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Th.Bar, BorderSizePixel = 0}, Top)
Create("Frame", {Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), BackgroundColor3 = Th.Acc, BorderSizePixel = 0}, Top)
Create("TextLabel", {Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "[NPC RADAR]", TextColor3 = Th.AccG, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left}, Top)

local countLbl = Create("TextLabel", {Size = UDim2.new(0, 50, 1, 0), Position = UDim2.new(1, -140, 0, 0), BackgroundTransparency = 1, Text = "0 NPCs", TextColor3 = Th.Sub, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right}, Top)

local EspB = Create("TextButton", {Size = UDim2.new(0, 32, 0, 24), Position = UDim2.new(1, -88, 0, 4), BackgroundColor3 = Th.BtnN, Text = "ESP", TextColor3 = Th.Sub, Font = Enum.Font.GothamBold, TextSize = 9, BorderSizePixel = 0, ZIndex = 22}, Top)
AddCorner(EspB, 6)

local MinB = Create("TextButton", {Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -54, 0, 4), BackgroundColor3 = Th.Warn, Text = "-", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 14, BorderSizePixel = 0, ZIndex = 22}, Top)
AddCorner(MinB, 6)

local CloseB = Create("TextButton", {Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(1, -26, 0, 4), BackgroundColor3 = Th.Err, Text = "X", TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize = 11, BorderSizePixel = 0, ZIndex = 22}, Top)
AddCorner(CloseB, 6)

local RadarFrame = Create("Frame", {Size = UDim2.new(0, RADAR_SIZE, 0, RADAR_SIZE), Position = UDim2.new(0, 10, 0, 38), BackgroundColor3 = Th.RadarBG, BorderSizePixel = 0, ClipsDescendants = true}, Main)
AddCorner(RadarFrame, RADAR_RADIUS)

local Ring = Create("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0}, RadarFrame)
Instance.new("UIStroke", Ring).Color = Th.RadarRing
Ring.UIStroke.Thickness = 2
Ring.UIStroke.Transparency = 0.3
AddCorner(Ring, RADAR_RADIUS)

Create("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Th.RadarGrid, BorderSizePixel = 0}, RadarFrame)
Create("Frame", {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundColor3 = Th.RadarGrid, BorderSizePixel = 0}, RadarFrame)

local InnerRing = Create("Frame", {Size = UDim2.new(0.5, 0, 0.5, 0), Position = UDim2.new(0.25, 0, 0.25, 0), BackgroundTransparency = 1, BorderSizePixel = 0}, RadarFrame)
Instance.new("UIStroke", InnerRing).Color = Th.RadarGrid
InnerRing.UIStroke.Thickness = 1
InnerRing.UIStroke.Transparency = 0.5
AddCorner(InnerRing, 50)

Create("Frame", {Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0.5, -5, 0.5, -5), BackgroundColor3 = Th.RadarCenter, BorderSizePixel = 0, ZIndex = 10}, RadarFrame)
Create("TextLabel", {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0.5, -8, 0.5, -16), BackgroundTransparency = 1, Text = "^", TextColor3 = Th.RadarCenter, Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 11}, RadarFrame)

local InfoBar = Create("Frame", {Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 1, -32), BackgroundColor3 = Th.Panel, BorderSizePixel = 0}, Main)
AddCorner(InfoBar, 8)
Instance.new("UIPadding", InfoBar).PaddingLeft = UDim.new(0, 8)
InfoBar.UIPadding.PaddingRight = UDim.new(0, 8)

local rangeLbl = Create("TextLabel", {Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, Text = "Range: 150", TextColor3 = Th.Sub, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left}, InfoBar)
local dirLbl = Create("TextLabel", {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundTransparency = 1, Text = "N", TextColor3 = Th.AccG, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right}, InfoBar)

-- Pools
local dotPool = {}
local espPool = {}
local cachedNPCs = {}

local function GetOrCreateDot(index)
    if dotPool[index] then
        dotPool[index].dot.Visible = true
        dotPool[index].nameLbl.Visible = true
        return dotPool[index]
    end
    
    local dot = Create("Frame", {Size = UDim2.new(0, Settings.DotSize, 0, Settings.DotSize), BackgroundColor3 = Th.NpcDot, BorderSizePixel = 0, ZIndex = 8, Visible = true}, RadarFrame)
    AddCorner(dot, 4)
    
    local pulse = Create("Frame", {Size = UDim2.new(0, Settings.DotSize+6, 0, Settings.DotSize+6), BackgroundColor3 = Th.NpcDot, BackgroundTransparency = 0.6, BorderSizePixel = 0, ZIndex = 7}, RadarFrame)
    AddCorner(pulse, 8)
    
    local nameLbl = Create("TextLabel", {Size = UDim2.new(0, 80, 0, 24), BackgroundTransparency = 1, Text = "", TextColor3 = Th.NpcName, Font = Enum.Font.Gotham, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 9, Visible = true}, RadarFrame)

    dotPool[index] = {dot = dot, pulse = pulse, nameLbl = nameLbl}
    return dotPool[index]
end

-- Background Scanner (Prevents RenderStepped Crashes)
task.spawn(function()
    while not isDestroyed do
        local playerChars = {}
        for _, plr in ipairs(P:GetPlayers()) do
            if plr.Character then playerChars[plr.Character] = true end
        end

        local npcs = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and not playerChars[obj] then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
                    if root then
                        table.insert(npcs, {model = obj, root = root})
                    end
                end
            end
        end
        cachedNPCs = npcs
        task.wait(0.2)
    end
end)

local function GetCompassDir(angle)
    local dirs = {"N","NE","E","SE","S","SW","W","NW","N"}
    return dirs[math.floor((angle+22.5)/45)%8+1]
end

-- ESP Toggle
EspB.MouseButton1Click:Connect(function()
    Settings.ESPEnabled = not Settings.ESPEnabled
    if Settings.ESPEnabled then
        EspB.BackgroundColor3 = Th.Acc
        EspB.TextColor3 = Color3.new(0,0,0)
    else
        EspB.BackgroundColor3 = Th.BtnN
        EspB.TextColor3 = Th.Sub
        for _, espData in pairs(espPool) do
            if espData.highlight and espData.highlight.Parent then espData.highlight.Enabled = false end
            if espData.billboard and espData.billboard.Parent then espData.billboard.Enabled = false end
        end
    end
end)

-- Main Render Loop
local pulseT = 0
RS.RenderStepped:Connect(function(dt)
    if isDestroyed then return end
    local char = LP.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if Settings.Minimized then return end

    pulseT = pulseT + dt
    local _, yaw, _ = root.CFrame:ToEulerAnglesYXZ()
    local compassDeg = math.deg(-yaw)
    if compassDeg < 0 then compassDeg = compassDeg + 360 end
    dirLbl.Text = GetCompassDir(compassDeg)
    
    local npcs = cachedNPCs
    countLbl.Text = #npcs .. " NPCs"

    -- ESP Update
    local activeESP = {}
    if Settings.ESPEnabled then
        for _, npc in ipairs(npcs) do
            local model = npc.model
            local npcRoot = npc.root
            local dist = (npcRoot.Position - root.Position).Magnitude
            activeESP[model] = true

            if not espPool[model] then
                local hl = Instance.new("Highlight")
                hl.FillColor = Th.NpcDot
                hl.OutlineColor = Color3.new(1,1,1)
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0
                hl.Parent = npcRoot

                local bb = Instance.new("BillboardGui")
                bb.Adornee = npcRoot
                bb.Size = UDim2.new(0, 100, 0, 30)
                bb.StudsOffset = Vector3.new(0, 3, 0)
                bb.AlwaysOnTop = true
                bb.Parent = npcRoot

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, 0, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = Color3.new(1,1,1)
                lbl.TextStrokeTransparency = 0.5
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 12
                lbl.TextScaled = true
                lbl.Parent = bb

                espPool[model] = {highlight = hl, billboard = bb, label = lbl}
            end

            espPool[model].highlight.Enabled = true
            espPool[model].billboard.Enabled = true
            espPool[model].label.Text = model.Name .. " | " .. math.floor(dist) .. "m"
        end
    end

    for model, espData in pairs(espPool) do
        if not model.Parent then
            espPool[model] = nil 
        elseif not activeESP[model] then
            espData.highlight.Enabled = false
            espData.billboard.Enabled = false
        end
    end

    -- Radar Dots Update
    local used = {}
    for i, npc in ipairs(npcs) do
        local diff = npc.root.Position - root.Position
        local dist = diff.Magnitude

        if dist <= Settings.RadarRange then
            local cos_y, sin_y = math.cos(yaw), math.sin(yaw)
            local rx = diff.X * cos_y + diff.Z * sin_y
            local rz = -diff.X * sin_y + diff.Z * cos_y
            
            local nx = (rx / Settings.RadarRange) * (RADAR_RADIUS - 6)
            local nz = (rz / Settings.RadarRange) * (RADAR_RADIUS - 6)
            
            local px = RADAR_RADIUS + nx - Settings.DotSize/2
            local py = RADAR_RADIUS + nz - Settings.DotSize/2
            
            local dx = px - (RADAR_RADIUS - Settings.DotSize/2)
            local dz = py - (RADAR_RADIUS - Settings.DotSize/2)
            local mag = math.sqrt(dx*dx + dz*dz)
            local maxR = RADAR_RADIUS - Settings.DotSize - 2
            
            if mag > maxR then
                local sc = maxR / mag
                px = (RADAR_RADIUS - Settings.DotSize/2) + dx * sc
                py = (RADAR_RADIUS - Settings.DotSize/2) + dz * sc
            end

            local entry = GetOrCreateDot(i)
            used[i] = true
            entry.dot.Position = UDim2.new(0, px, 0, py)
            entry.dot.Visible = true
            
            entry.pulse.BackgroundTransparency = 0.6 + 0.4 * math.abs(math.sin(pulseT*3 + i))
            entry.pulse.Position = UDim2.new(0, px-3, 0, py-3)
            entry.pulse.Visible = true
            
            local distRatio = math.clamp(dist / Settings.RadarRange, 0, 1)
            local dotColor = Color3.new(1, distRatio*0.3, distRatio*0.3)
            entry.dot.BackgroundColor3 = dotColor
            entry.pulse.BackgroundColor3 = dotColor
            
            if Settings.ShowNames or Settings.ShowDist then
                local labelText = ""
                if Settings.ShowNames then labelText = npc.model.Name end
                if Settings.ShowDist then labelText = labelText .. (Settings.ShowNames and "\n" or "") .. math.floor(dist) .. "m" end
                entry.nameLbl.Text = labelText
                local lx = px + Settings.DotSize + 2
                if lx > RADAR_SIZE - 60 then lx = px - 62 end
                entry.nameLbl.Position = UDim2.new(0, lx, 0, py - 4)
                entry.nameLbl.Visible = true
            else
                entry.nameLbl.Visible = false
            end
        end
    end

    for i, entry in pairs(dotPool) do
        if not used[i] then
            entry.dot.Visible = false
            entry.pulse.Visible = false
            entry.nameLbl.Visible = false
        end
    end
end)

-- Slider Panel Setup
local sliderPanel = Create("Frame", {Size = UDim2.new(0, 220, 0, 60), Position = UDim2.new(1, -250, 0, 310), BackgroundColor3 = Th.Panel, BorderSizePixel = 0, Active = true}, SG)
AddCorner(sliderPanel, 8)

local slHandle = Create("Frame", {Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = Th.Bar, BorderSizePixel = 0}, sliderPanel)
AddCorner(slHandle, 8)
Create("Frame", {Size = UDim2.new(1, 0, 0.5, 0), Position = UDim2.new(0, 0, 0.5, 0), BackgroundColor3 = Th.Bar, BorderSizePixel = 0}, slHandle)
Create("TextLabel", {Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.new(0, 8, 0, 0), BackgroundTransparency = 1, Text = "Radar Range", TextColor3 = Th.Sub, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left}, slHandle)
local rangeVal = Create("TextLabel", {Size = UDim2.new(0, 65, 1, 0), Position = UDim2.new(1, -68, 0, 0), BackgroundTransparency = 1, Text = "150 studs", TextColor3 = Th.AccG, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right}, slHandle)

local slTr = Create("Frame", {Size = UDim2.new(1, -20, 0, 8), Position = UDim2.new(0, 10, 0, 32), BackgroundColor3 = Color3.fromRGB(20,40,20), BorderSizePixel = 0}, sliderPanel)
AddCorner(slTr, 4)
local slFi = Create("Frame", {Size = UDim2.new(0.5, 0, 1, 0), BackgroundColor3 = Th.Acc, BorderSizePixel = 0}, slTr)
AddCorner(slFi, 4)
local slKn = Create("Frame", {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0.5, -10, 0.5, -10), BackgroundColor3 = Th.AccG, BorderSizePixel = 0, ZIndex = 2}, slTr)
AddCorner(slKn, 10)

-- Drag Slider Panel
local slPanDragging, slPanDragInput, slPanDragStart, slPanStartPos
slHandle.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        slPanDragging = true
        slPanDragStart = i.Position
        slPanStartPos = sliderPanel.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then slPanDragging = false end end)
    end
end)
slHandle.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then slPanDragInput = i end end)
UIS.InputChanged:Connect(function(i)
    if i == slPanDragInput and slPanDragging then
        local d = i.Position - slPanDragStart
        sliderPanel.Position = UDim2.new(slPanStartPos.X.Scale, slPanStartPos.X.Offset + d.X, slPanStartPos.Y.Scale, slPanStartPos.Y.Offset + d.Y)
    end
end)

-- Lock Slider
local sliderLocked = false
local lockBtn = Create("TextButton", {Size = UDim2.new(0, 50, 0, 18), Position = UDim2.new(1, -50, 0, 4), BackgroundColor3 = Color3.fromRGB(20,40,20), Text = "Lock", TextColor3 = Th.Sub, Font = Enum.Font.GothamSemibold, TextSize = 9, BorderSizePixel = 0}, sliderPanel)
AddCorner(lockBtn, 4)

lockBtn.MouseButton1Click:Connect(function()
    sliderLocked = not sliderLocked
    if sliderLocked then
        lockBtn.Text = "Locked"
        lockBtn.TextColor3 = Th.AccG
        TweenObj(lockBtn, {BackgroundColor3 = Color3.fromRGB(0,60,20)}, 0.2)
        slKn.BackgroundColor3 = Color3.fromRGB(100,120,100)
        slFi.BackgroundColor3 = Color3.fromRGB(40,100,40)
    else
        lockBtn.Text = "Lock"
        lockBtn.TextColor3 = Th.Sub
        TweenObj(lockBtn, {BackgroundColor3 = Color3.fromRGB(20,40,20)}, 0.2)
        slKn.BackgroundColor3 = Th.AccG
        slFi.BackgroundColor3 = Th.Acc
    end
end)

-- Slide Logic
local slDrag = false
slKn.InputBegan:Connect(function(i) if not sliderLocked and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then slDrag = true end end)
slTr.InputBegan:Connect(function(i) if not sliderLocked and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then slDrag = true end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then slDrag = false end end)
UIS.InputChanged:Connect(function(i)
    if slDrag and not sliderLocked and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local tp = slTr.AbsolutePosition
        local ts = slTr.AbsoluteSize
        local r = math.clamp((i.Position.X - tp.X) / ts.X, 0, 1)
        local v = math.floor(50 + r * 450)
        slFi.Size = UDim2.new(r, 0, 1, 0)
        slKn.Position = UDim2.new(r, -10, 0.5, -10)
        rangeVal.Text = v .. " studs"
        rangeLbl.Text = "Range: " .. v
        Settings.RadarRange = v
    end
end)

-- Minimize Button
MinB.MouseButton1Click:Connect(function()
    Settings.Minimized = not Settings.Minimized
    if Settings.Minimized then
        TweenObj(Main, {Size = UDim2.new(0, RADAR_SIZE+20, 0, 32)}, 0.3, Enum.EasingStyle.Back)
        MinB.Text = "+"
        RadarFrame.Visible = false
        InfoBar.Visible = false
        for _, e in pairs(dotPool) do e.dot.Visible = false e.pulse.Visible = false e.nameLbl.Visible = false end
    else
        TweenObj(Main, {Size = UDim2.new(0, RADAR_SIZE+20, 0, RADAR_SIZE+70)}, 0.3, Enum.EasingStyle.Back)
        MinB.Text = "-"
        task.delay(0.3, function() RadarFrame.Visible = true InfoBar.Visible = true end)
    end
end)

-- Close Button (Cleans up memory safely)
CloseB.MouseButton1Click:Connect(function()
    isDestroyed = true
    TweenObj(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back)
    task.delay(0.35, function()
        for _, espData in pairs(espPool) do
            if espData.highlight then espData.highlight:Destroy() end
            if espData.billboard then espData.billboard:Destroy() end
        end
        SG:Destroy()
    end)
end)

-- Drag Main Frame
local dragging, dragInput, dragStart, startPos
Top.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = i.Position
        startPos = Main.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
Top.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then dragInput = i end end)
UIS.InputChanged:Connect(function(i)
    if i == dragInput and dragging then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- Intro Animation
Main.Size = UDim2.new(0, 0, 0, 0)
TweenObj(Main, {Size = UDim2.new(0, RADAR_SIZE+20, 0, RADAR_SIZE+70)}, 0.5, Enum.EasingStyle.Back)
