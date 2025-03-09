local ARROW_TEXTURE = "fx/spark.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME_ARROW = "icey2_chainsaw_hit_arrow_colourenvelope"
local SCALE_ENVELOPE_NAME_ARROW = "icey2_chainsaw_hit_arrow_scaleenvelope"

local assets =
{
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("SHADER", ADD_SHADER),

    Asset("ANIM", "anim/deer_ice_charge.zip"),
    Asset("ANIM", "anim/deer_fire_charge.zip"),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_ARROW, {
        { 0,  IntColour(255, 255, 255, 180) },
        { .2, IntColour(255, 253, 245, 255) },
        { .6, IntColour(255, 226, 110, 255) },
        { 1,  IntColour(0, 0, 0, 0) },
    })

    local arrow_max_scale = 2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_ARROW,
        {
            { 0, { arrow_max_scale * 0.7, arrow_max_scale } },
            { 1, { arrow_max_scale * 0.1, arrow_max_scale * 0.1 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local ARROW_MAX_LIFETIME = 0.6

local function emit_arrow_fn(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local lifetime = ARROW_MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = pos:Get()

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        0,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
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

    --SPARKLE
    effect:SetRenderResources(0, ARROW_TEXTURE, ADD_SHADER)
    effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 64)
    effect:SetMaxLifetime(0, ARROW_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_ARROW)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_ARROW)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetDragCoefficient(0, .14)
    effect:SetRotateOnVelocity(0, true)
    effect:SetAcceleration(0, 0, -0.3, 0)
    -- effect:SetSortOrder(0, 0)
    -- effect:SetSortOffset(0, 2)

    -----------------------------------------------------

    local sphere_emitter = Icey2Math.CustomSphereEmitter(
        1, 1,
        0, 90 * DEGREES,
        -60 * DEGREES, 60 * DEGREES
    )

    inst.delay = 3 * FRAMES
    inst.emitted = false

    EmitterManager:AddEmitter(inst, nil, function()
        if inst.emitted then
            return
        end

        local parent = inst.entity:GetParent()

        if parent then
            if inst.delay > 0 then
                inst.delay = inst.delay - FRAMES
                return
            end

            for i = 1, 12 do
                local x, y, z = sphere_emitter()

                local axis_x = Icey2Basic.GetFaceVector(parent)
                local axis_y = Vector3(0, 1, 0)
                local axis_z = axis_y:Cross(axis_x):GetNormalized()

                local base = (axis_x * x + axis_y * y + axis_z * z):GetNormalized()
                local pos = base * 0.1
                local velocity = base * GetRandomMinMax(0.3, 0.4)

                emit_arrow_fn(effect, pos, velocity)
            end
            inst.emitted = true
        end
    end)

    return inst
end



local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("deer_fire_charge")
    inst.AnimState:SetBuild("deer_fire_charge")
    inst.AnimState:PlayAnimation("blast")

    inst.AnimState:HideSymbol("glow_")
    inst.AnimState:HideSymbol("fire_puff_fx")

    inst.AnimState:SetLightOverride(1)

    -- local c = 0.5
    -- inst.AnimState:SetAddColour(c, c, 0, 1)
    -- inst.AnimState:SetMultColour(1, 1, 0, 1)
    inst.AnimState:SetAddColour(255 / 255, 253 / 255, 245 / 255, 1)


    local s = 0.5
    inst.Transform:SetScale(s, s, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.vfx1 = inst:SpawnChild("icey2_chainsaw_hit_vfx")
    inst.vfx2 = inst:SpawnChild("icey2_focus_hit_vfx_yellow")

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

-- ThePlayer:SpawnChild("icey2_chainsaw_hit_vfx")
-- c_spawn("icey2_chainsaw_hit_fx")
return Prefab("icey2_chainsaw_hit_vfx", vfxfn, assets),
    Prefab("icey2_chainsaw_hit_fx", fxfn, assets)
