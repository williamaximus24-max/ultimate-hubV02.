script.lua --[[
    ⚔️ ULTIMATE HUB - MURDER MYSTERY ⚔️
    Sistema de Key Gerada
    Aimbot OP + ESP com Box e Linhas
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- ============================
-- VARIÁVEIS GLOBAIS
-- ============================
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid", 10)
local Camera = Workspace.CurrentCamera

if not Camera then
    Camera = Workspace:WaitForChild("Camera")
end

local Target = nil
local Running = false
local LastAttack = 0
local IsFlying = false
local ESPObjects = {}
local ScreenGui = nil
local MainFrame = nil
local SidePanel = nil
local CurrentTab = 1
local Tabs = {"⚔", "👁", "🏃", "💰", "📡", "⚙"}
local TabNames = {"Combate", "Visual", "Movimento", "Farm", "Teleports", "Config"}
local TabContents = {}
local UpdateTabContent = nil

-- ============================
-- CONFIGURAÇÕES
-- ============================
local Config = {
    Enabled = true,
    Minimized = false,
    
    AutoAttack = false,
    KillAura = false,
    KillAll = false,
    SilentAim = false,
    Aimbot = false,
    AimbotPart = "Head",
    AimbotFOV = 200,
    AimbotSmoothness = 1,
    AutoWin = false,
    AutoWinType = "Murderer",
    
    AutoDodge = false,
    
    ESP = false,
    ShowNames = true,
    ShowHealth = true,
    ShowDistance = true,
    ShowLines = true,
    ShowBox = true,
    Fullbright = false,
    Wallhack = false,
    Chams = false,
    NoFog = false,
    
    SpeedHack = false,
    WalkSpeed = 25,
    JumpPower = 60,
    Fly = false,
    FlySpeed = 50,
    NoClip = false,
    InfiniteJump = false,
    SpinBot = false,
    SpinSpeed = 5,
    AntiAFK = false,
    
    AutoFarm = false,
    FarmMode = "Smooth",
    AutoGrabGun = false,
    FarmSpeed = 10,
    
    TeleportMurderer = false,
    TeleportSheriff = false,
    TeleportLobby = false,
    ClickTeleport = false,
    Spectate = false,
    Rejoin = false,
    
    BigHead = false,
    RevealRoles = false,
    FovChanger = false,
    FovValue = 120,
}

-- ============================
-- SISTEMA DE KEY GERADA
-- ============================
local function GenerateKey()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local key = "WM-"
    
    for i = 1, 8 do
        local randomIndex = math.random(1, #chars)
        key = key .. chars:sub(randomIndex, randomIndex)
    end
    
    key = key .. "-" .. tostring(math.random(1000, 9999))
    
    return key
end

local function VerifyKey(key)
    -- Aceita qualquer key no formato WM-XXXXXXXX-0000
    if key:match("^WM%-[A-Z0-9]+%-%d+$") then
        return true
    end
    return false
end

local function Notify(title, text, duration)
    duration = duration or 3
    
    pcall(function()
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 260, 0, 60)
        frame.Position = UDim2.new(0.5, -130, -0.1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        frame.BorderSizePixel = 0
        frame.Parent = Player.PlayerGui
        
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(255, 60, 60)
        stroke.Thickness = 1.5
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, 0, 0.4, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        titleLabel.TextSize = 14
        titleLabel.Font = Enum.Font.Code
        titleLabel.Parent = frame
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 0.5, 0)
        textLabel.Position = UDim2.new(0, 0, 0.45, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
        textLabel.TextSize = 11
        textLabel.Font = Enum.Font.Code
        textLabel.Parent = frame
        
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = UDim2.new(0.5, -130, 0.02, 0)
        }):Play()
        
        task.wait(duration)
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = UDim2.new(0.5, -130, -0.1, 0)
        }):Play()
        task.wait(0.3)
        frame:Destroy()
    end)
end

-- ============================
-- UTILITÁRIOS
-- ============================
local function GetCharacter(p) 
    return p and p.Character 
end

local function GetHumanoid(p) 
    local char = GetCharacter(p)
    return char and char:FindFirstChild("Humanoid")
end

local function GetHRP(p)
    local char = GetCharacter(p)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsAlive(p)
    local hum = GetHumanoid(p)
    return hum and hum.Health > 0
end

local function GetDistance(p1, p2) 
    return (p1 - p2).Magnitude 
end

local function GetClosestPlayer()
    local closest = nil
    local closestDist = math.huge
    local myPos = GetHRP(Player)
    if not myPos then return nil end
    myPos = myPos.Position
    
    for _, other in pairs(Players:GetPlayers()) do
        if other ~= Player and IsAlive(other) then
            local pos = GetHRP(other)
            if pos then
                local dist = GetDistance(myPos, pos.Position)
                if dist < closestDist then
                    closestDist = dist
                    closest = other
                end
            end
        end
    end
    return closest
end

