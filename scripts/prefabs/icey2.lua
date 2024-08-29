local MakePlayerCharacter = require "prefabs/player_common"


local assets = {
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}
local prefabs = {}

-- 初始物品
local start_inv = {
	"spear", --自带一个长矛
}

local function OnNewSpawn(inst)
	for name, v in pairs(ICEY2_SKILL_DEFINES) do
		if v.Root then
			inst.components.icey2_skiller:Learn(name)
		end
	end
end


--这个函数将在服务器和客户端都会执行
--一般用于添加小地图标签等动画文件或者需要主客机都执行的组件（少数）
local common_postinit = function(inst)
	-- Minimap icon
	inst.MiniMapEntity:SetIcon("icey2.tex")

	inst:AddTag("icey2")
end

-- 这里的的函数只在主机执行  一般组件之类的都写在这里
local master_postinit = function(inst)
	-- 人物音效
	inst.soundsname = "willow"

	--最喜欢的食物  名字 倍率（1.2）
	inst.components.foodaffinity:AddPrefabAffinity("baconeggs", TUNING.AFFINITY_15_CALORIES_HUGE)

	-- 三维	
	inst.components.health:SetMaxHealth(TUNING.ICEY2_HEALTH)
	inst.components.hunger:SetMax(TUNING.ICEY2_HUNGER)
	inst.components.sanity:SetMax(TUNING.ICEY2_SANITY)

	inst:AddComponent("icey2_skiller")

	inst:AddComponent("icey2_skill_phantom_sword")
	inst:AddComponent("icey2_skill_dodge")

	inst.OnNewSpawn = OnNewSpawn
end

return MakePlayerCharacter("icey2", prefabs, assets, common_postinit, master_postinit, start_inv)
