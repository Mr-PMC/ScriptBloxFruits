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

-- Remotes Fast Attack & Hit Registration
local Modules = ReplicatedStorage:WaitForChild("Modules", 10)
local Net = Modules and Modules:WaitForChild("Net", 10)
local RegisterAttack = Net and Net:WaitForChild("RE/RegisterAttack", 10)
local RegisterHit = Net and Net:WaitForChild("RE/RegisterHit", 10)

local EnemiesFolder = Workspace:WaitForChild("Enemies", 10)
local NPCsFolder = Workspace:WaitForChild("NPCs", 10)
local MapFolder = Workspace:WaitForChild("Map", 10)
local SeaBeastsFolder = Workspace:FindFirstChild("SeaBeasts")
local BoatsFolder = Workspace:FindFirstChild("Boats")

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

local FarmConfig = {
    FlySpeed = 310,
    FarmDistance = 10,
    BringMobRadius = 280
}

-- ====================================================================
-- 7. MATRIX QUEST DATA (CƠ SỞ DỮ LIỆU QUEST SEA 1, 2, 3)
-- ====================================================================
local QuestDataMatrix = {
    [1] = { -- Sea 1
        {MinLevel = 1, MaxLevel = 9, Quest = "BanditQuest1", Level = 1, Mob = "Bandit [Lv. 5]", NPCPos = CFrame.new(1059.37, 16.45, 1550.42), MobPos = CFrame.new(1145, 17, 1634)},
        {MinLevel = 10, MaxLevel = 14, Quest = "JungleQuest", Level = 1, Mob = "Monkey [Lv. 14]", NPCPos = CFrame.new(-1598.44, 36.85, 153.86), MobPos = CFrame.new(-1610, 37, 145)},
        {MinLevel = 15, MaxLevel = 29, Quest = "JungleQuest", Level = 2, Mob = "Gorilla [Lv. 20]", NPCPos = CFrame.new(-1598.44, 36.85, 153.86), MobPos = CFrame.new(-1240, 6, 500)},
        {MinLevel = 30, MaxLevel = 39, Quest = "BuggyQuest1", Level = 1, Mob = "Pirate [Lv. 35]", NPCPos = CFrame.new(-1140, 4, 3828), MobPos = CFrame.new(-1215, 4, 3915)},
        {MinLevel = 40, MaxLevel = 59, Quest = "BuggyQuest1", Level = 2, Mob = "Brute [Lv. 45]", NPCPos = CFrame.new(-1140, 4, 3828), MobPos = CFrame.new(-1145, 14, 4300)},
        {MinLevel = 60, MaxLevel = 89, Quest = "DesertQuest", Level = 1, Mob = "Desert Bandit [Lv. 60]", NPCPos = CFrame.new(894, 6, 4388), MobPos = CFrame.new(950, 6, 4450)},
        {MinLevel = 90, MaxLevel = 119, Quest = "SnowQuest", Level = 1, Mob = "Snow Bandit [Lv. 90]", NPCPos = CFrame.new(1385, 87, -1298), MobPos = CFrame.new(1280, 105, -1380)},
        {MinLevel = 120, MaxLevel = 149, Quest = "MarineQuest2", Level = 1, Mob = "Chief Petty Officer [Lv. 120]", NPCPos = CFrame.new(-5035, 28, 4324), MobPos = CFrame.new(-4850, 22, 4260)},
        {MinLevel = 150, MaxLevel = 189, Quest = "SkyQuest", Level = 1, Mob = "Sky Bandit [Lv. 150]", NPCPos = CFrame.new(-4842, 717, -2623), MobPos = CFrame.new(-4975, 714, -2890)},
        {MinLevel = 190, MaxLevel = 224, Quest = "PrisonerQuest", Level = 1, Mob = "Prisoner [Lv. 190]", NPCPos = CFrame.new(530, 2, 474), MobPos = CFrame.new(480, 2, 580)},
        {MinLevel = 225, MaxLevel = 299, Quest = "ColosseumQuest", Level = 1, Mob = "Toga Warrior [Lv. 225]", NPCPos = CFrame.new(-1580, 7, -2980), MobPos = CFrame.new(-1800, 7, -2900)},
        {MinLevel = 300, MaxLevel = 374, Quest = "MagmaQuest", Level = 1, Mob = "Military Soldier [Lv. 300]", NPCPos = CFrame.new(-5315, 12, 8515), MobPos = CFrame.new(-5400, 11, 8530)},
        {MinLevel = 375, MaxLevel = 449, Quest = "FishmanQuest", Level = 1, Mob = "Fishman Warrior [Lv. 375]", NPCPos = CFrame.new(61122, 18, 1567), MobPos = CFrame.new(61000, 18, 1450)},
        {MinLevel = 450, MaxLevel = 524, Quest = "SkyExp1Quest", Level = 1, Mob = "God's Guard [Lv. 450]", NPCPos = CFrame.new(-4720, 846, -1950), MobPos = CFrame.new(-4710, 844, -1860)},
        {MinLevel = 525, MaxLevel = 624, Quest = "SkyExp2Quest", Level = 1, Mob = "Shandora Warrior [Lv. 525]", NPCPos = CFrame.new(-7860, 5545, -380), MobPos = CFrame.new(-7750, 5545, -430)},
        {MinLevel = 625, MaxLevel = 699, Quest = "FountainQuest", Level = 1, Mob = "Corporal [Lv. 625]", NPCPos = CFrame.new(5258, 38, 4050), MobPos = CFrame.new(5100, 38, 4120)},
    },
    [2] = { -- Sea 2
        {MinLevel = 700, MaxLevel = 724, Quest = "Area1Quest", Level = 1, Mob = "Raider [Lv. 700]", NPCPos = CFrame.new(-425, 73, 1835), MobPos = CFrame.new(-750, 73, 2400)},
        {MinLevel = 725, MaxLevel = 774, Quest = "Area1Quest", Level = 2, Mob = "Mercenary [Lv. 725]", NPCPos = CFrame.new(-425, 73, 1835), MobPos = CFrame.new(-930, 73, 1420)},
        {MinLevel = 775, MaxLevel = 874, Quest = "Area2Quest", Level = 1, Mob = "Swan Pirate [Lv. 775]", NPCPos = CFrame.new(635, 73, 918), MobPos = CFrame.new(880, 120, 1230)},
        {MinLevel = 875, MaxLevel = 999, Quest = "MarineQuest", Level = 1, Mob = "Marine Lieutenant [Lv. 875]", NPCPos = CFrame.new(-2440, 73, -3220), MobPos = CFrame.new(-2800, 73, -3000)},
        {MinLevel = 1000, MaxLevel = 1124, Quest = "SnowMountainQuest", Level = 1, Mob = "Snow Trooper [Lv. 1000]", NPCPos = CFrame.new(605, 400, -5370), MobPos = CFrame.new(500, 400, -5500)},
        {MinLevel = 1125, MaxLevel = 1249, Quest = "IceSideQuest", Level = 1, Mob = "Ice Military [Lv. 1125]", NPCPos = CFrame.new(5810, 28, -6270), MobPos = CFrame.new(6000, 28, -6180)},
        {MinLevel = 1250, MaxLevel = 1349, Quest = "ShipQuest1", Level = 1, Mob = "Ship Deckhand [Lv. 1250]", NPCPos = CFrame.new(1030, 125, 32900), MobPos = CFrame.new(1200, 125, 33000)},
        {MinLevel = 1350, MaxLevel = 1424, Quest = "FrostQuest", Level = 1, Mob = "Arctic Warrior [Lv. 1350]", NPCPos = CFrame.new(5670, 28, -6480), MobPos = CFrame.new(6000, 28, -6800)},
        {MinLevel = 1425, MaxLevel = 1499, Quest = "ForgottenQuest", Level = 1, Mob = "Sea Soldier [Lv. 1425]", NPCPos = CFrame.new(-3050, 240, -10140), MobPos = CFrame.new(-3000, 240, -9800)},
    },
    [3] = { -- Sea 3
        {MinLevel = 1500, MaxLevel = 1524, Quest = "PiratePortQuest", Level = 1, Mob = "Pirate Millionaire [Lv. 1500]", NPCPos = CFrame.new(-290, 44, 5580), MobPos = CFrame.new(-370, 75, 5550)},
        {MinLevel = 1525, MaxLevel = 1574, Quest = "PiratePortQuest", Level = 2, Mob = "Pistol Billionaire [Lv. 1525]", NPCPos = CFrame.new(-290, 44, 5580), MobPos = CFrame.new(-220, 74, 6000)},
        {MinLevel = 1575, MaxLevel = 1699, Quest = "AmazonQuest", Level = 1, Mob = "Dragon Crew Warrior [Lv. 1575]", NPCPos = CFrame.new(5830, 52, -1100), MobPos = CFrame.new(6400, 52, -800)},
        {MinLevel = 1700, MaxLevel = 1824, Quest = "MarineTreeQuest", Level = 1, Mob = "Marine Commodore [Lv. 1700]", NPCPos = CFrame.new(2180, 29, -6740), MobPos = CFrame.new(2400, 70, -6800)},
        {MinLevel = 1825, MaxLevel = 1899, Quest = "DeepForestIsland1Quest", Level = 1, Mob = "Fishman Raider [Lv. 1825]", NPCPos = CFrame.new(-13270, 332, -7630), MobPos = CFrame.new(-13000, 332, -7900)},
        {MinLevel = 1900, MaxLevel = 1974, Quest = "DeepForestIsland2Quest", Level = 1, Mob = "Jungle Pirate [Lv. 1900]", NPCPos = CFrame.new(-12680, 390, -9900), MobPos = CFrame.new(-12100, 332, -10500)},
        {MinLevel = 1975, MaxLevel = 2074, Quest = "HauntedQuest1", Level = 1, Mob = "Reborn Skeleton [Lv. 1975]", NPCPos = CFrame.new(-9480, 142, 5520), MobPos = CFrame.new(-8800, 142, 6000)},
        {MinLevel = 2075, MaxLevel = 2199, Quest = "PeanutQuest", Level = 1, Mob = "Peanut Scout [Lv. 2075]", NPCPos = CFrame.new(-2100, 38, -10190), MobPos = CFrame.new(-2000, 38, -10400)},
        {MinLevel = 2200, MaxLevel = 2299, Quest = "IceCreamQuest1", Level = 1, Mob = "Ice Cream Chef [Lv. 2200]", NPCPos = CFrame.new(-750, 65, -10980), MobPos = CFrame.new(-600, 65, -11200)},
        {MinLevel = 2300, MaxLevel = 2600, Quest = "ChocolatQuest1", Level = 1, Mob = "Cocoa Warrior [Lv. 2300]", NPCPos = CFrame.new(230, 24, -12200), MobPos = CFrame.new(350, 24, -12400)},
    }
}

