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

-- ====================================================================
-- 7. CÁC HÀM HỖ TRỢ HOẠT ĐỘNG & FAST ATTACK LOGIC
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

-- Hàm quét danh sách Part quái nằm trong khoảng cách cho phép
local function GetEnemiesInRange(maxDistance)
    local hitTargets = {}
    local char, root = CharacterManager.Get()
    if not root or not EnemiesFolder then return hitTargets end

    for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
        local enemyHum = enemy:FindFirstChildOfClass("Humanoid")
        if enemyRoot and enemyHum and enemyHum.Health > 0 then
            local dist = (enemyRoot.Position - root.Position).Magnitude
            if dist <= (maxDistance or 60) then
                local hitPart = enemy:FindFirstChild("Head") or enemyRoot
                table.insert(hitTargets, hitPart)
            end
        end
    end
    return hitTargets
end

-- Vòng lặp Fast Attack nâng cấp
task.spawn(function()
    local comboStep = 1
    while task.wait(0.05) do
        pcall(function()
            if Fluent.Options and Fluent.Options.FastAttack and Fluent.Options.FastAttack.Value then
                local char, root, hum = CharacterManager.Get()
                if char and hum and hum.Health > 0 then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword" or tool.ToolTip == "Blox Fruit") then
                        local targets = GetEnemiesInRange(60)
                        if #targets > 0 then
                            -- Ép vũ khí tung đòn đánh trên Client
                            tool:Activate()

                            -- Đăng ký nhịp vung đòn
                            if RegisterAttack then
                                RegisterAttack:FireServer(0.4, comboStep)
                                comboStep = (comboStep % 4) + 1
                            end

                            -- Đăng ký sát thương trực tiếp lên danh sách quái đã quét
                            if RegisterHit then
                                RegisterHit:FireServer(targets[1], targets)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ====================================================================
-- 8. XÂY DỰNG GIAO DIỆN CHỨC NĂNG CHÍNH (BUILD REAL UI ELEMENTS)
-- ====================================================================
local function BuildUI()
    -- TAB SETTING
    Tabs.Setting:AddSection("Combat Settings")

    Tabs.Setting:AddToggle("FastAttack", {
        Title = "Fast Attack",
        Description = "Tự động kích hoạt đòn đánh nhanh không delay",
        Default = false
    })

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

    Tabs.Setting:AddToggle("AntiAFK", {
        Title = "Anti AFK",
        Description = "",
        Default = true
    })

    Tabs.Setting:AddSection("Config")

    Tabs.Setting:AddButton({
        Title = "Reset Config",
        Description = "Delete saved configuration file",
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
-- 9. QUẢN LÝ CẤU HÌNH & TỰ ĐỘNG LƯU (SAVE MANAGER & CONFIG)
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
-- 10. THỰC THI KHỞI CHẠY HỆ THỐNG
-- ====================================================================
BuildUI()
SetupConfigManager()

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fat Cat Hub",
    Content = "Fat Cat Hub v2.5 - Tải Hoàn Tất!",
    Duration = 5
})
