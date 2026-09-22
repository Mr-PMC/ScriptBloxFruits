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
    [85211729168715] = 1,  -- Sea 1 Sub-place
    [79091703265657] = 2,  -- Sea 2
    [100117331123089] = 3   -- Sea 3
}

local currentSea = MAP_SEAS[game.PlaceId]
if not currentSea then
    Players.LocalPlayer:Kick("PlaceId không hợp lệ!")
    return
end

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
-- 4. REMOTES & NET MODULE
-- ====================================================================
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local CommF = Remotes and Remotes:WaitForChild("CommF_", 10)
local CommE = Remotes and Remotes:WaitForChild("CommE", 10)

local EnemiesFolder = Workspace:WaitForChild("Enemies", 10)
local NPCsFolder = Workspace:WaitForChild("NPCs", 10)

-- Lấy trực tiếp từ ReplicatedStorage.Modules.Net
local ModulesFolder = ReplicatedStorage:WaitForChild("Modules", 10)
local NetFolder = ModulesFolder and ModulesFolder:WaitForChild("Net", 10)

local RegisterAttack = NetFolder and NetFolder:WaitForChild("RE/RegisterAttack", 10)
local RegisterHit = NetFolder and NetFolder:WaitForChild("RE/RegisterHit", 10)

local function GetNetRemotes()
    return (RegisterAttack ~= nil) and (RegisterHit ~= nil)
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

local DEFAULT_CONFIG = "BloxFruit_" .. LocalPlayer.Name
local autoSaveActive = true

-- ====================================================================
-- 6. CÁC HÀM TỰ ĐỘNG (ANTI-AFK, BUSO, KEN, NOCLIP)
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
-- 7. TỐI ƯU HÓA HIỆU ỨNG (FX CLEANER & FPS BOOST)
-- ====================================================================
local function IsFXCleanerEnabled()
    return Fluent
        and Fluent.Options
        and Fluent.Options.RemoveAttackFX
        and Fluent.Options.RemoveAttackFX.Value
end

local function OptimizeLighting()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") then
            v.Enabled = false
        end
    end
end

local function DisableFX(v)
    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
        v.Enabled = false
    elseif v:IsA("Decal") or v:IsA("Texture") then
        v.Texture = ""
    end
end

Workspace.DescendantAdded:Connect(function(v)
    if IsFXCleanerEnabled() then
        DisableFX(v)
        if v:IsA("BillboardGui") and (v.Name == "Damage" or v.Name:find("Damage") or v.Name == "DamageCounter") then
            v.Enabled = false
        end
    end
end)

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
-- 8. FAST ATTACK ENGINE (GẮN SYSTEM LOG CHI TIẾT ĐỂ SOI NGUYÊN NHÂN LỖI)
-- ====================================================================
local CombatFramework = nil
local activeController = nil

task.spawn(function()
    pcall(function()
        local playerScripts = LocalPlayer:WaitForChild("PlayerScripts", 5)
        if playerScripts then
            local cfScript = playerScripts:WaitForChild("CombatFramework", 5)
            if cfScript then
                CombatFramework = require(cfScript)
            end
        end
    end)
end)

local function GetActiveController()
    if not CombatFramework then return nil end
    pcall(function()
        if debug and debug.getupvalues then
            local upvalues = debug.getupvalues(CombatFramework)
            if upvalues then
                for _, v in pairs(upvalues) do
                    if type(v) == "table" and rawget(v, "activeController") then
                        activeController = v.activeController
                        break
                    end
                end
            end
        end
    end)
    return activeController
end

local ATTACK_RADIUS = 55
local MAX_TARGETS = 10
local comboCount = 1

local function GetFastAttackTargets()
    local targets = {}
    local primaryTarget = nil
    local char, root = CharacterManager.Get()
    if not char or not root then return nil, targets end
    local myPos = root.Position

    if EnemiesFolder then
        for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
            local enemyHum = enemy:FindFirstChildOfClass("Humanoid")
            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart") 
                               or enemy:FindFirstChild("UpperTorso") 
                               or enemy:FindFirstChild("Head")

            if enemyHum and enemyHum.Health > 0 and enemyRoot then
                if (enemyRoot.Position - myPos).Magnitude <= ATTACK_RADIUS then
                    if not primaryTarget then primaryTarget = enemyRoot end
                    if #targets < MAX_TARGETS then
                        table.insert(targets, enemyRoot)
                    end
                end
            end
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                if (hrp.Position - myPos).Magnitude <= ATTACK_RADIUS then
                    if not primaryTarget then primaryTarget = hrp end
                    if #targets < MAX_TARGETS then
                        table.insert(targets, hrp)
                    end
                end
            end
        end
    end

    return primaryTarget, targets
