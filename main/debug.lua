local function EmitLaserAtPoint(start_pos, target_pos, segment_len, forward_len)
    local delta_pos = target_pos - start_pos
    local delta_pos_norm = delta_pos:GetNormalized()

    if forward_len then
        TheWorld:StartThread(function()
            local delta_xz = Vector3(delta_pos.x, 0, delta_pos.z)
            local delta_xz_norm = delta_xz:GetNormalized()
            local move_dist = 1
            local cnt = delta_xz:Length() / move_dist
            for i = 0, cnt do
                local this_target_pos = start_pos + delta_xz_norm * move_dist * i
                this_target_pos.y = target_pos.y
                EmitLaserAtPoint(start_pos, this_target_pos, segment_len)
                Sleep(0)
            end
            EmitLaserAtPoint(start_pos, target_pos, segment_len)
        end)
        return
    end


    local emit_cnt = delta_pos:Length() / segment_len

    for i = 0, emit_cnt do
        local pos = start_pos + delta_pos_norm * segment_len * i
        local vel = delta_pos_norm * 0.3
        local fx = SpawnAt("test_laser_beam_fx", pos)
        fx.vfx:SetEmitVelocity(vel.x, vel.y, vel.z)

        fx:DoTaskInTime(0.1, fx.Remove)
    end
end


-- c_test_laser()
-- c_test_laser(1,5)
function GLOBAL.c_test_laser(segment_len, forward_len)
    local start_pos = ThePlayer:GetPosition() + Vector3(0, 1, 0)
    local target_pos = TheInput:GetWorldPosition()
    segment_len = segment_len or 0.3
    EmitLaserAtPoint(start_pos, target_pos, segment_len, forward_len)
end

-- ThePlayer.AnimState:AddOverrideBuild("waxwell_minion_spawn") ThePlayer.AnimState:AddOverrideBuild("waxwell_minion_appear")
-- ThePlayer.AnimState:PlayAnimation("minion_spawn")
-- ThePlayer.AnimState:PlayAnimation("ready_stance_pre") ThePlayer.AnimState:PushAnimation("ready_stance_loop", true)
--
-- ThePlayer.AnimState:PlayAnimation("ready_stance_pst")

local obj_layout = require("map/object_layout")

local function _SpawnLayout_AddFn(prefab, points_x, points_y, current_pos_idx, entitiesOut, width, height, prefab_list,
                                  prefab_data, rand_offset)
    local x = (points_x[current_pos_idx] - width / 2.0) * TILE_SCALE
    local y = (points_y[current_pos_idx] - height / 2.0) * TILE_SCALE

    x = math.floor(x * 100) / 100.0
    y = math.floor(y * 100) / 100.0

    prefab_data.x = x
    prefab_data.z = y

    prefab_data.prefab = prefab

    -- local ent = SpawnSaveRecord(prefab_data)

    -- ent:LoadPostPass(Ents, FunctionOrValue(prefab_data.data))

    -- if ent.components.scenariorunner ~= nil then
    --     ent.components.scenariorunner:Run()
    -- end

    local ent = SpawnAt(prefab, Vector3(x, 0, y))
end

function GLOBAL.i_spawnlayout(name)
    local layout                = obj_layout.LayoutForDefinition(name)
    local map_width, map_height = TheWorld.Map:GetSize()

    local add_fn                = {
        fn = _SpawnLayout_AddFn,
        args = { entitiesOut = {}, width = map_width, height = map_height, rand_offset = false }
    }

    local offset                = layout.ground ~= nil and (#layout.ground / 2) or 0
    local size                  = layout.ground ~= nil and (#layout.ground * TILE_SCALE) or nil

    local pos                   = ConsoleWorldPosition()
    local x, z                  = TheWorld.Map:GetTileCoordsAtPoint(pos:Get())

    if size ~= nil then
        for i, ent in ipairs(TheSim:FindEntities(pos.x, 0, pos.z, size, nil, { "player", "INLIMBO", "FX" })) do -- Not a square, but that's fine for now.
            ent:Remove()
        end
    end

    obj_layout.Place({ x - offset, z - offset }, name, add_fn, nil, TheWorld.Map)
end

function GLOBAL.i_snowman()
    local snowman_prefabs = {
        "ash",
        "beardhair",
        "boneshard",
        "charcoal",
        "cutgrass",
        "eyeball",
        "featherpencil",
        "feather_crow",
        "feather_robin",
        "feather_robin_winter",
        "feather_canary",
        "flint",
        "gears",
        "goldnugget",
        "goose_feather",
        "houndstooth",
        "marble",
        "ice",
        "rocks",
        "malbatross_feather",
        "batwing",
        "moonglass",
        "moonrocknugget",
        "blue_cap",
        "red_cap",
        "green_cap",
        "nitre",
        "petals_evil",
        "petals",
        "seeds",
        "twigs",
        "carrot",
        "eggplant",
        "berries",
        "berries_juicy",
        "asparagus",
        "pepper",
    }

    for _, v in pairs(snowman_prefabs) do
        c_give(v, 10)
    end
end

function GLOBAL.i_allskill()
    for _, data in pairs(ICEY2_SKILL_DEFINES) do
        local name = data.Name
        if not ThePlayer.components.icey2_skiller:IsLearned(name) then
            ThePlayer.components.icey2_skiller:Learn(name)
        end
    end
end

function GLOBAL.i_wonkey()
    c_give("cursed_monkey_token", 10)
    c_give("cave_banana", 10)
    c_gonext("monkeyqueen")
end
