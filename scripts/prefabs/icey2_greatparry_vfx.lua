local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local EMBER_TEXTURE = "fx/snow.tex"
local CIRCLE_TEXTURE = "fx/smoke.tex"
local ARROW_TEXTURE = "fx/spark.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE = "icey2_greatparry_vfxeffect_colourenvelope_smoke"
local SCALE_ENVELOPE_NAME_SMOKE = "icey2_greatparry_vfxeffect_scaleenvelope_smoke"
local COLOUR_ENVELOPE_NAME_EMBER = "icey2_greatparry_vfxeffect_colourenvelope_ember"
local SCALE_ENVELOPE_NAME_EMBER = "icey2_greatparry_vfxeffect_scaleenvelope_ember"
local COLOUR_ENVELOPE_NAME_CIRCLE = "icey2_greatparry_vfxeffect_colourenvelope_circle"
local SCALE_ENVELOPE_NAME_CIRCLE = "icey2_greatparry_vfxeffect_scaleenvelope_circle"
local COLOUR_ENVELOPE_NAME_SMOKE2 = "icey2_greatparry_vfxeffect_colourenvelope_smoke2"
local SCALE_ENVELOPE_NAME_SMOKE2 = "icey2_greatparry_vfxeffect_scaleenvelope_smoke2"
local COLOUR_ENVELOPE_NAME_ARROW = "icey2_greatparry_vfxeffect_colourenvelope_arrow"
local SCALE_ENVELOPE_NAME_ARROW = "icey2_greatparry_vfxeffect_scaleenvelope_arrow"

