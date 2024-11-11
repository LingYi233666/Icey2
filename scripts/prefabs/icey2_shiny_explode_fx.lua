local assets =
{
    Asset("ANIM", "anim/bomb_lunarplant.zip"),
    Asset("ANIM", "anim/sleepcloud.zip"),
}


local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("bomb_lunarplant")
    inst.AnimState:SetBuild("bomb_lunarplant")
    inst.AnimState:PlayAnimation("used")

    inst.AnimState:SetSymbolBloom("light_beam")
    inst.AnimState:SetSymbolBloom("pb_energy_loop")
    inst.AnimState:SetSymbolLightOverride("light_beam", 1)
    inst.AnimState:SetSymbolLightOverride("pb_energy_loop", 1)
    -- inst.AnimState:OverrideSymbol("sleepcloud_pre", "sleepcloud", "sleepcloud_pre")
    inst.AnimState:HideSymbol("bombbreak")
    inst.AnimState:HideSymbol("splash_fx")
    inst.AnimState:HideSymbol("pb_energy_loop")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false

    return inst
end

return Prefab("icey2_shiny_explode_fx", fxfn, assets)
