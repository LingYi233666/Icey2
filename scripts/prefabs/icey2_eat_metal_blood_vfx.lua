local SPARKLE_TEXTURE = resolvefilepath("fx/icey2_elec_spark.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME = "icey2_eat_metal_blood_vfx_colourenvelope"
local SCALE_ENVELOPE_NAME = "icey2_eat_metal_blood_vfx_scaleenvelope"

local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, {
        { 0,   IntColour(122, 30, 30, 0) },
        { 0.3, IntColour(185, 0, 0, 255) },
        { 1,   IntColour(122, 30, 30, 0) },
    })

    local sparkle_max_scale = .4
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0, { sparkle_max_scale, sparkle_max_scale } },
            { 1, { sparkle_max_scale * .9, sparkle_max_scale * .9 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 1.5

local function emit_sparkle_fn(effect, sphere_emitter)
    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = (Vector3(px, py, pz):GetNormalized() * 0.001):Get()


    local angle = math.random() * 360
    local ang_vel = (UnitRand() - 1) * 10

    effect:AddRotatingParticle(
        0,
        lifetime,      -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,    -- velocity
        angle, ang_vel -- angle, angular_velocity
    )
end

local function fn()
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

    --SPARKLE
    effect:SetRenderResources(0, SPARKLE_TEXTURE, REVEAL_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetMaxNumParticles(0, 64)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)

    -----------------------------------------------------



    local num_to_emit = 0

    local sphere_emitter = CreateSphereEmitter(.1)
    inst.last_pos = inst:GetPosition()

    EmitterManager:AddEmitter(inst, nil, function()
        num_to_emit = num_to_emit + 0.3
        while num_to_emit > 1 do
            emit_sparkle_fn(effect, sphere_emitter)
            num_to_emit = num_to_emit - 1
        end
    end)

    return inst
end

return Prefab("icey2_eat_metal_blood_vfx", fn, assets)
