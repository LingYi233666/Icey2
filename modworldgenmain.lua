GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

modimport("main/tiles")

local StaticLayout = require("map/static_layout")
local Layouts = require("map/layouts").Layouts
local Tasks = require("map/tasks")


local function MyAddStaticLayout(name, path)
	Layouts[name] = StaticLayout.Get(path)

	Layouts[name].ground_types[WORLD_TILES.ICEY2_JUNGLE] = WORLD_TILES.ICEY2_JUNGLE

	return Layouts[name]
end

MyAddStaticLayout("icey1_graveyard", "layouts/icey1_graveyard")

AddLevelPreInitAny(function(level)
	if level.location == "cave" then
		-- if level.location == "forest" then
		if level.required_setpieces == nil then
			level.required_setpieces = {}
		end

		if level.required_prefabs == nil then
			level.required_prefabs = {}
		end

		table.insert(level.required_prefabs, "icey1_bluerose")
		table.insert(level.required_prefabs, "icey1_mound")

		local old_ChooseSetPieces = level.ChooseSetPieces
		assert(level.ChooseSetPieces ~= nil, "ChooseSetPieces is nil, sth wrong !!!")

		level.ChooseSetPieces = function(self, ...)
			local task_names_banned = {}
			local task_tags_banned = { "Atrium", "Nightmare" }
			-- local task_tags_required = {}

			-- room_tags
			local tasks = self:GetTasksForLevelSetPieces()
			local i = 1
			while i <= #tasks do
				if table.contains(task_names_banned, tasks[i].id)
					or table.contains(task_tags_banned, tasks[i].room_tags) then
					table.remove(tasks, i)
				else
					i = i + 1
				end
			end

			assert(#tasks > 0, "Not enough tasks !!!")

			print("Aviable tasks for icey1_graveyard:")
			for _, v in pairs(tasks) do
				print(v.id)
			end

			--Get random task
			local idx = math.random(#tasks)

			if tasks[idx].random_set_pieces == nil then
				tasks[idx].random_set_pieces = {}
			end
			print("[Icey2] icey1_graveyard added to task " .. tasks[idx].id)
			table.insert(tasks[idx].random_set_pieces, "icey1_graveyard")

			return old_ChooseSetPieces(self, ...)
		end
	end
end)

-- local all_tasks_name = Tasks.GetAllTaskNames()
-- for _, v in pairs(all_tasks_name) do
-- 	AddTaskPreInit(v, function(task)
-- 		if task.locks
-- 			and (table.contains(task.locks, LOCKS.ADVANCED_COMBAT)
-- 				or table.contains(task.locks, LOCKS.HARD_MONSTERS_DEFEATED)
-- 				or table.contains(task.locks, LOCKS.SPIDERS_DEFEATED)) then

-- 		end
-- 	end)
-- end
-- AddTaskP
