local assets =
{
    Asset("ANIM", "anim/moon_geyser.zip"),
}

local function CreateClientFX()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()


    inst.AnimState:SetBank("moon_altar_geyser")
    inst.AnimState:SetBuild("moon_geyser")
    inst.AnimState:PlayAnimation("moonpulse")
    inst.AnimState:SetLightOverride(1)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.persists = false

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function PlayFX(doer, offset)
    local fx = CreateClientFX()

    local x, y, z = doer.Transform:GetWorldPosition()
    if offset then
        x = x + offset.x
        y = y + offset.y
        z = z + offset.z
    end
    fx.Transform:SetPosition(x, y, z)
end

local offset_presets = {
    FACING_DOWN = function()

    end
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst._emit = net_event(inst.GUID, "inst._emit")

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("inst._emit", function()
            local parent = inst.entity:GetParent()
            if not parent then
                return
            end


            -- PlayFX(parent,FunctionOrValue(func_or_val,...))
        end)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false


    inst:DoTaskInTime(5 * FRAMES, inst.Remove)

    return inst
end

return Prefab("icey2_moonpluse_fx", fn, assets)
