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
-- 7. CÁC HÀM HỖ TRỢ HOẠT ĐỘNG & TỐI ƯU HIỆU ỨNG (FX CLEANER)
-- ====================================================================


-- Anti AFK
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

local FX_Classes = {
    ["ParticleEmitter"] = true,
    ["Trail"]           = true,
    ["Beam"]            = true,
    ["Fire"]            = true,
    ["Smoke"]           = true,
    ["Sparkles"]        = true
}

local function cleanAttackFX(v)
    -- Chỉ thực hiện khi người dùng Bật toggle RemoveAttackFX
    if not (Fluent.Options and Fluent.Options.RemoveAttackFX and Fluent.Options.RemoveAttackFX.Value) then
        return
    end

    -- 1. Tắt các hiệu ứng hạt / vệt đao
    if FX_Classes[v.ClassName] then
        v.Enabled = false
        return
    end
    
    -- 2. Ẩn các Part/Mesh 3D làm sóng chém, vòng nổ khi tung chiêu
    if (v:IsA("BasePart") or v:IsA("MeshPart")) and not v.CanCollide then
        -- Không can thiệp vào Part trên người nhân vật
        if LocalPlayer.Character and v:IsDescendantOf(LocalPlayer.Character) then 
            return 
        end
        
        local name = v.Name:lower()
        local parentName = v.Parent and v.Parent.Name:lower() or ""
        
        if name:find("fx") or name:find("effect") or name:find("slash") or name:find("hit") or name:find("blast") or parentName:find("fx") or parentName:find("effect") then
            pcall(function()
                v.Transparency = 1
            end)
        end
    end
end

-- Bắt sự kiện khi có hiệu ứng mới xuất hiện
Workspace.DescendantAdded:Connect(cleanAttackFX)
if Workspace.CurrentCamera then
    Workspace.CurrentCamera.DescendantAdded:Connect(cleanAttackFX)
end

-- ====================================================================
-- 8. XÂY DỰNG GIAO DIỆN CHỨC NĂNG CHÍNH (BUILD REAL UI ELEMENTS)
-- ====================================================================
local function BuildUI()
    -- TAB SETTING

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
    
    Tabs.Setting:AddSection("Performance & Optimization")
    local RemoveFXToggle = Tabs.Setting:AddToggle("RemoveAttackFX", {
        Title = "Remove Attack FX",
        Description = "Xóa hiệu ứng chiêu thức, vệt chém và vòng nổ",
        Default = true
    })
    -- Khi Bật công tắc -> Quét dọn các hiệu ứng đang có sẵn ngay lập tức
    RemoveFXToggle:OnChanged(function(Value)
        if Value then
            for _, v in ipairs(Workspace:GetDescendants()) do
                cleanAttackFX(v)
            end
        end
    end)
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

-- Chạy quét ban đầu nếu Toggle được lưu trạng thái bật (Default = true)
if Fluent.Options.RemoveAttackFX and Fluent.Options.RemoveAttackFX.Value then
    for _, v in ipairs(Workspace:GetDescendants()) do
        cleanAttackFX(v)
    end
end

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fat Cat Hub",
    Content = "Fat Cat Hub v2.5 - Tải Hoàn Tất!",
    Duration = 5
})
