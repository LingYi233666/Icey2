local SPARKLE_TEXTURE = "fx/sparkle.tex"
local ARROW_TEXTURE = "fx/spark.tex"
local SMOKE_TEXTURE = "fx/smoke.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME_ARROW_BLUE = "icey2_focus_hit_vfx_arrow_blue_colourenvelope"
local COLOUR_ENVELOPE_NAME_ARROW_RED = "icey2_focus_hit_vfx_arrow_red_colourenvelope"
local SCALE_ENVELOPE_NAME_ARROW = "icey2_focus_hit_vfx_arrow_scaleenvelope"

local COLOUR_ENVELOPE_NAME_SPARKLE_BLUE = "icey2_focus_hit_vfx_sparkle_blue_colourenvelope"
local COLOUR_ENVELOPE_NAME_SPARKLE_RED = "icey2_focus_hit_vfx_sparkle_red_colourenvelope"
local SCALE_ENVELOPE_NAME_SPARKLE = "icey2_focus_hit_vfx_sparkle_scaleenvelope"

local SCALE_ENVELOPE_NAME_SMOKE = "icey2_focus_hit_vfx_smoke_scaleenvelope"

local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("IMAGE", SMOKE_TEXTURE),
    Asset("SHADER", ADD_SHADER),

    Asset("ANIM", "anim/deer_ice_charge.zip"),
}


local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_ARROW_BLUE,
        {
            { 0,  IntColour(0, 240, 240, 180) },
            { .2, IntColour(10, 240, 240, 255) },
            { .6, IntColour(10, 240, 240, 175) },
            { 1,  IntColour(0, 240, 240, 0) },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_ARROW_RED,
        {
            -- { 0,  IntColour(200, 100, 26, 180) },
            -- { .2, IntColour(210, 100, 26, 255) },
            -- { .6, IntColour(210, 100, 26, 175) },
            -- { 1,  IntColour(200, 100, 26, 0) },

            -- { 0,  IntColour(200, 26, 26, 180) },
            -- { .2, IntColour(210, 26, 26, 255) },
            -- { .6, IntColour(210, 26, 26, 175) },
            -- { 1,  IntColour(200, 26, 26, 0) },

            { 0,  IntColour(200, 0, 0, 180) },
            { .2, IntColour(210, 0, 0, 255) },
            { .6, IntColour(210, 0, 0, 175) },
            { 1,  IntColour(200, 0, 0, 0) },
        }
    )

    local envs_blue = {}
    local t = 0
    local step = .15
    while t + step + .01 < 0.8 do
        table.insert(envs_blue, { t, IntColour(0, 229, 232, 255) })
        t = t + step
        table.insert(envs_blue, { t, IntColour(255, 229, 232, 200) })
        t = t + .01
    end
    table.insert(envs_blue, { 1, IntColour(0, 229, 232, 0) })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SPARKLE_BLUE, envs_blue)


    -- local envs_red = {}
    -- local t = 0
    -- local step = .15
    -- while t + step + .01 < 0.8 do
    --     table.insert(envs_red, { t, IntColour(200, 26, 26, 255) })
    --     t = t + step
    --     table.insert(envs_red, { t, IntColour(200, 229, 232, 200) })
    --     t = t + .01
    -- end
    -- table.insert(envs_red, { 1, IntColour(200, 26, 26, 0) })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SPARKLE_RED, {
        { 0,   IntColour(200, 0, 0, 255) },
        { 0.2, IntColour(200, 0, 0, 255) },
        { 1,   IntColour(210, 0, 0, 0) },
    })


    local arrow_max_scale = 2.5
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_ARROW,
        {

            { 0, { arrow_max_scale * 0.3, arrow_max_scale } },
            { 1, { arrow_max_scale * 0.2, arrow_max_scale * 0.9 } },
        }
    )

    local sparkle_max_scale = 0.6
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SPARKLE,
        {
            { 0, { sparkle_max_scale, sparkle_max_scale } },
            { 1, { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
        }
    )

    local smoke_max_scale = 0.8
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0, { smoke_max_scale, smoke_max_scale } },
            { 1, { smoke_max_scale * .5, smoke_max_scale * .5 } },
        }
    )




    InitEnvelope = nil
    IntColour = nil
end

local ARROW_MAX_LIFETIME = 0.5
local SPARKLE_MAX_LIFETIME = 1.5


local function emit_arrow_fn(effect, pos)
    local lifetime = ARROW_MAX_LIFETIME * GetRandomMinMax(0.7, 1)
    local px, py, pz = pos:Get()
    local vx, vy, vz = (pos:GetNormalized() * 0.1):Get()

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        0,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
    )
