local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),

    Asset("ANIM", "anim/icey2_pact_weapon_wheel.zip"),
    Asset("ANIM", "anim/icey2_new_skill_circle.zip"),
    Asset("ANIM", "anim/icey2_speedrun.zip"),
    Asset("ANIM", "anim/icey2_skill_shield_metrics.zip"),

    Asset("ANIM", "anim/swap_icey2_parry_shield.zip"),

    Asset("ANIM", "anim/icey2_shield_charge_cover.zip"),

    Asset("ANIM", "anim/icey2_soul_absorb_fx.zip"),

    Asset("ANIM", "anim/player_pistol.zip"),

    Asset("ANIM", "anim/wx_upgrade.zip"),



    -- test bladegun anims
    Asset("ANIM", "anim/tf2minigun.zip"),
    Asset("ANIM", "anim/player_actions_tf2minigun_ext.zip"),
    Asset("ANIM", "anim/player_walk_tf2minigun.zip"),
    Asset("ANIM", "anim/player_actions_tf2minigun.zip"),

    --------------------------------------------------------------
    -- Skills
    Asset("IMAGE", "images/ui/skill_slot/battle_focus.tex"),
    Asset("ATLAS", "images/ui/skill_slot/battle_focus.xml"),
    Asset("IMAGE", "images/ui/skill_slot/dodge.tex"),
    Asset("ATLAS", "images/ui/skill_slot/dodge.xml"),
    Asset("IMAGE", "images/ui/skill_slot/force_shield.tex"),
    Asset("ATLAS", "images/ui/skill_slot/force_shield.xml"),
    Asset("IMAGE", "images/ui/skill_slot/hunger_is_electricity.tex"),
    Asset("ATLAS", "images/ui/skill_slot/hunger_is_electricity.xml"),
    Asset("IMAGE", "images/ui/skill_slot/new_pact_weapon_chainsaw.tex"),
    Asset("ATLAS", "images/ui/skill_slot/new_pact_weapon_chainsaw.xml"),
    Asset("IMAGE", "images/ui/skill_slot/new_pact_weapon_gunlance.tex"),
    Asset("ATLAS", "images/ui/skill_slot/new_pact_weapon_gunlance.xml"),
    Asset("IMAGE", "images/ui/skill_slot/new_pact_weapon_scythe.tex"),
    Asset("ATLAS", "images/ui/skill_slot/new_pact_weapon_scythe.xml"),
    Asset("IMAGE", "images/ui/skill_slot/parry.tex"),
    Asset("ATLAS", "images/ui/skill_slot/parry.xml"),
    Asset("IMAGE", "images/ui/skill_slot/phantom_sword.tex"),
    Asset("ATLAS", "images/ui/skill_slot/phantom_sword.xml"),
    Asset("IMAGE", "images/ui/skill_slot/sample.tex"),
    Asset("ATLAS", "images/ui/skill_slot/sample.xml"),
    Asset("IMAGE", "images/ui/skill_slot/summon_pact_weapon.tex"),
    Asset("ATLAS", "images/ui/skill_slot/summon_pact_weapon.xml"),
    Asset("IMAGE", "images/ui/skill_slot/unknown.tex"),
    Asset("ATLAS", "images/ui/skill_slot/unknown.xml"),
    Asset("IMAGE", "images/ui/skill_slot/upgrade_pact_weapon_chainsaw_1.tex"),
    Asset("ATLAS", "images/ui/skill_slot/upgrade_pact_weapon_chainsaw_1.xml"),
    Asset("IMAGE", "images/ui/skill_slot/upgrade_pact_weapon_chainsaw_2.tex"),
    Asset("ATLAS", "images/ui/skill_slot/upgrade_pact_weapon_chainsaw_2.xml"),
    Asset("IMAGE", "images/ui/skill_slot/upgrade_pact_weapon_chainsaw_3.tex"),
    Asset("ATLAS", "images/ui/skill_slot/upgrade_pact_weapon_chainsaw_3.xml"),
    Asset("IMAGE", "images/ui/skill_slot/upgrade_pact_weapon_gunlance_1.tex"),
    Asset("ATLAS", "images/ui/skill_slot/upgrade_pact_weapon_gunlance_1.xml"),
    Asset("IMAGE", "images/ui/skill_slot/upgrade_pact_weapon_gunlance_2.tex"),
    Asset("ATLAS", "images/ui/skill_slot/upgrade_pact_weapon_gunlance_2.xml"),
    Asset("IMAGE", "images/ui/skill_slot/upgrade_pact_weapon_gunlance_3.tex"),
    Asset("ATLAS", "images/ui/skill_slot/upgrade_pact_weapon_gunlance_3.xml"),
    Asset("IMAGE", "images/ui/skill_slot/upgrade_pact_weapon_rapier_1.tex"),
    Asset("ATLAS", "images/ui/skill_slot/upgrade_pact_weapon_rapier_1.xml"),
    Asset("IMAGE", "images/ui/skill_slot/upgrade_pact_weapon_rapier_2.tex"),
    Asset("ATLAS", "images/ui/skill_slot/upgrade_pact_weapon_rapier_2.xml"),
    Asset("IMAGE", "images/ui/skill_slot/upgrade_pact_weapon_rapier_3.tex"),
    Asset("ATLAS", "images/ui/skill_slot/upgrade_pact_weapon_rapier_3.xml"),
    Asset("IMAGE", "images/ui/skill_slot/upgrade_pact_weapon_scythe_1.tex"),
    Asset("ATLAS", "images/ui/skill_slot/upgrade_pact_weapon_scythe_1.xml"),
    Asset("IMAGE", "images/ui/skill_slot/upgrade_pact_weapon_scythe_2.tex"),
    Asset("ATLAS", "images/ui/skill_slot/upgrade_pact_weapon_scythe_2.xml"),
    Asset("IMAGE", "images/ui/skill_slot/upgrade_pact_weapon_scythe_3.tex"),
    Asset("ATLAS", "images/ui/skill_slot/upgrade_pact_weapon_scythe_3.xml"),


}
-- ThePlayer.AnimState:OverrideSymbol("hairpigtails", "hibiki", "hairpigtails")
local prefabs = {}

