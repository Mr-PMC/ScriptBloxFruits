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

-- ====================================================================
-- 7. CÁC HÀM HOẠT ĐỘNG CHÍNH
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

local ATTACK_RADIUS = 60 -- Mặc định cố định 60 Studs (Tầm đánh tối đa server chấp nhận)

-- Hàm quét danh sách mục tiêu trong phạm vi 60 studs cố định
local function GetFastAttackTargets()
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
                if dist <= ATTACK_RADIUS then
                    table.insert(targets, {enemy, enemyRoot})
                end
            end
        end
    end

    return targets
end

-- Vòng lặp Fast Attack với Delay linh hoạt & Random Jitter né Anti-Cheat
task.spawn(function()
    while true do
        -- Lấy giá trị thời gian nghỉ từ ô nhập UI (Mặc định 0.5s)
        local baseDelay = 0.5
        if Fluent.Options and Fluent.Options.FastAttackDelay then
            baseDelay = tonumber(Fluent.Options.FastAttackDelay.Value) or 0.5
        end

        -- Tạo biến thiên ngẫu nhiên rất nhỏ (từ -0.015s đến +0.015s) sát với số được set để qua mặt Anti-Cheat
        local randomJitter = (math.random(-15, 15) / 1000)
        local actualDelay = math.max(0, baseDelay + randomJitter)

        task.wait(actualDelay)

        pcall(function()
            if Fluent.Options and Fluent.Options.FastAttack and Fluent.Options.FastAttack.Value then
                local char, root, hum = CharacterManager.Get()
                if not char or not hum or hum.Health <= 0 then return end

                local tool = char:FindFirstChildOfClass("Tool")
                if not tool then return end

                local targets = GetFastAttackTargets()
                if #targets > 0 then
                    if RegisterAttack and RegisterHit then
                        task.spawn(function()
                            RegisterAttack:FireServer(0)
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
    -- TAB TELEPORT & PVP
    Tabs.TeleportPvP:AddSection("PvP Mechanics")
    Tabs.TeleportPvP:AddToggle("Noclip", {
        Title = "No Clip",
        Description = "Đi xuyên tường/vật cản",
        Default = false
    })
    
    -- TAB SETTING
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
    
    Tabs.Setting:AddSection("Fast Attack Engine")
    -- Ô nhập/chỉnh tốc độ đánh (Delay)
    Tabs.Setting:AddSlider("FastAttackDelay", {
        Title = "Fast Attack Speed",
        Description = "",
        Default = 0.5,
        Min = 0,
        Max = 2,
        Rounding = 2
    })

    -- Nút bật tắt chế độ Fast Attack
    Tabs.Setting:AddToggle("FastAttack", {
        Title = "Fast Attack",
        Description = "",
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
