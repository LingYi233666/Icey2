local SPARKLE_TEXTURE = "fx/sparkle.tex"
local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local ARROW_TEXTURE = "fx/spark.tex"
local EMBER_TEXTURE = "fx/snow.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE_RED = "icey2_fire_explode_fx_colourenvelope_smoke_red"
local COLOUR_ENVELOPE_NAME_SMOKE_YELLOW = "icey2_fire_explode_fx_colourenvelope_smoke_yellow"
local COLOUR_ENVELOPE_NAME_SMOKE_BLUE = "icey2_fire_explode_fx_colourenvelope_smoke_blue"
local COLOUR_ENVELOPE_NAME_SMOKE_WHITE = "icey2_fire_explode_fx_colourenvelope_smoke_white"

local SCALE_ENVELOPE_NAME_SMOKE_1 = "icey2_fire_explode_fx_scaleenvelope_smoke_1"
local SCALE_ENVELOPE_NAME_SMOKE_2 = "icey2_fire_explode_fx_scaleenvelope_smoke_2"
local SCALE_ENVELOPE_NAME_SMOKE_3 = "icey2_fire_explode_fx_scaleenvelope_smoke_3"
local SCALE_ENVELOPE_NAME_SMOKE_4 = "icey2_fire_explode_fx_scaleenvelope_smoke_4"


local assets =
{
    Asset("ANIM", "anim/lavaarena_firebomb.zip"),

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
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_YELLOW, {
        { 0,  IntColour(255, 240, 0, 0) },
        { .2, IntColour(255, 253, 0, 200) },
        { .3, IntColour(200, 255, 0, 110) },
        { .6, IntColour(230, 245, 0, 180) },
        { .9, IntColour(255, 240, 0, 100) },
        { 1,  IntColour(255, 240, 0, 0) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_RED, {
        { 0,  IntColour(255, 0, 0, 0) },
        { .2, IntColour(255, 0, 0, 240) },
        { .3, IntColour(200, 0, 0, 180) },
        { .6, IntColour(230, 0, 0, 150) },
        { .9, IntColour(255, 0, 0, 110) },
        { 1,  IntColour(255, 0, 0, 0) },
    })

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



    local scale_factor = 1.2
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_1,
        {
            { 0,   { scale_factor * 0.07, scale_factor } },
            { 0.2, { scale_factor * 0.07, scale_factor } },
            { 1,   { scale_factor * .005, scale_factor * 0.6 } },
        }
    )


    scale_factor = 1
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_2,
        {
            { 0,   { scale_factor * 0.07, scale_factor } },
            { 0.2, { scale_factor * 0.07, scale_factor } },
            { 1,   { scale_factor * .01, scale_factor * 0.6 } },
        }
    )

    scale_factor = 1
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_3,
        {
            { 0,   { scale_factor * 0.07, scale_factor } },
            { 0.2, { scale_factor * 0.07, scale_factor } },
            { 1,   { scale_factor * .005, scale_factor * 0.6 } },
        }
    )


    scale_factor = 0.6
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_4,
        {
            { 0,   { scale_factor * 0.07, scale_factor } },
            { 0.2, { scale_factor * 0.07, scale_factor } },
            { 1,   { scale_factor * .01, scale_factor * 0.6 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

local MAX_LIFETIME = 0.6

local function emit_line_thin(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local px, py, pz = pos:Get()
    local lifetime = (MAX_LIFETIME * (.6 + UnitRand() * .4))

    effect:AddParticle(
        0,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function emit_line(effect, pos, velocity)
    local vx, vy, vz = velocity:Get()
    local px, py, pz = pos:Get()
    local lifetime = (MAX_LIFETIME * (.6 + UnitRand() * .4))

    effect:AddParticle(
        1,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function common_vfx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

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
    effect:InitEmitters(2)

    -- vERY thin yellow line in the flame middle
    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(0, true)
    effect:SetMaxNumParticles(0, 8)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE_YELLOW)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE_2)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(0, true)
    effect:SetRadius(0, 1)
    effect:SetSortOffset(0, 1)

    -- Thin red line of the flame
    effect:SetRenderResources(1, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(1, true)
    effect:SetMaxNumParticles(1, 8)
    effect:SetMaxLifetime(1, MAX_LIFETIME)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE_RED)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE_1)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    effect:EnableBloomPass(1, true)
    effect:SetRadius(1, 1)
    effect:SetSortOffset(1, 0)



    return inst
end

local function explode_vfx_fn()
    local inst = common_vfx_fn()

    if TheNet:IsDedicated() then
        return inst
    end


    local effect = inst.VFXEffect

    -----------------------------------------------------
    local norm_sphere_emitter = CreateSphereEmitter(1)
    local remain_time = FRAMES * 3
    EmitterManager:AddEmitter(inst, nil, function()
        if remain_time > 0 then
            for i = 1, 8 do
                local velocity = Vector3(norm_sphere_emitter()) * 0.3
                velocity.y = math.abs(velocity.y)
                -- local pos = Vector3(line_sphere_emitter())
                local pos = velocity:GetNormalized() * 0.66
                emit_line_thin(effect, pos, velocity)
                emit_line(effect, pos, velocity)
            end
            remain_time = remain_time - FRAMES
        end
    end)

    return inst
end


local function explode_blue_vfx_fn()
    local inst = common_vfx_fn()


    inst._can_emit = net_bool(inst.GUID, "inst._can_emit")
    inst._can_emit:set(false)

    if TheNet:IsDedicated() then
        return inst
    end

    local effect = inst.VFXEffect

    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE_WHITE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE_4)
    effect:SetBlendMode(0, BLENDMODE.AlphaAdditive)
    effect:SetMaxNumParticles(0, 16)
    effect:SetSortOrder(0, 2)

    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE_BLUE)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE_3)
    effect:SetBlendMode(1, BLENDMODE.AlphaAdditive)
    effect:SetMaxNumParticles(0, 16)
    effect:SetSortOrder(1, 2)

    -----------------------------------------------------
    local norm_sphere_emitter = CreateSphereEmitter(1)
    local num_to_emit = 1
    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if parent and inst._can_emit:value() and num_to_emit > 0 then
            for i = 1, 8 do
                local velocity = Vector3(norm_sphere_emitter()) * 0.1
                -- velocity.y = math.abs(velocity.y)
                -- local pos = Vector3(line_sphere_emitter())
                local pos = velocity:GetNormalized() * 0.66
                emit_line_thin(effect, pos, velocity)
                emit_line(effect, pos, velocity)
            end
            num_to_emit = num_to_emit - 1
        end
    end)


    return inst
end

local function explode_fx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("lavaarena_firebomb")
    inst.AnimState:SetBuild("lavaarena_firebomb")
    inst.AnimState:PlayAnimation("used")

    inst.AnimState:SetLightOverride(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.vfx = inst:SpawnChild("icey2_fire_explode_vfx")


    inst:ListenForEvent("animover", inst.Remove)

    return inst
end



return Prefab("icey2_fire_explode_vfx", explode_vfx_fn, assets),
    Prefab("icey2_blue_fire_explode_vfx", explode_blue_vfx_fn, assets),
    Prefab("icey2_fire_explode_fx", explode_fx_fn, assets)