-- ====================================================================
-- 8. CÁC HÀM HỖ TRỢ FARM & THAO TÁC CƠ BẢN
-- ====================================================================

-- Tự động cầm vũ khí đã chọn
local function EquipWeapon()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end

    local selectedType = (Fluent.Options.SelectWeapon and Fluent.Options.SelectWeapon.Value) or "Melee"

    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool and (currentTool.ToolTip == selectedType or (selectedType == "Melee" and currentTool.ToolTip == "Melee")) then
        return currentTool
    end

    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            if (selectedType == "Melee" and item.ToolTip == "Melee") or
               (selectedType == "Sword" and item.ToolTip == "Sword") or
               (selectedType == "Blox Fruit" and item.ToolTip == "Blox Fruit") then
                hum:EquipTool(item)
                return item
            end
        end
    end
    return currentTool
end

-- Fast Attack Logic
local function ExecuteFastAttack(targetMob)
    pcall(function()
        local tool = EquipWeapon()
        if not tool then return end

        tool:Activate()
        if RegisterAttack then
            RegisterAttack:FireServer(0)
        end
        if RegisterHit and targetMob and targetMob:FindFirstChild("Head") then
            local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("Part")
            if handle then
                RegisterHit:FireServer(targetMob.Head, {handle})
            end
        end
    end)
