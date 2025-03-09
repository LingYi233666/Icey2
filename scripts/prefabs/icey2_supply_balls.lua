local assets =
{
    Asset("ANIM", "anim/deer_ice_charge.zip"),
    Asset("ANIM", "anim/deer_fire_charge.zip"),
}

local SCALE_BALL_SHIELD = 0.7
local SCALE_BALL_HEALTH = 0.7

local SCALE_BALL_SHIELD_SMALL = 0.3
local SCALE_BALL_HEALTH_SMALL = 0.3

local MULTCOLOUR_SHIELD = { 96 / 255, 249 / 255, 255 / 255, 1 }
local MULTCOLOUR_HEALTH = { 0.8, 0.1, 0.1, 1 }

-- local function OnAbsorb_Shield(inst, player)
--     if player and player.components.icey2_skill_shield then
--         player.components.icey2_skill_shield:DoDelta(5)
--     end
--     SpawnAt("icey2_supply_ball_shield_hit", inst)
--     inst:Remove()
-- end

-- local function OnAbsorb_Health(inst, player)
--     if player and player.components.health then
--         player.components.health:DoDelta(3.75, true)
--     end
--     SpawnAt("icey2_supply_ball_health_hit", inst)
--     inst:Remove()
-- end

-- local function OnAbsorb_Shield_Small(inst, player)
--     if player and player.components.icey2_skill_shield then
--         player.components.icey2_skill_shield:DoDelta(1)
--     end
--     SpawnAt("icey2_supply_ball_shield_small_hit", inst)
--     inst:Remove()
-- end

-- local function OnAbsorb_Health_Small(inst, player)
--     if player and player.components.health then
--         player.components.health:DoDelta(0.5, true)
--     end
--     SpawnAt("icey2_supply_ball_health_small_hit", inst)
--     inst:Remove()
-- end

local function OnAbsorb(inst, player)
    if player then
        if inst.shield_recover and player.components.icey2_skill_shield then
            player.components.icey2_skill_shield:DoDelta(inst.shield_recover)
        end

        if inst.health_recover and player.components.health then
            player.components.health:DoDelta(inst.health_recover, true)
        end
    end

    SpawnAt(inst.prefab .. "_hit", inst)
    inst:Remove()
end


local function OnUpdateFn(inst, dt)
    local target = inst.chasing_target
    if not (target and target:IsValid() and not IsEntityDeadOrGhost(target, true)) then
        if inst.OnAbsordFn then
            inst:OnAbsordFn()
        end
        return true
    end

    local my_pos = inst:GetPosition()
    local target_pos = inst:GetTargetPosition(target)


    if (my_pos - target_pos):Length() < 0.5 or (my_pos - target:GetPosition()):Length() < 0.5 then
        if inst.OnAbsordFn then
            inst:OnAbsordFn(target)
        end
        return true
    end

    if GetTime() - inst.start_launch_time < inst.chase_after_time then
        local vx, vy, vz = (inst.direction * inst.speed):Get()
        inst.Physics:SetVel(vx, vy, vz)
        return true
    end

    local towards = target_pos - inst:GetPosition()

    local delta_vec = towards:GetNormalized() - inst.direction

    -- local max_delta_length = 5 * FRAMES
    -- if delta_vec:Length() < max_delta_length or inst.locked then
    --     inst.locked = true
    --     inst.direction = towards:GetNormalized()
    -- else
    --     inst.direction = inst.direction + delta_vec:GetNormalized() * max_delta_length
    -- end

    local cut_angle = Icey2Math.RadiansBetweenVectors(inst.direction, towards) * RADIANS
    local is_inverse_moving = math.abs(cut_angle) > 90

    if math.abs(cut_angle) < 10 or inst.locked then
        inst.locked = true
        inst.direction = towards:GetNormalized()
    else
        inst.direction = inst.direction + delta_vec:GetNormalized() * 0.14
    end

    local vx, vy, vz = (inst.direction * inst.speed):Get()
    inst.Physics:SetVel(vx, vy, vz)

    if is_inverse_moving then
        inst.speed = inst.speed - dt * 5
    else
        inst.speed = inst.speed + dt * 15
    end

    inst.speed = math.clamp(inst.speed, 10, 30)
