local assets =
{
    Asset("ANIM", "anim/icey2_dodge_charge_chip.zip"),

    Asset("IMAGE", "images/inventoryimages/icey2_dodge_charge_chip_1.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_dodge_charge_chip_1.xml"),

    Asset("IMAGE", "images/inventoryimages/icey2_dodge_charge_chip_2.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_dodge_charge_chip_2.xml"),

    Asset("IMAGE", "images/inventoryimages/icey2_dodge_charge_chip_3.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_dodge_charge_chip_3.xml"),

    Asset("IMAGE", "images/inventoryimages/icey2_dodge_charge_chip_4.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_dodge_charge_chip_4.xml"),
}

local function common_fn(suit_value)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("icey2_dodge_charge_chip")
    inst.AnimState:SetBuild("icey2_dodge_charge_chip")
    inst.AnimState:PlayAnimation("idle_" .. suit_value)


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
    inst.components.inventoryitem.imagename = "icey2_dodge_charge_chip_" .. suit_value
    inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_dodge_charge_chip_" .. suit_value .. ".xml"

    inst:AddComponent("icey2_dodge_charge_upgrader")
    inst.components.icey2_dodge_charge_upgrader.suit_value = suit_value

    MakeHauntableLaunch(inst)

    return inst
end


local rets = {}

for i = 1, 4 do
    local function fn()
        return common_fn(i)
    end
    table.insert(rets, Prefab("icey2_dodge_charge_chip_" .. i, fn, assets))
end

return unpack(rets)
