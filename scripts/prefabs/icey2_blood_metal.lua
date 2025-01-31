local assets =
{
    Asset("ANIM", "anim/icey2_blood_metal.zip"),

    Asset("IMAGE", "images/inventoryimages/icey2_blood_metal.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_blood_metal.xml"),
}

local function OnEat(inst, eater)
    if eater.components.icey2_status_bonus then
        local ceil_health = 150
        local add_health = math.min(ceil_health - eater.components.health.maxhealth, 2)

        if add_health > 0 then
            eater.components.icey2_status_bonus:AddBonus("health", add_health)
        end
    end

    if eater.prefab ~= "wx78" then
        if eater.SoundEmitter then
            eater.SoundEmitter:PlaySound("icey2_sfx/prefabs/blood_metal/explode")
        end

        SpawnAt("icey2_fire_explode_fx", eater, nil, Vector3(0, 1, 0))

        if eater.components.sanity then
            eater.components.sanity:DoDelta(-TUNING.SANITY_LARGE)
        end

        if not IsEntityDeadOrGhost(eater, true) and eater.components.combat then
            local damage = TUNING.HEALING_MED
            eater.components.health:DoDelta(-damage, nil, nil, nil, inst, true)
            eater:PushEvent("attacked", { attacker = inst, damage = damage })
        end
    else
        if eater.components.sanity then
            eater.components.sanity:DoDelta(TUNING.SANITY_HUGE)
        end

        if eater.components.health then
            eater.components.health:DoDelta(TUNING.HEALING_HUGE)
        end
    end
end

local function common_fn(anim, scale)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("icey2_blood_metal")
    inst.AnimState:SetBuild("icey2_blood_metal")
    inst.AnimState:PlayAnimation(anim)

    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)

    if scale then
        inst.AnimState:SetScale(scale, scale, 1)
    end

    inst:AddTag("blood_metal")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "icey2_blood_metal"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_blood_metal.xml"

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.GEARS
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.sanityvalue = 0
    inst.components.edible:SetOnEatenFn(OnEat)


    MakeHauntableLaunch(inst)

    return inst
end

local function fn_wx78()
    local inst = common_fn("idle", 1.5)

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function fn_icey()
    local inst = common_fn()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

return Prefab("icey2_blood_metal", fn_wx78, assets)
