-- local SCYTHE_TEXTURE = resolvefilepath("fx/icey2_rolling_scythe.tex")
-- local SCYTHE_TEXTURE = resolvefilepath("fx/animsmoke.tex")

local SCYTHE_SIDE_TEXTURE = resolvefilepath("fx/icey2_rolling_scythe_side.tex")
local SCYTHE_UPDOWN_TEXTURE = resolvefilepath("fx/icey2_rolling_scythe_updown.tex")



local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "scythe_colourenvelope"
local SCALE_ENVELOPE_NAME = "scythe_scaleenvelope"

local assets =
{
    Asset("IMAGE", SCYTHE_SIDE_TEXTURE),
    Asset("IMAGE", SCYTHE_UPDOWN_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, {
        { 0, IntColour(255, 255, 255, 255) },
        { 1, IntColour(255, 255, 255, 255) },
    })

    local scythe_scale = 355 / 256
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0, { scythe_scale, scythe_scale } },
            { 1, { scythe_scale, scythe_scale } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------

local function GetFacing(inst)

end

--------------------------------------------------------------------------
local ROTATION_SPEED = 45
local MAX_LIFETIME = FRAMES * 360 / math.abs(ROTATION_SPEED)

local function emit_scythe_fn(effect, angle, angular_velocity)
    local lifetime = MAX_LIFETIME

    angle = angle or math.random() * 360

    effect:AddRotatingParticle(
        0,
        lifetime,               -- lifetime
        0, 0, 0,                -- position
        0, 0, 0,                -- velocity
        angle, angular_velocity -- angle, angular_velocity
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

    --SCYTHE
    -- effect:SetRenderResources(0, SCYTHE_SIDE_TEXTURE, ADD_SHADER)
    effect:SetRenderResources(0, SCYTHE_UPDOWN_TEXTURE, ADD_SHADER)

    effect:SetRotationStatus(0, true)
    -- effect:SetRotateOnVelocity(0, true)
    effect:SetMaxNumParticles(0, 1)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.AlphaAdditive)
    effect:EnableBloomPass(0, true)
    -- effect:SetSortOrder(0, 0)
    -- effect:SetSortOffset(0, 2)
    effect:SetFollowEmitter(0, true)
    effect:SetKillOnEntityDeath(0, true)

    inst.emitted = false
    inst.start_angle = math.random(360)

    -----------------------------------------------------

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if not parent then
            return
        end

        local facing = GetFacing(parent)

        -- local c_down = TheCamera:GetPitchDownVec():Normalize()
        -- local c_right = TheCamera:GetRightVec():Normalize()
        -- local c_up = c_down:Cross(c_right):Normalize()
        -- local angle = parent.Transform:GetRotation() * DEGREES

        -- inst.VFXEffect:SetSpawnVectors(0,
        --     math.cos(angle), 0, math.sin(angle),
        --     c_up.x, c_up.y, c_up.z
        -- )

        if facing == FACING_LEFT then

        end

        emit_scythe_fn(effect, inst.start_angle, -ROTATION_SPEED)
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

    inst.persists = false

    inst.vfx = inst:SpawnChild("icey2_rolling_scythe_vfx")


    inst:DoTaskInTime(9, inst.Remove)

    return inst
end

-- c_spawn("icey2_rolling_scythe_fx"):ForceFacePoint(ThePlayer:GetPosition())

return Prefab("icey2_rolling_scythe_vfx", vfxfn, assets),
    Prefab("icey2_rolling_scythe_fx", fxfn, assets)
