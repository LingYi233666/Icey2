local ANIM_SMOKE_TEXTURE = "fx/animsmoke.tex"
local ARROW_TEXTURE = "fx/spark.tex"
local SMOKE_TEXTURE = "fx/smoke.tex"

local ADD_SHADER = "shaders/vfx_particle_add.ksh"
local REVEAL_SHADER = "shaders/vfx_particle_reveal.ksh"

local COLOUR_ENVELOPE_NAME_ARROW = "icey2_skull_tail_arrow_colourenvelope"
local SCALE_ENVELOPE_NAME_ARROW = "icey2_skull_tail_arrow_scaleenvelope"

local COLOUR_ENVELOPE_NAME_SMOKE_THIN = "icey2_skull_tail_smoke_thin_colourenvelope"
local SCALE_ENVELOPE_NAME_SMOKE_THIN = "icey2_skull_tail_smoke_thin_scaleenvelope"

local COLOUR_ENVELOPE_NAME_SMOKE_FAT = "icey2_skull_tail_smoke_fat_colourenvelope"
local SCALE_ENVELOPE_NAME_SMOKE_FAT = "icey2_skull_tail_smoke_fat_scaleenvelope"

local COLOUR_ENVELOPE_NAME_SMOKE_BALL = "icey2_skull_tail_smoke_ball_colourenvelope"
local SCALE_ENVELOPE_NAME_SMOKE_BALL = "icey2_skull_tail_smoke_ball_scaleenvelope"

local assets =
{
    Asset("IMAGE", ANIM_SMOKE_TEXTURE),
    Asset("IMAGE", ARROW_TEXTURE),
    Asset("IMAGE", SMOKE_TEXTURE),

    Asset("SHADER", ADD_SHADER),
    Asset("SHADER", REVEAL_SHADER),
}

--------------------------------------------------------------------------

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    -- EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_ARROW, {
    --     { 0,   IntColour(0, 148, 248, 0) },
    --     { 0.1, IntColour(0, 148, 248, 255) },
    --     { 0.8, IntColour(0, 148, 248, 255) },
    --     { 1,   IntColour(0, 148, 248, 0) },
    -- })

    -- local arrow_max_scale = 1
    -- EnvelopeManager:AddVector2Envelope(
    --     SCALE_ENVELOPE_NAME_ARROW,
    --     {
    --         { 0, { arrow_max_scale, arrow_max_scale } },
    --         { 1, { arrow_max_scale * .5, arrow_max_scale * .9 } },
    --     }
    -- )

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_THIN, {
        { 0, IntColour(0, 100, 200, 255) },
        -- { 0.05, IntColour(0, 148, 248, 255) },
        -- { 0.8, IntColour(0, 148, 248, 255) },
        { 1, IntColour(0, 100, 200, 255) },
    })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_FAT, {
        { 0,    IntColour(0, 100, 248, 0) },
        { 0.01, IntColour(0, 148, 248, 50) },
        -- { 0.8, IntColour(0, 148, 248, 255) },
        { 1,    IntColour(0, 100, 248, 0) },
    })


    -- EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_FAT, {
    --     { 0,    IntColour(255, 0, 0, 0) },
    --     { 0.01, IntColour(255, 0, 0, 100) },
    --     { 1,    IntColour(255, 0, 0, 0) },
    -- })

    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME_SMOKE_BALL, {
        { 0,    IntColour(200, 200, 200, 0) },
        { 0.01, IntColour(200, 200, 200, 200) },
        { 0.3,  IntColour(200, 200, 200, 200) },
        { 1,    IntColour(200, 200, 200, 0) },
    })


    local smoke_thin_max_scale = 0.3
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_THIN,
        {
            { 0, { smoke_thin_max_scale * 0.08, smoke_thin_max_scale } },
            { 1, { smoke_thin_max_scale * 0.03, smoke_thin_max_scale * .9 } },
        }
    )

    local smoke_fat_max_scale = 1
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_FAT,
        {
            { 0, { smoke_fat_max_scale * 0.11, smoke_fat_max_scale } },
            { 1, { smoke_fat_max_scale * 0.1, smoke_fat_max_scale * 0.9 } },
        }
    )

    local smoke_ball_max_scale = 0.4
    EnvelopeManager:AddVector2Envelope(
        SCALE_ENVELOPE_NAME_SMOKE_BALL,
        {
            { 0, { smoke_ball_max_scale, smoke_ball_max_scale } },
            { 1, { smoke_ball_max_scale * 0.5, smoke_ball_max_scale * 0.5 } },
        }
    )


    InitEnvelope = nil
    IntColour = nil
