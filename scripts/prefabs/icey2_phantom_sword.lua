local SPARKLE_TEXTURE = "fx/sparkle.tex"
local ARROW_TEXTURE = resolvefilepath("fx/icey2_spark_inverse.tex")
local SWORD_TEXTURE = resolvefilepath("fx/icey2_phantom_sword.tex")

local ADD_SHADER = "shaders/vfx_particle_add.ksh"

local SWORD_COLOUR_ENVELOPE_NAME = "icey2_phantom_sword_vfx_sword_colourenvelope"
local SWORD_SCALE_ENVELOPE_NAME = "icey2_phantom_sword_vfx_sword_scaleenvelope"

local ARROW_COLOUR_ENVELOPE_NAME = "icey2_phantom_sword_vfx_arrow_colourenvelope"
local ARROW_SCALE_ENVELOPE_NAME = "icey2_phantom_sword_vfx_arrow_scaleenvelope"

local SPARKLE_COLOUR_ENVELOPE_NAME = "icey2_phantom_sword_vfx_sparkle_colourenvelope"
local SPARKLE_SCALE_ENVELOPE_NAME = "icey2_phantom_sword_vfx_sparkle_scaleenvelope"


local assets =
{
    Asset("IMAGE", SPARKLE_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("IMAGE", SWORD_TEXTURE),
    Asset("SHADER", ADD_SHADER),
}


local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        SWORD_COLOUR_ENVELOPE_NAME,
        {
            { 0, IntColour(0, 255, 247, 180) },
            { 1, IntColour(0, 255, 247, 180) },
        }
    )

    EnvelopeManager:AddColourEnvelope(
        ARROW_COLOUR_ENVELOPE_NAME,
        {
            { 0,  IntColour(123, 245, 247, 180) },
            { .2, IntColour(147, 245, 247, 255) },
            { .8, IntColour(123, 245, 247, 175) },
            { 1,  IntColour(0, 0, 0, 0) },
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


    local sword_max_scale = 1.3
    EnvelopeManager:AddVector2Envelope(
        SWORD_SCALE_ENVELOPE_NAME,
        {
            { 0, { sword_max_scale * 0.7, sword_max_scale } },
            { 1, { sword_max_scale * 0.7, sword_max_scale } },
        }
    )

    local arrow_max_scale = 1
    EnvelopeManager:AddVector2Envelope(
        ARROW_SCALE_ENVELOPE_NAME,
        {
            { 0, { arrow_max_scale * 0.4, arrow_max_scale * 2.5 } },
            -- { 0.6,    { arrow_max_scale * 0.05 , arrow_max_scale * 1.5} },
            { 1, { arrow_max_scale * 0.1, arrow_max_scale * 2.5 } },
        }
    )


    local sparkle_max_scale = 0.44
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

local SWORD_MAX_LIFETIME = 1
local ARROW_MAX_LIFETIME = 0.2
local SPARKLE_MAX_LIFETIME = 0.1

local function emit_sword_fn(effect, velocity)
    local lifetime = SWORD_MAX_LIFETIME
    local px, py, pz = 0, 0, 0
    local vx, vy, vz = velocity:Get()

    effect:AddParticle(
        0,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function emit_arrow_fn(effect, velocity)
    local lifetime = ARROW_MAX_LIFETIME * GetRandomMinMax(0.7, 1)
    local px, py, pz = 0, 0, 0
    local vx, vy, vz = velocity:Get()

    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        1,
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

    inst._vx = net_float(inst.GUID, "inst._vx")
    inst._vy = net_float(inst.GUID, "inst._vy")
    inst._vz = net_float(inst.GUID, "inst._vz")

    inst.SetEmitVelocity = function(inst, x, y, z)
        inst._vx:set(x)
        inst._vy:set(y)
        inst._vz:set(z)
    end

    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return inst
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(2)

    --SWORD
    effect:SetRenderResources(0, SWORD_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(0, 1)
    effect:SetMaxLifetime(0, SWORD_MAX_LIFETIME)
    effect:SetColourEnvelope(0, SWORD_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SWORD_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:EnableBloomPass(0, true)
    -- effect:SetUVFrameSize(0, 0.25, 1)
    -- effect:SetSortOrder(0, 1)
    effect:SetSortOffset(0, 1)
    effect:SetDragCoefficient(0, 9999)
    effect:SetRotateOnVelocity(0, true)

    --ARROW
    effect:SetRenderResources(1, ARROW_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(1, 128)
    effect:SetMaxLifetime(1, ARROW_MAX_LIFETIME)
    effect:SetColourEnvelope(1, ARROW_COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(1, ARROW_SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(1, BLENDMODE.Additive)
    effect:EnableBloomPass(1, true)
    effect:SetUVFrameSize(1, 0.25, 1)
    -- effect:SetSortOrder(1, 1)
    effect:SetSortOffset(1, 1)
    effect:SetDragCoefficient(1, 0.05)
    effect:SetRotateOnVelocity(1, true)

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()

        if parent and parent.Physics then
            -- local velocity = Vector3(parent.Physics:GetVelocity())
            -- local velocity = Vector3(parent.Physics:GetMotorVel())
            local velocity = Vector3(inst._vx:value(), inst._vy:value(), inst._vz:value())

            if velocity:Length() > 0 then
                effect:ClearAllParticles(0)
                emit_sword_fn(effect, velocity:GetNormalized() * 0.1)
                emit_arrow_fn(effect, velocity:GetNormalized() * -0.1)
                -- for i = 1, math.random(2) do
                --     emit_sparkle_fn(effect, sphere_emitter, velocity:GetNormalized() * -0.02)
                -- end
            end
        end
    end)

    return inst
end

------------------------------------------------------------------------------

local function OnProjectileHit(inst, attacker, target)
    local s = 0.5
    local fx = SpawnAt("icey2_phantom_sword_hitfx", inst, { s, s, s })
    fx:SetEmitDirection(inst.direction)
    fx.SoundEmitter:PlaySound("icey2_sfx/skill/phantom_sword/hit3")


    if attacker and attacker:IsValid() and target then
        -- local x, y, z = inst:GetPosition():Get()
        -- local ents = TheSim:FindEntities(x, y, z, 1.5, { "_combat", "_health" }, { "INLIMBO" })
        -- if target then
        --     table.insert(ents, target)
        -- end

        -- for k, v in pairs(ents) do
        --     if attacker.components.combat:CanTarget(v) and not attacker.components.combat:IsAlly(v) then
        --         -- targ, weapon, projectile, stimuli, instancemult, instrangeoverride, instpos
        --         attacker.components.combat:DoAttack(v, inst, inst, nil, nil, 99999, inst:GetPosition())
        --     end
        -- end
        -- if target then
        --     attacker.components.combat:DoAttack(target, inst, inst, nil, nil, 99999, inst:GetPosition())
        -- end
        local spdamage = {
            icey2_spdamage_force = Icey2Math.SumDices(1, 4) + 1,
        }
        target.components.combat:GetAttacked(attacker, 0, inst, nil, spdamage)
    end

    inst:Remove()
end

local function OnProjectileLaunch(inst, attacker, target_pos)
    if inst.direction == nil then
        inst.direction = Vector3FromTheta(math.random() * 2 * PI)
        inst.direction.y = GetRandomMinMax(3, 6)
    end
    inst.direction:Normalize()

    inst.offset = nil
    inst.target_pos = target_pos
    inst.start_launch_time = GetTime()
end



local offset_presets = {
    -- rad_min, rad_max, height_min, height_max
    deerclops = { nil, 2, nil, 8 },
    bearger = { nil, 2, nil, 8 },
    moose = { nil, 2, nil, 8 },
    dragonfly = { nil, 2, 4, 8 },
}

local function SetVel(inst, vx, vy, vz)
    -- local x, y, z = inst.Transform:GetWorldPosition()
    -- local px, py, pz = x + vx, y + vy, z + vz

    -- inst:ForceFacePoint(px, py, pz)

    -- local vx1, vy1, vz1 = inst.entity:WorldToLocalSpace(px, py, pz)

    -- inst.Physics:SetMotorVel(vx1, vy1, vz1)

    inst.vfx:SetEmitVelocity(vx, vy, vz)
    inst.Physics:SetVel(vx, vy, vz)
end

local function OnUpdate(inst)
    if inst.target and inst.target:IsValid() then
        if inst.offset == nil then
            -- local physics_rad = inst.target:GetPhysicsRadius(0.5)
            -- local height = inst.target.Physics and inst.target.Physics:GetHeight() or 0.5


            -- -- local random_vec3 = Vector3(GetRandomMinMax(-99999, 99999), GetRandomMinMax(0, 99999),
            -- --                             GetRandomMinMax(-99999, 99999)):GetNormalized()
            -- if inst.target:HasTag("smallcreature") then
            --     physics_rad = 0.5
            --     height = 0.5
            -- elseif inst.target:HasTag("character") then
            --     physics_rad = 1
            --     height = 1
            -- elseif inst.target:HasTag("largecreature") then
            --     if inst.target:HasTag("epic") then
            --         physics_rad = 2
            --         height = 7
            --     else
            --         physics_rad = 2
            --         height = 1.5
            --     end
            -- end

            local rad_min = 0
            local rad_max = inst.target:GetPhysicsRadius(0.5)
            local height_min = 0
            local height_max = inst.target.Physics and inst.target.Physics:GetHeight() or 0.5

            if offset_presets[inst.target.prefab] then
                rad_min = offset_presets[inst.target.prefab][1] or rad_min
                rad_max = offset_presets[inst.target.prefab][2] or rad_max
                height_min = offset_presets[inst.target.prefab][3] or height_min
                height_max = offset_presets[inst.target.prefab][4] or height_max
            else
                if inst.target:HasTag("smallcreature") then
                    rad_max = 0.5
                    height_max = 0.5
                elseif inst.target:HasTag("character") then
                    rad_max = 1
                    height_max = 1.5
                elseif inst.target:HasTag("largecreature") then
                    rad_max = 2
                    height_max = 1.5
                end

                if inst.target:HasTag("flying") then
                    height_min = height_min + 1.5
                    height_max = height_max + 1.5
                end
            end

            inst.offset = Vector3FromTheta(math.random() * PI2, GetRandomMinMax(rad_min, rad_max))
            inst.offset.y = GetRandomMinMax(height_min, height_max)
        end
        inst.target_pos = inst.target:GetPosition() + inst.offset
    end

    if GetTime() - inst.start_launch_time < 0.2 then
        local speed = inst.components.complexprojectile.horizontalSpeed

        local vx, vy, vz = (inst.direction * speed):Get()
        -- inst.vfx:SetEmitVelocity(vx, vy, vz)
        -- inst.Physics:SetVel(vx, vy, vz)
        SetVel(inst, vx, vy, vz)
        return true
    end

    local towards = inst.target_pos - inst:GetPosition()

    local delta_vec = towards:GetNormalized() - inst.direction

    local max_delta_length = 5 * FRAMES
    if delta_vec:Length() < max_delta_length or inst.locked then
        inst.locked = true
        inst.direction = towards:GetNormalized()
    else
        inst.direction = inst.direction + delta_vec:GetNormalized() * max_delta_length
    end

    local cut_angle = Icey2Math.RadiansBetweenVectors(inst.direction, towards) * RADIANS
    local is_inverse_moving = math.abs(cut_angle) > 90


    local speed = inst.components.complexprojectile.horizontalSpeed


    local vx, vy, vz = (inst.direction * speed):Get()
    -- inst.vfx:SetEmitVelocity(vx, vy, vz)
    -- inst.Physics:SetVel(vx, vy, vz)
    SetVel(inst, vx, vy, vz)

    if is_inverse_moving then
        speed = speed - FRAMES * 10
    else
        speed = speed + FRAMES * 30
    end

    speed = math.clamp(speed, 10, 60)
    inst.components.complexprojectile:SetHorizontalSpeed(speed)


    local attacker = inst.components.complexprojectile.attacker
    if attacker
        and attacker:IsValid()
        and attacker.components.combat
        and attacker.components.combat:CanTarget(inst.target) then
        if (inst:GetPosition() - inst.target:GetPosition()):Length() < 1 or towards:Length() < 1 then
            inst.components.complexprojectile:Hit(inst.target)
        end
    else
        inst.components.complexprojectile:Hit()
    end

    return true
end

local function projectilefn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    -- inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeProjectilePhysics(inst)

    -- inst.AnimState:SetBank("metal_hulk_projectile")
    -- inst.AnimState:SetBuild("metal_hulk_projectile")
    -- inst.AnimState:PlayAnimation("spin_loop", true)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetOnHit(OnProjectileHit)
    inst.components.complexprojectile:SetOnLaunch(OnProjectileLaunch)
    inst.components.complexprojectile:SetHorizontalSpeed(40)
    inst.components.complexprojectile:SetOnUpdate(OnUpdate)

    inst.Launch = function(inst, attacker, target)
        inst.target = target
        inst.components.complexprojectile:Launch(target:GetPosition(), attacker)
    end

    inst.vfx = inst:SpawnChild("icey2_phantom_sword_vfx")

    return inst
end

------------------------------------------------------------------------------



-- c_spawn("icey2_phantom_sword"):Launch(ThePlayer,c_select())
return Prefab("icey2_phantom_sword", projectilefn, assets),
    Prefab("icey2_phantom_sword_vfx", vfxfn, assets)
