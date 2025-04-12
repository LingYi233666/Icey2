local SPARKLE_TEXTURE = "fx/sparkle.tex"
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local ARROW_TEXTURE = "fx/spark.tex"
local EMBER_TEXTURE = "fx/snow.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"


local COLOUR_ENVELOPE_NAME_SMOKE_BLUE = "icey2_ground_slam_colourenvelope_smoke_blue"
local COLOUR_ENVELOPE_NAME_SMOKE_WHITE = "icey2_ground_slam_colourenvelope_smoke_white"
local COLOUR_ENVELOPE_NAME_SMOKE_WHITE2 = "icey2_ground_slam_colourenvelope_smoke_white2"

local SCALE_ENVELOPE_NAME_SMOKE_1 = "icey2_ground_slam_scaleenvelope_smoke_1"
local SCALE_ENVELOPE_NAME_SMOKE_2 = "icey2_ground_slam_scaleenvelope_smoke_2"
local SCALE_ENVELOPE_NAME_SMOKE_3 = "icey2_ground_slam_scaleenvelope_smoke_3"


local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("IMAGE", EMBER_TEXTURE),

    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}


local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_BLUE, {
        { 0,  IntColour(0, 100, 200, 0) },
        { .2, IntColour(0, 100, 200, 240) },
        { .3, IntColour(0, 100, 200, 180) },
        { .6, IntColour(0, 100, 200, 150) },
        { .9, IntColour(0, 100, 200, 110) },
        { 1,  IntColour(0, 100, 200, 0) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_WHITE, {
        { 0,  IntColour(200, 200, 200, 0) },
        { .2, IntColour(200, 200, 200, 240) },
        { .3, IntColour(200, 200, 200, 180) },
        { .6, IntColour(200, 200, 200, 150) },
        { .9, IntColour(200, 200, 200, 110) },
        { 1,  IntColour(200, 200, 200, 0) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_WHITE2, {
        { 0,  IntColour(0, 100, 200, 100) },
        { .1, IntColour(0, 100, 200, 200) },
        { .6, IntColour(0, 100, 200, 150) },
        { 1,  IntColour(0, 100, 200, 0) },
    })




    local scale_factor = 1.2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_1,
        {
            { 0,   { scale_factor * 0.07, scale_factor } },
            { 0.2, { scale_factor * 0.07, scale_factor } },
            { 1,   { scale_factor * .01, scale_factor * 0.6 } },
        }
    )


    scale_factor = 0.6
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_2,
        {
            { 0,   { scale_factor * 0.07, scale_factor } },
            { 0.2, { scale_factor * 0.07, scale_factor } },
            { 1,   { scale_factor * .005, scale_factor * 0.6 } },
        }
    )

    scale_factor = 0.7
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_3,
        {
            { 0,   { scale_factor * .2, scale_factor * .2 } },
            { .40, { scale_factor * .7, scale_factor * .7 } },
            { .60, { scale_factor * .8, scale_factor * .8 } },
            { .75, { scale_factor * .7, scale_factor * .7 } },
            { 1,   { scale_factor, scale_factor } },
        }
    )


    InitEnvelope = nil
    IntColour = nil
end

local MAX_LIFETIME = 0.6
local MAX_LIFETIME2 = 1.1

local function emit_line(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local px, py, pz = pos:Get()
    local lifetime = (MAX_LIFETIME * (.8 + UnitRand() * .2))

    effect:AddParticle(
        0,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function emit_line_thin(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local px, py, pz = pos:Get()
    local lifetime = (MAX_LIFETIME * (.8 + UnitRand() * .2))

    effect:AddParticle(
        1,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function emit_smoke_fn(effect, sphere_emitter)
    local vx, vy, vz = .01 * UnitRand(), .01 + .02 * UnitRand(), .01 * UnitRand()
    local lifetime = MAX_LIFETIME2 * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()

    effect:AddRotatingParticle(
        2,
        lifetime,            -- lifetime
        px, py, pz,          -- position
        vx, vy, vz,          -- velocity
        math.random() * 360, --* TWOPI, -- angle
        UnitRand() * 2       -- angle velocity
    )
end

local function vfx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")


    inst._can_emit = net_bool(inst.GUID, "inst._can_emit")
    inst._can_emit:set(false)

    inst.entity:SetPristine()

    inst.persists = false

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    else
        if InitEnvelope ~= nil then
            InitEnvelope()
        end
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(3)

    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(0, true)
    effect:SetMaxNumParticles(0, 16)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE_BLUE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE_1)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    effect:SetRadius(0, 1)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 1)
    effect:SetDragCoefficient(0, 0.05)


    effect:SetRenderResources(1, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(1, true)
    effect:SetMaxNumParticles(1, 16)
    effect:SetMaxLifetime(1, MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE_WHITE)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE_2)
    effect:SetBlendMode(1, BLENDMODE.AlphaAdditive)
    effect:EnableBloomPass(1, true)
    effect:SetRadius(1, 1)
    effect:SetSortOrder(1, 1)
    effect:SetSortOffset(1, 1)
    effect:SetDragCoefficient(1, 0.05)

    --SMOKE
    effect:SetRenderResources(2, ANIM_SMOKE_TEXTURE, REVEAL_SHADER) --REVEAL_SHADER --particle_add
    effect:SetMaxNumParticles(2, 64)
    effect:SetRotationStatus(2, true)
    effect:SetMaxLifetime(2, MAX_LIFETIME2)
    effect:SetColourEnvelope(2, COLOUR_ENVELOPE_NAME_SMOKE_WHITE2)
    effect:SetScaleEnvelope(2, SCALE_ENVELOPE_NAME_SMOKE_3)
    effect:SetBlendMode(2, BLENDMODE.AlphaAdditive) --AlphaBlended Premultiplied
    effect:SetSortOrder(2, 1)
    effect:SetSortOffset(2, 2)


    local sphere_emitter_line = Icey2Math.CustomSphereEmitter(0.4, 0.6, 30 * DEGREES, 90 * DEGREES, 0, 360 * DEGREES)
    local sphere_emitter_smoke = Icey2Math.CustomSphereEmitter(0.3, 1.2, 75 * DEGREES, 95 * DEGREES, 0, 360 * DEGREES)


    local num_to_emit = 1
    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if not parent or not inst._can_emit:value() then
            return
        end

        if num_to_emit > 0 then
            for i = 1, 12 do
                local pos = Vector3(sphere_emitter_line())
                local velocity = pos:GetNormalized() * 0.6
                emit_line_thin(effect, pos, velocity)
                emit_line(effect, pos, velocity)
            end

            for i = 1, 24 do
                emit_smoke_fn(effect, sphere_emitter_smoke)
            end
            num_to_emit = num_to_emit - 1
        end
    end)

    return inst
end

return Prefab("icey2_ground_slam_vfx", vfx_fn, assets)
