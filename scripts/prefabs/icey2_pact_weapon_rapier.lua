local assets =
{
    Asset("ANIM", "anim/icey2_pact_weapon_rapier.zip"),
    Asset("ANIM", "anim/swap_icey2_pact_weapon_rapier.zip"),

    Asset("ANIM", "anim/swap_icey2_pact_weapon_great_sword.zip"),

    Asset("IMAGE", "images/inventoryimages/icey2_pact_weapon_rapier.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_pact_weapon_rapier.xml"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_icey2_pact_weapon_rapier", "swap_icey2_pact_weapon_rapier")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    owner.AnimState:SetSymbolLightOverride("swap_object", 0.6)
    owner.AnimState:SetSymbolLightOverride("fx_lunge_streak", 0.6)
    owner.AnimState:SetSymbolAddColour("fx_lunge_streak", 0 / 255, 100 / 255, 240 / 255, 1)
    -- owner.AnimState:SetSymbolMultColour("fx_lunge_streak", 70 / 255, 240 / 255, 235 / 255, 1)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    owner.AnimState:SetSymbolLightOverride("swap_object", 0)
    owner.AnimState:SetSymbolLightOverride("fx_lunge_streak", 0)
    owner.AnimState:SetSymbolAddColour("fx_lunge_streak", 0, 0, 0, 0)
    -- owner.AnimState:SetSymbolMultColour("fx_lunge_streak", 1, 1, 1, 1)
end

local function OnSpellHit(inst, doer, target)
    if not inst.components.icey2_aoeweapon_flurry_lunge.is_final_blow then
        local h = target.Physics and target.Physics:GetHeight() or 0.5
        local fx = SpawnAt("icey2_slash_fx", target)
        fx:SetHeight(h)
    end
end

local function SpellFn(inst, doer, pos)
    doer:PushEvent("icey2_aoeweapon_flurry_lunge_trigger", {
        weapon = inst,
        target_pos = pos,
    })

    if Icey2Basic.IsWearingArmor(doer) then
        inst.components.rechargeable:Discharge(15)
    else
        local level = inst.components.icey2_upgradable:GetLevel()
        inst.components.rechargeable:Discharge(math.max(0.1, 10 - level * 1.5))
    end
end

local function ApplyLevelFn(inst, new_level, old_level)
    if new_level >= 1 then
        inst.components.named:SetName(STRINGS.NAMES.ICEY2_PACT_WEAPON_RAPIER .. "+" .. tostring(new_level))
    else
        inst.components.named:SetName(STRINGS.NAMES.ICEY2_PACT_WEAPON_RAPIER)
    end

    inst.components.icey2_spdamage_force:SetBaseDamage(1 + new_level * 5)
    if new_level >= 3 then
        inst.components.planardamage:SetBaseDamage(1)
    else
        inst.components.planardamage:SetBaseDamage(0)
    end
end

local SKILL_TAB = {
    upgrade_pact_weapon_rapier_1 = 1,
    upgrade_pact_weapon_rapier_2 = 2,
    upgrade_pact_weapon_rapier_3 = 3,
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("icey2_pact_weapon_rapier")
    inst.AnimState:SetBuild("icey2_pact_weapon_rapier")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetLightOverride(0.6)

    inst:AddTag("icey2_pact_weapon")

    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)

    Icey2WeaponSkill.AddAoetargetingClient(inst, "point", nil, 12)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe_1_6"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping_1_6"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.hunger_burn_rate = 0.01

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(34)

    inst:AddComponent("icey2_spdamage_force")

    inst:AddComponent("planardamage")

    inst:AddComponent("inspectable")

    inst:AddComponent("named")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "icey2_pact_weapon_rapier"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_pact_weapon_rapier.xml"
    inst.components.inventoryitem.canonlygoinpocket = true

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("icey2_aoeweapon_flurry_lunge")
    inst.components.icey2_aoeweapon_flurry_lunge:SetOnHitFn(OnSpellHit)

    inst:AddComponent("icey2_upgradable")
    inst.components.icey2_upgradable:SetApplyFn(ApplyLevelFn)
    inst.components.icey2_upgradable:SetSkillTab(SKILL_TAB)
    inst.components.icey2_upgradable:SetLevel(0)

    Icey2WeaponSkill.AddAoetargetingServer(inst, SpellFn)

    MakeHauntableLaunch(inst)


    return inst
end

local function greatsword_fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("icey2_pact_weapon_rapier")
    inst.AnimState:SetBuild("icey2_pact_weapon_rapier")
    inst.AnimState:PlayAnimation("greatsword", true)

    inst.AnimState:OverrideSymbol("swap_great_sword", "swap_icey2_pact_weapon_great_sword",
        "swap_icey2_pact_weapon_great_sword")

    inst:AddTag("FX")

    inst.AnimState:SetLightOverride(0.6)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function emit_fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("halloween_embers_cold")
    inst.AnimState:SetBuild("halloween_embers_cold")
    -- inst.AnimState:PlayAnimation("puff_" .. math.random(1, 3))
    inst.AnimState:PlayAnimation("puff_1")

    inst:AddTag("FX")

    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetDeltaTimeMultiplier(1.5)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("icey2_pact_weapon_rapier", fn, assets),
    Prefab("icey2_pact_weapon_rapier_greatsword_fx", greatsword_fxfn, assets),
    Prefab("icey2_pact_weapon_rapier_emit_fx", emit_fxfn, assets)