end

-- Group / Bring Mob Engine
local function GroupEnemies(mobName, targetCFrame)
    if not EnemiesFolder then return end
    for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
        if enemy.Name == mobName then
            local eHum = enemy:FindFirstChildOfClass("Humanoid")
            local eRoot = enemy:FindFirstChild("HumanoidRootPart")
            if eHum and eHum.Health > 0 and eRoot then
                if (eRoot.Position - targetCFrame.Position).Magnitude <= FarmConfig.BringMobRadius then
                    eRoot.CFrame = targetCFrame
                    eRoot.CanCollide = false
                    eRoot.Size = Vector3.new(30, 30, 30)
                    eHum.WalkSpeed = 0
                    eHum:ChangeState(Enum.HumanoidStateType.Physics)
                end
            end
        end
    end
end

-- Tự động tra cứu Quest theo Level
local function GetCurrentQuestData()
    local levelData = LocalPlayer:FindFirstChild("Data") and LocalPlayer.Data:FindFirstChild("Level")
    local pLevel = levelData and levelData.Value or 1
    local currentSeaQuests = QuestDataMatrix[currentSea] or QuestDataMatrix[1]

    for _, data in ipairs(currentSeaQuests) do
        if pLevel >= data.MinLevel and pLevel <= data.MaxLevel then
            return data
        end
    end
    return currentSeaQuests[#currentSeaQuests]
end

-- Safe Tween Movement
local currentTween = nil
local function FarmFlyTo(targetCFrame)
    local char, root = CharacterManager.Get()
    if not root then return end

    local distance = (root.Position - targetCFrame.Position).Magnitude
    if distance <= 12 then
        if currentTween then currentTween:Cancel() end
        root.CFrame = targetCFrame
        return
    end

    local bodyVel = root:FindFirstChild("FatCatVelocity")
    if not bodyVel then
        bodyVel = Instance.new("BodyVelocity")
        bodyVel.Name = "FatCatVelocity"
        bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVel.Parent = root
    end
    bodyVel.Velocity = Vector3.zero

    local tweenInfo = TweenInfo.new(distance / FarmConfig.FlySpeed, Enum.EasingStyle.Linear)
    currentTween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    currentTween:Play()
end

local function StopFly()
    if currentTween then currentTween:Cancel() end
    local char, root = CharacterManager.Get()
    if root and root:FindFirstChild("FatCatVelocity") then
        root.FatCatVelocity:Destroy()
    end
end

local function HasQuest()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local mainGui = playerGui and playerGui:FindFirstChild("Main")
    local questFrame = mainGui and mainGui:FindFirstChild("Quest")
    return questFrame and questFrame.Visible == true
end

-- ====================================================================
-- 9. VÒNG LẶP UTILITY SẴN CÓ (ANTI-AFK, BUSO, KEN, NOCLIP)
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

-- Auto Buso
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

-- Auto Ken
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

-- No Clip
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

-- Loop Auto Farm Level
task.spawn(function()
    while task.wait(0.05) do
        pcall(function()
            if Fluent.Options and Fluent.Options.AutoFarmLevel and Fluent.Options.AutoFarmLevel.Value then
                local char, root, hum = CharacterManager.Get()
                if not char or not root or hum.Health <= 0 then return end

                local questData = GetCurrentQuestData()
                if not questData then return end

                if not HasQuest() then
                    local npcDist = (root.Position - questData.NPCPos.Position).Magnitude
                    if npcDist > 15 then
                        FarmFlyTo(questData.NPCPos)
                    else
                        StopFly()
                        if CommF then
                            CommF:InvokeServer("StartQuest", questData.Quest, questData.Level)
                        end
                    end
                else
                    local targetMob = nil
                    if EnemiesFolder then
                        for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
                            if enemy.Name == questData.Mob then
                                local eHum = enemy:FindFirstChildOfClass("Humanoid")
                                if eHum and eHum.Health > 0 then
                                    targetMob = enemy
                                    break
                                end
                            end
                        end
                    end

                    if targetMob and targetMob:FindFirstChild("HumanoidRootPart") then
                        local mobRoot = targetMob.HumanoidRootPart
                        local farmPos = mobRoot.CFrame * CFrame.new(0, FarmConfig.FarmDistance, 0)

                        FarmFlyTo(farmPos)

                        if Fluent.Options.BringMob and Fluent.Options.BringMob.Value then
                            GroupEnemies(questData.Mob, mobRoot.CFrame)
                        end

                        if Fluent.Options.FastAttack and Fluent.Options.FastAttack.Value then
                            ExecuteFastAttack(targetMob)
                        end
                    else
                        FarmFlyTo(questData.MobPos)
                    end
                end
            else
                StopFly()
            end
        end)
    end
end)

-- Loop Auto Stats Point
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if Fluent.Options and Fluent.Options.AutoStats and Fluent.Options.AutoStats.Value then
                local selectedStat = Fluent.Options.SelectStat and Fluent.Options.SelectStat.Value or "Melee"
                if CommF then
                    CommF:InvokeServer("AddPoint", selectedStat, 3)
                end
            end
        end)
    end
