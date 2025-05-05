local SHARD_TEXTURE = resolvefilepath("fx/icey2_shard.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local COLOUR_ENVELOPE_NAME = "icey2_shield_break_shard_vfx_colourenvelope"
local SCALE_ENVELOPE_NAME = "icey2_shield_break_shard_vfx_scaleenvelope"

local assets =
{
    Asset("IMAGE", SHARD_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    -- local envs = {}
    -- local t = 0
    -- local step = .15
    -- while t + step + .01 < 1 do
    --     table.insert(envs, { t, IntColour(255, 255, 150, 255) })
    --     t = t + step
    --     table.insert(envs, { t, IntColour(255, 255, 150, 0) })
    --     t = t + .01
    -- end
    -- table.insert(envs, { 1, IntColour(255, 255, 150, 0) })




    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, {
        { 0,   IntColour(96, 255, 249, 255) },
        { 0.8, IntColour(96, 255, 249, 255) },
        { 1,   IntColour(96, 255, 249, 0) },
    })

    local shard_max_scale = 3
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME,
        {
            { 0, { shard_max_scale, shard_max_scale } },
            { 1, { shard_max_scale * .5, shard_max_scale * .5 } },
        }
    )

    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME = 1

local function emit_shard_fn(effect, pos, vel)
    local lifetime = MAX_LIFETIME * (.7 + UnitRand() * .3)
    local px, py, pz = pos:Get()
    local vx, vy, vz = vel:Get()
    -- (pos:GetNormalized() * GetRandomMinMax(0.1, 0.2)):Get()


    local angle = math.random() * 360
    local ang_vel = (UnitRand() - 1) * 5

    effect:AddRotatingParticle(
        0,
        lifetime,      -- lifetime
        px, py, pz,    -- position
        vx, vy, vz,    -- velocity
        angle, ang_vel -- angle, angular_velocity
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

    --SHARD
    effect:SetRenderResources(0, SHARD_TEXTURE, ADD_SHADER)
    effect:SetRotationStatus(0, true)
    effect:SetMaxNumParticles(0, 16)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    effect:SetSortOrder(0, 1)
    effect:SetSortOffset(0, 1)
    -- effect:SetGroundPhysics(0, true)
    effect:SetAcceleration(0, 0, -0.3, 0)

    -----------------------------------------------------



    -- local sphere_emitter = CreateSphereEmitter(.25)
    local theta = 120 * DEGREES
    local phi = 75 * DEGREES
    local sphere_emitter = Icey2Math.CustomSphereEmitter(0.1, 0.3, 0, theta, -phi, phi)

    inst.emitted = false

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()
        if not parent then
            return
        end

        if inst.emitted then
            return
        end


        local time_alive = inst:GetTimeAlive()
        if time_alive > 1 * FRAMES and time_alive < 3 * FRAMES then
            local facing = parent.AnimState:GetCurrentFacing()

            local axis_x = Icey2Basic.GetFaceVector(parent)
            local axis_y = Vector3(0, 1, 0)
            local axis_z = axis_y:Cross(axis_x)

            for i = 1, 16 do
                local x, y, z = sphere_emitter()
                local pos = axis_x * x + axis_y * y + axis_z * z
                local vel = pos:GetNormalized() * GetRandomMinMax(0.1, 0.2)

                if facing == FACING_DOWN then
                    pos.y = pos.y + 1
                elseif facing == FACING_LEFT or facing == FACING_RIGHT then
                    pos.y = pos.y + 0.7
                    pos = pos + axis_x * 0.6
                else
                    pos.y = pos.y + 0.33
                    pos = pos + axis_x
                end

                emit_shard_fn(effect, pos, vel)

                inst.emitted = true
            end
        end
    end)

    return inst
end

local function create_blast_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("deer_ice_charge")
    inst.AnimState:SetBuild("deer_ice_charge")
    inst.AnimState:PlayAnimation("blast")
    inst.AnimState:SetLightOverride(1)

    local s = 0.67
    inst.AnimState:SetScale(s, s, s)


    inst:ListenForEvent("animover", inst.Remove)

    return inst
end


local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("FX")


    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(0, function()
            local parent = inst.entity:GetParent()
            if not parent then
                return
            end


            local fx = create_blast_fn()
            parent:AddChild(fx)

            local facing = parent.AnimState:GetCurrentFacing()
            if facing == FACING_DOWN then
                fx.Transform:SetPosition(0, 1, 0)
            elseif facing == FACING_LEFT or facing == FACING_RIGHT then
                fx.Transform:SetPosition(0.6, 0.7, 0)
            else
                fx.Transform:SetPosition(1, 0.33, 0)
            end
        end)
    end

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst:DoTaskInTime(FRAMES * 3, inst.Remove)

    return inst
end

return Prefab("icey2_shield_break_shard_vfx", fn, assets),
    Prefab("icey2_shield_break_fx", fxfn, assets)
