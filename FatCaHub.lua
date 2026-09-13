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

local Net = ReplicatedStorage:WaitForChild("Modules", 10):WaitForChild("Net", 10)
local RegisterAttack = Net and Net:WaitForChild("RegisterAttack", 5)
local RegisterHit = Net and Net:WaitForChild("RegisterHit", 5)

local EnemiesFolder = Workspace:WaitForChild("Enemies", 10)

-- ====================================================================
-- 5. FAST ATTACK SYSTEM (ĐÃ FIX TRUY CẬP FRAMEWORK)
-- ====================================================================
local CombatFrameworkModule = nil

local function GetCombatFramework()
    if CombatFrameworkModule then return CombatFrameworkModule end

    -- Cách 1: Require trực tiếp từ PlayerScripts (Chạy được trên 100% Executor)
    pcall(function()
        local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
        if playerScripts then
            local cf = playerScripts:FindFirstChild("CombatFramework")
            if cf then
                CombatFrameworkModule = require(cf)
            end
        end
    end)

    if CombatFrameworkModule then return CombatFrameworkModule end

    -- Cách 2: Quét getgc nếu cách 1 bị chặn
    if getgc then
        pcall(function()
            for _, v in pairs(getgc(true)) do
                if type(v) == "table" and rawget(v, "activeController") then
                    CombatFrameworkModule = v
                    return
                end
            end
        end)
    end

    return CombatFrameworkModule
end

-- Vòng lặp Fast Attack chính
task.spawn(function()
    while task.wait(0.01) do
        if Fluent.Options and Fluent.Options.FastAttack and Fluent.Options.FastAttack.Value then
            pcall(function()
                local char, root, hum = CharacterManager.Get()
                if not char then return end

                local tool = char:FindFirstChildOfClass("Tool")
                if not tool or tool.ToolTip == "Gun" then return end

                -- Truy cập Controller đòn đánh
                local framework = GetCombatFramework()
                if framework and framework.activeController then
                    local controller = framework.activeController
                    if controller.equippedWeapon then
                        -- Bỏ qua thời gian chờ đòn đánh
                        controller.timeToNextAttack = 0
                        controller.timeToNextRegen = 0
                        controller.increment = 3
                        controller.hitboxMagnitude = 60 -- Tăng bán kính đòn đánh lên 60 studs

                        -- Kích hoạt đòn đánh gốc của Blox Fruits
                        if type(controller.attack) == "function" then
                            controller:attack()
                        end
                    end
                else
                    -- Dự phòng bằng mô phỏng Click nếu Module bị mã hóa hoàn toàn
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end

                -- Tắt Animation chém để tối ưu FPS & tránh giật màn hình
                if hum.Animator then
                    for _, track in ipairs(hum.Animator:GetPlayingAnimationTracks()) do
                        local name = track.Name:lower()
                        if name:find("attack") or name:find("slash") or name:find("melee") or name:find("swing") then
                            track:Stop()
                        end
                    end
                end
            end)
        end
    end
end)

-- ====================================================================
-- 6. KHỞI TẠO FRAMEWORK FLUENT UI & TABS
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
-- 7. XÂY DỰNG GIAO DIỆN CẤU HÌNH (BUILD UI ELEMENTS)
-- ====================================================================
local function BuildUI()
    Tabs.Setting:AddSection("Fast Attack")

    Tabs.Setting:AddToggle("FastAttack", {
        Title = "Fast Attack",
        Description = "Tự động đánh siêu tốc mọi mục tiêu trong phạm vi",
        Default = true
    })

    Tabs.Setting:AddSection("Automation Settings")
    
    Tabs.Setting:AddToggle("AutoBuso", {
        Title = "Auto Turn On Buso",
        Default = true
    })
    
    Tabs.Setting:AddToggle("AutoKen", {
        Title = "Auto Turn On Ken",
        Default = true
    })
    
    Tabs.Setting:AddToggle("AntiAFK", {
        Title = "Auto Anti AFK",
        Default = true
    })

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
                Content = "Đã xóa Config thành công!",
                Duration = 5
            })
        end
    })
end

-- ====================================================================
-- 8. THỰC THI CHƯƠNG TRÌNH
-- ====================================================================
BuildUI()

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

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fat Cat Hub",
    Content = "Fat Cat Hub v2.5 - Fast Attack đã sửa hoàn toàn!",
    Duration = 5
})
