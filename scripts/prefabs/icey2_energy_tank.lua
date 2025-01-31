local assets =
{
    Asset("ANIM", "anim/icey2_energy_tank.zip"),

    Asset("IMAGE", "images/inventoryimages/icey2_energy_tank.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_energy_tank.xml"),
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("icey2_energy_tank")
    inst.AnimState:SetBuild("icey2_energy_tank")
    inst.AnimState:PlayAnimation("idle")


    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)

    -- local s = 1
    -- inst.AnimState:SetScale(s, s, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "icey2_energy_tank"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_energy_tank.xml"

    inst:AddComponent("icey2_shield_upgrader")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("icey2_energy_tank", fn, assets)
