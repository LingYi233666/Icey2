local LIGHT_CIRCLE_TEXTURE = resolvefilepath("fx/icey2_light_circle.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME_WHITE = "icey2_slash_vfx_colourenvelope_white"
local COLOUR_ENVELOPE_NAME_BLUE = "icey2_slash_vfx_colourenvelope_blue"
local COLOUR_ENVELOPE_NAME_GRAY = "icey2_slash_vfx_colourenvelope_gray"

local SCALE_ENVELOPE_NAME_SMALL = "icey2_slash_vfx_scaleenvelope_small"
local SCALE_ENVELOPE_NAME_MID = "icey2_slash_vfx_scaleenvelope_mid"
local SCALE_ENVELOPE_NAME_BIG = "icey2_slash_vfx_scaleenvelope_big"

local assets =
{
    Asset("IMAGE", LIGHT_CIRCLE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_WHITE, {
        { 0,   IntColour(255, 255, 255, 0) },
        { 0.1, IntColour(255, 255, 255, 255) },
        { 1,   IntColour(255, 255, 255, 255) },
    })
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_BLUE, {
        { 0,   IntColour(0, 249, 255, 0) },
        { 0.1, IntColour(0, 255, 255, 255) },
        { 1,   IntColour(0, 255, 255, 255) },
    })

    local max_scale = 0.6
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_MID,
        {
            { 0,   { 0, max_scale * 0.1 } },
            { 0.1, { max_scale, max_scale * 15 } },
            { 1,   { max_scale * 0.1, max_scale * 20 } },
        }
    )

    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMALL,
        {
            { 0,   { 0, max_scale * 0.1 } },
            { 0.1, { max_scale * 0.8, max_scale * 13 } },
            { 1,   { max_scale * 0.1, max_scale * 15 } },
        }
    )

    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_BIG,
        {
            { 0,   { 0, max_scale * 0.1 } },
            { 0.1, { max_scale * 1.3, max_scale * 17 } },
            { 1,   { max_scale * 0.1, max_scale * 23 } },
        }
    )



    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME_WHITE = 0.15
local MAX_LIFETIME_BLUE = 0.15

local function emit_white_fn(effect, px, py, pz, angle)
    local lifetime = MAX_LIFETIME_WHITE * (.9 + UnitRand() * .1)

    effect:AddRotatingParticle(
        0,
        lifetime,   -- lifetime
        px, py, pz, -- position
        0, 0, 0,    -- velocity
        angle, 0    -- angle, angular_velocity
    )
end

local function emit_blue_fn(effect, px, py, pz, angle)
    local lifetime = MAX_LIFETIME_BLUE * (.9 + UnitRand() * .1)

    effect:AddRotatingParticle(
        1,
        lifetime,   -- lifetime
        px, py, pz, -- position
        0, 0, 0,    -- velocity
        angle, 0    -- angle, angular_velocity
    )
end


local function vfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    inst._height = net_float(inst.GUID, "inst._height")
    inst._height:set(1)

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    effect:SetRenderResources(0, LIGHT_CIRCLE_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetMaxNumParticles(0, 16)
    effect:SetMaxLifetime(0, MAX_LIFETIME_WHITE)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_WHITE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMALL)
    effect:SetBlendMode(0, BLENDMODE.AlphaAdditive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 2)
    effect:SetSortOffset(0, 2)
    effect:SetFollowEmitter(0, true)


    effect:SetRenderResources(1, LIGHT_CIRCLE_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(1, true)
    effect:SetMaxNumParticles(1, 16)
    effect:SetMaxLifetime(1, MAX_LIFETIME_BLUE)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_BLUE)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_MID)
    effect:SetBlendMode(1, BLENDMODE.AlphaAdditive)
    effect:EnableBloomPass(1, true)
    effect:SetSortOrder(1, 1)
    effect:SetSortOffset(1, 2)
    effect:SetFollowEmitter(1, true)


    -----------------------------------------------------

    local sphere_emitter = CreateSphereEmitter(.5)
    local blue_emitted_time = nil
    local white_emitted_time = nil


    local num_to_emit = 3

    EmitterManager:AddEmitter(inst, nil, function()
        -- if not blue_emitted_time then
        --     for i = 1, 4 do
        --         emit_blue_fn(effect, px, py, pz, angle)
        --     end
        --     blue_emitted_time = GetTime()
        --     -- elseif not white_emitted_time and GetTime() - blue_emitted_time >= FRAMES * 2 then
        -- elseif not white_emitted_time then
        --     for i = 1, 4 do
        --         emit_white_fn(effect, px, py, pz, angle)
        --     end
        --     white_emitted_time = GetTime()
        -- end
        if num_to_emit > 0 then
            -- local angle = math.random() * 360
            local angle = math.random(45, 135)

            local px, py, pz = sphere_emitter()
            py = py + inst._height:value()

            for i = 1, 4 do
                emit_blue_fn(effect, px, py, pz, angle)
                emit_white_fn(effect, px, py, pz, angle)
            end
            num_to_emit = num_to_emit - 1
        end
    end)

    return inst
end

-- local function hitfxfn()
--     local inst = CreateEntity()

--     inst.entity:AddTransform()
--     inst.entity:AddAnimState()
--     inst.entity:AddSoundEmitter()
--     inst.entity:AddNetwork()

--     inst.AnimState:SetBank("deer_ice_charge")
--     inst.AnimState:SetBuild("deer_ice_charge")
--     inst.AnimState:PlayAnimation("blast")
--     inst.AnimState:SetLightOverride(1)
--     inst.AnimState:SetFinalOffset(3)


--     inst:AddTag("FX")

--     inst.entity:SetPristine()
--     if not TheWorld.ismastersim then
--         return inst
--     end

--     inst.persists = false
--     inst.AnimState:HideSymbol("line")

--     inst:ListenForEvent("animover", inst.Remove)

--     return inst
-- end

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()


    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.vfx = inst:SpawnChild("icey2_slash_vfx")

    inst.SetHeight = function(inst, h)
        inst.vfx._height:set(h)
    end

    inst.remove_task = inst:DoTaskInTime(10 * FRAMES, inst.Remove)

    return inst
end

-- c_spawn("icey2_slash_fx"):SetHeight(0.5)
return Prefab("icey2_slash_vfx", vfxfn, assets),
    Prefab("icey2_slash_fx", fxfn, assets)
