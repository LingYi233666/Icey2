local assets =
{
    Asset("ANIM", "anim/icey2_pact_weapon_rapier.zip"),
    Asset("ANIM", "anim/swap_icey2_pact_weapon_rapier.zip"),

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
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("icey2_pact_weapon_rapier")
    inst.AnimState:SetBuild("icey2_pact_weapon_rapier")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("pointy")

    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)


    Icey2WeaponSkill.AddAoetargetingClient(inst, "point", nil, 12)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe_1_6"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping_1_6"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(17)

    inst:AddComponent("icey2_spdamage_force")
    inst.components.icey2_spdamage_force:SetBaseDamage(17)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "icey2_pact_weapon_rapier"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_pact_weapon_rapier.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("icey2_aoeweapon_flurry_lunge")
    inst.components.icey2_aoeweapon_flurry_lunge:SetOnHitFn(OnSpellHit)


    Icey2WeaponSkill.AddAoetargetingServer(inst, SpellFn)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("icey2_pact_weapon_rapier", fn, assets)