local function GetPlayersInRange(range)
    local players = {}
    local myPos = GetHRP(Player)
    if not myPos then return players end
    myPos = myPos.Position
    
    for _, other in pairs(Players:GetPlayers()) do
        if other ~= Player and IsAlive(other) then
            local pos = GetHRP(other)
            if pos and GetDistance(myPos, pos.Position) <= range then
                table.insert(players, other)
            end
        end
    end
    return players
end

local function GetPlayerRole(player)
    if player.Character and player.Character:FindFirstChild("Murderer") then
        return "Murderer"
    elseif player.Character and player.Character:FindFirstChild("Sheriff") then
        return "Sheriff"
    else
        return "Innocent"
    end
end

-- ============================
-- AIMBOT
-- ============================
local function GetClosestPlayerInFOV()
    local closest = nil
    local shortestDistance = Config.AimbotFOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local char = player.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if root and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
                
                if onScreen then
                    local screenCenter = Camera.ViewportSize / 2
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

local function Aimbot()
    if not Config.Aimbot then return end
    
    local target = GetClosestPlayerInFOV()
    if not target or not target.Character then return end
    
    local char = target.Character
    local part = char:FindFirstChild(Config.AimbotPart) or char:FindFirstChild("HumanoidRootPart")
    if not part then return end
    
    local targetPos = part.Position
    
    if Config.AimbotSmoothness <= 1 then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
    else
        local lookAt = CFrame.new(Camera.CFrame.Position, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, 1 / Config.AimbotSmoothness)
    end
end

-- ============================
-- ESP
-- ============================
local function ClearESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function() obj:Destroy() end)
        end
        ESPObjects[player] = nil
    end
end

local function CreateESP(player)
    if not player or not player.Character then return end
    
    ClearESP(player)
    
    ESPObjects[player] = {}
    local char = player.Character
    local hrp = GetHRP(player)
    if not hrp then return end
    
    local espColor = Color3.fromRGB(255, 0, 0)
    local role = GetPlayerRole(player)
    
    if role == "Murderer" then
        espColor = Color3.fromRGB(255, 0, 0)
    elseif role == "Sheriff" then
        espColor = Color3.fromRGB(0, 100, 255)
    elseif role == "Innocent" then
        espColor = Color3.fromRGB(0, 255, 0)
    end
    
    if Config.ShowBox then
        local box = Instance.new("BoxHandleAdornment")
        box.Size = char:GetExtentsSize()
        box.Adornee = char
        box.ZIndex = 0
        box.AlwaysOnTop = true
        box.Color3 = espColor
        box.Transparency = 0.3
        box.Parent = char
        table.insert(ESPObjects[player], box)
    end
    
    if Config.ShowLines then
        local tracer = Instance.new("LineHandleAdornment")
        tracer.Length = 100
        tracer.Thickness = 2
        tracer.Adornee = char
        tracer.ZIndex = 0
        tracer.AlwaysOnTop = true
        tracer.Color3 = espColor
        tracer.Transparency = 0.3
        tracer.Parent = char
        table.insert(ESPObjects[player], tracer)
    end
    
    if Config.Chams then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local highlight = Instance.new("Highlight")
                highlight.Adornee = part
                highlight.FillColor = espColor
                highlight.FillTransparency = 0.3
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.OutlineTransparency = 0.2
                highlight.Parent = part
                table.insert(ESPObjects[player], highlight)
            end
        end
    end
    
    if Config.ShowNames and hrp then
        local nameTag = Instance.new("BillboardGui")
        nameTag.Size = UDim2.new(0, 180, 0, 30)
        nameTag.Adornee = hrp
        nameTag.AlwaysOnTop = true
        nameTag.Parent = hrp
        
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.Text = player.Name .. " [" .. role .. "]"
        nameLabel.TextColor3 = espColor
        nameLabel.TextScaled = true
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.TextStrokeTransparency = 0.3
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.Parent = nameTag
        table.insert(ESPObjects[player], nameTag)
    end
    
    if Config.ShowHealth and hrp then
        local healthBar = Instance.new("BillboardGui")
        healthBar.Size = UDim2.new(0, 100, 0, 8)
        healthBar.Adornee = hrp
        healthBar.AlwaysOnTop = true
        healthBar.Position = UDim2.new(0, -50, 0, -55)
        healthBar.Parent = hrp
        
        local healthFrame = Instance.new("Frame")
        healthFrame.Size = UDim2.new(1, 0, 1, 0)
        healthFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        healthFrame.BackgroundTransparency = 0.6
        healthFrame.Parent = healthBar
        
        Instance.new("UICorner", healthFrame).CornerRadius = UDim.new(1, 0)
        
        local healthFill = Instance.new("Frame")
        healthFill.Size = UDim2.new(1, 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthFill.Parent = healthFrame
        
        Instance.new("UICorner", healthFill).CornerRadius = UDim.new(1, 0)
        
        table.insert(ESPObjects[player], healthBar)
        
        task.spawn(function()
            while Config.ESP and player and player.Character and healthFill do
                local hum = GetHumanoid(player)
                if hum then
                    local percent = hum.Health / hum.MaxHealth
                    healthFill.Size = UDim2.new(percent, 0, 1, 0)
                    healthFill.BackgroundColor3 = percent > 0.5 and Color3.fromRGB(0, 255, 0) or 
                                                 percent > 0.25 and Color3.fromRGB(255, 200, 0) or 
                                                 Color3.fromRGB(255, 0, 0)
                end
                task.wait(0.15)
            end
        end)
    end
    
    if Config.ShowDistance and hrp then
        local distTag = Instance.new("BillboardGui")
        distTag.Size = UDim2.new(0, 80, 0, 20)
        distTag.Adornee = hrp
        distTag.AlwaysOnTop = true
        distTag.Position = UDim2.new(0, -40, 0, 40)
        distTag.Parent = hrp
        
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 1, 0)
        distLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        distLabel.TextScaled = true
        distLabel.BackgroundTransparency = 1
        distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        distLabel.TextStrokeTransparency = 0.5
        distLabel.Font = Enum.Font.Gotham
        distLabel.Parent = distTag
        table.insert(ESPObjects[player], distTag)
        
        task.spawn(function()
            while Config.ESP and player and player.Character and distLabel do
                local myPos = GetHRP(Player)
                local otherPos = GetHRP(player)
                if myPos and otherPos then
                    local dist = GetDistance(myPos.Position, otherPos.Position)
                    distLabel.Text = math.floor(dist) .. "m"
                end
                task.wait(0.2)
            end
        end)
    end
