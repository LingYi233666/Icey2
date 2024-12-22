local assets =
{
    Asset("ANIM", "anim/icey1_bluerose.zip"),
    Asset("ANIM", "anim/swap_icey1_bluerose.zip"),

    Asset("ANIM", "anim/lavaarena_hammer_attack_fx.zip"),

    Asset("IMAGE", "images/inventoryimages/icey1_bluerose.tex"),
    Asset("ATLAS", "images/inventoryimages/icey1_bluerose.xml"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_icey1_bluerose", "swap_icey_bluerose")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    inst.light = owner:SpawnChild("icey1_bluerose_light")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    if inst.light and inst.light:IsValid() then
        inst.light:Remove()
    end
    inst.light = nil
end

local function OnLeap(inst, doer, startingpos, targetpos)
    SpawnAt("icey1_bluerose_crackle", targetpos)
    SpawnAt("icey1_bluerose_cracklebase", targetpos)
    SpawnAt("icey1_bluerose_cracklehit", targetpos)
    SpawnAt("electricchargedfx", targetpos)


    doer.SoundEmitter:PlaySound("dontstarve/common/destroy_smoke")
    doer.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/hammer")
    doer.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/electric")
end

local function SpellFn(inst, doer, pos)
    doer:PushEvent("combat_leap", {
        weapon = inst,
        targetpos = pos,
        skipflash = true,
    })

    -- inst.components.rechargeable:Discharge(5)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("icey1_bluerose")
    inst.AnimState:SetBuild("icey1_bluerose")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)


    Icey2WeaponSkill.AddAoetargetingClient(inst, "point", nil, 12)
    -- inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe_1_6"
    -- inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping_1_6"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(35)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "icey1_bluerose"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/icey1_bluerose.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("aoeweapon_leap")
    inst.components.aoeweapon_leap:SetDamage(45)
    inst.components.aoeweapon_leap:SetAOERadius(5)
    inst.components.aoeweapon_leap:SetWorkActions(nil)
    inst.components.aoeweapon_leap:SetOnLeaptFn(OnLeap)

    Icey2WeaponSkill.AddAoetargetingServer(inst, SpellFn)

    MakeHauntableLaunch(inst)

    return inst
end


local function lightfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Light:SetIntensity(0.7)
    inst.Light:SetRadius(1.25)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetColour(0 / 255, 255 / 255, 255 / 255)
    inst.Light:Enable(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false


    return inst
end

local function cracklefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_hammer_attack_fx")
    inst.AnimState:SetBuild("lavaarena_hammer_attack_fx")
    inst.AnimState:PlayAnimation("crackle_hit")

    inst.AnimState:SetAddColour(0 / 255, 138 / 255, 255 / 255, 1)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetLightOverride(1)


    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function cracklebasefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_hammer_attack_fx")
    inst.AnimState:SetBuild("lavaarena_hammer_attack_fx")
    inst.AnimState:PlayAnimation("crackle_projection")

    inst.AnimState:SetAddColour(0 / 255, 138 / 255, 255 / 255, 1)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.AnimState:SetScale(1.5, 1.5)
    inst.AnimState:SetLightOverride(1)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)

    inst.persists = false

    return inst
end

local function cracklehitfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_hammer_attack_fx")
    inst.AnimState:SetBuild("lavaarena_hammer_attack_fx")
    inst.AnimState:PlayAnimation("crackle_loop")

    inst.AnimState:SetAddColour(0 / 255, 138 / 255, 255 / 255, 1)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetScale(1.5, 1.5)
    inst.AnimState:SetLightOverride(1)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("icey1_bluerose", fn, assets),
    Prefab("icey1_bluerose_light", lightfn, assets),
    Prefab("icey1_bluerose_crackle", cracklefn, assets),
    Prefab("icey1_bluerose_cracklebase", cracklebasefn, assets),
    Prefab("icey1_bluerose_cracklehit", cracklehitfn, assets)