end

-- Vòng lặp Fast Attack tích hợp Diagnostic Logger
task.spawn(function()
    print("--------------------------------------------------")
    print("[FAT CAT HUB] 🚀 Đã bật Logger soi dữ liệu Fast Attack!")
    print("--------------------------------------------------")

    while true do
        local currentDelay = math.random(110, 150) / 1000
        task.wait(currentDelay)

        pcall(function()
            if Fluent.Options and Fluent.Options.FastAttack and Fluent.Options.FastAttack.Value then
                local char, root, hum = CharacterManager.Get()
                if not char or not hum or hum.Health <= 0 then return end

                local tool = char:FindFirstChildOfClass("Tool")
                if not tool then return end

                local toolType = (tool.ToolTip and tool.ToolTip ~= "") and tool.ToolTip or "Khong Co ToolTip"
                local primary, targets = GetFastAttackTargets()

                if not primary or #targets == 0 then return end

                local targetName = primary.Parent and primary.Parent.Name or "Unknown Target"
                local dist = math.floor((primary.Position - root.Position).Magnitude)
                local controller = GetActiveController()
                local maxCombo = 4

                if controller then
                    controller.timeToNextAttack = 0
                    controller.attacking = false
                    controller.hitboxMagnitude = ATTACK_RADIUS
                    maxCombo = rawget(controller, "maxCombo") or controller.maxHits or 4
                end

                comboCount = (comboCount % maxCombo) + 1

                -- 1. PRINT LOG THÔNG SỐ VŨ KHÍ & MỤC TIÊU
                print(string.format(
                    "\n[FAT CAT DIAGNOSTIC - %s]\n" ..
                    " 🎒 Tên Vũ Khí: %s | ToolTip (Loại): %s\n" ..
                    " 🎯 Mục tiêu: %s | Khoảng cách: %d studs\n" ..
                    " 👥 Số lượng mục tiêu nhận sát thương: %d\n" ..
                    " ⚡ Combo Hit: %d/%d | Delay: %.3fs\n" ..
                    " 📡 Net Remotes Available: %s",
                    os.date("%X"),
                    tool.Name, toolType,
                    targetName, dist,
                    #targets,
                    comboCount, maxCombo, currentDelay,
                    GetNetRemotes() and "Co (Ready)" or "Khong (Missing)"
                ))

                -- 2. THỬ BẮN REMOTE VÀ LOG KẾT QUẢ GỬI PACKET
                if GetNetRemotes() then
                    local attackOk, errAttack = pcall(function()
                        RegisterAttack:FireServer(currentDelay, comboCount)
                    end)

                    local hitOk, errHit = pcall(function()
                        RegisterHit:FireServer(primary, targets)
                    end)

                    if attackOk and hitOk then
                        print(string.format(" 🟢 Gửi thành công RegisterAttack & RegisterHit cho [%s]", toolType))
                    else
                        warn(string.format(" 🔴 LỖI GỬI REMOTE: AttackErr: %s | HitErr: %s", tostring(errAttack), tostring(errHit)))
                    end
                end

                -- 3. KÍCH HOẠT VŨ KHÍ
                tool:Activate()
                print(" 🗡️ Đã gọi tool:Activate()")
            end
        end)
    end
end)

-- ====================================================================
-- 9. GIAO DIỆN VÀ LƯU CONFIG
-- ====================================================================
local function BuildUI()
    Tabs.TeleportPvP:AddSection("PvP Mechanics")
    Tabs.TeleportPvP:AddToggle("Noclip", {
        Title = "No Clip",
        Description = "Đi xuyên tường/vật cản",
        Default = false
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
                Content = "Config deleted!",
                Duration = 5
            })
        end
    })

    Tabs.Setting:AddSection("Fast Attack Engine")
    Tabs.Setting:AddToggle("FastAttack", {
        Title = "Fast Attack",
        Description = "Kích hoạt đánh nhanh (Bypass Anti-Cheat & Dynamic Delay)",
        Default = true
    })

    Tabs.Setting:AddSection("Performance")
    Tabs.Setting:AddToggle("RemoveAttackFX", {
        Title = "Remove Attack FX (FPS Boost)",
        Description = "Tắt hiệu ứng, số dame & rung màn hình",
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
        Description = "Chống văng game khi treo máy",
        Default = true
    })
end

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

BuildUI()
SetupConfigManager()

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fat Cat Hub",
    Content = "Fat Cat Hub v2.5 - Tải Hoàn Tất!",
    Duration = 5
})