end

local function UpdateESP()
    if not Config.ESP then
        for player in pairs(ESPObjects) do
            ClearESP(player)
        end
        ESPObjects = {}
        return
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and IsAlive(player) then
            if not ESPObjects[player] then
                CreateESP(player)
            end
        else
            ClearESP(player)
        end
    end
end

-- ============================
-- COMBATE
-- ============================
local function Attack(player)
    if not player or not IsAlive(player) then return end
    if tick() - LastAttack < 0.3 then return end
    
    local tool = Character and Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    if Config.SilentAim then
        local myHRP = GetHRP(Player)
        local targetHRP = GetHRP(player)
        if myHRP and targetHRP then
            local dir = (targetHRP.Position - myHRP.Position).Unit
            local lookVector = myHRP.CFrame.LookVector
            local angle = math.acos(math.clamp(lookVector:Dot(dir), -1, 1))
            if angle <= math.rad(90) then
                tool:Activate()
                LastAttack = tick()
            end
        end
    else
        tool:Activate()
        LastAttack = tick()
    end
end

local function KillAura()
    if not Config.KillAura then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and IsAlive(player) then
            local myPos = GetHRP(Player)
            local otherPos = GetHRP(player)
            if myPos and otherPos then
                local dist = GetDistance(myPos.Position, otherPos.Position)
                if dist <= 30 then
                    Attack(player)
                    task.wait(0.1)
                end
            end
        end
    end
end

local function KillAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and IsAlive(player) then
            Attack(player)
            task.wait(0.05)
        end
    end
end

local function AutoWin()
    if not Config.AutoWin then return end
    
    if Config.AutoWinType == "Murderer" then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and IsAlive(player) then
                Attack(player)
                task.wait(0.05)
            end
        end
    elseif Config.AutoWinType == "Innocent" then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and IsAlive(player) then
                local role = GetPlayerRole(player)
                if role == "Murderer" then
                    Attack(player)
                    break
                end
            end
        end
    end
end

-- ============================
-- MOVIMENTO
-- ============================
local function ToggleFly()
    IsFlying = not IsFlying
    local hrp = GetHRP(Player)
    if not hrp then return end
    
    if IsFlying then
        hrp.Anchored = true
        if Humanoid then Humanoid.PlatformStand = true end
    else
        hrp.Anchored = false
        if Humanoid then Humanoid.PlatformStand = false end
    end
end

