local SPARKLE_TEXTURE = "fx/sparkle.tex"
local ARROW_TEXTURE = "fx/spark.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local ARROW_COLOUR_ENVELOPE_NAME = "icey2_phantom_sword_hitvfx_arrow_colourenvelope"
local ARROW_SCALE_ENVELOPE_NAME = "icey2_phantom_sword_hitvfx_arrow_scaleenvelope"

local SPARKLE_COLOUR_ENVELOPE_NAME = "icey2_phantom_sword_hitvfx_sparkle_colourenvelope"
local SPARKLE_SCALE_ENVELOPE_NAME = "icey2_phantom_sword_hitvfx_sparkle_scaleenvelope"


local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("SHADER", ADD_SHADER),

    Asset("ANIM", "anim/deer_ice_charge.zip"),
}


local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        ARROW_COLOUR_ENVELOPE_NAME,
        {
            { 0,  IntColour(0, 240, 240, 180) },
            { .2, IntColour(10, 240, 240, 255) },
            { .6, IntColour(10, 240, 240, 175) },
            { 1,  IntColour(0, 240, 240, 0) },
        }
    )

    local envs = {}
    local t = 0
    local step = .15
    while t + step + .01 < 0.8 do
        table.insert(envs, { t, IntColour(0, 229, 232, 255) })
        t = t + step
        table.insert(envs, { t, IntColour(255, 229, 232, 200) })
        t = t + .01
    end
    table.insert(envs, { 1, IntColour(0, 229, 232, 0) })

    EnvelopeManager:AddColourEnvelope(SPARKLE_COLOUR_ENVELOPE_NAME, envs)


    local arrow_max_scale_width = 6
    local arrow_max_scale_height = 4
    EnvelopeManager:AddVector2Envelope(
        ARROW_SCALE_ENVELOPE_NAME,
        {

            { 0,   { arrow_max_scale_width * 0.1, arrow_max_scale_height * 0.5 } },
            { 0.2, { arrow_max_scale_width * 0.2, arrow_max_scale_height } },
            { 1,   { arrow_max_scale_width * 0.002, arrow_max_scale_height * 0.000001 } },
        }
    )

    local sparkle_max_scale = 1.0
    EnvelopeManager:AddVector2Envelope(
        SPARKLE_SCALE_ENVELOPE_NAME,
        {
            { 0, { sparkle_max_scale, sparkle_max_scale } },
            { 1, { sparkle_max_scale * .5, sparkle_max_scale * .5 } },
        }
    )


    InitEnvelope = nil
    IntColour = nil
end

local ARROW_MAX_LIFETIME = 0.3
local SPARKLE_MAX_LIFETIME = 1.5


local function emit_arrow_fn(effect, sphere_emitter)
    local lifetime = ARROW_MAX_LIFETIME * GetRandomMinMax(0.7, 1)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = (Vector3(px, py, pz):GetNormalized() * 0.3):Get()

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        0,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
    )
end

local function emit_sparkle_fn(effect, sphere_emitter)
    local lifetime = SPARKLE_MAX_LIFETIME * GetRandomMinMax(0.7, 1)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = (Vector3(px, py, pz):GetNormalized() * 0.08):Get()

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


------------------------------------------------------------------------------

local function hitvfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst.persists = false


    inst._direction_x = net_float(inst.GUID, "inst.direction_x")
    inst._direction_y = net_float(inst.GUID, "inst.direction_y")
    inst._direction_z = net_float(inst.GUID, "inst.direction_z")

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
    effect:SetMaxNumParticles(0, 8)
    effect:SetMaxLifetime(0, ARROW_MAX_LIFETIME)
    effect:SetColourEnvelope(0, ARROW_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, ARROW_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetUVFrameSize(0, 0.25, 1)
    -- effect:SetSortOrder(0, 1)
    effect:SetSortOffset(0, 1)
    effect:SetDragCoefficient(0, 0.08)
    effect:SetRotateOnVelocity(0, true)

    --SPARKLE
    effect:SetRenderResources(1, SPARKLE_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(1, 8)
    effect:SetMaxLifetime(1, SPARKLE_MAX_LIFETIME)
    effect:SetColourEnvelope(1, SPARKLE_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(1, SPARKLE_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, 0.25, 1)
    -- effect:SetSortOrder(1, 1)
    effect:SetSortOffset(1, 1)
    effect:SetDragCoefficient(1, 0.07)
    effect:SetRotationStatus(1, true)

    local sphere_emitter = CreateSphereEmitter(0.4)
    local sphere_emitter_2 = CreateSphereEmitter(0.1)

    inst.emitted = false

    EmitterManager:AddEmitter(inst, nil, function()
        if inst.emitted then
            return
        end

        local parent = inst.entity:GetParent()

        if parent then
            for i = 1, math.random(4, 5) do
                emit_arrow_fn(effect, sphere_emitter)
            end

            for i = 1, math.random(2, 3) do
                -- local vel_sparkle = Vector3(inst._direction_x:value(), inst._direction_y:value(),
                --                             inst._direction_z:value())
                --     :GetNormalized()
                -- local vec_vertical = vel_sparkle:Cross(Vector3(1, 0, 0)):GetNormalized()

                -- vel_sparkle.x = vel_sparkle.x + GetRandomMinMax(-0.2, 0.2)
                -- vel_sparkle.y = vel_sparkle.y + GetRandomMinMax(-0.2, 0.2)
                -- vel_sparkle.z = vel_sparkle.z + GetRandomMinMax(-0.2, 0.2)

                -- vel_sparkle = vel_sparkle + Vector3(GetRandomMinMax(-0.2, 0.2), 0, 0)
                -- vel_sparkle = vel_sparkle + vec_vertical * GetRandomMinMax(-0.2, 0.2)
                -- emit_sparkle_fn(effect, sphere_emitter_2, vel_sparkle:GetNormalized() * 0.1)

                emit_sparkle_fn(effect, sphere_emitter_2)
            end


            inst.emitted = true
        end
    end)

    return inst
end
------------------------------------------------------------------------------

local function SetEmitDirection(inst, direction)
    inst.vfx = inst:SpawnChild("icey2_phantom_sword_hitvfx")
    inst.vfx._direction_x:set(direction.x)
    inst.vfx._direction_y:set(direction.y)
    inst.vfx._direction_z:set(direction.z)
end

local function hitfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("deer_ice_charge")
    inst.AnimState:SetBuild("deer_ice_charge")
    inst.AnimState:PlayAnimation("blast")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(3)


    inst:AddTag("FX")

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst.SetEmitDirection = SetEmitDirection

    inst.AnimState:HideSymbol("line")

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

-- c_spawn("icey2_phantom_sword"):Launch(ThePlayer,c_select())
return Prefab("icey2_phantom_sword_hitvfx", hitvfxfn, assets),
    Prefab("icey2_phantom_sword_hitfx", hitfxfn, assets)