end

local function Setup(inst, player, pos_start)
    if pos_start == nil then
        pos_start = inst:GetPosition()
    end
    -- pos_start.y = pos_start.y + GetRandomMinMax(2, 3)
    -- pos_start.y = pos_start.y
    local pos_player = player:GetPosition()

    local vec_out    = (pos_start - pos_player):GetNormalized()
    vec_out.y        = 0
    local vec_up     = Vector3(0, 1, 0)
    local vec_z      = vec_out:Cross(vec_up)

    local theta_1    = GetRandomMinMax(-45, 45) * DEGREES
    local theta_2    = GetRandomMinMax(0, 60) * DEGREES


    inst.speed             = GetRandomMinMax(8, 10)
    inst.direction         = vec_out * math.cos(theta_1) * math.cos(theta_2) + vec_up * math.sin(theta_2) +
        vec_z * math.sin(theta_1) * math.cos(theta_2)
    inst.chasing_target    = player
    inst.start_launch_time = GetTime()


    inst.Transform:SetPosition(pos_start:Get())
    inst.Physics:SetVel((inst.direction * inst.speed):Get())


    if inst.tail_prefab then
        inst.vfx = inst:SpawnChild(inst.tail_prefab)
        inst.vfx.entity:AddFollower()
        inst.vfx.Follower:FollowSymbol(inst.GUID, "glow_", 0, 0, 0)
    end

    inst.components.updatelooper:AddOnUpdateFn(OnUpdateFn)
end

local function GetTargetPosition(inst, target)
    return target:GetPosition() + (inst.target_offset or Vector3(0, 0, 0))
end

