local MUZZLE_TEXTURE = resolvefilepath("fx/icey2_muzzles.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "icey2_melee_hit_vfx_colourenvelope"
local SCALE_ENVELOPE_NAME = "icey2_melee_hit_vfx_scaleenvelope"

local assets =
{
    Asset("IMAGE", MUZZLE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    local p1 = 0.4
    local p2 = 1 - p1

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,  IntColour(30, 220, 230, 200) },
            { p1, IntColour(30, 220, 230, 255) },
            { p2, IntColour(30, 220, 230, 255) },
            { 1,  IntColour(0, 210, 210, 200) },
        }
    )

    local muzzle_max_scale = 2.7
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0,  { muzzle_max_scale * 0.9, muzzle_max_scale * 3.7 } },
            { p1, { muzzle_max_scale, muzzle_max_scale * 3.9 } },
            { p2, { muzzle_max_scale, muzzle_max_scale * 3.9 } },
            { 1,  { muzzle_max_scale, muzzle_max_scale * 3.7 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 0.2

local function emit_muzzle_fn(effect, angle)
    local lifetime = MAX_LIFETIME * (.95 + UnitRand() * .05)
    local uv_offset = math.random(0, 2) * 0.25

    effect:AddRotatingParticleUV(
        0,
        lifetime,    -- lifetime
        0, 0, 0,     -- position
        0, 0, 0,     -- velocity
        angle, 0,    -- angle, angular_velocity
        uv_offset, 0 -- uv offset
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

    --MUZZLE
    effect:SetRenderResources(0, MUZZLE_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetUVFrameSize(0, 0.25, 1)
    effect:SetMaxNumParticles(0, 16)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 2)

    -----------------------------------------------------

    local num_to_emit = 1
    EmitterManager:AddEmitter(inst, nil, function()
        while num_to_emit > 0 do
            local angle = math.random() * 360
            local angle2 = 0
            if angle >= 180 then
                angle2 = angle - 180
            else
                angle2 = angle + 180
            end

            -- print(angle, angle2)

            emit_muzzle_fn(effect, angle)
            emit_muzzle_fn(effect, angle2)

            num_to_emit = num_to_emit - 1
        end
    end)

    inst:DoTaskInTime(1, inst.Remove)

    return inst
end
-- ThePlayer:SpawnChild("icey2_melee_hit_vfx")
return Prefab("icey2_melee_hit_vfx", fn, assets)
