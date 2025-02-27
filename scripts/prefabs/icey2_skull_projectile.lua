local assets =
{
    Asset("ANIM", "anim/icey2_skull_projectile.zip"),
    Asset("ANIM", "anim/icey2_advance_height_controler.zip"),
}

local FX_HEIGHTS = { -50, -25, -65, -45, -50 }

local function Projectile_OnLaunch(inst)
    inst.start_time = GetTime()
    inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)

    local fat_tail = SpawnAt("icey2_skull_fat_tail_fx", inst)
    fat_tail:Emit(inst.Transform:GetRotation())
end

local function Projectile_OnHit(inst, attacker, target)
    local self = inst.components.complexprojectile
    if attacker and target and self.owningweapon then
        if attacker ~= nil and attacker.components.combat ~= nil then
            local old_ignorehitrange = attacker.components.combat.ignorehitrange

            attacker.components.combat.ignorehitrange = true
            attacker.components.combat:DoAttack(target, self.owningweapon, inst, self.stimuli)
            attacker.components.combat.ignorehitrange = old_ignorehitrange
        end


        -- local start_pos = inst:GetPosition()
        -- start_pos.y = start_pos.y + GetRandomMinMax(0.8, 1.2)
        -- local fx = SpawnAt("icey2_supply_ball_shield_spawn", start_pos)
        -- local s = 1
        -- fx.Transform:SetScale(s, s, s)
        -- fx:FaceAwayFromPoint(attacker:GetPosition(), true)
        -- fx:SpawnChild("icey2_blue_fire_explode_vfx")

        local fx = SpawnAt("icey2_skull_projectile_hitfx", inst)
        fx.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_gunlance/hit")
    end



    inst:Remove()
end

local function Projectile_OnUpdateFn(inst, dt)
    dt = dt or FRAMES

    local self = inst.components.complexprojectile

    if GetTime() - inst.start_time > 2 then
        self:Hit()
        return true
    end


    local hit_pos = inst:GetPosition()
    local x, y, z = hit_pos:Get()

    inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)

    for k, v in pairs(TheSim:FindEntities(x, y, z, 4, { "_combat" })) do
        local rad = 0.5

        if self.attacker.components.combat:CanTarget(v) and not self.attacker.components.combat:IsAlly(v) then
            local hit_dist = rad + v:GetPhysicsRadius(0)
            local curr_dist = (hit_pos - v:GetPosition()):Length()

            if curr_dist <= hit_dist then
                self:Hit(v)
                break
            end
        end
    end

    local fat_tail = SpawnAt("icey2_skull_fat_tail_fx", inst)
    fat_tail:Emit(inst.Transform:GetRotation())

    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeProjectilePhysics(inst)

    inst.Transform:SetEightFaced()

    inst.AnimState:SetBank("icey2_advance_height_controler")
    inst.AnimState:SetBuild("icey2_advance_height_controler")
    inst.AnimState:PlayAnimation("mult_face")
    inst.AnimState:SetSymbolMultColour("swap_object", 0, 0, 0, 0)

    inst.AnimState:SetSortOrder(1)

    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")




    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(35)
    inst.components.complexprojectile:SetOnLaunch(Projectile_OnLaunch)
    inst.components.complexprojectile:SetOnHit(Projectile_OnHit)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(1.5, 0, 0))
    inst.components.complexprojectile.onupdatefn = Projectile_OnUpdateFn



    inst.skull_anims = {}
    inst.tail_vfxs = {}

    for i = 1, 5 do
        local skull = inst:SpawnChild("icey2_skull_projectile_anim")
        skull.entity:AddFollower()
        skull.AnimState:PlayAnimation("skull_" .. (i - 1))
        table.insert(inst.skull_anims, skull)

        -- local tail = inst:SpawnChild("icey2_skull_tail_vfx")
        -- tail.entity:AddFollower()
        -- table.insert(inst.tail_vfxs, tail)
    end

    for i = 1, 5 do
        inst.skull_anims[i].Follower:FollowSymbol(inst.GUID, "swap_object", 0, FX_HEIGHTS[i], 0, true, nil, i - 1)
    end
    -- inst.skull_anims[1].Follower:FollowSymbol(inst.GUID, "swap_object", 0, -50, 0, true, nil, 0)
    -- inst.skull_anims[2].Follower:FollowSymbol(inst.GUID, "swap_object", 0, -25, 0, true, nil, 1)
    -- inst.skull_anims[3].Follower:FollowSymbol(inst.GUID, "swap_object", 0, -65, 0, true, nil, 2)
    -- inst.skull_anims[4].Follower:FollowSymbol(inst.GUID, "swap_object", 0, -45, 0, true, nil, 3)
    -- inst.skull_anims[5].Follower:FollowSymbol(inst.GUID, "swap_object", 0, -50, 0, true, nil, 4)


    -- inst.tail_vfxs[1].Follower:FollowSymbol(inst.GUID, "swap_object", 0, -50, 0, nil, nil, 0)
    -- inst.tail_vfxs[2].Follower:FollowSymbol(inst.GUID, "swap_object", 0, -25, 0, nil, nil, 1)
    -- inst.tail_vfxs[3].Follower:FollowSymbol(inst.GUID, "swap_object", 0, -65, 0, nil, nil, 2)
    -- inst.tail_vfxs[4].Follower:FollowSymbol(inst.GUID, "swap_object", 0, -45, 0, nil, nil, 3)
    -- inst.tail_vfxs[5].Follower:FollowSymbol(inst.GUID, "swap_object", 0, -50, 0, nil, nil, 4)


    local tail = inst:SpawnChild("icey2_skull_tail_vfx")
    tail.entity:AddFollower()
    tail.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -60, 0)

    return inst
