local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_SMOKE = "icey2_weapon_change_smoke_colourenvelope"
local SCALE_ENVELOPE_NAME_SMOKE = "icey2_weapon_change_smoke_scaleenvelope"

local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE, {
        -- { 0,  IntColour(12, 12, 12, 64) },
        -- { .2, IntColour(10, 10, 10, 240) },
        -- { .7, IntColour(9, 9, 9, 256) },
        -- { 1,  IntColour(6, 6, 6, 0) },

        { 0,  IntColour(200, 240, 240, 0) },
        { .2, IntColour(210, 240, 240, 150) },
        { .6, IntColour(210, 240, 240, 100) },
        { 1,  IntColour(200, 240, 240, 0) },
    })

    local smoke_max_scale = .4
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE,
        {
            { 0,   { smoke_max_scale * .2, smoke_max_scale * .2 } },
            { .40, { smoke_max_scale * .7, smoke_max_scale * .7 } },
            { .60, { smoke_max_scale * .8, smoke_max_scale * .8 } },
            { .75, { smoke_max_scale * .7, smoke_max_scale * .7 } },
            { 1,   { smoke_max_scale, smoke_max_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local SMOKE_MAX_LIFETIME = 1.1

local function emit_smoke_fn(effect, sphere_emitter)
    local vx, vy, vz = .01 * UnitRand(), .01 + .02 * UnitRand(), .01 * UnitRand()
    local lifetime = SMOKE_MAX_LIFETIME * (.9 + UnitRand() * .1)
    local px, py, pz = sphere_emitter()

    effect:AddRotatingParticle(
        0,
        lifetime,            -- lifetime
        px, py, pz,          -- position
        vx, vy, vz,          -- velocity
        math.random() * 360, --* TWOPI, -- angle
        UnitRand() * 2       -- angle velocity
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

    --SMOKE
    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER) --REVEAL_SHADER --particle_add
    effect:SetMaxNumParticles(0, 64)
    effect:SetRotationStatus(0, true)
    effect:SetMaxLifetime(0, SMOKE_MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended) --AlphaBlended Premultiplied



    -----------------------------------------------------

    local sphere_emitter = CreateSphereEmitter(.1)
    inst.num_to_emit = 1

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        local facing = parent and parent.AnimState and parent.AnimState:GetCurrentFacing()
        -- if facing == FACING_DOWN or facing == FACING_DOWNLEFT or facing == FACING_DOWNRIGHT then
        --     effect:SetSortOrder(0, 1)
        --     effect:SetSortOffset(0, 1)
        -- else
        --     effect:SetSortOrder(0, 0)
        --     effect:SetSortOffset(0, 0)
        -- end

        if facing == FACING_UP or facing == FACING_UPLEFT or facing == FACING_UPRIGHT then
            effect:SetSortOrder(0, 0)
            effect:SetSortOffset(0, 0)
        else
            effect:SetSortOrder(0, 1)
            effect:SetSortOffset(0, 1)
        end


        -- for i = 1, 4 do
        -- end
        inst.num_to_emit = inst.num_to_emit + 0.2
        while inst.num_to_emit >= 1 do
            emit_smoke_fn(effect, sphere_emitter)

            inst.num_to_emit = inst.num_to_emit - 1
        end
    end)

    return inst
end

return Prefab("icey2_weapon_change_vfx", fn, assets)
