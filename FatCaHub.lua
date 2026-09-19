-- ====================================================================
-- 1. DỊCH VỤ HỆ THỐNG ROBLOX (ROBLOX SERVICES)
-- ====================================================================
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")
local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Lighting = game:GetService("Lighting")

local ParentGui = (gethui and gethui()) or CoreGui

-- ====================================================================
-- 2. KIỂM TRA MAP & SEA CHECK 
-- ====================================================================
local MAP_SEAS = {
    [85211729168715] = 1,  -- Sea 1
    [79091703265657] = 2,  -- Sea 2
    [100117331123089] = 3   -- Sea 3
}

local currentSea = MAP_SEAS[game.PlaceId]
if not currentSea then
    Players.LocalPlayer:Kick("PlaceId không hợp lệ!")
    return
end

local Sea1 = currentSea == 1
local Sea2 = currentSea == 2
local Sea3 = currentSea == 3

-- ====================================================================
-- 3. QUẢN LÝ NHÂN VẬT & MÁY CHỦ (CHARACTER MANAGER SYSTEM)
-- ====================================================================
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera
local CharacterManager = {}

function CharacterManager.Get()
    local char = LocalPlayer.Character
    if not char or not char:IsDescendantOf(Workspace) then return nil, nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if root and hum and hum.Health > 0 and root:IsDescendantOf(Workspace) then
        return char, root, hum
    end
    return nil, nil, nil
end

-- ====================================================================
-- 4. REMOTES & THƯ MỤC BLOX FRUITS
-- ====================================================================
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local CommF = Remotes and Remotes:WaitForChild("CommF_", 10)
local CommE = Remotes and Remotes:WaitForChild("CommE", 10)

local EnemiesFolder = Workspace:WaitForChild("Enemies", 10)
local NPCsFolder = Workspace:WaitForChild("NPCs", 10)
local MapFolder = Workspace:WaitForChild("Map", 10)
local SeaBeastsFolder = Workspace:FindFirstChild("SeaBeasts")
local BoatsFolder = Workspace:FindFirstChild("Boats")

-- Trích xuất Net Module hỗ trợ Fast Attack
local NetModule, RegisterAttack, RegisterHit
pcall(function()
    local Modules = ReplicatedStorage:WaitForChild("Modules", 5)
    if Modules and Modules:FindFirstChild("Net") then
        NetModule = require(Modules.Net)
        RegisterAttack = NetModule:RemoteEvent("RegisterAttack")
        RegisterHit = NetModule:RemoteEvent("RegisterHit")
    end
end)

-- Fallback tìm Remote trực tiếp nếu Net Module không khả dụng
if not RegisterAttack or not RegisterHit then
    RegisterAttack = Remotes and Remotes:FindFirstChild("RegisterAttack")
    RegisterHit = Remotes and Remotes:FindFirstChild("RegisterHit")
end

-- ====================================================================
-- 5. KHỞI TẠO FRAMEWORK FLUENT UI & TABS
-- ====================================================================
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mr-PMC/FluentUI/refs/heads/master/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mr-PMC/FluentUI/refs/heads/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Mr-PMC/FluentUI/refs/heads/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Fat Cat Hub",
    SubTitle = "v2.5 Full Edition | Sea " .. tostring(currentSea),
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 320),
    Acrylic = true,
    ToggleIcon = "rbxassetid://13717478897",
    ToggleIconSize = UDim2.fromOffset(40, 40),
})

local TabDefinitions = {
    {"Info", "Info", "info"},
    {"Farm", "Farm", "sword"},
    {"StackFarming", "Stack Farming", "layers"},
    {"ItemShop", "Item & Shop", "package"},
    {"ServerHopFarm", "Server Hop", "server"},
    {"ESPStats", "ESP & Stats", "eye"},
    {"FruitRaid", "Fruits & Raid", "apple"},
    {"TeleportPvP", "Teleport & PvP", "map-pin"},
    {"Race", "Race V4", "shield"},
    {"SeaEvent", "Sea Events", "waves"},
    {"Setting", "Settings", "settings"},
    {"DiscordWebhook", "Discord Webhook", "message-circle"}
}

