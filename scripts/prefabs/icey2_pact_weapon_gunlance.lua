local assets               =
{
    Asset("ANIM", "anim/icey2_pact_weapon_gunlance.zip"),
    Asset("ANIM", "anim/swap_icey2_pact_weapon_gunlance.zip"),
    Asset("ANIM", "anim/swap_icey2_pact_weapon_gunlance_range.zip"),

    Asset("ANIM", "anim/icey2_advance_height_controler.zip"),

    Asset("IMAGE", "images/inventoryimages/icey2_pact_weapon_gunlance.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_pact_weapon_gunlance.xml"),

    Asset("IMAGE", "images/inventoryimages/icey2_pact_weapon_gunlance_range.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_pact_weapon_gunlance_range.xml"),
}

local MELEE_PERIOD         = 17 * FRAMES
local OPENFIRE_VFX_OFFSETS = {
    -- Vector3(0, 182, 0),
    -- Vector3(85, 86, 0),
    -- Vector3(129, -33, 0),
    -- Vector3(55, -59, 0),
    -- Vector3(27, -166, 0),

    Vector3(0, 150, 0),
    Vector3(75, 79, 0),
    Vector3(115, -30, 0),
    Vector3(48, -55, 0),
    Vector3(24, -158, 0),
}

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_minigun", "swap_icey2_pact_weapon_gunlance_range", "swap_minigun")


    owner.AnimState:SetSymbolLightOverride("swap_object", 0.6)
    owner.AnimState:SetSymbolLightOverride("swap_minigun", 0.6)



    if inst.components.icey2_versatile_weapon:GetCurForm() == 1 then
        owner.AnimState:OverrideSymbol("swap_object", "swap_icey2_pact_weapon_gunlance",
            "swap_icey2_pact_weapon_gunlance")

        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")

        if owner.components.combat then
            owner.components.combat:SetAttackPeriod(MELEE_PERIOD)
        end
    elseif inst.components.icey2_versatile_weapon:GetCurForm() == 2 then
        owner.AnimState:OverrideSymbol("swap_object", "swap_icey2_pact_weapon_gunlance",
            "swap_icey2_pact_weapon_gunlance_range")

        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")


        if owner.components.combat then
            owner.components.combat:SetAttackPeriod(FRAMES)
        end
    end
end

--  ThePlayer.AnimState:Hide("ARM_carry") ThePlayer.AnimState:Show("ARM_normal")
local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    owner.AnimState:SetSymbolLightOverride("swap_object", 0)
    owner.AnimState:SetSymbolLightOverride("swap_minigun", 0)

    if owner.components.combat then
        owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
    end
end

local function OnAttackMelee(inst, attacker, target)
    local start_pos = target:GetPosition()
    start_pos.y = start_pos.y + GetRandomMinMax(0.8, 2)

    local fx = SpawnAt("icey2_supply_ball_shield_spawn", start_pos)
    fx:FaceAwayFromPoint(attacker:GetPosition(), true)
    fx:SpawnChild("icey2_melee_hit_vfx")

    if Icey2Basic.IsWearingArmor(attacker) then
        return
    end

    attacker.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_gunlance/melee_hit", nil, 0.3)

    local ball_prefabs = {
        { "icey2_supply_ball_shield",       1 },
        { "icey2_supply_ball_shield_small", math.random(1, 4) },
    }

    local sphere_emitter = Icey2Math.CustomSphereEmitter(0, 0.6, 0, PI, 0, PI * 2)

    if attacker.components.icey2_skill_shield
        and attacker.components.icey2_skill_shield:IsEnabled()
        and attacker.components.icey2_skill_shield:GetPercent() < 1 then
        for _, prefab_and_cnt in pairs(ball_prefabs) do
            for i = 1, prefab_and_cnt[2] do
                SpawnPrefab(prefab_and_cnt[1]):Setup(attacker, start_pos + Vector3(sphere_emitter()))
            end
        end
    end
end

