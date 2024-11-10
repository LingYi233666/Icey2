local SPARKLE_TEXTURE = "fx/sparkle.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "test_laser_beam_colourenvelope"
local SCALE_ENVELOPE_NAME = "test_laser_beam_scaleenvelope"

local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    local envs = {}
    local t = 0
    local step = .15
    while t + step + .01 < 1 do
        table.insert(envs, { t, IntColour(255, 0, 0, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(255, 0, 0, 0) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(255, 0, 0, 0) })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, envs)

    local sparkle_max_scale = .6
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0, { sparkle_max_scale, sparkle_max_scale } },
            { 1, { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.3

local function emit_sparkle_fn(effect, sphere_emitter, vel_offset)
    vel_offset = vel_offset or Vector3(0, 0, 0)

    local vx, vy, vz = .005 * UnitRand(), 0, .005 * UnitRand()
    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()

    local angle = math.random() * 360
    local uv_offset = math.random(0, 3) * .25
    local ang_vel = (UnitRand() - 1) * 5


    vx = vx + vel_offset.x
    vy = vy + vel_offset.y
    vz = vz + vel_offset.z

    effect:AddRotatingParticleUV(
        0,
        lifetime,       -- lifetime
        px, py, pz,     -- position
        vx, vy, vz,     -- velocity
        angle, ang_vel, -- angle, angular_velocity
        uv_offset, 0    -- uv offset
    )
end

local function vfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false


    inst._vx = net_float(inst.GUID, "inst._vx")
    inst._vy = net_float(inst.GUID, "inst._vy")
    inst._vz = net_float(inst.GUID, "inst._vz")

    inst.SetEmitVelocity = function(inst, x, y, z)
        inst._vx:set(x)
        inst._vy:set(y)
        inst._vz:set(z)
    end

    inst:SetEmitVelocity(0, 0, 0)

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    --SPARKLE
    effect:SetRenderResources(0, SPARKLE_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 64)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)
    effect:SetGroundPhysics(0, true)

    -----------------------------------------------------

    local sphere_emitter = CreateSphereEmitter(.1)

    EmitterManager:AddEmitter(inst, nil, function()
        for i = 1, 2 do
            emit_sparkle_fn(effect, sphere_emitter, Vector3(
                inst._vx:value(),
                inst._vy:value(),
                inst._vz:value()
            ))
        end
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

    inst.vfx = inst:SpawnChild("test_laser_beam_vfx")

    return inst
end



return Prefab("test_laser_beam_vfx", vfxfn, assets),
    Prefab("test_laser_beam_fx", fxfn, assets)
