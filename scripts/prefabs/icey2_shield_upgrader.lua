local assets =
{
    Asset("ANIM", "anim/icey2_shield_upgrader.zip"),

    Asset("IMAGE", "images/inventoryimages/icey2_shield_upgrader.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_shield_upgrader.xml"),
}

local function OnHeal(inst, target, doer)
    if target.components.icey2_skill_shield then
        local ceil_shield = 250
        local add_shield = math.min(ceil_shield - target.components.icey2_skill_shield.max, 10)


        if add_shield > 0 then
            target.components.icey2_skill_shield.max = target.components.icey2_skill_shield.max + add_shield
        end


        local ceil_absorb = 150
        local add_absorb = math.min(ceil_absorb - target.components.icey2_skill_shield.max_damage_absorb, 10)

        if add_absorb > 0 then
            target.components.icey2_skill_shield.max_damage_absorb = target.components.icey2_skill_shield
                .max_damage_absorb + add_absorb
        end

        target.components.icey2_skill_shield:SetPercent(1)


        SendModRPCToClient(CLIENT_MOD_RPC["icey2_rpc"]["push_shield_charge_anim"], target.userid)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("icey2_shield_upgrader")
    inst.AnimState:SetBuild("icey2_shield_upgrader")
    inst.AnimState:PlayAnimation("idle")


    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)

    local s = 1.5
    inst.AnimState:SetScale(s, s, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "icey2_shield_upgrader"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_shield_upgrader.xml"

    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(0)
    inst.components.healer:SetOnHealFn(OnHeal)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("icey2_shield_upgrader", fn, assets)
