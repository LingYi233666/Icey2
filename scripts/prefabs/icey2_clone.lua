local assets = {}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 75, .5)
    RemovePhysicsColliders(inst)

    inst.Transform:SetFourFaced(inst)

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("icey2")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")

    inst.AnimState:SetMultColour(0, 0, 0, .5)
    inst.AnimState:UsePointFiltering(true)

    inst.AnimState:AddOverrideBuild("player_actions_roll")
    inst.AnimState:AddOverrideBuild("player_lunge")
    inst.AnimState:AddOverrideBuild("player_attack_leap")
    inst.AnimState:AddOverrideBuild("player_superjump")
    inst.AnimState:AddOverrideBuild("player_multithrust")
    inst.AnimState:AddOverrideBuild("player_parryblock")


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("skinner")
    inst.components.skinner:SetupNonPlayerData()

    inst.Copy = function(inst, owner)
        inst.owner = owner
        inst.components.skinner:CopySkinsFromPlayer(owner)
    end

    return inst
end


return Prefab("icey2_clone", fn, assets)