local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("IMAGE", CIRCLE_TEXTURE),
    Asset("IMAGE", EMBER_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("SHADER", REVEAL_SHADER),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SMOKE,
        {
            { 0,   IntColour(10, 10, 10, 0) },
            { 0.1, IntColour(10, 10, 10, 10) },
            { .3,  IntColour(10, 10, 10, 175) },
            { .52, IntColour(10, 10, 10, 90) },
            { 1,   IntColour(10, 10, 10, 0) },
        }
    )

    local smoke_max_scale = 0.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0, { smoke_max_scale * .5, smoke_max_scale * .5 } },
            { 1, { smoke_max_scale, smoke_max_scale } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_EMBER,
        {
            { 0,  IntColour(255, 255, 255, 25) },
            { .2, IntColour(255, 255, 255, 255) },
            { .6, IntColour(255, 250, 250, 255) },
            { 1,  IntColour(255, 200, 200, 0) },

            -- 0, 229, 232, 255

            -- { 0,    IntColour(200, 85, 60, 25) },
            -- { .075, IntColour(230, 140, 90, 200) },
            -- { .3,   IntColour(255, 90, 70, 255) },
            -- { .6,   IntColour(255, 90, 70, 255) },
            -- { .9,   IntColour(255, 90, 70, 230) },
            -- { 1,    IntColour(255, 70, 70, 0) },
        }
    )

    local ember_max_scale = 1.25
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_EMBER,
        {
            { 0, { ember_max_scale, ember_max_scale } },
            { 1, { ember_max_scale * 0.1, ember_max_scale * 0.1 } },
        }
    )


    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_CIRCLE,
        {
            -- { 0,    IntColour(255, 90, 70, 0) },
            -- { .075, IntColour(255, 90, 70, 255) },
            -- { .3,   IntColour(200, 85, 60, 60) },
            -- { .6,   IntColour(230, 140, 90, 50) },
            -- { .9,   IntColour(255, 90, 70, 25) },
            -- { 1,    IntColour(255, 70, 70, 0) },

            { 0,    IntColour(96, 249, 255, 0) },
            { .075, IntColour(96, 249, 255, 255) },
            { .3,   IntColour(96, 249, 255, 60) },
            { .6,   IntColour(96, 249, 255, 50) },
            { .9,   IntColour(96, 249, 255, 25) },
            { 1,    IntColour(96, 249, 255, 0) },
        }
    )

    local circle_max_scale = 5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_CIRCLE,
        {
            { 0, { circle_max_scale, circle_max_scale } },
            { 1, { circle_max_scale * 1.1, circle_max_scale * 1.1 } },
        }
    )


    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SMOKE2,
        {
            { 0,  IntColour(255, 90, 70, 0) },
            { .2, IntColour(255, 120, 90, 240) },
            { .3, IntColour(200, 85, 60, 60) },
            { .6, IntColour(230, 140, 90, 50) },
            { .9, IntColour(255, 90, 70, 25) },
            { 1,  IntColour(255, 70, 70, 0) },
        }
    )

    local smoke2_max_scale = 1.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE2,
        {
            { 0, { smoke2_max_scale, smoke2_max_scale } },
            { 1, { smoke2_max_scale * 1.1, smoke2_max_scale * 1.1 } },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_ARROW,
        {
            -- { 0,  IntColour(255, 90, 70, 180) },
            -- { .2, IntColour(255, 120, 90, 255) },
            -- { .6, IntColour(255, 90, 70, 175) },
            -- { 1,  IntColour(0, 0, 0, 0) },

            { 0,  IntColour(96, 249, 255, 180) },
            { .2, IntColour(96, 249, 255, 255) },
            { .6, IntColour(96, 249, 255, 175) },
            { 1,  IntColour(96, 249, 255, 0) },


        }
    )
    local arrow_max_scale = 2.25
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_ARROW,
        {
            { 0, { arrow_max_scale, arrow_max_scale } },
            { 1, { arrow_max_scale * 0.125, arrow_max_scale * 0.8 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local EMBER_MAX_LIFETIME = 0.3
local SMOKE_MAX_LIFETIME = 2
local CIRCLE_MAX_LIFETIME = 0.33
local SMOKE2_MAX_LIFETIME = 0.5
local ARROW_MAX_LIFETIME = 0.35

local SPAWN_HEIGHT = 1.1

local function emit_ember_fn(effect, sphere_emitter, adjust_vec)
    local lifetime = EMBER_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = sphere_emitter()
    local vec = Vector3(px, py, pz):GetNormalized() * GetRandomMinMax(0.5, 1.4)
    -- local vx, vy, vz = .17 * UnitRand(), .17 * math.random(), .17 * UnitRand()
    local vx, vy, vz = (vec + Vector3(0, GetRandomMinMax(0.4, 0.9), 0)):Get()

    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    effect:AddParticle(
        0,
        lifetime,                  -- lifetime
        px, py + SPAWN_HEIGHT, pz, -- position
        vx, vy, vz                 -- velocity
    )
end

local function emit_smoke_fn(effect, sphere_emitter, adjust_vec)
    local vx, vy, vz = .2 * UnitRand(), .1 + .1 * UnitRand(), .2 * UnitRand()
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = sphere_emitter()
    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    effect:AddRotatingParticle(
        1,
        lifetime,            -- lifetime
        px, py + .5, pz,     -- position
        vx, vy, vz,          -- velocity
        math.random() * 360, --* 2 * PI, -- angle
        UnitRand() * 2       -- angle velocity
    )
end

local function emit_circle_fn(effect, adjust_vec)
    local vx, vy, vz = 0, 0, 0
    local lifetime = CIRCLE_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = 0, 0, 0
    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    effect:AddRotatingParticle(
        2,
        lifetime,                  -- lifetime
        px, py + SPAWN_HEIGHT, pz, -- position
        vx, vy, vz,                -- velocity
        math.random() * 360,       --* 2 * PI, -- angle
        UnitRand() * 0.1           -- angle velocity
    )
end

local function emit_smoke2_fn(effect, adjust_vec)
    local vx, vy, vz = 0, 0, 0
    local lifetime = SMOKE2_MAX_LIFETIME * (.9 + math.random() * .1)
    local px, py, pz = 0, 0, 0
    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    effect:AddRotatingParticle(
        3,
        lifetime,            -- lifetime
        px, py + .7, pz,     -- position
        vx, vy, vz,          -- velocity
        math.random() * 360, --* 2 * PI, -- angle
        UnitRand() * 2.5     -- angle velocity
    )
end

local function emit_arrow_fn(effect, sphere_emitter, adjust_vec)
    local lifetime = ARROW_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = sphere_emitter()

    -- local vx, vy, vz = sz * UnitRand(), 3*sz * UnitRand(), sz * UnitRand()
    local vec = Vector3(px, py, pz):GetNormalized() * GetRandomMinMax(0.5, 0.6)
    -- local vx, vy, vz = .17 * UnitRand(), .17 * math.random(), .17 * UnitRand()
    local vx, vy, vz = vec:Get()

    if adjust_vec ~= nil then
        px = px + adjust_vec.x
        py = py + adjust_vec.y
        pz = pz + adjust_vec.z
    end

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        4,
        lifetime,                  -- lifetime
        px, py + SPAWN_HEIGHT, pz, -- position
        vx, vy, vz,                -- velocity
        uv_offset, 0               -- uv offset
    )
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    inst:DoTaskInTime(1, inst.Remove)

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    -- print(inst,"AddVFXEffect")

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(5)

    --EMBER
    effect:SetRenderResources(0, EMBER_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 128)
    effect:SetMaxLifetime(0, EMBER_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_EMBER)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_EMBER)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 0)
    effect:SetDragCoefficient(0, .3)
    effect:SetAcceleration(0, 0, -0.5, 0)

    --SMOKE
    effect:SetRenderResources(1, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(1, 64)
    effect:SetRotationStatus(1, true)
    effect:SetMaxLifetime(1, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    --effect:EnableBloomPass(1, true)
    --effect:SetUVFrameSize(1, .25, 1)
    effect:SetSortOrder(1, 0)
    effect:SetSortOffset(1, 0)
    effect:SetRadius(1, 3) --only needed on a single emitter
    effect:SetDragCoefficient(1, .1)

    --CIRCLE
    effect:SetRenderResources(2, CIRCLE_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(2, 1)
    effect:SetRotationStatus(2, true)
    effect:SetUVFrameSize(2, 0.25, 1)
    effect:SetMaxLifetime(2, CIRCLE_MAX_LIFETIME)
    effect:SetColourEnvelope(2, COLOUR_ENVELOPE_NAME_CIRCLE)
    effect:SetScaleEnvelope(2, SCALE_ENVELOPE_NAME_CIRCLE)
    effect:SetBlendMode(2, BLENDMODE.Additive) --AlphaBlended Premultiplied
    effect:SetSortOrder(2, 2)
    effect:SetSortOffset(2, 2)
    -- effect:SetRadius(2, 3) --only needed on a single emitter
    effect:SetDragCoefficient(2, .1)

    --SMOKE2
    effect:SetRenderResources(3, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetMaxNumParticles(3, 1)
    effect:SetRotationStatus(3, true)
    effect:SetMaxLifetime(3, SMOKE2_MAX_LIFETIME)
    effect:SetColourEnvelope(3, COLOUR_ENVELOPE_NAME_SMOKE2)
    effect:SetScaleEnvelope(3, SCALE_ENVELOPE_NAME_SMOKE2)
    effect:SetBlendMode(3, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied
    --effect:EnableBloomPass(1, true)
    --effect:SetUVFrameSize(1, .25, 1)
    effect:SetSortOrder(3, 0)
    effect:SetSortOffset(3, 0)
    effect:SetRadius(3, 3) --only needed on a single emitter
    effect:SetDragCoefficient(3, .1)

    --ARROW
    effect:SetRenderResources(4, ARROW_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(4, 25)
    effect:SetMaxLifetime(4, ARROW_MAX_LIFETIME)
    effect:SetColourEnvelope(4, COLOUR_ENVELOPE_NAME_ARROW)
    effect:SetScaleEnvelope(4, SCALE_ENVELOPE_NAME_ARROW)
    effect:SetBlendMode(4, BLENDMODE.Additive)
    effect:EnableBloomPass(4, true)
    effect:SetUVFrameSize(4, 0.25, 1)
    effect:SetSortOrder(4, 0)
    effect:SetSortOffset(4, 0)
    effect:SetDragCoefficient(4, .14)
    effect:SetRotateOnVelocity(4, true)
    -- effect:SetAcceleration(4, 0, -0.3, 0)

    -----------------------------------------------------


    local ember_sphere_emitter = function()
        local rad = 0.1
        local theate = PI * 2 * math.random()
        local fai = math.random() <= 0.5 and PI * GetRandomMinMax(0, 0.3) or PI * GetRandomMinMax(0.7, 1)
        local x = rad * math.sin(theate) * math.cos(fai)
        local y = rad * math.sin(theate) * math.sin(fai)
        local z = rad * math.cos(theate)
        return x, y, z
    end
    -- local ember_sphere_emitter = CreateSphereEmitter(0.15)
    local smoke_sphere_emitter = CreateSphereEmitter(.2)
    local arrow_sphere_emitter = CreateSphereEmitter(.1)
    -- print("ember_sphere_emitter")

    local num_to_emit_ember = 40
    local num_to_emit_smoke = 75
    local num_to_emit_circle = 2
    local num_to_emit_arrow = 25

    EmitterManager:AddEmitter(inst, nil, function()
        -- print("start AddEmitter")

        while num_to_emit_circle > 1 do
            emit_circle_fn(effect)
            -- emit_smoke2_fn(effect)
            num_to_emit_circle = num_to_emit_circle - 1
        end

        while num_to_emit_arrow > 1 do
            emit_arrow_fn(effect, arrow_sphere_emitter)
            num_to_emit_arrow = num_to_emit_arrow - 1
        end

        while num_to_emit_ember > 1 do
            emit_ember_fn(effect, ember_sphere_emitter)
            num_to_emit_ember = num_to_emit_ember - 1
        end

        -- while num_to_emit_smoke > 1 do
        --     emit_smoke_fn(effect, smoke_sphere_emitter)
        --     num_to_emit_smoke = num_to_emit_smoke - 1
        -- end
    end)

    return inst
end

return Prefab("icey2_greatparry_vfx", fn, assets)
