local ARROW_TEXTURE = "fx/spark.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME_ARROW = "icey2_scythe_tail_vfx_arrow_colourenvelope"
local SCALE_ENVELOPE_NAME_ARROW = "icey2_scythe_tail_vfx_arrow_scaleenvelope"

local assets =
{
    Asset("IMAGE", ARROW_TEXTURE),

    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_ARROW,
        {
            { 0,  IntColour(100, 255, 255, 0) },
            { .2, IntColour(100, 253, 245, 210) },
            { .6, IntColour(100, 226, 110, 200) },
            { 1,  IntColour(100, 226, 110, 0) },
        }
    )
    local arrow_max_scale = 1.2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_ARROW,
        {
            { 0, { arrow_max_scale, arrow_max_scale * 2.4 } },
            { 1, { arrow_max_scale * 0.01, arrow_max_scale * 2 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local ARROW_MAX_LIFETIME = 0.55

local function emit_arrow_fn(effect, ellipse_emitter, direction)
    local vx, vy, vz = direction:Get()

    local lifetime = ARROW_MAX_LIFETIME * (0.7 + math.random() * .3)
    local px, py, pz = ellipse_emitter()
    -- local px, py, pz = 0, 0, 0


    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        0,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
    )
end

local function CreateEllipseEmitter(r1, r2, r3)
    local function fn()
        local theta1 = math.random() * PI2
        local theta2 = math.random() * PI2

        return r1 * math.cos(theta1) * math.cos(theta2),
            r2 * math.sin(theta1) * math.cos(theta2),
            r3 * math.sin(theta2)
    end
    return fn
end

local function GetFaceVector(inst)
    local angle = (inst.Transform:GetRotation() + 90) * DEGREES
    local sinangle = math.sin(angle)
    local cosangle = math.cos(angle)

    return Vector3(sinangle, 0, cosangle)
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
    effect:SetRenderResources(0, ARROW_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 64)
    effect:SetMaxLifetime(0, ARROW_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_ARROW)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_ARROW)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 0.25, 1)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 0)
    effect:SetDragCoefficient(0, .05)
    effect:SetRotateOnVelocity(0, true)
    -- effect:SetAcceleration(0, 0, -0.3, 0)

    -----------------------------------------------------

    local ellipse_emitter = CreateEllipseEmitter(0.4, 1.1, 0.4)
    inst.last_pos = inst:GetPosition()

    local tick_time = TheSim:GetTickTime()

    local desired_pps_low = 1
    local desired_pps_high = 5
    local low_per_tick = desired_pps_low * tick_time
    local high_per_tick = desired_pps_high * tick_time
    local num_to_emit = 0

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if not parent then
            return
        end

        local dist_moved = inst:GetPosition() - inst.last_pos
        local move = dist_moved:Length()
        move = math.clamp(move * 6, 0, 1)

        local per_tick = Lerp(low_per_tick, high_per_tick, move)

        inst.last_pos = inst:GetPosition()

        num_to_emit = num_to_emit + per_tick * math.random(2, 3)
        while num_to_emit > 1 do
            local face_vec = GetFaceVector(parent)
            emit_arrow_fn(effect, ellipse_emitter, face_vec * GetRandomMinMax(0.25, 0.33))
            num_to_emit = num_to_emit - 1
        end

        -- local face_vec = GetFaceVector(parent)
        -- emit_arrow_fn(effect, ellipse_emitter, face_vec * GetRandomMinMax(0.25, 0.33))
    end)

    return inst
end

return Prefab("icey2_scythe_tail_vfx", fn, assets)