local function OnProjectileLaunched(inst, attacker, target, proj)
    local energy_required = 5
    local hunger_required = 1

    if attacker.components.icey2_skill_shield
        and attacker.components.icey2_skill_shield:IsEnabled()
        and attacker.components.icey2_skill_shield.current >= energy_required
        and attacker.components.hunger
        and attacker.components.hunger.current >= hunger_required then
        if attacker.SoundEmitter then
            -- attacker.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_gunlance/shot2")
            attacker.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_gunlance/shot3")
        end

        attacker.components.icey2_skill_shield:DoDelta(-energy_required)
        attacker.components.icey2_skill_shield:Pause(1)

        attacker.components.hunger:DoDelta(-hunger_required, true, true)


        -- local proj = SpawnAt("fire_projectile", attacker)
        -- proj.components.projectile:Throw(inst, target, attacker)

        -- local proj = SpawnAt("icey2_pact_weapon_gunlance_projectile", attacker)
        local rotate_rad = GetRandomMinMax(-5, 5) * DEGREES
        local delta_pos = (target:GetPosition() - attacker:GetPosition()):GetNormalized()
        local x, z = delta_pos.x, delta_pos.z
        delta_pos.x = math.cos(rotate_rad) * x - math.sin(rotate_rad) * z
        delta_pos.z = math.sin(rotate_rad) * x + math.cos(rotate_rad) * z

        local proj = SpawnAt("icey2_skull_projectile", attacker)
        proj.components.complexprojectile:Launch(attacker:GetPosition() + delta_pos * 10, attacker, inst)

        local openfire_fx = SpawnAt("icey2_pact_weapon_gunlance_openfire_fx", attacker:GetPosition() + delta_pos * 0.8)
        openfire_fx.Transform:SetRotation(attacker.Transform:GetRotation())
        openfire_fx:Emit()

        -- Test duration between two shootings
        -- local t = GetTime()
        -- if inst.last_shoot_time ~= nil then
        --     print("Between shoot:", t - inst.last_shoot_time)
        -- end
        -- inst.last_shoot_time = t
    else
        if attacker.SoundEmitter then
            attacker.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_gunlance/empty")
        end

        if attacker.components.icey2_skill_shield:IsEnabled() then
            attacker.components.icey2_skill_shield:Pause(1)
        end
    end
end

local function OnFormChange(inst, old_form, new_form, on_load)
    local owner = inst.components.inventoryitem:GetGrandOwner()

    if new_form == 1 then
        inst.AnimState:PlayAnimation("idle")

        inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_pact_weapon_gunlance.xml"
        inst.components.inventoryitem:ChangeImageName("icey2_pact_weapon_gunlance")

        inst.components.weapon:SetDamage(17)
        inst.components.weapon:SetRange(0)
        inst.components.weapon:SetProjectile(nil)
        inst.components.weapon:SetOnAttack(OnAttackMelee)
        inst.components.weapon:SetOnProjectileLaunched(nil)

        inst.components.icey2_spdamage_force:SetBaseDamage(34)

        inst:RemoveTag("icey2_pact_weapon_gunlance_range")
        inst:RemoveTag("NO_ICEY2_PARRY")

        if owner then
            owner.AnimState:OverrideSymbol("swap_object", "swap_icey2_pact_weapon_gunlance",
                "swap_icey2_pact_weapon_gunlance")

            owner.AnimState:Show("ARM_carry")
            owner.AnimState:Hide("ARM_normal")


            if owner.components.combat then
                owner.components.combat:SetAttackPeriod(MELEE_PERIOD)
            end
        end
    elseif new_form == 2 then
        inst.AnimState:PlayAnimation("idle_range")

        inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_pact_weapon_gunlance_range.xml"
        inst.components.inventoryitem:ChangeImageName("icey2_pact_weapon_gunlance_range")

        inst.components.weapon:SetDamage(21.5)
        inst.components.weapon:SetRange(20, 30)
        inst.components.weapon:SetProjectile("icey2_fake_projectile")
        inst.components.weapon:SetOnAttack(nil)
        inst.components.weapon:SetOnProjectileLaunched(OnProjectileLaunched)

        inst.components.icey2_spdamage_force:SetBaseDamage(21.5)

        inst:AddTag("icey2_pact_weapon_gunlance_range")
        inst:AddTag("NO_ICEY2_PARRY")

        if owner then
            owner.AnimState:OverrideSymbol("swap_object", "swap_icey2_pact_weapon_gunlance",
                "swap_icey2_pact_weapon_gunlance_range")

            owner.AnimState:Hide("ARM_carry")
            owner.AnimState:Show("ARM_normal")

            if owner.components.combat then
                owner.components.combat:SetAttackPeriod(FRAMES)
            end
        end
    end


    if owner then
        if not on_load and owner.SoundEmitter then
            owner.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_gunlance/change_to_range")
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("icey2_pact_weapon_gunlance")
    inst.AnimState:SetBuild("icey2_pact_weapon_gunlance")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetLightOverride(0.6)

    inst:AddTag("allow_action_on_impassable")
    inst:AddTag("icey2_pact_weapon")

    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")

    inst:AddComponent("icey2_spdamage_force")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canonlygoinpocket = true

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    -- inst.components.equippable.speed

    inst:AddComponent("icey2_versatile_weapon")
    inst.components.icey2_versatile_weapon:SetNumForms(2)
    inst.components.icey2_versatile_weapon.onformchange = OnFormChange

    inst:AddComponent("icey2_supply_ball_override")

    MakeHauntableLaunch(inst)

    return inst
