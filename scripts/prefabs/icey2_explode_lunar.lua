local assets =
{
    Asset("ANIM", "anim/alterguardian_meteor.zip"),
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()


    inst.AnimState:SetBank("alterguardian_meteor")
    inst.AnimState:SetBuild("alterguardian_meteor")
    inst.AnimState:PlayAnimation("meteor_pre")
    inst.AnimState:SetLightOverride(1)

    local symbols =
    {
        "charged",
        "charged_moonglass_rock",
        "fx_aoe_beam",
        "fx_aoe_texture",
        "fx_beam",
        "fx_crown_break",
        "fx_dot",
        "fx_skybeam",
    }

    for _, symbol in pairs(symbols) do
        inst.AnimState:HideSymbol(symbol)
    end


    inst.AnimState:SetTime(0.95)


    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false


    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")

    inst:ListenForEvent("animover", inst.Remove)


    return inst
end

return Prefab("icey2_explode_lunar", fn, assets)
