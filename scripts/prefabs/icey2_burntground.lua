local assets =
{
    Asset("ANIM", "anim/burntground.zip"),
}



local function FadeOut(inst, duration, delay)
    duration = duration or 5

    if delay then
        inst:DoTaskInTime(delay, function()
            FadeOut(inst, duration)
        end)
        return
    end

    local _, _, _, a = inst.AnimState:GetMultColour()
    local speed = a / duration

    inst:DoPeriodicTask(0, function()
        local r, g, b, a = inst.AnimState:GetMultColour()
        a = math.max(0, a - FRAMES * speed)

        inst.AnimState:SetMultColour(r, g, b, a)
        if a <= 0 then
            inst:Remove()
        end
    end)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("burntground")
    inst.AnimState:SetBank("burntground")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_GROUND)
    inst.AnimState:SetSortOrder(3)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")


    inst:SetPrefabName("burntground")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false


    inst.FadeOut = FadeOut


    inst.Transform:SetRotation(math.random() * 360)


    return inst
end

return Prefab("icey2_burntground", fn, assets)
