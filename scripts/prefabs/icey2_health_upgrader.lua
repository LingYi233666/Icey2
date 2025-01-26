local assets =
{
    Asset("ANIM", "anim/icey2_health_upgrader.zip"),

    Asset("IMAGE", "images/inventoryimages/icey2_health_upgrader.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_health_upgrader.xml"),
}

local function OnEat(inst, eater)
    if eater.components.icey2_status_bonus then
        local ceil_health = 150
        local add_health = math.min(ceil_health - eater.components.health.maxhealth, 3)

        if add_health > 0 then
            eater.components.icey2_status_bonus:AddBonus("health", add_health)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("icey2_health_upgrader")
    inst.AnimState:SetBuild("icey2_health_upgrader")
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
    inst.components.inventoryitem.imagename = "icey2_health_upgrader"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_health_upgrader.xml"

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.GEARS
    inst.components.edible.healthvalue = TUNING.HEALING_HUGE
    inst.components.edible.hungervalue = TUNING.CALORIES_HUGE
    inst.components.edible.sanityvalue = TUNING.SANITY_HUGE
    inst.components.edible:SetOnEatenFn(OnEat)


    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("icey2_health_upgrader", fn, assets)
