local SPARKLE_TEXTURE = "fx/sparkle.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "icey2_dodge_vfx_colourenvelope"
local SCALE_ENVELOPE_NAME = "icey2_dodge_vfx_scaleenvelope"

local assets = { Asset("IMAGE", SPARKLE_TEXTURE), Asset("SHADER", ADD_SHADER) }

--------------------------------------------------------------------------

local function IntColour(r, g, b, a) return { r / 255, g / 255, b / 255, a / 255 } end

local function InitEnvelope()
    local envs = {}
    local t = 0
    local step = .15
    while t + step + .01 < 1 do
        table.insert(envs, { t, IntColour(0, 229, 232, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(0, 229, 232, 0) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(0, 229, 232, 0) })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, envs)

    local sparkle_max_scale = 1
    EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE_NAME, {
        { 0, { sparkle_max_scale, sparkle_max_scale } },
        -- { 0.7, { sparkle_max_scale, sparkle_max_scale } },
        { 1, { sparkle_max_scale * .001, sparkle_max_scale * .001 } }
    })

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.33

local function emit_sparkle_fn(effect, sphere_emitter, offset)
    local vx, vy, vz = .012 * UnitRand(), 0, .012 * UnitRand()
    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()

    local angle = math.random() * 360
    local uv_offset = math.random(0, 3) * .25
    local ang_vel = (UnitRand() - 1) * 5

    effect:AddRotatingParticleUV(0,
                                 lifetime,                                    -- lifetime
                                 px + offset.x, py + offset.y, pz + offset.z, -- position
                                 vx, vy, vz,                                  -- velocity
                                 angle, ang_vel,                              -- angle, angular_velocity
                                 uv_offset, 0                                 -- uv offset
    )
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false

    -- Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    -- SPARKLE
    effect:SetRenderResources(0, SPARKLE_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 512)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local sparkle_desired_pps_low = 5
    local sparkle_desired_pps_high = 50
    local low_per_tick = sparkle_desired_pps_low * tick_time
    local high_per_tick = sparkle_desired_pps_high * tick_time
    local num_to_emit = 0

    local sphere_emitter = CreateSphereEmitter(.25)
    inst.last_pos = inst:GetPosition()

    local offsets = {
        Vector3(0, 1, 0),
        Vector3(0, 0.66, 0),
        Vector3(0, 0.33, 0),
    }

    EmitterManager:AddEmitter(inst, nil, function()
        local dist_moved = inst:GetPosition() - inst.last_pos
        local move = dist_moved:Length()
        move = math.clamp(move * 6, 0, 1)

        local per_tick = Lerp(low_per_tick, high_per_tick, move)

        inst.last_pos = inst:GetPosition()

        num_to_emit = num_to_emit + per_tick * math.random() * 3
        while num_to_emit > 1 do
            for _, offset in pairs(offsets) do
                emit_sparkle_fn(effect, sphere_emitter, offset)
            end
            num_to_emit = num_to_emit - 1
        end
    end)

    return inst
end

return Prefab("icey2_dodge_vfx", fn, assets)
