local MUZZLE_TEXTURE = resolvefilepath("fx/icey2_muzzles.tex")
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_FLAME = "icey2_pact_weapon_gunlance_openfire_vfx_flame_colourenvelope"
local COLOUR_ENVELOPE_NAME_SMOKE = "icey2_pact_weapon_gunlance_openfire_vfx_smoke_colourenvelope"

local SCALE_ENVELOPE_NAME_FLAME = "icey2_pact_weapon_gunlance_openfire_vfx_flame_scaleenvelope"
local SCALE_ENVELOPE_NAME_SMOKE = "icey2_pact_weapon_gunlance_openfire_vfx_smoke_scaleenvelope"

local assets =
{
    Asset("ANIM", "anim/icey2_advance_height_controler.zip"),

    Asset("IMAGE", MUZZLE_TEXTURE),
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_FLAME,
        {
            -- { 0,   IntColour(255, 255, 255, 200) },
            -- { 0.3, IntColour(255, 255, 255, 255) },
            -- { 1,   IntColour(255, 255, 255, 0) },

            { 0,   IntColour(0, 100, 200, 150) },
            { 0.3, IntColour(0, 100, 200, 200) },
            { 1,   IntColour(0, 100, 200, 0) },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME_SMOKE,
        {
            { 0,   IntColour(0, 100, 200, 100) },
            { 0.3, IntColour(0, 100, 200, 150) },
            { 1,   IntColour(0, 100, 200, 0) },
        }
    )

    local flame_max_scale = 0.8
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_FLAME,
        {
            -- { 0,   { flame_max_scale * 0.9, flame_max_scale * 2.5 } },
            -- { 0.4, { flame_max_scale, flame_max_scale * 3 } },
            -- { 1,   { flame_max_scale, flame_max_scale * 2.5 } },

            { 0,   { flame_max_scale * 0.1, flame_max_scale * 0.4 } },
            { 0.2, { flame_max_scale * 0.1, flame_max_scale } },
            { 1,   { flame_max_scale * .05, flame_max_scale * 0.6 } },
        }
    )


    local smoke_max_scale = 0.3
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0,   { smoke_max_scale, smoke_max_scale * 1 } },
            { 0.4, { smoke_max_scale, smoke_max_scale * 1 } },
            { 1,   { smoke_max_scale * 0.6, smoke_max_scale * 0.6 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME_FLAME = 0.8
local MAX_LIFETIME_SMOKE = 1

local function emit_flame_fn(effect, pos)
    local lifetime = MAX_LIFETIME_FLAME * (.7 + UnitRand() * .3)
    local px, py, pz = pos:Get()
    local vx, vy, vz = (pos:GetNormalized() * 0.1):Get()

    effect:AddParticle(
        0,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end


local function emit_smoke_fn(effect, sphere_emitter)
    local lifetime = MAX_LIFETIME_SMOKE * (.7 + UnitRand() * .3)
    local px, py, pz = sphere_emitter()
    local vx, vy, vz = (Vector3(px, py, pz):GetNormalized() * 0.03):Get()
    local angle = math.random() * 360
    local angular_velocity = UnitRand() * 5

    effect:AddRotatingParticle(
        1,
        lifetime,               -- lifetime
        px, py, pz,             -- position
        vx, vy, vz,             -- velocity
        angle, angular_velocity -- angle, angular_velocity
    )
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    -- inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.entity:SetPristine()

    inst._can_emit = net_bool(inst.GUID, "inst._can_emit")

    inst.persists = false

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    -- effect:SetRotationStatus(0, true)
    effect:SetRotateOnVelocity(0, true)
    effect:SetMaxNumParticles(0, 64)
    effect:SetMaxLifetime(0, MAX_LIFETIME_FLAME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_FLAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_FLAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaAdditive)
    effect:EnableBloomPass(0, true)
    effect:SetRadius(0, 1)
    effect:SetSortOrder(0, 0)
    effect:SetSortOffset(0, 1)
    -- effect:SetDragCoefficient(0, 0.01)

    effect:SetRenderResources(1, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotationStatus(1, true)
    effect:SetMaxNumParticles(1, 64)
    effect:SetMaxLifetime(1, MAX_LIFETIME_SMOKE)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(1, BLENDMODE.AlphaAdditive)
    effect:EnableBloomPass(1, true)
    effect:SetSortOrder(1, 1)
    effect:SetSortOffset(1, 1)

    local sphere_emitter_flame = Icey2Math.CustomSphereEmitter(
        0.7,
        0.8,
        60 * DEGREES,
        120 * DEGREES,
        -90 * DEGREES,
        90 * DEGREES
    )
    local sphere_emitter_smoke = CreateSphereEmitter(0.2)

    local num_to_emit = 2
    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if parent and inst._can_emit:value() and num_to_emit > 0 then
            local face_vector = Icey2Basic.GetFaceVector(parent)
            local y_vector = Vector3(0, 1, 0)
            local z_vector = face_vector:Cross(y_vector)


            for i = 1, math.random(4, 5) do
                local x, y, z = sphere_emitter_flame()
                local pos = face_vector * x + y_vector * y + z_vector * z

                emit_flame_fn(effect, pos)
            end

            for i = 1, math.random(6, 7) do
                emit_smoke_fn(effect, sphere_emitter_smoke)
            end

            num_to_emit = num_to_emit - 1
        end
    end)

    -- inst:DoTaskInTime(0, function()
    --     inst.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_gunlance/shot3")
    -- end)


    return inst
end


local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.Transform:SetEightFaced()

    inst.AnimState:SetBank("icey2_advance_height_controler")
    inst.AnimState:SetBuild("icey2_advance_height_controler")
    inst.AnimState:PlayAnimation("mult_face")
    inst.AnimState:SetSymbolMultColour("swap_object", 0, 0, 0, 0)

    inst.AnimState:SetSortOrder(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst.persists = false

    inst.Emit = function(inst)
        inst.vfx = inst:SpawnChild("icey2_pact_weapon_gunlance_openfire_vfx")
        inst.vfx.entity:AddFollower()
        inst.vfx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -60, 0)
        inst.vfx._can_emit:set(true)
    end

    inst:DoTaskInTime(1, inst.Remove)

    return inst
end

-- ThePlayer:SpawnChild("icey2_pact_weapon_gunlance_openfire_vfx")
return Prefab("icey2_pact_weapon_gunlance_openfire_vfx", fn, assets),
    Prefab("icey2_pact_weapon_gunlance_openfire_fx", fxfn, assets)
