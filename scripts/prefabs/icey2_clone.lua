local assets = {
    Asset("ANIM", "anim/icey2.zip"),
}


local function CommonFn()
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

    -- inst.AnimState:SetMultColour(0, 0, 0, .5)
    -- inst.AnimState:SetAddColour(0, 0, 0.8, 1)
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

local function NormalCloneFn()
    local inst = CommonFn()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function DodgeCounterBackFn()
    local inst = CommonFn()

    inst.AnimState:SetAddColour(0, 0, 0.8, 1)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SetSuitablePosition = function(inst, target)
        local radius = inst:GetPhysicsRadius(0.5)
        local offset = Vector3FromTheta(math.random() * PI2, radius)
        local x, y, z = (target:GetPosition() + offset):Get()
        inst.Transform:SetPosition(x, y, z)
    end

    inst.CounterBack         = function(inst, owner, target, dmg, spdmg)
        inst:Copy(owner)

        inst.Transform:SetEightFaced()
        inst.AnimState:PlayAnimation("atk_leap")

        inst:ForceFacePoint(target:GetPosition())

        inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        -- inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")

        inst:DoTaskInTime(13 * FRAMES, function()
            if owner and owner:IsValid() then
                target.components.combat:GetAttacked(owner, dmg, nil, nil, spdmg)
            end
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end)

        inst:DoTaskInTime(20 * FRAMES, function()
            inst:Remove()
        end)
    end
end

return Prefab("icey2_clone", NormalCloneFn, assets),
    Prefab("icey2_clone_dodge_counter_back", DodgeCounterBackFn, assets)
