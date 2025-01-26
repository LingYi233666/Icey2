local assets = {
    Asset("ANIM", "anim/icey2_dodge_fx.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("icey2_dodge_fx")
    inst.AnimState:SetBuild("icey2_dodge_fx")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLightOverride(1)
    -- inst.AnimState:SetFinalOffset(3)

    -- local s = 1
    -- inst.Transform:SetScale(s, s, s)

    inst.AnimState:SetDeltaTimeMultiplier(4)


    inst:AddTag("FX")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false


    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("icey2_dodge_fx", fn, assets)
