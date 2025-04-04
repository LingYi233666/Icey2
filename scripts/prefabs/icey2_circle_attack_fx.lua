local assets =
{
    Asset("ANIM", "anim/icey2_circle_attack_fx.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()


    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("icey2_circle_attack_fx")
    inst.AnimState:SetBuild("icey2_circle_attack_fx")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetScale(1.8, 1.8, 1.8)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(-1)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)

    inst.AnimState:SetAddColour(0, 1, 1, 1)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("icey2_circle_attack_fx", fn, assets)
