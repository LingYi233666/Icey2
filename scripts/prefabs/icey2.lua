local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/hibiki.zip"),
}
-- ThePlayer.AnimState:OverrideSymbol("hairpigtails", "hibiki", "hairpigtails")
local prefabs = {}

-- 初始物品
local start_inv = {
    -- "spear" -- 自带一个长矛
}

local function OnNewSpawn(inst)
    for name, v in pairs(ICEY2_SKILL_DEFINES) do
        if v.Root then
            inst.components.icey2_skiller:Learn(name)
        end
    end
end

-- 这个函数将在服务器和客户端都会执行
-- 一般用于添加小地图标签等动画文件或者需要主客机都执行的组件（少数）
local common_postinit = function(inst)
    -- Minimap icon
    inst.MiniMapEntity:SetIcon("icey2.tex")

    inst:AddTag("icey2")

    if not inst.components.updatelooper then
        inst:AddComponent("updatelooper")
    end
end

-- 这里的的函数只在主机执行  一般组件之类的都写在这里
local master_postinit = function(inst)
    -- 人物音效
    inst.soundsname = "wendy"

    -- 最喜欢的食物  名字 倍率（1.2）
    -- 老马克肖：艾希最喜欢吃老马爱吃的汉堡
    local favorite_foods = {
        "leafymeatburger",
        "quagmire_food_020",
        "quagmire_food_033",
        "quagmire_food_034",
        "quagmire_food_035",
        "quagmire_food_052",
    }

    for _, food in pairs(favorite_foods) do
        inst.components.foodaffinity:AddPrefabAffinity(food, TUNING.AFFINITY_15_CALORIES_HUGE)
    end


    -- 三维	
    inst.components.health:SetMaxHealth(TUNING.ICEY2_HEALTH)
    inst.components.hunger:SetMax(TUNING.ICEY2_HUNGER)
    inst.components.sanity:SetMax(TUNING.ICEY2_SANITY)

    inst.components.eater:SetCanEatGears()

    ----------------------------------------------------------------------

    inst:AddComponent("icey2_spdamage_force")

    inst:AddComponent("icey2_skiller")

    inst:AddComponent("icey2_skill_phantom_sword")

    inst:AddComponent("icey2_skill_dodge")

    inst:AddComponent("icey2_skill_unarmoured_movement")

    inst:AddComponent("icey2_skill_shield")

    inst:AddComponent("icey2_skill_summon_pact_weapon")

    inst:AddComponent("icey2_skill_battle_focus")

    inst.OnNewSpawn = OnNewSpawn
end

return MakePlayerCharacter("icey2", prefabs, assets, common_postinit,
    master_postinit, start_inv)