end)

-- ====================================================================
-- 10. XÂY DỰNG GIAO DIỆN HỆ THỐNG (BUILD UI)
-- ====================================================================
local function BuildUI()
    -- TAB FARM - AUTO FARM LEVEL & STATS
    Tabs.Farm:AddSection("Auto Farm Level Settings")

    Tabs.Farm:AddDropdown("SelectWeapon", {
        Title = "Chọn Vũ Khí Farm",
        Values = {"Melee", "Sword", "Blox Fruit"},
        Default = "Melee"
    })

    Tabs.Farm:AddToggle("AutoFarmLevel", {
        Title = "Auto Farm Level",
        Description = "Tự động nhận Quest, di chuyển và tiêu diệt Mob",
        Default = false
    })

    Tabs.Farm:AddToggle("FastAttack", {
        Title = "Fast Attack Mode",
        Description = "Gửi Remote Hit để tăng tốc độ tấn công",
        Default = true
    })

    Tabs.Farm:AddToggle("BringMob", {
        Title = "Auto Bring Mob",
        Description = "Gom tất cả Mob lại một điểm để quái không bị tản ra",
        Default = true
    })

    Tabs.Farm:AddSection("Auto Stats Point")

    Tabs.Farm:AddDropdown("SelectStat", {
        Title = "Chọn Stat Cần Nâng",
        Values = {"Melee", "Defense", "Sword", "Demon Fruit"},
        Default = "Melee"
    })

    Tabs.Farm:AddToggle("AutoStats", {
        Title = "Auto Add Stats",
        Description = "Tự động cộng Stat mỗi khi lên cấp",
        Default = false
    })

    -- TAB SETTING
    Tabs.Setting:AddToggle("AutoBuso", {
        Title = "Auto Turn On Buso",
        Description = "",
        Default = true
    })

    Tabs.Setting:AddToggle("AutoKen", {
        Title = "Auto Turn On Ken",
        Description = "",
        Default = true
    })

    Tabs.Setting:AddToggle("Noclip", {
        Title = "No Clip (Xuyên Tường)",
        Description = "Đi xuyên qua mọi vật thể rắn và địa hình",
        Default = true
    })

    Tabs.Setting:AddToggle("AntiAFK", {
        Title = "Anti AFK",
        Description = "",
        Default = true
    })

    Tabs.Setting:AddSection("Config")

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
end


-- ====================================================================
-- 12. QUẢN LÝ CẤU HÌNH & TỰ ĐỘNG LƯU (SAVE MANAGER & CONFIG)
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
-- 13. THỰC THI KHỞI CHẠY HỆ THỐNG
-- ====================================================================
BuildUI()
SetupConfigManager()

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fat Cat Hub",
    Content = "Fat Cat Hub v2.5 - Tải Hoàn Tất!",
    Duration = 5
})