end

local function anim_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("icey2_skull_projectile")
    inst.AnimState:SetBuild("icey2_skull_projectile")
    inst.AnimState:SetLightOverride(1)
    -- inst.AnimState:SetHaunted(true)


    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst:AddComponent("colouradder")

    inst.persists = false

    return inst
end

local function CreateHitAnim()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()


    inst.AnimState:SetBank("deer_ice_charge")
    inst.AnimState:SetBuild("deer_ice_charge")
    inst.AnimState:PlayAnimation("blast")

    -- inst.AnimState:HideSymbol("glow_")

    inst.AnimState:SetLightOverride(1)

    for _, v in pairs({ "blast", "line" }) do
        inst.AnimState:SetSymbolAddColour(v, 0 / 255, 148 / 255, 230 / 255, 1)
    end

    inst.AnimState:SetDeltaTimeMultiplier(1.5)


    return inst
end

local function hitfx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Transform:SetEightFaced()

    inst.AnimState:SetBank("icey2_advance_height_controler")
    inst.AnimState:SetBuild("icey2_advance_height_controler")
    inst.AnimState:PlayAnimation("mult_face")
    inst.AnimState:SetSymbolMultColour("swap_object", 0, 0, 0, 0)

    -- inst.AnimState:SetSortOrder(1)

    local height_offset = -15

    if not TheNet:IsDedicated() then
        for i = 1, 5 do
            local anim = CreateHitAnim()
            inst:AddChild(anim)
            anim.Follower:FollowSymbol(inst.GUID, "swap_object", 0, FX_HEIGHTS[i] + height_offset, 0, true, nil, i - 1)
        end
    end


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst.persists = false

    for i = 1, 5 do
        local vfx = inst:SpawnChild("icey2_blue_fire_explode_vfx")
        vfx.entity:AddFollower()
        vfx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, FX_HEIGHTS[i] + height_offset, 0, true, nil, i - 1)

        -- inst:DoTaskInTime(0, function()
        vfx._can_emit:set(true)
        -- end)
    end

    -- local vfx = inst:SpawnChild("icey2_blue_fire_explode_vfx")
    -- vfx.entity:AddFollower()
    -- vfx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -50, 0)

    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

return Prefab("icey2_skull_projectile", fn, assets),
    Prefab("icey2_skull_projectile_anim", anim_fn, assets),
    Prefab("icey2_skull_projectile_hitfx", hitfx_fn, assets)
