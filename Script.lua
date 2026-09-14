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
