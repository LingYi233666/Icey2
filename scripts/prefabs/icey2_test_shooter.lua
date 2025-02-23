local assets =
{
    Asset("ANIM", "anim/trusty_shooter.zip"),
    Asset("ANIM", "anim/swap_trusty_shooter.zip"),
}

local function GetDamage(inst, attacker, target)
    if target.components.freezable and target.components.freezable:IsFrozen() then
        return 0
    end

    return 0.1
end

local function OnAttack(inst, attacker, target)
    if target:IsValid() and target.components.freezable ~= nil then
        target.components.freezable:AddColdness(0.3)
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_trusty_shooter", "swap_trusty_shooter")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    owner.components.combat:SetAttackPeriod(FRAMES)
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("trusty_shooter")
    inst.AnimState:SetBuild("trusty_shooter")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(GetDamage)
    inst.components.weapon:SetRange(20)
    inst.components.weapon:SetProjectile("icey2_blue_arrow_projectile")
    inst.components.weapon:SetOnAttack(OnAttack)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "icey2_skill_builder_battle_focus"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_skill_builder_battle_focus.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("icey2_test_shooter", fn, assets)
