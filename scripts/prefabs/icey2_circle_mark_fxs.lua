local assets = {
    Asset("ANIM", "anim/deerclops_mutated_actions.zip"),
    Asset("ANIM", "anim/deerclops_mutated.zip"),
    Asset("ANIM", "anim/deer_ice_circle.zip"),
}

local function ping_CreateDisc(multcolour, addcolour)
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    --[[Non-networked entity]]
    --inst.entity:SetCanSleep(false) --use parent sleep
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("deerclops")
    inst.AnimState:SetBuild("deerclops_mutated")
    inst.AnimState:PlayAnimation("target_fx_ring")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)

    inst.AnimState:SetSortOrder(3)

    if multcolour then
        inst.AnimState:SetMultColour(unpack(multcolour))
    end

    if addcolour then
        inst.AnimState:SetAddColour(unpack(addcolour))
    end

    inst.AnimState:SetLightOverride(1)

    return inst
end

local function MakeCircle(name, multcolour, addcolour, radius)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")

        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
        inst.AnimState:SetSortOrder(3)
        inst.AnimState:SetFinalOffset(1)

        inst.AnimState:SetBank("deerclops")
        inst.AnimState:SetBuild("deerclops_mutated")
        inst.AnimState:PlayAnimation("target_fx_pre")
        inst.AnimState:PushAnimation("target_fx", true)

        if multcolour then
            inst.AnimState:SetMultColour(unpack(multcolour))
        end

        if addcolour then
            inst.AnimState:SetAddColour(unpack(addcolour))
        end

        inst.AnimState:SetLightOverride(1)

        inst._remove_dist_event = net_event(inst.GUID, "inst._remove_dist_event")

        --Dedicated server does not need to spawn the local fx
        if not TheNet:IsDedicated() then
            inst.disc = ping_CreateDisc(multcolour, addcolour)
            inst.disc.entity:SetParent(inst.entity)

            inst:ListenForEvent("inst._remove_dist_event", function()
                if inst.disc and inst.disc:IsValid() then
                    inst.disc:Remove()
                end
            end)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.persists = false

        inst.ApplyRadius = function(inst, r)
            local ICE_LANCE_RADIUS = 5.5
            local s = r / ICE_LANCE_RADIUS

            inst.Transform:SetScale(s, s, s)
        end

        inst.KillFX = function(inst)
            inst._remove_dist_event:push()
            inst.AnimState:PlayAnimation("target_fx_pst")
            inst:ListenForEvent("animover", inst.Remove)
        end

        inst:ApplyRadius(radius)

        return inst
    end

    return Prefab(name, fn, assets)
end

local color_presets = {
    yellow = { multcolour = { 1, 1, 0, 1 }, addcolor = { 1, 1, 0, 1 } },
    red = { multcolour = { 1, 0, 0, 1 }, addcolor = { 1, 0, 0, 1 } },
    blue = { multcolour = { 0, 0, 1, 1 }, addcolor = { 0, 0, 1, 1 } },
    lightblue = { multcolour = { 0, 1, 1, 1 }, addcolor = { 0, 1, 1, 1 } },
    iceyblue = { multcolour = { 96 / 255, 249 / 255, 255 / 255, 0.5 }, addcolor = { 96 / 255, 249 / 255, 255 / 255, 1 } },
}

local bundle = {}
for color, data in pairs(color_presets) do
    for radius = 1, 15 do
        table.insert(bundle,
            MakeCircle("icey2_circle_mark_" .. color .. "_" .. tostring(radius), data.multcolour, data.addcolor, radius))
    end
end

return unpack(bundle)
