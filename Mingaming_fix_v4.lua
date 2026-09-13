--[[
================================================================================
    MIN GAMING HUB - Blox Fruits Script
    Discord: discord.gg/25ms
================================================================================

    CẤU TRÚC FILE (Thứ tự logic tối ưu):
    1.  Services (khai báo 1 lần) & ParentGui
    2.  Fake Loader (UX loading)
    3.  Anti-Tamper (đã tắt)
    4.  Load Fluent UI Library
    5.  Tạo Window + Mobile Minimize Button
    6.  Tạo các Tab
    7.  Player & Sea Detection
    8.  Data Tables (Quest / Boss / Material)
    9.  Helper Functions (CheckLevel, Tween, Attack, ESP...)
    10. BuildUI() - Tất cả Toggle / Button / Logic farm
    11. Gọi BuildUI() + Notify hoàn thành

    Lưu ý:
    - Tất cả Roblox Services khai báo 1 lần ở mục 1
    - LocalPlayer alias: plr = Players.LocalPlayer (dùng plr xuyên suốt)
    - Phía dưới chỉ dùng biến (Players, ReplicatedStorage, Workspace, plr...)
    - Tất cả hàm hỗ trợ được định nghĩa TRƯỚC BuildUI
    - Data tables đứng trước các hàm sử dụng chúng
    - Biến _G. dùng để chia sẻ trạng thái giữa các loop
================================================================================
]]

-------------------------------------------------
-- 1. SERVICES CƠ BẢN (khai báo 1 lần, dùng xuyên suốt file)
-------------------------------------------------
local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local Workspace           = game:GetService("Workspace")
local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local RunService          = game:GetService("RunService")
local TeleportService     = game:GetService("TeleportService")
local Lighting            = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui             = game:GetService("CoreGui")
local HttpService         = game:GetService("HttpService")
local CollectionService   = game:GetService("CollectionService")
local LocalizationService = game:GetService("LocalizationService")
local VirtualUser         = game:GetService("VirtualUser")

-- Ưu tiên gethui() nếu executor hỗ trợ (an toàn hơn CoreGui)
local ParentGui = (gethui and gethui()) or CoreGui

-- Alias ngắn
local plr = Players.LocalPlayer
local RS  = ReplicatedStorage

-------------------------------------------------
-- 2. FAKE LOADER (Hiển thị loading giả lập)
-------------------------------------------------
shared.LoaderTitle = "Đăng Ký Kênh Min Gaming"

shared.LoaderKeyFrames = {
    [1] = {1, 10},   -- giây chờ, % progress
    [2] = {2, 30},
    [3] = {3, 60},
    [4] = {2, 100}
}

local LoaderConfig = {
    LoaderData = {
        Name = shared.LoaderTitle or "A Loader",
        Colors = shared.LoaderColors or {
            Main = Color3.fromRGB(0, 0, 0),
            Topic = Color3.fromRGB(200, 200, 200),
            Title = Color3.fromRGB(255, 255, 255),
            LoaderBackground = Color3.fromRGB(40, 40, 40),
            LoaderSplash = Color3.fromRGB(3, 252, 3)
        }
    },
    Keyframes = shared.LoaderKeyFrames
}

local LoaderStepTexts = {
    [1] = "Đang kiểm tra dữ liệu...",
    [2] = "Đang nạp thư viện UI...",
    [3] = "Đang kết nối Server...",
    [4] = "Thành công!"
}

function TweenObject(object, duration, goals)
    if not object then
        return
    end

    local tween = TweenService:Create(
        object,
        TweenInfo.new(
            duration,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        goals
    )

    tween:Play()
    return tween
end

_G.LoaderConfig = LoaderConfig
_G.LoaderStepTexts = LoaderStepTexts

function CreateObject(className, props)
    local instance = Instance.new(className)

    for property, value in pairs(props) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end

    instance.Parent = props.Parent
    return instance
end

local function AddUICorner(radius, parentObj)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parentObj
end

local LoaderGui = CreateObject("ScreenGui", {
    Name = "Core",
    Parent = ParentGui
})

local MainFrame = CreateObject("Frame", {
    Name = "Main",
    Parent = LoaderGui,
    BackgroundColor3 = LoaderConfig.LoaderData.Colors.Main,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.new(0, 0, 0, 0)
})

AddUICorner(12, MainFrame)

local UserImage = CreateObject("ImageLabel", {
    Name = "UserImage",
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Image = "rbxassetid://13717478897",
    Position = UDim2.new(0, 15, 0, 10),
    Size = UDim2.new(0, 50, 0, 50)
})

AddUICorner(25, UserImage)

local UserNameLabel = CreateObject("TextLabel", {
    Name = "UserName",
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Text = "Youtube: Min Gaming",
    Position = UDim2.new(0, 75, 0, 10),
    Size = UDim2.new(0, 200, 0, 50),
    Font = Enum.Font.GothamBold,
    TextColor3 = LoaderConfig.LoaderData.Colors.Title,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left
})

local TopicLabel = CreateObject("TextLabel", {
    Name = "Top",
    Parent = MainFrame,
    TextTransparency = 1,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 30, 0, 70),
    Size = UDim2.new(0, 301, 0, 20),
    Font = Enum.Font.Gotham,
    Text = "Loader",
    TextColor3 = LoaderConfig.LoaderData.Colors.Topic,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left
})

local TitleLabel = CreateObject("TextLabel", {
    Name = "Title",
    Parent = MainFrame,
    TextTransparency = 1,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 30, 0, 90),
    Size = UDim2.new(0, 301, 0, 46),
    Font = Enum.Font.Gotham,
    RichText = true,
    Text = "<b>" .. LoaderConfig.LoaderData.Name .. "</b>",
    TextColor3 = LoaderConfig.LoaderData.Colors.Title,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left
})

local ProgressBG = CreateObject("Frame", {
    Name = "BG",
    Parent = MainFrame,
    AnchorPoint = Vector2.new(0.5, 0),
    BackgroundTransparency = 1,
    BackgroundColor3 = LoaderConfig.LoaderData.Colors.LoaderBackground,
    BorderSizePixel = 0,
    Position = UDim2.new(0.5, 0, 0, 70),
    Size = UDim2.new(0.85, 0, 0, 24)
})

AddUICorner(8, ProgressBG)

local ProgressBar = CreateObject("Frame", {
    Name = "Progress",
    Parent = ProgressBG,
    BackgroundColor3 = LoaderConfig.LoaderData.Colors.LoaderSplash,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 0, 0, 24)
})

AddUICorner(8, ProgressBar)

local StepLabel = CreateObject("TextLabel", {
    Name = "StepLabel",
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, 0, 1, -25),
    Size = UDim2.new(1, -20, 0, 20),
    Font = Enum.Font.Gotham,
    Text = "",
    TextColor3 = LoaderConfig.LoaderData.Colors.Topic,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Center,
    AnchorPoint = Vector2.new(0.5, 0.5)
})

function UpdateStepText(stepIndex)
    StepLabel.Text = LoaderStepTexts[stepIndex] or ""
end

function UpdatePercentage(percent, stepIndex)
    TweenObject(ProgressBar, 0.5, {
        Size = UDim2.new(percent / 100, 0, 0, 24)
    })

    UpdateStepText(stepIndex)
end

-- Mở Loader
TweenObject(MainFrame, 0.25, {
    Size = UDim2.new(0, 346, 0, 121)
})

task.wait(0.25)

-- Hiện nội dung
TweenObject(TopicLabel, 0.5, {
    TextTransparency = 0
})

TweenObject(TitleLabel, 0.5, {
    TextTransparency = 0
})

TweenObject(ProgressBG, 0.5, {
    BackgroundTransparency = 0
})

TweenObject(ProgressBar, 0.5, {
    BackgroundTransparency = 0
})

-- Loading giả lập
for step, keyframe in ipairs(LoaderConfig.Keyframes) do
    task.wait(keyframe[1])
    UpdatePercentage(keyframe[2], step)
end

task.wait(0.5)

-- Ẩn nội dung
TweenObject(TopicLabel, 0.5, {
    TextTransparency = 1
})

TweenObject(TitleLabel, 0.5, {
    TextTransparency = 1
})

TweenObject(ProgressBG, 0.5, {
    BackgroundTransparency = 1
})

TweenObject(ProgressBar, 0.5, {
    BackgroundTransparency = 1
})

task.wait(0.5)

-- Đóng Loader
TweenObject(MainFrame, 0.25, {
    Size = UDim2.new(0, 0, 0, 0)
})

task.wait(0.25)

if LoaderGui and LoaderGui.Parent then
    LoaderGui:Destroy()
end

-- =========================================================
-- 3. ANTI-TAMPER / ANTI-SKID
--    TẠM THỜI TẮT (comment lại toàn bộ)
--    Chỉ bật khi cần bảo vệ code khỏi skid
-- =========================================================

--[[
spawn(function()
    while task.wait() do
        function print()
        end

        function warn()
        end

        function error()
        end

        debug.traceback = function()
            return "Traceback blocked"
        end

        debug.info = function()
            return "Info blocked"
        end

        local meta = getrawmetatable(game)

        if meta and not meta.__metatable then
            setreadonly(meta, false)

            local oldIndex = meta.__index
            local oldNewIndex = meta.__newindex

            meta.__index = function(metaObj, val4)
                if val4 == "debug" or val4 == "getrawmetatable" then
                    error("Anti Skid: Tampering detected!")
                end

                return oldIndex(metaObj, val4)
            end

            meta.__newindex = function(metaObj2, val5, metaVal)
                if val5 == "debug" or val5 == "getrawmetatable" then
                    error("Anti Skid: Tampering detected!")
                end

                return oldNewIndex(metaObj2, val5, metaVal)
            end

            setreadonly(meta, true)
        end

        local function checkEnvTamper()
            local envDangerList = {
                "_G",
                "debug",
                "getgenv",
                "getrawmetatable",
                "setfenv",
                "loadstring",
                "hookfunction"
            }

            for _, item in ipairs(envDangerList) do
                local pcallOk, pcallResult = pcall(function()
                    return _G[item]
                end)

                if pcallOk and pcallResult then
                    error("Anti Skid: Environment tampering detected!")
                end
            end
        end

        local function checkHookTamper()
            local hookDangerList = {
                getrawmetatable,
                setreadonly,
                getgenv,
                debug.getinfo,
                debug.getregistry
            }

            for _, item in ipairs(hookDangerList) do
                if item then
                    error("Anti Skid: Hook tampering detected!")
                end
            end
        end

        local temp1 = game:FindService("HttpService")

        if temp1 then
            temp1.RequestAsync = function()
                error("HTTP Requests Blocked")
            end

            temp1.GetAsync = function()
                error("HTTP Get Blocked")
            end

            temp1.PostAsync = function()
                error("HTTP Post Blocked")
            end
        end

        function collectgarbage()
            error("GC Blocked")
        end

        os.time = function()
            error("OS Time Blocked")
        end

        pcall(checkEnvTamper)
        pcall(checkHookTamper)
    end
end)
]]

-- =========================================================
-- HẾT ANTI-TAMPER
-- Hiện tại không thực thi.
-- =========================================================


-------------------------------------------------
-- 4. LOAD FLUENT UI LIBRARY
-------------------------------------------------
local success, Fluent = pcall(function()
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/Mr-PMC/FluentUI/refs/heads/master/main.lua"
    ))()
end)

assert(
    success and Fluent,
    "[Min Gaming] Không thể tải Fluent UI! Hãy kiểm tra lại kết nối mạng hoặc Executor."
)

local Window = Fluent:CreateWindow({
    Title = "Min Gaming",
    SubTitle = "",
    TabWidth = 160,
    Theme = "Light",
    Acrylic = false,
    Size = UDim2.fromOffset(500, 320),
    MinimizeKey = Enum.KeyCode.End
})



----------------------------------------------------------------
-- 6. TẠO CÁC TAB CHÍNH
----------------------------------------------------------------

local TabDefinitions = {
    {"Home",     "Thông Tin",   "info"},
    {"Main",     "Cày",         "sword"},
    {"Sea",      "Sự Kiện",     "waves"},
    {"ITM",      "Vật Phẩm",    "package"},
    {"Setting",  "Cài Đặt",     "settings"},
    {"Status",   "Máy Chủ",     "server"},
    {"Stats",    "Chỉ Số",      "bar-chart-2"},
    {"Player",   "Người Chơi",  "user"},
    {"Teleport", "Dịch Chuyển", "map-pin"},
    {"Fruit",    "Trái",        "apple"},
    {"Raid",     "Tập Kích",    "swords"},
    {"Race",     "Tộc",         "shield"},
    {"Shop",     "Cửa Hàng",    "shopping-cart"},
    {"Misc",     "Khác",        "layers"}
}

local Tabs = {}

for _, tab in ipairs(TabDefinitions) do
    local ok, result = pcall(Window.AddTab, Window, {
        Title = tab[2],
        Icon = tab[3]
    })

    if not ok or not result then
        result = Window:AddTab({Title = tab[2]})
    end

    Tabs[tab[1]] = result
end

----------------------------------------------------------------
-- 7. PLAYER & SEA DETECTION
--    (Players / ReplicatedStorage đã khai báo ở mục 1)
----------------------------------------------------------------
local PlaceId = game.PlaceId

-- Fluent Options (dùng để SetValue toggle)
local Options = Fluent.Options

-------------------------------------------------
-- PERSISTENT CONFIG SYSTEM (Min Gaming)
-- Lưu / khôi phục toàn bộ Options giữa các lần Execute
-- Mỗi tài khoản Roblox có 1 file riêng: DU_LIEU_TK_<TênTàiKhoản>.json
-------------------------------------------------
local CONFIG_FOLDER = "MinGamingHub"
local CONFIG_FILE   = CONFIG_FOLDER .. "/DU_LIEU_TK_" .. tostring(plr.Name) .. ".json"
local IsResettingConfig = false
local DefaultConfig = {}
local savePending = false
local saveGeneration = 0

local function DeepCopy(value)
    if type(value) ~= "table" then
        return value
    end
    local result = {}
    for k, v in pairs(value) do
        result[k] = DeepCopy(v)
    end
    return result
end

local function EnsureConfigFolder()
    if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
        if not isfolder(CONFIG_FOLDER) then
            pcall(makefolder, CONFIG_FOLDER)
        end
    end
end

local function WriteConfig(data)
    if typeof(writefile) ~= "function" then
        return
    end

    pcall(function()
        EnsureConfigFolder()
        writefile(CONFIG_FILE, HttpService:JSONEncode(data))
    end)
end

local function SaveConfig()
    if IsResettingConfig then return end
    if typeof(writefile) ~= "function" then return end
    pcall(function()
        EnsureConfigFolder()
        local data = {}
        for idx, opt in pairs(Options) do
            if opt and opt.Value ~= nil then
                data[idx] = DeepCopy(opt.Value)
            end
        end
        WriteConfig(data)
    end)
end

local function QueueSaveConfig()
    if IsResettingConfig or savePending then return end

    savePending = true
    saveGeneration = saveGeneration + 1
    local generation = saveGeneration

    task.delay(0.75, function()
        if generation ~= saveGeneration then
            return
        end

        savePending = false

        if not IsResettingConfig then
            SaveConfig()
        end
    end)
end

local function LoadConfig()
    if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then return end
    if not isfile(CONFIG_FILE) then return end
    local ok, content = pcall(readfile, CONFIG_FILE)
    if not ok or type(content) ~= "string" or content == "" then return end
    local ok2, data = pcall(function()
        return HttpService:JSONDecode(content)
    end)
    if not ok2 or type(data) ~= "table" then return end
    for idx, value in pairs(data) do
        local opt = Options[idx]
        if opt and type(opt.SetValue) == "function" then
            pcall(function()
                opt:SetValue(value)
            end)
        end
    end
end

local function CaptureDefaults()
    for idx, opt in pairs(Options) do
        if opt and opt.Value ~= nil then
            DefaultConfig[idx] = DeepCopy(opt.Value)
        end
    end
end

local function ValuesEqual(a, b)
    if type(a) ~= type(b) then
        return false
    end

    if type(a) ~= "table" then
        return a == b
    end

    for k, v in pairs(a) do
        if not ValuesEqual(v, b[k]) then
            return false
        end
    end

    for k in pairs(b) do
        if a[k] == nil then
            return false
        end
    end

    return true
end

local function ResetAllToDefault()
    if IsResettingConfig then
        return
    end

    IsResettingConfig = true
    saveGeneration = saveGeneration + 1
    savePending = false

    task.spawn(function()
        local changed = 0

        for idx, defaultValue in pairs(DefaultConfig) do
            local opt = Options[idx]

            if opt
                and opt.Value ~= nil
                and type(opt.SetValue) == "function"
                and not ValuesEqual(opt.Value, defaultValue) then

                pcall(function()
                    opt:SetValue(DeepCopy(defaultValue))
                end)

                changed = changed + 1

                -- Nhường frame định kỳ để tránh dồn toàn bộ callback vào một frame.
                if changed % 6 == 0 then
                    task.wait()
                end
            end
        end

        -- Ghi đúng DefaultConfig một lần duy nhất.
        WriteConfig(DeepCopy(DefaultConfig))

        IsResettingConfig = false

        Fluent:Notify({
            Title = "Min Gaming",
            Content = "Đã khôi phục thiết lập mặc định!",
            Duration = 3
        })
    end)
end

local function WrapOptionsForAutoSave()
    for idx, opt in pairs(Options) do
        if opt and type(opt.SetValue) == "function" and not opt.__MinGamingWrapped then
            local originalSetValue = opt.SetValue
            opt.SetValue = function(self, value, ...)
                originalSetValue(self, value, ...)
                if not IsResettingConfig then
                    QueueSaveConfig()
                end
            end
            opt.__MinGamingWrapped = true
        end
    end
end
-------------------------------------------------
-- END PERSISTENT CONFIG SYSTEM
-------------------------------------------------

-- Danh sách PlaceId hợp lệ (Sea 1, 2, 3)
local MAP_SEAS = {
    [85211729168715] = 1,
    [79091703265657] = 2,
    [100117331123089] = 3
}

-- Xác định Sea
local currentSea = MAP_SEAS[PlaceId]

if not currentSea then
    plr:Kick("[Min Gaming] PlaceId không hợp lệ! Vui lòng vào đúng Blox Fruits (Sea 1, 2, 3).")
    return
end

-- Biến local dùng cho toàn bộ logic ở các dòng bên dưới
local Sea1 = (currentSea == 1)
local Sea2 = (currentSea == 2)
local Sea3 = (currentSea == 3)

-------------------------------------------------
-- Biến toàn cục mặc định (tránh nil khi mới load)
-------------------------------------------------
ChooseWeapon = "Melee"
SelectWeapon = nil
SelectBoss = ""
SelectMaterial = ""
SelectChip = "Flame"
_G.Fast_Delay = 0.3
_G.AutoLevel = false
Pos = CFrame.new(0, 30, 0)

----------------------------------------------------------------
-- 8. DATA TABLES - QUEST (Quái thường theo level & sea)
----------------------------------------------------------------
local QuestData = {
    Sea1 = {
        {Min = 1,   Max = 9,   Mon = "Bandit",            Quest = "BanditQuest1",   QLv = 1, QCF = CFrame.new(1060.9383544922, 16.455066680908, 1547.7841796875), MonCF = CFrame.new(1038.5533447266, 41.296249389648, 1576.5098876953)},
        {Min = 10,  Max = 14,  Mon = "Monkey",            Quest = "JungleQuest",    QLv = 1, QCF = CFrame.new(-1601.6553955078, 36.85213470459, 153.38809204102), MonCF = CFrame.new(-1448.1446533203, 50.851993560791, 63.60718536377)},
        {Min = 15,  Max = 29,  Mon = "Gorilla",           Quest = "JungleQuest",    QLv = 2, QCF = CFrame.new(-1601.6553955078, 36.85213470459, 153.38809204102), MonCF = CFrame.new(-1142.6488037109, 40.462348937988, -515.39227294922)},
        {Min = 30,  Max = 39,  Mon = "Pirate",            Quest = "BuggyQuest1",    QLv = 1, QCF = CFrame.new(-1140.1761474609, 4.752049446106, 3827.4057617188), MonCF = CFrame.new(-1201.0881347656, 40.628940582275, 3857.5966796875)},
        {Min = 40,  Max = 59,  Mon = "Brute",             Quest = "BuggyQuest1",    QLv = 2, QCF = CFrame.new(-1140.1761474609, 4.752049446106, 3827.4057617188), MonCF = CFrame.new(-1387.5324707031, 24.592035293579, 4100.9575195313)},
        {Min = 60,  Max = 74,  Mon = "Desert Bandit",     Quest = "DesertQuest",    QLv = 1, QCF = CFrame.new(896.51721191406, 6.4384617805481, 4390.1494140625), MonCF = CFrame.new(984.99896240234, 16.109552383423, 4417.91015625)},
        {Min = 75,  Max = 89,  Mon = "Desert Officer",    Quest = "DesertQuest",    QLv = 2, QCF = CFrame.new(896.51721191406, 6.4384617805481, 4390.1494140625), MonCF = CFrame.new(1547.1510009766, 14.452038764954, 4381.8002929688)},
        {Min = 90,  Max = 99,  Mon = "Snow Bandit",       Quest = "SnowQuest",      QLv = 1, QCF = CFrame.new(1386.8073730469, 87.272789001465, -1298.3576660156), MonCF = CFrame.new(1356.3028564453, 105.76865386963, -1328.2418212891)},
        {Min = 100, Max = 119, Mon = "Snowman",           Quest = "SnowQuest",      QLv = 2, QCF = CFrame.new(1386.8073730469, 87.272789001465, -1298.3576660156), MonCF = CFrame.new(1218.7956542969, 138.01184082031, -1488.0262451172)},
        {Min = 120, Max = 149, Mon = "Chief Petty Officer", Quest = "MarineQuest2", QLv = 1, QCF = CFrame.new(-5035.49609375, 28.677835464478, 4324.1840820313), MonCF = CFrame.new(-4931.1552734375, 65.793113708496, 4121.8393554688)},
        {Min = 150, Max = 174, Mon = "Sky Bandit",        Quest = "SkyQuest",       QLv = 1, QCF = CFrame.new(-4842.1372070313, 717.69543457031, -2623.0483398438), MonCF = CFrame.new(-4955.6411132813, 365.46365356445, -2908.1865234375)},
        {Min = 175, Max = 189, Mon = "Dark Master",       Quest = "SkyQuest",       QLv = 2, QCF = CFrame.new(-4842.1372070313, 717.69543457031, -2623.0483398438), MonCF = CFrame.new(-5148.1650390625, 439.04571533203, -2332.9611816406)},
        {Min = 190, Max = 209, Mon = "Prisoner",          Quest = "PrisonerQuest",  QLv = 1, QCF = CFrame.new(5310.60547, 0.350014925, 474.946594, 0.0175017118, 0, 0.999846935, 0, 1, 0, -0.999846935, 0, 0.0175017118), MonCF = CFrame.new(4937.31885, 0.332031399, 649.574524, 0.694649816, 0, -0.719348073, 0, 1, 0, 0.719348073, 0, 0.694649816)},
        {Min = 210, Max = 249, Mon = "Dangerous Prisoner", Quest = "PrisonerQuest", QLv = 2, QCF = CFrame.new(5310.60547, 0.350014925, 474.946594, 0.0175017118, 0, 0.999846935, 0, 1, 0, -0.999846935, 0, 0.0175017118), MonCF = CFrame.new(5099.6626, 0.351562679, 1055.7583, 0.898906827, 0, -0.438139856, 0, 1, 0, 0.438139856, 0, 0.898906827)},
        {Min = 250, Max = 274, Mon = "Toga Warrior",      Quest = "ColosseumQuest", QLv = 1, QCF = CFrame.new(-1577.7890625, 7.4151420593262, -2984.4838867188), MonCF = CFrame.new(-1872.5166015625, 49.080215454102, -2913.810546875)},
        {Min = 275, Max = 299, Mon = "Gladiator",         Quest = "ColosseumQuest", QLv = 2, QCF = CFrame.new(-1577.7890625, 7.4151420593262, -2984.4838867188), MonCF = CFrame.new(-1521.3740234375, 81.203170776367, -3066.3139648438)},
        {Min = 300, Max = 324, Mon = "Military Soldier",  Quest = "MagmaQuest",     QLv = 1, QCF = CFrame.new(-5316.1157226563, 12.262831687927, 8517.00390625), MonCF = CFrame.new(-5369.0004882813, 61.24352645874, 8556.4921875)},
        {Min = 325, Max = 374, Mon = "Military Spy",      Quest = "MagmaQuest",     QLv = 2, QCF = CFrame.new(-5316.1157226563, 12.262831687927, 8517.00390625), MonCF = CFrame.new(-5787.00293, 75.8262634, 8651.69922, 0.838590562, 0, -0.544762194, 0, 1, 0, 0.544762194, 0, 0.838590562)},
        {Min = 375, Max = 399, Mon = "Fishman Warrior",   Quest = "FishmanQuest",   QLv = 1, QCF = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734), MonCF = CFrame.new(60844.10546875, 98.462875366211, 1298.3985595703), Entrance = Vector3.new(61163.8515625, 11.6796875, 1819.7841796875)},
        {Min = 400, Max = 449, Mon = "Fishman Commando",  Quest = "FishmanQuest",   QLv = 2, QCF = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734), MonCF = CFrame.new(61738.3984375, 64.207321166992, 1433.8375244141), Entrance = Vector3.new(61163.8515625, 11.6796875, 1819.7841796875)},
        {Min = 450, Max = 474, Mon = "God's Guard",       Quest = "SkyExp1Quest",   QLv = 1, QCF = CFrame.new(-4721.8603515625, 845.30297851563, -1953.8489990234), MonCF = CFrame.new(-4628.0498046875, 866.92877197266, -1931.2352294922), Entrance = Vector3.new(-4607.82275, 872.54248, -1667.55688)},
        {Min = 475, Max = 524, Mon = "Shanda",            Quest = "SkyExp1Quest",   QLv = 2, QCF = CFrame.new(-7863.1596679688, 5545.5190429688, -378.42266845703), MonCF = CFrame.new(-7685.1474609375, 5601.0751953125, -441.38876342773), Entrance = Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047)},
        {Min = 525, Max = 549, Mon = "Royal Squad",       Quest = "SkyExp2Quest",   QLv = 1, QCF = CFrame.new(-7903.3828125, 5635.9897460938, -1410.923828125), MonCF = CFrame.new(-7654.2514648438, 5637.1079101563, -1407.7550048828),Entrance = Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047)},
        {Min = 550, Max = 624, Mon = "Royal Soldier",     Quest = "SkyExp2Quest",   QLv = 2, QCF = CFrame.new(-7903.3828125, 5635.9897460938, -1410.923828125), MonCF = CFrame.new(-7760.4106445313, 5679.9077148438, -1884.8112792969),Entrance = Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047)},
        {Min = 625, Max = 649, Mon = "Galley Pirate",     Quest = "FountainQuest",  QLv = 1, QCF = CFrame.new(5258.2788085938, 38.526931762695, 4050.044921875), MonCF = CFrame.new(5557.1684570313, 152.32717895508, 3998.7758789063)},
        {Min = 650, Max = 9999, Mon = "Galley Captain",   Quest = "FountainQuest",  QLv = 2, QCF = CFrame.new(5258.2788085938, 38.526931762695, 4050.044921875), MonCF = CFrame.new(5677.6772460938, 92.786109924316, 4966.6323242188)},
    },

    Sea2 = {
        {Min = 700,  Max = 724,  Mon = "Raider",            Quest = "Area1Quest",       QLv = 1, QCF = CFrame.new(-427.72567749023, 72.99634552002, 1835.9426269531), MonCF = CFrame.new(68.874565124512, 93.635643005371, 2429.6752929688)},
        {Min = 725,  Max = 774,  Mon = "Mercenary",         Quest = "Area1Quest",       QLv = 2, QCF = CFrame.new(-427.72567749023, 72.99634552002, 1835.9426269531), MonCF = CFrame.new(-864.85009765625, 122.47104644775, 1453.1505126953)},
        {Min = 775,  Max = 799,  Mon = "Swan Pirate",       Quest = "Area2Quest",       QLv = 1, QCF = CFrame.new(635.61151123047, 73.096351623535, 917.81298828125), MonCF = CFrame.new(1065.3669433594, 137.64012145996, 1324.3798828125)},
        {Min = 800,  Max = 874,  Mon = "Factory Staff",     Quest = "Area2Quest",       QLv = 2, QCF = CFrame.new(635.61151123047, 73.096351623535, 917.81298828125), MonCF = CFrame.new(533.22045898438, 128.46876525879, 355.62615966797)},
        {Min = 875,  Max = 899,  Mon = "Marine Lieutenant", Quest = "MarineQuest3",     QLv = 1, QCF = CFrame.new(-2440.9934082031, 73.04190826416, -3217.7082519531), MonCF = CFrame.new(-2489.2622070313, 84.613594055176, -3151.8830566406)},
        {Min = 900,  Max = 949,  Mon = "Marine Captain",    Quest = "MarineQuest3",     QLv = 2, QCF = CFrame.new(-2440.9934082031, 73.04190826416, -3217.7082519531), MonCF = CFrame.new(-2335.2026367188, 79.786659240723, -3245.8674316406)},
        {Min = 950,  Max = 974,  Mon = "Zombie",            Quest = "ZombieQuest",      QLv = 1, QCF = CFrame.new(-5494.3413085938, 48.505931854248, -794.59094238281), MonCF = CFrame.new(-5536.4970703125, 101.08577728271, -835.59075927734)},
        {Min = 975,  Max = 999,  Mon = "Vampire",           Quest = "ZombieQuest",      QLv = 2, QCF = CFrame.new(-5494.3413085938, 48.505931854248, -794.59094238281), MonCF = CFrame.new(-5806.1098632813, 16.722528457642, -1164.4384765625)},
        {Min = 1000, Max = 1049, Mon = "Snow Trooper",      Quest = "SnowMountainQuest", QLv = 1, QCF = CFrame.new(607.05963134766, 401.44781494141, -5370.5546875), MonCF = CFrame.new(535.21051025391, 432.74209594727, -5484.9165039063)},
        {Min = 1050, Max = 1099, Mon = "Winter Warrior",    Quest = "SnowMountainQuest", QLv = 2, QCF = CFrame.new(607.05963134766, 401.44781494141, -5370.5546875), MonCF = CFrame.new(1234.4449462891, 456.95419311523, -5174.130859375)},
        {Min = 1100, Max = 1124, Mon = "Lab Subordinate",   Quest = "IceSideQuest",     QLv = 1, QCF = CFrame.new(-6061.841796875, 15.926671981812, -4902.0385742188), MonCF = CFrame.new(-5720.5576171875, 63.309471130371, -4784.6103515625)},
        {Min = 1125, Max = 1174, Mon = "Horned Warrior",    Quest = "IceSideQuest",     QLv = 2, QCF = CFrame.new(-6061.841796875, 15.926671981812, -4902.0385742188), MonCF = CFrame.new(-6292.751953125, 91.181983947754, -5502.6499023438)},
        {Min = 1175, Max = 1199, Mon = "Magma Ninja",       Quest = "FireSideQuest",    QLv = 1, QCF = CFrame.new(-5429.0473632813, 15.977565765381, -5297.9614257813), MonCF = CFrame.new(-5461.8388671875, 130.36347961426, -5836.4702148438)},
        {Min = 1200, Max = 1249, Mon = "Lava Pirate",       Quest = "FireSideQuest",    QLv = 2, QCF = CFrame.new(-5429.0473632813, 15.977565765381, -5297.9614257813), MonCF = CFrame.new(-5251.1889648438, 55.164535522461, -4774.4096679688)},
        {Min = 1250, Max = 1274, Mon = "Ship Deckhand",     Quest = "ShipQuest1",       QLv = 1, QCF = CFrame.new(1040.2927246094, 125.08293151855, 32911.0390625), MonCF = CFrame.new(921.12365722656, 125.9839553833, 33088.328125), Entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)},
        {Min = 1275, Max = 1299, Mon = "Ship Engineer",     Quest = "ShipQuest1",       QLv = 2, QCF = CFrame.new(1040.2927246094, 125.08293151855, 32911.0390625), MonCF = CFrame.new(886.28179931641, 40.47790145874, 32800.83203125), Entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)},
        {Min = 1300, Max = 1324, Mon = "Ship Steward",      Quest = "ShipQuest2",       QLv = 1, QCF = CFrame.new(971.42065429688, 125.08293151855, 33245.54296875), MonCF = CFrame.new(943.85504150391, 129.58183288574, 33444.3671875), Entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)},
        {Min = 1325, Max = 1349, Mon = "Ship Officer",      Quest = "ShipQuest2",       QLv = 2, QCF = CFrame.new(971.42065429688, 125.08293151855, 33245.54296875), MonCF = CFrame.new(955.38458251953, 181.08335876465, 33331.890625), Entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)},
        {Min = 1350, Max = 1374, Mon = "Arctic Warrior",    Quest = "FrostQuest",       QLv = 1, QCF = CFrame.new(5668.1372070313, 28.202531814575, -6484.6005859375), MonCF = CFrame.new(5935.4541015625, 77.26016998291, -6472.7568359375)},
        {Min = 1375, Max = 1424, Mon = "Snow Lurker",       Quest = "FrostQuest",       QLv = 2, QCF = CFrame.new(5668.1372070313, 28.202531814575, -6484.6005859375), MonCF = CFrame.new(5628.482421875, 57.574996948242, -6618.3481445313)},
        {Min = 1425, Max = 1449, Mon = "Sea Soldier",       Quest = "ForgottenQuest",   QLv = 1, QCF = CFrame.new(-3054.5827636719, 236.87213134766, -10147.790039063), MonCF = CFrame.new(-3185.0153808594, 58.789089202881, -9663.6064453125)},
        {Min = 1450, Max = 9999, Mon = "Water Fighter",     Quest = "ForgottenQuest",   QLv = 2, QCF = CFrame.new(-3054.5827636719, 236.87213134766, -10147.790039063), MonCF = CFrame.new(-3262.9301757813, 298.69036865234, -10552.529296875)},
    },

    Sea3 = {
        {Min = 1500, Max = 1524, Mon = "Pirate Millionaire",   Quest = "PiratePortQuest",    QLv = 1, QCF = CFrame.new(-450.1046447753906, 107.68145751953125, 5950.72607421875), MonCF = CFrame.new(-193.99227905273438, 56.12502670288086, 5755.7880859375)},
        {Min = 1525, Max = 1574, Mon = "Pistol Billionaire",   Quest = "PiratePortQuest",    QLv = 2, QCF = CFrame.new(-450.1046447753906, 107.68145751953125, 5950.72607421875), MonCF = CFrame.new(-188.14462280273438, 84.49613189697266, 6337.0419921875)},
        {Min = 1575, Max = 1599, Mon = "Dragon Crew Warrior",  Quest = "DragonCrewQuest",    QLv = 1, QCF = CFrame.new(6735.11083984375, 126.99046325683594, -711.0979614257812), MonCF = CFrame.new(6615.2333984375, 50.847679138183594, -978.93408203125)},
        {Min = 1600, Max = 1624, Mon = "Dragon Crew Archer",   Quest = "DragonCrewQuest",    QLv = 2, QCF = CFrame.new(6735.11083984375, 126.99046325683594, -711.0979614257812), MonCF = CFrame.new(6818.58935546875, 483.718994140625, 512.726806640625)},
        {Min = 1625, Max = 1649, Mon = "Hydra Enforcer",       Quest = "VenomCrewQuest",     QLv = 1, QCF = CFrame.new(5446.8793945313, 601.62945556641, 749.45672607422), MonCF = CFrame.new(4547.115234375, 1001.60205078125, 334.1954650878906)},
        {Min = 1650, Max = 1699, Mon = "Venomous Assailant",   Quest = "VenomCrewQuest",     QLv = 2, QCF = CFrame.new(5446.8793945313, 601.62945556641, 749.45672607422), MonCF = CFrame.new(4637.88525390625, 1077.85595703125, 882.4183959960938)},
        {Min = 1700, Max = 1724, Mon = "Marine Commodore",     Quest = "MarineTreeIsland",   QLv = 1, QCF = CFrame.new(2179.98828125, 28.731239318848, -6740.0551757813), MonCF = CFrame.new(2198.0063476563, 128.71075439453, -7109.5043945313)},
        {Min = 1725, Max = 1774, Mon = "Marine Rear Admiral",  Quest = "MarineTreeIsland",   QLv = 2, QCF = CFrame.new(2179.98828125, 28.731239318848, -6740.0551757813), MonCF = CFrame.new(3294.3142089844, 385.41125488281, -7048.6342773438)},
        {Min = 1775, Max = 1799, Mon = "Fishman Raider",       Quest = "DeepForestIsland3",  QLv = 1, QCF = CFrame.new(-10582.759765625, 331.78845214844, -8757.666015625), MonCF = CFrame.new(-10553.268554688, 521.38439941406, -8176.9458007813)},
        {Min = 1800, Max = 1824, Mon = "Fishman Captain",      Quest = "DeepForestIsland3",  QLv = 2, QCF = CFrame.new(-10583.099609375, 331.78845214844, -8759.4638671875), MonCF = CFrame.new(-10789.401367188, 427.18637084961, -9131.4423828125)},
        {Min = 1825, Max = 1849, Mon = "Forest Pirate",        Quest = "DeepForestIsland",   QLv = 1, QCF = CFrame.new(-13232.662109375, 332.40396118164, -7626.4819335938), MonCF = CFrame.new(-13489.397460938, 400.30349731445, -7770.251953125)},
        {Min = 1850, Max = 1899, Mon = "Mythological Pirate",  Quest = "DeepForestIsland",   QLv = 2, QCF = CFrame.new(-13232.662109375, 332.40396118164, -7626.4819335938), MonCF = CFrame.new(-13508.616210938, 582.46228027344, -6985.3037109375)},
        {Min = 1900, Max = 1924, Mon = "Jungle Pirate",        Quest = "DeepForestIsland2",  QLv = 1, QCF = CFrame.new(-12682.096679688, 390.88653564453, -9902.1240234375), MonCF = CFrame.new(-12267.103515625, 459.75262451172, -10277.200195313)},
        {Min = 1925, Max = 1974, Mon = "Musketeer Pirate",     Quest = "DeepForestIsland2",  QLv = 2, QCF = CFrame.new(-12682.096679688, 390.88653564453, -9902.1240234375), MonCF = CFrame.new(-13291.5078125, 520.47338867188, -9904.638671875)},
        {Min = 1975, Max = 1999, Mon = "Reborn Skeleton",      Quest = "HauntedQuest1",      QLv = 1, QCF = CFrame.new(-9480.80762, 142.130661, 5566.37305, -0.00655503059, 4.5295423e-8, -0.999978542, 2.0492047e-8, 1, 4.5162068e-8, 0.999978542, -2.0195568e-8, -0.00655503059), MonCF = CFrame.new(-8761.77148, 183.431747, 6168.33301, 0.978073597, -0.000013950732, -0.208259016, -0.0000010807393, 1, -0.00007206303, 0.208259016, 0.00007070804, 0.978073597)},
        {Min = 2000, Max = 2024, Mon = "Living Zombie",        Quest = "HauntedQuest1",      QLv = 2, QCF = CFrame.new(-9480.80762, 142.130661, 5566.37305, -0.00655503059, 4.5295423e-8, -0.999978542, 2.0492047e-8, 1, 4.5162068e-8, 0.999978542, -2.0195568e-8, -0.00655503059), MonCF = CFrame.new(-10103.7529, 238.565979, 6179.75977, 0.999474227, 2.7754714e-8, 0.0324240364, -2.5800633e-8, 1, -6.068485e-8, -0.0324240364, 5.981639e-8, 0.999474227)},
        {Min = 2025, Max = 2049, Mon = "Demonic Soul",         Quest = "HauntedQuest2",      QLv = 1, QCF = CFrame.new(-9516.9931640625, 178.00651550293, 6078.4653320313), MonCF = CFrame.new(-9712.03125, 204.69589233398, 6193.322265625)},
        {Min = 2050, Max = 2074, Mon = "Posessed Mummy",       Quest = "HauntedQuest2",      QLv = 2, QCF = CFrame.new(-9516.9931640625, 178.00651550293, 6078.4653320313), MonCF = CFrame.new(-9545.7763671875, 69.619895935059, 6339.5615234375)},
        {Min = 2075, Max = 2099, Mon = "Peanut Scout",         Quest = "NutsIslandQuest",    QLv = 1, QCF = CFrame.new(-2105.53198, 37.2495995, -10195.5088, -0.766061664, 0, -0.642767608, 0, 1, 0, 0.642767608, 0, -0.766061664), MonCF = CFrame.new(-2150.587890625, 122.49767303467, -10358.994140625)},
        {Min = 2100, Max = 2124, Mon = "Peanut President",     Quest = "NutsIslandQuest",    QLv = 2, QCF = CFrame.new(-2105.53198, 37.2495995, -10195.5088, -0.766061664, 0, -0.642767608, 0, 1, 0, 0.642767608, 0, -0.766061664), MonCF = CFrame.new(-2150.587890625, 122.49767303467, -10358.994140625)},
        {Min = 2125, Max = 2149, Mon = "Ice Cream Chef",       Quest = "IceCreamIslandQuest", QLv = 1, QCF = CFrame.new(-819.376709, 64.9259796, -10967.2832, -0.766061664, 0, 0.642767608, 0, 1, 0, -0.642767608, 0, -0.766061664), MonCF = CFrame.new(-789.941528, 209.382889, -11009.9805, -0.0703101531, 0, -0.997525156, 0, 1, 0, 0.997525275, 0, -0.0703101456)},
        {Min = 2150, Max = 2199, Mon = "Ice Cream Commander",  Quest = "IceCreamIslandQuest", QLv = 2, QCF = CFrame.new(-819.376709, 64.9259796, -10967.2832, -0.766061664, 0, 0.642767608, 0, 1, 0, -0.642767608, 0, -0.766061664), MonCF = CFrame.new(-789.941528, 209.382889, -11009.9805, -0.0703101531, 0, -0.997525156, 0, 1, 0, 0.997525275, 0, -0.0703101456)},
        {Min = 2200, Max = 2224, Mon = "Cookie Crafter",       Quest = "CakeQuest1",         QLv = 1, QCF = CFrame.new(-2022.29858, 36.9275894, -12030.9766, -0.961273909, 0, -0.275594592, 0, 1, 0, 0.275594592, 0, -0.961273909), MonCF = CFrame.new(-2321.71216, 36.699482, -12216.7871, -0.780074954, 0, 0.625686109, 0, 1, 0, -0.625686109, 0, -0.780074954)},
        {Min = 2225, Max = 2249, Mon = "Cake Guard",           Quest = "CakeQuest1",         QLv = 2, QCF = CFrame.new(-2022.29858, 36.9275894, -12030.9766, -0.961273909, 0, -0.275594592, 0, 1, 0, 0.275594592, 0, -0.961273909), MonCF = CFrame.new(-1418.11011, 36.6718941, -12255.7324, 0.0677844882, 0, 0.997700036, 0, 1, 0, -0.997700036, 0, 0.0677844882)},
        {Min = 2250, Max = 2274, Mon = "Baking Staff",         Quest = "CakeQuest2",         QLv = 1, QCF = CFrame.new(-1928.31763, 37.7296638, -12840.626, 0.951068401, 0, -0.308980465, 0, 1, 0, 0.308980465, 0, 0.951068401), MonCF = CFrame.new(-1980.43848, 36.6716766, -12983.8418, -0.254443765, 0, -0.967087567, 0, 1, 0, 0.967087567, 0, -0.254443765)},
        {Min = 2275, Max = 2299, Mon = "Head Baker",           Quest = "CakeQuest2",         QLv = 2, QCF = CFrame.new(-1928.31763, 37.7296638, -12840.626, 0.951068401, 0, -0.308980465, 0, 1, 0, 0.308980465, 0, 0.951068401), MonCF = CFrame.new(-2251.5791, 52.2714615, -13033.3965, -0.991971016, 0, -0.126466095, 0, 1, 0, 0.126466095, 0, -0.991971016)},
        {Min = 2300, Max = 2324, Mon = "Cocoa Warrior",        Quest = "ChocQuest1",         QLv = 1, QCF = CFrame.new(231.75, 23.9003029, -12200.292, -1, 0, 0, 0, 1, 0, 0, 0, -1), MonCF = CFrame.new(167.978516, 26.2254658, -12238.874, -0.939700961, 0, 0.341998369, 0, 1, 0, -0.341998369, 0, -0.939700961)},
        {Min = 2325, Max = 2349, Mon = "Chocolate Bar Battler", Quest = "ChocQuest1",        QLv = 2, QCF = CFrame.new(231.75, 23.9003029, -12200.292, -1, 0, 0, 0, 1, 0, 0, 0, -1), MonCF = CFrame.new(701.312073, 25.5824986, -12708.2148, -0.342042685, 0, -0.939684391, 0, 1, 0, 0.939684391, 0, -0.342042685)},
        {Min = 2350, Max = 2374, Mon = "Sweet Thief",          Quest = "ChocQuest2",         QLv = 1, QCF = CFrame.new(151.198242, 23.8907146, -12774.6172, 0.422592998, 0, 0.906319618, 0, 1, 0, -0.906319618, 0, 0.422592998), MonCF = CFrame.new(-140.258301, 25.5824986, -12652.3115, 0.173624337, 0, -0.984811902, 0, 1, 0, 0.984811902, 0, 0.173624337)},
        {Min = 2375, Max = 2399, Mon = "Candy Rebel",          Quest = "ChocQuest2",         QLv = 2, QCF = CFrame.new(151.198242, 23.8907146, -12774.6172, 0.422592998, 0, 0.906319618, 0, 1, 0, -0.906319618, 0, 0.422592998), MonCF = CFrame.new(47.9231453, 25.5824986, -13029.2402, -0.819156051, 0, -0.573571265, 0, 1, 0, 0.573571265, 0, -0.819156051)},
        {Min = 2400, Max = 2424, Mon = "Candy Pirate",         Quest = "CandyQuest1",        QLv = 1, QCF = CFrame.new(-1149.328, 13.5759039, -14445.6143, -0.156446099, 0, -0.987686574, 0, 1, 0, 0.987686574, 0, -0.156446099), MonCF = CFrame.new(-1437.56348, 17.1481285, -14385.6934, 0.173624337, 0, -0.984811902, 0, 1, 0, 0.984811902, 0, 0.173624337)},
        {Min = 2425, Max = 2449, Mon = "Snow Demon",           Quest = "CandyQuest1",        QLv = 2, QCF = CFrame.new(-1149.328, 13.5759039, -14445.6143, -0.156446099, 0, -0.987686574, 0, 1, 0, 0.987686574, 0, -0.156446099), MonCF = CFrame.new(-916.222656, 17.1481285, -14638.8125, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)},
        {Min = 2450, Max = 2474, Mon = "Isle Outlaw",          Quest = "TikiQuest1",         QLv = 1, QCF = CFrame.new(-16549.890625, 55.68635559082031, -179.91360473632812), MonCF = CFrame.new(-16162.8193359375, 11.6863374710083, -96.45481872558594)},
        {Min = 2475, Max = 2499, Mon = "Island Boy",           Quest = "TikiQuest1",         QLv = 2, QCF = CFrame.new(-16549.890625, 55.68635559082031, -179.91360473632812), MonCF = CFrame.new(-16357.3125, 20.632822036743164, 1005.64892578125)},
        {Min = 2500, Max = 2524, Mon = "Sun-kissed Warrior",   Quest = "TikiQuest2",         QLv = 1, QCF = CFrame.new(-16541.021484375, 54.77081298828125, 1051.461181640625), MonCF = CFrame.new(-16357.3125, 20.632822036743164, 1005.64892578125)},
        {Min = 2525, Max = 2549, Mon = "Isle Champion",        Quest = "TikiQuest2",         QLv = 2, QCF = CFrame.new(-16541.021484375, 54.77081298828125, 1051.461181640625), MonCF = CFrame.new(-16848.94140625, 21.68633460998535, 1041.4490966796875)},
        {Min = 2550, Max = 2574, Mon = "Serpent Hunter",       Quest = "TikiQuest3",         QLv = 1, QCF = CFrame.new(-16665.19140625, 104.59640502929688, 1579.6943359375), MonCF = CFrame.new(-16621.4140625, 121.40631103515625, 1290.6881103515625)},
        {Min = 2575, Max = 9999, Mon = "Skull Slayer",         Quest = "TikiQuest3",         QLv = 2, QCF = CFrame.new(-16665.19140625, 104.59640502929688, 1579.6943359375), MonCF = CFrame.new(-16811.5703125, 84.625244140625, 1542.235107421875)},
    }
}

----------------------------------------------------------------
-- 9. HÀM CHECK LEVEL (Tự động chọn quái theo level hiện tại)
----------------------------------------------------------------
function CheckLevel()
    local myLevel = plr.Data.Level.Value
    local currentSea = Sea1 and "Sea1" or Sea2 and "Sea2" or Sea3 and "Sea3"

    if not currentSea or not QuestData[currentSea] then
        return
    end
    for _, data in ipairs(QuestData[currentSea]) do
        if myLevel >= data.Min and myLevel <= data.Max then

            NameMon   = data.Mon
            NameQuest = data.Quest
            QuestLv   = data.QLv
            CFrameQ   = data.QCF
            CFrameMon = data.MonCF
            
            -- BYPASS ENTRANCE
            if _G.AutoLevel and data.Entrance then
                local character = plr.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local distance = (CFrameMon.Position - rootPart.Position).Magnitude
                    -- Tất cả Sea đều dùng ngưỡng 3000
                    if distance > 3000 then
                        pcall(function()
                            GameTeleport(data.Entrance)
                        end)
                    end
                end
            end

            break
        end
    end
end

----------------------------------------------------------------
-- 10. DATA TABLES - BOSS
----------------------------------------------------------------
local BossData = {
    -- ========== Sea 1 ==========
    ["The Gorilla King"] = {
        NameQuestBoss = "JungleQuest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$2,000\n7,000 Exp.",
        CFrameQBoss = CFrame.new(-1601.6553955078, 36.85213470459, 153.38809204102),
        CFrameBoss = CFrame.new(-1088.75977, 8.13463783, -488.559906, -0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, -0.707134247)
    },
    ["Bobby"] = {
        NameQuestBoss = "BuggyQuest1",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$8,000\n35,000 Exp.",
        CFrameQBoss = CFrame.new(-1140.1761474609, 4.752049446106, 3827.4057617188),
        CFrameBoss = CFrame.new(-1087.3760986328, 46.949409484863, 4040.1462402344)
    },
    ["The Saw"] = {
        CFrameBoss = CFrame.new(-784.89715576172, 72.427383422852, 1603.5822753906)
    },
    ["Yeti"] = {
        NameQuestBoss = "SnowQuest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$10,000\n180,000 Exp.",
        CFrameQBoss = CFrame.new(1386.8073730469, 87.272789001465, -1298.3576660156),
        CFrameBoss = CFrame.new(1218.7956542969, 138.01184082031, -1488.0262451172)
    },
    ["Mob Leader"] = {
        CFrameBoss = CFrame.new(-2844.7307128906, 7.4180502891541, 5356.6723632813)
    },
    ["Vice Admiral"] = {
        NameQuestBoss = "MarineQuest2",
        QuestLvBoss = 2,
        RewardBoss = "Reward:\n$10,000\n180,000 Exp.",
        CFrameQBoss = CFrame.new(-5036.2465820313, 28.677835464478, 4324.56640625),
        CFrameBoss = CFrame.new(-5006.5454101563, 88.032081604004, 4353.162109375)
    },
    ["Saber Expert"] = {
        CFrameBoss = CFrame.new(-1458.89502, 29.8870335, -50.633564)
    },
    ["Warden"] = {
        NameQuestBoss = "ImpelQuest",
        QuestLvBoss = 1,
        RewardBoss = "Reward:\n$6,000\n850,000 Exp.",
        CFrameQBoss = CFrame.new(5191.86133, 2.84020686, 686.438721, -0.731384635, 0, 0.681965172, 0, 1, 0, -0.681965172, 0, -0.731384635),
        CFrameBoss = CFrame.new(5278.04932, 2.15167475, 944.101929, 0.220546961, -0.000004499464, 0.975376427, -0.000019541258, 1, 0.000009031621, -0.975376427, -0.000021051976, 0.220546961)
    },
    ["Chief Warden"] = {
        NameQuestBoss = "ImpelQuest",
        QuestLvBoss = 2,
        RewardBoss = "Reward:\n$10,000\n1,000,000 Exp.",
        CFrameQBoss = CFrame.new(5191.86133, 2.84020686, 686.438721, -0.731384635, 0, 0.681965172, 0, 1, 0, -0.681965172, 0, -0.731384635),
        CFrameBoss = CFrame.new(5206.92578, 0.997753382, 814.976746, 0.342041343, -0.00062915677, 0.939684749, 0.00191645394, 0.999998152, -0.000028042234, -0.939682961, 0.00181045406, 0.342041939)
    },
    ["Swan"] = {
        NameQuestBoss = "ImpelQuest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$15,000\n1,600,000 Exp.",
        CFrameQBoss = CFrame.new(5191.86133, 2.84020686, 686.438721, -0.731384635, 0, 0.681965172, 0, 1, 0, -0.681965172, 0, -0.731384635),
        CFrameBoss = CFrame.new(5325.09619, 7.03906584, 719.570679, -0.309060812, 0, 0.951042235, 0, 1, 0, -0.951042235, 0, -0.309060812)
    },
    ["Magma Admiral"] = {
        NameQuestBoss = "MagmaQuest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$15,000\n2,800,000 Exp.",
        CFrameQBoss = CFrame.new(-5314.6220703125, 12.262420654297, 8517.279296875),
        CFrameBoss = CFrame.new(-5765.8969726563, 82.92064666748, 8718.3046875)
    },
    ["Fishman Lord"] = {
        NameQuestBoss = "FishmanQuest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$15,000\n4,000,000 Exp.",
        CFrameQBoss = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734),
        CFrameBoss = CFrame.new(61260.15234375, 30.950881958008, 1193.4329833984)
    },
    ["Wysper"] = {
        NameQuestBoss = "SkyExp1Quest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$15,000\n4,800,000 Exp.",
        CFrameQBoss = CFrame.new(-7861.947265625, 5545.517578125, -379.85974121094),
        CFrameBoss = CFrame.new(-7866.1333007813, 5576.4311523438, -546.74816894531)
    },
    ["Thunder God"] = {
        NameQuestBoss = "SkyExp2Quest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$20,000\n5,800,000 Exp.",
        CFrameQBoss = CFrame.new(-7903.3828125, 5635.9897460938, -1410.923828125),
        CFrameBoss = CFrame.new(-7994.984375, 5761.025390625, -2088.6479492188)
    },
    ["Cyborg"] = {
        NameQuestBoss = "FountainQuest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$20,000\n7,500,000 Exp.",
        CFrameQBoss = CFrame.new(5258.2788085938, 38.526931762695, 4050.044921875),
        CFrameBoss = CFrame.new(6094.0249023438, 73.770050048828, 3825.7348632813)
    },
    ["Ice Admiral"] = {
        CFrameBoss = CFrame.new(1266.08948, 26.1757946, -1399.57678, -0.573599219, 0, -0.81913656, 0, 1, 0, 0.81913656, 0, -0.573599219)
    },
    ["Greybeard"] = {
        CFrameBoss = CFrame.new(-5081.3452148438, 85.221641540527, 4257.3588867188)
    },

    -- ========== Sea 2 ==========
    ["Diamond"] = {
        NameQuestBoss = "Area1Quest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$25,000\n9,000,000 Exp.",
        CFrameQBoss = CFrame.new(-427.5666809082, 73.313781738281, 1835.4208984375),
        CFrameBoss = CFrame.new(-1576.7166748047, 198.59265136719, 13.724286079407)
    },
    ["Jeremy"] = {
        NameQuestBoss = "Area2Quest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$25,000\n11,500,000 Exp.",
        CFrameQBoss = CFrame.new(636.79943847656, 73.413787841797, 918.00415039063),
        CFrameBoss = CFrame.new(2006.9261474609, 448.95666503906, 853.98284912109)
    },
    ["Fajita"] = {
        NameQuestBoss = "MarineQuest3",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$25,000\n15,000,000 Exp.",
        CFrameQBoss = CFrame.new(-2441.986328125, 73.359344482422, -3217.5324707031),
        CFrameBoss = CFrame.new(-2172.7399902344, 103.32216644287, -4015.025390625)
    },
    ["Don Swan"] = {
        CFrameBoss = CFrame.new(2286.2004394531, 15.177839279175, 863.8388671875)
    },
    ["Smoke Admiral"] = {
        NameQuestBoss = "IceSideQuest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$20,000\n25,000,000 Exp.",
        CFrameQBoss = CFrame.new(-5429.0473632813, 15.977565765381, -5297.9614257813),
        CFrameBoss = CFrame.new(-5275.1987304688, 20.757257461548, -5260.6669921875)
    },
    ["Awakened Ice Admiral"] = {
        NameQuestBoss = "FrostQuest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$20,000\n36,000,000 Exp.",
        CFrameQBoss = CFrame.new(5668.9780273438, 28.519989013672, -6483.3520507813),
        CFrameBoss = CFrame.new(6403.5439453125, 340.29766845703, -6894.5595703125)
    },
    ["Tide Keeper"] = {
        NameQuestBoss = "ForgottenQuest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$12,500\n38,000,000 Exp.",
        CFrameQBoss = CFrame.new(-3053.9814453125, 237.18954467773, -10145.0390625),
        CFrameBoss = CFrame.new(-3795.6423339844, 105.88877105713, -11421.307617188)
    },
    ["Darkbeard"] = {
        CFrameBoss = CFrame.new(3677.08203125, 62.751937866211, -3144.8332519531) -- đã sửa từ CFrameMon
    },
    ["Cursed Captain"] = {
        CFrameBoss = CFrame.new(916.928589, 181.092773, 33422)
    },
    ["Order"] = {
        CFrameBoss = CFrame.new(-6217.2021484375, 28.047645568848, -5053.1357421875)
    },

    -- ========== Sea 3 ==========
    ["Stone"] = {
        NameQuestBoss = "PiratePortQuest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$25,000\n40,000,000 Exp.",
        CFrameQBoss = CFrame.new(-289.76705932617, 43.819011688232, 5579.9384765625),
        CFrameBoss = CFrame.new(-1027.6512451172, 92.404174804688, 6578.8530273438)
    },
    ["Hydra Leader"] = {
        NameQuestBoss = "VenomCrewQuest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$30,000\n52,000,000 Exp.",
        CFrameQBoss = CFrame.new(5445.9541015625, 601.62945556641, 751.43792724609),
        CFrameBoss = CFrame.new(5543.86328125, 668.97399902344, 199.0341796875)
    },
    ["Kilo Admiral"] = {
        NameQuestBoss = "MarineTreeIsland",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$35,000\n56,000,000 Exp.",
        CFrameQBoss = CFrame.new(2179.3010253906, 28.731239318848, -6739.9741210938),
        CFrameBoss = CFrame.new(2764.2233886719, 432.46154785156, -7144.4580078125)
    },
    ["Captain Elephant"] = {
        NameQuestBoss = "DeepForestIsland",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$40,000\n67,000,000 Exp.",
        CFrameQBoss = CFrame.new(-13232.682617188, 332.40396118164, -7626.01171875),
        CFrameBoss = CFrame.new(-13376.7578125, 433.28689575195, -8071.392578125)
    },
    ["Beautiful Pirate"] = {
        NameQuestBoss = "DeepForestIsland2",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$50,000\n70,000,000 Exp.",
        CFrameQBoss = CFrame.new(-12682.096679688, 390.88653564453, -9902.1240234375),
        CFrameBoss = CFrame.new(5283.609375, 22.56223487854, -110.78285217285)
    },
    ["Cake Queen"] = {
        NameQuestBoss = "IceCreamIslandQuest",
        QuestLvBoss = 3,
        RewardBoss = "Reward:\n$30,000\n112,500,000 Exp.",
        CFrameQBoss = CFrame.new(-819.376709, 64.9259796, -10967.2832, -0.766061664, 0, 0.642767608, 0, 1, 0, -0.642767608, 0, -0.766061664),
        CFrameBoss = CFrame.new(-678.648804, 381.353943, -11114.2012, -0.908641815, 0.00149294338, 0.41757378, 0.00837114919, 0.999857843, 0.0146408929, -0.417492568, 0.0167988986, -0.90852499)
    },
    ["Longma"] = {
        CFrameBoss = CFrame.new(-10238.875976563, 389.7912902832, -9549.7939453125)
    },
    ["Soul Reaper"] = {
        CFrameBoss = CFrame.new(-9524.7890625, 315.80429077148, 6655.7192382813)
    },
    ["rip_indra True Form"] = {
        CFrameBoss = CFrame.new(-5415.3920898438, 505.74133300781, -2814.0166015625)
    }
}

function CheckBossQuest()
    -- Reset sạch để tránh dính data cũ
    BossMon = nil
    NameBoss = nil
    NameQuestBoss = nil
    QuestLvBoss = nil
    RewardBoss = nil
    CFrameQBoss = nil
    CFrameBoss = nil

    if not SelectBoss or SelectBoss == "" then return end

    local data = BossData[SelectBoss]
    if data then
        BossMon = SelectBoss
        NameBoss = SelectBoss
        NameQuestBoss = data.NameQuestBoss
        QuestLvBoss = data.QuestLvBoss
        RewardBoss = data.RewardBoss
        CFrameQBoss = data.CFrameQBoss
        CFrameBoss = data.CFrameBoss
    end
end
----------------------------------------------------------------
-- 11. DATA TABLES - MATERIAL
----------------------------------------------------------------
local MaterialData = {
    -- ========== Flat (không phụ thuộc Sea) ==========
    ["Radioactive Material"] = {
        MMon = "Factory Staff",
        MPos = CFrame.new(295, 73, -56),
        TargetSea = 2
    },
    ["Mystic Droplet"] = {
        MMon = "Water Fighter",
        MPos = CFrame.new(-3385, 239, -10542),
        TargetSea = 2
    },
    ["Angel Wings"] = {
        MMon = "God's Guard",
        MPos = CFrame.new(-4698, 845, -1912),
        Entrance = Vector3.new(-7859.09814, 5544.19043, -381.476196),
        Distance = 5000,
        TargetSea = 1
    },
    ["Demonic Wisp"] = {
        MMon = "Demonic Soul",
        MPos = CFrame.new(-9507, 172, 6158),
        TargetSea = 3
    },
    ["Vampire Fang"] = {
        MMon = "Vampire",
        MPos = CFrame.new(-6033, 7, -1317),
        TargetSea = 2
    },
    ["Conjured Cocoa"] = {
        MMon = "Chocolate Bar Battler",
        MPos = CFrame.new(620.63446, 78.93644, -12581.36914),
        TargetSea = 3
    },
    ["Dragon Scale"] = {
        MMon = "Dragon Crew Archer",
        MPos = CFrame.new(6827.91455, 609.41271, 252.3538),
        TargetSea = 3
    },
    ["Gunpowder"] = {
        MMon = "Pistol Billionaire",
        MPos = CFrame.new(-469, 74, 5904),
        TargetSea = 3
    },
    ["Mini Tusk"] = {
        MMon = "Mythological Pirate",
        MPos = CFrame.new(-13540, 332, -10440),
        TargetSea = 3
    },

    -- ========== Có chia theo Sea ==========
    ["Magma Ore"] = {
        Sea1 = { MMon = "Military Spy", MPos = CFrame.new(-5815, 84, 8820) },
        Sea2 = { MMon = "Magma Ninja", MPos = CFrame.new(-5428, 78, -5959) }
    },
    ["Leather"] = {
        Sea1 = { MMon = "Brute", MPos = CFrame.new(-1145, 15, 4350) },
        Sea2 = { MMon = "Marine Captain", MPos = CFrame.new(-2010.50598, 73.00115, -3326.62085) },
        Sea3 = { MMon = "Jungle Pirate", MPos = CFrame.new(-11975.78515, 331.7734, -10620.03027) }
    },
    ["Scrap Metal"] = {
        Sea1 = { MMon = "Brute", MPos = CFrame.new(-1145, 15, 4350) },
        Sea2 = { MMon = "Swan Pirate", MPos = CFrame.new(878, 122, 1235) },
        Sea3 = { MMon = "Jungle Pirate", MPos = CFrame.new(-12107, 332, -10549) }
    },
    ["Fish Tail"] = {
        Sea1 = {
            MMon = "Fishman Warrior",
            MPos = CFrame.new(61123, 19, 1569),
            Entrance = Vector3.new(61163.8515625, 5.342342376708984, 1819.7841796875),
            Distance = 17000
        },
        Sea3 = {
            MMon = "Fishman Raider",
            MPos = CFrame.new(-10993, 332, -8940)
        }
    }
}

-- Hàm hỗ trợ dịch chuyển Sea (Travel Sea)
local function TravelToSea(targetSeaNumber)
    local commF = ReplicatedStorage.Remotes.CommF_
    if targetSeaNumber == 1 then
        commF:InvokeServer("TravelMain")
    elseif targetSeaNumber == 2 then
        commF:InvokeServer("TravelDressrosa")
    elseif targetSeaNumber == 3 then
        commF:InvokeServer("TravelZou")
    end
end

-- Biến chống spam đổi Sea
local lastTravelTime = 0

function MaterialMon()
    -- Reset sạch
    MMon = nil
    MPos = nil

    if not SelectMaterial or SelectMaterial == "" then return end

    local matInfo = MaterialData[SelectMaterial]
    if not matInfo then return end

    -- Xác định Sea hiện tại dạng số (1, 2, 3)
    local currentSeaNum = Sea1 and 1 or Sea2 and 2 or Sea3 and 3
    local currentSeaKey = "Sea" .. tostring(currentSeaNum)

    -- Lấy dữ liệu nguyên liệu theo Sea hiện tại
    local data = matInfo[currentSeaKey] or (matInfo.MMon and matInfo)

    -- NẾU SEA HIỆN TẠI KHÔNG CÓ NGUYÊN LIỆU NÀY
    if not (data and data.MMon and data.MPos) then
        -- Tìm Sea nào có chứa nguyên liệu này
        local targetSea = nil

        if matInfo.TargetSea then
            targetSea = matInfo.TargetSea
        else
            if matInfo.Sea1 then targetSea = 1
            elseif matInfo.Sea2 then targetSea = 2
            elseif matInfo.Sea3 then targetSea = 3
            end
        end

        -- Nếu tìm thấy Sea phù hợp và khác Sea hiện tại, thực hiện chuyển Sea với bộ đếm thời gian
        if targetSea and targetSea ~= currentSeaNum then
            if tick() - lastTravelTime > 5 then -- Chống spam 5 giây (an toàn và mượt mà)
                lastTravelTime = tick()
                TravelToSea(targetSea)
            end
        end
        return
    end

    -- Nếu Sea hiện tại có nguyên liệu, tiến hành gán dữ liệu bình thường
    MMon = data.MMon
    MPos = data.MPos

    -- Xử lý Entrance an toàn
    if data.Entrance and data.Distance then
        local char = plr.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local dist = (root.Position - data.Entrance).Magnitude
            if dist >= data.Distance then
                GameTeleport(data.Entrance)
            end
        end
    end
end
------------------------------------------------------------------
-- 12. ESP HELPERS
--     Phải định nghĩa trước tất cả hàm Update*ESP
------------------------------------------------------------------
function isnil(value)
    return value == nil
end

function Round(num)
    return math.floor(tonumber(num or 0) + 0.5)
end

Number = math.random(1, 1000000)

-- Toggle mặc định (UI sẽ gán lại khi bật)
ESPPlayer = ESPPlayer or false
ChestESP = ChestESP or false
DevilFruitESP = DevilFruitESP or false
FlowerESP = FlowerESP or false
RealFruitESP = RealFruitESP or false
IslandESP = IslandESP or false
MirageIslandESP = MirageIslandESP or false
GearESP = GearESP or false
AuraESP = AuraESP or false
LADESP = LADESP or false
MobESP = MobESP or false
SeaESP = SeaESP or false
NpcESP = NpcESP or false

function UpdatePlayerChams()
    for _, player in pairs(Players:GetChildren()) do
        pcall(function()
            if not isnil(player.Character) then
                if ESPPlayer then
                    if (not isnil(player.Character.Head) and not player.Character.Head:FindFirstChild("NameEsp" .. Number)) then
                        local billboard = Instance.new("BillboardGui", player.Character.Head);
billboard.Name = "NameEsp" .. Number ;
                        billboard.ExtentsOffset = Vector3.new(0, 1, 0);
                        billboard.Size = UDim2.new(1, 200, 1, 30);
                        billboard.Adornee = player.Character.Head;
                        billboard.AlwaysOnTop = true;
                        local textLabel = Instance.new("TextLabel", billboard);
textLabel.Font = Enum.Font.GothamSemibold;
                        textLabel.FontSize = "Size10";
                        textLabel.TextWrapped = true;
                        textLabel.Text = player.Name .. " \n" .. Round((plr.Character.Head.Position - player.Character.Head.Position).Magnitude / 3) .. " Distance" ;
                        textLabel.Size = UDim2.new(1, 0, 1, 0);
                        textLabel.TextYAlignment = "Top";
                        textLabel.BackgroundTransparency = 1;
                        textLabel.TextStrokeTransparency = 0.5;
                        if (player.Team == plr.Team) then
                            textLabel.TextColor3 = Color3.new(0, 0, 254);
                        else
                            textLabel.TextColor3 = Color3.new(255, 0, 0);
                        end
                    else
                        player.Character.Head["NameEsp" .. Number ].TextLabel.Text = player.Name .. " | " .. Round((plr.Character.Head.Position - player.Character.Head.Position).Magnitude / 3) .. " Distance\nHealth : " .. Round((player.Character.Humanoid.Health * 100) / player.Character.Humanoid.MaxHealth) .. "%" ;
                    end
                elseif player.Character.Head:FindFirstChild("NameEsp" .. Number) then
                    player.Character.Head:FindFirstChild("NameEsp" .. Number):Destroy();
                end
            end
        end);
    end
end
function UpdateChestChams()
    for _, obj in pairs(Workspace:GetChildren()) do
        pcall(function()
            if string.find(obj.Name, "Chest") then
                if ChestESP then
                    if string.find(obj.Name, "Chest") then
                        if not obj:FindFirstChild("NameEsp" .. Number) then
                            local billboard = Instance.new("BillboardGui", obj);
billboard.Name = "NameEsp" .. Number ;
                            billboard.ExtentsOffset = Vector3.new(0, 1, 0);
                            billboard.Size = UDim2.new(1, 200, 1, 30);
                            billboard.Adornee = obj;
                            billboard.AlwaysOnTop = true;
                            local textLabel = Instance.new("TextLabel", billboard);
textLabel.Font = Enum.Font.GothamSemibold;
                            textLabel.FontSize = "Size14";
                            textLabel.TextWrapped = true;
                            textLabel.Size = UDim2.new(1, 0, 1, 0);
                            textLabel.TextYAlignment = "Top";
                            textLabel.BackgroundTransparency = 1;
                            textLabel.TextStrokeTransparency = 0.5;
                            if (obj.Name == "Chest1") then
                                textLabel.TextColor3 = Color3.fromRGB(109, 109, 109);
                                textLabel.Text = "Chest 1" .. " \n" .. Round((plr.Character.Head.Position - obj.Position).Magnitude / 3) .. " Distance" ;
                            end
                            if (obj.Name == "Chest2") then
                                textLabel.TextColor3 = Color3.fromRGB(173, 158, 21);
                                textLabel.Text = "Chest 2" .. " \n" .. Round((plr.Character.Head.Position - obj.Position).Magnitude / 3) .. " Distance" ;
                            end
                            if (obj.Name == "Chest3") then
                                textLabel.TextColor3 = Color3.fromRGB(85, 255, 255);
                                textLabel.Text = "Chest 3" .. " \n" .. Round((plr.Character.Head.Position - obj.Position).Magnitude / 3) .. " Distance" ;
                            end
                        else
                            obj["NameEsp" .. Number ].TextLabel.Text = obj.Name .. "   \n" .. Round((plr.Character.Head.Position - obj.Position).Magnitude / 3) .. " Distance" ;
                        end
                    end
                elseif obj:FindFirstChild("NameEsp" .. Number) then
                    obj:FindFirstChild("NameEsp" .. Number):Destroy();
                end
            end
        end);
    end
end
function UpdateDevilChams()
    for _, obj in pairs(Workspace:GetChildren()) do
        pcall(function()
            if DevilFruitESP then
                if string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") then
                    if not obj.Handle:FindFirstChild("NameEsp" .. Number) then
                        local billboard = Instance.new("BillboardGui", obj.Handle);
billboard.Name = "NameEsp" .. Number ;
                        billboard.ExtentsOffset = Vector3.new(0, 1, 0);
                        billboard.Size = UDim2.new(1, 200, 1, 30);
                        billboard.Adornee = obj.Handle;
                        billboard.AlwaysOnTop = true;
                        local textLabel = Instance.new("TextLabel", billboard);
textLabel.Font = Enum.Font.GothamSemibold;
                        textLabel.FontSize = "Size14";
                        textLabel.TextWrapped = true;
                        textLabel.Size = UDim2.new(1, 0, 1, 0);
                        textLabel.TextYAlignment = "Top";
                        textLabel.BackgroundTransparency = 1;
                        textLabel.TextStrokeTransparency = 0.5;
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
                        textLabel.Text = obj.Name .. " \n" .. Round((plr.Character.Head.Position - obj.Handle.Position).Magnitude / 3) .. " Distance" ;
                    else
                        obj.Handle["NameEsp" .. Number ].TextLabel.Text = obj.Name .. "   \n" .. Round((plr.Character.Head.Position - obj.Handle.Position).Magnitude / 3) .. " Distance" ;
                    end
                end
            elseif obj:FindFirstChild("Handle") and obj.Handle:FindFirstChild("NameEsp" .. Number) then
                obj.Handle:FindFirstChild("NameEsp" .. Number):Destroy();
            end
        end);
    end
end
function UpdateFlowerChams()
    for _, obj in pairs(Workspace:GetChildren()) do
        pcall(function()
            if ((obj.Name == "Flower2") or (obj.Name == "Flower1")) then
                if FlowerESP then
                    if not obj:FindFirstChild("NameEsp" .. Number) then
                        local billboard = Instance.new("BillboardGui", obj);
billboard.Name = "NameEsp" .. Number ;
                        billboard.ExtentsOffset = Vector3.new(0, 1, 0);
                        billboard.Size = UDim2.new(1, 200, 1, 30);
                        billboard.Adornee = obj;
                        billboard.AlwaysOnTop = true;
                        local textLabel = Instance.new("TextLabel", billboard);
textLabel.Font = Enum.Font.GothamSemibold;
                        textLabel.FontSize = "Size14";
                        textLabel.TextWrapped = true;
                        textLabel.Size = UDim2.new(1, 0, 1, 0);
                        textLabel.TextYAlignment = "Top";
                        textLabel.BackgroundTransparency = 1;
                        textLabel.TextStrokeTransparency = 0.5;
                        textLabel.TextColor3 = Color3.fromRGB(255, 0, 0);
                        if (obj.Name == "Flower1") then
                            textLabel.Text = "Blue Flower" .. " \n" .. Round((plr.Character.Head.Position - obj.Position).Magnitude / 3) .. " Distance" ;
                            textLabel.TextColor3 = Color3.fromRGB(0, 0, 255);
                        end
                        if (obj.Name == "Flower2") then
                            textLabel.Text = "Red Flower" .. " \n" .. Round((plr.Character.Head.Position - obj.Position).Magnitude / 3) .. " Distance" ;
                            textLabel.TextColor3 = Color3.fromRGB(255, 0, 0);
                        end
                    else
                        obj["NameEsp" .. Number ].TextLabel.Text = obj.Name .. "   \n" .. Round((plr.Character.Head.Position - obj.Position).Magnitude / 3) .. " Distance" ;
                    end
                elseif obj:FindFirstChild("NameEsp" .. Number) then
                    obj:FindFirstChild("NameEsp" .. Number):Destroy();
                end
            end
        end);
    end
end
function UpdateRealFruitChams()
    local function espSpawner(spawnerName, color)
        local spawner = Workspace:FindFirstChild(spawnerName)
        if not spawner then return end
        for _, fruit in pairs(spawner:GetChildren()) do
            pcall(function()
                if not fruit:IsA("Tool") then return end
                local handle = fruit:FindFirstChild("Handle")
                if not handle then return end
                if RealFruitESP then
                    if not handle:FindFirstChild("NameEsp" .. Number) then
                        local billboard = Instance.new("BillboardGui", handle)
                        billboard.Name = "NameEsp" .. Number
                        billboard.ExtentsOffset = Vector3.new(0, 1, 0)
                        billboard.Size = UDim2.new(1, 200, 1, 30)
                        billboard.Adornee = handle
                        billboard.AlwaysOnTop = true
                        local textLabel = Instance.new("TextLabel", billboard)
                        textLabel.Font = Enum.Font.GothamSemibold
                        textLabel.TextSize = 14
                        textLabel.TextWrapped = true
                        textLabel.Size = UDim2.new(1, 0, 1, 0)
                        textLabel.TextYAlignment = Enum.TextYAlignment.Top
                        textLabel.BackgroundTransparency = 1
                        textLabel.TextStrokeTransparency = 0.5
                        textLabel.TextColor3 = color
                        textLabel.Text = fruit.Name .. " \n" .. Round((plr.Character.Head.Position - handle.Position).Magnitude / 3) .. " Distance"
                    else
                        handle["NameEsp" .. Number].TextLabel.Text = fruit.Name .. " " .. Round((plr.Character.Head.Position - handle.Position).Magnitude / 3) .. " Distance"
                    end
                elseif handle:FindFirstChild("NameEsp" .. Number) then
                    handle:FindFirstChild("NameEsp" .. Number):Destroy()
                end
            end)
        end
    end
    espSpawner("AppleSpawner", Color3.fromRGB(255, 0, 0))
    espSpawner("PineappleSpawner", Color3.fromRGB(255, 174, 0))
    espSpawner("BananaSpawner", Color3.fromRGB(251, 255, 0))
end

function UpdateIslandESP()
    -- 1. Tìm thư mục chứa các đảo
    local locations = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
    if not locations then return end

    -- 2. Lấy vị trí nhân vật hiện tại
    local myPos = plr.Character and plr.Character:FindFirstChild("Head") and plr.Character.Head.Position

    for _, island in pairs(locations:GetChildren()) do
        pcall(function()
            -- Nếu tắt ESP hoặc mất nhân vật -> Xóa ESP cũ
            if not IslandESP or not myPos then
                local oldEsp = island:FindFirstChild("NameEsp")
                if oldEsp then oldEsp:Destroy() end
                return
            end

            if island.Name == "Sea" or not island:IsA("BasePart") then return end

            -- 3. Tạo khung hiển thị (BillboardGui) nếu chưa có
            local esp = island:FindFirstChild("NameEsp")
            if not esp then
                esp = Instance.new("BillboardGui", island)
                esp.Name = "NameEsp"
                esp.Size = UDim2.new(0, 200, 0, 45)
                esp.StudsOffset = Vector3.new(0, 4, 0)
                esp.AlwaysOnTop = true

                local text = Instance.new("TextLabel", esp)
                text.Name = "TextLabel"
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.TextColor3 = Color3.fromRGB(255, 255, 255)
                text.TextStrokeTransparency = 0.2
                text.Font = Enum.Font.GothamBold
                text.TextSize = 15
            end

            -- 4. Tính khoảng cách và cập nhật chữ liên tục
            local dist = math.floor((myPos - island.Position).Magnitude / 3)
            esp.TextLabel.Text = string.format("%s\n[%d m]", island.Name, dist)
        end)
    end
end
function UpdateIslandMirageESP()
    for _, loc in pairs(Workspace['_WorldOrigin'].Locations:GetChildren()) do
        pcall(function()
            if MirageIslandESP then
                if (loc.Name == "Mirage Island") then
                    if not loc:FindFirstChild("NameEsp") then
                        local billboard = Instance.new("BillboardGui", loc);
billboard.Name = "NameEsp";
                        billboard.ExtentsOffset = Vector3.new(0, 1, 0);
                        billboard.Size = UDim2.new(1, 200, 1, 30);
                        billboard.Adornee = loc;
                        billboard.AlwaysOnTop = true;
                        local textLabel = Instance.new("TextLabel", billboard);
textLabel.Font = Enum.Font.Code;
                        textLabel.TextSize = 14;
                        textLabel.TextWrapped = true;
                        textLabel.Size = UDim2.new(1, 0, 1, 0);
                        textLabel.TextYAlignment = Enum.TextYAlignment.Top;
                        textLabel.BackgroundTransparency = 1;
                        textLabel.TextStrokeTransparency = 0.5;
                        textLabel.TextColor3 = Color3.fromRGB(80, 245, 245);
                    else
                        loc['NameEsp'].TextLabel.Text = loc.Name .. "   \n" .. Round((plr.Character.Head.Position - loc.Position).Magnitude / 3) .. " M" ;
                    end
                end
            elseif loc:FindFirstChild("NameEsp") then
                loc:FindFirstChild("NameEsp"):Destroy();
            end
        end);
    end
end
function UpdateAuraESP()
    for _, mirage in pairs(Workspace.NPCs:GetChildren()) do
        pcall(function()
            if AuraESP then
                if (mirage.Name == "Master of Enhancement") then
                    if not mirage:FindFirstChild("NameEsp") then
                        local billboard = Instance.new("BillboardGui", mirage);
billboard.Name = "NameEsp";
                        billboard.ExtentsOffset = Vector3.new(0, 1, 0);
                        billboard.Size = UDim2.new(1, 200, 1, 30);
                        billboard.Adornee = mirage;
                        billboard.AlwaysOnTop = true;
                        local textLabel = Instance.new("TextLabel", billboard);
textLabel.Font = "Code";
                        textLabel.FontSize = "Size14";
                        textLabel.TextWrapped = true;
                        textLabel.Size = UDim2.new(1, 0, 1, 0);
                        textLabel.TextYAlignment = "Top";
                        textLabel.BackgroundTransparency = 1;
                        textLabel.TextStrokeTransparency = 0.5;
                        textLabel.TextColor3 = Color3.fromRGB(80, 245, 245);
                    else
                        mirage['NameEsp'].TextLabel.Text = mirage.Name .. "   \n" .. Round((plr.Character.Head.Position - mirage.Position).Magnitude / 3) .. " M" ;
                    end
                end
            elseif mirage:FindFirstChild("NameEsp") then
                mirage:FindFirstChild("NameEsp"):Destroy();
            end
        end);
    end
end
function UpdateLSDESP()
    for _, location in pairs(Workspace.NPCs:GetChildren()) do
        pcall(function()
            if LADESP then
                if (location.Name == "Legendary Sword Dealer") then
                    if not location:FindFirstChild("NameEsp") then
                        local billboard = Instance.new("BillboardGui", location);
billboard.Name = "NameEsp";
                        billboard.ExtentsOffset = Vector3.new(0, 1, 0);
                        billboard.Size = UDim2.new(1, 200, 1, 30);
                        billboard.Adornee = location;
                        billboard.AlwaysOnTop = true;
                        local textLabel = Instance.new("TextLabel", billboard);
textLabel.Font = "Code";
                        textLabel.FontSize = "Size14";
                        textLabel.TextWrapped = true;
                        textLabel.Size = UDim2.new(1, 0, 1, 0);
                        textLabel.TextYAlignment = "Top";
                        textLabel.BackgroundTransparency = 1;
                        textLabel.TextStrokeTransparency = 0.5;
                        textLabel.TextColor3 = Color3.fromRGB(80, 245, 245);
                    else
                        location['NameEsp'].TextLabel.Text = location.Name .. "   \n" .. Round((plr.Character.Head.Position - location.Position).Magnitude / 3) .. " M" ;
                    end
                end
            elseif location:FindFirstChild("NameEsp") then
                location:FindFirstChild("NameEsp"):Destroy();
            end
        end);
    end
end
function UpdateGeaESP()
    for _, island in pairs(Workspace.Map.MysticIsland:GetChildren()) do
        pcall(function()
            if GearESP then
                if (island.Name == "MeshPart") then
                    if not island:FindFirstChild("NameEsp") then
                        local billboard = Instance.new("BillboardGui", island);
billboard.Name = "NameEsp";
                        billboard.ExtentsOffset = Vector3.new(0, 1, 0);
                        billboard.Size = UDim2.new(1, 200, 1, 30);
                        billboard.Adornee = island;
                        billboard.AlwaysOnTop = true;
                        local textLabel = Instance.new("TextLabel", billboard);
textLabel.Font = "Code";
                        textLabel.FontSize = "Size14";
                        textLabel.TextWrapped = true;
                        textLabel.Size = UDim2.new(1, 0, 1, 0);
                        textLabel.TextYAlignment = "Top";
                        textLabel.BackgroundTransparency = 1;
                        textLabel.TextStrokeTransparency = 0.5;
                        textLabel.TextColor3 = Color3.fromRGB(80, 245, 245);
                    else
                        island['NameEsp'].TextLabel.Text = island.Name .. "   \n" .. Round((plr.Character.Head.Position - island.Position).Magnitude / 3) .. " M" ;
                    end
                end
            elseif island:FindFirstChild("NameEsp") then
                island:FindFirstChild("NameEsp"):Destroy();
            end
        end);
    end
end

----------------------------------------------------------------
-- 13. ESP LOOPS (Quái / Hải thú / NPC)
----------------------------------------------------------------
spawn(function()
    while wait() do
        pcall(function()
            if MobESP then
                for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("HumanoidRootPart") then
                        if not mob:FindFirstChild("MobEap") then
                            local bb = Instance.new("BillboardGui")
                            local tl = Instance.new("TextLabel")
                            bb.Parent = mob
                            bb.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                            bb.Active = true
                            bb.Name = "MobEap"
                            bb.AlwaysOnTop = true
                            bb.LightInfluence = 1
                            bb.Size = UDim2.new(0, 200, 0, 50)
                            bb.StudsOffset = Vector3.new(0, 2.5, 0)
                            tl.Parent = bb
                            tl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                            tl.BackgroundTransparency = 1
                            tl.Size = UDim2.new(0, 200, 0, 50)
                            tl.Font = Enum.Font.GothamBold
                            tl.TextColor3 = Color3.fromRGB(7, 236, 240)
                            tl.TextSize = 14
                        end
                        local char = plr.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local dist = math.floor((char.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude)
                            mob.MobEap.TextLabel.Text = mob.Name .. "-" .. dist .. " Distance"
                        end
                    end
                end
            else
                for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("MobEap") then
                        mob.MobEap:Destroy()
                    end
                end
            end
        end)
    end
end)

spawn(function()
    while wait() do
        pcall(function()
            local seaFolder = Workspace:FindFirstChild("SeaBeasts")
            if not seaFolder then return end
            if SeaESP then
                for _, beast in pairs(seaFolder:GetChildren()) do
                    if beast:FindFirstChild("HumanoidRootPart") then
                        if not beast:FindFirstChild("Seaesps") then
                            local bb = Instance.new("BillboardGui")
                            local tl = Instance.new("TextLabel")
                            bb.Parent = beast
                            bb.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                            bb.Active = true
                            bb.Name = "Seaesps"
                            bb.AlwaysOnTop = true
                            bb.LightInfluence = 1
                            bb.Size = UDim2.new(0, 200, 0, 50)
                            bb.StudsOffset = Vector3.new(0, 2.5, 0)
                            tl.Parent = bb
                            tl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                            tl.BackgroundTransparency = 1
                            tl.Size = UDim2.new(0, 200, 0, 50)
                            tl.Font = Enum.Font.GothamBold
                            tl.TextColor3 = Color3.fromRGB(7, 236, 240)
                            tl.TextSize = 14
                        end
                        local char = plr.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local dist = math.floor((char.HumanoidRootPart.Position - beast.HumanoidRootPart.Position).Magnitude)
                            beast.Seaesps.TextLabel.Text = beast.Name .. "-" .. dist .. " Distance"
                        end
                    end
                end
            else
                for _, beast in pairs(seaFolder:GetChildren()) do
                    if beast:FindFirstChild("Seaesps") then
                        beast.Seaesps:Destroy()
                    end
                end
            end
        end)
    end
end)

spawn(function()
    while wait() do
        pcall(function()
            local npcFolder = Workspace:FindFirstChild("NPCs")
            if not npcFolder then return end
            if NpcESP then
                for _, npc in pairs(npcFolder:GetChildren()) do
                    if npc:FindFirstChild("HumanoidRootPart") then
                        if not npc:FindFirstChild("NpcEspes") then
                            local bb = Instance.new("BillboardGui")
                            local tl = Instance.new("TextLabel")
                            bb.Parent = npc
                            bb.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                            bb.Active = true
                            bb.Name = "NpcEspes"
                            bb.AlwaysOnTop = true
                            bb.LightInfluence = 1
                            bb.Size = UDim2.new(0, 200, 0, 50)
                            bb.StudsOffset = Vector3.new(0, 2.5, 0)
                            tl.Parent = bb
                            tl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                            tl.BackgroundTransparency = 1
                            tl.Size = UDim2.new(0, 200, 0, 50)
                            tl.Font = Enum.Font.GothamBold
                            tl.TextColor3 = Color3.fromRGB(7, 236, 240)
                            tl.TextSize = 14
                        end
                        local char = plr.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local dist = math.floor((char.HumanoidRootPart.Position - npc.HumanoidRootPart.Position).Magnitude)
                            npc.NpcEspes.TextLabel.Text = npc.Name .. "-" .. dist .. " Distance"
                        end
                    end
                end
            else
                for _, npc in pairs(npcFolder:GetChildren()) do
                    if npc:FindFirstChild("NpcEspes") then
                        npc.NpcEspes:Destroy()
                    end
                end
            end
        end)
    end
end)

-------------------------------------------------
-- 14. MOVEMENT SYSTEM
-------------------------------------------------
-- Chỉ có 2 hệ thống di chuyển:
-- 1. BAY / FLY       -> Tween()
-- 2. GAME TELEPORT   -> cổng / requestEntrance / cơ chế teleport của game
--
-- Noclip / BodyClip / Stun chỉ là hệ thống hỗ trợ, không phải kiểu di chuyển.
-------------------------------------------------

-- 14.1 BAY / FLY
local TweenSpeed = 270
local CurrentTween = nil
_G.StopTween = false

function Tween(targetCFrame, waitForArrival)
    if _G.StopTween then return end
    if not targetCFrame then return end

    local character = plr.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local distance = (targetCFrame.Position - root.Position).Magnitude
    if distance < 2 then
        root.CFrame = targetCFrame
        return
    end

    if CurrentTween then
        pcall(function()
            CurrentTween:Cancel()
        end)
        CurrentTween = nil
    end

    local tweenTime = distance / TweenSpeed
    CurrentTween = TweenService:Create(
        root,
        TweenInfo.new(tweenTime, Enum.EasingStyle.Linear),
        {CFrame = targetCFrame}
    )

    CurrentTween:Play()

    if waitForArrival then
        local tween = CurrentTween
        while tween == CurrentTween and tween.PlaybackState == Enum.PlaybackState.Playing do
            if _G.StopTween or not root.Parent then
                break
            end
            task.wait()
        end

        if not _G.StopTween and root.Parent then
            root.CFrame = targetCFrame
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
    end
end

function CancelTween()
    _G.StopTween = true

    if CurrentTween then
        pcall(function()
            CurrentTween:Cancel()
        end)
        CurrentTween = nil
    end

    local character = plr.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

-- 14.2 GAME TELEPORT
-- Dùng cơ chế teleport có sẵn của game.
-- Nếu truyền targetCFrame thì sau khi teleport sẽ gọi lại Tween()
-- để bay nốt tới vị trí đích chính xác.
function GameTeleport(entrancePosition, targetCFrame)
    if not entrancePosition then return false end

    local character = plr.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local remoteFolder = ReplicatedStorage:FindFirstChild("Remotes")
    local commF = remoteFolder and remoteFolder:FindFirstChild("CommF_")
    if not commF then return false end

    local ok = pcall(function()
        commF:InvokeServer("requestEntrance", entrancePosition)
    end)

    if not ok then
        return false
    end

    if targetCFrame then
        task.wait()
        Tween(targetCFrame, true)
    end

    return true
end

-- 14.3 MOVEMENT SUPPORT - BodyClip
-- BodyClip chỉ hỗ trợ ổn định nhân vật trong lúc các chức năng di chuyển.
task.spawn(function()
    while task.wait() do
        pcall(function()
            local character = plr.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if not root then return end

            local movementEnabled =
                _G.AutoEvoRace
                or _G.CastleRaid
                or _G.CollectAzure
                or _G.TweenToKitsune
                or _G.GhostShip
                or _G.Ship
                or _G.Auto_Holy_Torch
                or _G.TeleportPly
                or _G.Auto_Sea3
                or _G.Auto_Sea2
                or _G.Tweenfruit
                or _G.AutoFishCrew
                or _G.Auto_Saber
                or _G.AutoShark
                or _G.Auto_Warden
                or _G.Auto_RainbowHaki
                or AutoFarmRace
                or _G.AutoQuestRace
                or Auto_Law
                or AutoTushita
                or _G.AutoHolyTorch
                or _G.AutoTerrorshark
                or _G.farmpiranya
                or _G.Auto_MusketeerHat
                or _G.Auto_ObservationV2
                or _G.AutoNear
                or _G.Auto_PoleV1
                or _G.Auto_Buddy
                or _G.Ectoplasm
                or AutoEvoRace
                or AutoBartilo
                or _G.Auto_Canvander
                or _G.AutoLevel
                or _G.Auto_DualKatana
                or Auto_Quest_Yama_3
                or Auto_Quest_Yama_2
                or Auto_Quest_Yama_1
                or Auto_Quest_Tushita_1
                or Auto_Quest_Tushita_2
                or Auto_Quest_Tushita_3
                or _G.Auto_Regoku
                or _G.AutoBone
                or _G.AutoBoneNoQuest
                or _G.AutoBoss
                or AutoFarmMasDevilFruit
                or AutoHallowSycthe
                or _G.CakePrince
                or _G.Auto_SkullGuitar
                or _G.AutoFarmSwan
                or _G.DoughKing
                or _G.AutoEliteor
                or AutoNextIsland
                or Musketeer
                or _G.AutoMaterial
                or AutoFarmRaceQuest
                or _G.Factory
                or _G.Auto_Saw
                or _G.AutoFrozenDimension
                or _G.AutoKillTrial
                or _G.AutoUpgrade
                or _G.TweenToFrozenDimension

            if movementEnabled then
                if not root:FindFirstChild("BodyClip") then
                    local bodyClip = Instance.new("BodyVelocity")
                    bodyClip.Name = "BodyClip"
                    bodyClip.MaxForce = Vector3.new(0, 100000, 0)
                    bodyClip.Velocity = Vector3.zero
                    bodyClip.Parent = root
                end
            else
                local bodyClip = root:FindFirstChild("BodyClip")
                if bodyClip then
                    bodyClip:Destroy()
                end
            end
        end)
    end
end)

-- 14.4 MOVEMENT SUPPORT - Noclip
task.spawn(function()
    pcall(function()
        RunService.Stepped:Connect(function()
            local character = plr.Character
            if not character then return end

            local noclipEnabled =
                _G.AutoEvoRace
                or _G.Auto_RainbowHaki
                or _G.Auto_SkullGuitar
                or _G.CastleRaid
                or _G.CollectAzure
                or _G.TweenToKitsune
                or _G.Auto_Sea3
                or _G.Auto_Sea2
                or _G.GhostShip
                or _G.Ship
                or _G.Auto_Holy_Torch
                or _G.TeleportPly
                or _G.Tweenfruit
                or _G.Auto_Saber
                or _G.Auto_PoleV1
                or _G.Auto_MusketeerHat
                or _G.AutoFishCrew
                or _G.AutoShark
                or AutoFarmRace
                or _G.AutoQuestRace
                or _G.Auto_Warden
                or Auto_Law
                or _G.Auto_DualKatana
                or Auto_Quest_Tushita_1
                or Auto_Quest_Tushita_2
                or Auto_Quest_Tushita_3
                or AutoTushita
                or _G.AutoHolyTorch
                or _G.Auto_Buddy
                or _G.AutoTerrorshark
                or _G.farmpiranya
                or Auto_Quest_Yama_3
                or _G.Auto_ObservationV2
                or Auto_Quest_Yama_2
                or Auto_Quest_Yama_1
                or _G.AutoNear
                or _G.Ectoplasm
                or AutoEvoRace
                or _G.AutoKillTrial
                or AutoBartilo
                or _G.Auto_Regoku
                or _G.AutoLevel
                or _G.AutoBone
                or _G.Auto_Canvander
                or _G.AutoBoneNoQuest
                or _G.AutoBoss
                or _G.Auto_Saw
                or AutoFarmMasDevilFruit
                or AutoHallowSycthe
                or _G.CakePrince
                or _G.DoughKing
                or _G.AutoFarmSwan
                or _G.AutoEliteor
                or AutoNextIsland
                or Musketeer
                or _G.AutoMaterial
                or _G.Factory
                or _G.AutoFrozenDimension
                or AutoFarmRaceQuest
                or _G.AutoUpgrade
                or _G.TweenToFrozenDimension

            if noclipEnabled then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end)
end)

-- 14.5 MOVEMENT SUPPORT - Stun
task.spawn(function()
    local character = plr.Character
    local stun = character and character:FindFirstChild("Stun")
    if not stun then return end

    stun.Changed:Connect(function()
        pcall(function()
            if stun.Parent then
                stun.Value = 0
            end
        end)
    end)
end)

-- 15. CHARACTER / TOOL HELPERS
-------------------------------------------------
function EquipTool(toolName)
    local tool = plr.Backpack:FindFirstChild(toolName)
    if tool and plr.Character then
        local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            task.wait()
            humanoid:EquipTool(tool)
        end
    end
end

function GetEquippedTool()
    local char = plr.Character
    if not char then
        return nil
    end

    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end

    return nil
end

-------------------------------------------------
-- 16. PLAYER / ENEMY HELPERS
-------------------------------------------------
local LocalPlayer = plr

function FindEnemiesInRange(resultTable, enemyList)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local myPos = character:GetPivot().Position
    local hitPart = nil

    for _, child in ipairs(enemyList) do
        local humanoid = child:FindFirstChildOfClass("Humanoid")

        if not child:GetAttribute("IsBoat")
            and humanoid
            and humanoid.Health > 0 then

            local headPart = child:FindFirstChild("Head")

            if headPart and (myPos - headPart.Position).Magnitude <= 60 then
                if child ~= LocalPlayer.Character then
                    table.insert(resultTable, {
                        child,
                        headPart
                    })
                    hitPart = headPart
                end
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player ~= LocalPlayer then
            local head = player.Character:FindFirstChild("Head")

            if head and (myPos - head.Position).Magnitude <= 60 then
                table.insert(resultTable, {
                    player.Character,
                    head
                })
                hitPart = head
            end
        end
    end

    return hitPart
end

-------------------------------------------------
-- 17. INVENTORY HELPERS
-------------------------------------------------
function CheckMaterial(matName)
    for _, invItem in pairs(
        ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory")
    ) do
        if type(invItem) == "table"
            and invItem.Type == "Material"
            and invItem.Name == matName then

            return invItem.Count
        end
    end

    return 0
end

function GetWeaponInventory(weaponName)
    for _, invItem in pairs(
        ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory")
    ) do
        if type(invItem) == "table"
            and invItem.Type == "Sword"
            and invItem.Name == weaponName then

            return true
        end
    end

    return false
end

-------------------------------------------------
-- 18. COMBAT SYSTEM
-------------------------------------------------
function AttackNoCoolDown()
    local enemiesInRange = {}
    local enemies = Workspace.Enemies:GetChildren()
    local hitPart = FindEnemiesInRange(enemiesInRange, enemies)

    if not hitPart then
        return
    end

    local equipped = GetEquippedTool()
    if not equipped then
        return
    end

    pcall(function()
        local delay = _G.Fast_Delay or 0.5
        local RS = ReplicatedStorage

        local regAttack = RS:WaitForChild("Modules")
            :WaitForChild("Net")
            :WaitForChild("RE/RegisterAttack")

        local regHit = RS:WaitForChild("Modules")
            :WaitForChild("Net")
            :WaitForChild("RE/RegisterHit")

        if #enemiesInRange > 0 then
            regAttack:FireServer(delay)
            regHit:FireServer(hitPart, enemiesInRange)
        else
            task.wait(delay)
        end
    end)
end

-------------------------------------------------
-- 19. HAKI / FARM CONFIG
-------------------------------------------------
Type = 1
Pos = CFrame.new(0, 30, 0)

function AutoHaki()
    if not plr.Character:FindFirstChild("HasBuso") then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
    end
end

-------------------------------------------------
-- 20. REMOTE / SKILL HOOK
-------------------------------------------------
task.spawn(function()
    local ref1 = getrawmetatable(game)
    local oldNamecall = ref1.__namecall

    setreadonly(ref1, false)

    ref1.__namecall = newcclosure(function(...)
        local method = getnamecallmethod()
        local part = {
            ...
        }

        if tostring(method) == "FireServer" then
            if tostring(part[1]) == "RemoteEvent" then
                if tostring(part[2]) ~= "true"
                    and tostring(part[2]) ~= "false" then

                    if _G.UseSkill then
                        if type(part[2]) == "vector" then
                            part[2] = PositionSkillMasteryDevilFruit
                        else
                            part[2] = CFrame.new(PositionSkillMasteryDevilFruit)
                        end

                        return oldNamecall(unpack(part))
                    end
                end
            end
        end

        return oldNamecall(...)
    end)
end)

-------------------------------------------------
-- 21. EFFECT OPTIMIZATION
-------------------------------------------------
local container = ReplicatedStorage:FindFirstChild("Effect")
    and ReplicatedStorage.Effect:FindFirstChild("Container")

if container then
    for _, name in ipairs({"Death", "Respawn"}) do
        local mod = container:FindFirstChild(name)

        if mod and mod:IsA("ModuleScript") then
            local eff = mod:FindFirstChild("eff")

            if eff then
                for _, child in ipairs(eff:GetChildren()) do
                    pcall(function()
                        child:Destroy()
                    end)
                end
            end

            pcall(function()
                local loaded = require(mod)

                if type(loaded) == "function" then
                    hookfunction(loaded, function() end)

                elseif type(loaded) == "table" then
                    for k, v in pairs(loaded) do
                        if type(v) == "function" then
                            loaded[k] = function() end
                        end
                    end
                end
            end)
        end
    end
end

-------------------------------------------------
-- 16. BUILD UI
--     Tất cả Toggle / Dropdown / Button + logic farm
--     được gom vào đây để dễ bảo trì
-------------------------------------------------
local function BuildUI()

-------------------------------------------------
-- TAB: HOME (Thông tin)
-------------------------------------------------
Tabs.Home:AddButton({
    Title = "Discord",
    Description = "Giao Lưu",
    Callback = function()
        setclipboard("https://discord.gg/25ms")
    end
})
local SelectWeaponDropdown = Tabs.Main:AddDropdown("DropdownSelectWeapon", {
    Title = "Vũ Khí",
    Description = "",
    Values = {
        "Melee",
        "Sword",
        "Blox Fruits"
    },
    Multi = false,
    Default = 1
});
SelectWeaponDropdown:SetValue("Melee");
SelectWeaponDropdown:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    ChooseWeapon = value;
end);
task.spawn(function()
    while wait() do
        pcall(function()
            if (ChooseWeapon == "Melee") then
                for _, tool in pairs(plr.Backpack:GetChildren()) do
                    if (tool.ToolTip == "Melee") then
                        if plr.Backpack:FindFirstChild(tostring(tool.Name)) then
                            SelectWeapon = tool.Name;
                        end
                    end
                end
            elseif (ChooseWeapon == "Sword") then
                for _, tool in pairs(plr.Backpack:GetChildren()) do
                    if (tool.ToolTip == "Sword") then
                        if plr.Backpack:FindFirstChild(tostring(tool.Name)) then
                            SelectWeapon = tool.Name;
                        end
                    end
                end
            elseif (ChooseWeapon == "Blox Fruits") then
                for _, tool in pairs(plr.Backpack:GetChildren()) do
                    if (tool.ToolTip == "Blox Fruit") then
                        if plr.Backpack:FindFirstChild(tostring(tool.Name)) then
                            SelectWeapon = tool.Name;
                        end
                    end
                end
            end
        end);
    end
end);
local AutoLevelToggle = Tabs.Main:AddToggle("ToggleLevel", {
    Title = "Cày Cấp",
    Description = "",
    Default = false
});
AutoLevelToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoLevel = value;
    if value == false then
        bringmob = false
        CancelTween()
    end
    if IsResettingConfig then return end
end);
Options.ToggleLevel:SetValue(false);
spawn(function()
    while task.wait() do
        if _G.AutoLevel then
            pcall(function()
                CheckLevel();
                if not _G.AutoLevel then return end

                if (not string.find(plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NameMon) or (plr.PlayerGui.Main.Quest.Visible == false)) then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest");
                    if not _G.AutoLevel then return end

                    Tween(CFrameQ);
                    if ((CFrameQ.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 5) then
                        if not _G.AutoLevel then return end
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", NameQuest, QuestLv);
                        task.wait(0.5);
                        if not _G.AutoLevel then return end
                    end
                elseif (string.find(plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NameMon) or (plr.PlayerGui.Main.Quest.Visible == true)) then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if not _G.AutoLevel then break end
                        if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                            if (enemy.Name == NameMon) then
                                repeat
                                    wait(_G.Fast_Delay);
                                    if not _G.AutoLevel then break end

                                    AttackNoCoolDown();
                                    bringmob = true;
                                    AutoHaki();
                                    EquipTool(SelectWeapon);
                                    if not _G.AutoLevel then break end

                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                    enemy.HumanoidRootPart.Transparency = 1;
                                    enemy.Humanoid.JumpPower = 0;
                                    enemy.Humanoid.WalkSpeed = 0;
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    FarmPos = enemy.HumanoidRootPart.CFrame;
                                    MonFarm = enemy.Name;
                                until not _G.AutoLevel or not enemy.Parent or (enemy.Humanoid.Health <= 0) or not Workspace.Enemies:FindFirstChild(enemy.Name) or (plr.PlayerGui.Main.Quest.Visible == false)
                                bringmob = false;
                            end
                        end
                    end

                    if not _G.AutoLevel then return end
                    for _, enemySpawn in pairs(Workspace['_WorldOrigin'].EnemySpawns:GetChildren()) do
                        if not _G.AutoLevel then break end
                        if string.find(enemySpawn.Name, NameMon) then
                            if ((plr.Character.HumanoidRootPart.Position - enemySpawn.Position).Magnitude >= 10) then
                                if not _G.AutoLevel then break end
                                Tween(enemySpawn.CFrame * Pos);
                            end
                        end
                    end
                end
            end);
        end
    end
end);
local MobAuraToggle = Tabs.Main:AddToggle("ToggleMobAura", {
    Title = "Đấm Quái Gần",
    Description = "",
    Default = false
});
MobAuraToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoNear = value;
    if IsResettingConfig then return end
    if (value == false) then
            CancelTween()
        end
end);
Options.ToggleMobAura:SetValue(false);
spawn(function()
    while wait() do
        if _G.AutoNear then
            pcall(function()
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                        if enemy.Name then
                            if ((plr.Character.HumanoidRootPart.Position - enemy:FindFirstChild("HumanoidRootPart").Position).Magnitude <= 5000) then
                                repeat
                                    wait(_G.Fast_Delay);
                                    AttackNoCoolDown();
                                    bringmob = true;
                                    AutoHaki();
                                    EquipTool(SelectWeapon);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                    enemy.HumanoidRootPart.Transparency = 1;
                                    enemy.Humanoid.JumpPower = 0;
                                    enemy.Humanoid.WalkSpeed = 0;
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    FarmPos = enemy.HumanoidRootPart.CFrame;
                                    MonFarm = enemy.Name;
                                until not _G.AutoNear or not enemy.Parent or (enemy.Humanoid.Health <= 0) or not Workspace.Enemies:FindFirstChild(enemy.Name)
                                bringmob = false;
                            end
                        end
                    end
                end
            end);
        end
    end
end);
local CastleRaidToggle = Tabs.Main:AddToggle("ToggleCastleRaid", {
    Title = "Đấm Hải Tặc",
    Description = "",
    Default = false
});
CastleRaidToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.CastleRaid = value;
end);
Options.ToggleCastleRaid:SetValue(false);
spawn(function()
    while wait() do
        if _G.CastleRaid then
            pcall(function()
                local castleRaidCFrame = CFrame.new(- 5496.17432, 313.768921, - 2841.53027, 0.924894512, 7.37058e-9, 0.380223751, 3.588102e-8, 1, - 1.06665446e-7, - 0.380223751, 1.1229711e-7, 0.924894512);
                if ((CFrame.new(- 5539.3115234375, 313.800537109375, - 2972.372314453125).Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 500) then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if (_G.CastleRaid and enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and (enemy.Humanoid.Health > 0)) then
                            if ((enemy.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 2000) then
                                repeat
                                    wait(_G.Fast_Delay);
                                    AttackNoCoolDown();
                                    AutoHaki();
                                    EquipTool(SelectWeapon);
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                until (enemy.Humanoid.Health <= 0) or not enemy.Parent or not _G.CastleRaid
                            end
                        end
                    end
                else
                    Tween(castleRaidCFrame);
                end
            end);
        end
    end
end);
local HakiFortressToggle = Tabs.Main:AddToggle("ToggleHakiFortress", {
    Title = "Bật Haki Màu Pháo Đài",
    Description = "",
    Default = false
});
HakiFortressToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.EnableHakiFortress = value;
end);
Options.ToggleHakiFortress:SetValue(false);
local function equipAuraSkin(storageNameArg, targetCFrameArg)
    local fruitCustomArgs = {
        [1] = {
            StorageName = storageNameArg,
            Type = "AuraSkin",
            Context = "Equip"
        }
    };
    ReplicatedStorage.Modules.Net:FindFirstChild("RF/FruitCustomizerRF"):InvokeServer(unpack(fruitCustomArgs));
    Tween(targetCFrameArg, true);
end
local function isNearPosition(targetPos, maxDist)
    local character = plr.Character;
    if (not character or not character:FindFirstChild("HumanoidRootPart")) then
        return false;
    end
    local myPos = character.HumanoidRootPart.Position;
    return (myPos - targetPos).Magnitude < maxDist ;
end
spawn(function()
    while true do
        if _G.EnableHakiFortress then
            equipAuraSkin("Snow White", Vector3.new(- 4971.71826171875, 335.9582214355469, - 3720.0595703125));
            while not isNearPosition(Vector3.new(- 4971.71826171875, 335.9582214355469, - 3720.0595703125), 1) do
                wait(0.1);
            end
            wait(0.5);
            equipAuraSkin("Pure Red", Vector3.new(- 5414.92041015625, 314.2582092285156, - 2212.20166015625));
            while not isNearPosition(Vector3.new(- 5414.92041015625, 314.2582092285156, - 2212.20166015625), 1) do
                wait(0.1);
            end
            wait(0.5);
            equipAuraSkin("Winter Sky", Vector3.new(- 5420.26318359375, 1089.3582763671875, - 2666.8193359375));
            while not isNearPosition(Vector3.new(- 5420.26318359375, 1089.3582763671875, - 2666.8193359375), 1) do
                wait(0.1);
            end
            wait(0.5);
            _G.EnableHakiFortress = false;
        end
        wait(0.5);
    end
end);
local CollectChestToggle = Tabs.Main:AddToggle("ToggleCollectChest", {
    Title = "Lụm Rương",
    Description = "",
    Default = false
});
CollectChestToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoCollectChest = value;
end);
spawn(function()
    while wait() do
        if _G.AutoCollectChest then
            local playersService = Players;
            local localPlr = playersService.LocalPlayer;
            local localChar = localPlr.Character or localPlr.CharacterAdded:Wait() ;
            local myPivotPos = localChar:GetPivot().Position;
            local collectionService = CollectionService;
            local taggedChests = collectionService:GetTagged("_ChestTagged");
            local nearestDist, nearestChest = math.huge;
            for chestIdx = 1, # taggedChests do
                local chestObj = taggedChests[chestIdx];
                local chestDist = (chestObj:GetPivot().Position - myPivotPos).Magnitude;
                if (not chestObj:GetAttribute("IsDisabled") and (chestDist < nearestDist)) then
                    nearestDist, nearestChest = chestDist, chestObj;
                end
            end
            if nearestChest then
                local chestPos = nearestChest:GetPivot().Position;
                local chestCFrame = CFrame.new(chestPos);
                Tween(chestCFrame, true);
            end
        end
    end
end);
local MasterySection = Tabs.Main:AddSection("Thông Thạo");
local MasteryDropdown = Tabs.Main:AddDropdown("DropdownMastery", {
    Title = "Cày Thông Thạo",
    Description = "",
    Values = {
        "Near Mobs"
    },
    Multi = false,
    Default = 1
});
MasteryDropdown:SetValue(TypeMastery);
MasteryDropdown:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    TypeMastery = value;
end);
local MasteryFruitToggle = Tabs.Main:AddToggle("ToggleMasteryFruit", {
    Title = "Cày Trái",
    Description = "",
    Default = false
});
MasteryFruitToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    AutoFarmMasDevilFruit = value;
end);
Options.ToggleMasteryFruit:SetValue(false);
local HealthInput = Tabs.Main:AddInput("InputHealth", {
    Title = "Máu Quái Còn Lại",
    Description = "",
    Default = "20",
    Placeholder = "Nhập % Máu Quái",
    Numeric = true,
    Finished = false, 
    Callback = function(masteryPercentInput)
        local num = tonumber(masteryPercentInput)
        if num then
            KillPercent = math.clamp(num, 0, 100)
        else
            KillPercent = 20 
        end
    end
});
HealthInput:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    KillPercent = value;
end);
HealthInput:SetValue(20);
spawn(function()
    while task.wait() do
        if _G.UseSkill then
            pcall(function()
                if _G.UseSkill then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if ((enemy.Name == MonFarm) and enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health <= ((enemy.Humanoid.MaxHealth * KillPercent) / 100))) then
                            repeat
                                RunService.Heartbeat:wait();
                                EquipTool(plr.Data.DevilFruit.Value);
                                Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                PositionSkillMasteryDevilFruit = enemy.HumanoidRootPart.Position;
                                if plr.Character:FindFirstChild(plr.Data.DevilFruit.Value) then
                                    plr.Character:FindFirstChild(plr.Data.DevilFruit.Value).MousePos.Value = PositionSkillMasteryDevilFruit;
                                    local fruitLevel = plr.Character:FindFirstChild(plr.Data.DevilFruit.Value).Level.Value;
                                    if (SkillZ and (fruitLevel >= 1)) then
                                        game:service("VirtualInputManager"):SendKeyEvent(true, "Z", false, game);
                                        wait();
                                        game:service("VirtualInputManager"):SendKeyEvent(false, "Z", false, game);
                                    end
                                    if (SkillX and (fruitLevel >= 2)) then
                                        game:service("VirtualInputManager"):SendKeyEvent(true, "X", false, game);
                                        wait();
                                        game:service("VirtualInputManager"):SendKeyEvent(false, "X", false, game);
                                    end
                                    if (SkillC and (fruitLevel >= 3)) then
                                        game:service("VirtualInputManager"):SendKeyEvent(true, "C", false, game);
                                        wait();
                                        game:service("VirtualInputManager"):SendKeyEvent(false, "C", false, game);
                                    end
                                    if (SkillV and (fruitLevel >= 4)) then
                                        game:service("VirtualInputManager"):SendKeyEvent(true, "V", false, game);
                                        wait();
                                        game:service("VirtualInputManager"):SendKeyEvent(false, "V", false, game);
                                    end
                                    if (SkillF and (fruitLevel >= 5)) then
                                        VirtualInputManager:SendKeyEvent(true, "F", false, game);
                                        wait();
                                        VirtualInputManager:SendKeyEvent(false, "F", false, game);
                                    end
                                end
                            until not AutoFarmMasDevilFruit or not _G.UseSkill or (enemy.Humanoid.Health == 0)
                        end
                    end
                end
            end);
        end
    end
end);
spawn(function()
    while task.wait(0.1) do
        if (AutoFarmMasDevilFruit and (TypeMastery == "Near Mobs")) then
            pcall(function()
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if (targetPlayer.Name and targetPlayer:FindFirstChild("Humanoid") and targetPlayer:FindFirstChild("HumanoidRootPart")) then
                        if ((plr.Character.HumanoidRootPart.Position - targetPlayer:FindFirstChild("HumanoidRootPart").Position).Magnitude <= 5000) then
                            repeat
                                wait(_G.Fast_Delay);
                                if (enemy.Humanoid.Health <= ((targetPlayer.Humanoid.MaxHealth * KillPercent) / 100)) then
                                    _G.UseSkill = true;
                                else
                                    _G.UseSkill = false;
                                    AutoHaki();
                                    bringmob = true;
                                    EquipTool(SelectWeapon);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                    enemy.HumanoidRootPart.Transparency = 1;
                                    targetPlayer.Humanoid.JumpPower = 0;
                                    targetPlayer.Humanoid.WalkSpeed = 0;
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    FarmPos = enemy.HumanoidRootPart.CFrame;
                                    MonFarm = targetPlayer.Name;
                                    AttackNoCoolDown();
                                end
                            until not AutoFarmMasDevilFruit or (not MasteryType == "Near Mobs") or not enemy.Parent or (enemy.Humanoid.Health == 0)
                            bringmob = false;
                            _G.UseSkill = false;
                        end
                    end
                end
            end);
        end
    end
end);
if Sea3 then
    local sectionBone = Tabs.Main:AddSection("Xương");
    local paraBoneCount = Tabs.Main:AddParagraph({
        Title = "Xương Trạng Thái",
        Content = ""
    });
    spawn(function()
        pcall(function()
            while wait() do
                local boneCheckResult = ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Check");
                paraBoneCount:SetDesc("Mày Có: " .. tostring(boneCheckResult) .. " Xương");
            end
        end);
    end);
    local toggleBone = Tabs.Main:AddToggle("ToggleBone", {
        Title = "Cày Xương",
        Description = "",
        Default = false
    });
    toggleBone:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        _G.AutoBone = value;
        if IsResettingConfig then return end
        if (value == false) then
            CancelTween()
        end
    end);
    Options.ToggleBone:SetValue(false);
    local cframeBoneQuest = CFrame.new(- 9515.75, 174.8521728515625, 6079.40625);
    spawn(function()
        while wait() do
            if _G.AutoBone then
                pcall(function()
                    local questTitleText = plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text;
                    if not string.find(questTitleText, "Demonic Soul") then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest");
                    end
                    if (plr.PlayerGui.Main.Quest.Visible == false) then
                        Tween(cframeBoneQuest);
                        if ((cframeBoneQuest.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 3) then
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", "HauntedQuest2", 1);
                        end
                    elseif (plr.PlayerGui.Main.Quest.Visible == true) then
                        if (Workspace.Enemies:FindFirstChild("Reborn Skeleton") or Workspace.Enemies:FindFirstChild("Living Zombie") or Workspace.Enemies:FindFirstChild("Demonic Soul") or Workspace.Enemies:FindFirstChild("Posessed Mummy")) then
                            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                                if (enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and (enemy.Humanoid.Health > 0)) then
                                    if ((enemy.Name == "Reborn Skeleton") or (enemy.Name == "Living Zombie") or (enemy.Name == "Demonic Soul") or (enemy.Name == "Posessed Mummy")) then
                                        if string.find(plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "Demonic Soul") then
                                            repeat
                                                wait(_G.Fast_Delay);
                                                AttackNoCoolDown();
                                                AutoHaki();
                                                bringmob = true;
                                                EquipTool(SelectWeapon);
                                                Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                                enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                                enemy.HumanoidRootPart.Transparency = 1;
                                                enemy.Humanoid.JumpPower = 0;
                                                enemy.Humanoid.WalkSpeed = 0;
                                                enemy.HumanoidRootPart.CanCollide = false;
                                                FarmPos = enemy.HumanoidRootPart.CFrame;
                                                MonFarm = enemy.Name;
                                            until not _G.AutoBone or (enemy.Humanoid.Health <= 0) or not enemy.Parent or (plr.PlayerGui.Main.Quest.Visible == false)
                                        else
                                            ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest");
                                            bringmob = false;
                                        end
                                    end
                                end
                            end
                        else
                        end
                    end
                end);
            end
        end
    end);
    local cframeBoneQuest2 = CFrame.new(- 9515.75, 174.8521728515625, 6079.40625);
    spawn(function()
        while wait() do
            if _G.AutoBoneNoQuest then
                pcall(function()
                    Tween(cframeBoneQuest2);
                    if ((cframeBoneQuest2.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 3) then
                    end
                    if (Workspace.Enemies:FindFirstChild("Reborn Skeleton") or Workspace.Enemies:FindFirstChild("Living Zombie") or Workspace.Enemies:FindFirstChild("Demonic Soul") or Workspace.Enemies:FindFirstChild("Posessed Mummy")) then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if (enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and (enemy.Humanoid.Health > 0)) then
                                if ((enemy.Name == "Reborn Skeleton") or (enemy.Name == "Living Zombie") or (enemy.Name == "Demonic Soul") or (enemy.Name == "Posessed Mummy")) then
                                    repeat
                                        wait(_G.Fast_Delay);
                                        AttackNoCoolDown();
                                        AutoHaki();
                                        bringmob = true;
                                        EquipTool(SelectWeapon);
                                        Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                        enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                        enemy.HumanoidRootPart.Transparency = 1;
                                        enemy.Humanoid.JumpPower = 0;
                                        enemy.Humanoid.WalkSpeed = 0;
                                        enemy.HumanoidRootPart.CanCollide = false;
                                        FarmPos = enemy.HumanoidRootPart.CFrame;
                                        MonFarm = enemy.Name;
                                    until not _G.AutoBoneNoQuest or (enemy.Humanoid.Health <= 0) or not enemy.Parent
                                end
                            end
                        end
                    end
                end);
            end
        end
    end);
    Tabs.Main:AddButton({
        Title = "Cầu Nguyện",
        Description = "",
        Callback = function()
            local buyBoneArgs = {
                [1] = "gravestoneEvent",
                [2] = 1
            };
            ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(buyBoneArgs));
        end
    });
    Tabs.Main:AddButton({
        Title = "Thử Vận May",
        Description = "",
        Callback = function()
            local buyBoneArgs2 = {
                [1] = "gravestoneEvent",
                [2] = 2
            };
            ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(buyBoneArgs2));
        end
    });
    local toggleRandomBone = Tabs.Main:AddToggle("ToggleRandomBone", {
        Title = "Random Xương",
        Description = "",
        Default = false
    });
    toggleRandomBone:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        _G.AutoRandomBone = value;
    end);
    Options.ToggleRandomBone:SetValue(false);
    spawn(function()
        while wait() do
            if _G.AutoRandomBone then
                local randomBoneArgs = {
                    [1] = "Bones",
                    [2] = "Buy",
                    [3] = 1,
                    [4] = 1
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(randomBoneArgs));
            end
        end
    end);
end
if Sea3 then
    local sectionCake = Tabs.Main:AddSection("Tư Lệnh Bánh");
    local section = Tabs.Main:AddParagraph({
        Title = "Trạng Thái Nó Ra",
        Content = ""
    });
    spawn(function()
        while wait() do
            pcall(function()
                if (string.len(ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner")) == 88) then
                    section:SetDesc("Còn: " .. string.sub(ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner"), 39, 41) .. "");
                elseif (string.len(ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner")) == 87) then
                    section:SetDesc("Còn: " .. string.sub(ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner"), 39, 40) .. "");
                elseif (string.len(ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner")) == 86) then
                    section:SetDesc("Còn: " .. string.sub(ReplicatedStorage.Remotes.CommF_:InvokeServer("CakePrinceSpawner"), 39, 39) .. " ");
                else
                    section:SetDesc("Tư Lệnh Bánh : ✅️");
                end
            end);
        end
    end);
    local toggleCake = Tabs.Main:AddToggle("ToggleCake", {
        Title = "Cày Tư Lệnh Bánh",
        Description = "",
        Default = false
    });
    local cakeFirstTween = true;
    toggleCake:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        _G.CakePrince = value;
        if value then
            if cakeFirstTween then
                cakeFirstTween = false;
                local cakeTweenCFrame = CFrame.new(- 2003.932861328125, 380.4824523925781, - 12561.0185546875);
                Tween(cakeTweenCFrame);
            end
        else
            cakeFirstTween = true;
            CancelTween()
        end
    end);
    Options.ToggleCake:SetValue(false);
    spawn(function()
        while wait() do
            if _G.CakePrince then
                pcall(function()
                    if Workspace.Enemies:FindFirstChild("Cake Prince") then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if (enemy.Name == "Cake Prince") then
                                if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                                    repeat
                                        task.wait(_G.Fast_Delay);
                                        AutoHaki();
                                        EquipTool(SelectWeapon);
                                        enemy.HumanoidRootPart.CanCollide = false;
                                        enemy.Humanoid.WalkSpeed = 0;
                                        enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                        Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                        AttackNoCoolDown();
                                    until not _G.CakePrince or not enemy.Parent or (enemy.Humanoid.Health <= 0)
                                end
                            end
                        end
                    elseif ReplicatedStorage:FindFirstChild("Cake Prince [Lv. 2300] [Raid Boss]") then
                        Tween(ReplicatedStorage:FindFirstChild("Cake Prince [Lv. 2300] [Raid Boss]").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2));
                    elseif (Workspace.Map.CakeLoaf.BigMirror.Other.Transparency == 1) then
                        if (Workspace.Enemies:FindFirstChild("Cookie Crafter") or Workspace.Enemies:FindFirstChild("Cake Guard") or Workspace.Enemies:FindFirstChild("Baking Staff") or Workspace.Enemies:FindFirstChild("Head Baker")) then
                            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                                if ((enemy.Name == "Cookie Crafter") or (enemy.Name == "Cake Guard") or (enemy.Name == "Baking Staff") or (enemy.Name == "Head Baker")) then
                                    if (temp5:FindFirstChild("Humanoid") and temp5:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                                        repeat
                                            task.wait(_G.Fast_Delay);
                                            AutoHaki();
                                            bringmob = true;
                                            EquipTool(SelectWeapon);
                                            enemy.HumanoidRootPart.CanCollide = false;
                                            temp5.Humanoid.WalkSpeed = 0;
                                            temp5.Head.CanCollide = false;
                                            enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                            FarmPos = enemy.HumanoidRootPart.CFrame;
                                            MonFarm = temp5.Name;
                                            Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                            AttackNoCoolDown();
                                        until not _G.CakePrince or not enemy.Parent or (enemy.Humanoid.Health <= 0) or (Workspace.Map.CakeLoaf.BigMirror.Other.Transparency == 0) or ReplicatedStorage:FindFirstChild("Cake Prince [Lv. 2300] [Raid Boss]") or Workspace.Enemies:FindFirstChild("Cake Prince [Lv. 2300] [Raid Boss]")
                                        bringmob = false;
                                    end
                                end
                            end
                        end
                    end
                end);
            end
        end
    end);
    local toggleDoughKing = Tabs.Main:AddToggle("ToggleDoughKing", {
        Title = "Đấm Vua Bột",
        Description = "",
        Default = false
    });
    toggleDoughKing:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        _G.DoughKing = value;
        if (value == false) then
            CancelTween()
        end
    end);
    Options.ToggleDoughKing:SetValue(false);
    spawn(function()
        while wait() do
            if _G.DoughKing then
                pcall(function()
                    if Workspace.Enemies:FindFirstChild("Dough King") then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if (enemy.Name == "Dough King") then
                                if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                                    repeat
                                        task.wait(_G.Fast_Delay);
                                        AutoHaki();
                                        EquipTool(SelectWeapon);
                                        enemy.HumanoidRootPart.CanCollide = false;
                                        enemy.Humanoid.WalkSpeed = 0;
                                        enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                        Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                        AttackNoCoolDown();
                                    until not _G.DoughKing or not enemy.Parent or (enemy.Humanoid.Health <= 0)
                                end
                            end
                        end
                    end
                end);
            end
        end
    end);
    local toggleSpawnCake = Tabs.Main:AddToggle("ToggleSpawnCake", {
        Title = "Triệu Hồi Tư Lệnh Bánh",
        Description = "",
        Default = true
    });
    toggleSpawnCake:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        _G.SpawnCakePrince = value;
    end);
    Options.ToggleSpawnCake:SetValue(true);
end
spawn(function()
    while wait() do
        if _G.SpawnCakePrince then
            local spawnCakeArgs = {
                [1] = "CakePrinceSpawner",
                [2] = true
            };
            ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(spawnCakeArgs));
            local spawnCakeArgs = {
                [1] = "CakePrinceSpawner"
            };
            ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(spawnCakeArgs));
        end
    end
end);
if Sea2 then
    local sectionEctoplasm = Tabs.Main:AddSection("Ectoplasm Farm");
    local toggleEctoplasm = Tabs.Main:AddToggle("ToggleVatChatKiDi", {
        Title = "Auto Farm Ectoplasm",
        Description = "",
        Default = false
    });
    toggleEctoplasm:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        _G.Ectoplasm = value;
    end);
    Options.ToggleVatChatKiDi:SetValue(false);
    spawn(function()
        while wait() do
            pcall(function()
                if _G.Ectoplasm then
                    if (Workspace.Enemies:FindFirstChild("Ship Deckhand") or Workspace.Enemies:FindFirstChild("Ship Engineer") or Workspace.Enemies:FindFirstChild("Ship Steward") or Workspace.Enemies:FindFirstChild("Ship Officer")) then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if ((enemy.Name == "Ship Steward") or (enemy.Name == "Ship Engineer") or (enemy.Name == "Ship Deckhand") or ((enemy.Name == "Ship Officer") and varA:FindFirstChild("Humanoid"))) then
                                if (enemy.Humanoid.Health > 0) then
                                    repeat
                                        wait(_G.Fast_Delay);
                                        AttackNoCoolDown();
                                        AutoHaki();
                                        bringmob = true;
                                        EquipTool(SelectWeapon);
                                        Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                        enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                        enemy.HumanoidRootPart.Transparency = 1;
                                        varA.Humanoid.JumpPower = 0;
                                        varA.Humanoid.WalkSpeed = 0;
                                        enemy.HumanoidRootPart.CanCollide = false;
                                        FarmPos = enemy.HumanoidRootPart.CFrame;
                                        MonFarm = varA.Name;
                                    until (_G.Ectoplasm == false) or not enemy.Parent or (enemy.Humanoid.Health == 0) or not Workspace.Enemies:FindFirstChild(varA.Name)
                                    bringmob = false;
                                end
                            end
                        end
                    else
                        local ectoplasmDist = (Vector3.new(904.4072265625, 181.05767822266, 33341.38671875) - plr.Character.HumanoidRootPart.Position).Magnitude;
                        if (ectoplasmDist > 20000) then
                            GameTeleport(Vector3.new(923.21252441406, 126.9760055542, 32852.83203125));
                        end
                        Tween(CFrame.new(904.4072265625, 181.05767822266, 33341.38671875));
                    end
                end
            end);
        end
    end);
end
local BossSection = Tabs.Main:AddSection("Trùm");
if Sea1 then
    tableBoss = {
        "The Gorilla King",
        "Bobby",
        "Yeti",
        "Mob Leader",
        "Vice Admiral",
        "Warden",
        "Chief Warden",
        "Swan",
        "Magma Admiral",
        "Fishman Lord",
        "Wysper",
        "Thunder God",
        "Cyborg",
        "Saber Expert"
    };
elseif Sea2 then
    tableBoss = {
        "Diamond",
        "Jeremy",
        "Fajita",
        "Don Swan",
        "Smoke Admiral",
        "Cursed Captain",
        "Darkbeard",
        "Order",
        "Awakened Ice Admiral",
        "Tide Keeper"
    };
elseif Sea3 then
    tableBoss = {
        "Stone",
        "Hydra Leader",
        "Kilo Admiral",
        "Captain Elephant",
        "Beautiful Pirate",
        "rip_indra True Form",
        "Longma",
        "Soul Reaper",
        "Cake Queen"
    };
end
local BossDropdown = Tabs.Main:AddDropdown("DropdownBoss", {
    Title = "Chọn Trùm",
    Description = "",
    Values = tableBoss,
    Multi = false,
    Default = 1
});
BossDropdown:SetValue(_G.SelectBoss);
BossDropdown:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.SelectBoss = value;
end);
local BossStatus = Tabs.Main:AddParagraph({ Title = "Boss Status", Content = "Chưa chọn boss" })
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local bossName = _G.SelectBoss
            if not bossName or bossName == "" then
                BossStatus:SetDesc("Chưa chọn boss")
                return
            end
            local isAlive = false
            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                if v.Name == bossName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    isAlive = true
                    break
                end
            end
            if not isAlive then
                local repBoss = ReplicatedStorage:FindFirstChild(bossName)
                if repBoss and repBoss:FindFirstChild("Humanoid") and repBoss.Humanoid.Health > 0 then
                    isAlive = true
                end
            end
            if isAlive then
                BossStatus:SetDesc(bossName .. ": 🟢 - Đang Sống")
            else
                BossStatus:SetDesc(bossName .. ": 🔴 - Chờ Hồi Sinh")
            end
        end)
    end
end)
local AutoFarmBossToggle = Tabs.Main:AddToggle("ToggleAutoFarmBoss", {
    Title = "Đấm Trùm",
    Description = "",
    Default = false
});
AutoFarmBossToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.AutoBoss = value;
end);
Options.ToggleAutoFarmBoss:SetValue(false);
spawn(function()
    while wait() do
        if _G.AutoBoss then
            pcall(function()
                if Workspace.Enemies:FindFirstChild(_G.SelectBoss) then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if (enemy.Name == _G.SelectBoss) then
                            if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                                repeat
                                    wait(_G.Fast_Delay);
                                    AttackNoCoolDown();
                                    AutoHaki();
                                    EquipTool(SelectWeapon);
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    enemy.Humanoid.WalkSpeed = 0;
                                    enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    sethiddenproperty(plr, "SimulationRadius", math.huge);
                                until not _G.AutoBoss or not enemy.Parent or (enemy.Humanoid.Health <= 0)
                            end
                        end
                    end
                elseif ReplicatedStorage:FindFirstChild(_G.SelectBoss) then
                    Tween(ReplicatedStorage:FindFirstChild(_G.SelectBoss).HumanoidRootPart.CFrame * CFrame.new(5, 10, 7));
                end
            end);
        end
    end
end);
local MaterialSection = Tabs.Main:AddSection("Nguyên Liệu");
if Sea1 then
    MaterialList = {
        "Scrap Metal",
        "Leather",
        "Angel Wings",
        "Magma Ore",
        "Fish Tail"
    };
elseif Sea2 then
    MaterialList = {
        "Scrap Metal",
        "Leather",
        "Radioactive Material",
        "Mystic Droplet",
        "Magma Ore",
        "Vampire Fang"
    };
elseif Sea3 then
    MaterialList = {
        "Scrap Metal",
        "Leather",
        "Demonic Wisp",
        "Conjured Cocoa",
        "Dragon Scale",
        "Gunpowder",
        "Fish Tail",
        "Mini Tusk",
        "Hydra Enforcer",
        "Venomous Assailant"
    };
end
local MaterialDropdown = Tabs.Main:AddDropdown("DropdownMaterial", {
    Title = "Chọn Nguyên Liệu",
    Description = "",
    Values = MaterialList,
    Multi = false,
    Default = 1
});
MaterialDropdown:SetValue(SelectMaterial);
MaterialDropdown:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    SelectMaterial = value;
end);
local MaterialToggle = Tabs.Main:AddToggle("ToggleMaterial", {
    Title = "Cày Nguyên Liệu",
    Description = "",
    Default = false
});
MaterialToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoMaterial = value;
    if IsResettingConfig then return end
    if (value == false) then
            CancelTween()
        end
end);
Options.ToggleMaterial:SetValue(false);
spawn(function()
    while task.wait() do
        if _G.AutoMaterial then
            pcall(function()
                MaterialMon(SelectMaterial);
                Tween(MPos);
                if Workspace.Enemies:FindFirstChild(MMon) then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if (varB:FindFirstChild("Humanoid") and varB:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                            if (enemy.Name == MMon) then
                                repeat
                                    wait(_G.Fast_Delay);
                                    AttackNoCoolDown();
                                    AutoHaki();
                                    bringmob = true;
                                    EquipTool(SelectWeapon);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                    enemy.HumanoidRootPart.Transparency = 1;
                                    varB.Humanoid.JumpPower = 0;
                                    varB.Humanoid.WalkSpeed = 0;
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    FarmPos = enemy.HumanoidRootPart.CFrame;
                                    MonFarm = varB.Name;
                                until not _G.AutoMaterial or not enemy.Parent or (enemy.Humanoid.Health <= 0)
                                bringmob = false;
                            end
                        end
                    end
                else
                    for _, spawnNode in pairs(Workspace['_WorldOrigin'].EnemySpawns:GetChildren()) do
                        if string.find(spawnNode.Name, Mon) then
                            if ((plr.Character.HumanoidRootPart.Position - spawnNode.Position).Magnitude >= 10) then
                                Tween(enemy.HumanoidRootPart.CFrame * Pos);
                            end
                        end
                    end
                end
            end);
        end
    end
end);
if Sea3 then
    local sectionMaterial = Tabs.Sea:AddSection("Đảo Cáo");
    local dropdownMaterial = Tabs.Sea:AddParagraph({
        Title = "Trạng Thái Đảo Cáo",
        Content = ""
    });
    function UpdateKitsune()
        if Workspace.Map:FindFirstChild("KitsuneIsland") then
            dropdownMaterial:SetDesc("Đảo Cáo : 🟢");
        else
            dropdownMaterial:SetDesc("Đảo Cáo : 🔴");
        end
    end
    spawn(function()
        pcall(function()
            while wait() do
                UpdateKitsune();
            end
        end);
    end);
    local toggleEspKitsune = Tabs.Sea:AddToggle("ToggleEspKitsune", {
        Title = "Định Vị Đảo Cáo",
        Description = "",
        Default = false
    });
    toggleEspKitsune:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        KitsuneIslandEsp = value;
        while KitsuneIslandEsp do
            wait();
            UpdateIslandKisuneESP();
        end
    end);
    Options.ToggleEspKitsune:SetValue(false);
    function UpdateIslandKisuneESP()
        for _, enemy in pairs(Workspace['_WorldOrigin'].Locations:GetChildren()) do
            pcall(function()
                if KitsuneIslandEsp then
                    if (enemy.Name == "Kitsune Island") then
                        if not enemy:FindFirstChild("NameEsp") then
                            local billboard = Instance.new("BillboardGui", enemy);
billboard.Name = "NameEsp";
                            varC.ExtentsOffset = Vector3.new(0, 1, 0);
                            varC.Size = UDim2.new(1, 200, 1, 30);
                            varC.Adornee = enemy;
                            varC.AlwaysOnTop = true;
                            local textLabel = Instance.new("TextLabel", varC);
textLabel.Font = "Code";
                            label.FontSize = "Size14";
                            label.TextWrapped = true;
                            label.Size = UDim2.new(1, 0, 1, 0);
                            label.TextYAlignment = "Top";
                            label.BackgroundTransparency = 1;
                            label.TextStrokeTransparency = 0.5;
                            label.TextColor3 = Color3.fromRGB(80, 245, 245);
                        else
                            enemy['NameEsp'].TextLabel.Text = enemy.Name .. "   \n" .. Round((plr.Character.Head.Position - enemy.Position).Magnitude / 3) .. " M" ;
                        end
                    end
                elseif enemy:FindFirstChild("NameEsp") then
                    enemy:FindFirstChild("NameEsp"):Destroy();
                end
            end);
        end
    end
    local toggleTPKitsune = Tabs.Sea:AddToggle("ToggleTPKitsune", {
        Title = "Bay Vô Đảo Cáo",
        Description = "",
        Default = false
    });
    toggleTPKitsune:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        if value == false then
            CancelTween()
        end
        _G.TweenToKitsune = value;
    end);
    Options.ToggleTPKitsune:SetValue(false);
    spawn(function()
        local kitsuneIsland;
        while not kitsuneIsland do
            kitsuneIsland = Workspace.Map:FindFirstChild("KitsuneIsland");
            wait();
        end
        while wait() do
            if _G.TweenToKitsune then
                local kitsuneModel = kitsuneIsland:FindFirstChild("ShrineActive");
                if kitsuneModel then
                    for _, descendant in pairs(kitsuneModel:GetDescendants()) do
                        if (descendant:IsA("BasePart") and descendant.Name:find("NeonShrinePart")) then
                            Tween(descendant.CFrame);
                        end
                    end
                end
            end
        end
    end);
    local toggleCollectAzure = Tabs.Sea:AddToggle("ToggleCollectAzure", {
        Title = "Lụm Linh Hồn Xanh",
        Description = "",
        Default = false
    });
    toggleCollectAzure:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        if value == false then
            CancelTween()
        end
        _G.CollectAzure = value;
    end);
    Options.ToggleCollectAzure:SetValue(false);
    spawn(function()
        while wait() do
            if _G.CollectAzure then
                pcall(function()
                    if Workspace:FindFirstChild("AttachedAzureEmber") then
                        Tween(Workspace:WaitForChild("EmberTemplate"):FindFirstChild("Part").CFrame);
                    end
                end);
            end
        end
    end);
end
Tabs.Sea:AddButton({
    Title = "Đổi Linh Hồn Xanh",
    Description = "",
    Callback = function()
        ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/KitsuneStatuePray"):InvokeServer();
    end
});
if Sea3 then
    local sectionSeaEvent = Tabs.Sea:AddSection("Biển");
    local ws = Players;
    local service = RunService;
    local root = VirtualInputManager;
    local WorkspaceService = Workspace;
    local map = 350;
    local paraSeaEvent = Tabs.Sea:AddSlider("SliderSpeedBoat", {
        Title = "Tốc Độ Thuyền",
        Description = "",
        Default = map,
        Min = 0,
        Max = 350,
        Rounding = 1,
        Callback = function(mapSelection)
            map = mapSelection;
        end
    });
    paraSeaEvent:SetValue(map);
    local toggleFindPrehistoric = Tabs.Sea:AddToggle("AutoFindPrehistoric", {
        Title = "Tìm Đảo Dung Nham",
        Description = "",
        Default = false
    });
    Options.AutoFindPrehistoric:SetValue(false);
    toggleFindPrehistoric:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        _G.AutoFindPrehistoric = value;
    end);
    local boatList = {};
    local isProcessing = false;
    local hasFound = false;
    service.RenderStepped:Connect(function()
        if not _G.AutoFindPrehistoric then
            hasFound = false;
            return;
        end
        local prehistoricPlayer = ws.LocalPlayer;
        local ability = prehistoricPlayer.Character;
        if (not ability or not ability:FindFirstChild("Humanoid")) then
            return;
        end
        local function disableBoatCollision()
            if isProcessing then
                return;
            end
            isProcessing = true;
            for idx, boatName in pairs(boatList) do
                if (boatName and enemy.Parent and (enemy.Name == "VehicleSeat") and not boatName.Occupant) then
                    Tween(boatName.CFrame, true);
                    break;
                end
            end
            isProcessing = false;
        end
        local prehistoricHumanoid = ability.Humanoid;
        local foundPrehistoricBoat = false;
        local haki = nil;
        for _, child in pairs(WorkspaceService.Boats:GetChildren()) do
            local boat = boatObj:FindFirstChild("VehicleSeat");
            if (boat and (boat.Occupant == prehistoricHumanoid)) then
                foundPrehistoricBoat = true;
                haki = boat;
                boatList[boatObj.Name] = boat;
            elseif (boat and (boat.Occupant == nil)) then
                disableBoatCollision();
            end
        end
        if not foundPrehistoricBoat then
            return;
        end
        haki.MaxSpeed = map;
        haki.CFrame = CFrame.new(Vector3.new(haki.Position.X, haki.Position.Y, haki.Position.Z)) * haki.CFrame.Rotation ;
        root:SendKeyEvent(true, "W", false, game);
        for _, descendant in pairs(WorkspaceService.Boats:GetDescendants()) do
            if boatPart:IsA("BasePart") then
                boatPart.CanCollide = false;
            end
        end
        for _, descendant in pairs(ability:GetDescendants()) do
            if boatPart2:IsA("BasePart") then
                boatPart2.CanCollide = false;
            end
        end
        local prehistoricIslandNames = {
            "ShipwreckIsland",
            "SandIsland",
            "TreeIsland",
            "TinyIsland",
            "MysticIsland",
            "KitsuneIsland",
            "FrozenDimension"
        };
        for _, item in ipairs(prehistoricIslandNames) do
            local prehistoricMapObj = WorkspaceService.Map:FindFirstChild(islandNameItem);
            if (prehistoricMapObj and prehistoricMapObj:IsA("Model")) then
                prehistoricMapObj:Destroy();
            end
        end
        local shouldFindBoat = WorkspaceService.Map:FindFirstChild("PrehistoricIsland");
        if shouldFindBoat then
            root:SendKeyEvent(false, "W", false, game);
            _G.AutoFindPrehistoric = false;
            if not hasFound then
                Fluent:Notify({
                    Title = "Min Gaming",
                    Content = "Đảo Dung Nham Tìm Thấy",
                    Duration = 10
                });
                hasFound = true;
            end
            return;
        end
    end);
    local toggleFindMirage = Tabs.Sea:AddToggle("AutoFindMirage", {
        Title = "Tìm Đảo Bí Ẩn",
        Description = "",
        Default = false
    });
    Options.AutoFindMirage:SetValue(false);
    toggleFindMirage:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        _G.AutoFindMirage = value;
    end);
    local boatList = {};
    local isProcessing = false;
    local hasFound = false;
    service.RenderStepped:Connect(function()
        if not _G.AutoFindMirage then
            hasFound = false;
            return;
        end
        local miragePlayer = ws.LocalPlayer;
        local equipped = miragePlayer.Character;
        if (not equipped or not equipped:FindFirstChild("Humanoid")) then
            return;
        end
        local function disableMirageBoatCollision()
            if isProcessing then
                return;
            end
            isProcessing = true;
            for _, boatEntry in pairs(boatList) do
                if (boatEntry and enemy.Parent and (enemy.Name == "VehicleSeat") and not boatEntry.Occupant) then
                    Tween(boatEntry.CFrame, true);
                    break;
                end
            end
            isProcessing = false;
        end
        local mirageHumanoid = equipped.Humanoid;
        local foundMirageBoat = false;
        local tool = nil;
        for _, child in pairs(WorkspaceService.Boats:GetChildren()) do
            local raid = mirageBoatChild:FindFirstChild("VehicleSeat");
            if (raid and (raid.Occupant == mirageHumanoid)) then
                foundMirageBoat = true;
                tool = raid;
                boatList[mirageBoatChild.Name] = raid;
            elseif (raid and (raid.Occupant == nil)) then
                disableMirageBoatCollision();
            end
        end
        if not foundMirageBoat then
            return;
        end
        tool.MaxSpeed = map;
        tool.CFrame = CFrame.new(Vector3.new(tool.Position.X, tool.Position.Y, tool.Position.Z)) * tool.CFrame.Rotation ;
        root:SendKeyEvent(true, "W", false, game);
        for _, descendant in pairs(WorkspaceService.Boats:GetDescendants()) do
            if mirageBoatPart:IsA("BasePart") then
                mirageBoatPart.CanCollide = false;
            end
        end
        for _, descendant in pairs(equipped:GetDescendants()) do
            if mirageBoatPart2:IsA("BasePart") then
                mirageBoatPart2.CanCollide = false;
            end
        end
        local mirageIslandNames = {
            "ShipwreckIsland",
            "SandIsland",
            "TreeIsland",
            "TinyIsland",
            "PrehistoricIsland",
            "KitsuneIsland",
            "FrozenDimension"
        };
        for _, item in ipairs(mirageIslandNames) do
            local mirageMapObj = WorkspaceService.Map:FindFirstChild(mirageIslandItem);
            if (mirageMapObj and mirageMapObj:IsA("Model")) then
                mirageMapObj:Destroy();
            end
        end
        local shouldFindBoat2 = WorkspaceService.Map:FindFirstChild("MysticIsland");
        if shouldFindBoat2 then
            root:SendKeyEvent(false, "W", false, game);
            _G.AutoFindMirage = false;
            if not hasFound then
                Fluent:Notify({
                    Title = "Min Gaming",
                    Content = "Đảo Bí Ẩn Tìm Thấy",
                    Duration = 10
                });
                hasFound = true;
            end
            return;
        end
    end);
    local toggleFindFrozen = Tabs.Sea:AddToggle("AutoFindFrozen", {
        Title = "Tìm Đảo Leviathan",
        Description = "Cần 5 Người Không Idk",
        Default = false
    });
    Options.AutoFindFrozen:SetValue(false);
    toggleFindFrozen:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        _G.AutoFindFrozen = value;
    end);
    local boatList = {};
    local isProcessing = false;
    local hasFound = false;
    service.RenderStepped:Connect(function()
        if not _G.AutoFindFrozen then
            hasFound = false;
            return;
        end
        local frozenPlayer = ws.LocalPlayer;
        local selected = frozenPlayer.Character;
        if (not selected or not selected:FindFirstChild("Humanoid")) then
            return;
        end
        local function disableFrozenBoatCollision()
            if isProcessing then
                return;
            end
            isProcessing = true;
            for _, boatEntry2 in pairs(boatList) do
                if (boatEntry2 and enemy.Parent and (enemy.Name == "VehicleSeat") and not boatEntry2.Occupant) then
                    Tween(boatEntry2.CFrame, true);
                    break;
                end
            end
            isProcessing = false;
        end
        local frozenHumanoid = selected.Humanoid;
        local foundFrozenBoat = false;
        local weapon = nil;
        for _, child in pairs(WorkspaceService.Boats:GetChildren()) do
            local boss = frozenBoatChild:FindFirstChild("VehicleSeat");
            if (boss and (boss.Occupant == frozenHumanoid)) then
                foundFrozenBoat = true;
                weapon = boss;
                boatList[frozenBoatChild.Name] = boss;
            elseif (boss and (boss.Occupant == nil)) then
                disableFrozenBoatCollision();
            end
        end
        if not foundFrozenBoat then
            return;
        end
        weapon.MaxSpeed = map;
        weapon.CFrame = CFrame.new(Vector3.new(weapon.Position.X, weapon.Position.Y, weapon.Position.Z)) * weapon.CFrame.Rotation ;
        root:SendKeyEvent(true, "W", false, game);
        for _, descendant in pairs(WorkspaceService.Boats:GetDescendants()) do
            if frozenBoatPart:IsA("BasePart") then
                frozenBoatPart.CanCollide = false;
            end
        end
        for _, descendant in pairs(selected:GetDescendants()) do
            if frozenBoatPart2:IsA("BasePart") then
                frozenBoatPart2.CanCollide = false;
            end
        end
        local frozenIslandNames = {
            "ShipwreckIsland",
            "SandIsland",
            "TreeIsland",
            "TinyIsland",
            "MysticIsland",
            "KitsuneIsland",
            "PrehistoricIsland"
        };
        for _, item in ipairs(frozenIslandNames) do
            local shipBoatChild = WorkspaceService.Map:FindFirstChild(frozenIslandItem);
            if (shipBoatChild and shipBoatChild:IsA("Model")) then
                shipBoatChild:Destroy();
            end
        end
        local shouldFindBoat3 = WorkspaceService.Map:FindFirstChild("FrozenDimension");
        if shouldFindBoat3 then
            root:SendKeyEvent(false, "W", false, game);
            _G.AutoFindFrozen = false;
            if not hasFound then
                Fluent:Notify({
                    Title = "Min Gaming",
                    Content = "Đảo Leviathan Tìm Thấy",
                    Duration = 10
                });
                hasFound = true;
            end
            return;
        end
    end);
    local toggleComeKitsune = Tabs.Sea:AddToggle("AutoComeTiki", {
        Title = "Lái Thuyền Về Đảo Tiki",
        Description = "",
        Default = false
    });
    toggleComeKitsune:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        _G.AutoComeTiki = value;
    end);
    service.RenderStepped:Connect(function()
        if not _G.AutoComeTiki then
            return;
        end
        local hydraPlayer = ws.LocalPlayer;
        local hydraChar = hydraPlayer.Character;
        if (not hydraChar or not hydraChar:FindFirstChild("Humanoid")) then
            return;
        end
        local hydraHumanoid = hydraChar.Humanoid;
        local mob = nil;
        for _, child in pairs(WorkspaceService.Boats:GetChildren()) do
            local shipBoatSeat = child:FindFirstChild("VehicleSeat");
            if (shipBoatSeat and (shipBoatSeat.Occupant == hydraHumanoid)) then
                mob = shipBoatSeat;
                break;
            end
        end
        if mob then
            mob.MaxSpeed = map;
            local boatDir = CFrame.new(- 16217.7568359375, 9.126761436462402, 446.06536865234375);
            local seatPos = mob.Position;
            local model = boatDir.Position;
            local boatMovePos = (model - seatPos).unit;
            local boatLookTarget = boatMovePos * mob.MaxSpeed * service.RenderStepped:Wait() ;
            mob.CFrame = mob.CFrame + boatLookTarget ;
            local lookCFrame = CFrame.new(seatPos, model);
            mob.CFrame = CFrame.new(mob.Position, model);
            if ((mob.Position - model).magnitude < 120) then
                _G.AutoComeTiki = false;
                root:SendKeyEvent(false, "W", false, game);
            end
        end
    end);
    local toggleComeHydra = Tabs.Sea:AddToggle("AutoComeHydra", {
        Title = "Lái Thuyền Về Đảo Hydra",
        Description = "",
        Default = false
    });
    toggleComeHydra:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        _G.AutoComeHydra = value;
    end);
    service.RenderStepped:Connect(function()
        if not _G.AutoComeHydra then
            return;
        end
        local seaLocalPlayer = ws.LocalPlayer;
        local seaCharacter = seaLocalPlayer.Character;
        if (not seaCharacter or not seaCharacter:FindFirstChild("Humanoid")) then
            return;
        end
        local seaHumanoid = seaCharacter.Humanoid;
        local target = nil;
        for _, child in pairs(WorkspaceService.Boats:GetChildren()) do
            local vehicleSeat = child:FindFirstChild("VehicleSeat");
            if (vehicleSeat and (vehicleSeat.Occupant == seaHumanoid)) then
                target = vehicleSeat;
                break;
            end
        end
        if target then
            target.MaxSpeed = map;
            local hydraTargetCFrame = CFrame.new(5193.9375, - 0.04690289497375488, 1631.578369140625);
            local hydraTargetPos = target.Position;
            local desc = hydraTargetCFrame.Position;
            local hydraDir = (desc - hydraTargetPos).unit;
            local hydraStep = hydraDir * target.MaxSpeed * service.RenderStepped:Wait() ;
            target.CFrame = target.CFrame + hydraStep ;
            local hydraLookCF = CFrame.new(hydraTargetPos, desc);
            target.CFrame = CFrame.new(target.Position, desc);
            if ((target.Position - desc).magnitude < 120) then
                _G.AutoComeHydra = false;
                root:SendKeyEvent(false, "W", false, game);
            end
        end
    end);
    Tabs.Sea:AddButton({
        Title = "Bay Đến Khu Vực Săn",
        Description = "",
        Callback = function()
            _G.StopTween = false;
            Tween(CFrame.new(- 16917.154296875, 7.757596015930176, 511.8203125), true);
        end
    });
    local boatList = {};
    local boatListData = {
        "Beast Hunter",
        "Sleigh",
        "Miracle",
        "The Sentinel",
        "Guardian",
        "Lantern",
        "Dinghy",
        "PirateSloop",
        "PirateBrigade",
        "PirateGrandBrigade",
        "MarineGrandBrigade",
        "MarineBrigade",
        "MarineSloop"
    };
    local dropdownBoat = Tabs.Sea:AddDropdown("DropdownBoat", {
        Title = "Chọn Thuyền",
        Description = "",
        Values = boatListData,
        Multi = false,
        Default = 1
    });
    dropdownBoat:SetValue(selectedBoat);
    dropdownBoat:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        selectedBoat = value;
    end);
    local function sectionSeaMobs(selectedBoatName)
        local buyBoatArgs = {
            [1] = "BuyBoat",
            [2] = value
        };
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(buyBoatArgs));
        task.delay(2, function()
            for _, child in pairs(WorkspaceService.Boats:GetChildren()) do
                if (ownedBoat:IsA("Model") and (enemy.Name == selectedBoatName)) then
                    local ownedBoatSeat = ownedBoat:FindFirstChild("VehicleSeat");
                    if (ownedBoatSeat and not ownedBoatSeat.Occupant) then
                        boatList[selectedBoatName] = ownedBoatSeat;
                    end
                end
            end
        end);
    end
    local function paraSeaMobs()
        for _, boatCheck1 in pairs(boatList) do
            if (boatCheck1 and enemy.Parent and (enemy.Name == "VehicleSeat") and not boatCheck1.Occupant) then
                Tween(boatCheck1.CFrame, true);
            end
        end
    end
    RunService.RenderStepped:Connect(function()
        for _, boatCheck2 in pairs(boatList) do
            if (boatCheck2 and enemy.Parent and (enemy.Name == "VehicleSeat") and not boatCheck2.Occupant) then
                boatList[ghostBoatName] = boatCheck2;
            end
        end
    end);
    Tabs.Sea:AddButton({
        Title = "Mua Thuyền",
        Description = "",
        Callback = function()
            sectionSeaMobs(selectedBoat);
        end
    });
    Tabs.Sea:AddButton({
        Title = "Bay Đến Thuyền",
        Description = "Duy Nhất Thuyền Bạn Mua Ở Chỗ Chọn",
        Callback = function()
            paraSeaMobs();
        end
    });
    local toggleTerrorshark = Tabs.Sea:AddToggle("ToggleTerrorshark", {
        Title = "Đấm Cá Mập",
        Description = "",
        Default = false
    });
    toggleTerrorshark:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        if value == false then
            CancelTween()
        end
        _G.AutoTerrorshark = value;
    end);
    Options.ToggleTerrorshark:SetValue(false);
    spawn(function()
        while wait() do
            if _G.AutoTerrorshark then
                pcall(function()
                    if Workspace.Enemies:FindFirstChild("Terrorshark") then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if (enemy.Name == "Terrorshark") then
                                if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                                    repeat
                                        wait(_G.Fast_Delay);
                                        AttackNoCoolDown();
                                        AutoHaki();
                                        EquipTool(SelectWeapon);
                                        enemy.HumanoidRootPart.CanCollide = false;
                                        enemy.Humanoid.WalkSpeed = 0;
                                        enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                        Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    until not _G.AutoTerrorshark or not enemy.Parent or (enemy.Humanoid.Health <= 0)
                                end
                            end
                        end
                    elseif ReplicatedStorage:FindFirstChild("Terrorshark") then
                        Tween(ReplicatedStorage:FindFirstChild("Terrorshark").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2));
                    else
                    end
                end);
            end
        end
    end);
    local togglePiranha = Tabs.Sea:AddToggle("TogglePiranha", {
        Title = "Đấm Piranha",
        Description = "",
        Default = false
    });
    togglePiranha:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        if value == false then
            CancelTween()
        end
        _G.farmpiranya = value;
    end);
    Options.TogglePiranha:SetValue(false);
    spawn(function()
        while wait() do
            if _G.farmpiranya then
                pcall(function()
                    if Workspace.Enemies:FindFirstChild("Piranha") then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if (enemy.Name == "Piranha") then
                                if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                                    repeat
                                        wait(_G.Fast_Delay);
                                        AttackNoCoolDown();
                                        AutoHaki();
                                        EquipTool(SelectWeapon);
                                        enemy.HumanoidRootPart.CanCollide = false;
                                        enemy.Humanoid.WalkSpeed = 0;
                                        enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                        Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    until not _G.farmpiranya or not enemy.Parent or (enemy.Humanoid.Health <= 0)
                                end
                            end
                        end
                    elseif ReplicatedStorage:FindFirstChild("Piranha") then
                        Tween(ReplicatedStorage:FindFirstChild("Piranha").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2));
                    else
                    end
                end);
            end
        end
    end);
    local toggleShark = Tabs.Sea:AddToggle("ToggleShark", {
        Title = "Đấm Cá Con",
        Description = "",
        Default = false
    });
    toggleShark:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        if value == false then
            CancelTween()
        end
        _G.AutoShark = value;
    end);
    Options.ToggleShark:SetValue(false);
    spawn(function()
        while wait() do
            if _G.AutoShark then
                pcall(function()
                    if Workspace.Enemies:FindFirstChild("Shark") then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if (enemy.Name == "Shark") then
                                if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                                    repeat
                                        wait(_G.Fast_Delay);
                                        AttackNoCoolDown();
                                        AutoHaki();
                                        EquipTool(SelectWeapon);
                                        enemy.HumanoidRootPart.CanCollide = false;
                                        enemy.Humanoid.WalkSpeed = 0;
                                        enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                        Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                        plr.Character.Humanoid.Sit = false;
                                    until not _G.AutoShark or not enemy.Parent or (enemy.Humanoid.Health <= 0)
                                end
                            end
                        end
                    else
                        Tween(Workspace.Boats.PirateGrandBrigade.VehicleSeat.CFrame * CFrame.new(0, 1, 0));
                        if ReplicatedStorage:FindFirstChild("Terrorshark") then
                            Tween(ReplicatedStorage:FindFirstChild("Terrorshark").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2));
                        else
                        end
                    end
                end);
            end
        end
    end);
    local toggleFishCrew = Tabs.Sea:AddToggle("ToggleFishCrew", {
        Title = "Đấm Tàu Cá",
        Description = "",
        Default = false
    });
    toggleFishCrew:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        if value == false then
            CancelTween()
        end
        _G.AutoFishCrew = value;
    end);
    Options.ToggleFishCrew:SetValue(false);
    spawn(function()
        while wait() do
            if _G.AutoFishCrew then
                pcall(function()
                    if Workspace.Enemies:FindFirstChild("Fish Crew Member") then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if (enemy.Name == "Fish Crew Member") then
                                if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                                    repeat
                                        wait(_G.Fast_Delay);
                                        AttackNoCoolDown();
                                        AutoHaki();
                                        EquipTool(SelectWeapon);
                                        enemy.HumanoidRootPart.CanCollide = false;
                                        enemy.Humanoid.WalkSpeed = 0;
                                        enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                        Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                        plr.Character.Humanoid.Sit = false;
                                    until not _G.AutoFishCrew or not enemy.Parent or (enemy.Humanoid.Health <= 0)
                                end
                            end
                        end
                    else
                        Tween(Workspace.Boats.PirateGrandBrigade.VehicleSeat.CFrame * CFrame.new(0, 1, 0));
                        if ReplicatedStorage:FindFirstChild("Fish Crew Member") then
                            Tween(ReplicatedStorage:FindFirstChild("Fish Crew Member").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2));
                        else
                        end
                    end
                end);
            end
        end
    end);
    local toggleShip = Tabs.Sea:AddToggle("ToggleShip", {
        Title = "Đấm Tàu",
        Description = "",
        Default = false
    });
    toggleShip:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        if value == false then
            CancelTween()
        end
        _G.Ship = value;
    end);
    Options.ToggleShip:SetValue(false);
    function CheckPirateBoat()
        local shipEnemyNames = {
            "PirateGrandBrigade",
            "PirateBrigade"
        };
        for shipEnemyIdx, enemyRoot in next, Workspace.Enemies:GetChildren() do
            if (table.find(shipEnemyNames, enemyRoot.Name) and enemyRoot:FindFirstChild("Health") and (enemyRoot.Health.Value > 0)) then
                return enemyRoot;
            end
        end
    end
    spawn(function()
        while wait() do
            if _G.Ship then
                pcall(function()
                    if CheckPirateBoat() then
                        VirtualInputManager:SendKeyEvent(true, 32, false, game);
                        wait(0.5);
                        VirtualInputManager:SendKeyEvent(false, 32, false, game);
                        local pirateBoatCheck = CheckPirateBoat();
                        repeat
                            wait();
                            spawn(Tween(pirateBoatCheck.Engine.CFrame * CFrame.new(0, - 20, 0)), 1);
                            AimBotSkillPosition = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, - 5, 0) ;
                            Skillaimbot = true;
                            AutoSkill = false;
                        until not pirateBoatCheck or not pirateBoatCheck.Parent or (pirateBoatCheck.Health.Value <= 0) or not CheckPirateBoat()
                        Skillaimbot = true;
                        AutoSkill = false;
                    end
                end);
            end
        end
    end);
    local toggleGhostShip = Tabs.Sea:AddToggle("ToggleGhostShip", {
        Title = "Đấm Tàu Ma",
        Description = "",
        Default = false
    });
    toggleGhostShip:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        if value == false then
            CancelTween()
        end
        _G.GhostShip = value;
    end);
    Options.ToggleGhostShip:SetValue(false);
    function CheckGhostShip()
        local ghostShipNames = {
            "FishBoat"
        };
        for ghostEnemyIdx, enemyHum in next, Workspace.Enemies:GetChildren() do
            if (table.find(ghostShipNames, enemyHum.Name) and enemyHum:FindFirstChild("Health") and (enemyHum.Health.Value > 0)) then
                return enemyHum;
            end
        end
    end
    spawn(function()
        while wait() do
            pcall(function()
                if _G.bjirFishBoat then
                    if CheckGhostShip() then
                        VirtualInputManager:SendKeyEvent(true, 32, false, game);
                        wait();
                        VirtualInputManager:SendKeyEvent(false, 32, false, game);
                        local ghostBoatCheck = CheckGhostShip();
                        repeat
                            wait();
                            spawn(Tween(ghostBoatCheck.Engine.CFrame * CFrame.new(0, - 20, 0), 1));
                            AutoSkill = true;
                            Skillaimbot = true;
                            AimBotSkillPosition = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, - 5, 0) ;
                        until not ghostBoatCheck.Parent or (ghostBoatCheck.Health.Value <= 0) or not CheckGhostShip()
                        AutoSkill = false;
                        Skillaimbot = false;
                    end
                end
            end);
        end
    end);
    spawn(function()
        while wait() do
            if _G.bjirFishBoat then
                pcall(function()
                    if CheckGhostShip() then
                        AutoHaki();
                        VirtualUser:CaptureController();
                        VirtualUser:Button1Down(Vector2.new(1280, 672));
                        for _, tool in pairs(plr.Backpack:GetChildren()) do
                            if tool:IsA("Tool") then
                                if (tool.ToolTip == "Melee") then
                                    plr.Character.Humanoid:EquipTool(tool);
                                end
                            end
                        end
                        VirtualInputManager:SendKeyEvent(true, 122, false, plr.Character.HumanoidRootPart);
                        VirtualInputManager:SendKeyEvent(false, 122, false, plr.Character.HumanoidRootPart);
                        wait(0.2);
                        VirtualInputManager:SendKeyEvent(true, 120, false, plr.Character.HumanoidRootPart);
                        VirtualInputManager:SendKeyEvent(false, 120, false, plr.Character.HumanoidRootPart);
                        wait(0.2);
                        VirtualInputManager:SendKeyEvent(true, 99, false, plr.Character.HumanoidRootPart);
                        VirtualInputManager:SendKeyEvent(false, 99, false, plr.Character.HumanoidRootPart);
                        wait(0.2);
                        VirtualInputManager:SendKeyEvent(false, "C", false, plr.Character.HumanoidRootPart);
                        for _, tool in pairs(plr.Backpack:GetChildren()) do
                            if tool:IsA("Tool") then
                                if (tool.ToolTip == "Blox Fruit") then
                                    plr.Character.Humanoid:EquipTool(tool);
                                end
                            end
                        end
                        VirtualInputManager:SendKeyEvent(true, 122, false, plr.Character.HumanoidRootPart);
                        VirtualInputManager:SendKeyEvent(false, 122, false, plr.Character.HumanoidRootPart);
                        wait(0.2);
                        VirtualInputManager:SendKeyEvent(true, 120, false, plr.Character.HumanoidRootPart);
                        VirtualInputManager:SendKeyEvent(false, 120, false, plr.Character.HumanoidRootPart);
                        wait(0.2);
                        VirtualInputManager:SendKeyEvent(true, 99, false, plr.Character.HumanoidRootPart);
                        VirtualInputManager:SendKeyEvent(false, 99, false, plr.Character.HumanoidRootPart);
                        wait(0.2);
                        VirtualInputManager:SendKeyEvent(true, "V", false, plr.Character.HumanoidRootPart);
                        VirtualInputManager:SendKeyEvent(false, "V", false, plr.Character.HumanoidRootPart);
                        wait();
                        for _, tool in pairs(plr.Backpack:GetChildren()) do
                            if tool:IsA("Tool") then
                                if (tool.ToolTip == "Sword") then
                                    plr.Character.Humanoid:EquipTool(tool);
                                end
                            end
                        end
                        VirtualInputManager:SendKeyEvent(true, 122, false, plr.Character.HumanoidRootPart);
                        VirtualInputManager:SendKeyEvent(false, 122, false, plr.Character.HumanoidRootPart);
                        wait(0.2);
                        VirtualInputManager:SendKeyEvent(true, 120, false, plr.Character.HumanoidRootPart);
                        VirtualInputManager:SendKeyEvent(false, 120, false, plr.Character.HumanoidRootPart);
                        wait(0.2);
                        VirtualInputManager:SendKeyEvent(true, 99, false, plr.Character.HumanoidRootPart);
                        VirtualInputManager:SendKeyEvent(false, 99, false, plr.Character.HumanoidRootPart);
                        wait();
                        for _, tool in pairs(plr.Backpack:GetChildren()) do
                            if tool:IsA("Tool") then
                                if (tool.ToolTip == "Gun") then
                                    plr.Character.Humanoid:EquipTool(tool);
                                end
                            end
                        end
                        VirtualInputManager:SendKeyEvent(true, 122, false, plr.Character.HumanoidRootPart);
                        VirtualInputManager:SendKeyEvent(false, 122, false, plr.Character.HumanoidRootPart);
                        wait(0.2);
                        VirtualInputManager:SendKeyEvent(true, 120, false, plr.Character.HumanoidRootPart);
                        VirtualInputManager:SendKeyEvent(false, 120, false, plr.Character.HumanoidRootPart);
                        wait(0.2);
                        VirtualInputManager:SendKeyEvent(true, 99, false, plr.Character.HumanoidRootPart);
                        VirtualInputManager:SendKeyEvent(false, 99, false, plr.Character.HumanoidRootPart);
                    end
                end);
            end
        end
    end);
    local sectionElite = Tabs.Main:AddSection("Elite");
    local paraElite = Tabs.Main:AddParagraph({
        Title = "Trạng Thái Elite",
        Content = ""
    });
    spawn(function()
        while wait() do
            pcall(function()
                if (ReplicatedStorage:FindFirstChild("Diablo") or ReplicatedStorage:FindFirstChild("Deandre") or ReplicatedStorage:FindFirstChild("Urban") or Workspace.Enemies:FindFirstChild("Diablo") or Workspace.Enemies:FindFirstChild("Deandre") or Workspace.Enemies:FindFirstChild("Urban")) then
                    paraElite:SetDesc("Elite Boss: 🟢 | Killed:  " .. ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter", "Progress"));
                else
                    paraElite:SetDesc("Elite Boss: 🔴 | Killed: " .. ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter", "Progress"));
                end
            end);
        end
    end);
    local toggleElite = Tabs.Main:AddToggle("ToggleElite", {
        Title = "Đấm Elite",
        Description = "",
        Default = false
    });
    toggleElite:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        _G.AutoElite = value;
    end);
    Options.ToggleElite:SetValue(false);
    spawn(function()
        while task.wait() do
            if _G.AutoElite then
                pcall(function()
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter");
                    if (plr.PlayerGui.Main.Quest.Visible == true) then
                        if (string.find(plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "Diablo") or string.find(plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "Deandre") or string.find(plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "Urban")) then
                            if (Workspace.Enemies:FindFirstChild("Diablo") or Workspace.Enemies:FindFirstChild("Deandre") or Workspace.Enemies:FindFirstChild("Urban")) then
                                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                                    if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                                        if ((enemy.Name == "Diablo") or (enemy.Name == "Deandre") or (enemy.Name == "Urban")) then
                                            repeat
                                                wait(_G.Fast_Delay);
                                                AttackNoCoolDown();
                                                EquipTool(SelectWeapon);
                                                AutoHaki();
                                                Tween(enemy.HumanoidRootPart.CFrame * Pos, true);
                                                enemy.Humanoid.WalkSpeed = 0;
                                                enemy.HumanoidRootPart.CanCollide = false;
                                                enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                            until (_G.AutoElite == false) or (enemy.Humanoid.Health <= 0) or not enemy.Parent
                                        end
                                    end
                                end
                            elseif ReplicatedStorage:FindFirstChild("Diablo") then
                                Tween(ReplicatedStorage:FindFirstChild("Diablo").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2), true);
                            elseif ReplicatedStorage:FindFirstChild("Deandre") then
                                Tween(ReplicatedStorage:FindFirstChild("Deandre").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2), true);
                            elseif ReplicatedStorage:FindFirstChild("Urban") then
                                Tween(ReplicatedStorage:FindFirstChild("Urban").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2), true);
                            end
                        end
                    else
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter");
                    end
                end);
            end
        end
    end);
end
if Sea3 then
    local sectionMirage = Tabs.Sea:AddSection("Đảo Bí Ẩn");
    local paraMirage = Tabs.Sea:AddParagraph({
        Title = "Trạng Thái",
        Content = ""
    });
    task.spawn(function()
        while task.wait() do
            pcall(function()
                local childObj = Lighting.Sky.MoonTextureId;
                if (childObj == "http://www.roblox.com/asset/?id=9709149431") then
                    FullMoonStatus = "100%";
                elseif (childObj == "http://www.roblox.com/asset/?id=9709149052") then
                    FullMoonStatus = "75%";
                elseif (childObj == "http://www.roblox.com/asset/?id=9709143733") then
                    FullMoonStatus = "50%";
                elseif (childObj == "http://www.roblox.com/asset/?id=9709150401") then
                    FullMoonStatus = "25%";
                elseif (childObj == "http://www.roblox.com/asset/?id=9709149680") then
                    FullMoonStatus = "15%";
                else
                    FullMoonStatus = "0%";
                end
            end);
        end
    end);
    task.spawn(function()
        while task.wait() do
            pcall(function()
                if Workspace.Map:FindFirstChild("MysticIsland") then
                    MirageStatus = "🟢";
                else
                    MirageStatus = "🔴";
                end
            end);
        end
    end);
    spawn(function()
        pcall(function()
            while wait() do
                paraMirage:SetDesc("Đảo Bí Ẩn: " .. MirageStatus .. " | Trăng Tròn: " .. FullMoonStatus);
            end
        end);
    end);
    Tabs.Sea:AddButton({
        Title = "Bay Đến Chỗ Cao",
        Description = "",
        Callback = function()
            _G.StopTween = false;
            TweenToHighestPoint();
        end
    });
    function TweenToHighestPoint()
        local highestPoint = getHighestPoint();
        if highestPoint then
            Tween(highestPoint.CFrame * CFrame.new(0, 211.88, 0), true);
        end
    end
    function getHighestPoint()
        if not Workspace.Map:FindFirstChild("MysticIsland") then
            return nil;
        end
        for _, mysticDescendant in pairs(Workspace.Map.MysticIsland:GetDescendants()) do
            if mysticDescendant:IsA("MeshPart") then
                if (mysticDescendant.MeshId == "rbxassetid://6745037796") then
                    return mysticDescendant;
                end
            end
        end
    end
end
local TweenAdvancedToggle = Tabs.Sea:AddToggle("ToggleTpAdvanced", {
    Title = "Bay Đến Advanced Fruit Dealer",
    Description = "",
    Default = false
});
TweenAdvancedToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoTpAdvanced = value;
end);
spawn(function()
    while wait() do
        if _G.AutoTpAdvanced then
            local enemyHRP = ReplicatedStorage.NPCs:FindFirstChild("Advanced Fruit Dealer");
            if (enemyHRP and enemyHRP:IsA("Model")) then
                local fruitDropPos = enemyHRP.PrimaryPart and enemyHRP.PrimaryPart.Position ;
                if fruitDropPos then
                    Tween(CFrame.new(fruitDropPos), true);
                end
            end
        end
    end
end);
local TweenGearToggle = Tabs.Sea:AddToggle("ToggleTweenGear", {
    Title = "Bay Đến Bánh Răng",
    Description = "",
    Default = false
});
TweenGearToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.TweenToGear = value;
end);
Options.ToggleTweenGear:SetValue(false);
spawn(function()
    pcall(function()
        while wait() do
            if _G.TweenToGear then
                if Workspace.Map:FindFirstChild("MysticIsland") then
                    for _, bossEnemy509 in pairs(Workspace.Map.MysticIsland:GetChildren()) do
                        if bossEnemy509:IsA("MeshPart") then
                            if (bossEnemy509.Material == Enum.Material.Neon) then
                                Tween(bossEnemy509.CFrame, true);
                            end
                        end
                    end
                end
            end
        end
    end);
end);
local LockMoonToggle = Tabs.Sea:AddToggle("Togglelockmoon", {
    Title = "Nhìn Trăng Và Dùng Tộc",
    Description = "",
    Default = false
});
LockMoonToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoLockMoon = value;
end);
Options.Togglelockmoon:SetValue(false);
spawn(function()
    while wait() do
        pcall(function()
            if _G.AutoLockMoon then
                local moonDirection = Lighting:GetMoonDirection();
                local moonLookPos = Workspace.CurrentCamera.CFrame.p + (moonDirection * 100) ;
                Workspace.CurrentCamera.CFrame = CFrame.lookAt(Workspace.CurrentCamera.CFrame.p, moonLookPos);
            end
        end);
    end
end);
spawn(function()
    while wait() do
        pcall(function()
            if _G.AutoLockMoon then
                ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility");
            end
        end);
    end
end);
local AutoSaberToggle = Tabs.ITM:AddToggle("ToggleAutoSaber", {
    Title = "Saber",
    Description = "",
    Default = false
});
AutoSaberToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.Auto_Saber = value;
end);
Options.ToggleAutoSaber:SetValue(false);
spawn(function()
    while task.wait() do
        if (_G.Auto_Saber and (plr.Data.Level.Value >= 200)) then
            pcall(function()
                if (Workspace.Map.Jungle.Final.Part.Transparency == 0) then
                    if (Workspace.Map.Jungle.QuestPlates.Door.Transparency == 0) then
                        if ((CFrame.new(- 1612.55884, 36.9774132, 148.719543, 0.37091279, 3.071715e-9, - 0.928667724, 3.970995e-8, 1, 1.9167935e-8, 0.928667724, - 4.398698e-8, 0.37091279).Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 100) then
                            Tween(plr.Character.HumanoidRootPart.CFrame);
                            wait(1);
                            plr.Character.HumanoidRootPart.CFrame = Workspace.Map.Jungle.QuestPlates.Plate1.Button.CFrame;
                            wait(1);
                            plr.Character.HumanoidRootPart.CFrame = Workspace.Map.Jungle.QuestPlates.Plate2.Button.CFrame;
                            wait(1);
                            plr.Character.HumanoidRootPart.CFrame = Workspace.Map.Jungle.QuestPlates.Plate3.Button.CFrame;
                            wait(1);
                            plr.Character.HumanoidRootPart.CFrame = Workspace.Map.Jungle.QuestPlates.Plate4.Button.CFrame;
                            wait(1);
                            plr.Character.HumanoidRootPart.CFrame = Workspace.Map.Jungle.QuestPlates.Plate5.Button.CFrame;
                            wait(1);
                        else
                            Tween(CFrame.new(- 1612.55884, 36.9774132, 148.719543, 0.37091279, 3.071715e-9, - 0.928667724, 3.970995e-8, 1, 1.9167935e-8, 0.928667724, - 4.398698e-8, 0.37091279));
                        end
                    elseif (Workspace.Map.Desert.Burn.Part.Transparency == 0) then
                        if (plr.Backpack:FindFirstChild("Torch") or plr.Character:FindFirstChild("Torch")) then
                            EquipTool("Torch");
                            Tween(CFrame.new(1114.61475, 5.04679728, 4350.22803, - 0.648466587, - 1.2879909e-9, 0.761243105, - 5.706529e-10, 1, 1.2058454e-9, - 0.761243105, 3.4754488e-10, - 0.648466587));
                        else
                            Tween(CFrame.new(- 1610.00757, 11.5049858, 164.001587, 0.984807551, - 0.167722285, - 0.0449818149, 0.17364943, 0.951244235, 0.254912198, 0.00003423728, - 0.258850515, 0.965917408));
                        end
                    elseif (ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "SickMan") ~= 0) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "GetCup");
                        wait(0.5);
                        EquipTool("Cup");
                        wait(0.5);
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "FillCup", plr.Character.Cup);
                        wait(0);
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "SickMan");
                    elseif (ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon") == nil) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon");
                    elseif (ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon") == 0) then
                        if (Workspace.Enemies:FindFirstChild("Mob Leader") or ReplicatedStorage:FindFirstChild("Mob Leader")) then
                            Tween(CFrame.new(- 2967.59521, - 4.91089821, 5328.70703, 0.342208564, - 0.0227849055, 0.939347804, 0.0251603816, 0.999569714, 0.0150796166, - 0.939287126, 0.0184739735, 0.342634559));
                            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                                if (enemy.Name == "Mob Leader") then
                                    if Workspace.Enemies:FindFirstChild("Mob Leader [Lv. 120] [Boss]") then
                                        if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                                            repeat
                                                task.wait(_G.Fast_Delay);
                                                AutoHaki();
                                                EquipTool(SelectWeapon);
                                                enemy.HumanoidRootPart.CanCollide = false;
                                                enemy.Humanoid.WalkSpeed = 0;
                                                enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                                Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                                AttackNoCoolDown();
                                            until (enemy.Humanoid.Health <= 0) or not _G.Auto_Saber
                                        end
                                    end
                                    if ReplicatedStorage:FindFirstChild("Mob Leader") then
                                        Tween(ReplicatedStorage:FindFirstChild("Mob Leader").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2));
                                    end
                                end
                            end
                        end
                    elseif (ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon") == 1) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "RichSon");
                        wait(0.5);
                        EquipTool("Relic");
                        wait(0.5);
                        Tween(CFrame.new(- 1404.91504, 29.9773273, 3.80598116, 0.876514494, 5.6690688e-9, 0.481375456, 2.53852e-8, 1, - 5.799956e-8, - 0.481375456, 6.3057264e-8, 0.876514494));
                    end
                elseif (Workspace.Enemies:FindFirstChild("Saber Expert") or ReplicatedStorage:FindFirstChild("Saber Expert")) then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if (varD:FindFirstChild("Humanoid") and varD:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                            if (enemy.Name == "Saber Expert") then
                                repeat
                                    task.wait(_G.Fast_Delay);
                                    EquipTool(SelectWeapon);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                    enemy.HumanoidRootPart.Transparency = 1;
                                    varD.Humanoid.JumpPower = 0;
                                    varD.Humanoid.WalkSpeed = 0;
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    bringmob = true;
                                    FarmPos = enemy.HumanoidRootPart.CFrame;
                                    MonFarm = varD.Name;
                                    AttackNoCoolDown();
                                until (enemy.Humanoid.Health <= 0) or not _G.Auto_Saber
                                bringmob = true;
                                if (enemy.Humanoid.Health <= 0) then
                                    ReplicatedStorage.Remotes.CommF_:InvokeServer("ProQuestProgress", "PlaceRelic");
                                end
                            end
                        end
                    end
                end
            end);
        end
    end
end);
local AutoPoleV1Toggle = Tabs.ITM:AddToggle("ToggleAutoPoleV1", {
    Title = "Pole V1",
    Description = "",
    Default = false
});
AutoPoleV1Toggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.Auto_PoleV1 = value;
end);
Options.ToggleAutoPoleV1:SetValue(false);
local targetCFrame = CFrame.new(- 7748.0185546875, 5606.80615234375, - 2305.898681640625);
spawn(function()
    while wait() do
        if _G.Auto_PoleV1 then
            pcall(function()
                if Workspace.Enemies:FindFirstChild("Thunder God") then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if (enemy.Name == "Thunder God") then
                            if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                                repeat
                                    task.wait(_G.Fast_Delay);
                                    AutoHaki();
                                    EquipTool(SelectWeapon);
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    enemy.Humanoid.WalkSpeed = 0;
                                    enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    AttackNoCoolDown();
                                until not _G.Auto_PoleV1 or not enemy.Parent or (enemy.Humanoid.Health <= 0)
                            end
                        end
                    end
                elseif ((plr.Character.HumanoidRootPart.Position - targetCF.Position).Magnitude < 1500) then
                    Tween(targetCF);
                end
                Tween(CFrame.new(- 7748.0185546875, 5606.80615234375, - 2305.898681640625));
                if ReplicatedStorage:FindFirstChild("Thunder God") then
                    Tween(ReplicatedStorage:FindFirstChild("Thunder God").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2));
                end
            end);
        end
    end
end);
local AutoSawToggle = Tabs.ITM:AddToggle("ToggleAutoSaw", {
    Title = "Cưa Cá Mập",
    Description = "",
    Default = false
});
AutoSawToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.Auto_Saw = value;
end);
Options.ToggleAutoSaw:SetValue(false);
local targetCFrame = CFrame.new(- 690.33081054688, 15.09425163269, 1582.2380371094);
spawn(function()
    while wait() do
        if _G.Auto_Saw then
            pcall(function()
                if Workspace.Enemies:FindFirstChild("The Saw") then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if (enemy.Name == "The Saw") then
                            if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                                repeat
                                    task.wait(_G.Fast_Delay);
                                    AutoHaki();
                                    EquipTool(SelectWeapon);
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    enemy.Humanoid.WalkSpeed = 0;
                                    enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    AttackNoCoolDown();
                                until not _G.Auto_Saw or not enemy.Parent or (enemy.Humanoid.Health <= 0)
                            end
                        end
                    end
                elseif ((plr.Character.HumanoidRootPart.Position - targetCF.Position).Magnitude < 1500) then
                    Tween(targetCF);
                end
                Tween(CFrame.new(- 690.33081054688, 15.09425163269, 1582.2380371094));
                if ReplicatedStorage:FindFirstChild("The Saw") then
                    Tween(ReplicatedStorage:FindFirstChild("The Saw").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2));
                end
            end);
        end
    end
end);
local AutoWardenToggle = Tabs.ITM:AddToggle("ToggleAutoWarden", {
    Title = "Kiếm Quản Ngục",
    Description = "",
    Default = false
});
AutoWardenToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.Auto_Warden = value;
end);
Options.ToggleAutoWarden:SetValue(false);
local targetCFrame = CFrame.new(5186.14697265625, 24.86684226989746, 832.1885375976562);
spawn(function()
    while wait() do
        if _G.Auto_Warden then
            pcall(function()
                if Workspace.Enemies:FindFirstChild("Chief Warden") then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if (enemy.Name == "Chief Warden") then
                            if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                                repeat
                                    task.wait(_G.Fast_Delay);
                                    AutoHaki();
                                    EquipTool(SelectWeapon);
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    enemy.Humanoid.WalkSpeed = 0;
                                    enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    AttackNoCoolDown();
                                until not _G.Auto_Warden or not enemy.Parent or (enemy.Humanoid.Health <= 0)
                            end
                        end
                    end
                elseif ((plr.Character.HumanoidRootPart.Position - uiUnused2.Position).Magnitude < 1500) then
                    Tween(uiUnused2);
                end
                Tween(CFrame.new(5186.14697265625, 24.86684226989746, 832.1885375976562));
                if ReplicatedStorage:FindFirstChild("Chief Warden") then
                    Tween(ReplicatedStorage:FindFirstChild("Chief Warden").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2));
                end
            end);
        end
    end
end);
if Sea3 then
    local toggleHallow = Tabs.ITM:AddToggle("ToggleHallow", {
        Title = "Lưỡi Hái",
        Description = "",
        Default = false
    });
    toggleHallow:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        if value == false then
            CancelTween()
        end
        AutoHallowSycthe = value;
    end);
    Options.ToggleHallow:SetValue(false);
    spawn(function()
        while wait() do
            if AutoHallowSycthe then
                pcall(function()
                    if Workspace.Enemies:FindFirstChild("Soul Reaper") then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if string.find(soulReaperObj.Name, "Soul Reaper") then
                                repeat
                                    wait(_G.Fast_Delay);
                                    AttackNoCoolDown();
                                    AutoHaki();
                                    EquipTool(SelectWeapon);
                                    enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    enemy.HumanoidRootPart.Transparency = 1;
                                    sethiddenproperty(plr, "SimulationRadius", math.huge);
                                until (enemy.Humanoid.Health <= 0) or (AutoHallowSycthe == false)
                            end
                        end
                    elseif (plr.Backpack:FindFirstChild("Hallow Essence") or plr.Character:FindFirstChild("Hallow Essence")) then
                        repeat
                            Tween(CFrame.new(- 8932.322265625, 146.83154296875, 6062.55078125));
                            wait();
                        until (CFrame.new(- 8932.322265625, 146.83154296875, 6062.55078125).Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 8
                        wait();
                        EquipTool("Hallow Essence");
                    elseif ReplicatedStorage:FindFirstChild("Soul Reaper") then
                        Tween(ReplicatedStorage:FindFirstChild("Soul Reaper").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2));
                    else
                    end
                end);
            end
        end
    end);
    spawn(function()
        while wait() do
            if AutoHallowSycthe then
                local hallowEssenceArgs = {
                    [1] = "Bones",
                    [2] = "Buy",
                    [3] = 1,
                    [4] = 1
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(hallowEssenceArgs));
            end
        end
    end);
    local toggleYama = Tabs.ITM:AddToggle("ToggleYama", {
        Title = "Yama",
        Description = "",
        Default = false
    });
    toggleYama:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        _G.AutoYama = value;
    end);
    Options.ToggleYama:SetValue(false);
    spawn(function()
        while wait() do
            if _G.AutoYama then
                if (ReplicatedStorage.Remotes.CommF_:InvokeServer("EliteHunter", "Progress") >= 30) then
                    repeat
                        wait();
                        fireclickdetector(Workspace.Map.Waterfall.SealedKatana.Handle.ClickDetector);
                    until plr.Backpack:FindFirstChild("Yama") or not _G.AutoYama
                end
            end
        end
    end);
    local toggleTushita = Tabs.ITM:AddToggle("ToggleTushita", {
        Title = "Tushita",
        Description = "",
        Default = false
    });
    toggleTushita:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        if value == false then
            CancelTween()
        end
        AutoTushita = value;
    end);
    Options.ToggleTushita:SetValue(false);
    spawn(function()
        while wait() do
            if AutoTushita then
                if Workspace.Enemies:FindFirstChild("Longma") then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if ((enemy.Name == ("Longma" or (enemy.Name == "Longma"))) and (enemy.Humanoid.Health > 0) and obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart")) then
                            repeat
                                wait(_G.Fast_Delay);
                                AttackNoCoolDown();
                                AutoHaki();
                                if not plr.Character:FindFirstChild(SelectWeapon) then
                                    wait();
                                    EquipTool(SelectWeapon);
                                end
                                FarmPos = enemy.HumanoidRootPart.CFrame;
                                enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                obj.Humanoid.JumpPower = 0;
                                obj.Humanoid.WalkSpeed = 0;
                                enemy.HumanoidRootPart.CanCollide = false;
                                obj.Humanoid:ChangeState(11);
                                Tween(enemy.HumanoidRootPart.CFrame * Pos);
                            until not AutoTushita or not enemy.Parent or (enemy.Humanoid.Health <= 0)
                        end
                    end
                else
                    Tween(CFrame.new(- 10238.875976563, 389.7912902832, - 9549.7939453125));
                end
            end
        end
    end);
    local toggleHoly = Tabs.ITM:AddToggle("ToggleHoly", {
        Title = "Đốt Đuốc",
        Description = "",
        Default = false
    });
    toggleHoly:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        if value == false then
            CancelTween()
        end
        _G.Auto_Holy_Torch = value;
    end);
    Options.ToggleHoly:SetValue(false);
    spawn(function()
        while wait() do
            if _G.Auto_Holy_Torch then
                pcall(function()
                    wait();
                    repeat
                        Tween(CFrame.new(- 10752, 417, - 9366));
                        wait();
                    until not _G.Auto_Holy_Torch or ((plr.Character.HumanoidRootPart.Position - Vector3.new(- 10752, 417, - 9366)).Magnitude <= 10)
                    wait();
                    repeat
                        Tween(CFrame.new(- 11672, 334, - 9474));
                        wait();
                    until not _G.Auto_Holy_Torch or ((plr.Character.HumanoidRootPart.Position - Vector3.new(- 11672, 334, - 9474)).Magnitude <= 10)
                    wait();
                    repeat
                        Tween(CFrame.new(- 12132, 521, - 10655));
                        wait();
                    until not _G.Auto_Holy_Torch or ((plr.Character.HumanoidRootPart.Position - Vector3.new(- 12132, 521, - 10655)).Magnitude <= 10)
                    wait();
                    repeat
                        Tween(CFrame.new(- 13336, 486, - 6985));
                        wait();
                    until not _G.Auto_Holy_Torch or ((plr.Character.HumanoidRootPart.Position - Vector3.new(- 13336, 486, - 6985)).Magnitude <= 10)
                    wait();
                    repeat
                        Tween(CFrame.new(- 13489, 332, - 7925));
                        wait();
                    until not _G.Auto_Holy_Torch or ((plr.Character.HumanoidRootPart.Position - Vector3.new(- 13489, 332, - 7925)).Magnitude <= 10)
                end);
            end
        end
    end);
end
local AutoCanvanderToggle = Tabs.ITM:AddToggle("ToggleAutoCanvander", {
    Title = "Canvander",
    Description = "",
    Default = false
});
AutoCanvanderToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.Auto_Canvander = value;
end);
Options.ToggleAutoCanvander:SetValue(false);
local targetCFrame = CFrame.new(5311.07421875, 426.0243835449219, 165.12762451171875);
spawn(function()
    while wait() do
        if _G.Auto_Canvander then
            pcall(function()
                if Workspace.Enemies:FindFirstChild("Beautiful Pirate") then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if (enemy.Name == "Beautiful Pirate") then
                            if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                                repeat
                                    task.wait(_G.Fast_Delay);
                                    AutoHaki();
                                    EquipTool(SelectWeapon);
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    enemy.Humanoid.WalkSpeed = 0;
                                    enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    AttackNoCoolDown();
                                until not _G.Auto_Canvander or not enemy.Parent or (enemy.Humanoid.Health <= 0)
                            end
                        end
                    end
                elseif ((plr.Character.HumanoidRootPart.Position - targetCF.Position).Magnitude < 1500) then
                    Tween(targetCF);
                end
                Tween(CFrame.new(5311.07421875, 426.0243835449219, 165.12762451171875));
                if ReplicatedStorage:FindFirstChild("Beautiful Pirate") then
                    Tween(ReplicatedStorage:FindFirstChild("Beautiful Pirate").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2));
                end
            end);
        end
    end
end);
local AutoMusketeerHatToggle = Tabs.ITM:AddToggle("ToggleAutoMusketeerHat", {
    Title = "Mũ Lính Ngự Lâm",
    Description = "",
    Default = false
});
AutoMusketeerHatToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.Auto_MusketeerHat = value;
end);
Options.ToggleAutoMusketeerHat:SetValue(false);
spawn(function()
    pcall(function()
        while wait(0.1) do
            if _G.Auto_MusketeerHat then
                if ((plr.Data.Level.Value >= 1800) and (ReplicatedStorage.Remotes.CommF_:InvokeServer("CitizenQuestProgress").KilledBandits == false)) then
                    if (string.find(plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "Forest Pirate") and string.find(plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "50") and (plr.PlayerGui.Main.Quest.Visible == true)) then
                        if Workspace.Enemies:FindFirstChild("Forest Pirate") then
                            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                                if (enemy.Name == "Forest Pirate") then
                                    repeat
                                        task.wait(_G.Fast_Delay);
                                        pcall(function()
                                            EquipTool(SelectWeapon);
                                            AutoHaki();
                                            enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                                            Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                            enemy.HumanoidRootPart.CanCollide = false;
                                            AttackNoCoolDown();
                                            PosMon = enemy.HumanoidRootPart.CFrame;
                                            MonFarm = farmTarget2.Name;
                                            bringmob = true;
                                        end);
                                    until (_G.Auto_MusketeerHat == false) or not enemy.Parent or (enemy.Humanoid.Health <= 0) or (plr.PlayerGui.Main.Quest.Visible == false)
                                    bringmob = false;
                                end
                            end
                        else
                            bringmob = false;
                            Tween(CFrame.new(- 13206.452148438, 425.89199829102, - 7964.5537109375));
                        end
                    else
                        Tween(CFrame.new(- 12443.8671875, 332.40396118164, - 7675.4892578125));
                        if ((Vector3.new(- 12443.8671875, 332.40396118164, - 7675.4892578125) - plr.Character.HumanoidRootPart.Position).Magnitude <= 30) then
                            wait(1.5);
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", "CitizenQuest", 1);
                        end
                    end
                elseif ((plr.Data.Level.Value >= 1800) and (ReplicatedStorage.Remotes.CommF_:InvokeServer("CitizenQuestProgress").KilledBoss == false)) then
                    if (plr.PlayerGui.Main.Quest.Visible and string.find(plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "Captain Elephant") and (plr.PlayerGui.Main.Quest.Visible == true)) then
                        if Workspace.Enemies:FindFirstChild("Captain Elephant") then
                            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                                if (enemy.Name == "Captain Elephant") then
                                    OldCFrameElephant = enemy.HumanoidRootPart.CFrame;
                                    repeat
                                        task.wait(_G.Fast_Delay);
                                        pcall(function()
                                            EquipTool(SelectWeapon);
                                            AutoHaki();
                                            enemy.HumanoidRootPart.CanCollide = false;
                                            enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                                            Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                            enemy.HumanoidRootPart.CanCollide = false;
                                            enemy.HumanoidRootPart.CFrame = OldCFrameElephant;
                                            AttackNoCoolDown();
                                        end);
                                    until (_G.Auto_MusketeerHat == false) or (enemy.Humanoid.Health <= 0) or not enemy.Parent or (plr.PlayerGui.Main.Quest.Visible == false)
                                end
                            end
                        else
                            Tween(CFrame.new(- 13374.889648438, 421.27752685547, - 8225.208984375));
                        end
                    else
                        Tween(CFrame.new(- 12443.8671875, 332.40396118164, - 7675.4892578125));
                        if ((CFrame.new(- 12443.8671875, 332.40396118164, - 7675.4892578125).Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 4) then
                            wait(1.5);
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("CitizenQuestProgress", "Citizen");
                        end
                    end
                elseif ((plr.Data.Level.Value >= 1800) and (ReplicatedStorage.Remotes.CommF_:InvokeServer("CitizenQuestProgress", "Citizen") == 2)) then
                    Tween(CFrame.new(- 12512.138671875, 340.39279174805, - 9872.8203125));
                end
            end
        end
    end);
end);
local AutoObservationV2Toggle = Tabs.ITM:AddToggle("ToggleAutoObservationV2", {
    Title = "Haki Quan Sát V2",
    Description = "",
    Default = false
});
AutoObservationV2Toggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.Auto_ObservationV2 = value;
end);
Options.ToggleAutoObservationV2:SetValue(false);
spawn(function()
    while wait() do
        pcall(function()
            if _G.Auto_ObservationV2 then
                if (ReplicatedStorage.Remotes.CommF_:InvokeServer("CitizenQuestProgress", "Citizen") == 3) then
                    _G.Auto_MusketeerHat = false;
                    if (plr.Backpack:FindFirstChild("Banana") and plr.Backpack:FindFirstChild("Apple") and plr.Backpack:FindFirstChild("Pineapple")) then
                        repeat
                            Tween(CFrame.new(- 12444.78515625, 332.40396118164, - 7673.1806640625));
                            wait();
                        until not _G.Auto_ObservationV2 or ((plr.Character.HumanoidRootPart.Position - Vector3.new(- 12444.78515625, 332.40396118164, - 7673.1806640625)).Magnitude <= 10)
                        wait(0.5);
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("CitizenQuestProgress", "Citizen");
                    elseif (plr.Backpack:FindFirstChild("Fruit Bowl") or plr.Character:FindFirstChild("Fruit Bowl")) then
                        repeat
                            Tween(CFrame.new(- 10920.125, 624.20275878906, - 10266.995117188));
                            wait();
                        until not _G.Auto_ObservationV2 or ((plr.Character.HumanoidRootPart.Position - Vector3.new(- 10920.125, 624.20275878906, - 10266.995117188)).Magnitude <= 10)
                        wait(0.5);
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("KenTalk2", "Start");
                        wait(1);
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("KenTalk2", "Buy");
                    else
                        for _, fruitDescendant in pairs(Workspace:GetDescendants()) do
                            if ((enemy.Name == "Apple") or (enemy.Name == "Banana") or (enemy.Name == "Pineapple")) then
                                fruitDescendant.Handle.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 1, 10) ;
                                wait();
                                firetouchinterest(plr.Character.HumanoidRootPart, fruitDescendant.Handle, 0);
                                wait();
                            end
                        end
                    end
                else
                    _G.Auto_MusketeerHat = true;
                end
            end
        end);
    end
end);
local AutoRainbowHakiToggle = Tabs.ITM:AddToggle("ToggleAutoRainbowHaki", {
    Title = "Haki 7 Màu",
    Description = "",
    Default = false
});
AutoRainbowHakiToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.Auto_RainbowHaki = value;
end);
Options.ToggleAutoRainbowHaki:SetValue(false);
spawn(function()
    pcall(function()
        while wait(0.1) do
            if _G.Auto_RainbowHaki then
                if not plr.PlayerGui.Main.Quest.Visible then
                    Tween(CFrame.new(- 11892.0703125, 930.57672119141, - 8760.1591796875));
                    if ((Vector3.new(- 11892.0703125, 930.57672119141, - 8760.1591796875) - plr.Character.HumanoidRootPart.Position).Magnitude <= 30) then
                        wait(1.5);
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("HornedMan", "Bet");
                    end
                elseif (plr.PlayerGui.Main.Quest.Visible and string.find(plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "Stone")) then
                    if Workspace.Enemies:FindFirstChild("Stone") then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if (enemy.Name == "Stone") then
                                OldCFrameRainbow = enemy.HumanoidRootPart.CFrame;
                                repeat
                                    task.wait(_G.Fast_Delay);
                                    EquipTool(SelectWeapon);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    enemy.HumanoidRootPart.CFrame = OldCFrameRainbow;
                                    enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                                    AttackNoCoolDown();
                                until not _G.Auto_RainbowHaki or (enemy.Humanoid.Health <= 0) or not enemy.Parent or not plr.PlayerGui.Main.Quest.Visible
                            end
                        end
                    else
                        Tween(CFrame.new(- 1086.11621, 38.8425903, 6768.71436));
                    end
                elseif (plr.PlayerGui.Main.Quest.Visible and string.find(plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "Hydra Leader")) then
                    if Workspace.Enemies:FindFirstChild("Hydra Leader") then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if (enemy.Name == "Hydra Leader") then
                                OldCFrameRainbow = enemy.HumanoidRootPart.CFrame;
                                repeat
                                    task.wait(_G.Fast_Delay);
                                    EquipTool(SelectWeapon);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    enemy.HumanoidRootPart.CFrame = OldCFrameRainbow;
                                    enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                                    AttackNoCoolDown();
                                until not _G.Auto_RainbowHaki or (enemy.Humanoid.Health <= 0) or not enemy.Parent or not plr.PlayerGui.Main.Quest.Visible
                            end
                        end
                    else
                        Tween(CFrame.new(5713.98877, 601.922974, 202.751251));
                    end
                elseif string.find(plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "Kilo Admiral") then
                    if Workspace.Enemies:FindFirstChild("Kilo Admiral") then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if (enemy.Name == "Kilo Admiral") then
                                OldCFrameRainbow = enemy.HumanoidRootPart.CFrame;
                                repeat
                                    task.wait(_G.Fast_Delay);
                                    EquipTool(SelectWeapon);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                                    enemy.HumanoidRootPart.CFrame = OldCFrameRainbow;
                                    AttackNoCoolDown();
                                until not _G.Auto_RainbowHaki or (enemy.Humanoid.Health <= 0) or not enemy.Parent or not plr.PlayerGui.Main.Quest.Visible
                            end
                        end
                    else
                        Tween(CFrame.new(2877.61743, 423.558685, - 7207.31006));
                    end
                elseif string.find(plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "Captain Elephant") then
                    if Workspace.Enemies:FindFirstChild("Captain Elephant") then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if (enemy.Name == "Captain Elephant") then
                                OldCFrameRainbow = enemy.HumanoidRootPart.CFrame;
                                repeat
                                    task.wait(_G.Fast_Delay);
                                    EquipTool(SelectWeapon);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                                    enemy.HumanoidRootPart.CFrame = OldCFrameRainbow;
                                    AttackNoCoolDown();
                                until not _G.Auto_RainbowHaki or (enemy.Humanoid.Health <= 0) or not enemy.Parent or not plr.PlayerGui.Main.Quest.Visible
                            end
                        end
                    else
                        Tween(CFrame.new(- 13485.0283, 331.709259, - 8012.4873));
                    end
                elseif string.find(plr.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, "Beautiful Pirate") then
                    if Workspace.Enemies:FindFirstChild("Beautiful Pirate") then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if (enemy.Name == "Beautiful Pirate") then
                                OldCFrameRainbow = enemy.HumanoidRootPart.CFrame;
                                repeat
                                    task.wait(_G.Fast_Delay);
                                    EquipTool(SelectWeapon);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                                    enemy.HumanoidRootPart.CFrame = OldCFrameRainbow;
                                    AttackNoCoolDown();
                                until not _G.Auto_RainbowHaki or (enemy.Humanoid.Health <= 0) or not enemy.Parent or not plr.PlayerGui.Main.Quest.Visible
                            end
                        end
                    else
                        Tween(CFrame.new(5312.3598632813, 20.141201019287, - 10.158538818359));
                    end
                else
                    Tween(CFrame.new(- 11892.0703125, 930.57672119141, - 8760.1591796875));
                    if ((Vector3.new(- 11892.0703125, 930.57672119141, - 8760.1591796875) - plr.Character.HumanoidRootPart.Position).Magnitude <= 30) then
                        wait(1.5);
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("HornedMan", "Bet");
                    end
                end
            end
        end
    end);
end);
local AutoSkullGuitarToggle = Tabs.ITM:AddToggle("ToggleAutoSkullGuitar", {
    Title = "Skull Guitar",
    Description = "",
    Default = false
});
AutoSkullGuitarToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.Auto_SkullGuitar = value;
end);
Options.ToggleAutoSkullGuitar:SetValue(false);
spawn(function()
    while wait() do
        pcall(function()
            if _G.Auto_SkullGuitar then
                if (GetWeaponInventory("Skull Guitar") == false) then
                    if ((CFrame.new(- 9681.458984375, 6.139880657196045, 6341.3720703125).Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 5000) then
                        if Workspace.NPCs:FindFirstChild("Skeleton Machine") then
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("soulGuitarBuy", true);
                        elseif (Workspace.Map["Haunted Castle"].Candle1.Transparency == 0) then
                            if (Workspace.Map["Haunted Castle"].Placard1.Left.Part.Transparency == 0) then
                                Quest2 = true;
                                repeat
                                    wait();
                                    Tween(CFrame.new(- 8762.69140625, 176.84783935546875, 6171.3076171875));
                                until ((CFrame.new(- 8762.69140625, 176.84783935546875, 6171.3076171875).Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 3) or not _G.Auto_SkullGuitar
                                wait(1);
                                fireclickdetector(Workspace.Map["Haunted Castle"].Placard7.Left.ClickDetector);
                                wait(1);
                                fireclickdetector(Workspace.Map["Haunted Castle"].Placard6.Left.ClickDetector);
                                wait(1);
                                fireclickdetector(Workspace.Map["Haunted Castle"].Placard5.Left.ClickDetector);
                                wait(1);
                                fireclickdetector(Workspace.Map["Haunted Castle"].Placard4.Right.ClickDetector);
                                wait(1);
                                fireclickdetector(Workspace.Map["Haunted Castle"].Placard3.Left.ClickDetector);
                                wait(1);
                                fireclickdetector(Workspace.Map["Haunted Castle"].Placard2.Right.ClickDetector);
                                wait(1);
                                fireclickdetector(Workspace.Map["Haunted Castle"].Placard1.Right.ClickDetector);
                                wait(1);
                            elseif Workspace.Map["Haunted Castle"].Tablet.Segment1:FindFirstChild("ClickDetector") then
                                if Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part1:FindFirstChild("ClickDetector") then
                                    Quest4 = true;
                                    repeat
                                        wait();
                                        Tween(CFrame.new(- 9553.5986328125, 65.62338256835938, 6041.58837890625));
                                    until ((CFrame.new(- 9553.5986328125, 65.62338256835938, 6041.58837890625).Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 3) or not _G.Auto_SkullGuitar
                                    wait(1);
                                    Tween(Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part3.CFrame);
                                    wait(1);
                                    fireclickdetector(Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part3.ClickDetector);
                                    wait(1);
                                    Tween(Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part4.CFrame);
                                    wait(1);
                                    fireclickdetector(Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part4.ClickDetector);
                                    wait(1);
                                    fireclickdetector(Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part4.ClickDetector);
                                    wait(1);
                                    fireclickdetector(Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part4.ClickDetector);
                                    wait(1);
                                    Tween(Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part6.CFrame);
                                    wait(1);
                                    fireclickdetector(Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part6.ClickDetector);
                                    wait(1);
                                    fireclickdetector(Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part6.ClickDetector);
                                    wait(1);
                                    Tween(Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part8.CFrame);
                                    wait(1);
                                    fireclickdetector(Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part8.ClickDetector);
                                    wait(1);
                                    Tween(Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part10.CFrame);
                                    wait(1);
                                    fireclickdetector(Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part10.ClickDetector);
                                    wait(1);
                                    fireclickdetector(Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part10.ClickDetector);
                                    wait(1);
                                    fireclickdetector(Workspace.Map["Haunted Castle"]["Lab Puzzle"].ColorFloor.Model.Part10.ClickDetector);
                                else
                                    Quest3 = true;
                                end
                            else
                                if Workspace.NPCs:FindFirstChild("Ghost") then
                                    local gravestoneArgs = {
                                        [1] = "GuitarPuzzleProgress",
                                        [2] = "Ghost"
                                    };
                                    ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(gravestoneArgs));
                                end
                                if Workspace.Enemies:FindFirstChild("Living Zombie") then
                                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                                        if (enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and (enemy.Humanoid.Health > 0)) then
                                            if (enemy.Name == "Living Zombie") then
                                                EquipTool(SelectWeapon);
                                                enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                                enemy.HumanoidRootPart.Transparency = 1;
                                                enemy.Humanoid.JumpPower = 0;
                                                enemy.Humanoid.WalkSpeed = 0;
                                                enemy.HumanoidRootPart.CanCollide = false;
                                                enemy.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0) ;
                                                Tween(CFrame.new(- 10160.787109375, 138.6616973876953, 5955.03076171875));
                                                VirtualUser:CaptureController();
                                                VirtualUser:Button1Down(Vector2.new(1280, 672));
                                            end
                                        end
                                    end
                                else
                                    Tween(CFrame.new(- 10160.787109375, 138.6616973876953, 5955.03076171875));
                                end
                            end
                        elseif string.find(ReplicatedStorage.Remotes.CommF_:InvokeServer("gravestoneEvent", 2), "Error") then
                            Tween(CFrame.new(- 8653.2060546875, 140.98487854003906, 6160.033203125));
                        elseif string.find(ReplicatedStorage.Remotes.CommF_:InvokeServer("gravestoneEvent", 2), "Nothing") then
                            Tween("Wait Full Moon");
                        else
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("gravestoneEvent", 2, true);
                        end
                    else
                        Tween(CFrame.new(- 9681.458984375, 6.139880657196045, 6341.3720703125));
                    end
                end
            end
        end);
    end
end);
local AutoBuddyToggle = Tabs.ITM:AddToggle("ToggleAutoBuddy", {
    Title = "Kiếm Buddy",
    Description = "",
    Default = false
});
AutoBuddyToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.Auto_Buddy = value;
end);
Options.ToggleAutoBuddy:SetValue(false);
local targetCFrame = CFrame.new(- 731.2034301757812, 381.5658874511719, - 11198.4951171875);
spawn(function()
    while wait() do
        if _G.Auto_Buddy then
            pcall(function()
                if Workspace.Enemies:FindFirstChild("Cake Queen") then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if (enemy.Name == "Cake Queen") then
                            if (enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and (enemy.Humanoid.Health > 0)) then
                                repeat
                                    task.wait(_G.Fast_Delay);
                                    AutoHaki();
                                    EquipTool(SelectWeapon);
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    enemy.Humanoid.WalkSpeed = 0;
                                    enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    AttackNoCoolDown();
                                until not _G.Auto_Buddy or not enemy.Parent or (enemy.Humanoid.Health <= 0)
                            end
                        end
                    end
                elseif ((plr.Character.HumanoidRootPart.Position - targetCFrame.Position).Magnitude < 1500) then
                    Tween(targetCFrame);
                end
                Tween(CFrame.new(- 731.2034301757812, 381.5658874511719, - 11198.4951171875));
                if ReplicatedStorage:FindFirstChild("Cake Queen") then
                    Tween(ReplicatedStorage:FindFirstChild("Cake Queen").HumanoidRootPart.CFrame * CFrame.new(2, 20, 2));
                end
            end);
        end
    end
end);
local AutoDualKatanaToggle = Tabs.ITM:AddToggle("ToggleAutoDualKatana", {
    Title = "Song Kiếm",
    Description = "",
    Default = false
});
AutoDualKatanaToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.Auto_DualKatana = value;
end);
Options.ToggleAutoDualKatana:SetValue(false);
spawn(function()
    while wait() do
        pcall(function()
            if _G.Auto_DualKatana then
                if (plr.Character:FindFirstChild("Tushita") or plr.Backpack:FindFirstChild("Tushita") or plr.Character:FindFirstChild("Yama") or plr.Backpack:FindFirstChild("Yama")) then
                    if (plr.Character:FindFirstChild("Tushita") or plr.Backpack:FindFirstChild("Tushita")) then
                        if plr.Backpack:FindFirstChild("Tushita") then
                            EquipTool("Tushita");
                        end
                    elseif (plr.Character:FindFirstChild("Yama") or plr.Backpack:FindFirstChild("Yama")) then
                        if plr.Backpack:FindFirstChild("Yama") then
                            EquipTool("Yama");
                        end
                    end
                else
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("LoadItem", "Tushita");
                end
            end
        end);
    end
end);
spawn(function()
    while wait() do
        pcall(function()
            if _G.Auto_DualKatana then
                if (GetMaterial("Alucard Fragment") == 0) then
                    Auto_Quest_Yama_1 = true;
                    Auto_Quest_Yama_2 = false;
                    Auto_Quest_Yama_3 = false;
                    Auto_Quest_Tushita_1 = false;
                    Auto_Quest_Tushita_2 = false;
                    Auto_Quest_Tushita_3 = false;
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "Progress", "Evil");
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "StartTrial", "Evil");
                elseif (GetMaterial("Alucard Fragment") == 1) then
                    Auto_Quest_Yama_1 = false;
                    Auto_Quest_Yama_2 = true;
                    Auto_Quest_Yama_3 = false;
                    Auto_Quest_Tushita_1 = false;
                    Auto_Quest_Tushita_2 = false;
                    Auto_Quest_Tushita_3 = false;
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "Progress", "Evil");
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "StartTrial", "Evil");
                elseif (GetMaterial("Alucard Fragment") == 2) then
                    Auto_Quest_Yama_1 = false;
                    Auto_Quest_Yama_2 = false;
                    Auto_Quest_Yama_3 = true;
                    Auto_Quest_Tushita_1 = false;
                    Auto_Quest_Tushita_2 = false;
                    Auto_Quest_Tushita_3 = false;
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "Progress", "Evil");
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "StartTrial", "Evil");
                elseif (GetMaterial("Alucard Fragment") == 3) then
                    Auto_Quest_Yama_1 = false;
                    Auto_Quest_Yama_2 = false;
                    Auto_Quest_Yama_3 = false;
                    Auto_Quest_Tushita_1 = true;
                    Auto_Quest_Tushita_2 = false;
                    Auto_Quest_Tushita_3 = false;
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "Progress", "Good");
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "StartTrial", "Good");
                elseif (GetMaterial("Alucard Fragment") == 4) then
                    Auto_Quest_Yama_1 = false;
                    Auto_Quest_Yama_2 = false;
                    Auto_Quest_Yama_3 = false;
                    Auto_Quest_Tushita_1 = false;
                    Auto_Quest_Tushita_2 = true;
                    Auto_Quest_Tushita_3 = false;
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "Progress", "Good");
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "StartTrial", "Good");
                elseif (GetMaterial("Alucard Fragment") == 5) then
                    Auto_Quest_Yama_1 = false;
                    Auto_Quest_Yama_2 = false;
                    Auto_Quest_Yama_3 = false;
                    Auto_Quest_Tushita_1 = false;
                    Auto_Quest_Tushita_2 = false;
                    Auto_Quest_Tushita_3 = true;
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "Progress", "Good");
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "StartTrial", "Good");
                elseif (GetMaterial("Alucard Fragment") == 6) then
                    if (Workspace.Enemies:FindFirstChild("Cursed Skeleton Boss [Lv. 2025] [Boss]") or Workspace.ReplicatedStorage:FindFirstChild("Cursed Skeleton Boss [Lv. 2025] [Boss]")) then
                        Auto_Quest_Yama_1 = false;
                        Auto_Quest_Yama_2 = false;
                        Auto_Quest_Yama_3 = false;
                        Auto_Quest_Tushita_1 = false;
                        Auto_Quest_Tushita_2 = false;
                        Auto_Quest_Tushita_3 = false;
                        if (Workspace.Enemies:FindFirstChild("Cursed Skeleton Boss [Lv. 2025] [Boss]") or Workspace.Enemies:FindFirstChild("Cursed Skeleton [Lv. 2200]")) then
                            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                                if ((enemy.Name == "Cursed Skeleton Boss") or (enemy.Name == "Cursed Skeleton")) then
                                    if (enemy.Humanoid.Health > 0) then
                                        EquipTool(Sword);
                                        Tween(enemy.HumanoidRootPart.CFrame * pos);
                                        enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                        enemy.HumanoidRootPart.Transparency = 1;
                                        enemy.Humanoid.JumpPower = 0;
                                        enemy.Humanoid.WalkSpeed = 0;
                                        enemy.HumanoidRootPart.CanCollide = false;
                                        bringmob = true;
                                        FarmPos = enemy.HumanoidRootPart.CFrame;
                                        MonFarm = enemy.Name;
                                        AttackNoCoolDown();
                                    end
                                end
                            end
                        end
                    elseif ((CFrame.new(- 12361.7060546875, 603.3547973632812, - 6550.5341796875).Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 100) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "Progress", "Good");
                        wait(1);
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "Progress", "Evil");
                        wait(1);
                        Tween(CFrame.new(- 12361.7060546875, 603.3547973632812, - 6550.5341796875));
                        wait(1.5);
                        VirtualInputManager:SendKeyEvent(true, "E", false, game);
                        wait(1.5);
                        Tween(CFrame.new(- 12253.5419921875, 598.8999633789062, - 6546.8388671875));
                    else
                        Tween(CFrame.new(- 12361.7060546875, 603.3547973632812, - 6550.5341796875));
                    end
                end
            end
        end);
    end
end);
spawn(function()
    while wait() do
        if Auto_Quest_Yama_1 then
            pcall(function()
                if Workspace.Enemies:FindFirstChild("Mythological Pirate") then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if (enemy.Name == "Mythological Pirate") then
                            repeat
                                wait();
                                Tween(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, - 2));
                            until (_G.Auto_DualKatana == false) or (Auto_Quest_Yama_1 == false)
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("CDKQuest", "StartTrial", "Evil");
                        end
                    end
                else
                    Tween(CFrame.new(- 13451.46484375, 543.712890625, - 6961.0029296875));
                end
            end);
        end
    end
end);
spawn(function()
    while wait() do
        pcall(function()
            if Auto_Quest_Yama_2 then
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if hazeEnemy:FindFirstChild("HazeESP") then
                        hazeEnemy.HazeESP.Size = UDim2.new(50, 50, 50, 50);
                        hazeEnemy.HazeESP.MaxDistance = "inf";
                    end
                end
                for _, yamaArgs in pairs(ReplicatedStorage:GetChildren()) do
                    if yamaArgs:FindFirstChild("HazeESP") then
                        yamaArgs.HazeESP.Size = UDim2.new(50, 50, 50, 50);
                        yamaArgs.HazeESP.MaxDistance = "inf";
                    end
                end
            end
        end);
    end
end);
spawn(function()
    while wait() do
        pcall(function()
            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                if (Auto_Quest_Yama_2 and enemy:FindFirstChild("HazeESP") and ((enemy.HumanoidRootPart.Position - FarmPossEsp.Position).magnitude <= 300)) then
                    enemy.HumanoidRootPart.CFrame = FarmPossEsp;
                    enemy.HumanoidRootPart.CanCollide = false;
                    enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                    if not enemy.HumanoidRootPart:FindFirstChild("BodyVelocity") then
                        local questEnemy515 = Instance.new("BodyVelocity", enemy.HumanoidRootPart);
                        questEnemy515.MaxForce = Vector3.new(1, 1, 1) * math.huge ;
                        questEnemy515.Velocity = Vector3.new(0, 0, 0);
                    end
                end
            end
        end);
    end
end);
spawn(function()
    while wait() do
        if Auto_Quest_Yama_2 then
            pcall(function()
                for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                    if enemyModel:FindFirstChild("HazeESP") then
                        repeat
                            wait();
                            if ((enemy.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude > 2000) then
                                Tween(enemy.HumanoidRootPart.CFrame * Pos);
                            else
                                EquipTool(Sword);
                                Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                enemy.HumanoidRootPart.Transparency = 1;
                                enemyModel.Humanoid.JumpPower = 0;
                                enemyModel.Humanoid.WalkSpeed = 0;
                                enemy.HumanoidRootPart.CanCollide = false;
                                FarmPos = enemy.HumanoidRootPart.CFrame;
                                MonFarm = enemyModel.Name;
                                AttackNoCoolDown();
                                if ((enemy.Humanoid.Health <= 0) and enemyModel.Humanoid:FindFirstChild("Animator")) then
                                    enemyModel.Humanoid.Animator:Destroy();
                                end
                            end
                        until (_G.Auto_DualKatana == false) or (Auto_Quest_Yama_2 == false) or not enemy.Parent or (enemy.Humanoid.Health <= 0) or not enemyModel:FindFirstChild("HazeESP")
                    else
                        for _, eliteEnemy in pairs(ReplicatedStorage:GetChildren()) do
                            if eliteEnemy:FindFirstChild("HazeESP") then
                                if ((enemy.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude > 2000) then
                                    Tween(enemy.HumanoidRootPart.CFrameMon * CFrame.new(2, 20, 2));
                                else
                                    Tween(enemy.HumanoidRootPart.CFrame * CFrame.new(2, 20, 2));
                                end
                            end
                        end
                    end
                end
            end);
        end
    end
end);
spawn(function()
    while wait() do
        if Auto_Quest_Yama_3 then
            pcall(function()
                if plr.Backpack:FindFirstChild("Hallow Essence") then
                    Tween(Workspace.Map["Haunted Castle"].Summoner.Detection.CFrame);
                elseif Workspace.Map:FindFirstChild("HellDimension") then
                    repeat
                        wait();
                        if (Workspace.Enemies:FindFirstChild("Cursed Skeleton [Lv. 2200]") or Workspace.Enemies:FindFirstChild("Cursed Skeleton [Lv. 2200] [Boss]") or Workspace.Enemies:FindFirstChild("Hell's Messenger [Lv. 2200] [Boss]")) then
                            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                                if ((enemy.Name == "Cursed Skeleton") or (enemy.Name == "Cursed Skeleton") or (enemy.Name == "Hell's Messenger")) then
                                    if (enemy.Humanoid.Health > 0) then
                                        repeat
                                            wait();
                                            EquipTool(Sword);
                                            Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                            enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                            enemy.HumanoidRootPart.Transparency = 1;
                                            varE.Humanoid.JumpPower = 0;
                                            varE.Humanoid.WalkSpeed = 0;
                                            enemy.HumanoidRootPart.CanCollide = false;
                                            FarmPos = enemy.HumanoidRootPart.CFrame;
                                            MonFarm = varE.Name;
                                            AttackNoCoolDown();
                                            if ((enemy.Humanoid.Health <= 0) and varE.Humanoid:FindFirstChild("Animator")) then
                                                varE.Humanoid.Animator:Destroy();
                                            end
                                        until (enemy.Humanoid.Health <= 0) or not enemy.Parent or (Auto_Quest_Yama_3 == false)
                                    end
                                end
                            end
                        else
                            wait(5);
                            Tween(Workspace.Map.HellDimension.Torch1.CFrame);
                            wait(1.5);
                            VirtualInputManager:SendKeyEvent(true, "E", false, game);
                            wait(1.5);
                            Tweem(Workspace.Map.HellDimension.Torch2.CFrame);
                            wait(1.5);
                            VirtualInputManager:SendKeyEvent(true, "E", false, game);
                            wait(1.5);
                            Tween(Workspace.Map.HellDimension.Torch3.CFrame);
                            wait(1.5);
                            VirtualInputManager:SendKeyEvent(true, "E", false, game);
                            wait(1.5);
                            Tween(Workspace.Map.HellDimension.Exit.CFrame);
                        end
                    until (_G.Auto_DualKatana == false) or (Auto_Quest_Yama_3 == false) or (GetMaterial("Alucard Fragment") == 3)
                elseif (Workspace.Enemies:FindFirstChild("Soul Reaper") or ReplicatedStorage:FindFirstChild("Soul Reaper [Lv. 2100] [Raid Boss]")) then
                    if Workspace.Enemies:FindFirstChild("Soul Reaper") then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if (enemy.Name == "Soul Reaper") then
                                if (enemy.Humanoid.Health > 0) then
                                    repeat
                                        wait();
                                        Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    until (_G.Auto_DualKatana == false) or (Auto_Quest_Yama_3 == false) or Workspace.Map:FindFirstChild("HellDimension")
                                end
                            end
                        end
                    else
                        Tween(CFrame.new(- 9570.033203125, 315.9346923828125, 6726.89306640625));
                    end
                else
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Buy", 1, 1);
                end
            end);
        end
    end
end);
spawn(function()
    while wait() do
        if Auto_Quest_Tushita_1 then
            Tween(CFrame.new(- 9546.990234375, 21.139892578125, 4686.1142578125));
            wait(5);
            Tween(CFrame.new(- 6120.0576171875, 16.455780029296875, - 2250.697265625));
            wait(5);
            Tween(CFrame.new(- 9533.2392578125, 7.254445552825928, - 8372.69921875));
        end
    end
end);
spawn(function()
    while wait() do
        if Auto_Quest_Tushita_2 then
            pcall(function()
                if ((CFrame.new(- 5539.3115234375, 313.800537109375, - 2972.372314453125).Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 500) then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if (Auto_Quest_Tushita_2 and espText:FindFirstChild("HumanoidRootPart") and espText:FindFirstChild("Humanoid") and (enemy.Humanoid.Health > 0)) then
                            if ((enemy.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 2000) then
                                repeat
                                    wait();
                                    EquipTool(Sword);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                    enemy.HumanoidRootPart.Transparency = 1;
                                    espText.Humanoid.JumpPower = 0;
                                    espText.Humanoid.WalkSpeed = 0;
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    FarmPos = enemy.HumanoidRootPart.CFrame;
                                    MonFarm = espText.Name;
                                    AttackNoCoolDown();
                                    if ((enemy.Humanoid.Health <= 0) and espText.Humanoid:FindFirstChild("Animator")) then
                                        espText.Humanoid.Animator:Destroy();
                                    end
                                until (enemy.Humanoid.Health <= 0) or not enemy.Parent or (Auto_Quest_Tushita_2 == false)
                            end
                        end
                    end
                else
                    Tween(CFrame.new(- 5545.1240234375, 313.800537109375, - 2976.616455078125));
                end
            end);
        end
    end
end);
spawn(function()
    while wait() do
        if Auto_Quest_Tushita_3 then
            pcall(function()
                if (Workspace.Enemies:FindFirstChild("Cake Queen") or ReplicatedStorage:FindFirstChild("Cake Queen [Lv. 2175] [Boss]")) then
                    if Workspace.Enemies:FindFirstChild("Cake Queen") then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if (enemy.Name == "Cake Queen") then
                                if (enemy.Humanoid.Health > 0) then
                                    repeat
                                        wait();
                                        EquipTool(Sword);
                                        Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                        enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                        enemy.HumanoidRootPart.Transparency = 1;
                                        obj1.Humanoid.JumpPower = 0;
                                        obj1.Humanoid.WalkSpeed = 0;
                                        enemy.HumanoidRootPart.CanCollide = false;
                                        FarmPos = enemy.HumanoidRootPart.CFrame;
                                        MonFarm = obj1.Name;
                                        AttackNoCoolDown();
                                        if ((enemy.Humanoid.Health <= 0) and obj1.Humanoid:FindFirstChild("Animator")) then
                                            obj1.Humanoid.Animator:Destroy();
                                        end
                                    until (_G.Auto_DualKatana == false) or (Auto_Quest_Tushita_3 == false) or Workspace.Map:FindFirstChild("HeavenlyDimension")
                                end
                            end
                        end
                    else
                        Tween(CFrame.new(- 709.3132934570312, 381.6005859375, - 11011.396484375));
                    end
                elseif Workspace.Map:FindFirstChild("HeavenlyDimension") then
                    repeat
                        wait();
                        if (Workspace.Enemies:FindFirstChild("Cursed Skeleton [Lv. 2200]") or Workspace.Enemies:FindFirstChild("Cursed Skeleton [Lv. 2200] [Boss]") or Workspace.Enemies:FindFirstChild("Heaven's Guardian [Lv. 2200] [Boss]")) then
                            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                                if ((enemy.Name == "Cursed Skeleton") or (enemy.Name == "Cursed Skeleton") or (enemy.Name == "Heaven's Guardian")) then
                                    if (enemy.Humanoid.Health > 0) then
                                        repeat
                                            wait();
                                            EquipTool(Sword);
                                            Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                            enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                            enemy.HumanoidRootPart.Transparency = 1;
                                            obj2.Humanoid.JumpPower = 0;
                                            obj2.Humanoid.WalkSpeed = 0;
                                            enemy.HumanoidRootPart.CanCollide = false;
                                            FarmPos = enemy.HumanoidRootPart.CFrame;
                                            MonFarm = obj2.Name;
                                            AttackNoCoolDown();
                                            if ((enemy.Humanoid.Health <= 0) and obj2.Humanoid:FindFirstChild("Animator")) then
                                                obj2.Humanoid.Animator:Destroy();
                                            end
                                        until (enemy.Humanoid.Health <= 0) or not enemy.Parent or (Auto_Quest_Tushita_3 == false)
                                    end
                                end
                            end
                        else
                            wait(5);
                            Tween(Workspace.Map.HeavenlyDimension.Torch1.CFrame);
                            wait(1.5);
                            VirtualInputManager:SendKeyEvent(true, "E", false, game);
                            wait(1.5);
                            Tween(Workspace.Map.HeavenlyDimension.Torch2.CFrame);
                            wait(1.5);
                            VirtualInputManager:SendKeyEvent(true, "E", false, game);
                            wait(1.5);
                            Tween(Workspace.Map.HeavenlyDimension.Torch3.CFrame);
                            wait(1.5);
                            VirtualInputManager:SendKeyEvent(true, "E", false, game);
                            wait(1.5);
                            Tween(Workspace.Map.HeavenlyDimension.Exit.CFrame);
                        end
                    until not _G.Auto_DualKatana or not Auto_Quest_Tushita_3 or (GetMaterial("Alucard Fragment") == 6)
                end
            end);
        end
    end
end);
if Sea2 then
    local toggleFactory = Tabs.ITM:AddToggle("ToggleFactory", {
        Title = "Đấm Nhà Máy",
        Description = "",
        Default = false
    });
    toggleFactory:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        if value == false then
            CancelTween()
        end
        _G.Factory = value;
    end);
    Options.ToggleFactory:SetValue(false);
    spawn(function()
        while wait() do
            if _G.Factory then
                if Workspace.Enemies:FindFirstChild("Core") then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if ((enemy.Name == "Core") and (enemy.Humanoid.Health > 0)) then
                            repeat
                                wait(_G.Fast_Delay);
                                AttackNoCoolDown();
                                repeat
                                    Tween(CFrame.new(448.46756, 199.356781, - 441.389252));
                                    wait();
                                until not _G.Factory or ((plr.Character.HumanoidRootPart.Position - Vector3.new(448.46756, 199.356781, - 441.389252)).Magnitude <= 10)
                                EquipTool(SelectWeapon);
                                AutoHaki();
                                Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                enemy.HumanoidRootPart.Transparency = 1;
                                enemy.Humanoid.JumpPower = 0;
                                enemy.Humanoid.WalkSpeed = 0;
                                enemy.HumanoidRootPart.CanCollide = false;
                                FarmPos = enemy.HumanoidRootPart.CFrame;
                                MonFarm = enemy.Name;
                            until not enemy.Parent or (enemy.Humanoid.Health <= 0) or (_G.Factory == false)
                        end
                    end
                elseif ReplicatedStorage:FindFirstChild("Core") then
                    repeat
                        Tween(CFrame.new(448.46756, 199.356781, - 441.389252));
                        wait();
                    until not _G.Factory or ((plr.Character.HumanoidRootPart.Position - Vector3.new(448.46756, 199.356781, - 441.389252)).Magnitude <= 10)
                end
            end
        end
    end);
end
local AutoFarmSwanToggle = Tabs.ITM:AddToggle("ToggleAutoFarmSwan", {
    Title = "Đấm Swan",
    Description = "",
    Default = false
});
AutoFarmSwanToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.Auto_FarmSwan = value;
end);
Options.ToggleAutoFarmSwan:SetValue(false);
spawn(function()
    pcall(function()
        while wait() do
            if _G.AutoFarmSwan then
                if Workspace.Enemies:FindFirstChild("Don Swan") then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if ((enemy.Name == "Don Swan") and (enemy.Humanoid.Health > 0) and questEnemy516:IsA("Model") and questEnemy516:FindFirstChild("Humanoid") and questEnemy516:FindFirstChild("HumanoidRootPart")) then
                            repeat
                                task.wait();
                                pcall(function()
                                    AutoHaki();
                                    EquipTool(SelectWeapon);
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    AttackNoCoolDown();
                                end);
                            until (_G.AutoFarmSwan == false) or (enemy.Humanoid.Health <= 0)
                        end
                    end
                else
                    repeat
                        task.wait();
                        GameTeleport(Vector3.new(2284.912109375, 15.537666320801, 905.48291015625));
                    until ((CFrame.new(2284.912109375, 15.537666320801, 905.48291015625).Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 4) or (_G.AutoFarmSwan == false)
                end
            end
        end
    end);
end);
local AutoRengokuToggle = Tabs.ITM:AddToggle("ToggleAutoRengoku", {
    Title = "Rengoku",
    Description = "",
    Default = false
});
AutoRengokuToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.Auto_Regoku = value;
end);
Options.ToggleAutoRengoku:SetValue(false);
spawn(function()
    pcall(function()
        while wait() do
            if _G.Auto_Regoku then
                if (plr.Backpack:FindFirstChild("Hidden Key") or plr.Character:FindFirstChild("Hidden Key")) then
                    EquipTool("Hidden Key");
                    Tween(CFrame.new(6571.1201171875, 299.23028564453, - 6967.841796875));
                elseif (Workspace.Enemies:FindFirstChild("Snow Lurker") or Workspace.Enemies:FindFirstChild("Arctic Warrior")) then
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if (((enemy.Name == "Snow Lurker") or (enemy.Name == "Arctic Warrior")) and (enemy.Humanoid.Health > 0)) then
                            repeat
                                task.wait(_G.Fast_Delay);
                                EquipTool(SelectWeapon);
                                AutoHaki();
                                enemy.HumanoidRootPart.CanCollide = false;
                                enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                                FarmPos = enemy.HumanoidRootPart.CFrame;
                                MonFarm = farmTarget.Name;
                                Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                AttackNoCoolDown();
                                bringmob = true;
                            until plr.Backpack:FindFirstChild("Hidden Key") or (_G.Auto_Regoku == false) or not enemy.Parent or (enemy.Humanoid.Health <= 0)
                            bringmob = false;
                        end
                    end
                else
                    bringmob = false;
                    Tween(CFrame.new(5439.716796875, 84.420944213867, - 6715.1635742188));
                end
            end
        end
    end);
end);
if (Sea2 or Sea3) then
    local toggleHakiColor = Tabs.ITM:AddToggle("ToggleHakiColor", {
        Title = "Mua Màu Haki",
        Description = "",
        Default = false
    });
    toggleHakiColor:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        _G.Auto_Buy_Enchancement = value;
    end);
    Options.ToggleHakiColor:SetValue(false);
    spawn(function()
        while wait() do
            if _G.Auto_Buy_Enchancement then
                local colorDealerArgs = {
                    [1] = "ColorsDealer",
                    [2] = "2"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(colorDealerArgs));
            end
        end
    end);
end
if Sea2 then
    local toggleSwordLengend = Tabs.Main:AddToggle("ToggleSwordLengend", {
        Title = "Mua Kiếm Huyền Thoại",
        Description = "",
        Default = false
    });
    toggleSwordLengend:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        _G.BuyLengendSword = value;
    end);
    Options.ToggleSwordLengend:SetValue(false);
    spawn(function()
        while wait() do
            pcall(function()
                if (_G.BuyLengendSword or Triple_A) then
                    local questCheckResult = {
                        [1] = "LegendarySwordDealer",
                        [2] = "2"
                    };
                    ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(questCheckResult));
                else
                    wait();
                end
            end);
        end
    end);
end
if Sea2 then
    local toggleEvoRace = Tabs.Main:AddToggle("ToggleEvoRace", {
        Title = "Nâng Tộc V2",
        Description = "",
        Default = false
    });
    toggleEvoRace:OnChanged(function(value)
    if value == true then _G.StopTween = false end
        if value == false then
            CancelTween()
        end
        _G.AutoEvoRace = value;
    end);
    Options.ToggleEvoRace:SetValue(false);
    spawn(function()
        pcall(function()
            while wait(0.1) do
                if _G.AutoEvoRace then
                    if not plr.Data.Race:FindFirstChild("Evolved") then
                        if (ReplicatedStorage.Remotes.CommF_:InvokeServer("Alchemist", "1") == 0) then
                            Tween(CFrame.new(- 2779.83521, 72.9661407, - 3574.02002, - 0.730484903, 6.390141e-8, - 0.68292886, 3.5996322e-8, 1, 5.5066703e-8, 0.68292886, 1.5642467e-8, - 0.730484903));
                            if ((Vector3.new(- 2779.83521, 72.9661407, - 3574.02002) - plr.Character.HumanoidRootPart.Position).Magnitude <= 4) then
                                wait(1.3);
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("Alchemist", "2");
                            end
                        elseif (ReplicatedStorage.Remotes.CommF_:InvokeServer("Alchemist", "1") == 1) then
                            pcall(function()
                                if (not plr.Backpack:FindFirstChild("Flower 1") and not plr.Character:FindFirstChild("Flower 1")) then
                                    Tween(Workspace.Flower1.CFrame);
                                elseif (not plr.Backpack:FindFirstChild("Flower 2") and not plr.Character:FindFirstChild("Flower 2")) then
                                    Tween(Workspace.Flower2.CFrame);
                                elseif (not plr.Backpack:FindFirstChild("Flower 3") and not plr.Character:FindFirstChild("Flower 3")) then
                                    if Workspace.Enemies:FindFirstChild("Zombie") then
                                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                                            if (enemy.Name == "Zombie") then
                                                repeat
                                                    task.wait(_G.Fast_Delay);
                                                    AutoHaki();
                                                    EquipTool(SelectWeapon);
                                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                                    enemy.HumanoidRootPart.CanCollide = false;
                                                    enemy.HumanoidRootPart.Size = Vector3.new(50, 50, 50);
                                                    AttackNoCoolDown();
                                                    FarmPos = enemy.HumanoidRootPart.CFrame;
                                                    MonFarm = enemy.Name;
                                                    bringmob = true;
                                                until plr.Backpack:FindFirstChild("Flower 3") or not enemy.Parent or (enemy.Humanoid.Health <= 0) or (_G.AutoEvoRace == false)
                                                bringmob = false;
                                            end
                                        end
                                    else
                                        Tween(CFrame.new(- 5685.9233398438, 48.480125427246, - 853.23724365234));
                                    end
                                end
                            end);
                        elseif (ReplicatedStorage.Remotes.CommF_:InvokeServer("Alchemist", "1") == 2) then
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("Alchemist", "3");
                        end
                    end
                end
            end
        end);
    end);
end
local AutoTToggle = Tabs.Setting:AddToggle("ToggleAutoT", {
    Title = "Bật Tộc V3",
    Description = "",
    Default = false
});
AutoTToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoT = value;
end);
Options.ToggleAutoT:SetValue(false);
spawn(function()
    while wait() do
        pcall(function()
            if _G.AutoT then
                ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility");
            end
        end);
    end
end);
local AutoYToggle = Tabs.Setting:AddToggle("ToggleAutoY", {
    Title = "Bật Tộc V4",
    Description = "",
    Default = false
});
AutoYToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoY = value;
end);
Options.ToggleAutoY:SetValue(false);
spawn(function()
    while wait() do
        pcall(function()
            if _G.AutoY then
                VirtualInputManager:SendKeyEvent(true, "Y", false, game);
                wait();
                VirtualInputManager:SendKeyEvent(false, "Y", false, game);
            end
        end);
    end
end);
local AutoKenToggle = Tabs.Setting:AddToggle("ToggleAutoKen", {
    Title = "Bật Haki Quan Sát",
    Description = "",
    Default = true
});
AutoKenToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoKen = value;
    if IsResettingConfig then return end
    if value then
        ReplicatedStorage.Remotes.CommE:FireServer("Ken", true);
    else
        ReplicatedStorage.Remotes.CommE:FireServer("Ken", false);
    end
end);
Options.ToggleAutoKen:SetValue(true);
spawn(function()
    while wait() do
        pcall(function()
            if _G.AutoKen then
                ReplicatedStorage.Remotes.CommE:FireServer("Ken", true);
            end
        end);
    end
end);
local toggleSaveSpawn = Tabs.Setting:AddToggle("ToggleSaveSpawn", {
    Title = "Lưu Điểm Hồi Sinh",
    Description = "",
    Default = false
});
toggleSaveSpawn:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.SaveSpawn = value;
    if IsResettingConfig then return end
    if value then
        local setSpawnArgs3 = {
            [1] = "SetSpawnPoint"
        };
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(setSpawnArgs3));
    end
end);
Options.ToggleSaveSpawn:SetValue(false);
spawn(function()
    while wait() do
        pcall(function()
            if _G.SaveSpawn then
                local setSpawnArgs4 = {
                    [1] = "SetSpawnPoint"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(setSpawnArgs4));
            end
        end);
    end
end);
local toggleMisc5 = require(ReplicatedStorage.Util.CameraShaker);
toggleMisc5:Stop();
_G.FastAttack = true
_G.Fast_Delay = 0.5
_G.FastAttackInput = "0.5"
local FastToggle = Tabs.Setting:AddToggle("ToggleFastAttack", {
    Title = "Tốc Đánh",
    Description = "Tắt Thì Max Tốc Đánh",
    Default = true
})
FastToggle:OnChanged(function(Value)
    _G.FastAttack = Value
    if Value then
        local delay = tonumber(_G.FastAttackInput) or 0.5
        _G.Fast_Delay = math.clamp(delay, 0.05, 2)
    else
        _G.Fast_Delay = 1e-9
    end
end)
local FastInput = Tabs.Setting:AddInput("InputFastDelay", {
    Title = "Nhập Tốc Đánh",
    Description = "(0.05s -> 2s)",
    Default = "0.5",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        _G.FastAttackInput = Value
        if _G.FastAttack then
            local delay = tonumber(Value) or 0.5
            _G.Fast_Delay = math.clamp(delay, 0.05, 2)
        end
    end
})
local toggleBringMob = Tabs.Setting:AddToggle("ToggleBringMob", {
    Title = "Gom Quái",
    Description = "",
    Default = true
});
toggleBringMob:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.BringMob = value;
end);
Options.ToggleBringMob:SetValue(true);
spawn(function()
    while wait() do
        pcall(function()
            for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                if (_G.BringMob and bringmob) then
                    if ((enemy.Name == MonFarm) and targetEnemy:FindFirstChild("Humanoid") and (enemy.Humanoid.Health > 0)) then
                        if (enemy.Name == "Factory Staff") then
                            if ((enemy.HumanoidRootPart.Position - FarmPos.Position).Magnitude <= 1000000000) then
                                targetEnemy.Head.CanCollide = false;
                                enemy.HumanoidRootPart.CanCollide = false;
                                enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                enemy.HumanoidRootPart.CFrame = FarmPos;
                                if targetEnemy.Humanoid:FindFirstChild("Animator") then
                                    targetEnemy.Humanoid.Animator:Destroy();
                                end
                                sethiddenproperty(plr, "SimulationRadius", math.huge);
                            end
                        elseif (enemy.Name == MonFarm) then
                            if ((enemy.HumanoidRootPart.Position - FarmPos.Position).Magnitude <= 1000000000) then
                                enemy.HumanoidRootPart.CFrame = FarmPos;
                                enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                enemy.HumanoidRootPart.Transparency = 1;
                                targetEnemy.Humanoid.JumpPower = 0;
                                targetEnemy.Humanoid.WalkSpeed = 0;
                                if targetEnemy.Humanoid:FindFirstChild("Animator") then
                                    targetEnemy.Humanoid.Animator:Destroy();
                                end
                                enemy.HumanoidRootPart.CanCollide = false;
                                targetEnemy.Head.CanCollide = false;
                                targetEnemy.Humanoid:ChangeState(11);
                                targetEnemy.Humanoid:ChangeState(14);
                                sethiddenproperty(plr, "SimulationRadius", math.huge);
                            end
                        end
                    end
                end
            end
        end);
    end
end);
local toggleRemoveNotify = Tabs.Setting:AddToggle("ToggleRemoveNotify", {
    Title = "Xóa Thông Báo",
    Description = "",
    Default = false
});
toggleRemoveNotify:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    RemoveNotify = value;
end);
Options.ToggleRemoveNotify:SetValue(false);
spawn(function()
    while wait() do
        if RemoveNotify then
            plr.PlayerGui.Notifications.Enabled = false;
        else
            plr.PlayerGui.Notifications.Enabled = true;
        end
    end
end);
local toggleWhiteScreen = Tabs.Setting:AddToggle("ToggleWhite", {
    Title = "Màn Hình Trắng",
    Description = "",
    Default = false
});
toggleWhiteScreen:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.WhiteScreen = value;
    if IsResettingConfig then return end
    if (_G.WhiteScreen == true) then
        RunService:Set3dRenderingEnabled(false);
    elseif (_G.WhiteScreen == false) then
        RunService:Set3dRenderingEnabled(true);
    end
end);
Options.ToggleWhite:SetValue(false);
local SettingSection = Tabs.Setting:AddSection("Kĩ Năng Thông Thạo");
local toggleSkillZ = Tabs.Setting:AddToggle("ToggleZ", {
    Title = "Kĩ Năng Z",
    Description = "",
    Default = true
});
toggleSkillZ:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    SkillZ = value;
end);
Options.ToggleZ:SetValue(true);
local toggleSkillX = Tabs.Setting:AddToggle("ToggleX", {
    Title = "Kĩ Năng X",
    Description = "",
    Default = true
});
toggleSkillX:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    SkillX = value;
end);
Options.ToggleX:SetValue(true);
local toggleSkillC = Tabs.Setting:AddToggle("ToggleC", {
    Title = "Kĩ Năng C",
    Description = "",
    Default = true
});
toggleSkillC:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    SkillC = value;
end);
Options.ToggleC:SetValue(true);
local toggleSkillV = Tabs.Setting:AddToggle("ToggleV", {
    Title = "Kĩ Năng V",
    Description = "",
    Default = true
});
toggleSkillV:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    SkillV = value;
end);
Options.ToggleV:SetValue(true);
local toggleSkillF = Tabs.Setting:AddToggle("ToggleF", {
    Title = "Kĩ Năng F",
    Description = "",
    Default = false
});
toggleSkillF:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    SkillF = value;
end);
Options.ToggleF:SetValue(true);

-- Nút Reset Config (Persistent Config)
Tabs.Setting:AddButton({
    Title = "Khôi Phục Thiết Lập Mặc Định",
    Description = "Đưa toàn bộ cài đặt về mặc định",
    Callback = function()
        ResetAllToDefault()
    end
})

local paraServerTime = Tabs.Status:AddParagraph({
    Title = "Thông Tin",
    Content = "━━━━━━━━━━━━━━━━━━━━━\n" .. "Tên : " .. plr.DisplayName .. " (@" .. plr.Name .. ")\n" .. "Cấp : " .. plr.Data.Level.Value .. "\n" .. "Tiền : " .. plr.Data.Beli.Value .. "\n" .. "Điểm F : " .. plr.Data.Fragments.Value .. "\n" .. "Tiền Truy Nã : " .. plr.leaderstats["Bounty/Honor"].Value .. "\n" .. "Máu: " .. plr.Character.Humanoid.Health .. "/" .. plr.Character.Humanoid.MaxHealth .. "\n" .. "Năng Lượng : " .. plr.Character.Energy.Value .. "/" .. plr.Character.Energy.MaxValue .. "\n" .. "Tộc : " .. plr.Data.Race.Value .. "\n" .. "Trái : " .. plr.Data.DevilFruit.Value .. "\n" .. "━━━━━━━━━━━━━━━━━━━━━"
});
local paraLocalTime = Tabs.Status:AddParagraph({
    Title = "Thời Gian",
    Content = ""
});
local function paraUnused16()
    local config = os.date("*t");
    local hour24 = config.hour % 24 ;
    local ampm = ((hour24 < 12) and "AM") or "PM" ;
    local timeStr = string.format("%02i:%02i:%02i %s", ((hour24 - 1) % 12) + 1, config.min, config.sec, ampm);
    local dateStr = string.format("%02d/%02d/%04d", config.day, config.month, config.year);
    local localizationService = LocalizationService;
    local playersService2 = Players;
    local localPlayerForRegion = playersService2.LocalPlayer;
    local playerName = localPlayerForRegion.Name;
    local playerRegion = "Unknown";
    local regionOk, regionResult = pcall(function()
        return localizationService:GetCountryRegionForPlayerAsync(localPlayerForRegion);
    end);
    if regionOk then
        playerRegion = regionResult;
    end
    paraLocalTime:SetDesc(dateStr .. "-" .. timeStr .. " [ " .. playerRegion .. " ]");
end
spawn(function()
    while true do
        paraUnused16();
        RunService.RenderStepped:Wait();
    end
end);
local paraPlayTime = Tabs.Status:AddParagraph({
    Title = "Thời Gian Máy Chủ",
    Content = ""
});
local function paraUnused18()
    local playTimeSeconds = math.floor(workspace.DistributedGameTime + 0.5);
    local playHours = math.floor(playTimeSeconds / (60 ^ 2)) % 24 ;
    local playMinutes = math.floor(playTimeSeconds / 60) % 60 ;
    local playSeconds = playTimeSeconds % 60 ;
    paraPlayTime:SetDesc(string.format("%02d Tiếng-%02d Phút-%02d Giây", playHours, playMinutes, playSeconds));
end
spawn(function()
    while task.wait() do
        pcall(paraUnused18);
    end
end);
local paraFpsPing = Tabs.Status:AddParagraph({
    Title = "Đảo Leviathan",
    Content = ""
});
spawn(function()
    pcall(function()
        while wait() do
            if Workspace.Map:FindFirstChild("FrozenDimension") then
                paraFpsPing:SetDesc("🟢");
            else
                paraFpsPing:SetDesc("🔴");
            end
        end
    end);
end);
local inputJobId = Tabs.Status:AddInput("Input", {
    Title = "Job ID",
    Default = "",
    Placeholder = "Dán Job ID Vào Đây",
    Numeric = false,
    Finished = false,
    Callback = function(value)
    _G.Job = value;
    end
});
Tabs.Status:AddButton({
    Title = "Bắt Đầu Tham Gia Job ID",
    Description = "",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.placeId, _G.Job, plr);
    end
});
Tabs.Status:AddButton({
    Title = "Sao Chép Job ID",
    Description = "",
    Callback = function()
        setclipboard(tostring(game.JobId));
    end
});
local toggleJoinJob = Tabs.Status:AddToggle("MyToggle", {
    Title = "Spam Tham Gia Job ID",
    Default = false
});
toggleJoinJob:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.Join = value;
end);
spawn(function()
    while wait() do
        if _G.Join then
            TeleportService:TeleportToPlaceInstance(game.placeId, _G.Job, plr);
        end
    end
end);
local toggleStatMelee = Tabs.Stats:AddToggle("ToggleMelee", {
    Title = "Nâng Đấm",
    Description = "",
    Default = false
});
toggleStatMelee:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.Auto_Stats_Melee = value;
end);
Options.ToggleMelee:SetValue(false);
local toggleStatDefense = Tabs.Stats:AddToggle("ToggleDe", {
    Title = "Nâng Máu",
    Description = "",
    Default = false
});
toggleStatDefense:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.Auto_Stats_Defense = value;
end);
Options.ToggleDe:SetValue(false);
local toggleStatSword = Tabs.Stats:AddToggle("ToggleSword", {
    Title = "Nâng Kiếm",
    Description = "",
    Default = false
});
toggleStatSword:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.Auto_Stats_Sword = value;
end);
Options.ToggleSword:SetValue(false);
local toggleStatGun = Tabs.Stats:AddToggle("ToggleGun", {
    Title = "Nâng Súng",
    Description = "",
    Default = false
});
toggleStatGun:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.Auto_Stats_Gun = value;
end);
Options.ToggleGun:SetValue(false);
local toggleBuyFruit = Tabs.Stats:AddToggle("ToggleFruit", {
    Title = "Nâng Trái",
    Description = "",
    Default = false
});
toggleBuyFruit:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.Auto_Stats_Devil_Fruit = value;
end);
Options.ToggleFruit:SetValue(false);
spawn(function()
    while wait() do
        if _G.Auto_Stats_Devil_Fruit then
            local loadFruitArgs5 = {
                [1] = "AddPoint",
                [2] = "Demon Fruit",
                [3] = 3
            };
            ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(loadFruitArgs5));
        end
    end
end);
spawn(function()
    while wait() do
        if _G.Auto_Stats_Gun then
            local loadFruitArgs4 = {
                [1] = "AddPoint",
                [2] = "Gun",
                [3] = 3
            };
            ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(loadFruitArgs4));
        end
    end
end);
spawn(function()
    while wait() do
        if _G.Auto_Stats_Sword then
            local loadFruitArgs3 = {
                [1] = "AddPoint",
                [2] = "Sword",
                [3] = 3
            };
            ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(loadFruitArgs3));
        end
    end
end);
spawn(function()
    while wait() do
        if _G.Auto_Stats_Defense then
            local loadFruitArgs2 = {
                [1] = "AddPoint",
                [2] = "Defense",
                [3] = 3
            };
            ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(loadFruitArgs2));
        end
    end
end);
spawn(function()
    while wait() do
        if _G.Auto_Stats_Melee then
            local loadFruitArgs = {
                [1] = "AddPoint",
                [2] = "Melee",
                [3] = 3
            };
            ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(loadFruitArgs));
        end
    end
end);
local playerNameList = {};
for _, player in pairs(Players:GetChildren()) do
    table.insert(playerNameList, player.Name);
end
local dropdownSelectPlayer = Tabs.Player:AddDropdown("SelectedPly", {
    Title = "Chọn Người Chơi",
    Description = "",
    Values = playerNameList,
    Multi = false,
    Default = 1
});
dropdownSelectPlayer:SetValue(_G.SelectPly);
dropdownSelectPlayer:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.SelectPly = value;
end);
Tabs.Player:AddButton({
    Title = "Tải Lại Người Chơi",
    Description = "",
    Callback = function()
        table.clear(playerNameList);
        for _, player in pairs(Players:GetChildren()) do
            table.insert(playerNameList, player.Name);
        end
    end
});
local toggleTeleportPlayer = Tabs.Player:AddToggle("ToggleTeleport", {
    Title = "Bay Đến Người Chơi",
    Description = "",
    Default = false
});
toggleTeleportPlayer:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.TeleportPly = value;
    if (value == false) then
        CancelTween()
    end
end);
Options.ToggleTeleport:SetValue(false);
spawn(function()
    while wait() do
        if _G.TeleportPly then
            pcall(function()
                if Players:FindFirstChild(_G.SelectPly) then
                    Tween(Players[_G.SelectPly].Character.HumanoidRootPart.CFrame, true);
                end
            end);
        end
    end
end);
local _section = Tabs.Player:AddSection("Khác");
local toggleNoClip = Tabs.Player:AddToggle("ToggleNoClip", {
    Title = "Đi Xuyên Tường",
    Description = "",
    Default = true
});
toggleNoClip:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.LOf = value;
end);
Options.ToggleNoClip:SetValue(true);
spawn(function()
    pcall(function()
        RunService.Stepped:Connect(function()
            if _G.LOf then
                for _, descendant in pairs(plr.Character:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        descendant.CanCollide = false;
                    end
                end
            end
        end);
    end);
end);
local toggleWalkonWater = Tabs.Player:AddToggle("ToggleWalkonWater", {
    Title = "Đi Trên Nước",
    Description = "",
    Default = true
});
toggleWalkonWater:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.WalkonWater = value;
end);
Options.ToggleWalkonWater:SetValue(true);
spawn(function()
    while task.wait() do
        pcall(function()
            if _G.WalkonWater then
                Workspace.Map["WaterBase-Plane"].Size = Vector3.new(1000, 112, 1000);
            else
                Workspace.Map["WaterBase-Plane"].Size = Vector3.new(1000, 80, 1000);
            end
        end);
    end
end);
local toggleEnablePvp = Tabs.Player:AddToggle("ToggleEnablePvp", {
    Title = "Bật PVP",
    Description = "",
    Default = false
});
toggleEnablePvp:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.EnabledPvP = value;
end);
Options.ToggleEnablePvp:SetValue(false);
spawn(function()
    pcall(function()
        while wait() do
            if _G.EnabledPvP then
                if (plr.PlayerGui.Main.PvpDisabled.Visible == true) then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("EnablePvp");
                end
            end
        end
    end);
end);
local TeleportSection = Tabs.Teleport:AddSection("Thế Giới");
local toggleAutoSea2 = Tabs.Teleport:AddToggle("ToggleAutoSea2", {
    Title = "Nhiệm Vụ Qua Biển 2",
    Description = "",
    Default = false
});
toggleAutoSea2:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.Auto_Sea2 = value;
end);
Options.ToggleAutoSea2:SetValue(false);
spawn(function()
    while task.wait() do
        if _G.Auto_Sea2 then
            pcall(function()
                local level = plr.Data.Level.Value
                if level >= 700 and Sea1 then
                    local door = Workspace.Map.Ice.Door
                    if door.CanCollide == true or door.Transparency < 1 then
                        local detectiveCF = CFrame.new(4849.29883, 5.65138149, 719.611877)
                        Tween(detectiveCF)
                        repeat task.wait() until (detectiveCF.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 5 or not _G.Auto_Sea2
                        task.wait(1)
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("DressrosaQuestProgress", "Detective")
                        task.wait(0.5)
                        EquipTool("Key")
                        local keyCF = CFrame.new(1347.7124, 37.3751602, -1325.6488)
                        Tween(keyCF)
                        repeat task.wait() until (keyCF.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 5 or not _G.Auto_Sea2
                        task.wait(0.5)
                    else
                        if Workspace.Enemies:FindFirstChild("Ice Admiral") then
                            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                                if v.Name == "Ice Admiral" and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    local oldCF = v.HumanoidRootPart.CFrame
                                    repeat
                                        task.wait(_G.Fast_Delay or 0.1)
                                        AutoHaki()
                                        EquipTool(SelectWeapon)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                        v.HumanoidRootPart.CFrame = oldCF
                                        Tween(v.HumanoidRootPart.CFrame * Pos)
                                        AttackNoCoolDown()
                                        sethiddenproperty(plr, "SimulationRadius", math.huge)
                                    until not _G.Auto_Sea2 or not v.Parent or v.Humanoid.Health <= 0
                                    ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
                                end
                            end
                        elseif ReplicatedStorage:FindFirstChild("Ice Admiral") then
                            Tween(ReplicatedStorage["Ice Admiral"].HumanoidRootPart.CFrame * CFrame.new(5, 10, 7))
                        end
                    end
                end
            end)
        end
    end
end)
local toggleAutoSea3 = Tabs.Teleport:AddToggle("ToggleAutoSea3", {
    Title = "Nhiệm Vụ Qua Biển 3",
    Description = "",
    Default = false
});
toggleAutoSea3:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.Auto_Sea3 = value;
end);
Options.ToggleAutoSea3:SetValue(false);
spawn(function()
    while task.wait() do
        if _G.Auto_Sea3 then
            pcall(function()
                local level = plr.Data.Level.Value
                if level >= 1500 and Sea2 then
                    _G.AutoLevel = false
                    if ReplicatedStorage.Remotes.CommF_:InvokeServer("ZQuestProgress", "General") == 0 then
                        local startCF = CFrame.new(-1926.3221435547, 12.819851875305, 1738.3092041016)
                        Tween(startCF)
                        repeat task.wait() until (startCF.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 10 or not _G.Auto_Sea3
                        task.wait(1.5)
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("ZQuestProgress", "Begin")
                        task.wait(1.8)
                        if Workspace.Enemies:FindFirstChild("rip_indra") then
                            for _, v in pairs(Workspace.Enemies:GetChildren()) do
                                if v.Name == "rip_indra" and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                                    local oldCF = v.HumanoidRootPart.CFrame
                                    repeat
                                        task.wait(_G.Fast_Delay or 0.1)
                                        AutoHaki()
                                        EquipTool(SelectWeapon)
                                        Tween(v.HumanoidRootPart.CFrame * Pos)
                                        v.HumanoidRootPart.CFrame = oldCF
                                        v.HumanoidRootPart.Size = Vector3.new(50, 50, 50)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.Humanoid.WalkSpeed = 0
                                        AttackNoCoolDown()
                                        ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou")
                                    until not _G.Auto_Sea3 or v.Humanoid.Health <= 0 or not v.Parent
                                end
                            end
                        else
                            local indraCF = CFrame.new(-26880.93359375, 22.848554611206, 473.18951416016)
                            if (indraCF.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 1000 then
                                Tween(indraCF)
                            end
                        end
                    end
                end
            end)
        end
    end
end)
Tabs.Teleport:AddButton({
    Title = "Biển 1",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelMain")
    end
});
Tabs.Teleport:AddButton({
    Title = "Biển 2",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
    end
});
Tabs.Teleport:AddButton({
    Title = "Biển 3",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou")
    end
});
local _section = Tabs.Teleport:AddSection("Đảo");
if Sea1 then
    IslandList = {
        "WindMill",
        "Marine",
        "Middle Town",
        "Jungle",
        "Pirate Village",
        "Desert",
        "Snow Island",
        "MarineFord",
        "Colosseum",
        "Sky Island 1",
        "Sky Island 2",
        "Sky Island 3",
        "Prison",
        "Magma Village",
        "Under Water Island",
        "Fountain City",
        "Shank Room",
        "Mob Island"
    };
elseif Sea2 then
    IslandList = {
        "The Cafe",
        "Frist Spot",
        "Dark Area",
        "Flamingo Mansion",
        "Flamingo Room",
        "Green Zone",
        "Factory",
        "Colossuim",
        "Zombie Island",
        "Two Snow Mountain",
        "Punk Hazard",
        "Cursed Ship",
        "Ice Castle",
        "Forgotten Island",
        "Ussop Island",
        "Mini Sky Island"
    };
elseif Sea3 then
    IslandList = {
        "Mansion",
        "Port Town",
        "Great Tree",
        "Castle On The Sea",
        "MiniSky",
        "Hydra Island",
        "Floating Turtle",
        "Haunted Castle",
        "Ice Cream Island",
        "Peanut Island",
        "Cake Island",
        "Cocoa Island",
        "Candy Island",
        "Tiki Outpost"
    };
end
local dropdownIsland = Tabs.Teleport:AddDropdown("DropdownIsland", {
    Title = "Chọn Đảo",
    Description = "",
    Values = IslandList,
    Multi = false,
    Default = 1
});
dropdownIsland:SetValue(_G.SelectIsland);
dropdownIsland:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.SelectIsland = value;
end);
Tabs.Teleport:AddButton({
    Title = "Bay Đến Đảo",
    Description = "",
    Callback = function()
        _G.StopTween = false;
        if (_G.SelectIsland == "WindMill") then
            Tween(CFrame.new(979.79895019531, 16.516613006592, 1429.0466308594), true);
        elseif (_G.SelectIsland == "Marine") then
            Tween(CFrame.new(- 2566.4296875, 6.8556680679321, 2045.2561035156), true);
        elseif (_G.SelectIsland == "Middle Town") then
            Tween(CFrame.new(- 690.33081054688, 15.09425163269, 1582.2380371094), true);
        elseif (_G.SelectIsland == "Jungle") then
            Tween(CFrame.new(- 1612.7957763672, 36.852081298828, 149.12843322754), true);
        elseif (_G.SelectIsland == "Pirate Village") then
            Tween(CFrame.new(- 1181.3093261719, 4.7514905929565, 3803.5456542969), true);
        elseif (_G.SelectIsland == "Desert") then
            Tween(CFrame.new(944.15789794922, 20.919729232788, 4373.3002929688), true);
        elseif (_G.SelectIsland == "Snow Island") then
            Tween(CFrame.new(1347.8067626953, 104.66806030273, - 1319.7370605469), true);
        elseif (_G.SelectIsland == "MarineFord") then
            Tween(CFrame.new(- 4914.8212890625, 50.963626861572, 4281.0278320313), true);
        elseif (_G.SelectIsland == "Colosseum") then
            Tween(CFrame.new(- 1427.6203613281, 7.2881078720093, - 2792.7722167969), true);
        elseif (_G.SelectIsland == "Sky Island 1") then
            Tween(CFrame.new(- 4869.1025390625, 733.46051025391, - 2667.0180664063), true);
        elseif (_G.SelectIsland == "Sky Island 2") then
            GameTeleport(Vector3.new(- 4607.82275, 872.54248, - 1667.55688));
        elseif (_G.SelectIsland == "Sky Island 3") then
            GameTeleport(Vector3.new(- 7894.6176757813, 5547.1416015625, - 380.29119873047));
        elseif (_G.SelectIsland == "Prison") then
            Tween(CFrame.new(4875.330078125, 5.6519818305969, 734.85021972656), true);
        elseif (_G.SelectIsland == "Magma Village") then
            Tween(CFrame.new(- 5247.7163085938, 12.883934020996, 8504.96875), true);
        elseif (_G.SelectIsland == "Under Water Island") then
            GameTeleport(Vector3.new(61163.8515625, 11.6796875, 1819.7841796875));
        elseif (_G.SelectIsland == "Fountain City") then
            Tween(CFrame.new(5127.1284179688, 59.501365661621, 4105.4458007813), true);
        elseif (_G.SelectIsland == "Shank Room") then
            Tween(CFrame.new(- 1442.16553, 29.8788261, - 28.3547478), true);
        elseif (_G.SelectIsland == "Mob Island") then
            Tween(CFrame.new(- 2850.20068, 7.39224768, 5354.99268), true);
        elseif (_G.SelectIsland == "The Cafe") then
            GameTeleport(Vector3.new(- 281.93707275390625, 306.130615234375, 609.280029296875));
            wait();
            Tween(CFrame.new(- 380.47927856445, 77.220390319824, 255.82550048828), true);
        elseif (_G.SelectIsland == "Frist Spot") then
            Tween(CFrame.new(- 11.311455726624, 29.276733398438, 2771.5224609375), true);
        elseif (_G.SelectIsland == "Dark Area") then
            Tween(CFrame.new(3780.0302734375, 22.652164459229, - 3498.5859375), true);
        elseif (_G.SelectIsland == "Flamingo Mansion") then
            GameTeleport(Vector3.new(- 281.93707275390625, 306.130615234375, 609.280029296875));
        elseif (_G.SelectIsland == "Flamingo Room") then
            GameTeleport(Vector3.new(2284.912109375, 15.152034759521484, 905.48291015625));
        elseif (_G.SelectIsland == "Green Zone") then
            Tween(CFrame.new(- 2448.5300292969, 73.016105651855, - 3210.6306152344), true);
        elseif (_G.SelectIsland == "Factory") then
            Tween(CFrame.new(424.12698364258, 211.16171264648, - 427.54049682617), true);
        elseif (_G.SelectIsland == "Colossuim") then
            Tween(CFrame.new(- 1503.6224365234, 219.7956237793, 1369.3101806641), true);
        elseif (_G.SelectIsland == "Zombie Island") then
            Tween(CFrame.new(- 5622.033203125, 492.19604492188, - 781.78552246094), true);
        elseif (_G.SelectIsland == "Two Snow Mountain") then
            Tween(CFrame.new(753.14288330078, 408.23559570313, - 5274.6147460938), true);
        elseif (_G.SelectIsland == "Punk Hazard") then
            Tween(CFrame.new(- 6127.654296875, 15.951762199402, - 5040.2861328125), true);
        elseif (_G.SelectIsland == "Cursed Ship") then
            GameTeleport(Vector3.new(923.40197753906, 125.05712890625, 32885.875));
        elseif (_G.SelectIsland == "Ice Castle") then
            Tween(CFrame.new(6148.4116210938, 294.38687133789, - 6741.1166992188), true);
        elseif (_G.SelectIsland == "Forgotten Island") then
            Tween(CFrame.new(- 3032.7641601563, 317.89672851563, - 10075.373046875), true);
        elseif (_G.SelectIsland == "Ussop Island") then
            Tween(CFrame.new(4816.8618164063, 8.4599885940552, 2863.8195800781), true);
        elseif (_G.SelectIsland == "Mini Sky Island") then
            Tween(CFrame.new(- 288.74060058594, 49326.31640625, - 35248.59375), true);
        elseif (_G.SelectIsland == "Great Tree") then
            Tween(CFrame.new(2681.2736816406, 1682.8092041016, - 7190.9853515625), true);
        elseif (_G.SelectIsland == "Castle On The Sea") then
            GameTeleport(Vector3.new(- 5075.50927734375, 314.5155029296875, - 3150.0224609375));
        elseif (_G.SelectIsland == "MiniSky") then
            Tween(CFrame.new(- 260.65557861328, 49325.8046875, - 35253.5703125), true);
        elseif (_G.SelectIsland == "Port Town") then
            Tween(CFrame.new(- 290.7376708984375, 6.729952812194824, 5343.5537109375), true);
        elseif (_G.SelectIsland == "Hydra Island") then
            GameTeleport(Vector3.new(5661.5322265625, 1013.0907592773438, - 334.9649963378906));
        elseif (_G.SelectIsland == "Floating Turtle") then
            Tween(CFrame.new(- 13274.528320313, 531.82073974609, - 7579.22265625), true);
        elseif (_G.SelectIsland == "Mansion") then
            GameTeleport(Vector3.new(- 12468.5380859375, 375.0094299316406, - 7554.62548828125));
        elseif (_G.SelectIsland == "Haunted Castle") then
            Tween(CFrame.new(- 9515.3720703125, 164.00624084473, 5786.0610351562), true);
        elseif (_G.SelectIsland == "Ice Cream Island") then
            Tween(CFrame.new(- 902.56817626953, 79.93204498291, - 10988.84765625), true);
        elseif (_G.SelectIsland == "Peanut Island") then
            Tween(CFrame.new(- 2062.7475585938, 50.473892211914, - 10232.568359375), true);
        elseif (_G.SelectIsland == "Cake Island") then
            Tween(CFrame.new(- 1884.7747802734375, 19.327526092529297, - 11666.8974609375), true);
        elseif (_G.SelectIsland == "Cocoa Island") then
            Tween(CFrame.new(87.94276428222656, 73.55451202392578, - 12319.46484375), true);
        elseif (_G.SelectIsland == "Candy Island") then
            Tween(CFrame.new(- 1014.4241943359375, 149.11068725585938, - 14555.962890625), true);
        elseif (_G.SelectIsland == "Tiki Outpost") then
            Tween(CFrame.new(- 16542.447265625, 55.68632888793945, 1044.41650390625), true);
        end
    end
});
Tabs.Teleport:AddButton({
    Title = "Dừng Bay",
    Description = "",
    Callback = function()
        CancelTween();
    end
});
local fruitListData = ReplicatedStorage:FindFirstChild("Remotes").CommF_:InvokeServer("GetFruits");
Table_DevilFruitSniper = {};
ShopDevilSell = {};
for fruitIdx, fruitData in next, fruitListData do
    table.insert(Table_DevilFruitSniper, fruitData.Name);
    if fruitData.OnSale then
        table.insert(ShopDevilSell, fruitData.Name);
    end
end
_G.SelectFruit = "Dragon-Dragon";
_G.PermanentFruit = "Dragon-Dragon";
_G.AutoBuyFruitSniper = false;
_G.AutoSwitchPermanentFruit = false;
local dropdownFruit = Tabs.Fruit:AddDropdown("DropdownFruit", {
    Title = "Chọn Trái",
    Description = "",
    Values = Table_DevilFruitSniper,
    Multi = false,
    Default = 1
});
dropdownFruit:SetValue(_G.SelectFruit);
dropdownFruit:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.SelectFruit = value;
end);
local toggleBuyFruit = Tabs.Fruit:AddToggle("ToggleFruit", {
    Title = "Mua Trái Chọn",
    Description = "",
    Default = false
});
toggleBuyFruit:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value then
        _G.AutoBuyFruitSniper = true;
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("GetFruits");
            ReplicatedStorage.Remotes.CommF_:InvokeServer("PurchaseRawFruit", _G.SelectFruit, false);
        end);
        _G.AutoBuyFruitSniper = false;
    end
end);
Options.ToggleFruit:SetValue(false);
local dropdownPermanentFruit = Tabs.Fruit:AddDropdown("DropdownPermanentFruit", {
    Title = "Chọn Trái Vĩnh Viễn",
    Description = "",
    Values = Table_DevilFruitSniper,
    Multi = false,
    Default = 1
});
dropdownPermanentFruit:SetValue(_G.PermanentFruit);
dropdownPermanentFruit:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.PermanentFruit = value;
end);
local togglePermanentFruit = Tabs.Fruit:AddToggle("TogglePermanentFruit", {
    Title = "Đổi Trái Vĩnh Viễn",
    Description = "",
    Default = false
});
togglePermanentFruit:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value then
        _G.AutoSwitchPermanentFruit = true;
        pcall(function()
            local switchFruitArgs = {
                [1] = "SwitchFruit",
                [2] = _G.PermanentFruit
            };
            ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(switchFruitArgs));
        end);
        _G.AutoSwitchPermanentFruit = false;
    end
end);
Options.TogglePermanentFruit:SetValue(false);
local toggleStoreFruit = Tabs.Fruit:AddToggle("ToggleStore", {
    Title = "Lưu Trái",
    Description = "",
    Default = false
});
toggleStoreFruit:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoStoreFruit = value;
end);
Options.ToggleStore:SetValue(false);
spawn(function()
    while task.wait() do
        if _G.AutoStoreFruit then
            pcall(function()
                if _G.AutoStoreFruit then
                    if (plr.Character:FindFirstChild("Bomb Fruit") or plr.Backpack:FindFirstChild("Bomb Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Bomb-Bomb", plr.Backpack:FindFirstChild("Bomb Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Spike Fruit") or plr.Backpack:FindFirstChild("Spike Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Spike-Spike", plr.Backpack:FindFirstChild("Spike Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Chop Fruit") or plr.Backpack:FindFirstChild("Chop Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Chop-Chop", plr.Backpack:FindFirstChild("Chop Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Spring Fruit") or plr.Backpack:FindFirstChild("Spring Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Spring-Spring", plr.Backpack:FindFirstChild("Spring Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Rocket Fruit") or plr.Backpack:FindFirstChild("Kilo Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Rocket-Rocket", plr.Backpack:FindFirstChild("Kilo Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Smoke Fruit") or plr.Backpack:FindFirstChild("Smoke Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Smoke-Smoke", plr.Backpack:FindFirstChild("Smoke Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Spin Fruit") or plr.Backpack:FindFirstChild("Spin Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Spin-Spin", plr.Backpack:FindFirstChild("Spin Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Flame Fruit") or plr.Backpack:FindFirstChild("Flame Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Flame-Flame", plr.Backpack:FindFirstChild("Flame Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Falcon Fruit") or plr.Backpack:FindFirstChild("Falcon Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Falcon", plr.Backpack:FindFirstChild("alcon Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Ice Fruit") or plr.Backpack:FindFirstChild("Ice Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Ice-Ice", plr.Backpack:FindFirstChild("Ice Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Sand Fruit") or plr.Backpack:FindFirstChild("Sand Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Sand-Sand", plr.Backpack:FindFirstChild("Sand Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Dark Fruit") or plr.Backpack:FindFirstChild("Dark Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Dark-Dark", plr.Backpack:FindFirstChild("Dark Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Ghost Fruit") or plr.Backpack:FindFirstChild("Revive Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Ghost-Ghost", plr.Backpack:FindFirstChild("Revive Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Diamond Fruit") or plr.Backpack:FindFirstChild("Diamond Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Diamond-Diamond", plr.Backpack:FindFirstChild("Diamond Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Light Fruit") or plr.Backpack:FindFirstChild("Light Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Light-Light", plr.Backpack:FindFirstChild("Light Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Love Fruit") or plr.Backpack:FindFirstChild("Love Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Love-Love", plr.Backpack:FindFirstChild("Love Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Rubber Fruit") or plr.Backpack:FindFirstChild("Rubber Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Rubber-Rubber", plr.Backpack:FindFirstChild("Rubber Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Barrier Fruit") or plr.Backpack:FindFirstChild("Barrier Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Barrier-Barrier", plr.Backpack:FindFirstChild("Barrier Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Magma Fruit") or plr.Backpack:FindFirstChild("Magma Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Magma-Magma", plr.Backpack:FindFirstChild("Magma Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Portal Fruit") or plr.Backpack:FindFirstChild("Portal Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Door-Door", plr.Backpack:FindFirstChild("Portal Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Quake Fruit") or plr.Backpack:FindFirstChild("Quake Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Quake-Quake", plr.Backpack:FindFirstChild("Quake Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Buddha Fruit") or plr.Backpack:FindFirstChild("Buddha Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("Buddha", plr.Backpack:FindFirstChild("Buddha Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Spider Fruit") or plr.Backpack:FindFirstChild("Spider Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Spider-Spider", plr.Backpack:FindFirstChild("Spider Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Bird: Phoenix Fruit") or plr.Backpack:FindFirstChild("Phoenix Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Phoenix", plr.Backpack:FindFirstChild("Phoenix Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Rumble Fruit") or plr.Backpack:FindFirstChild("Rumble Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Rumble-Rumble", plr.Backpack:FindFirstChild("Rumble Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Pain Fruit") or plr.Backpack:FindFirstChild("Pain Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Pain-Pain", plr.Backpack:FindFirstChild("Pain Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Gravity Fruit") or plr.Backpack:FindFirstChild("Gravity Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Gravity-Gravity", plr.Backpack:FindFirstChild("Gravity Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Dough Fruit") or plr.Backpack:FindFirstChild("Dough Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Dough-Dough", plr.Backpack:FindFirstChild("Dough Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Shadow Fruit") or plr.Backpack:FindFirstChild("Shadow Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Shadow-Shadow", plr.Backpack:FindFirstChild("Shadow Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Venom Fruit") or plr.Backpack:FindFirstChild("Venom Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Venom-Venom", plr.Backpack:FindFirstChild("Venom Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Control Fruit") or plr.Backpack:FindFirstChild("Control Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Control-Control", plr.Backpack:FindFirstChild("Control Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Spirit Fruit") or plr.Backpack:FindFirstChild("Spirit Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Soul-Soul", plr.Backpack:FindFirstChild("Spirit Fruit"));
                    end
                    if (plr.Character:FindFirstChild("Dragon Fruit") or plr.Backpack:FindFirstChild("Dragon Fruit")) then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Dragon-Dragon", plr.Backpack:FindFirstChild("Dragon Fruit"));
                        if (plr.Character:FindFirstChild("Leopard Fruit") or plr.Backpack:FindFirstChild("Leopard Fruit")) then
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("StoreFruit", "Leopard-Leopard", plr.Backpack:FindFirstChild("Leopard Fruit"));
                        end
                    end
                end
            end);
        end
        wait();
    end
end);
local toggleRandomFruit = Tabs.Fruit:AddToggle("ToggleRandomFruit", {
    Title = "Random Trái",
    Description = "",
    Default = false
});
toggleRandomFruit:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.Random_Auto = value;
end);
Options.ToggleRandomFruit:SetValue(false);
spawn(function()
    pcall(function()
        while wait() do
            if _G.Random_Auto then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Cousin", "Buy");
            end
        end
    end);
end);
local toggleCollectFruitTP = Tabs.Fruit:AddToggle("ToggleCollectTP", {
    Title = "Bay Đến Trái",
    Description = "",
    Default = false
});
toggleCollectFruitTP:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.CollectFruitTP = value;
end);
Options.ToggleCollectTP:SetValue(false);
spawn(function()
    while wait() do
        if _G.CollectFruitTP then
            for _, child in pairs(Workspace:GetChildren()) do
                if string.find(child.Name, "Fruit") and child:FindFirstChild("Handle") then
                    pcall(function()
                        plr.Character.HumanoidRootPart.CFrame = child.Handle.CFrame
                    end)
                end
            end
        end
    end
end);
local toggleTweenFruit = Tabs.Fruit:AddToggle("ToggleCollect", {
    Title = "Dịch Chuyển Đến Trái",
    Description = "",
    Default = false
});
toggleTweenFruit:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.Tweenfruit = value;
end);
Options.ToggleCollect:SetValue(false);
spawn(function()
    while wait() do
        if _G.Tweenfruit then
            for _, child in pairs(Workspace:GetChildren()) do
                if string.find(child.Name, "Fruit") and child:FindFirstChild("Handle") then
                    pcall(function()
                        Tween(child.Handle.CFrame)
                    end)
                end
            end
        end
    end
end);
local _section = Tabs.Fruit:AddSection("Định Vị");
local toggleEspPlayer = Tabs.Fruit:AddToggle("ToggleEspPlayer", {
    Title = "Người Chơi",
    Description = "",
    Default = false
});
toggleEspPlayer:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    ESPPlayer = value;
    UpdatePlayerChams();
end);
Options.ToggleEspPlayer:SetValue(false);
local toggleEspFruit = Tabs.Fruit:AddToggle("ToggleEspFruit", {
    Title = "Trái",
    Description = "",
    Default = false
});
toggleEspFruit:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    DevilFruitESP = value
end);
Options.ToggleEspFruit:SetValue(false);
local toggleEspIsland = Tabs.Fruit:AddToggle("ToggleEspIsland", {
    Title = "Đảo",
    Description = "",
    Default = false
});
toggleEspIsland:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    IslandESP = value
end);
Options.ToggleEspIsland:SetValue(false);
local toggleEspFlower = Tabs.Fruit:AddToggle("ToggleEspFlower", {
    Title = "Hoa",
    Description = "",
    Default = false
});
toggleEspFlower:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    FlowerESP = value;
    UpdateFlowerChams();
end);
Options.ToggleEspFlower:SetValue(false);
spawn(function()
    while wait() do
        if FlowerESP then
            UpdateFlowerChams()
        end
        if DevilFruitESP then
            UpdateDevilChams()
        end
        if ChestESP then
            UpdateChestChams()
        end
        if ESPPlayer then
            UpdatePlayerChams()
        end
        if RealFruitESP then
            UpdateRealFruitChams()
        end
        if MirageIslandESP then
            UpdateIslandMirageESP()
        end
        if IslandESP then
            UpdateIslandESP()
        end
    end
end);
local toggleEspRealFruit = Tabs.Fruit:AddToggle("ToggleEspRealFruit", {
    Title = "Trái Dứa Khớm Táo",
    Description = "",
    Default = false
});
toggleEspRealFruit:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    RealFruitESP = value
end);
Options.ToggleEspRealFruit:SetValue(false);

local toggleEspMirageIsland = Tabs.Fruit:AddToggle("ToggleIslandMirageEsp", {
    Title = "Đảo Bí Ẩn",
    Description = "",
    Default = false
});
toggleEspMirageIsland:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    MirageIslandESP = value
end);
Options.ToggleIslandMirageEsp:SetValue(false);

local raidChipList = {
    "Flame",
    "Ice",
    "Quake",
    "Light",
    "Dark",
    "Spider",
    "Rumble",
    "Magma",
    "Buddha",
    "Sand",
    "Phoenix",
    "Dough"
};
local dropdownRaid = Tabs.Raid:AddDropdown("DropdownRaid", {
    Title = "Chọn Chip",
    Description = "",
    Values = raidChipList,
    Multi = false,
    Default = 1
});
dropdownRaid:SetValue(SelectChip);
dropdownRaid:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    SelectChip = value;
end);
local toggleBuyChip = Tabs.Raid:AddToggle("ToggleBuy", {
    Title = "Mua Chip",
    Description = "",
    Default = false
});
toggleBuyChip:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.Auto_Buy_Chips_Dungeon = value;
end);
Options.ToggleBuy:SetValue(false);
spawn(function()
    while wait() do
        if _G.Auto_Buy_Chips_Dungeon then
            pcall(function()
                local raidSelectArgs = {
                    [1] = "RaidsNpc",
                    [2] = "Select",
                    [3] = SelectChip
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(raidSelectArgs));
            end);
        end
    end
end);
local toggleStartRaid = Tabs.Raid:AddToggle("ToggleStart", {
    Title = "Bắt Đầu Raid",
    Description = "",
    Default = false
});
toggleStartRaid:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.Auto_StartRaid = value;
end);
Options.ToggleStart:SetValue(false);
spawn(function()
    while wait() do
        pcall(function()
            if _G.Auto_StartRaid then
                if (Players['LocalPlayer'].PlayerGui.Main.Timer.Visible == false) then
                    if (not Workspace['_WorldOrigin'].Locations:FindFirstChild("Island 1") and (plr.Backpack:FindFirstChild("Special Microchip") or plr.Character:FindFirstChild("Special Microchip"))) then
                        if Sea2 then
                            Tween(CFrame.new(- 6438.73535, 250.645355, - 4501.50684), true);
                            local setSpawnArgs = {
                                [1] = "SetSpawnPoint"
                            };
                            ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(setSpawnArgs));
                            fireclickdetector(Workspace.Map.CircleIsland.RaidSummon2.Button.Main.ClickDetector);
                        elseif Sea3 then
                            GameTeleport(Vector3.new(- 5075.50927734375, 314.5155029296875, - 3150.0224609375));
                            Tween(CFrame.new(- 5017.40869, 314.844055, - 2823.0127, - 0.925743818, 4.482175e-8, - 0.378151238, 4.5550315e-9, 1, 1.0737756e-7, 0.378151238, 9.768162e-8, - 0.925743818), true);
                            local setSpawnArgs2 = {
                                [1] = "SetSpawnPoint"
                            };
                            ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(setSpawnArgs2));
                            fireclickdetector(Workspace.Map["Boat Castle"].RaidSummon2.Button.Main.ClickDetector);
                        end
                    end
                end
            end
        end);
    end
end);
local toggleNextIsland = Tabs.Raid:AddToggle("ToggleNextIsland", {
    Title = "Đấm Quái Raid+Bay Đến Đảo",
    Description = "",
    Default = false
});
toggleNextIsland:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    AutoNextIsland = value
    if not value then
        _G.AutoNear = false
    end
end)
Options.ToggleNextIsland:SetValue(false);
spawn(function()
    local flag = {};
    while task.wait() do
        if AutoNextIsland then
            pcall(function()
                local raidPlayerChar = plr.Character
                if raidPlayerChar and raidPlayerChar:FindFirstChild("HumanoidRootPart") then
                    local locations = Workspace["_WorldOrigin"].Locations
                    local raidCharPos = raidPlayerChar.HumanoidRootPart.Position

                    -- Reset flag khi đứng ở chỗ bắt đầu Raid
                    if (raidCharPos - Vector3.new(-6438.73535, 250.645355, -4501.50684)).Magnitude < 10
                        or (raidCharPos - Vector3.new(-5017.40869, 314.844055, -2823.0127)).Magnitude < 10 then
                        flag = {}
                    end

                    if locations:FindFirstChild("Island 1") then
                        _G.AutoNear = true
                    end

                    if locations:FindFirstChild("Island 2") and not flag["Island 2"] then
                        Tween(locations["Island 2"].CFrame)
                        flag["Island 2"] = true
                    elseif locations:FindFirstChild("Island 3") and not flag["Island 3"] then
                        Tween(locations["Island 3"].CFrame)
                        flag["Island 3"] = true
                    elseif locations:FindFirstChild("Island 4") and not flag["Island 4"] then
                        Tween(locations["Island 4"].CFrame)
                        flag["Island 4"] = true
                    elseif locations:FindFirstChild("Island 5") and not flag["Island 5"] then
                        Tween(locations["Island 5"].CFrame)
                        flag["Island 5"] = true
                    end
                end
            end);
        end
    end
end);
local toggleAwake = Tabs.Raid:AddToggle("ToggleAwake", {
    Title = "Thức Tỉnh",
    Description = "",
    Default = false
});
toggleAwake:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    AutoAwakenAbilities = value;
end);
Options.ToggleAwake:SetValue(false);
spawn(function()
    while task.wait() do
        if AutoAwakenAbilities then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Awakener", "Awaken");
            end);
        end
    end
end);
local toggleGetFruit = Tabs.Raid:AddToggle("ToggleGetFruit", {
    Title = "Lấy Trái Dưới 1 Triệu",
    Description = "",
    Default = false
});
toggleGetFruit:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.Autofruit = value;
end);
spawn(function()
    while wait() do
        pcall(function()
            if _G.Autofruit then
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Rocket-Rocket"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Spin-Spin"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Chop-Chop"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Spring-Spring"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Bomb-Bomb"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Smoke-Smoke"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Spike-Spike"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Flame-Flame"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Falcon-Falcon"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Ice-Ice"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Sand-Sand"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Dark-Dark"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Ghost-Ghost"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Diamond-Diamond"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Light-Light"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Rubber-Rubber"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
                local prompt = {
                    [1] = "LoadFruit",
                    [2] = "Barrier-Barrier"
                };
                ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(prompt));
            end
        end);
    end
end);
if Sea2 then
    Tabs.Raid:AddButton({
        Title = "Bay Đến Chỗ Tập Kích",
        Description = "",
        Callback = function()
            _G.StopTween = false;
            Tween(CFrame.new(- 6438.73535, 250.645355, - 4501.50684), true);
        end
    });
elseif Sea3 then
    Tabs.Raid:AddButton({
        Title = "Bay Đến Chỗ Tập Kích",
        Description = "",
        Callback = function()
            _G.StopTween = false;
            GameTeleport(Vector3.new(- 5075.50927734375, 314.5155029296875, - 3150.0224609375));
            Tween(CFrame.new(- 5017.40869, 314.844055, - 2823.0127, - 0.925743818, 4.482175e-8, - 0.378151238, 4.5550315e-9, 1, 1.0737756e-7, 0.378151238, 9.768162e-8, - 0.925743818), true);
        end
    });
end
local _section = Tabs.Raid:AddSection("Tập Kích Law");
local toggleLaw = Tabs.Raid:AddToggle("ToggleLaw", {
    Title = "Mua Chip Và Đấm Law",
    Description = "",
    Default = false
});
toggleLaw:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    Auto_Law = value;
end);
Options.ToggleLaw:SetValue(false);
spawn(function()
    pcall(function()
        while wait() do
            if Auto_Law then
                if (not plr.Character:FindFirstChild("Microchip") and not plr.Backpack:FindFirstChild("Microchip") and not Workspace.Enemies:FindFirstChild("Order") and not ReplicatedStorage:FindFirstChild("Order")) then
                    wait();
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Microchip", "1");
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Microchip", "2");
                end
            end
        end
    end);
end);
spawn(function()
    pcall(function()
        while wait() do
            if Auto_Law then
                if (not Workspace.Enemies:FindFirstChild("Order") and not ReplicatedStorage:FindFirstChild("Order")) then
                    if (plr.Character:FindFirstChild("Microchip") or plr.Backpack:FindFirstChild("Microchip")) then
                        fireclickdetector(Workspace.Map.CircleIsland.RaidSummon.Button.Main.ClickDetector);
                    end
                end
                if (ReplicatedStorage:FindFirstChild("Order") or Workspace.Enemies:FindFirstChild("Order")) then
                    if Workspace.Enemies:FindFirstChild("Order") then
                        for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                            if (enemy.Name == "Order") then
                                repeat
                                    wait(_G.Fast_Delay);
                                    AttackNoCoolDown();
                                    AutoHaki();
                                    EquipTool(SelectWeapon);
                                    Tween(enemy.HumanoidRootPart.CFrame * Pos);
                                    enemy.HumanoidRootPart.CanCollide = false;
                                    enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60);
                                until not enemy.Parent or (enemy.Humanoid.Health <= 0) or (Auto_Law == false)
                            end
                        end
                    elseif ReplicatedStorage:FindFirstChild("Order") then
                        Tween(CFrame.new(- 6217.2021484375, 28.047645568848, - 5053.1357421875));
                    end
                end
            end
        end
    end);
end);
Tabs.Race:AddButton({
    Title = "Đền Thời Gian",
    Description = "",
    Callback = function()
        GameTeleport(Vector3.new(28286.35546875, 14895.3017578125, 102.62469482421875));
    end
});
Tabs.Race:AddButton({
    Title = "Cần Gạt",
    Description = "",
    Callback = function()
        GameTeleport(Vector3.new(28286.35546875, 14895.3017578125, 102.62469482421875));
        Tween(CFrame.new(28575.181640625, 14936.6279296875, 72.31636810302734), true);
    end
});
Tabs.Race:AddButton({
    Title = "Chỗ Mua Gear",
    Description = "",
    Callback = function()
        GameTeleport(Vector3.new(28286.35546875, 14895.3017578125, 102.62469482421875));
        Tween(CFrame.new(28981.552734375, 14888.4267578125, - 120.245849609375), true);
    end
});
local _section = Tabs.Race:AddSection("Tộc");
Tabs.Race:AddButton({
    Title = "Cửa Tộc",
    Description = "",
    Callback = function()
        GameTeleport(Vector3.new(28286.35546875, 14895.3017578125, 102.62469482421875));
        if (plr.Data.Race.Value == "Human") then
            Tween(CFrame.new(29221.822265625, 14890.9755859375, - 205.99114990234375), true);
        elseif (plr.Data.Race.Value == "Skypiea") then
            Tween(CFrame.new(28960.158203125, 14919.6240234375, 235.03948974609375), true);
        elseif (plr.Data.Race.Value == "Fishman") then
            Tween(CFrame.new(28231.17578125, 14890.9755859375, - 211.64173889160156), true);
        elseif (plr.Data.Race.Value == "Cyborg") then
            Tween(CFrame.new(28502.681640625, 14895.9755859375, - 423.7279357910156), true);
        elseif (plr.Data.Race.Value == "Ghoul") then
            Tween(CFrame.new(28674.244140625, 14890.6767578125, 445.4310607910156), true);
        elseif (plr.Data.Race.Value == "Mink") then
            Tween(CFrame.new(29012.341796875, 14890.9755859375, - 380.1492614746094), true);
        end
    end
});
local toggleHumanGhoul = Tabs.Race:AddToggle("ToggleHumanandghoul", {
    Title = "Hoàn Thành Ải [Human/Ghoul]",
    Description = "",
    Default = false
});
toggleHumanGhoul:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    KillAura = value;
end);
Options.ToggleHumanandghoul:SetValue(false);
local toggleAutoTrial = Tabs.Race:AddToggle("ToggleAutotrial", {
    Title = "Hoàn Thành Ải",
    Description = "",
    Default = false
});
toggleAutoTrial:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoQuestRace = value;
end);
Options.ToggleAutotrial:SetValue(false);
spawn(function()
    while wait() do
        if _G.AutoQuestRace then
            pcall(function()
                local race = plr.Data.Race.Value
                if race == "Human" or race == "Ghoul" then
                    for _, mob in pairs(Workspace.Enemies:GetDescendants()) do
                        if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                            pcall(function()
                                mob.Humanoid.Health = 0
                                mob.HumanoidRootPart.CanCollide = false
                                sethiddenproperty(plr, "SimulationRadius", math.huge)
                            end)
                        end
                    end
                elseif race == "Skypiea" then
                    local skyTrial = Workspace.Map:FindFirstChild("SkyTrial")
                    if skyTrial and skyTrial:FindFirstChild("Model") then
                        for _, part in pairs(skyTrial.Model:GetDescendants()) do
                            if part.Name == "snowisland_Cylinder.081" then
                                Tween(part.CFrame)
                            end
                        end
                    end
                elseif race == "Fishman" then
                    local seaBeast = Workspace.SeaBeasts:FindFirstChild("SeaBeast1")
                    if seaBeast then
                        local root = seaBeast:FindFirstChild("HumanoidRootPart", true)
                        if root then
                            Tween(root.CFrame * Pos)
                            for _, tool in pairs(plr.Backpack:GetChildren()) do
                                if tool:IsA("Tool") and (tool.ToolTip == "Melee" or tool.ToolTip == "Blox Fruit" or tool.ToolTip == "Sword" or tool.ToolTip == "Gun") then
                                    plr.Character.Humanoid:EquipTool(tool)
                                    local vim = VirtualInputManager
                                    for _, key in ipairs({122, 120, 99}) do
                                        vim:SendKeyEvent(true, key, false, game)
                                        vim:SendKeyEvent(false, key, false, game)
                                        wait(0.2)
                                    end
                                end
                            end
                        end
                    end
                elseif race == "Cyborg" then
                    Tween(CFrame.new(28654, 14898.7832, -30))
                elseif race == "Mink" then
                    for _, part in pairs(Workspace:GetDescendants()) do
                        if part.Name == "StartPoint" then
                            Tween(part.CFrame * CFrame.new(0, 10, 0))
                        end
                    end
                end
            end)
        end
    end
end);

local toggleKillTrial = Tabs.Race:AddToggle("ToggleKillTrial", {
    Title = "Đấm Người Chơi Trong Trial",
    Description = "",
    Default = false
});
toggleKillTrial:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    _G.AutoKillTrial = value;
end);
Options.ToggleKillTrial:SetValue(false);
spawn(function()
    while wait() do
        pcall(function()
            if _G.AutoKillTrial then
                for _, otherPlayer in pairs(Players:GetPlayers()) do
                    if otherPlayer ~= plr and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") and otherPlayer.Character:FindFirstChild("Humanoid") then
                        if (otherPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= 100 then
                            if otherPlayer.Character.Humanoid.Health > 0 then
                                repeat
                                    wait(_G.Fast_Delay or 0.1)
                                    EquipTool(SelectWeapon)
                                    AutoHaki()
                                    Tween(otherPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5))
                                    otherPlayer.Character.HumanoidRootPart.CanCollide = false
                                    otherPlayer.Character.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                    AttackNoCoolDown()
                                until not _G.AutoKillTrial or not otherPlayer.Character or otherPlayer.Character.Humanoid.Health <= 0
                            end
                        end
                    end
                end
            end
        end)
    end
end);
local _section = Tabs.Race:AddSection("Huấn Luyện");
local toggleFarmRace = Tabs.Race:AddToggle("ToggleFarmRace", {
    Title = "Cày Luyện Tộc",
    Description = "",
    Default = false
});
local farmRaceEnabled = false;
toggleFarmRace:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    if value == false then
        CancelTween()
    end
    farmRaceEnabled = value;
end);
Options.ToggleFarmRace:SetValue(false);
spawn(function()
    while wait() do
        if farmRaceEnabled then
            pcall(function()
                if plr.Character:FindFirstChild("RaceTransformed") then
                    if (plr.Character.RaceTransformed.Value == true) then
                        _G.AutoBoneNoQuest = false;
                        Tween(CFrame.new(- 9698.4736328125, 445.09442138671875, 6545.8525390625));
                    elseif (plr.Character.RaceTransformed.Value == false) then
                        _G.AutoBoneNoQuest = true;
                        VirtualInputManager:SendKeyEvent(true, "Y", false, game);
                        wait();
                        VirtualInputManager:SendKeyEvent(false, "Y", false, game);
                    end
                end
            end);
        else
            _G.AutoBoneNoQuest = false;
        end
    end
end);
local toggleUpgradeRace = Tabs.Race:AddToggle("ToggleUpgrade", {
    Title = "Mua Gear",
    Description = "",
    Default = false
});
toggleUpgradeRace:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoUpgrade = value;
    if IsResettingConfig then return end
    if _G.AutoUpgrade then
        ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Buy");
    end
end);
Options.ToggleUpgrade:SetValue(false);
local _section = Tabs.Shop:AddSection("Khả Năng");
Tabs.Shop:AddButton({
    Title = "Nhảy",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Geppo");
    end
});
Tabs.Shop:AddButton({
    Title = "Haki Đấm",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Buso");
    end
});
Tabs.Shop:AddButton({
    Title = "Dịch Chuyển",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Soru");
    end
});
Tabs.Shop:AddButton({
    Title = "Haki Quan Sát",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("KenTalk", "Buy");
    end
});
local _section = Tabs.Shop:AddSection("Kiếm");
Tabs.Shop:AddButton({
    Title = "Cutlass",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Cutlass");
    end
});
Tabs.Shop:AddButton({
    Title = "Katana",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Katana");
    end
});
Tabs.Shop:AddButton({
    Title = "Iron Mace",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Iron Mace");
    end
});
Tabs.Shop:AddButton({
    Title = "Duel Katana",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Duel Katana");
    end
});
Tabs.Shop:AddButton({
    Title = "Triple Katana",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Triple Katana");
    end
});
Tabs.Shop:AddButton({
    Title = "Pipe",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Pipe");
    end
});
Tabs.Shop:AddButton({
    Title = "Dual-Headed Blade",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Dual-Headed Blade");
    end
});
Tabs.Shop:AddButton({
    Title = "Bisento",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Bisento");
    end
});
Tabs.Shop:AddButton({
    Title = "Soul Cane",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", "Soul Cane");
    end
});
Tabs.Shop:AddButton({
    Title = "Pole V2",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("ThunderGodTalk");
    end
});
local _section = Tabs.Shop:AddSection("Võ");
Tabs.Shop:AddButton({
    Title = "Black Leg",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyBlackLeg");
    end
});
Tabs.Shop:AddButton({
    Title = "Electro",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyElectro");
    end
});
Tabs.Shop:AddButton({
    Title = "Fishman Karate",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyFishmanKarate");
    end
});
Tabs.Shop:AddButton({
    Title = "Dragon Claw",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "1");
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "DragonClaw", "2");
    end
});
Tabs.Shop:AddButton({
    Title = "Superhuman",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySuperhuman");
    end
});
Tabs.Shop:AddButton({
    Title = "Death Step",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyDeathStep");
    end
});
Tabs.Shop:AddButton({
    Title = "Sharkman Karate",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate", true);
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySharkmanKarate");
    end
});
Tabs.Shop:AddButton({
    Title = "Electric Claw",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyElectricClaw");
    end
});
Tabs.Shop:AddButton({
    Title = "Dragon Talon",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyDragonTalon");
    end
});
Tabs.Shop:AddButton({
    Title = "Godhuman",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyGodhuman");
    end
});
Tabs.Shop:AddButton({
    Title = "Sanguine Art",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuySanguineArt");
    end
});
local _section = Tabs.Shop:AddSection("Khác");
Tabs.Shop:AddButton({
    Title = "Đổi Chỉ Số",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "1");
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "2");
    end
});
Tabs.Shop:AddButton({
    Title = "Đổi Tộc",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Reroll", "1");
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Reroll", "2");
    end
});
Tabs.Shop:AddButton({
    Title = "Đổi Tộc Ghoul",
    Description = "",
    Callback = function()
        local ectoplasmChangeArgs = {
            [1] = "Ectoplasm",
            [2] = "Change",
            [3] = 4
        };
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(ectoplasmChangeArgs));
    end
});
Tabs.Shop:AddButton({
    Title = "Đổi Tộc Cyborg",
    Description = "",
    Callback = function()
        local cyborgBuyArgs = {
            [1] = "CyborgTrainer",
            [2] = "Buy"
        };
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(cyborgBuyArgs));
    end
});
Tabs.Shop:AddButton({
    Title = "Đổi Tộc Draco",
    Description = "Chỉ Ở Biển 3",
    Callback = function()
        GameTeleport(Vector3.new(5661.5322265625, 1013.0907592773438, - 334.9649963378906));
        Tween(CFrame.new(5814.42724609375, 1208.3267822265625, 884.5785522460938), true);
        local dracoPos = Vector3.new(5814.42724609375, 1208.3267822265625, 884.5785522460938);
        local dracoPlayer = plr;
        local dracoChar = dracoPlayer.Character or dracoPlayer.CharacterAdded:Wait() ;
        repeat
            wait();
        until (dracoChar.HumanoidRootPart.Position - dracoPos).Magnitude < 1
        local dracoQuestArgs = {
            [1] = {
                NPC = "Dragon Wizard",
                Command = "DragonRace"
            }
        };
        ReplicatedStorage.Modules.Net:FindFirstChild("RF/InteractDragonQuest"):InvokeServer(unpack(dracoQuestArgs));
    end
});
Tabs.Misc:AddButton({
    Title = "Tham Gia Máy Chủ Lại",
    Description = "",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, plr);
    end
});
Tabs.Misc:AddButton({
    Title = "Đổi Máy Chủ",
    Description = "",
    Callback = function()
        Hop();
    end
});
function Hop()
    local placeId = game.PlaceId
    local triedServers = {}
    local cursor = ""
    local currentHour = os.date("!*t").hour
    local found = false
    function TPReturner()
        local servers
        if cursor == "" then
            servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
        else
            servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. cursor))
        end
        local serverId = ""
        if servers.nextPageCursor and servers.nextPageCursor ~= "null" and servers.nextPageCursor ~= nil then
            cursor = servers.nextPageCursor
        end
        local count = 0
        for _, server in pairs(servers.data) do
            local isValid = true
            serverId = tostring(server.id)
            if tonumber(server.maxPlayers) > tonumber(server.playing) then
                for _, tried in pairs(triedServers) do
                    if count ~= 0 then
                        if serverId == tostring(tried) then
                            isValid = false
                        end
                    elseif tonumber(currentHour) ~= tonumber(tried) then
                        local success = pcall(function()
                            triedServers = {}
                            table.insert(triedServers, currentHour)
                        end)
                    end
                    count = count + 1
                end
                if isValid == true then
                    table.insert(triedServers, serverId)
                    wait()
                    pcall(function()
                        wait()
                        TeleportService:TeleportToPlaceInstance(placeId, serverId, plr)
                    end)
                    wait()
                end
            end
        end
    end
    function ServerHopLoop()
        while wait() do
            pcall(function()
                TPReturner()
                if cursor ~= "" then
                    TPReturner()
                end
            end)
        end
    end
    ServerHopLoop()
end
local _section = Tabs.Misc:AddSection("Đội");
Tabs.Misc:AddButton({
    Title = "Hải Tặc",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Pirates");
    end
});
Tabs.Misc:AddButton({
    Title = "Hải Quân",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines");
    end
});
local _section = Tabs.Misc:AddSection("Kinh Nghiệm");
local RedeemCodes = {
    "KITT_RESET",
    "Sub2UncleKizaru",
    "SUB2GAMERROBOT_RESET1",
    "Sub2Fer999",
    "Enyu_is_Pro",
    "JCWK",
    "StarcodeHEO",
    "MagicBus",
    "KittGaming",
    "Sub2CaptainMaui",
    "Sub2OfficalNoobie",
    "TheGreatAce",
    "Sub2NoobMaster123",
    "Sub2Daigrock",
    "Axiore",
    "StrawHatMaine",
    "TantaiGaming",
    "Bluxxy",
    "SUB2GAMERROBOT_EXP1",
    "Chandler",
    "NOMOREHACK",
    "BANEXPLOIT",
    "WildDares",
    "BossBuild",
    "GetPranked",
    "EARN_FRUITS",
    "FIGHT4FRUIT",
    "NOEXPLOITER",
    "NOOB2ADMIN",
    "CODESLIDE",
    "ADMINHACKED",
    "ADMINDARES",
    "fruitconcepts",
    "krazydares",
    "TRIPLEABUSE",
    "SEATROLLING",
    "24NOADMIN",
    "REWARDFUN",
    "NEWTROLL",
    "fudd10_v2",
    "Fudd10",
    "Bignews",
    "SECRET_ADMIN"
};
Tabs.Misc:AddButton({
    Title = "Nhập Hết",
    Description = "",
    Callback = function()
        for _, item in ipairs(RedeemCodes) do
            RedeemCode(item)
        end
    end
});
function RedeemCode(code)
    ReplicatedStorage.Remotes.Redeem:InvokeServer(code);
end
local _section = Tabs.Misc:AddSection("Danh Hiệu");
Tabs.Misc:AddButton({
    Title = "Danh Hiệu",
    Description = "",
    Callback = function()
        local getTitlesArgs = {
            [1] = "getTitles"
        };
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(getTitlesArgs));
        plr.PlayerGui.Main.Titles.Visible = true;
    end
});
local _section = Tabs.Misc:AddSection("Thức Tỉnh");
Tabs.Misc:AddButton({
    Title = "Thức Tỉnh",
    Description = "",
    Callback = function()
        plr.PlayerGui.Main.AwakeningToggler.Visible = true;
    end
});
local _section = Tabs.Misc:AddSection("Khác");
local toggleAutoRejoin = Tabs.Misc:AddToggle("ToggleRejoin", {
    Title = "Tham Gia Máy Chủ Lại",
    Description = "",
    Default = true
});
toggleAutoRejoin:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoRejoin = value;
end);
Options.ToggleRejoin:SetValue(true);
spawn(function()
    while wait() do
        if _G.AutoRejoin then
            getgenv().rejoin = CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(promptChild)
                if (promptChild.Name == "ErrorPrompt" and promptChild:FindFirstChild("MessageArea") and promptChild.MessageArea:FindFirstChild("ErrorFrame")) then
                    TeleportService:Teleport(game.PlaceId)
                end
            end)
        end
    end
end);
local _section = Tabs.Misc:AddSection("Sương");
local function RemoveFog()
    local lighting = Lighting;
    if lighting:FindFirstChild("BaseAtmosphere") then
        lighting.BaseAtmosphere:Destroy();
    end
    if lighting:FindFirstChild("SeaTerrorCC") then
        lighting.SeaTerrorCC:Destroy();
    end
    if lighting:FindFirstChild("LightingLayers") then
        if lighting.LightingLayers:FindFirstChild("Atmosphere") then
            lighting.LightingLayers.Atmosphere:Destroy();
        end
        wait();
        if lighting.LightingLayers:FindFirstChild("DarkFog") then
            lighting.LightingLayers.DarkFog:Destroy();
        end
    end
    lighting.FogEnd = 100000;
end
Tabs.Misc:AddButton({
    Title = "Xóa Sương Mù",
    Description = "",
    Callback = function()
        RemoveFog();
    end
});
local AntiBandToggle = Tabs.Misc:AddToggle("ToggleAntiBand", {
    Title = "Chống Band",
    Description = "",
    Default = true
});
AntiBandToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AntiBand = value;
end);
local BannedUserIds = {
    17884881,
    120173604,
    912348
};
spawn(function()
    while wait() do
        if _G.AntiBand then
            for _, player in pairs(Players:GetPlayers()) do
                if table.find(BannedUserIds, player.UserId) then
                    Hop()
                end
            end
        end
    end
end);
----------------------------------------------------------------
-- 17. TAB SEA - SỰ KIỆN BIỂN (Leviathan / Draco / Volcano...)
--     Phần này nằm cuối BuildUI
----------------------------------------------------------------

-- ==================== LEVIATHAN ====================
local LeviathanSection = Tabs.Sea:AddSection("Leviathan")

Tabs.Sea:AddButton({
    Title = "Mua Chip Leviathan",
    Description = "",
    Callback = function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("InfoLeviathan", "2")
    end
})

local TweenFrozenToggle = Tabs.Sea:AddToggle("ToggleTPFrozenDimension", {
    Title = "Bay Đến Đảo Leviathan",
    Description = "",
    Default = false
})
TweenFrozenToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.TweenToFrozenDimension = value
end)
TweenFrozenToggle:SetValue(false)

spawn(function()
    local frozenDimension
    while not frozenDimension do
        frozenDimension = workspace.Map:FindFirstChild("FrozenDimension")
        task.wait()
    end
    while task.wait() do
        if _G.TweenToFrozenDimension and frozenDimension then
            Tween(frozenDimension.CFrame)
        end
    end
end)

if Sea3 then
    local LeviathanStatus = Tabs.Sea:AddParagraph({
        Title = "Trạng Thái Chip Leviathan",
        Content = ""
    })
    spawn(function()
        pcall(function()
            while task.wait() do
                local status = ReplicatedStorage.Remotes.CommF_:InvokeServer("InfoLeviathan", "1")
                if status == 5 then
                    LeviathanStatus:SetDesc("Leviathan Is Out There")
                elseif status == 0 then
                    LeviathanStatus:SetDesc("I Don't Know")
                else
                    LeviathanStatus:SetDesc("Mua: " .. tostring(status))
                end
            end
        end)
    end)
end

-- ==================== DRACO ====================
local DracoSection = Tabs.Sea:AddSection("Draco")

local BlazeEmberToggle = Tabs.Sea:AddToggle("ToggleBlazeEmber", {
    Title = "Lụm Lửa Đỏ",
    Description = "",
    Default = false
})
BlazeEmberToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoBlazeEmber = value
end)

spawn(function()
    while task.wait() do
        if _G.AutoBlazeEmber then
            pcall(function()
                ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/DragonDojoEmber"):FireServer()
            end)
        end
    end
end)

local ReceiveQuestToggle = Tabs.Sea:AddToggle("ToggleReceiveQuest", {
    Title = "Nhận Nhiệm Vụ Lửa Đỏ",
    Description = "Bật Lên 1 Lần Là Nhận 1 Nhận Nữa Thì Tắt Bật Lại",
    Default = false
})
ReceiveQuestToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoReceiveQuest = value
    if IsResettingConfig then return end
    if _G.AutoReceiveQuest then
        GameTeleport(Vector3.new(5661.5322265625, 1013.0907592773438, -334.9649963378906))
        Tween(CFrame.new(5814.42724609375, 1208.3267822265625, 884.5785522460938), true)
        spawn(function()
            pcall(function()
                while task.wait() do
                    local requestArgs = {
                        [1] = {
                            Context = "RequestQuest"
                        }
                    }
                    ReplicatedStorage.Modules.Net:FindFirstChild("RF/DragonHunter"):InvokeServer(unpack(requestArgs))

                    local checkArgs = {
                        [1] = {
                            Context = "Check"
                        }
                    }
                    ReplicatedStorage.Modules.Net:FindFirstChild("RF/DragonHunter"):InvokeServer(unpack(checkArgs))
                end
            end)
        end)
    end
end)

local QuestStatusParagraph = Tabs.Sea:AddParagraph({
    Title = "Trạng Thái Nhiệm Vụ Lửa Đỏ",
    Content = ""
})

spawn(function()
    pcall(function()
        while task.wait() do
            local checkArgs = {
                [1] = {
                    Context = "Check"
                }
            }
            local result = ReplicatedStorage.Modules.Net:FindFirstChild("RF/DragonHunter"):InvokeServer(unpack(checkArgs))
            if typeof(result) == "table" then
                for _, questText in pairs(result) do
                    if questText == "Defeat 3 Venomous Assailants on Hydra Island." then
                        QuestStatusParagraph:SetDesc("Defeat 3 Venomous Assailants on Hydra Island.")
                    elseif questText == "Defeat 3 Hydra Enforcers on Hydra Island." then
                        QuestStatusParagraph:SetDesc("Defeat 3 Hydra Enforcers on Hydra Island.")
                    elseif questText == "Destroy 10 trees on Hydra Island." then
                        QuestStatusParagraph:SetDesc("Destroy 10 trees on Hydra Island.")
                    end
                end
            end
        end
    end)
end)

-- ==================== HYDRA TREE ====================
local HydraTreeToggle = Tabs.Sea:AddToggle("ToggleHydraTree", {
    Title = "Phá Cây Ở Đảo Hydra",
    Description = "",
    Default = false
})
HydraTreeToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoHydraTree = value
end)

local function PressKey(key)
    local vim = VirtualInputManager
    vim:SendKeyEvent(true, key, false, game)
    vim:SendKeyEvent(false, key, false, game)
end

local function EquipAndUseTool(toolType)
    local player = plr
    local backpack = player.Backpack
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == toolType then
            tool.Parent = player.Character
            for _, key in ipairs({"Z", "X", "C", "V", "F"}) do
                task.wait()
                pcall(function()
                    PressKey(key)
                end)
            end
            tool.Parent = backpack
            break
        end
    end
end

local HydraTreePositions = {
    CFrame.new(5288.61962890625, 1005.4000244140625, 392.43011474609375),
    CFrame.new(5343.39453125, 1004.1998901367188, 361.0687561035156),
    CFrame.new(5235.78564453125, 1004.1998901367188, 431.4530944824219),
    CFrame.new(5321.30615234375, 1004.1998901367188, 440.8951416015625),
    CFrame.new(5258.96484375, 1004.1998901367188, 345.5052490234375)
}

spawn(function()
    while task.wait() do
        if _G.AutoHydraTree then
            AutoHaki()
            for _, pos in ipairs(HydraTreePositions) do
                if not _G.AutoHydraTree then break end
                Tween(pos, true)
                task.wait()
                local character = plr.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local distance = (character.HumanoidRootPart.Position - pos.Position).Magnitude
                    if distance <= 1 then
                        EquipAndUseTool("Melee")
                        EquipAndUseTool("Sword")
                        EquipAndUseTool("Gun")
                    end
                end
            end
        end
    end
end)

DracoSection:AddButton({
    Title = "Bay Đến Khu Vực Dragon Dojo",
    Description = "",
    Callback = function()
        GameTeleport(Vector3.new(5661.5322265625, 1013.0907592773438, -334.9649963378906))
        Tween(CFrame.new(5814.42724609375, 1208.3267822265625, 884.5785522460938), true)
    end
})

DracoSection:AddButton({
    Title = "Chế Tạo Volcanic Magnet",
    Description = "",
    Callback = function()
        local args = {
            [1] = "CraftItem",
            [2] = "Craft",
            [3] = "Volcanic Magnet"
        }
        ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
    end
})

-- ==================== FIRE FLOWERS ====================
local CollectFireFlowersToggle = Tabs.Sea:AddToggle("ToggleCollectFireFlowers", {
    Title = "Lụm Hoa Đỏ",
    Description = "",
    Default = false
})
CollectFireFlowersToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoCollectFireFlowers = value
end)

spawn(function()
    while task.wait() do
        if _G.AutoCollectFireFlowers then
            local fireFlowers = workspace:FindFirstChild("FireFlowers")
            if fireFlowers then
                for _, flower in pairs(fireFlowers:GetChildren()) do
                    if flower:IsA("Model") and flower.PrimaryPart then
                        local flowerPos = flower.PrimaryPart.Position
                        local myPos = plr.Character and plr.Character.HumanoidRootPart and plr.Character.HumanoidRootPart.Position
                        if myPos then
                            local distance = (flowerPos - myPos).Magnitude
                            if distance <= 1 then
                                VirtualInputManager:SendKeyEvent(true, "E", false, game)
                                task.wait(1.5)
                                VirtualInputManager:SendKeyEvent(false, "E", false, game)
                            else
                                Tween(CFrame.new(flowerPos), true)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ==================== WHITE BELT ====================
local WhiteBeltToggle = Tabs.Sea:AddToggle("ToggleWhiteBelt", {
    Title = "Cày Đai Trắng",
    Description = "",
    Default = false
})

WhiteBeltToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    -- Dùng biến riêng biệt để không xung đột với AutoLevel
    _G.AutoWhiteBelt = value
    if IsResettingConfig then return end

    if value then
        -- Gửi yêu cầu nhận Quest lần đầu khi bật
        pcall(function()
            ReplicatedStorage.Modules.Net:FindFirstChild("RF/InteractDragonQuest"):InvokeServer({
                NPC = "Dojo Trainer",
                Command = "RequestQuest"
            })
        end)

        -- Vòng lặp claim quest tự động
        spawn(function()
            while _G.AutoWhiteBelt do
                pcall(function()
                    ReplicatedStorage.Modules.Net:FindFirstChild("RF/InteractDragonQuest"):InvokeServer({
                        NPC = "Dojo Trainer",
                        Command = "ClaimQuest"
                    })
                end)
                
                -- Đợi 0.5 giây thay vì chạy mỗi frame để tránh bị Anti-Cheat ngắt kết nối
                task.wait(0.5)
            end
        end)
    end
end)
Tabs.Sea:AddParagraph({
    Title = "Hoàn Thành Ải Draco V4 (Sớm Ra)",
    Content = ""
})

local TrialTeleportToggle = Tabs.Sea:AddToggle("ToggleTrialTeleport", {
    Title = "Bay Đến Cửa Trial Tộc Draco",
    Description = "",
    Default = false
})
TrialTeleportToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoTrialTeleport = value
end)

spawn(function()
    while task.wait() do
        if _G.AutoTrialTeleport then
            local trialPart = workspace.Map.PrehistoricIsland and workspace.Map.PrehistoricIsland:FindFirstChild("TrialTeleport")
            if trialPart and trialPart:IsA("Part") then
                Tween(CFrame.new(trialPart.Position), true)
            end
        end
    end
end)

-- ==================== ĐẢO DUNG NHAM (VOLCANO) ====================
local VolcanoSection = Tabs.Sea:AddSection("Đảo Dung Nham")

local VolcanoStatus = Tabs.Sea:AddParagraph({
    Title = "Trạng Thái Đảo Dung Nham",
    Content = ""
})

spawn(function()
    pcall(function()
        while task.wait() do
            if workspace.Map:FindFirstChild("PrehistoricIsland") then
                VolcanoStatus:SetDesc("Đảo Dung Nham: ✅️")
            else
                VolcanoStatus:SetDesc("Đảo Dung Nham: ❌️")
            end
        end
    end)
end)

local TPVolcanoToggle = Tabs.Sea:AddToggle("ToggleTPVolcano", {
    Title = "Bay Đến Đảo Dung Nham",
    Description = "",
    Default = false
})
TPVolcanoToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.TweenToPrehistoric = value
end)
Options.ToggleTPVolcano:SetValue(false)

spawn(function()
    local prehistoricIsland
    while not prehistoricIsland do
        prehistoricIsland = workspace.Map:FindFirstChild("PrehistoricIsland")
        task.wait()
    end
    while task.wait() do
        if _G.TweenToPrehistoric then
            local island = workspace.Map:FindFirstChild("PrehistoricIsland")
            if island then
                local core = island:FindFirstChild("Core")
                local relic = core and core:FindFirstChild("PrehistoricRelic")
                local skull = relic and relic:FindFirstChild("Skull")
                if skull then
                    Tween(CFrame.new(skull.Position), true)
                    _G.TweenToPrehistoric = false
                end
            end
        end
    end
end)

local DefendVolcanoToggle = Tabs.Sea:AddToggle("ToggleDefendVolcano", {
    Title = "Phòng Thủ",
    Description = "",
    Default = false
})
DefendVolcanoToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoDefendVolcano = value
end)

local UseMeleeToggle = Tabs.Sea:AddToggle("ToggleMelee", {
    Title = "Dùng Melee",
    Description = "",
    Default = false
})
UseMeleeToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.UseMelee = value
end)

local UseSwordToggle = Tabs.Sea:AddToggle("ToggleSword", {
    Title = "Dùng Sword",
    Description = "",
    Default = false
})
UseSwordToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.UseSword = value
end)

local UseGunToggle = Tabs.Sea:AddToggle("ToggleGun", {
    Title = "Dùng Gun",
    Description = "",
    Default = false
})
UseGunToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.UseGun = value
end)

local function RemoveLava()
    local interiorLava = workspace.Map.PrehistoricIsland and workspace.Map.PrehistoricIsland.Core and workspace.Map.PrehistoricIsland.Core:FindFirstChild("InteriorLava")
    if interiorLava and interiorLava:IsA("Model") then
        interiorLava:Destroy()
    end

    local island = workspace.Map:FindFirstChild("PrehistoricIsland")
    if island then
        for _, descendant in pairs(island:GetDescendants()) do
            if descendant:IsA("Part") and descendant.Name:lower():find("lava") then
                descendant:Destroy()
            end
        end
        for _, model in pairs(island:GetDescendants()) do
            if model:IsA("Model") then
                for _, part in pairs(model:GetDescendants()) do
                    if part:IsA("MeshPart") and part.Name:lower():find("lava") then
                        part:Destroy()
                    end
                end
            end
        end
    end
end

local function FindActiveVolcanoRock()
    local volcanoRocks = workspace.Map.PrehistoricIsland and workspace.Map.PrehistoricIsland.Core and workspace.Map.PrehistoricIsland.Core:FindFirstChild("VolcanoRocks")
    if not volcanoRocks then return nil end

    for _, model in pairs(volcanoRocks:GetChildren()) do
        if model:IsA("Model") then
            local mesh = model:FindFirstChild("volcanorock")
            if mesh and mesh:IsA("MeshPart") then
                local color = mesh.Color
                if color == Color3.fromRGB(185, 53, 56) or color == Color3.fromRGB(185, 53, 57) then
                    return mesh
                end
            end
        end
    end
    return nil
end

spawn(function()
    while task.wait() do
        if _G.AutoDefendVolcano then
            AutoHaki()
            pcall(RemoveLava)
            local rock = FindActiveVolcanoRock()
            if rock then
                Tween(CFrame.new(rock.Position), true)
                local color = rock.Color
                if color ~= Color3.fromRGB(185, 53, 56) and color ~= Color3.fromRGB(185, 53, 57) then
                    rock = FindActiveVolcanoRock()
                else
                    local character = plr.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local distance = (character.HumanoidRootPart.Position - rock.Position).Magnitude
                        if distance <= 1 then
                            if _G.UseMelee then EquipAndUseTool("Melee") end
                            if _G.UseSword then EquipAndUseTool("Sword") end
                            if _G.UseGun then EquipAndUseTool("Gun") end
                        end
                    end
                    _G.TweenToPrehistoric = false
                end
            else
                _G.TweenToPrehistoric = true
            end
        end
    end
end)

-- ==================== KILL AURA ====================
local KillAuraToggle = Tabs.Sea:AddToggle("ToggleKillAura", {
    Title = "Đấm Golems Aura",
    Description = "",
    Default = false
})
KillAuraToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    KillAura = value
end)
Options.ToggleKillAura:SetValue(false)

spawn(function()
    while task.wait() do
        if KillAura then
            pcall(function()
                for _, mob in pairs(workspace.Enemies:GetDescendants()) do
                    if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                        repeat
                            task.wait()
                            sethiddenproperty(plr, "SimulationRadius", math.huge)
                            mob.Humanoid.Health = 0
                            mob.HumanoidRootPart.CanCollide = false
                        until not KillAura or not mob.Parent or mob.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

-- ==================== COLLECT BONE ====================
local CollectBoneToggle = Tabs.Sea:AddToggle("ToggleCollectBone", {
    Title = "Lụm Xương",
    Description = "",
    Default = false
})
CollectBoneToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoCollectBone = value
end)

spawn(function()
    while task.wait() do
        if _G.AutoCollectBone then
            for _, part in pairs(workspace:GetDescendants()) do
                if part:IsA("BasePart") and part.Name == "DinoBone" then
                    Tween(CFrame.new(part.Position), true)
                end
            end
        end
    end
end)

-- ==================== COLLECT EGG ====================
local CollectEggToggle = Tabs.Sea:AddToggle("ToggleCollectEgg", {
    Title = "Lụm Trứng",
    Description = "",
    Default = false
})
CollectEggToggle:OnChanged(function(value)
    if value == true then _G.StopTween = false end
    _G.AutoCollectEgg = value
end)

spawn(function()
    while task.wait() do
        if _G.AutoCollectEgg then
            local eggsFolder = workspace.Map.PrehistoricIsland and workspace.Map.PrehistoricIsland.Core and workspace.Map.PrehistoricIsland.Core:FindFirstChild("SpawnedDragonEggs")
            if eggsFolder then
                local eggs = eggsFolder:GetChildren()
                if #eggs > 0 then
                    local egg = eggs[math.random(1, #eggs)]
                    if egg:IsA("Model") and egg.PrimaryPart then
                        Tween(egg.PrimaryPart.CFrame, true)
                        local character = plr.Character
                        if character and character:FindFirstChild("HumanoidRootPart") then
                            local distance = (character.HumanoidRootPart.Position - egg.PrimaryPart.Position).Magnitude
                            if distance <= 1 then
                                VirtualInputManager:SendKeyEvent(true, "E", false, game)
                                task.wait(1.5)
                                VirtualInputManager:SendKeyEvent(false, "E", false, game)
                            end
                        end
                    end
                end
            end
        end
    end
end)

end -- Kết thúc function BuildUI()

-------------------------------------------------
-- 18. KHỞI CHẠY
-------------------------------------------------
BuildUI()

-- Capture Default sau khi toàn bộ Options đã được tạo
CaptureDefaults()

-- Bọc SetValue để tự động lưu khi người dùng thay đổi
WrapOptionsForAutoSave()

-- Load Persistent Config (sau khi Options tồn tại)
LoadConfig()

Fluent:Notify({
    Title = "Min Gaming",
    Content = "Tải Xong - Sẵn sàng sử dụng!",
    Duration = 10
})

-- Kết thúc script
-- discord.gg/25ms