local function UpdateFly()
    if not IsFlying then return end
    
    local hrp = GetHRP(Player)
    if not hrp then return end
    
    local speed = Config.FlySpeed
    local move = Vector3.new(0, 0, 0)
    local cam = Camera
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        move = move + cam.CFrame.LookVector * Vector3.new(1, 0, 1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        move = move - cam.CFrame.LookVector * Vector3.new(1, 0, 1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        move = move - cam.CFrame.RightVector * Vector3.new(1, 0, 1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        move = move + cam.CFrame.RightVector * Vector3.new(1, 0, 1)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        move = move + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        move = move - Vector3.new(0, 1, 0)
    end
    
    if move.Magnitude > 0 then
        move = move.Unit * speed
    end
    
    hrp.Velocity = move
end

local function UpdateSpinBot()
    if not Config.SpinBot then return end
    
    local hrp = GetHRP(Player)
    if not hrp then return end
    
    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(Config.SpinSpeed), 0)
end

-- ============================
-- TELEPORTS
-- ============================
local function TeleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    local hrp = GetHRP(targetPlayer)
    if not hrp then return end
    
    local myHRP = GetHRP(Player)
    if not myHRP then return end
    
    myHRP.CFrame = hrp.CFrame + Vector3.new(0, 3, 0)
end

local function TeleportToMurderer()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and IsAlive(player) then
            local role = GetPlayerRole(player)
            if role == "Murderer" then
                TeleportToPlayer(player)
                break
            end
        end
    end
end

local function TeleportToSheriff()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and IsAlive(player) then
            local role = GetPlayerRole(player)
            if role == "Sheriff" then
                TeleportToPlayer(player)
                break
            end
        end
    end
end

-- ============================
-- FARM
-- ============================
local function AutoFarmCoins()
    if not Config.AutoFarm then return end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Name:lower():find("coin") then
            local hrp = GetHRP(Player)
            if hrp then
                if Config.FarmMode == "Teleport" then
                    hrp.CFrame = obj.CFrame + Vector3.new(0, 3, 0)
                else
                    local dir = (obj.Position - hrp.Position).Unit
                    hrp.Velocity = dir * Config.FarmSpeed
                end
            end
            task.wait(0.1)
        end
    end
end

local function AutoGrabGun()
    if not Character then return end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
            local hrp = GetHRP(Player)
            if hrp then
                local dist = GetDistance(hrp.Position, obj.Handle.Position)
                if dist <= 15 then
                    obj.Parent = Character
                    task.wait(0.5)
                end
            end
        end
    end
end

-- ============================
-- KEY PAGE (GERADA)
-- ============================
local function CreateKeyPage()
    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "KeySystem"
    KeyGui.Parent = Player.PlayerGui
    
    local KeyPage = Instance.new("Frame")
    KeyPage.Size = UDim2.new(0, 350, 0, 300)
    KeyPage.Position = UDim2.new(0.5, -175, 0.5, -150)
    KeyPage.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    KeyPage.BorderSizePixel = 0
    KeyPage.Parent = KeyGui
    
    Instance.new("UICorner", KeyPage).CornerRadius = UDim.new(0, 12)
    
    local stroke = Instance.new("UIStroke", KeyPage)
    stroke.Color = Color3.fromRGB(255, 60, 60)
    stroke.Thickness = 2
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0.15, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🔐 ULTIMATE HUB"
    Title.TextColor3 = Color3.fromRGB(255, 60, 60)
    Title.TextSize = 18
    Title.Font = Enum.Font.Code
    Title.Parent = KeyPage
    
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Size = UDim2.new(1, 0, 0.1, 0)
    SubTitle.Position = UDim2.new(0, 0, 0.15, 0)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "Sistema de Key Gerada"
    SubTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    SubTitle.TextSize = 12
    SubTitle.Font = Enum.Font.Code
    SubTitle.Parent = KeyPage
    
    -- Botão Gerar Key
    local GenerateBtn = Instance.new("TextButton")
    GenerateBtn.Size = UDim2.new(0.85, 0, 0.1, 0)
    GenerateBtn.Position = UDim2.new(0.075, 0, 0.3, 0)
    GenerateBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    GenerateBtn.BorderSizePixel = 0
    GenerateBtn.Text = "🔄 GERAR KEY"
    GenerateBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
    GenerateBtn.TextSize = 14
    GenerateBtn.Font = Enum.Font.Code
    GenerateBtn.Parent = KeyPage
    
    Instance.new("UICorner", GenerateBtn).CornerRadius = UDim.new(0, 8)
    
    local genStroke = Instance.new("UIStroke", GenerateBtn)
    genStroke.Color = Color3.fromRGB(0, 255, 100)
    genStroke.Thickness = 1.5
    
    -- Key Input
    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(0.85, 0, 0.1, 0)
    KeyInput.Position = UDim2.new(0.075, 0, 0.45, 0)
    KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    KeyInput.BorderSizePixel = 0
    KeyInput.PlaceholderText = "Cole sua key aqui..."
    KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 12
    KeyInput.Font = Enum.Font.Code
    KeyInput.Parent = KeyPage
    
    Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 8)
    
    -- Botão Verificar
    local VerifyBtn = Instance.new("TextButton")
    VerifyBtn.Size = UDim2.new(0.85, 0, 0.1, 0)
    VerifyBtn.Position = UDim2.new(0.075, 0, 0.6, 0)
    VerifyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    VerifyBtn.BorderSizePixel = 0
    VerifyBtn.Text = "✅ VERIFICAR KEY"
    VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    VerifyBtn.TextSize = 14
    VerifyBtn.Font = Enum.Font.Code
    VerifyBtn.Parent = KeyPage
    
    Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 8)
    
    local verifyStroke = Instance.new("UIStroke", VerifyBtn)
    verifyStroke.Color = Color3.fromRGB(255, 60, 60)
    verifyStroke.Thickness = 1.5
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0.08, 0)
    StatusLabel.Position = UDim2.new(0, 0, 0.75, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = ""
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    StatusLabel.TextSize = 10
    StatusLabel.Font = Enum.Font.Code
    StatusLabel.Parent = KeyPage
    
    GenerateBtn.MouseButton1Click:Connect(function()
        local key = GenerateKey()
        KeyInput.Text = key
        if setclipboard then
            setclipboard(key)
        end
        StatusLabel.Text = "✅ Key gerada e copiada!"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        Notify("KEY GERADA", key, 3)
    end)
    
    VerifyBtn.MouseButton1Click:Connect(function()
        local key = KeyInput.Text:upper():gsub("%s+", "")
        
        if key == "" then
            StatusLabel.Text = "❌ Gere uma key primeiro!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            return
        end
        
        if VerifyKey(key) then
            StatusLabel.Text = "✅ Key válida!"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            task.wait(1)
            KeyGui:Destroy()
            InitHub()
        else
            StatusLabel.Text = "❌ Key inválida!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)
end

-- ============================
-- INTERFACE HORIZONTAL
-- ============================
local function CreateHorizontalUI()
    if ScreenGui then
        ScreenGui:Destroy()
    end
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UltimateHubHorizontal"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 780, 0, 340)
    MainFrame.Position = UDim2.new(0.5, -390, 0.5, -170)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 18)
    
    local border = Instance.new("UIStroke", MainFrame)
    border.Color = Color3.fromRGB(220, 0, 0)
    border.Thickness = 2.5
    
    -- TOP BAR
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 45)
    topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    topBar.BackgroundTransparency = 0.3
    topBar.BorderSizePixel = 0
    topBar.Parent = MainFrame
    
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 18)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.35, 0, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚔ ULTIMATE HUB ⚔"
    title.TextColor3 = Color3.fromRGB(220, 0, 0)
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.Parent = topBar
    
    -- Botão minimizar
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 22, 0, 22)
    minBtn.Position = UDim2.new(1, -55, 0, 11)
    minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    minBtn.Text = "◉"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.TextSize = 9
    minBtn.BorderSizePixel = 0
    minBtn.Parent = topBar
    
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(1, 0)
    
    -- Botão fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -25, 0, 11)
    closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
    closeBtn.TextSize = 9
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = topBar
    
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
    
    minBtn.MouseButton1Click:Connect(function()
        MainFrame.Size = MainFrame.Size == UDim2.new(0, 780, 0, 340) and UDim2.new(0, 780, 0, 45) or UDim2.new(0, 780, 0, 340)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        Running = false
    end)
    
    -- Sistema de arrasto
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Painel Lateral
    SidePanel = Instance.new("Frame")
    SidePanel.Size = UDim2.new(0, 140, 0, 295)
    SidePanel.Position = UDim2.new(0, 0, 0, 45)
    SidePanel.BackgroundColor3 = Color3.fromRGB(8, 8, 16)
    SidePanel.BackgroundTransparency = 0.3
    SidePanel.BorderSizePixel = 0
    SidePanel.ClipsDescendants = true
    SidePanel.Parent = MainFrame
    
    local navButtons = {}
    
    for i = 1, 6 do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 130, 0, 32)
        btn.Position = UDim2.new(0.5, -65, 0, 10 + (i-1) * 42)
        btn.BackgroundColor3 = i == 1 and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(20, 20, 35)
        btn.Text = Tabs[i] .. " " .. TabNames[i]
        btn.TextColor3 = i == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 0, 0)
        btn.TextSize = 11
        btn.TextXAlignment = Enum.TextXAlignment.Center
        btn.BorderSizePixel = 0
        btn.Parent = SidePanel
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        
        navButtons[i] = btn
        
        btn.MouseButton1Click:Connect(function()
            CurrentTab = i
            for j, b in ipairs(navButtons) do
                b.BackgroundColor3 = j == i and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(20, 20, 35)
                b.TextColor3 = j == i and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 0, 0)
            end
            if UpdateTabContent then
                UpdateTabContent(i)
            end
        end)
    end
    
    -- Container de conteúdo
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -150, 0, 295)
    contentContainer.Position = UDim2.new(0, 145, 0, 45)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ClipsDescendants = true
    contentContainer.Parent = MainFrame
    
    for i = 1, 6 do
        local content = Instance.new("ScrollingFrame")
        content.Size = UDim2.new(1, -10, 1, -10)
        content.Position = UDim2.new(0, 5, 0, 5)
        content.BackgroundTransparency = 1
        content.CanvasSize = UDim2.new(0, 0, 0, 0)
        content.ScrollBarThickness = 0
        content.Visible = i == 1
        content.Parent = contentContainer
        TabContents[i] = content
    end
    
    -- Funções da UI
    local function CreateToggle(parent, text, setting, x, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 280, 0, 28)
        frame.Position = UDim2.new(0, x, 0, y)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        parent.CanvasSize = UDim2.new(0, 0, 0, y + 35)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.65, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(215, 215, 225)
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 28, 0, 28)
        toggle.Position = UDim2.new(0.88, 0, 0, 0)
        toggle.BackgroundColor3 = Config[setting] and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(35, 35, 50)
        toggle.Text = Config[setting] and "◈" or "◎"
        toggle.TextColor3 = Config[setting] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 160)
        toggle.TextSize = 13
        toggle.BorderSizePixel = 0
        toggle.Parent = frame
        
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
        
        toggle.MouseButton1Click:Connect(function()
            Config[setting] = not Config[setting]
            toggle.BackgroundColor3 = Config[setting] and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(35, 35, 50)
            toggle.Text = Config[setting] and "◈" or "◎"
            toggle.TextColor3 = Config[setting] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 160)
        end)
    end
    
    local function CreateSlider(parent, text, setting, min, max, x, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 280, 0, 40)
        frame.Position = UDim2.new(0, x, 0, y)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        parent.CanvasSize = UDim2.new(0, 0, 0, y + 45)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 18)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. Config[setting]
        label.TextColor3 = Color3.fromRGB(215, 215, 225)
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0, 5)
        slider.Position = UDim2.new(0, 0, 0, 25)
        slider.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        slider.BorderSizePixel = 0
        slider.Parent = frame
        
        Instance.new("UICorner", slider).CornerRadius = UDim.new(1, 0)
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((Config[setting] - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
        fill.BorderSizePixel = 0
        fill.Parent = slider
        
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        
        local drag = Instance.new("TextButton")
        drag.Size = UDim2.new(0, 14, 0, 14)
        drag.Position = UDim2.new((Config[setting] - min) / (max - min), -7, 0.5, -7)
        drag.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
        drag.BorderSizePixel = 0
        drag.Text = ""
        drag.Parent = slider
        
        Instance.new("UICorner", drag).CornerRadius = UDim.new(1, 0)
        
        local function updateSlider(input)
            if slider.AbsoluteSize.X > 0 then
                local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                Config[setting] = value
                label.Text = text .. ": " .. value
                fill.Size = UDim2.new(pos, 0, 1, 0)
                drag.Position = UDim2.new(pos, -7, 0.5, -7)
            end
        end
        
        drag.MouseButton1Down:Connect(function()
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local mouse = Player:GetMouse()
                updateSlider({Position = Vector2.new(mouse.X, mouse.Y)})
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                end
            end)
        end)
    end
    
    local function CreateDropdown(parent, text, setting, options, x, y)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 280, 0, 30)
        frame.Position = UDim2.new(0, x, 0, y)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        parent.CanvasSize = UDim2.new(0, 0, 0, y + 35)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(215, 215, 225)
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.Parent = frame
        
        local dropdown = Instance.new("TextButton")
        dropdown.Size = UDim2.new(0, 100, 0, 25)
        dropdown.Position = UDim2.new(0.55, 0, 0.08, 0)
        dropdown.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        dropdown.Text = Config[setting]
        dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
        dropdown.TextSize = 11
        dropdown.BorderSizePixel = 0
        dropdown.Parent = frame
        
        Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 8)
        
        dropdown.MouseButton1Click:Connect(function()
            local current = table.find(options, Config[setting])
            local next = current and current % #options + 1 or 1
            Config[setting] = options[next]
            dropdown.Text = options[next]
        end)
    end
    
    UpdateTabContent = function(tab)
        for i, content in pairs(TabContents) do
            content.Visible = (i == tab)
        end
    end
    
    -- Popular abas
    local c1 = 0
    CreateToggle(TabContents[1], "🎯 Aimbot OP", "Aimbot", 0, c1)
    c1 = c1 + 33
    CreateDropdown(TabContents[1], "Parte do Alvo", "AimbotPart", {"Head", "UpperTorso", "HumanoidRootPart"}, 0, c1)
    c1 = c1 + 35
    CreateSlider(TabContents[1], "🎯 FOV", "AimbotFOV", 50, 500, 0, c1)
    c1 = c1 + 45
    CreateSlider(TabContents[1], "🔄 Suavidade", "AimbotSmoothness", 1, 20, 0, c1)
    c1 = c1 + 45
    CreateToggle(TabContents[1], "⚔ Auto Attack", "AutoAttack", 0, c1)
    c1 = c1 + 33
    CreateToggle(TabContents[1], "💀 Kill Aura", "KillAura", 0, c1)
    c1 = c1 + 33
    CreateToggle(TabContents[1], "💀 Kill All", "KillAll", 0, c1)
    c1 = c1 + 33
    CreateToggle(TabContents[1], "🎯 Silent Aim", "SilentAim", 0, c1)
    c1 = c1 + 33
    CreateToggle(TabContents[1], "🏆 Auto Win", "AutoWin", 0, c1)
    c1 = c1 + 33
    CreateDropdown(TabContents[1], "Win Type", "AutoWinType", {"Murderer", "Innocent"}, 0, c1)
    c1 = c1 + 35
    CreateToggle(TabContents[1], "🛡 Auto Dodge", "AutoDodge", 0, c1)
    
    local v1 = 0
    CreateToggle(TabContents[2], "👁 ESP", "ESP", 0, v1)
    v1 = v1 + 33
    CreateToggle(TabContents[2], "📦 Box", "ShowBox", 0, v1)
    v1 = v1 + 33
    CreateToggle(TabContents[2], "📏 Linhas", "ShowLines", 0, v1)
    v1 = v1 + 33
    CreateToggle(TabContents[2], "🔦 Wallhack", "Wallhack", 0, v1)
    v1 = v1 + 33
    CreateToggle(TabContents[2], "☀ Fullbright", "Fullbright", 0, v1)
    v1 = v1 + 33
    CreateToggle(TabContents[2], "🏷 Names", "ShowNames", 0, v1)
    v1 = v1 + 33
    CreateToggle(TabContents[2], "❤ Health", "ShowHealth", 0, v1)
    v1 = v1 + 33
    CreateToggle(TabContents[2], "📏 Distance", "ShowDistance", 0, v1)
    v1 = v1 + 33
    CreateToggle(TabContents[2], "✨ Chams", "Chams", 0, v1)
    v1 = v1 + 33
    CreateToggle(TabContents[2], "🌫 No Fog", "NoFog", 0, v1)
    
    local m1 = 0
    CreateToggle(TabContents[3], "💨 Speed Hack", "SpeedHack", 0, m1)
    m1 = m1 + 33
    CreateToggle(TabContents[3], "✈ Fly", "Fly", 0, m1)
    m1 = m1 + 33
    CreateToggle(TabContents[3], "🚪 No Clip", "NoClip", 0, m1)
    m1 = m1 + 33
    CreateToggle(TabContents[3], "🔄 Infinite Jump", "InfiniteJump", 0, m1)
    m1 = m1 + 33
    CreateToggle(TabContents[3], "🔄 Spin Bot", "SpinBot", 0, m1)
    m1 = m1 + 33
    CreateToggle(TabContents[3], "💤 Anti AFK", "AntiAFK", 0, m1)
    m1 = m1 + 33
    CreateSlider(TabContents[3], "🏃 Walk Speed", "WalkSpeed", 16, 100, 0, m1)
    m1 = m1 + 45
    CreateSlider(TabContents[3], "🦘 Jump Power", "JumpPower", 50, 200, 0, m1)
    m1 = m1 + 45
    CreateSlider(TabContents[3], "✈ Fly Speed", "FlySpeed", 20, 100, 0, m1)
    m1 = m1 + 45
    CreateSlider(TabContents[3], "🔄 Spin Speed", "SpinSpeed", 1, 20, 0, m1)
    
    local f1 = 0
    CreateToggle(TabContents[4], "💰 Auto Farm", "AutoFarm", 0, f1)
    f1 = f1 + 33
    CreateToggle(TabContents[4], "🔫 Auto Grab Gun", "AutoGrabGun", 0, f1)
    f1 = f1 + 33
    CreateDropdown(TabContents[4], "Farm Mode", "FarmMode", {"Teleport", "Smooth", "Walk"}, 0, f1)
    f1 = f1 + 35
    CreateSlider(TabContents[4], "🏃 Farm Speed", "FarmSpeed", 5, 30, 0, f1)
    
    local t1 = 0
    CreateToggle(TabContents[5], "📡 TP Murderer", "TeleportMurderer", 0, t1)
    t1 = t1 + 33
    CreateToggle(TabContents[5], "📡 TP Sheriff", "TeleportSheriff", 0, t1)
    t1 = t1 + 33
    CreateToggle(TabContents[5], "📡 TP Lobby", "TeleportLobby", 0, t1)
    t1 = t1 + 33
    CreateToggle(TabContents[5], "🎯 Click TP", "ClickTeleport", 0, t1)
    t1 = t1 + 33
    CreateToggle(TabContents[5], "👁 Spectate", "Spectate", 0, t1)
    t1 = t1 + 33
    CreateToggle(TabContents[5], "🔄 Rejoin", "Rejoin", 0, t1)
    
    local co1 = 0
    CreateToggle(TabContents[6], "🔴 Ativo", "Enabled", 0, co1)
    co1 = co1 + 33
    CreateToggle(TabContents[6], "👤 Big Head", "BigHead", 0, co1)
    co1 = co1 + 33
    CreateToggle(TabContents[6], "🔍 Roles", "RevealRoles", 0, co1)
    co1 = co1 + 33
    CreateToggle(TabContents[6], "🔄 FOV Changer", "FovChanger", 0, co1)
    co1 = co1 + 33
    CreateSlider(TabContents[6], "🎯 FOV", "FovValue", 70, 160, 0, co1)