end

--------------------------------------------------------------------------
local MAX_LIFETIME_SMOKE_THIN = 3
local MAX_LIFETIME_SMOKE_FAT = 0.6
local MAX_LIFETIME_SMOKE_BALL = 0.5

local function emit_smoke_thin_fn(effect, pos, vel)
    local vx, vy, vz = vel:Get()
    local lifetime = MAX_LIFETIME_SMOKE_THIN * (.7 + UnitRand() * .3)
    local px, py, pz = pos:Get()

    effect:AddParticle(
        0,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function emit_smoke_fat_fn(effect, pos, vel)
    local vx, vy, vz = vel:Get()
    local lifetime = MAX_LIFETIME_SMOKE_FAT * (.7 + UnitRand() * .3)
    local px, py, pz = pos:Get()

    -- effect:AddParticle(
    --     1,
    --     lifetime,   -- lifetime
    --     px, py, pz, -- position
    --     vx, vy, vz  -- velocity
    -- )

    effect:AddParticle(
        0,
        lifetime,   -- lifetime
        px, py, pz, -- position
        vx, vy, vz  -- velocity
    )
end

local function emit_smoke_ball_fn(effect, pos, vel)
    local vx, vy, vz = vel:Get()
    local lifetime = MAX_LIFETIME_SMOKE_BALL * (.9 + UnitRand() * .1)
    local px, py, pz = pos:Get()
    local uv_offset = math.random(0, 3) * .25

    effect:AddParticleUV(
        2,
        lifetime,    -- lifetime
        px, py, pz,  -- position
        vx, vy, vz,  -- velocity
        uv_offset, 0 -- uv offset
    )
end


local function GetPosList(inst, parent)
    local pos_list = {}
    local sphere_emitter_thin = Icey2Math.CustomSphereEmitter(
        0.45,
        0.65,
        0 * DEGREES,
        180 * DEGREES,
        90 * DEGREES,
        (360 - 90) * DEGREES
    )
    local sphere_emitter_thin_small = Icey2Math.CustomSphereEmitter(
        0,
        0.45,
        0 * DEGREES,
        180 * DEGREES,
        90 * DEGREES,
        (360 - 90) * DEGREES
    )

    local facing = parent.AnimState:GetCurrentFacing()
    local face_vector = Icey2Basic.GetFaceVector(parent)

    if facing == FACING_UP then
        for i = 1, 128 do
            local pos = Vector3(sphere_emitter_thin()) - Vector3(0, 0.05, 0)
            table.insert(pos_list, pos)
        end
    elseif facing == FACING_UPLEFT or facing == FACING_UPRIGHT then
        for i = 1, 128 do
            local pos = Vector3(sphere_emitter_thin()) - Vector3(0, 0.07, 0)
            table.insert(pos_list, pos)
        end
    elseif facing == FACING_LEFT or facing == FACING_RIGHT then
        for i = 1, 128 do
            table.insert(pos_list, Vector3(sphere_emitter_thin()))
        end
    elseif facing == FACING_DOWNLEFT or facing == FACING_DOWNRIGHT then
        for i = 1, 128 do
            local pos = Vector3(sphere_emitter_thin()) - Vector3(0, 0.2, 0)
            table.insert(pos_list, pos)
        end
    elseif facing == FACING_DOWN then
        for i = 1, 128 do
            local pos = Vector3(sphere_emitter_thin()) - Vector3(0, 0.05, 0)
            table.insert(pos_list, pos)
        end
    end


    for k, pos in pairs(pos_list) do
        local x, y, z = pos:Get()
        z = 120 * z / 180
        local axis_y = Vector3(0, 1, 0)
        local axis_z = face_vector:Cross(axis_y):GetNormalized()

        local pos_calib = face_vector * x + axis_y * y + axis_z * z
        pos_calib = pos_calib - face_vector * 0.3

        pos_list[k] = pos_calib
    end


    return pos_list
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
    effect:InitEmitters(3)

    -- Thin smoke
    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, ADD_SHADER)
    effect:SetRotateOnVelocity(0, true)
    effect:SetFollowEmitter(0, true)
    effect:SetKillOnEntityDeath(0, true)
    -- effect:SetUVFrameSize(0, .25, 1)
    effect:SetMaxNumParticles(0, 128)
    effect:SetMaxLifetime(0, MAX_LIFETIME_SMOKE_THIN)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE_THIN)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE_THIN)
    effect:SetBlendMode(0, BLENDMODE.Additive)
    effect:SetSortOrder(0, 1)
    -- effect:SetSortOffset(0, 1)
    effect:SetDragCoefficient(0, 0.1)

    -- Fat Smoke
    effect:SetRenderResources(1, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(1, true)
    effect:SetMaxNumParticles(1, 128)
    effect:SetMaxLifetime(1, MAX_LIFETIME_SMOKE_FAT)
    effect:SetColourEnvelope(1, COLOUR_ENVELOPE_NAME_SMOKE_FAT)
    effect:SetScaleEnvelope(1, SCALE_ENVELOPE_NAME_SMOKE_FAT)
    effect:SetBlendMode(1, BLENDMODE.AlphaBlended)
    -- effect:SetSortOrder(1, 1)
    -- effect:SetLayer(1,LAYER_BACKDROP)
    -- effect:SetIsTrailEmitter(1, true)
    -- effect:SetSortOffset(1, 2)
    effect:SetDragCoefficient(1, 0.02)

    -- Ball Smoke
    --SMOKE
    effect:SetRenderResources(2, SMOKE_TEXTURE, ADD_SHADER)
    effect:SetMaxNumParticles(2, 128)
    effect:SetMaxLifetime(2, MAX_LIFETIME_SMOKE_BALL)
    effect:SetColourEnvelope(2, COLOUR_ENVELOPE_NAME_SMOKE_BALL)
    effect:SetScaleEnvelope(2, SCALE_ENVELOPE_NAME_SMOKE_BALL)
    effect:SetBlendMode(2, BLENDMODE.AlphaAdditive)
    effect:EnableBloomPass(2, true)
    effect:SetUVFrameSize(2, .25, 1)
    effect:SetSortOrder(2, 1)
    -- effect:SetSortOffset(2, 2)
    effect:SetRadius(2, 3) --only needed on a single emitter
    effect:SetDragCoefficient(2, 0.1)
    effect:SetAcceleration(2, 0, -0.1, 0)
    effect:SetGroundPhysics(2, true)
    -----------------------------------------------------





    local sphere_emitter_fat = CreateSphereEmitter(.3)
    local sphere_emitter_ball = CreateSphereEmitter(.35)

    local up_facing = {
        FACING_UP, FACING_UPLEFT, FACING_UPRIGHT
    }

    local num_to_emit_smoke_fat = 1
    local num_to_emit_smoke_ball = 1

    inst.last_facing = nil
    inst.pos_presets = {}

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()

        if parent then
            local facing = parent.AnimState:GetCurrentFacing()
            local face_vector = Icey2Basic.GetFaceVector(parent)

            if inst.last_facing ~= facing then
                effect:ClearAllParticles(0)

                if inst.pos_presets[facing] == nil then
                    inst.pos_presets[facing] = GetPosList(inst, parent)
                end

                local vel = face_vector * 0.01

                for _, pos in pairs(inst.pos_presets[facing]) do
                    emit_smoke_thin_fn(effect, pos, vel)
                end

                inst.last_facing = facing
            end

            if table.contains(up_facing, facing) then
                -- effect:SetSortOrder(0, 3)
                effect:SetSortOffset(0, 1)
            else
                -- effect:SetSortOrder(0, 1)
                effect:SetSortOffset(0, 0)
            end


            -- Emit fat smoke
            -- num_to_emit_smoke_fat = num_to_emit_smoke_fat + GetRandomMinMax(1.1, 1.2)

            -- while num_to_emit_smoke_fat > 0 do
            --     local pos = Vector3(sphere_emitter_fat()) - face_vector * 0.2
            --     -- local pos = Vector3(0, 0, 0)
            --     local vel = face_vector * 0.05

            --     emit_smoke_fat_fn(effect, pos, vel)
            --     num_to_emit_smoke_fat = num_to_emit_smoke_fat - 1
            -- end


            -- Emit ball smoke
            num_to_emit_smoke_ball = num_to_emit_smoke_ball + GetRandomMinMax(1.3, 1.4)

            while num_to_emit_smoke_ball > 0 do
                local pos = Vector3(sphere_emitter_ball())
                local vel = face_vector * 0.05
                emit_smoke_ball_fn(effect, pos, vel)
                num_to_emit_smoke_ball = num_to_emit_smoke_ball - 1
            end
        end
    end)

    return inst
