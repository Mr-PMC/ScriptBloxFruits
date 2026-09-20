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
    [2753915549] = 1,      -- Sea 1
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
-- 4. REMOTES & NET MODULE (CHUẨN CÁC HUB LỚN)
-- ====================================================================
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local CommF = Remotes and Remotes:WaitForChild("CommF_", 10)
local CommE = Remotes and Remotes:WaitForChild("CommE", 10)

local EnemiesFolder = Workspace:WaitForChild("Enemies", 10)
local NPCsFolder = Workspace:WaitForChild("NPCs", 10)
local MapFolder = Workspace:WaitForChild("Map", 10)
local SeaBeastsFolder = Workspace:FindFirstChild("SeaBeasts")
local BoatsFolder = Workspace:FindFirstChild("Boats")

-- Khởi tạo Net Module Wrapper
local NetModule, RegisterAttack, RegisterHit

local function GetNetModule()
    if RegisterAttack and RegisterHit then
        return true
    end

    local success, _ = pcall(function()
        local Modules = ReplicatedStorage:WaitForChild("Modules", 5)
        if Modules and Modules:FindFirstChild("Net") then
            NetModule = require(Modules.Net)
            RegisterAttack = NetModule:RemoteEvent("RegisterAttack")
            RegisterHit = NetModule:RemoteEvent("RegisterHit")
        end
    end)

    return success and (RegisterAttack ~= nil) and (RegisterHit ~= nil)
end

GetNetModule()

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

-- ====================================================================
-- 8. TỐI ƯU HÓA HIỆU ỨNG (FX CLEANER & FPS BOOST)
-- ====================================================================

local function IsFXCleanerEnabled()
    return Fluent 
       and Fluent.Options 
       and Fluent.Options.RemoveAttackFX 
       and Fluent.Options.RemoveAttackFX.Value
end

-- 8.1. Tối ưu Lighting & Môi trường
local function OptimizeLighting()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") then
            v.Enabled = false
        end
    end
end

-- 8.2. Hàm vô hiệu hóa render hiệu ứng
local function DisableFX(v)
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Texture = ""
    end
end

-- 8.3. Bắt sự kiện tạo Object mới trong Workspace
Workspace.DescendantAdded:Connect(function(v)
    if IsFXCleanerEnabled() then
        DisableFX(v)
        if v:IsA("BillboardGui") and (v.Name == "Damage" or v.Name:find("Damage") or v.Name == "DamageCounter") then
            v.Enabled = false
        end
    end
end)

-- 8.4. Vòng lặp dọn dẹp FX ngầm
task.spawn(function()
    OptimizeLighting()
    while task.wait(1) do
        if IsFXCleanerEnabled() then
            pcall(function()
                local fxFolder = Workspace:FindFirstChild("FX")
                if fxFolder then
                    fxFolder:ClearAllChildren()
                end

                for _, v in ipairs(Camera:GetChildren()) do
                    if v:IsA("Model") or v:IsA("Part") then
                        DisableFX(v)
                    end
                end
            end)
        end
    end
end)

-- ====================================================================
-- 9. FAST ATTACK ENGINE (TARGET BATCHING CHUẨN HUB LỚN)
-- ====================================================================
local ATTACK_RADIUS = 60

local function GetFastAttackTargets()
    local targets = {}
    local char, root, hum = CharacterManager.Get()
    if not char or not root then return targets end

    local myPos = root.Position

    if EnemiesFolder then
        for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") 
                               or enemy:FindFirstChild("UpperTorso") 
                               or enemy:FindFirstChild("Head")
            local enemyHum = enemy:FindFirstChildOfClass("Humanoid")

            if enemyRoot and enemyHum and enemyHum.Health > 0 then
                local dist = (enemyRoot.Position - myPos).Magnitude
                if dist <= ATTACK_RADIUS then
                    -- Cấu trúc chuẩn của Blox Fruits Batch: {Model, TargetPart}
                    table.insert(targets, {enemy, enemyRoot})
                end
            end
        end
    end

    return targets
end

task.spawn(function()
    while true do
        -- Delay động ngẫu nhiên (13ms - 20ms) giúp đánh cực nhanh và chống bị Kick/Rate-Limit
        task.wait(0.015 + (math.random(-2, 5) / 1000))

        pcall(function()
            if Fluent.Options and Fluent.Options.FastAttack and Fluent.Options.FastAttack.Value then
                local char, root, hum = CharacterManager.Get()
                if not char or not hum or hum.Health <= 0 then return end

                -- Bắt buộc phải cầm vũ khí trên tay
                local tool = char:FindFirstChildOfClass("Tool")
                if not tool then return end

                -- Kiểm tra Net Module
                if not GetNetModule() then return end

                local targets = GetFastAttackTargets()
                if #targets > 0 then
                    -- Gửi Vung Vũ Khí (0s Cooldown)
                    RegisterAttack:FireServer(0)
                    -- Gửi Hit Batch trúng toàn bộ mục tiêu trong tầm đánh cùng 1 lúc
                    RegisterHit:FireServer(targets[1][2], targets)
                end
            end
        end)
    end
end)

-- ====================================================================
-- 10. XÂY DỰNG GIAO DIỆN CHỨC NĂNG CHÍNH (BUILD REAL UI ELEMENTS)
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
    Tabs.Setting:AddToggle("FastAttack", {
        Title = "Fast Attack",
        Description = "Kích hoạt đánh nhanh",
        Default = true
    })

    Tabs.Setting:AddSection("Performance")
    Tabs.Setting:AddToggle("RemoveAttackFX", {
        Title = "Remove Attack FX (FPS Boost)",
        Description = "Tắt vệt chém, hiệu ứng nổ, số dame & rung màn hình",
        Default = true
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
-- 11. QUẢN LÝ CẤU HÌNH & TỰ ĐỘNG LƯU (SAVE MANAGER & CONFIG)
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
-- 12. THỰC THI KHỞI CHẠY HỆ THỐNG
-- ====================================================================
BuildUI()
SetupConfigManager()

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fat Cat Hub",
    Content = "Fat Cat Hub v2.5 - Tải Hoàn Tất!",
    Duration = 5
})
