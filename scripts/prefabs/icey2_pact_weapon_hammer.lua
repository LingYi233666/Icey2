local SourceModifierList = require("util/sourcemodifierlist")

local assets =
{
    Asset("ANIM", "anim/icey2_pact_weapon_hammer.zip"),
    Asset("ANIM", "anim/swap_icey2_pact_weapon_hammer.zip"),

    Asset("IMAGE", "images/inventoryimages/icey2_pact_weapon_hammer.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_pact_weapon_hammer.xml"),
}


local function OnAttack(inst, doer, target)
    if inst.in_area_attack:Get() then
        return
    end

    if doer.components.combat then
        inst.in_area_attack:SetModifier(inst, true, "normal_attack")

        local multi = 0.3
        local x, y, z = target.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 1.5, { "_combat" })


        inst.components.icey2_spdamage_force:AddMultiplier(inst, multi, "area_attack")
        if doer.components.icey2_skill_battle_focus then
            doer.components.icey2_skill_battle_focus.increasemultipliers:SetModifier(inst, 0, "area_attack")
        end

        for _, v in pairs(ents) do
            if v ~= target
                and v ~= doer
                and doer.components.combat:CanTarget(v)
                and not doer.components.combat:IsAlly(v) then
                doer.components.combat:DoAttack(v, inst, nil, nil, multi, 99999)
            end
        end

        inst.components.icey2_spdamage_force:RemoveMultiplier(inst, "area_attack")
        if doer.components.icey2_skill_battle_focus then
            doer.components.icey2_skill_battle_focus.increasemultipliers:RemoveModifier(inst, "area_attack")
        end

        inst.in_area_attack:RemoveModifier(inst, "normal_attack")
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_icey2_pact_weapon_hammer", "hammer")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    owner.AnimState:SetSymbolLightOverride("swap_object", 0.6)

    owner.components.combat:SetAttackPeriod(23 * FRAMES)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    owner.AnimState:SetSymbolLightOverride("swap_object", 0)

    -- inst.components.icey2_aoeweapon_kingkong:Stop()

    owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
end

-- local function OnSpellHit(inst, doer, target)
--     if not inst.components.icey2_aoeweapon_flurry_lunge.is_final_blow then
--         local h = target.Physics and target.Physics:GetHeight() or 0.5
--         local fx = SpawnAt("icey2_slash_fx", target)
--         fx:SetHeight(h)
--     end
-- end

local function StartFn(inst, attacker, pos)
    inst.in_area_attack:SetModifier(inst, true, "ground_slam")
end

local function StopFn(inst, attacker)
    inst.in_area_attack:RemoveModifier(inst, "ground_slam")
end

local function SpellFn(inst, doer, pos)
    doer:PushEvent("icey2_ground_slam", { weapon = inst, target_pos = pos })

    -- if Icey2Basic.IsWearingArmor(doer) then
    --     inst.components.rechargeable:Discharge(15)
    -- else
    --     inst.components.rechargeable:Discharge(5)
    -- end

    inst.components.rechargeable:Discharge(4)
end

local function ApplyLevelFn(inst, new_level, old_level)
    if new_level >= 1 then
        inst.components.named:SetName(STRINGS.NAMES.ICEY2_PACT_WEAPON_HAMMER .. "+" .. tostring(new_level))
    else
        inst.components.named:SetName(STRINGS.NAMES.ICEY2_PACT_WEAPON_HAMMER)
    end

    -- inst.components.icey2_spdamage_force:SetBaseDamage(1 + new_level * 10)
    inst.components.icey2_spdamage_force:SetBaseDamage(1 + new_level * 16)
    if new_level >= 3 then
        inst.components.planardamage:SetBaseDamage(1)
    else
        inst.components.planardamage:SetBaseDamage(0)
    end
end

local SKILL_TAB = {
    upgrade_pact_weapon_hammer_1 = 1,
    upgrade_pact_weapon_hammer_2 = 2,
    upgrade_pact_weapon_hammer_3 = 3,
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("icey2_pact_weapon_hammer")
    inst.AnimState:SetBuild("icey2_pact_weapon_hammer")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetLightOverride(0.6)

    inst:AddTag("icey2_pact_weapon")
    -- inst:AddTag("hide_percentage")
    -- inst:AddTag("ignore_icey2_unarmoured_defence_limit")
    -- inst:AddTag("heavyarmor")
    -- inst:AddTag("icey2_parry_anim_attacked")

    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)

    Icey2WeaponSkill.AddAoetargetingClient(inst, "point", nil, 4)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoesmall"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoesmallping"
    -- inst.components.aoetargeting:SetShouldRepeatCastFn(function()
    --     return true
    -- end)


    -- inst.fxcolour = { 96 / 255, 249 / 255, 255 / 255 }
    -- inst.castsound = "dontstarve/common/lava_arena/spell/meteor"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.hunger_burn_rate = 0.6
    inst.in_area_attack = SourceModifierList(inst, false, SourceModifierList.boolean)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(51)
    inst.components.weapon:SetOnAttack(OnAttack)

    inst:AddComponent("icey2_spdamage_force")

    inst:AddComponent("planardamage")

    inst:AddComponent("inspectable")

    inst:AddComponent("named")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "icey2_pact_weapon_hammer"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_pact_weapon_hammer.xml"
    inst.components.inventoryitem.canonlygoinpocket = true

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    -- inst:AddComponent("armor")
    -- inst.components.armor:InitIndestructible(0.25)

    -- inst:AddComponent("planardefense")
    -- inst.components.planardefense:SetBaseDefense(10)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.HAMMER, 3)

    inst:AddComponent("icey2_upgradable")
    inst.components.icey2_upgradable:SetApplyFn(ApplyLevelFn)
    inst.components.icey2_upgradable:SetSkillTab(SKILL_TAB)
    inst.components.icey2_upgradable:SetLevel(0)

    inst:AddComponent("icey2_aoeweapon_ground_slam")
    inst.components.icey2_aoeweapon_ground_slam.startfn = StartFn
    inst.components.icey2_aoeweapon_ground_slam.stopfn = StopFn


    Icey2WeaponSkill.AddAoetargetingServer(inst, SpellFn)

    MakeHauntableLaunch(inst)


    return inst
end

return Prefab("icey2_pact_weapon_hammer", fn, assets)