end

-- ============================
-- LOOP PRINCIPAL
-- ============================
local function MainLoop()
    while Running do
        task.wait(0.05)
        
        if not Config.Enabled then
            task.wait(1)
            continue
        end
        
        Character = Player.Character
        if not Character then continue end
        
        Humanoid = Character:FindFirstChild("Humanoid")
        if not Humanoid or Humanoid.Health <= 0 then continue end
        
        if Config.SpeedHack then
            Humanoid.WalkSpeed = Config.WalkSpeed
            Humanoid.JumpPower = Config.JumpPower
        else
            Humanoid.WalkSpeed = 16
            Humanoid.JumpPower = 50
        end
        
        if Config.InfiniteJump then
            Humanoid.JumpPower = 200
        end
        
        if Config.NoClip then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        
        if Config.Fullbright then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            Lighting.Brightness = 1
            Lighting.OutdoorAmbient = Color3.fromRGB(0, 0, 0)
        end
        
        if Config.Wallhack then
            for _, part in pairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 0.3
                end
            end
        end
        
        if Config.NoFog then
            Lighting.FogEnd = 999999
            Lighting.FogStart = 0
        end
        
        if Config.AntiAFK then
            if not UserInputService:IsKeyDown(Enum.KeyCode.W) and 
               not UserInputService:IsKeyDown(Enum.KeyCode.A) and
               not UserInputService:IsKeyDown(Enum.KeyCode.S) and 
               not UserInputService:IsKeyDown(Enum.KeyCode.D) then
                Humanoid.MoveDirection = Vector3.new(0, 0, 1)
            end
        end
        
        if Config.Fly then
            if not IsFlying then ToggleFly() end
            UpdateFly()
        else
            if IsFlying then ToggleFly() end
        end
        
        if Config.SpinBot then
            UpdateSpinBot()
        end
        
        if Config.BigHead then
            local head = Character:FindFirstChild("Head")
            if head then
                head.Size = Vector3.new(5, 5, 5)
            end
        end
        
        if Config.FovChanger then
            Camera.FieldOfView = Config.FovValue
        else
            Camera.FieldOfView = 70
        end
        
        if Config.RevealRoles then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= Player and player.Character then
                    local role = GetPlayerRole(player)
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        if role == "Murderer" then
                            head.BrickColor = BrickColor.new("Bright red")
                        elseif role == "Sheriff" then
                            head.BrickColor = BrickColor.new("Bright blue")
                        else
                            head.BrickColor = BrickColor.new("Bright green")
                        end
                    end
                end
            end
        end
        
        if Config.Aimbot then
            Aimbot()
        end
        
        if Config.AutoAttack or Config.KillAura then
            Target = GetClosestPlayer()
        end
        
        if Config.AutoAttack and Target then
            Attack(Target)
        end
        
        if Config.KillAura then
            KillAura()
        end
        
        if Config.KillAll then
            KillAllPlayers()
            Config.KillAll = false
        end
        
        if Config.AutoWin then
            AutoWin()
            Config.AutoWin = false
        end
        
        if Config.AutoDodge then
            local players = GetPlayersInRange(15)
            if #players > 0 then
                local hrp = GetHRP(Player)
                if hrp then
                    local dir = Vector3.new(math.random(-10, 10), 0, math.random(-10, 10)).Unit
                    hrp.Velocity = dir * 50 + Vector3.new(0, 15, 0)
                end
            end
        end
        
        if Config.AutoFarm then
            AutoFarmCoins()
        end
        
        if Config.AutoGrabGun then
            AutoGrabGun()
        end
        
        if Config.TeleportMurderer then
            TeleportToMurderer()
            Config.TeleportMurderer = false
        end
        
        if Config.TeleportSheriff then
            TeleportToSheriff()
            Config.TeleportSheriff = false
        end
        
        if Config.TeleportLobby then
            local lobby = Workspace:FindFirstChild("Lobby")
            if lobby then
                local hrp = GetHRP(Player)
                if hrp then
                    hrp.CFrame = lobby.CFrame + Vector3.new(0, 3, 0)
                end
            end
            Config.TeleportLobby = false
        end
        
        if Config.Rejoin then
            TeleportService:Teleport(game.PlaceId)
            Config.Rejoin = false
        end
        
        if Config.Spectate then
            local target = GetClosestPlayer()
            if target and target.Character then
                Camera.CameraSubject = target.Character
            end
        else
            Camera.CameraSubject = Character
        end
        
        UpdateESP()
    end
end

-- ============================
-- INICIALIZAÇÃO
-- ============================
function InitHub()
    CreateHorizontalUI()
    Running = true
    task.spawn(MainLoop)
    
    print("⚔️ ULTIMATE HUB PREMIUM carregado!")
end

-- Iniciar com Key System
CreateKeyPage()

-- ============================
-- LIMPEZA
-- ============================
Player.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid", 10)
    IsFlying = false
end)
