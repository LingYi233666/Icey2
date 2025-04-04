local Tasks = require("map/tasks")

local Icey2SkullPileSpawner = Class(function(self, inst)
    self.inst = inst

    self.init_spawned = false
    self.skull_piles = {}

    self.timer_regenerate = TUNING.TOTAL_DAY_TIME

    inst:DoTaskInTime(1, function()
        if not self.init_spawned then
            self:DoInitSpawn()
            self.init_spawned = true
        end
    end)

    inst:StartUpdatingComponent(self)
end)

local VOXEL_SIZE = 100

function Icey2SkullPileSpawner:IsValidPos(pos)
    local x, y, z = pos:Get()


    for dx = -3, 3 do
        for dz = -3, 3 do
            local cx = x + dx
            local cz = z + dz

            if TheWorld.Map:IsOceanTileAtPoint(cx, y, cz)
                or not TheWorld.Map:IsVisualGroundAtPoint(cx, y, cz)
                or not TheWorld.Map:IsPassableAtPoint(cx, 0, cz)
                or TheWorld.Map:GetPlatformAtPoint(cx, cz) ~= nil then
                return false
            end
        end
    end

    -- Avoid island
    local node, node_index = TheWorld.Map:FindVisualNodeAtPoint(x, y, z)
    if node and node.type == NODE_TYPE.SeparatedRoom then
        return false
    end

    local player = FindClosestPlayerInRange(x, y, z, 50)
    if player ~= nil then
        return false
    end

    local ents = TheSim:FindEntities(x, 0, z, 4, nil, { "NOBLOCK", "FX", "INLIMBO" })

    if #ents > 0 then
        return false
    end

    return true
end

function Icey2SkullPileSpawner:SpawnCommon(set_count, voxel_size)
    local map_x, map_y = TheWorld.Map:GetWorldSize()
    map_x = map_x * TILE_SCALE / 2
    map_y = map_y * TILE_SCALE / 2


    local lookup_table = {}
    local skull_piles_this = {}
    local spawn_count = 0

    while spawn_count < set_count do
        local pos = Vector3(GetRandomMinMax(-map_x, map_x), 0, GetRandomMinMax(-map_y, map_y))

        if self:IsValidPos(pos) then
            local voxel_id = Icey2Math.GetVoxelCellIndex(pos, voxel_size)

            if lookup_table[voxel_id] == nil then
                local ent = self:SpawnSkullPile(pos)

                table.insert(skull_piles_this, ent)

                lookup_table[voxel_id] = pos
                spawn_count = spawn_count + 1
            end
        end
    end

    return skull_piles_this
end

