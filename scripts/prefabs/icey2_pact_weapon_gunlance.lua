local assets       =
{
    -- Asset("ANIM", "anim/icey2_pact_weapon_gunlance.zip"),
    Asset("ANIM", "anim/swap_icey2_pact_weapon_gunlance.zip"),
    Asset("ANIM", "anim/swap_icey2_pact_weapon_gunlance_range.zip"),

    -- Asset("IMAGE", "images/inventoryimages/icey2_pact_weapon_gunlance.tex"),
    -- Asset("ATLAS", "images/inventoryimages/icey2_pact_weapon_gunlance.xml"),
}

local MELEE_PERIOD = 17 * FRAMES

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_minigun", "swap_icey2_pact_weapon_gunlance_range", "swap_minigun")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    owner.AnimState:SetSymbolLightOverride("swap_object", 0.6)
    owner.AnimState:SetSymbolLightOverride("swap_minigun", 0.6)

    if inst.components.icey2_versatile_weapon:GetCurForm() == 1 then
        owner.AnimState:OverrideSymbol("swap_object", "swap_icey2_pact_weapon_gunlance",
            "swap_icey2_pact_weapon_gunlance")

        if owner.components.combat then
            owner.components.combat:SetAttackPeriod(MELEE_PERIOD)
        end
    elseif inst.components.icey2_versatile_weapon:GetCurForm() == 2 then
        owner.AnimState:OverrideSymbol("swap_object", "swap_icey2_pact_weapon_gunlance",
            "swap_icey2_pact_weapon_gunlance_range")

        if owner.components.combat then
            owner.components.combat:SetAttackPeriod(FRAMES)
        end
    end
end

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
    if Icey2Basic.IsWearingArmor(attacker) then
        return
    end

    local start_pos = target:GetPosition()
    start_pos.y = start_pos.y + GetRandomMinMax(0.8, 2)

    local fx = SpawnAt("icey2_supply_ball_shield_spawn", start_pos)
    fx:FaceAwayFromPoint(attacker:GetPosition(), true)
    fx:SpawnChild("icey2_melee_hit_vfx")

    attacker.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_gunlance/melee_hit", nil, 0.5)

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
            attacker.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_gunlance/shot2")
        end

        attacker.components.icey2_skill_shield:DoDelta(-energy_required)
        attacker.components.icey2_skill_shield:Pause(1)

        attacker.components.hunger:DoDelta(-hunger_required, true, true)


        local proj = SpawnAt("fire_projectile", attacker)
        proj.components.projectile:Throw(inst, target, attacker)
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
        inst.components.weapon:SetDamage(17)
        inst.components.weapon:SetRange(0)
        inst.components.weapon:SetProjectile(nil)
        inst.components.weapon:SetOnAttack(OnAttackMelee)
        inst.components.weapon:SetOnProjectileLaunched(nil)

        inst.components.icey2_spdamage_force:SetBaseDamage(34)

        inst:RemoveTag("icey2_pact_weapon_gunlance_ranged")

        if owner then
            owner.AnimState:OverrideSymbol("swap_object", "swap_icey2_pact_weapon_gunlance",
                "swap_icey2_pact_weapon_gunlance")

            if owner.components.combat then
                owner.components.combat:SetAttackPeriod(MELEE_PERIOD)
            end
        end
    elseif new_form == 2 then
        inst.components.weapon:SetDamage(21.5)
        inst.components.weapon:SetRange(20, 30)
        inst.components.weapon:SetProjectile("icey2_fake_projectile")
        inst.components.weapon:SetOnAttack(nil)
        inst.components.weapon:SetOnProjectileLaunched(OnProjectileLaunched)

        inst.components.icey2_spdamage_force:SetBaseDamage(21.5)

        inst:AddTag("icey2_pact_weapon_gunlance_ranged")

        if owner then
            owner.AnimState:OverrideSymbol("swap_object", "swap_icey2_pact_weapon_gunlance",
                "swap_icey2_pact_weapon_gunlance_range")

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

    inst.AnimState:SetBank("spear")
    inst.AnimState:SetBuild("swap_spear")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetLightOverride(0.6)

    inst:AddTag("sharp")
    inst:AddTag("pointy")

    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")

    inst:AddComponent("icey2_spdamage_force")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "icey2_skill_builder_battle_focus"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_skill_builder_battle_focus.xml"
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

return Prefab("icey2_pact_weapon_gunlance", fn, assets)
