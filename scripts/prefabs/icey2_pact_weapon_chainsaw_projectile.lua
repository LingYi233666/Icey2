local assets =
{
    Asset("ANIM", "anim/icey2_advance_height_controler.zip"),
    Asset("ANIM", "anim/icey2_pact_weapon_chainsaw.zip"),
}


local function OnLaunch(inst, attacker, targetPos)
    inst.start_time = GetTime()
    inst.motor_vel = Vector3(inst.components.complexprojectile.horizontalSpeed, 0, 0)
    inst.Physics:SetMotorVel(inst.motor_vel:Get())


    local function OnOwnerAttack(_, data)
        if data.weapon == inst then
            return
        end

        local target = data.target

        if (inst.last_rotate_time == nil or GetTime() - inst.last_rotate_time > 1)
            and target
            and target:IsValid() then
            -- local cur_speed = inst.motor_vel:Length()
            local target_pos = target:GetPosition()
            local my_pos = inst:GetPosition()
            local delta_pos = (target_pos - my_pos)
            local direction = delta_pos:GetNormalized()
            local speed = delta_pos:Length()
            -- speed = math.clamp(speed, 30, 40)
            speed = math.max(speed, 40)



            local new_vel = direction * speed
            new_vel = new_vel + my_pos
            new_vel.x, new_vel.y, new_vel.z = inst.entity:WorldToLocalSpace(new_vel.x, new_vel.y, new_vel.z)

            inst.motor_vel = new_vel
            inst.Physics:SetMotorVel(inst.motor_vel:Get())

            inst.last_rotate_time = GetTime()
        end
    end

    inst:ListenForEvent("onhitother", OnOwnerAttack, attacker)
end

local function OnHit(inst, attacker, target)
    inst:Remove()
end

local function OnUpdateFn(inst, dt)
    dt = dt or FRAMES


    local attacker = inst.components.complexprojectile.attacker

    inst.motor_vel = inst.components.icey2_elasticity_force:GetAfterVel(attacker, inst.motor_vel, dt, true)
    inst.Physics:SetMotorVel(inst.motor_vel:Get())

    local hit_pos = inst:GetPosition()
    local x, y, z = hit_pos:Get()
    -- local rad = 2
    local rad = 1
    local factor = inst.motor_vel:Length()
    factor = math.clamp(factor, 0, 40)
    factor = Remap(factor, 0, 40, 1, 2)

    for k, v in pairs(TheSim:FindEntities(x, y, z, 6, nil, { "INLIMBO" }, { "_combat", "CHOP_workable" })) do
        if inst.victims[v] and GetTime() - inst.victims[v] < 0.3 then

        else
            local hit_dist = rad + v:GetPhysicsRadius(0)
            local curr_dist = (hit_pos - v:GetPosition()):Length()

            if curr_dist <= hit_dist then
                if attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then
                    attacker.components.combat:DoAttack(v, inst, inst, nil, factor, 99999, hit_pos)
                    inst.victims[v] = GetTime()
                elseif v.components.workable and v.components.workable.action == ACTIONS.CHOP then
                    v.components.workable:WorkedBy(attacker, 2 * factor)
                    inst.victims[v] = GetTime()
                end
            end
        end
    end

    return true
end

local function OnAttack(inst, attacker, target)
    local start_pos = target:GetPosition()
    start_pos.y = start_pos.y + GetRandomMinMax(0.6, 0.8)

    local fx = SpawnAt("icey2_supply_ball_shield_spawn", start_pos)
    fx:FaceAwayFromPoint(inst:GetPosition(), true)
    -- fx:SpawnChild("icey2_melee_hit_vfx")

    inst.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_chainsaw/hit", nil, 0.8)
end

local function projectile_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeProjectilePhysics(inst)

    inst.AnimState:SetBank("icey2_advance_height_controler")
    inst.AnimState:SetBuild("icey2_advance_height_controler")
    inst.AnimState:PlayAnimation("no_face")
    inst.AnimState:SetSymbolMultColour("swap_object", 0, 0, 0, 0)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.victims = {}

    inst.persists = false

    inst:AddComponent("icey2_elasticity_force")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(10)
    inst.components.weapon:SetOnAttack(OnAttack)

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetOnLaunch(OnLaunch)
    inst.components.complexprojectile:SetOnHit(OnHit)
    inst.components.complexprojectile:SetHorizontalSpeed(30)
    inst.components.complexprojectile.onupdatefn = OnUpdateFn

    inst.anim = inst:SpawnChild("icey2_pact_weapon_chainsaw_projectile_anim")
    inst.anim.entity:AddFollower()
    inst.anim.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -50, 0)

    -- inst.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_chainsaw/pan_loop", "pan_loop", 0.1)

    return inst
end

local function anim_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("icey2_pact_weapon_chainsaw")
    inst.AnimState:SetBuild("icey2_pact_weapon_chainsaw")
    inst.AnimState:PlayAnimation("proj", true)
    inst.AnimState:SetDeltaTimeMultiplier(4)

    -- local s = 2
    local s = 1
    inst.AnimState:SetScale(s, s, 1)

    inst.AnimState:SetLightOverride(0.6)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD)
    -- inst.AnimState:SetSortOrder(3)


    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst:AddComponent("colouradder")

    inst.persists = false

    return inst
end

-- c_spawn("icey2_pact_weapon_chainsaw_projectile").components.complexprojectile:Launch(TheInput:GetWorldPosition(),ThePlayer)
return Prefab("icey2_pact_weapon_chainsaw_projectile", projectile_fn, assets),
    Prefab("icey2_pact_weapon_chainsaw_projectile_anim", anim_fn, assets)