function Icey2SkullPileSpawner:DoInitSpawn()
    local skull_piles_this = self:SpawnCommon(15, VOXEL_SIZE)
    print("Init spawn, total skull pile count:", #skull_piles_this)
end

-- TheWorld.components.icey2_skull_pile_spawner:DoSpawnDuringGame()
function Icey2SkullPileSpawner:DoSpawnDuringGame()
    local skull_piles_this = self:SpawnCommon(1, VOXEL_SIZE)
    local skull_piles_near_player = {}

    for _, v in pairs(skull_piles_this) do
        local players = {}

        for _, player in pairs(AllPlayers) do
            if player:IsValid() and not IsEntityDeadOrGhost(player, true) then
                local dist = math.sqrt(player:GetDistanceSqToInst(v))
                if dist >= 60 and dist <= 800 then
                    table.insert(players, player)
                end
            end
        end

        if #players > 0 then
            table.insert(skull_piles_near_player, { v, GetRandomItem(players) })
        end
    end

    if #skull_piles_near_player > 0 then
        local select_skull_pile, select_player = unpack(GetRandomItem(skull_piles_near_player))
        local wagstaff_pos

        for i = 15, 8, -1 do
            wagstaff_pos = FindNearbyLand(select_player:GetPosition(), i)
            if wagstaff_pos then
                break
            end
        end


        if wagstaff_pos then
            local wagstaff_npc = self:SpawnWagstaff(wagstaff_pos, select_skull_pile:GetPosition())
            print("Spawn", wagstaff_npc, "in", wagstaff_npc:GetPosition(), "for", select_skull_pile, "in",
                select_skull_pile:GetPosition())
        else
            print("Sorry, no valid pos to put wagstaff...")
        end
    else
        print("Sorry, too far, no wagstaff spawned...")
    end

    print("Spawn duration game, total skull pile count:", #skull_piles_this)
end

function Icey2SkullPileSpawner:SpawnWagstaff(pos, destination)
    local wagstaff = SpawnPrefab("icey2_wagstaff_npc_skull_pile")

    wagstaff.Transform:SetPosition(pos:Get())

    wagstaff.components.timer:StartTimer("fadeout", 8)

    wagstaff.components.knownlocations:RememberLocation("skull_pile", destination)

    return wagstaff
end

-- function Icey2SkullPileSpawner:InitSpawn_ByTask()
--     local spawned_count = 0
--     -- local chosen_tasks = {}

--     local chosen_pos_list = {}

--     for k, node in ipairs(TheWorld.topology.nodes) do
--         local pos = Vector3(node.x, 0, node.y)
--         local task_name = TheWorld.topology.ids[k]:split(":")[1]

--         -- print("This task_name:", task_name)
--         local task = Tasks.GetTaskByName(task_name)
--         if task_name
--             and task
--             and task.locks
--             and (
--                 table.contains(task.locks, LOCKS.BASIC_COMBA)
--                 or table.contains(task.locks, LOCKS.ADVANCED_COMBAT)
--                 or table.contains(task.locks, LOCKS.MONSTERS_DEFEATED)
--                 or table.contains(task.locks, LOCKS.HARD_MONSTERS_DEFEATED)
--                 or table.contains(task.locks, LOCKS.SPIDERS_DEFEATED)
--                 or table.contains(task.locks, LOCKS.TREES)
--                 or table.contains(task.locks, LOCKS.SPIDERDENS)
--                 or table.contains(task.locks, LOCKS.KILLERBEES)
--                 or table.contains(task.locks, LOCKS.MEDIUM)
--                 or table.contains(task.locks, LOCKS.HARD))
--             and node.type ~= NODE_TYPE.SeparatedRoom
--             and self:IsValidPos(pos) then
--             if chosen_pos_list[task_name] == nil then
--                 chosen_pos_list[task_name] = {}
--             end
--             table.insert(chosen_pos_list[task_name], pos)
--             -- print(("Spawn a skull pile in %s, node id: %d, pos: %s"):format(TheWorld.topology.ids[k], k, tostring(pos)))

--             -- self:SpawnSkullPile(pos)
--             -- spawned_count = spawned_count + 1
--         end
--     end

--     local max_per_task = 1
--     for task_name, pos_list in pairs(chosen_pos_list) do
--         -- pos_list = shuffleArray(pos_list)
--         -- for i = 1, math.min(max_per_task, #pos_list) do
--         --     self:SpawnSkullPile(pos_list[i])
--         --     spawned_count = spawned_count + 1
--         -- end

--         local used_pos_list = {}
--         local num_pos = #pos_list
--         local try_count = math.min(max_per_task, num_pos)
--         for i = 1, try_count do
--             local select_index
--             if i == 1 then
--                 select_index = math.random(num_pos)
--             else
--                 local max_dist = 0

--                 for k, remain_pos in pairs(pos_list) do
--                     local this_dist = 0
--                     for _, used_pos in pairs(used_pos_list) do
--                         this_dist = this_dist + (remain_pos - used_pos):Length()
--                     end

--                     if this_dist > max_dist then
--                         max_dist = this_dist
--                         select_index = k
--                     end
--                 end
--             end

--             if select_index then
--                 local pos = table.remove(pos_list, select_index)

--                 self:SpawnSkullPile(pos)

--                 table.insert(used_pos_list, pos)
--                 spawned_count = spawned_count + 1
--             end
--         end
--     end

--     print("Total skull pile count:", spawned_count)
-- end

function Icey2SkullPileSpawner:SpawnSkullPile(pos)
    local ent = SpawnAt("icey2_skull_pile", pos)
    self:RecordSkullPile(ent)

    return ent
end

function Icey2SkullPileSpawner:RecordSkullPile(ent)
    local function onremove_fn()
        self:StopRecordingSkullPile(ent)
    end

    table.insert(self.skull_piles,
        {
            ent = ent,
            onremove_fn = onremove_fn,
        }
    )

    self.inst:ListenForEvent("onremove", onremove_fn, ent)
end

function Icey2SkullPileSpawner:StopRecordingSkullPile(ent)
    local index
    for k, data in pairs(self.skull_piles) do
        if data.ent == ent then
            index = k
            print("Stop record:", ent)
            self.inst:RemoveEventCallback("onremove", data.onremove_fn, ent)
            break
        end
    end

    if index then
        table.remove(self.skull_piles, index)
    end
end

function Icey2SkullPileSpawner:OnUpdate(dt)
    if self.timer_regenerate == nil then
        return
    end

    local rate = 1
    for _, v in pairs(AllPlayers) do
        if v and v.prefab == "icey2" then
            rate = rate + 0.1
        end
    end

    self.timer_regenerate = self.timer_regenerate - dt * rate
    if self.timer_regenerate <= 0 then
        -- Enough skull piles, no nedd to spawn
        if #self.skull_piles > 16 then
            self.timer_regenerate = TUNING.TOTAL_DAY_TIME
            return
        end

        -- Not enough skull plies, regenerate it.
        self:DoSpawnDuringGame()
        self.timer_regenerate = GetRandomMinMax(TUNING.TOTAL_DAY_TIME * 3, TUNING.TOTAL_DAY_TIME * 5)
    end
end

function Icey2SkullPileSpawner:OnSave()
    local data = {
        init_spawned = self.init_spawned,
        timer_regenerate = self.timer_regenerate,
        skull_piles_GUID = {},
    }

    local references = {}

    for _, skull_pile_data in pairs(self.skull_piles) do
        if skull_pile_data.ent:IsValid() then
            table.insert(data.skull_piles_GUID, skull_pile_data.ent.GUID)
            table.insert(references, skull_pile_data.ent.GUID)
        end
    end

    return data, references
end

function Icey2SkullPileSpawner:OnLoad(data)
    if data ~= nil then
        if data.init_spawned ~= nil then
            self.init_spawned = data.init_spawned
        end
        if data.timer_regenerate ~= nil then
            self.timer_regenerate = data.timer_regenerate
        end
    end
end

function Icey2SkullPileSpawner:LoadPostPass(newents, savedata)
    if savedata ~= nil then
        if savedata.skull_piles_GUID ~= nil then
            for _, guid in pairs(savedata.skull_piles_GUID) do
                local new_ent = newents[guid]
                if new_ent then
                    self:RecordSkullPile(new_ent.entity)
                end
            end
        end
    end
end

return Icey2SkullPileSpawner
