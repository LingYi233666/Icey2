local assets =
{
    Asset("ANIM", "anim/crab_king_shine.zip"),
}

local GOOD_PARRY_THRESHOLD = 0.33

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()


    inst.AnimState:SetBank("crab_king_shine")
    inst.AnimState:SetBuild("crab_king_shine")
    inst.AnimState:PlayAnimation("shine")

    -- local t = inst.AnimState:GetCurrentAnimationLength()


    -- inst.AnimState:SetAddColour(80 / 255, 0.4, 0.4, 0)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)
    inst.AnimState:SetLightOverride(1)


    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    local t_big_shining = 0.534
    inst.AnimState:SetDeltaTimeMultiplier(t_big_shining / GOOD_PARRY_THRESHOLD)

    inst:DoTaskInTime(t_big_shining, function()
        inst.AnimState:SetDeltaTimeMultiplier(1)
    end)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("icey2_parry_shield_shining_fx", fn, assets)
