local assets =
{
    Asset("ANIM", "anim/lavaarena_heal_projectile.zip"),
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()


    inst.AnimState:SetBank("lavaarena_heal_projectile")
    inst.AnimState:SetBuild("lavaarena_heal_projectile")
    inst.AnimState:PlayAnimation("hit")

    inst.AnimState:SetAddColour(80 / 255, 0.4, 0.4, 0)

    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:SetLightOverride(1)


    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("icey2_leaf_hitfx", fn, assets)