-- 初始物品
local start_inv = {
    "leafymeatburger",
}


local function CustomIdleStateFn(inst)
    -- if inst.components.icey2_skill_battle_focus
    --     and inst.components.icey2_skill_battle_focus:IsEnabled()
    --     and inst.components.icey2_skill_battle_focus:GetPercent() > 0.5 then
    --     return "icey2_funnyidle"
    -- end

    return "icey2_funnyidle"
end

local function OnNewState(inst, data)
    print(inst, "new state:", data.statename)
end

local function ParryCallback(inst, data)
    if inst.components.icey2_skill_battle_focus
        and inst.components.icey2_skill_battle_focus:IsEnabled()
        and data.is_good_parry
        and not Icey2Basic.IsWearingArmor(inst) then
        inst.components.icey2_skill_battle_focus:RefreshAttackTime()
        inst.components.icey2_skill_battle_focus:DoDelta(100)
    end

    local attacker = data.attacker
    if attacker and inst.components.combat:CanTarget(attacker) and not inst.components.combat:IsAlly(attacker) then
        local damage = 34
        local spdamage = {
            icey2_spdamage_force = 34
        }
        attacker.components.combat:GetAttacked(inst, damage, nil, "electric", spdamage)

        SpawnAt("electrichitsparks", attacker):AlignToTarget(attacker, inst, true)
    end
end

local function OnPlayerSpawn(inst)
    for _, v in pairs(ICEY2_SKILL_DEFINES) do
        if v.Root then
            if not inst.components.icey2_skiller:IsLearned(v.Name) then
                inst.components.icey2_skiller:Learn(v.Name)
            end
        end
    end
end

-- 这个函数将在服务器和客户端都会执行
-- 一般用于添加小地图标签等动画文件或者需要主客机都执行的组件（少数）
local common_postinit = function(inst)
    -- Minimap icon
    inst.MiniMapEntity:SetIcon("icey2.tex")

    inst.AnimState:AddOverrideBuild("wx_upgrade")

    inst:AddTag("icey2")
    for i = 1, 5 do
        inst:AddTag("icey2_dodge_charge_chip_" .. i .. "_builder")
    end

    if not inst.components.updatelooper then
        inst:AddComponent("updatelooper")
    end

    inst:AddComponent("icey2_control_key_helper")
end

local function OnSave(inst, data)
    for i = 1, 5 do
        local tag = "icey2_dodge_charge_chip_" .. i .. "_builder"
        local index = "has_" .. tag
        data[index] = inst:HasTag(tag)
    end
end

local function OnLoad(inst, data)
    if data ~= nil then
        for i = 1, 5 do
            local tag = "icey2_dodge_charge_chip_" .. i .. "_builder"
            local index = "has_" .. tag

            if data[index] ~= nil then
                if data[index] then
                    inst:AddTag(tag)
                else
                    inst:RemoveTag(tag)
                end
            end
        end
    end
end

-- 这里的的函数只在主机执行  一般组件之类的都写在这里
local master_postinit = function(inst)
    -- 人物音效
    inst.soundsname = "wendy"
    -- inst.customidlestate = CustomIdleStateFn

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

    inst:AddComponent("icey2_status_bonus")

    inst:AddComponent("icey2_spdamage_force")

    inst:AddComponent("icey2_skiller")

    inst:AddComponent("icey2_skill_phantom_sword")

    inst:AddComponent("icey2_skill_dodge")

    inst:AddComponent("icey2_skill_unarmoured_movement")

    inst:AddComponent("icey2_skill_shield")

    inst:AddComponent("icey2_skill_summon_pact_weapon")

    inst:AddComponent("icey2_skill_battle_focus")

    inst:AddComponent("icey2_skill_parry")
    inst.components.icey2_skill_parry.parrycallback = ParryCallback

    -- icey2_reroll_data_handler is added in main/prefabs.lua
    -- inst:AddComponent("icey2_reroll_data_handler")

    -- inst.OnNewSpawn = OnNewSpawn

    -- inst:ListenForEvent("playeractivated", OnPlayerSpawn)

    -- inst:ListenForEvent("newstate", OnNewState)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    OnPlayerSpawn(inst)
end

return MakePlayerCharacter("icey2", prefabs, assets, common_postinit,
    master_postinit, start_inv)
