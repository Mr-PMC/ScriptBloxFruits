FAT CAT HUB

local ok, result = xpcall(function()
    local source = game:HttpGet(
        "https://raw.githubusercontent.com/Mr-PMC/ScriptBloxFruits/refs/heads/main/FatCaHub.lua"
    )

    if not source or source == "" then
        error("Không tải được FatCaHub.lua hoặc file rỗng")
    end

    local fn, compileError = loadstring(source)

    if not fn then
        error("COMPILE ERROR: " .. tostring(compileError))
    end

    return fn()
end, function(err)
    warn("")
    warn("==============================================")
    warn("        FAT CAT HUB - ERROR REPORT")
    warn("==============================================")
    warn("LỖI:", tostring(err))
    warn("----------------------------------------------")
    warn("TRACEBACK:")
    warn(debug.traceback())
    warn("==============================================")
    return err
end)

if ok then
    warn("[FAT CAT HUB] Execute thành công")
else
    warn("[FAT CAT HUB] Execute THẤT BẠI")
    warn("[FAT CAT HUB] Chi tiết:", tostring(result))
end






MINGAMING HUB

local ok, result = xpcall(function()
    local source = game:HttpGet(
        "https://raw.githubusercontent.com/Mr-PMC/ScriptBloxFruits/refs/heads/main/Mingaming_fix_v4.lua"
    )

    if not source or source == "" then
        error("Không tải được MingamingHub.lua hoặc file rỗng")
    end

    local fn, compileError = loadstring(source)

    if not fn then
        error("COMPILE ERROR: " .. tostring(compileError))
    end

    return fn()
end, function(err)
    warn("")
    warn("==============================================")
    warn("        MINGAMING HUB - ERROR REPORT")
    warn("==============================================")
    warn("LỖI:", tostring(err))
    warn("----------------------------------------------")
    warn("TRACEBACK:")
    warn(debug.traceback())
    warn("==============================================")
    return err
end)

if ok then
    warn("[MINGAMING HUB] Execute thành công")
else
    warn("[MINGAMING HUB] Execute THẤT BẠI")
    warn("MINGAMING HUB] Chi tiết:", tostring(result))
end





ASTRAL HUB

local ok, result = xpcall(function()
    local source = game:HttpGet(
        "https://raw.githubusercontent.com/Mr-PMC/ScriptBloxFruits/refs/heads/main/AstralHub.lua"
    )

    if not source or source == "" then
        error("Không tải được  AstralHub.lua hoặc file rỗng")
    end

    local fn, compileError = loadstring(source)

    if not fn then
        error("COMPILE ERROR: " .. tostring(compileError))
    end

    return fn()
end, function(err)
    warn("")
    warn("==============================================")
    warn("        ASTRAL HUB - ERROR REPORT")
    warn("==============================================")
    warn("LỖI:", tostring(err))
    warn("----------------------------------------------")
    warn("TRACEBACK:")
    warn(debug.traceback())
    warn("==============================================")
    return err
end)

if ok then
    warn("[ ASTRAL HUB] Execute thành công")
else
    warn("[ ASTRAL HUB] Execute THẤT BẠI")
    warn("[ ASTRAL HUB] Chi tiết:", tostring(result))
end







 BANANA CAT  HUB CRACKE

local ok, result = xpcall(function()
    local source = game:HttpGet(
        "https://raw.githubusercontent.com/Mr-PMC/ScriptBloxFruits/refs/heads/main/BananaCatHubCracket.lua"
    )

    if not source or source == "" then
        error("Không tải được  BananaCatHubCracker.lua hoặc file rỗng")
    end

    local fn, compileError = loadstring(source)

    if not fn then
        error("COMPILE ERROR: " .. tostring(compileError))
    end

    return fn()
end, function(err)
    warn("")
    warn("==============================================")
    warn("        BANANA CAT  HUB CRACKER- ERROR REPORT")
    warn("==============================================")
    warn("LỖI:", tostring(err))
    warn("----------------------------------------------")
    warn("TRACEBACK:")
    warn(debug.traceback())
    warn("==============================================")
    return err
end)

if ok then
    warn("[  BANANA CAT  HUB CRACKER] Execute thành công")
else
    warn("[  BANANA CAT  HUB CRACKER] Execute THẤT BẠI")
    warn("[  BANANA CAT  HUB CRACKER] Chi tiết:", tostring(result))
end



















