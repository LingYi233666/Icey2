local assets =
{
    Asset("ANIM", "anim/moonstorm_groundlight.zip"),
}

-- local SCALE_FACTOR = 2.5
local SCALE_FACTOR = 1.8
local anim_options = {
    { anim = "strike",  speed = 1 * SCALE_FACTOR,   disappear_time = 9 * FRAMES },
    { anim = "strike2", speed = 1.3 * SCALE_FACTOR, disappear_time = 20 * FRAMES },
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("moonstorm_groundlight")
    inst.AnimState:SetBank("moonstorm_groundlight")

    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.AnimState:SetMultColour(0, 0.5, 1, 1)
    -- inst.AnimState:SetMultColour(0, 1, 1, 1)


    -- inst.Transform:SetScale(1, 1, 1)
    -- inst.Transform:SetRotation(math.random() * 360)
    --inst.Transform:SetRotation(90)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst:AddTag("fx")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false


    local anim_option = GetRandomItem(anim_options)
    if anim_option then
        inst.AnimState:PlayAnimation(anim_option.anim)
        inst.AnimState:SetDeltaTimeMultiplier(anim_option.speed)

        -- inst:DoTaskInTime(anim_option.disappear_time / anim_option.speed, function()
        --     inst.AnimState:SetDeltaTimeMultiplier(1)
        -- end)
    end



    -- inst:DoTaskInTime(13 * FRAMES, function() checkspawn(inst) end)
    inst:ListenForEvent("animover", inst.Remove)

    -- inst.SoundEmitter:PlaySound("moonstorm/common/moonstorm/electricity")


    return inst
end

return Prefab("icey2_ground_lightning_fx", fn, assets)