local Tabs = {}
for _, tabData in ipairs(TabDefinitions) do
    Tabs[tabData[1]] = Window:AddTab({ Title = tabData[2], Icon = tabData[3] })
end

-- ====================================================================
-- 6. BIẾN CẤU HÌNH DÙNG CHUNG (SHARED CONFIG VARIABLES)
-- ====================================================================
local DEFAULT_CONFIG = "BloxFruit_" .. LocalPlayer.Name
local autoSaveActive = true

local QuestLevelData = {
    Sea1 = {},
    Sea2 = {
        {MinLevel = 700,  MaxLevel = 724,  Monster = "Raider",            Quest = "Area1Quest",        QuestLevel = 1, NPCPos = CFrame.new(-427.72567749023, 72.99634552002, 1835.9426269531), MonterPos = CFrame.new(68.874565124512, 93.635643005371, 2429.6752929688)},
        {MinLevel = 725,  MaxLevel = 774,  Monster = "Mercenary",         Quest = "Area1Quest",        QuestLevel = 2, NPCPos = CFrame.new(-427.72567749023, 72.99634552002, 1835.9426269531), MonterPos = CFrame.new(-864.85009765625, 122.47104644775, 1453.1505126953)},
        {MinLevel = 775,  MaxLevel = 799,  Monster = "Swan Pirate",       Quest = "Area2Quest",        QuestLevel = 1, NPCPos = CFrame.new(635.61151123047, 73.096351623535, 917.81298828125), MonterPos = CFrame.new(1065.3669433594, 137.64012145996, 1324.3798828125)},
        {MinLevel = 800,  MaxLevel = 874,  Monster = "Factory Staff",     Quest = "Area2Quest",        QuestLevel = 2, NPCPos = CFrame.new(635.61151123047, 73.096351623535, 917.81298828125), MonterPos = CFrame.new(533.22045898438, 128.46876525879, 355.62615966797)},
        {MinLevel = 875,  MaxLevel = 899,  Monster = "Marine Lieutenant", Quest = "MarineQuest3",      QuestLevel = 1, NPCPos = CFrame.new(-2440.9934082031, 73.04190826416, -3217.7082519531), MonterPos = CFrame.new(-2489.2622070313, 84.613594055176, -3151.8830566406)},
        {MinLevel = 900,  MaxLevel = 949,  Monster = "Marine Captain",    Quest = "MarineQuest3",      QuestLevel = 2, NPCPos = CFrame.new(-2440.9934082031, 73.04190826416, -3217.7082519531), MonterPos = CFrame.new(-2335.2026367188, 79.786659240723, -3245.8674316406)},
        {MinLevel = 950,  MaxLevel = 974,  Monster = "Zombie",            Quest = "ZombieQuest",       QuestLevel = 1, NPCPos = CFrame.new(-5494.3413085938, 48.505931854248, -794.59094238281), MonterPos = CFrame.new(-5536.4970703125, 101.08577728271, -835.59075927734)},
        {MinLevel = 975,  MaxLevel = 999,  Monster = "Vampire",           Quest = "ZombieQuest",       QuestLevel = 2, NPCPos = CFrame.new(-5494.3413085938, 48.505931854248, -794.59094238281), MonterPos = CFrame.new(-5806.1098632813, 16.722528457642, -1164.4384765625)},
        {MinLevel = 1000, MaxLevel = 1049, Monster = "Snow Trooper",      Quest = "SnowMountainQuest", QuestLevel = 1, NPCPos = CFrame.new(607.05963134766, 401.44781494141, -5370.5546875), MonterPos = CFrame.new(535.21051025391, 432.74209594727, -5484.9165039063)},
        {MinLevel = 1050, MaxLevel = 1099, Monster = "Winter Warrior",    Quest = "SnowMountainQuest", QuestLevel = 2, NPCPos = CFrame.new(607.05963134766, 401.44781494141, -5370.5546875), MonterPos = CFrame.new(1234.4449462891, 456.95419311523, -5174.130859375)},
        {MinLevel = 1100, MaxLevel = 1124, Monster = "Lab Subordinate",   Quest = "IceSideQuest",      QuestLevel = 1, NPCPos = CFrame.new(-6061.841796875, 15.926671981812, -4902.0385742188), MonterPos = CFrame.new(-5720.5576171875, 63.309471130371, -4784.6103515625)},
        {MinLevel = 1125, MaxLevel = 1174, Monster = "Horned Warrior",    Quest = "IceSideQuest",      QuestLevel = 2, NPCPos = CFrame.new(-6061.841796875, 15.926671981812, -4902.0385742188), MonterPos = CFrame.new(-6292.751953125, 91.181983947754, -5502.6499023438)},
        {MinLevel = 1175, MaxLevel = 1199, Monster = "Magma Ninja",       Quest = "FireSideQuest",     QuestLevel = 1, NPCPos = CFrame.new(-5429.0473632813, 15.977565765381, -5297.9614257813), MonterPos = CFrame.new(-5461.8388671875, 130.36347961426, -5836.4702148438)},
        {MinLevel = 1200, MaxLevel = 1249, Monster = "Lava Pirate",       Quest = "FireSideQuest",     QuestLevel = 2, NPCPos = CFrame.new(-5429.0473632813, 15.977565765381, -5297.9614257813), MonterPos = CFrame.new(-5251.1889648438, 55.164535522461, -4774.4096679688)},
        {MinLevel = 1250, MaxLevel = 1274, Monster = "Ship Deckhand",     Quest = "ShipQuest1",        QuestLevel = 1, NPCPos = CFrame.new(1040.2927246094, 125.08293151855, 32911.0390625), MonterPos = CFrame.new(921.12365722656, 125.9839553833, 33088.328125), Entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)},
        {MinLevel = 1275, MaxLevel = 1299, Monster = "Ship Engineer",     Quest = "ShipQuest1",        QuestLevel = 2, NPCPos = CFrame.new(1040.2927246094, 125.08293151855, 32911.0390625), MonterPos = CFrame.new(886.28179931641, 40.47790145874, 32800.83203125), Entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)},
        {MinLevel = 1300, MaxLevel = 1324, Monster = "Ship Steward",      Quest = "ShipQuest2",        QuestLevel = 1, NPCPos = CFrame.new(971.42065429688, 125.08293151855, 33245.54296875), MonterPos = CFrame.new(943.85504150391, 129.58183288574, 33444.3671875), Entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)},
        {MinLevel = 1325, MaxLevel = 1349, Monster = "Ship Officer",      Quest = "ShipQuest2",        QuestLevel = 2, NPCPos = CFrame.new(971.42065429688, 125.08293151855, 33245.54296875), MonterPos = CFrame.new(955.38458251953, 181.08335876465, 33331.890625), Entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)},
        {MinLevel = 1350, MaxLevel = 1374, Monster = "Arctic Warrior",    Quest = "FrostQuest",        QuestLevel = 1, NPCPos = CFrame.new(5668.1372070313, 28.202531814575, -6484.6005859375), MonterPos = CFrame.new(5935.4541015625, 77.26016998291, -6472.7568359375)},
        {MinLevel = 1375, MaxLevel = 1424, Monster = "Snow Lurker",       Quest = "FrostQuest",        QuestLevel = 2, NPCPos = CFrame.new(5668.1372070313, 28.202531814575, -6484.6005859375), MonterPos = CFrame.new(5628.482421875, 57.574996948242, -6618.3481445313)},
        {MinLevel = 1425, MaxLevel = 1449, Monster = "Sea Soldier",       Quest = "ForgottenQuest",    QuestLevel = 1, NPCPos = CFrame.new(-3054.5827636719, 236.87213134766, -10147.790039063), MonterPos = CFrame.new(-3185.0153808594, 58.789089202881, -9663.6064453125)},
        {MinLevel = 1450, MaxLevel = 9999, Monster = "Water Fighter",    Quest = "ForgottenQuest",    QuestLevel = 2, NPCPos = CFrame.new(-3054.5827636719, 236.87213134766, -10147.790039063), MonterPos = CFrame.new(-3262.9301757813, 298.69036865234, -10552.529296875)},
    },
    Sea3 = {}
}

