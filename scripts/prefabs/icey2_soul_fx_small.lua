local assets =
{
    Asset("ANIM", "anim/icey2_soul_fx_small.zip"),
}

local function FadeIn(inst, duration)
    if inst.fade_task then
        inst.fade_task:Cancel()
    end

    local speed = 1 / duration

    local r, g, b, alpha = inst.AnimState:GetMultColour()

    inst.AnimState:SetMultColour(r, g, b, 0)

    inst.fade_task = inst:DoPeriodicTask(0, function()
        r, g, b, alpha = inst.AnimState:GetMultColour()
        alpha = math.min(1, alpha + speed * FRAMES)

        inst.AnimState:SetMultColour(r, g, b, alpha)

        if alpha >= 1 then
            inst.fade_task:Cancel()
            inst.fade_task = nil
        end
    end)
end

local function FadeOut(inst, duration)
    if inst.fade_task then
        inst.fade_task:Cancel()
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

local function FlyUp(inst, init_speed, acc)
    inst.speed = init_speed
    inst.Physics:SetVel(0, inst.speed, 0)

    inst:DoPeriodicTask(0, function()
        inst.speed = math.max(0, inst.speed + acc * FRAMES)
        inst.Physics:SetVel(0, inst.speed, 0)
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

    inst.AnimState:SetBank("icey2_soul_fx_small")
    inst.AnimState:SetBuild("icey2_soul_fx_small")
    inst.AnimState:PlayAnimation("idle")

    -- inst.AnimState:SetAddColour(180 / 255, 23 / 255, 23 / 255, 1)
    inst.AnimState:SetMultColour(186 / 255, 0 / 255, 0 / 255, 1)
    inst.AnimState:SetDeltaTimeMultiplier(1.5)
    inst.AnimState:SetLightOverride(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.FadeIn = FadeIn
    inst.FadeOut = FadeOut
    inst.FlyUp = FlyUp


    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false

    return inst
end

return Prefab("icey2_soul_fx_small", fxfn, assets)