local function fn_common()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetDeltaTimeMultiplier(3)

    MakeProjectilePhysics(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.chase_after_time = GetRandomMinMax(0.4, 0.6)
    inst.target_offset = Vector3FromTheta(math.random() * PI2, 0.4)
    inst.target_offset.y = math.random(1, 1.75)

    inst.Setup = Setup
    inst.GetTargetPosition = GetTargetPosition
    inst.OnAbsordFn = OnAbsorb


    inst:AddComponent("updatelooper")

    inst:ListenForEvent("animover", function()
        inst.AnimState:SetDeltaTimeMultiplier(1)
    end)

    inst.persists = false

    return inst
end

local function fn_shield()
    local inst = fn_common()

    inst.AnimState:SetBank("deer_ice_charge")
    inst.AnimState:SetBuild("deer_ice_charge")
    inst.AnimState:PlayAnimation("pre")
    inst.AnimState:PushAnimation("loop", true)

    inst.AnimState:HideSymbol("line")
    inst.AnimState:HideSymbol("blast")

    inst.AnimState:SetMultColour(unpack(MULTCOLOUR_SHIELD))

    inst.Transform:SetScale(SCALE_BALL_SHIELD, SCALE_BALL_SHIELD, 1)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.shield_recover = 3
    inst.tail_prefab = "icey2_supply_ball_tail_blue"



    return inst
end

local function fn_shield_small()
    local inst = fn_shield()

    inst.Transform:SetScale(SCALE_BALL_SHIELD_SMALL, SCALE_BALL_SHIELD_SMALL, 1)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.shield_recover = 1
    inst.tail_prefab = "icey2_supply_ball_tail_blue_small"

    return inst
end


local function fn_health()
    local inst = fn_common()

    inst.AnimState:SetBank("deer_fire_charge")
    inst.AnimState:SetBuild("deer_fire_charge")
    inst.AnimState:PlayAnimation("pre")
    inst.AnimState:PushAnimation("loop", true)

    inst.AnimState:HideSymbol("line")
    inst.AnimState:HideSymbol("fire_puff_fx")
    inst.AnimState:HideSymbol("blast")

    inst.AnimState:SetMultColour(unpack(MULTCOLOUR_HEALTH))

    inst.Transform:SetScale(SCALE_BALL_HEALTH, SCALE_BALL_HEALTH, 1)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.health_recover = 3.75

    inst.tail_prefab = "icey2_supply_ball_tail_red"

    return inst
end


local function fn_health_small()
    local inst = fn_health()

    inst.Transform:SetScale(SCALE_BALL_HEALTH_SMALL, SCALE_BALL_HEALTH_SMALL, 1)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.health_recover = 0.5
    inst.tail_prefab = "icey2_supply_ball_tail_red_small"

    return inst
end

local function fn_shield_hit()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("deer_ice_charge")
    inst.AnimState:SetBuild("deer_ice_charge")
    inst.AnimState:PlayAnimation("blast")

    inst.AnimState:HideSymbol("line")
    inst.AnimState:HideSymbol("blast")

    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetMultColour(unpack(MULTCOLOUR_SHIELD))

    inst.AnimState:SetDeltaTimeMultiplier(2)

    inst.Transform:SetScale(SCALE_BALL_SHIELD, SCALE_BALL_SHIELD, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function fn_shield_hit_small()
    local inst = fn_shield_hit()

    inst.Transform:SetScale(SCALE_BALL_SHIELD_SMALL, SCALE_BALL_SHIELD_SMALL, 1)

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function fn_health_hit()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("deer_fire_charge")
    inst.AnimState:SetBuild("deer_fire_charge")
    inst.AnimState:PlayAnimation("blast")

    inst.AnimState:HideSymbol("line")
    inst.AnimState:HideSymbol("fire_puff_fx")
    inst.AnimState:HideSymbol("blast")

    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetMultColour(unpack(MULTCOLOUR_HEALTH))

    inst.AnimState:SetDeltaTimeMultiplier(2)

    inst.Transform:SetScale(SCALE_BALL_HEALTH, SCALE_BALL_HEALTH, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end


local function fn_health_hit_small()
    local inst = fn_health_hit()

    inst.Transform:SetScale(SCALE_BALL_HEALTH_SMALL, SCALE_BALL_HEALTH_SMALL, 1)

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end


local function fn_shield_spawn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("deer_ice_charge")
    inst.AnimState:SetBuild("deer_ice_charge")
    inst.AnimState:PlayAnimation("blast")

    inst.AnimState:HideSymbol("glow_")

    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetMultColour(unpack(MULTCOLOUR_SHIELD))

    inst.Transform:SetScale(SCALE_BALL_SHIELD, SCALE_BALL_SHIELD, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.vfx = inst:SpawnChild("icey2_focus_hit_vfx_blue")

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function fn_health_spawn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("deer_fire_charge")
    inst.AnimState:SetBuild("deer_fire_charge")
    inst.AnimState:PlayAnimation("blast")

    inst.AnimState:HideSymbol("glow_")
    inst.AnimState:HideSymbol("fire_puff_fx")

    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetMultColour(unpack(MULTCOLOUR_HEALTH))

    inst.Transform:SetScale(SCALE_BALL_HEALTH, SCALE_BALL_HEALTH, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.vfx = inst:SpawnChild("icey2_focus_hit_vfx_red")

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end


return Prefab("icey2_supply_ball_shield", fn_shield, assets),
    Prefab("icey2_supply_ball_health", fn_health, assets),
    Prefab("icey2_supply_ball_shield_small", fn_shield_small, assets),
    Prefab("icey2_supply_ball_health_small", fn_health_small, assets),
    Prefab("icey2_supply_ball_shield_hit", fn_shield_hit, assets),
    Prefab("icey2_supply_ball_health_hit", fn_health_hit, assets),
    Prefab("icey2_supply_ball_shield_small_hit", fn_shield_hit_small, assets),
    Prefab("icey2_supply_ball_health_small_hit", fn_health_hit_small, assets),
    Prefab("icey2_supply_ball_shield_spawn", fn_shield_spawn, assets),
    Prefab("icey2_supply_ball_health_spawn", fn_health_spawn, assets)