-- ====================================================================
-- 1. CƠ CHẾ XÓA HIỆU ỨNG ĐÁNH (FAST ATTACK NO-FX / ANTI-LAG)
-- ====================================================================
local function ClearHitEffects(parent)
    if not parent then return end
    for _, v in ipairs(parent:GetChildren()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Explosion") then
            v:Destroy()
        elseif v:IsA("BasePart") and (v.Name:find("Hit") or v.Name:find("Slash") or v.Name:find("Effect")) then
            v:Destroy()
        end
    end
end

-- Tự động dọn dẹp FX sinh ra ở Workspace trong lúc Fast Attack
Workspace.ChildAdded:Connect(function(child)
    if Fluent.Options and Fluent.Options.FastAttack and Fluent.Options.FastAttack.Value then
        if child:IsA("ParticleEmitter") or child:IsA("Trail") or child.Name:find("Effect") or child.Name:find("Slash") then
            task.defer(child.Destroy, child)
        end
    end
end)

-- ====================================================================
-- 2. HÀM QUÉT MỤC TIÊU TỐI ƯU (GỌN NẸ, ÉP CHẠY LÊN MỌI MỤC TIÊU)
-- ====================================================================
local function GetFastTargets(maxDist)
    local targets = {}
    local char, root = CharacterManager.Get()
    if not root then return targets end

    local rootPos = root.Position
    local containers = {EnemiesFolder, NPCsFolder}

    -- Quét gộp Quái vật & NPC
    for _, folder in ipairs(containers) do
        if folder then
            for _, model in ipairs(folder:GetChildren()) do
                local hum = model:FindFirstChildOfClass("Humanoid")
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp and (hrp.Position - rootPos).Magnitude <= maxDist then
                    table.insert(targets, model:FindFirstChild("Head") or hrp)
                end
            end
        end
    end

    -- Quét Người chơi (PvP)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp and (hrp.Position - rootPos).Magnitude <= maxDist then
                table.insert(targets, plr.Character:FindFirstChild("Head") or hrp)
            end
        end
    end

    return targets
end









    Tabs.Setting:AddSection("Combat Settings")

    Tabs.Setting:AddToggle("FastAttack", {
        Title = "Fast Attack",
        Description = "Tự động kích hoạt đòn đánh nhanh không delay",
        Default = false
    })

















local QuestLevelData = {
    Sea1 = {
        {MinLevel = 1,    MaxLevel = 9,    Monster = "Bandit",               Quest = "BanditQuest1",    QuestLevel = 1, NPCPos = CFrame.new(1060.9383544922, 16.455066680908, 1547.7841796875), MonterPos = CFrame.new(1038.5533447266, 41.296249389648, 1576.5098876953)},
        {MinLevel = 10,   MaxLevel = 14,   Monster = "Monkey",               Quest = "JungleQuest",     QuestLevel = 1, NPCPos = CFrame.new(-1601.6553955078, 36.85213470459, 153.38809204102), MonterPos = CFrame.new(-1448.1446533203, 50.851993560791, 63.60718536377)},
        {MinLevel = 15,   MaxLevel = 29,   Monster = "Gorilla",              Quest = "JungleQuest",     QuestLevel = 2, NPCPos = CFrame.new(-1601.6553955078, 36.85213470459, 153.38809204102), MonterPos = CFrame.new(-1142.6488037109, 40.462348937988, -515.39227294922)},
        {MinLevel = 30,   MaxLevel = 39,   Monster = "Pirate",               Quest = "BuggyQuest1",     QuestLevel = 1, NPCPos = CFrame.new(-1140.1761474609, 4.752049446106, 3827.4057617188), MonterPos = CFrame.new(-1201.0881347656, 40.628940582275, 3857.5966796875)},
        {MinLevel = 40,   MaxLevel = 59,   Monster = "Brute",                Quest = "BuggyQuest1",     QuestLevel = 2, NPCPos = CFrame.new(-1140.1761474609, 4.752049446106, 3827.4057617188), MonterPos = CFrame.new(-1387.5324707031, 24.592035293579, 4100.9575195313)},
        {MinLevel = 60,   MaxLevel = 74,   Monster = "Desert Bandit",        Quest = "DesertQuest",     QuestLevel = 1, NPCPos = CFrame.new(896.51721191406, 6.4384617805481, 4390.1494140625), MonterPos = CFrame.new(984.99896240234, 16.109552383423, 4417.91015625)},
        {MinLevel = 75,   MaxLevel = 89,   Monster = "Desert Officer",       Quest = "DesertQuest",     QuestLevel = 2, NPCPos = CFrame.new(896.51721191406, 6.4384617805481, 4390.1494140625), MonterPos = CFrame.new(1547.1510009766, 14.452038764954, 4381.8002929688)},
        {MinLevel = 90,   MaxLevel = 99,   Monster = "Snow Bandit",          Quest = "SnowQuest",       QuestLevel = 1, NPCPos = CFrame.new(1386.8073730469, 87.272789001465, -1298.3576660156), MonterPos = CFrame.new(1356.3028564453, 105.76865386963, -1328.2418212891)},
        {MinLevel = 100,  MaxLevel = 119,  Monster = "Snowman",              Quest = "SnowQuest",       QuestLevel = 2, NPCPos = CFrame.new(1386.8073730469, 87.272789001465, -1298.3576660156), MonterPos = CFrame.new(1218.7956542969, 138.01184082031, -1488.0262451172)},
        {MinLevel = 120,  MaxLevel = 149,  Monster = "Chief Petty Officer", Quest = "MarineQuest2",    QuestLevel = 1, NPCPos = CFrame.new(-5035.49609375, 28.677835464478, 4324.1840820313), MonterPos = CFrame.new(-4931.1552734375, 65.793113708496, 4121.8393554688)},
        {MinLevel = 150,  MaxLevel = 174,  Monster = "Sky Bandit",           Quest = "SkyQuest",        QuestLevel = 1, NPCPos = CFrame.new(-4842.1372070313, 717.69543457031, -2623.0483398438), MonterPos = CFrame.new(-4955.6411132813, 365.46365356445, -2908.1865234375)},
        {MinLevel = 175,  MaxLevel = 189,  Monster = "Dark Master",          Quest = "SkyQuest",        QuestLevel = 2, NPCPos = CFrame.new(-4842.1372070313, 717.69543457031, -2623.0483398438), MonterPos = CFrame.new(-5148.1650390625, 439.04571533203, -2332.9611816406)},
        {MinLevel = 190,  MaxLevel = 209,  Monster = "Prisoner",             Quest = "PrisonerQuest",   QuestLevel = 1, NPCPos = CFrame.new(5310.60547, 0.350014925, 474.946594, 0.0175017118, 0, 0.999846935, 0, 1, 0, -0.999846935, 0, 0.0175017118), MonterPos = CFrame.new(4937.31885, 0.332031399, 649.574524, 0.694649816, 0, -0.719348073, 0, 1, 0, 0.719348073, 0, 0.694649816)},
        {MinLevel = 210,  MaxLevel = 249,  Monster = "Dangerous Prisoner", Quest = "PrisonerQuest",   QuestLevel = 2, NPCPos = CFrame.new(5310.60547, 0.350014925, 474.946594, 0.0175017118, 0, 0.999846935, 0, 1, 0, -0.999846935, 0, 0.0175017118), MonterPos = CFrame.new(5099.6626, 0.351562679, 1055.7583, 0.898906827, 0, -0.438139856, 0, 1, 0, 0.438139856, 0, 0.898906827)},
        {MinLevel = 250,  MaxLevel = 274,  Monster = "Toga Warrior",         Quest = "ColosseumQuest",  QuestLevel = 1, NPCPos = CFrame.new(-1577.7890625, 7.4151420593262, -2984.4838867188), MonterPos = CFrame.new(-1872.5166015625, 49.080215454102, -2913.810546875)},
        {MinLevel = 275,  MaxLevel = 299,  Monster = "Gladiator",            Quest = "ColosseumQuest",  QuestLevel = 2, NPCPos = CFrame.new(-1577.7890625, 7.4151420593262, -2984.4838867188), MonterPos = CFrame.new(-1521.3740234375, 81.203170776367, -3066.3139648438)},
        {MinLevel = 300,  MaxLevel = 324,  Monster = "Military Soldier",     Quest = "MagmaQuest",      QuestLevel = 1, NPCPos = CFrame.new(-5316.1157226563, 12.262831687927, 8517.00390625), MonterPos = CFrame.new(-5369.0004882813, 61.24352645874, 8556.4921875)},
        {MinLevel = 325,  MaxLevel = 374,  Monster = "Military Spy",         Quest = "MagmaQuest",      QuestLevel = 2, NPCPos = CFrame.new(-5316.1157226563, 12.262831687927, 8517.00390625), MonterPos = CFrame.new(-5787.00293, 75.8262634, 8651.69922, 0.838590562, 0, -0.544762194, 0, 1, 0, 0.544762194, 0, 0.838590562)},
        {MinLevel = 375,  MaxLevel = 399,  Monster = "Fishman Warrior",      Quest = "FishmanQuest",    QuestLevel = 1, NPCPos = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734), MonterPos = CFrame.new(60844.10546875, 98.462875366211, 1298.3985595703), Entrance = Vector3.new(61163.8515625, 11.6796875, 1819.7841796875)},
        {MinLevel = 400,  MaxLevel = 449,  Monster = "Fishman Commando",     Quest = "FishmanQuest",    QuestLevel = 2, NPCPos = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734), MonterPos = CFrame.new(61738.3984375, 64.207321166992, 1433.8375244141), Entrance = Vector3.new(61163.8515625, 11.6796875, 1819.7841796875)},
        {MinLevel = 450,  MaxLevel = 474,  Monster = "God's Guard",          Quest = "SkyExp1Quest",    QuestLevel = 1, NPCPos = CFrame.new(-4721.8603515625, 845.30297851563, -1953.8489990234), MonterPos = CFrame.new(-4628.0498046875, 866.92877197266, -1931.2352294922), Entrance = Vector3.new(-4607.82275, 872.54248, -1667.55688)},
        {MinLevel = 475,  MaxLevel = 524,  Monster = "Shanda",               Quest = "SkyExp1Quest",    QuestLevel = 2, NPCPos = CFrame.new(-7863.1596679688, 5545.5190429688, -378.42266845703), MonterPos = CFrame.new(-7685.1474609375, 5601.0751953125, -441.38876342773), Entrance = Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047)},
        {MinLevel = 525,  MaxLevel = 549,  Monster = "Royal Squad",          Quest = "SkyExp2Quest",    QuestLevel = 1, NPCPos = CFrame.new(-7903.3828125, 5635.9897460938, -1410.923828125), MonterPos = CFrame.new(-7654.2514648438, 5637.1079101563, -1407.7550048828), Entrance = Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047)},
        {MinLevel = 550,  MaxLevel = 624,  Monster = "Royal Soldier",        Quest = "SkyExp2Quest",    QuestLevel = 2, NPCPos = CFrame.new(-7903.3828125, 5635.9897460938, -1410.923828125), MonterPos = CFrame.new(-7760.4106445313, 5679.9077148438, -1884.8112792969), Entrance = Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047)},
        {MinLevel = 625,  MaxLevel = 649,  Monster = "Galley Pirate",        Quest = "FountainQuest",   QuestLevel = 1, NPCPos = CFrame.new(5258.2788085938, 38.526931762695, 4050.044921875), MonterPos = CFrame.new(5557.1684570313, 152.32717895508, 3998.7758789063)},
        {MinLevel = 650,  MaxLevel = 9999, Monster = "Galley Captain",       Quest = "FountainQuest",   QuestLevel = 2, NPCPos = CFrame.new(5258.2788085938, 38.526931762695, 4050.044921875), MonterPos = CFrame.new(5677.6772460938, 92.786109924316, 4966.6323242188)},
    },

    Sea2 = {
        {MinLevel = 700,  MaxLevel = 724,  Monster = "Raider",               Quest = "Area1Quest",        QuestLevel = 1, NPCPos = CFrame.new(-427.72567749023, 72.99634552002, 1835.9426269531), MonterPos = CFrame.new(68.874565124512, 93.635643005371, 2429.6752929688)},
        {MinLevel = 725,  MaxLevel = 774,  Monster = "Mercenary",            Quest = "Area1Quest",        QuestLevel = 2, NPCPos = CFrame.new(-427.72567749023, 72.99634552002, 1835.9426269531), MonterPos = CFrame.new(-864.85009765625, 122.47104644775, 1453.1505126953)},
        {MinLevel = 775,  MaxLevel = 799,  Monster = "Swan Pirate",          Quest = "Area2Quest",        QuestLevel = 1, NPCPos = CFrame.new(635.61151123047, 73.096351623535, 917.81298828125), MonterPos = CFrame.new(1065.3669433594, 137.64012145996, 1324.3798828125)},
        {MinLevel = 800,  MaxLevel = 874,  Monster = "Factory Staff",        Quest = "Area2Quest",        QuestLevel = 2, NPCPos = CFrame.new(635.61151123047, 73.096351623535, 917.81298828125), MonterPos = CFrame.new(533.22045898438, 128.46876525879, 355.62615966797)},
        {MinLevel = 875,  MaxLevel = 899,  Monster = "Marine Lieutenant",    Quest = "MarineQuest3",      QuestLevel = 1, NPCPos = CFrame.new(-2440.9934082031, 73.04190826416, -3217.7082519531), MonterPos = CFrame.new(-2489.2622070313, 84.613594055176, -3151.8830566406)},
        {MinLevel = 900,  MaxLevel = 949,  Monster = "Marine Captain",       Quest = "MarineQuest3",      QuestLevel = 2, NPCPos = CFrame.new(-2440.9934082031, 73.04190826416, -3217.7082519531), MonterPos = CFrame.new(-2335.2026367188, 79.786659240723, -3245.8674316406)},
        {MinLevel = 950,  MaxLevel = 974,  Monster = "Zombie",               Quest = "ZombieQuest",       QuestLevel = 1, NPCPos = CFrame.new(-5494.3413085938, 48.505931854248, -794.59094238281), MonterPos = CFrame.new(-5536.4970703125, 101.08577728271, -835.59075927734)},
        {MinLevel = 975,  MaxLevel = 999,  Monster = "Vampire",              Quest = "ZombieQuest",       QuestLevel = 2, NPCPos = CFrame.new(-5494.3413085938, 48.505931854248, -794.59094238281), MonterPos = CFrame.new(-5806.1098632813, 16.722528457642, -1164.4384765625)},
        {MinLevel = 1000, MaxLevel = 1049, Monster = "Snow Trooper",         Quest = "SnowMountainQuest", QuestLevel = 1, NPCPos = CFrame.new(607.05963134766, 401.44781494141, -5370.5546875), MonterPos = CFrame.new(535.21051025391, 432.74209594727, -5484.9165039063)},
        {MinLevel = 1050, MaxLevel = 1099, Monster = "Winter Warrior",       Quest = "SnowMountainQuest", QuestLevel = 2, NPCPos = CFrame.new(607.05963134766, 401.44781494141, -5370.5546875), MonterPos = CFrame.new(1234.4449462891, 456.95419311523, -5174.130859375)},
        {MinLevel = 1100, MaxLevel = 1124, Monster = "Lab Subordinate",      Quest = "IceSideQuest",      QuestLevel = 1, NPCPos = CFrame.new(-6061.841796875, 15.926671981812, -4902.0385742188), MonterPos = CFrame.new(-5720.5576171875, 63.309471130371, -4784.6103515625)},
        {MinLevel = 1125, MaxLevel = 1174, Monster = "Horned Warrior",       Quest = "IceSideQuest",      QuestLevel = 2, NPCPos = CFrame.new(-6061.841796875, 15.926671981812, -4902.0385742188), MonterPos = CFrame.new(-6292.751953125, 91.181983947754, -5502.6499023438)},
        {MinLevel = 1175, MaxLevel = 1199, Monster = "Magma Ninja",          Quest = "FireSideQuest",     QuestLevel = 1, NPCPos = CFrame.new(-5429.0473632813, 15.977565765381, -5297.9614257813), MonterPos = CFrame.new(-5461.8388671875, 130.36347961426, -5836.4702148438)},
        {MinLevel = 1200, MaxLevel = 1249, Monster = "Lava Pirate",          Quest = "FireSideQuest",     QuestLevel = 2, NPCPos = CFrame.new(-5429.0473632813, 15.977565765381, -5297.9614257813), MonterPos = CFrame.new(-5251.1889648438, 55.164535522461, -4774.4096679688)},
        {MinLevel = 1250, MaxLevel = 1274, Monster = "Ship Deckhand",        Quest = "ShipQuest1",        QuestLevel = 1, NPCPos = CFrame.new(1040.2927246094, 125.08293151855, 32911.0390625), MonterPos = CFrame.new(921.12365722656, 125.9839553833, 33088.328125), Entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)},
        {MinLevel = 1275, MaxLevel = 1299, Monster = "Ship Engineer",        Quest = "ShipQuest1",        QuestLevel = 2, NPCPos = CFrame.new(1040.2927246094, 125.08293151855, 32911.0390625), MonterPos = CFrame.new(886.28179931641, 40.47790145874, 32800.83203125), Entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)},
        {MinLevel = 1300, MaxLevel = 1324, Monster = "Ship Steward",         Quest = "ShipQuest2",        QuestLevel = 1, NPCPos = CFrame.new(971.42065429688, 125.08293151855, 33245.54296875), MonterPos = CFrame.new(943.85504150391, 129.58183288574, 33444.3671875), Entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)},
        {MinLevel = 1325, MaxLevel = 1349, Monster = "Ship Officer",         Quest = "ShipQuest2",        QuestLevel = 2, NPCPos = CFrame.new(971.42065429688, 125.08293151855, 33245.54296875), MonterPos = CFrame.new(955.38458251953, 181.08335876465, 33331.890625), Entrance = Vector3.new(923.21252441406, 126.9760055542, 32852.83203125)},
        {MinLevel = 1350, MaxLevel = 1374, Monster = "Arctic Warrior",       Quest = "FrostQuest",        QuestLevel = 1, NPCPos = CFrame.new(5668.1372070313, 28.202531814575, -6484.6005859375), MonterPos = CFrame.new(5935.4541015625, 77.26016998291, -6472.7568359375)},
        {MinLevel = 1375, MaxLevel = 1424, Monster = "Snow Lurker",          Quest = "FrostQuest",        QuestLevel = 2, NPCPos = CFrame.new(5668.1372070313, 28.202531814575, -6484.6005859375), MonterPos = CFrame.new(5628.482421875, 57.574996948242, -6618.3481445313)},
        {MinLevel = 1425, MaxLevel = 1449, Monster = "Sea Soldier",          Quest = "ForgottenQuest",    QuestLevel = 1, NPCPos = CFrame.new(-3054.5827636719, 236.87213134766, -10147.790039063), MonterPos = CFrame.new(-3185.0153808594, 58.789089202881, -9663.6064453125)},
        {MinLevel = 1450, MaxLevel = 9999, Monster = "Water Fighter",        Quest = "ForgottenQuest",    QuestLevel = 2, NPCPos = CFrame.new(-3054.5827636719, 236.87213134766, -10147.790039063), MonterPos = CFrame.new(-3262.9301757813, 298.69036865234, -10552.529296875)},
    },

    Sea3 = {
        {MinLevel = 1500, MaxLevel = 1524, Monster = "Pirate Millionaire",   Quest = "PiratePortQuest",   QuestLevel = 1, NPCPos = CFrame.new(-450.1046447753906, 107.68145751953125, 5950.72607421875), MonterPos = CFrame.new(-193.99227905273438, 56.12502670288086, 5755.7880859375)},
        {MinLevel = 1525, MaxLevel = 1574, Monster = "Pistol Billionaire",   Quest = "PiratePortQuest",   QuestLevel = 2, NPCPos = CFrame.new(-450.1046447753906, 107.68145751953125, 5950.72607421875), MonterPos = CFrame.new(-188.14462280273438, 84.49613189697266, 6337.0419921875)},
        {MinLevel = 1575, MaxLevel = 1599, Monster = "Dragon Crew Warrior", Quest = "DragonCrewQuest",   QuestLevel = 1, NPCPos = CFrame.new(6735.11083984375, 126.99046325683594, -711.0979614257812), MonterPos = CFrame.new(6615.2333984375, 50.847679138183594, -978.93408203125)},
        {MinLevel = 1600, MaxLevel = 1624, Monster = "Dragon Crew Archer",  Quest = "DragonCrewQuest",   QuestLevel = 2, NPCPos = CFrame.new(6735.11083984375, 126.99046325683594, -711.0979614257812), MonterPos = CFrame.new(6818.58935546875, 483.718994140625, 512.726806640625)},
        {MinLevel = 1625, MaxLevel = 1649, Monster = "Hydra Enforcer",      Quest = "VenomCrewQuest",    QuestLevel = 1, NPCPos = CFrame.new(5446.8793945313, 601.62945556641, 749.45672607422), MonterPos = CFrame.new(4547.115234375, 1001.60205078125, 334.1954650878906)},
        {MinLevel = 1650, MaxLevel = 1699, Monster = "Venomous Assailant",  Quest = "VenomCrewQuest",    QuestLevel = 2, NPCPos = CFrame.new(5446.8793945313, 601.62945556641, 749.45672607422), MonterPos = CFrame.new(4637.88525390625, 1077.85595703125, 882.4183959960938)},
        {MinLevel = 1700, MaxLevel = 1724, Monster = "Marine Commodore",    Quest = "MarineTreeIsland",  QuestLevel = 1, NPCPos = CFrame.new(2179.98828125, 28.731239318848, -6740.0551757813), MonterPos = CFrame.new(2198.0063476563, 128.71075439453, -7109.5043945313)},
        {MinLevel = 1725, MaxLevel = 1774, Monster = "Marine Rear Admiral", Quest = "MarineTreeIsland",  QuestLevel = 2, NPCPos = CFrame.new(2179.98828125, 28.731239318848, -6740.0551757813), MonterPos = CFrame.new(3294.3142089844, 385.41125488281, -7048.6342773438)},
        {MinLevel = 1775, MaxLevel = 1799, Monster = "Fishman Raider",      Quest = "DeepForestIsland3", QuestLevel = 1, NPCPos = CFrame.new(-10582.759765625, 331.78845214844, -8757.666015625), MonterPos = CFrame.new(-10553.268554688, 521.38439941406, -8176.9458007813)},
        {MinLevel = 1800, MaxLevel = 1824, Monster = "Fishman Captain",     Quest = "DeepForestIsland3", QuestLevel = 2, NPCPos = CFrame.new(-10583.099609375, 331.78845214844, -8759.4638671875), MonterPos = CFrame.new(-10789.401367188, 427.18637084961, -9131.4423828125)},
        {MinLevel = 1825, MaxLevel = 1849, Monster = "Forest Pirate",       Quest = "DeepForestIsland",  QuestLevel = 1, NPCPos = CFrame.new(-13232.662109375, 332.40396118164, -7626.4819335938), MonterPos = CFrame.new(-13489.397460938, 400.30349731445, -7770.251953125)},
        {MinLevel = 1850, MaxLevel = 1899, Monster = "Mythological Pirate", Quest = "DeepForestIsland",  QuestLevel = 2, NPCPos = CFrame.new(-13232.662109375, 332.40396118164, -7626.4819335938), MonterPos = CFrame.new(-13508.616210938, 582.46228027344, -6985.3037109375)},
        {MinLevel = 1900, MaxLevel = 1924, Monster = "Jungle Pirate",       Quest = "DeepForestIsland2", QuestLevel = 1, NPCPos = CFrame.new(-12682.096679688, 390.88653564453, -9902.1240234375), MonterPos = CFrame.new(-12267.103515625, 459.75262451172, -10277.200195313)},
        {MinLevel = 1925, MaxLevel = 1974, Monster = "Musketeer Pirate",    Quest = "DeepForestIsland2", QuestLevel = 2, NPCPos = CFrame.new(-12682.096679688, 390.88653564453, -9902.1240234375), MonterPos = CFrame.new(-13291.5078125, 520.47338867188, -9904.638671875)},
        {MinLevel = 1975, MaxLevel = 1999, Monster = "Reborn Skeleton",     Quest = "HauntedQuest1",     QuestLevel = 1, NPCPos = CFrame.new(-9480.80762, 142.130661, 5566.37305, -0.00655503059, 4.5295423e-8, -0.999978542, 2.0492047e-8, 1, 4.5162068e-8, 0.999978542, -2.0195568e-8, -0.00655503059), MonterPos = CFrame.new(-8761.77148, 183.431747, 6168.33301, 0.978073597, -0.000013950732, -0.208259016, -0.0000010807393, 1, -0.00007206303, 0.208259016, 0.00007070804, 0.978073597)},
        {MinLevel = 2000, MaxLevel = 2024, Monster = "Living Zombie",       Quest = "HauntedQuest1",     QuestLevel = 2, NPCPos = CFrame.new(-9480.80762, 142.130661, 5566.37305, -0.00655503059, 4.5295423e-8, -0.999978542, 2.0492047e-8, 1, 4.5162068e-8, 0.999978542, -2.0195568e-8, -0.00655503059), MonterPos = CFrame.new(-10103.7529, 238.565979, 6179.75977, 0.999474227, 2.7754714e-8, 0.0324240364, -2.5800633e-8, 1, -6.068485e-8, -0.0324240364, 5.981639e-8, 0.999474227)},
        {MinLevel = 2025, MaxLevel = 2049, Monster = "Demonic Soul",        Quest = "HauntedQuest2",     QuestLevel = 1, NPCPos = CFrame.new(-9516.9931640625, 178.00651550293, 6078.4653320313), MonterPos = CFrame.new(-9712.03125, 204.69589233398, 6193.322265625)},
        {MinLevel = 2050, MaxLevel = 2074, Monster = "Posessed Mummy",      Quest = "HauntedQuest2",     QuestLevel = 2, NPCPos = CFrame.new(-9516.9931640625, 178.00651550293, 6078.4653320313), MonterPos = CFrame.new(-9545.7763671875, 69.619895935059, 6339.5615234375)},
        {MinLevel = 2075, MaxLevel = 2099, Monster = "Peanut Scout",        Quest = "NutsIslandQuest",   QuestLevel = 1, NPCPos = CFrame.new(-2105.53198, 37.2495995, -10195.5088, -0.766061664, 0, -0.642767608, 0, 1, 0, 0.642767608, 0, -0.766061664), MonterPos = CFrame.new(-2150.587890625, 122.49767303467, -10358.994140625)},
        {MinLevel = 2100, MaxLevel = 2124, Monster = "Peanut President",    Quest = "NutsIslandQuest",   QuestLevel = 2, NPCPos = CFrame.new(-2105.53198, 37.2495995, -10195.5088, -0.766061664, 0, -0.642767608, 0, 1, 0, 0.642767608, 0, -0.766061664), MonterPos = CFrame.new(-2150.587890625, 122.49767303467, -10358.994140625)},
        {MinLevel = 2125, MaxLevel = 2149, Monster = "Ice Cream Chef",      Quest = "IceCreamIslandQuest", QuestLevel = 1, NPCPos = CFrame.new(-819.376709, 64.9259796, -10967.2832, -0.766061664, 0, 0.642767608, 0, 1, 0, -0.642767608, 0, -0.766061664), MonterPos = CFrame.new(-789.941528, 209.382889, -11009.9805, -0.0703101531, 0, -0.997525156, 0, 1, 0, 0.997525275, 0, -0.0703101456)},
        {MinLevel = 2150, MaxLevel = 2199, Monster = "Ice Cream Commander", Quest = "IceCreamIslandQuest", QuestLevel = 2, NPCPos = CFrame.new(-819.376709, 64.9259796, -10967.2832, -0.766061664, 0, 0.642767608, 0, 1, 0, -0.642767608, 0, -0.766061664), MonterPos = CFrame.new(-789.941528, 209.382889, -11009.9805, -0.0703101531, 0, -0.997525156, 0, 1, 0, 0.997525275, 0, -0.0703101456)},
        {MinLevel = 2200, MaxLevel = 2224, Monster = "Cookie Crafter",      Quest = "CakeQuest1",        QuestLevel = 1, NPCPos = CFrame.new(-2022.29858, 36.9275894, -12030.9766, -0.961273909, 0, -0.275594592, 0, 1, 0, 0.275594592, 0, -0.961273909), MonterPos = CFrame.new(-2321.71216, 36.699482, -12216.7871, -0.780074954, 0, 0.625686109, 0, 1, 0, -0.625686109, 0, -0.780074954)},
        {MinLevel = 2225, MaxLevel = 2249, Monster = "Cake Guard",           Quest = "CakeQuest1",        QuestLevel = 2, NPCPos = CFrame.new(-2022.29858, 36.9275894, -12030.9766, -0.961273909, 0, -0.275594592, 0, 1, 0, 0.275594592, 0, -0.961273909), MonterPos = CFrame.new(-1418.11011, 36.6718941, -12255.7324, 0.0677844882, 0, 0.997700036, 0, 1, 0, -0.997700036, 0, 0.0677844882)},
        {MinLevel = 2250, MaxLevel = 2274, Monster = "Baking Staff",        Quest = "CakeQuest2",        QuestLevel = 1, NPCPos = CFrame.new(-1928.31763, 37.7296638, -12840.626, 0.951068401, 0, -0.308980465, 0, 1, 0, 0.308980465, 0, 0.951068401), MonterPos = CFrame.new(-1980.43848, 36.6716766, -12983.8418, -0.254443765, 0, -0.967087567, 0, 1, 0, 0.967087567, 0, -0.254443765)},
        {MinLevel = 2275, MaxLevel = 2299, Monster = "Head Baker",          Quest = "CakeQuest2",        QuestLevel = 2, NPCPos = CFrame.new(-1928.31763, 37.7296638, -12840.626, 0.951068401, 0, -0.308980465, 0, 1, 0, 0.308980465, 0, 0.951068401), MonterPos = CFrame.new(-2251.5791, 52.2714615, -13033.3965, -0.991971016, 0, -0.126466095, 0, 1, 0, 0.126466095, 0, -0.991971016)},
        {MinLevel = 2300, MaxLevel = 2324, Monster = "Cocoa Warrior",       Quest = "ChocQuest1",        QuestLevel = 1, NPCPos = CFrame.new(231.75, 23.9003029, -12200.292, -1, 0, 0, 0, 1, 0, 0, 0, -1), MonterPos = CFrame.new(167.978516, 26.2254658, -12238.874, -0.939700961, 0, 0.341998369, 0, 1, 0, -0.341998369, 0, -0.939700961)},
        {MinLevel = 2325, MaxLevel = 2349, Monster = "Chocolate Bar Battler", Quest = "ChocQuest1",      QuestLevel = 2, NPCPos = CFrame.new(231.75, 23.9003029, -12200.292, -1, 0, 0, 0, 1, 0, 0, 0, -1), MonterPos = CFrame.new(701.312073, 25.5824986, -12708.2148, -0.342042685, 0, -0.939684391, 0, 1, 0, 0.939684391, 0, -0.342042685)},
        {MinLevel = 2350, MaxLevel = 2374, Monster = "Sweet Thief",         Quest = "ChocQuest2",        QuestLevel = 1, NPCPos = CFrame.new(151.198242, 23.8907146, -12774.6172, 0.422592998, 0, 0.906319618, 0, 1, 0, -0.906319618, 0, 0.422592998), MonterPos = CFrame.new(-140.258301, 25.5824986, -12652.3115, 0.173624337, 0, -0.984811902, 0, 1, 0, 0.984811902, 0, 0.173624337)},
        {MinLevel = 2375, MaxLevel = 2399, Monster = "Candy Rebel",         Quest = "ChocQuest2",        QuestLevel = 2, NPCPos = CFrame.new(151.198242, 23.8907146, -12774.6172, 0.422592998, 0, 0.906319618, 0, 1, 0, -0.906319618, 0, 0.422592998), MonterPos = CFrame.new(47.9231453, 25.5824986, -13029.2402, -0.819156051, 0, -0.573571265, 0, 1, 0, 0.573571265, 0, -0.819156051)},
        {MinLevel = 2400, MaxLevel = 2424, Monster = "Candy Pirate",        Quest = "CandyQuest1",       QuestLevel = 1, NPCPos = CFrame.new(-1149.328, 13.5759039, -14445.6143, -0.156446099, 0, -0.987686574, 0, 1, 0, 0.987686574, 0, -0.156446099), MonterPos = CFrame.new(-1437.56348, 17.1481285, -14385.6934, 0.173624337, 0, -0.984811902, 0, 1, 0, 0.984811902, 0, 0.173624337)},
        {MinLevel = 2425, MaxLevel = 2449, Monster = "Snow Demon",           Quest = "CandyQuest1",       QuestLevel = 2, NPCPos = CFrame.new(-1149.328, 13.5759039, -14445.6143, -0.156446099, 0, -0.987686574, 0, 1, 0, 0.987686574, 0, -0.156446099), MonterPos = CFrame.new(-916.222656, 17.1481285, -14638.8125, 0.866007268, 0, 0.500031412, 0, 1, 0, -0.500031412, 0, 0.866007268)},
        {MinLevel = 2450, MaxLevel = 2474, Monster = "Isle Outlaw",          Quest = "TikiQuest1",        QuestLevel = 1, NPCPos = CFrame.new(-16549.890625, 55.68635559082031, -179.91360473632812), MonterPos = CFrame.new(-16162.8193359375, 11.6863374710083, -96.45481872558594)},
        {MinLevel = 2475, MaxLevel = 2499, Monster = "Island Boy",           Quest = "TikiQuest1",        QuestLevel = 2, NPCPos = CFrame.new(-16549.890625, 55.68635559082031, -179.91360473632812), MonterPos = CFrame.new(-16357.3125, 20.632822036743164, 1005.64892578125)},
        {MinLevel = 2500, MaxLevel = 2524, Monster = "Sun-kissed Warrior",   Quest = "TikiQuest2",        QuestLevel = 1, NPCPos = CFrame.new(-16541.021484375, 54.77081298828125, 1051.461181640625), MonterPos = CFrame.new(-16357.3125, 20.632822036743164, 1005.64892578125)},
        {MinLevel = 2525, MaxLevel = 2549, Monster = "Isle Champion",        Quest = "TikiQuest2",        QuestLevel = 2, NPCPos = CFrame.new(-16541.021484375, 54.77081298828125, 1051.461181640625), MonterPos = CFrame.new(-16848.94140625, 21.68633460998535, 1041.4490966796875)},
        {MinLevel = 2550, MaxLevel = 2574, Monster = "Serpent Hunter",       Quest = "TikiQuest3",        QuestLevel = 1, NPCPos = CFrame.new(-16665.19140625, 104.59640502929688, 1579.6943359375), MonterPos = CFrame.new(-16621.4140625, 121.40631103515625, 1290.6881103515625)},
        {MinLevel = 2575, MaxLevel = 9999, Monster = "Skull Slayer",         Quest = "TikiQuest3",        QuestLevel = 2, NPCPos = CFrame.new(-16665.19140625, 104.59640502929688, 1579.6943359375), MonterPos = CFrame.new(-16811.5703125, 84.625244140625, 1542.235107421875)},
    }
}