end

local function fat_vfx_fn()
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

    -- Fat Smoke
    effect:SetRenderResources(0, ANIM_SMOKE_TEXTURE, REVEAL_SHADER)
    effect:SetRotateOnVelocity(0, true)
    effect:SetMaxNumParticles(0, 128)
    effect:SetMaxLifetime(0, MAX_LIFETIME_SMOKE_FAT)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME_SMOKE_FAT)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME_SMOKE_FAT)
    effect:SetBlendMode(0, BLENDMODE.AlphaBlended)
    effect:SetDragCoefficient(0, 0.02)


    local sphere_emitter_fat = CreateSphereEmitter(.3)

    local num_to_emit_smoke_fat = 1

    EmitterManager:AddEmitter(inst, nil, function()
        local parent = inst.entity:GetParent()

        if parent then
            local face_vector = Icey2Basic.GetFaceVector(parent)

            -- Emit fat smoke
            num_to_emit_smoke_fat = num_to_emit_smoke_fat + GetRandomMinMax(1.1, 1.2)

            while num_to_emit_smoke_fat > 0 do
                local pos = Vector3(sphere_emitter_fat()) - face_vector * 0.2
                -- local pos = Vector3(0, 0, 0)
                local vel = face_vector * 0.05

                emit_smoke_fat_fn(effect, pos, vel)
                num_to_emit_smoke_fat = num_to_emit_smoke_fat - 1
            end
        end
    end)

    return inst
end


local function fat_fx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetEightFaced()

    inst.AnimState:SetBank("icey2_advance_height_controler")
    inst.AnimState:SetBuild("icey2_advance_height_controler")
    inst.AnimState:PlayAnimation("mult_face")
    inst.AnimState:SetSymbolMultColour("swap_object", 0, 0, 0, 0)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst.persists = false

    inst.Emit = function(inst, angle)
        inst.Transform:SetRotation(angle)

        inst.vfx = inst:SpawnChild("icey2_skull_fat_tail_vfx")
        inst.vfx.entity:AddFollower()
        inst.vfx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -60, 0)
    end

    inst:DoTaskInTime(FRAMES, inst.Remove)


    return inst
end


return Prefab("icey2_skull_tail_vfx", fn, assets),
    Prefab("icey2_skull_fat_tail_vfx", fat_vfx_fn, assets),
    Prefab("icey2_skull_fat_tail_fx", fat_fx_fn, assets)