-- ====================================================================
-- 7. CÁC HÀM HỖ TRỢ HOẠT ĐỘNG
-- ====================================================================
LocalPlayer.Idled:Connect(function()
    if Fluent.Options and Fluent.Options.AntiAFK and Fluent.Options.AntiAFK.Value then
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), Camera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), Camera.CFrame)
        end)
    end
end)

-- Vòng lặp Auto Turn on Buso
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if Fluent.Options and Fluent.Options.AutoBuso and Fluent.Options.AutoBuso.Value then
                local char, root, hum = CharacterManager.Get()
                if char and hum and hum.Health > 0 then
                    if not char:FindFirstChild("HasBuso") and CommF then
                        CommF:InvokeServer("Buso")
                    end
                end
            end
        end)
    end
end)

-- Vòng lặp Auto Turn on Ken (Haki Quan Sát)
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if Fluent.Options and Fluent.Options.AutoKen and Fluent.Options.AutoKen.Value then
                local char, root, hum = CharacterManager.Get()
                if char and hum and hum.Health > 0 then
                    local isKenActive = LocalPlayer:GetAttribute("KenActive")
                    if not isKenActive and CommE then
                        CommE:FireServer("Ken", true)
                    end
                end
            end
        end)
    end
end)

-- Vòng lặp No Clip (Xuyên Tường)
RunService.Stepped:Connect(function()
    pcall(function()
        if Fluent.Options and Fluent.Options.Noclip and Fluent.Options.Noclip.Value then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
end)

-- ====================================================================
-- 8. PHÂN HỆ FAST ATTACK (FAST ATTACK ENGINE)
-- ====================================================================
local FastAttackConfig = {
    Radius = 60,         -- Bán kính quét quái (Studs)
    MicroDelay = 0.015   -- Khoảng nghỉ giữa các nhịp đánh tránh Kick 267
}

-- Hàm quét danh sách mục tiêu trong phạm vi
local function GetFastAttackTargets(radius)
    local targets = {}
    local char, root, hum = CharacterManager.Get()
    if not char or not root then return targets end

    local myPos = root.Position

    if EnemiesFolder then
        for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("UpperTorso") or enemy:FindFirstChild("Head")
            local enemyHum = enemy:FindFirstChildOfClass("Humanoid")

            if enemyRoot and enemyHum and enemyHum.Health > 0 then
                local dist = (enemyRoot.Position - myPos).Magnitude
                if dist <= radius then
                    table.insert(targets, {enemy, enemyRoot})
                end
            end
        end
    end

    return targets
end

-- Vòng lặp xử lý Fast Attack siêu tốc
task.spawn(function()
    while task.wait(FastAttackConfig.MicroDelay) do
        pcall(function()
            if Fluent.Options and Fluent.Options.FastAttack and Fluent.Options.FastAttack.Value then
                local char, root, hum = CharacterManager.Get()
                if not char or not hum or hum.Health <= 0 then return end

                -- Kiểm tra nhân vật có đang cầm vũ khí không
                local tool = char:FindFirstChildOfClass("Tool")
                if not tool then return end

                local targets = GetFastAttackTargets(FastAttackConfig.Radius)
                if #targets > 0 then
                    if RegisterAttack and RegisterHit then
                        task.spawn(function()
                            -- Bắn lệnh bỏ qua animation vung tay
                            RegisterAttack:FireServer(0)
                            -- Bắn lệnh ghi nhận va chạm trên toàn bộ danh sách quái
                            RegisterHit:FireServer(targets[1][2], targets)
                        end)
                    end
                end
            end
        end)
    end
end)

-- ====================================================================
-- 9. XÂY DỰNG GIAO DIỆN CHỨC NĂNG CHÍNH (BUILD REAL UI ELEMENTS)
-- ====================================================================
local function BuildUI()
    -- TAB SETTING
    Tabs.Setting:AddSection("Fast Attack Engine")
    
    Tabs.Setting:AddToggle("FastAttack", {
        Title = "Enable Fast Attack",
        Description = "Đánh quái siêu tốc bỏ qua Cooldown Client",
        Default = false
    })

    Tabs.Setting:AddSection("Automation & Protection")
    
    Tabs.Setting:AddToggle("AutoBuso", {
        Title = "Auto Turn On Buso",
        Description = "Tự động bật Haki Vũ Trang",
        Default = true
    })
    
    Tabs.Setting:AddToggle("AutoKen", {
        Title = "Auto Turn On Ken",
        Description = "Tự động bật Haki Quan Sát",
        Default = true
    })
    
    Tabs.Setting:AddToggle("AntiAFK", {
        Title = "Anti AFK",
        Description = "Chống bị văng game khi treo máy",
        Default = true
    })

    Tabs.Setting:AddSection("Config File")
    
    Tabs.Setting:AddButton({
        Title = "Reset Config",
        Description = "Xóa tệp cấu hình đã lưu",
        Callback = function()
            autoSaveActive = false
            pcall(function()
                local filePath = "FatCatHub/settings/" .. DEFAULT_CONFIG .. ".json"
                if isfile and isfile(filePath) then
                    delfile(filePath)
                end
            end)
            Fluent:Notify({
                Title = "Fat Cat Hub",
                Content = "Config deleted! Execute the script again to apply default.",
                Duration = 5
            })
        end
    })

    -- TAB TELEPORT & PVP
    Tabs.TeleportPvP:AddSection("PvP Mechanics")
    Tabs.TeleportPvP:AddToggle("Noclip", {
        Title = "No Clip",
        Description = "Đi xuyên tường/vật cản",
        Default = false
    })
end

-- ====================================================================
-- 10. QUẢN LÝ CẤU HÌNH & TỰ ĐỘNG LƯU (SAVE MANAGER & CONFIG)
-- ====================================================================
local function SetupConfigManager()
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)
    SaveManager:SetFolder("FatCatHub")
    InterfaceManager:SetFolder("FatCatHub")
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({})
    InterfaceManager:BuildInterfaceSection(Tabs.Setting)
    
    pcall(function()
        SaveManager:Load(DEFAULT_CONFIG)
    end)
    
    local saveThread = nil
    local function RequestAutoSave()
        if not autoSaveActive then return end
        if saveThread then task.cancel(saveThread) end
        
        saveThread = task.delay(0.5, function()
            pcall(function()
                SaveManager:Save(DEFAULT_CONFIG)
            end)
        end)
    end
    
    task.defer(function()
        for _, option in pairs(Fluent.Options) do
            if type(option) == "table" and typeof(option.OnChanged) == "function" then
                option:OnChanged(function()
                    RequestAutoSave()
                end)
            end
        end
    end)
end

-- ====================================================================
-- 11. THỰC THI KHỞI CHẠY HỆ THỐNG
-- ====================================================================
BuildUI()
SetupConfigManager()

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fat Cat Hub",
    Content = "Fat Cat Hub v2.5 - Tải Hoàn Tất!",
    Duration = 5
})