end

-------------------------------------------------------------------------------------------


local function Projectile_OnLaunch(inst)
    inst.start_time = GetTime()
    inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)
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

    return true
end

local function create_arrow(parent)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()



    inst:AddTag("FX")

    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false


    inst.AnimState:SetBank("lavaarena_blowdart_attacks")
    inst.AnimState:SetBuild("lavaarena_blowdart_attacks")
    inst.AnimState:PlayAnimation("attack_3", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetAddColour(0, 220 / 255, 230 / 255, 1)


    if parent then
        parent:AddChild(inst)
    end

    return inst
end

local function projectile_fn()
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

    if not TheNet:IsDedicated() then
        -- local normal_height = 1
        -- local side_height = 0.5
        -- local downside_height = 0
        -- local upside_height = 0.4

        -- down, downside, side, upside, up
        inst._arrows = {}

        for i = 1, 5 do
            local arrow = create_arrow(inst)
            arrow.entity:AddFollower()
            table.insert(inst._arrows, arrow)
        end

        inst._arrows[1].Follower:FollowSymbol(inst.GUID, "swap_object", 0, -50, 0, nil, nil, 0)
        inst._arrows[2].Follower:FollowSymbol(inst.GUID, "swap_object", 0, -25, 0, nil, nil, 1)
        inst._arrows[3].Follower:FollowSymbol(inst.GUID, "swap_object", 0, -65, 0, nil, nil, 2)
        inst._arrows[4].Follower:FollowSymbol(inst.GUID, "swap_object", 0, -45, 0, nil, nil, 3)
        inst._arrows[5].Follower:FollowSymbol(inst.GUID, "swap_object", 0, -50, 0, nil, nil, 4)

        -- inst._arrow1 = create_arrow(inst)
        -- inst._arrow1.Transform:SetPosition(0, normal_height, 0)
        -- inst._arrow1:Hide()

        -- inst._arrow2 = create_arrow(inst)
        -- inst._arrow2.Transform:SetPosition(0, downside_height, 0)
        -- inst._arrow2:Hide()

        -- inst._arrow3 = create_arrow(inst)
        -- inst._arrow3.Transform:SetPosition(0, side_height, 0)
        -- inst._arrow3:Hide()

        -- inst._arrow4 = create_arrow(inst)
        -- inst._arrow4.Transform:SetPosition(0, upside_height, 0)
        -- inst._arrow4:Hide()

        -- inst:DoPeriodicTask(0, function()
        --     local facing = inst.AnimState:GetCurrentFacing()
        --     if facing == FACING_DOWNLEFT or facing == FACING_DOWNRIGHT then
        --         inst._arrow1:Hide()
        --         inst._arrow2:Show()
        --         inst._arrow3:Hide()
        --         inst._arrow4:Hide()
        --     elseif facing == FACING_LEFT or facing == FACING_RIGHT then
        --         inst._arrow1:Hide()
        --         inst._arrow2:Hide()
        --         inst._arrow3:Show()
        --         inst._arrow4:Hide()
        --     elseif facing == FACING_UPLEFT or facing == FACING_UPRIGHT then
        --         inst._arrow1:Hide()
        --         inst._arrow2:Hide()
        --         inst._arrow3:Hide()
        --         inst._arrow4:Show()
        --     else
        --         inst._arrow1:Show()
        --         inst._arrow2:Hide()
        --         inst._arrow3:Hide()
        --         inst._arrow4:Hide()
        --     end
        -- end)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetOnLaunch(Projectile_OnLaunch)
    inst.components.complexprojectile:SetOnHit(Projectile_OnHit)
    inst.components.complexprojectile:SetHorizontalSpeed(30)
    inst.components.complexprojectile.onupdatefn = Projectile_OnUpdateFn

    return inst
end

return Prefab("icey2_pact_weapon_gunlance", fn, assets)
-- Prefab("icey2_pact_weapon_gunlance_projectile", projectile_fn, assets)
