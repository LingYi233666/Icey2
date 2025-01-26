local assets =
{
    Asset("ANIM", "anim/icey2_skull_fx.zip"),
}

local function FadeOut(inst, duration)
    if duration == nil then
        duration = 1
    end

    local _, _, _, alpha = inst.AnimState:GetMultColour()
    local speed = alpha / duration

    inst:DoPeriodicTask(0, function()
        local r, g, b, alpha = inst.AnimState:GetMultColour()
        alpha = math.max(0, alpha - speed * FRAMES)

        inst.AnimState:SetMultColour(r, g, b, alpha)
        if alpha <= 0 then
            inst:Remove()
        end
    end)
end

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    MakeProjectilePhysics(inst)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("icey2_skull_fx")
    inst.AnimState:SetBuild("icey2_skull_fx")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetMultColour(186 / 255, 0 / 255, 0 / 255, 1)
    inst.AnimState:SetDeltaTimeMultiplier(1.8)
    inst.AnimState:SetLightOverride(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.FadeOut = FadeOut


    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false

    return inst
end

return Prefab("icey2_skull_fx", fxfn, assets)
