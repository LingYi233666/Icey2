local assets = {
    Asset("ANIM", "anim/icey2_skull_pile.zip"),

    Asset("IMAGE", "images/map_icons/icey2_skull_pile.tex"), -- 小地图
    Asset("ATLAS", "images/map_icons/icey2_skull_pile.xml"),
}

local FULL_WORKLEFT = 15

SetSharedLootTable("icey2_skull_pile_mining",
    {
        { "wagpunk_bits", 1.00 },
        { "wagpunk_bits", 0.67 },
        { "transistor",   1.00 },
        { "transistor",   0.67 },
        { "rocks",        0.25 },
        { "log",          0.25 },
        { "boards",       0.12 },
        { "trinket_6",    0.12 },
        { "blueprint",    0.12 },
        { "gears",        0.12 },
    }
)

-- SetSharedLootTable("icey2_skull_pile_mining_2",
--     {
--         { "wagpunk_bits", 0.3 },
--         { "rocks",        0.06 },
--         { "log",          0.06 },
--         { "boards",       0.03 },
--         { "transistor",   0.03 },
--         { "trinket_6",    0.03 },
--         { "blueprint",    0.03 },
--         { "gears",        0.03 },
--     }
-- )

SetSharedLootTable("icey2_skull_pile_final",
    {
        { "icey2_blood_metal", 1.00 },
        { "wagpunk_bits",      1.00 },
        { "wagpunk_bits",      1.00 },
        { "wagpunk_bits",      1.00 },
        { "wagpunk_bits",      0.67 },
        { "transistor",        0.50 },
        { "trinket_6",         0.50 },
        { "blueprint",         0.50 },
        { "rocks",             0.12 },
        { "log",               0.12 },
        { "boards",            0.06 },
        { "gears",             0.03 },
    }
)

local function ResetLottRequiredCount(inst)
    inst.loot_required_count = math.random(2)
end

local function CheckAnim(inst)
    local workleft = inst.components.workable:GetWorkLeft()
    inst.AnimState:PlayAnimation(
        (workleft < FULL_WORKLEFT / 3 and "low") or
        (workleft < FULL_WORKLEFT * 2 / 3 and "med") or
        "full"
    )

    inst.loot_height = (workleft < FULL_WORKLEFT / 3 and 1.5) or
        (workleft < FULL_WORKLEFT * 2 / 3 and 2) or
        3
end

local function OnWork(inst, worker, workleft)
    local loot_pt = inst:GetPosition()
    loot_pt.y = loot_pt.y + inst.loot_height

    if workleft <= 0 then
        ShakeAllCameras(CAMERASHAKE.FULL, 0.8, .03, .25, nil, 40)

        inst.components.lootdropper:SetChanceLootTable("icey2_skull_pile_final")
        inst.components.lootdropper:DropLoot(loot_pt)

        local fx = SpawnAt("collapse_big", inst)
        fx:SetMaterial("metal")

        inst:Remove()
        return
    end


    local old_height = inst.loot_height
    CheckAnim(inst)

    if old_height and math.abs(old_height - inst.loot_height) > 1e-6 then
        inst.components.lootdropper:SetChanceLootTable("icey2_skull_pile_mining")
        inst.components.lootdropper:DropLoot(loot_pt)

        ShakeAllCameras(CAMERASHAKE.FULL, 0.6, .02, .2, nil, 40)

        local fx = inst:SpawnChild("collapse_small")
        if not fx.Follower then
            fx.entity:AddFollower()
        end
        fx.Follower:FollowSymbol(inst.GUID, "chest", 0, -100 * inst.loot_height, 0, true)

        inst.SoundEmitter:PlaySound("dontstarve/common/lightningrod")
    end

    -- inst.loot_required_count = inst.loot_required_count - 1
    -- if inst.loot_required_count <= 0 then
    --     inst.components.lootdropper:SetChanceLootTable("icey2_skull_pile_mining")
    --     inst.components.lootdropper:DropLoot(loot_pt)
    --     ResetLottRequiredCount(inst)
    -- end
end

local function WorkableOnLoad(inst, data)
    CheckAnim(inst)
end

local function EnableGhostFX(inst, enable)
    if inst.ghost_task then
        inst.ghost_task:Cancel()
        inst.ghost_task = nil
    end

    if enable then
        local workleft = inst.components.workable:GetWorkLeft()

        inst.ghost_task = inst:DoPeriodicTask(FRAMES * 2, function()
            local min_height, max_height = 1.7, 4
            local height = GetRandomMinMax(min_height, inst.loot_height + 1)
            local down_radius, up_radius = 2, 0.5
            local max_radius = Remap(height, min_height, max_height, down_radius, up_radius)

            inst.last_emit_theta = inst.last_emit_theta or math.random() * PI2
            local offset = Vector3FromTheta(inst.last_emit_theta, GetRandomMinMax(max_radius * 0.5, max_radius))
            offset.y = height

            local s = 6
            -- local fx = SpawnAt("icey2_skull_fx", inst, Vector3(s, s, s), offset)
            local fx = SpawnAt("icey2_soul_fx_small", inst, Vector3(s, s, s), offset)

            fx:FadeIn(0.2)
            fx:DoTaskInTime(0.5, function()
                fx:FadeOut(0.46)
            end)
            fx:FlyUp(2, -0.3)

            inst.last_emit_theta = inst.last_emit_theta + GetRandomMinMax(PI / 3, PI) * (math.random() > 0.5 and 1 or -1)
            if inst.last_emit_theta >= PI2 then
                inst.last_emit_theta = inst.last_emit_theta - PI2
            end
            if inst.last_emit_theta < 0 then
                inst.last_emit_theta = inst.last_emit_theta + PI2
            end
        end)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1.5)

    inst.MiniMapEntity:SetIcon("icey2_skull_pile.tex")

    inst.AnimState:SetBank("icey2_skull_pile")
    inst.AnimState:SetBuild("icey2_skull_pile")
    inst.AnimState:PlayAnimation("full")

    inst:AddTag("boulder")


    local s = 1.33
    inst.AnimState:SetScale(s, s, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.EnableGhostFX = EnableGhostFX

    inst:AddComponent("lootdropper")
    -- inst.components.lootdropper.min_speed = 3
    -- inst.components.lootdropper.min_speed = 6

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(FULL_WORKLEFT)
    inst.components.workable:SetOnWorkCallback(OnWork)
    inst.components.workable:SetOnLoadFn(WorkableOnLoad)
    inst.components.workable.savestate = true

    inst:AddComponent("inspectable")


    local colour = GetRandomMinMax(0.6, 0.8)
    inst.AnimState:SetMultColour(colour, colour, colour, 1)

    MakeHauntableWork(inst)
    ResetLottRequiredCount(inst)
    CheckAnim(inst)
    EnableGhostFX(inst, true)

    return inst
end

return Prefab("icey2_skull_pile", fn, assets)
