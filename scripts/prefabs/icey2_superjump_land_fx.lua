local ARROW_TEXTURE = "fx/spark.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "icey2_superjump_land_fx_colourenvelope"
local SCALE_ENVELOPE_NAME = "icey2_superjump_land_fx_scaleenvelope"

local assets =
{
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

local assets_fx2 =
{
    Asset("ANIM", "anim/player_superjump.zip"),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,   IntColour(0, 229, 232, 255) },
            { 0.5, IntColour(0, 229, 232, 255) },
            { 1,   IntColour(0, 229, 232, 0) },
        }
    )

    local arrow_max_scale = 1
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0, { arrow_max_scale * 1, arrow_max_scale * 6 } },
            { 1, { arrow_max_scale * .05, arrow_max_scale * 4 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local height_init = 6
local vel_init = 3
local moving_t = 4 * FRAMES

-- local acc = (height_init - vel_init * moving_t) / (0.5 * moving_t * moving_t)
local acc = 0.4

local MAX_LIFETIME = 1

local function emit_arrow_fn(effect, sphere_emitter, height)
    height           = height or 0

    local vx, vy, vz = 0, -vel_init, 0
    local lifetime   = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()

    local uv_offset  = math.random(0, 3) * .25


    effect:AddParticleUV(
        0,
        lifetime,            -- lifetime
        px, py + height, pz, -- position
        vx, vy, vz,          -- velocity
        uv_offset, 0         -- uv offset
    )
end

local function vfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    effect:SetRenderResources(0, ARROW_TEXTURE, ADD_SHADER)
    effect:SetRotateOnVelocity(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 32)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)
    effect:SetDragCoefficient(0, acc)

    -----------------------------------------------------


    local sphere_emitter = CreateSphereEmitter(.5)

    local num_to_emit = 1
    local height = height_init
    local rad = 0.01
    EmitterManager:AddEmitter(inst, nil, function()
        -- if height <= 2 then
        --     return
        -- end

        while num_to_emit > 1 do
            emit_arrow_fn(effect, sphere_emitter, height)
            num_to_emit = num_to_emit - 1
        end

        num_to_emit = num_to_emit + 0.7
        -- height = math.max(2, height - FRAMES * 8)
        -- rad = math.min(0.5, rad + FRAMES * 3)
        -- sphere_emitter = CreateSphereEmitter(rad)
    end)

    return inst
end

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

    inst.vfx = inst:SpawnChild("icey2_superjump_land_vfx")

    inst:DoTaskInTime(2, inst.Remove)

    return inst
end

local function fx2fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()


    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("player_superjump")
    inst.AnimState:PlayAnimation("superjump_land_fx")

    inst.AnimState:SetLightOverride(1)

    inst.AnimState:SetMultColour(0, 1, 1, 1)
    -- inst.AnimState:SetAddColour(0, 1, 1, 1)
    -- inst.AnimState:SetMultColour(0, 0.5, 1, 1)



    inst:AddTag("FX")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

return Prefab("icey2_superjump_land_vfx", vfxfn, assets),
    Prefab("icey2_superjump_land_fx", fxfn, assets),
    Prefab("icey2_superjump_land_fx2", fx2fn, assets_fx2)