end

local function emit_sparkle_fn(effect, pos)
    local lifetime = SPARKLE_MAX_LIFETIME * GetRandomMinMax(0.7, 1)
    local px, py, pz = pos:Get()
    local vx, vy, vz = (pos:GetNormalized() * 0.08):Get()

    local uv_offset = math.random(0, 3) * .25

    local angle = math.random() * 360
    local ang_vel = (UnitRand() - 1) * 5

    effect:AddRotatingParticleUV(
        1,
        lifetime,       -- lifetime
        px, py, pz,     -- position
        vx, vy, vz,     -- velocity
        angle, ang_vel, -- angle, angular_velocity
        uv_offset, 0    -- uv offset
    )
end


local function common_fn()
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
    effect:InitEmitters(2)

    --ARROW
    effect:SetRenderResources(0, ARROW_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 16)
    effect:SetMaxLifetime(0, ARROW_MAX_LIFETIME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_ARROW)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 0.25, 1)
    -- effect:SetSortOrder(0, 1)
    effect:SetSortOffset(0, 1)
    effect:SetDragCoefficient(0, 0.08)
    effect:SetRotateOnVelocity(0, true)

    --SPARKLE
    effect:SetRenderResources(1, SPARKLE_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(1, 16)
    effect:SetMaxLifetime(1, SPARKLE_MAX_LIFETIME)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SPARKLE)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, 0.25, 1)
    -- effect:SetSortOrder(1, 1)
    effect:SetSortOffset(1, 1)
    effect:SetDragCoefficient(1, 0.07)
    effect:SetRotationStatus(1, true)


    inst.direction_emitter_1 = Icey2Math.CustomSphereEmitter(0.3,
        0.4,
        30 * DEGREES,
        150 * DEGREES,
        -70 * DEGREES,
        70 * DEGREES)

    inst.direction_emitter_2 = Icey2Math.CustomSphereEmitter(0,
        0.1,
        30 * DEGREES,
        150 * DEGREES,
        -70 * DEGREES,
        70 * DEGREES)

    inst.num_emit_arrow = math.random(4, 5)
    inst.num_emit_sparkle = math.random(9, 12)

    inst.emitted = false

    EmitterManager:AddEmitter(inst, nil, function()
        if inst.emitted then
            return
        end

        local parent = inst.entity:GetParent()

        if parent then
            local face_vec = Icey2Basic.GetFaceVector(parent)
            local axis_y = Vector3(0, 1, 0)
            local axis_z = axis_y:Cross(face_vec)

            for i = 1, inst.num_emit_arrow do
                local direction = Vector3(inst.direction_emitter_1())
                direction = face_vec * direction.x + axis_y * direction.y + axis_z * direction.z
                emit_arrow_fn(inst.VFXEffect, direction)
            end

            for i = 1, inst.num_emit_sparkle do
                local direction = Vector3(inst.direction_emitter_2())
                direction = face_vec * direction.x + axis_y * direction.y + axis_z * direction.z
                emit_sparkle_fn(inst.VFXEffect, direction)
            end


            inst.emitted = true
        end
    end)

    return inst
end


local function blue_vfx_fn()
    local inst = common_fn()

    if TheNet:IsDedicated() then
        return inst
    end

    inst.VFXEffect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_ARROW_BLUE)

    inst.VFXEffect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SPARKLE_BLUE)

    return inst
end

local function red_vfx_fn()
    local inst = common_fn()

    if TheNet:IsDedicated() then
        return inst
    end

    inst.direction_emitter_1 = Icey2Math.CustomSphereEmitter(0.3,
        0.4,
        0,
        PI,
        0,
        PI)

    inst.direction_emitter_2 = Icey2Math.CustomSphereEmitter(0,
        0.1,
        30 * DEGREES,
        150 * DEGREES,
        -70 * DEGREES,
        70 * DEGREES)

    inst.num_emit_arrow = math.random(14, 16)
    -- inst.num_emit_sparkle = math.random(4, 5)

    inst.VFXEffect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_ARROW_RED)

    inst.VFXEffect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SPARKLE_RED)
    inst.VFXEffect:SetRenderResources(1, SMOKE_TEXTURE, ADD_SHADER)
    inst.VFXEffect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE)

    return inst
end

return Prefab("icey2_focus_hit_vfx_blue", blue_vfx_fn, assets),
    Prefab("icey2_focus_hit_vfx_red", red_vfx_fn, assets)
