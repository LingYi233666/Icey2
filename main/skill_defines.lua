local function CastSkillByComponent(cmp_name, inst, x, y, z, ent)
    local cmp = inst.components[cmp_name]

    if cmp then
        local can_cast, reason = cmp:CanCast(x, y, z, ent)

        if can_cast then
            cmp:Cast(x, y, z, ent)
        else
            print(cmp_name .. " cast failed, reason: " .. tostring(reason))
        end
    end
end

local function CastSkillByComponentWrapper(cmp_name)
    local function fn(inst, x, y, z, ent)
        CastSkillByComponent(cmp_name, inst, x, y, z, ent)
    end

    return fn
end

local function PassiveSkillOnLearnedWrapper(cmp_name)
    local function fn(inst, is_onload)
        if is_onload then
            return
        end

        local cmp = inst.components[cmp_name]

        if cmp then
            cmp:Enable()
        end
    end

    return fn
end

local function PassiveSkillOnForgetWrapper(cmp_name)
    local function fn(inst)
        local cmp = inst.components[cmp_name]

        if cmp then
            cmp:Disable()
        end
    end

    return fn
end

ICEY2_SKILL_DEFINES = {
    {
        Name = "hunger_is_electricity",
        Root = true,
    },

    {
        Name = "force_shield",
        OnLearned = PassiveSkillOnLearnedWrapper("icey2_skill_shield"),

        OnForget = PassiveSkillOnForgetWrapper("icey2_skill_shield"),

        Root = true,
    },

    {
        Name = "dodge",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        OnPressed = CastSkillByComponentWrapper("icey2_skill_dodge"),

        Root = true,
    },

    {
        Name = "summon_pact_weapon",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        OnPressed_Client = function(inst)
            if inst.replica.icey2_skill_summon_pact_weapon.call_cd == nil
                or GetTime() - inst.replica.icey2_skill_summon_pact_weapon.call_cd > 0.1 then
                inst.replica.icey2_skill_summon_pact_weapon:ShowPactWeaponsWheel()
                inst.replica.icey2_skill_summon_pact_weapon.call_cd = GetTime()
            end
        end,

        DescFn = function(inst)
            return STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC.SUMMON_PACT_WEAPON.DESC ..
                "\n\n" .. STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC.SUMMON_PACT_WEAPON.DESC_TIP_MORE_WEAPON
        end,

        Root = true,
    },

    {
        Name = "upgrade_pact_weapon_rapier_1",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        RequiredSkills = { "summon_pact_weapon" },
        Ingredients = { Ingredient("icey2_blood_metal", 3), },
    },

    {
        Name = "upgrade_pact_weapon_rapier_2",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        RequiredSkills = { "upgrade_pact_weapon_rapier_1" },
        Ingredients = { Ingredient("icey2_blood_metal", 5), },
    },

    {
        Name = "upgrade_pact_weapon_rapier_3",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        RequiredSkills = { "upgrade_pact_weapon_rapier_2" },
        Ingredients = { Ingredient("icey2_blood_metal", 7), },
    },

    {
        Name = "new_pact_weapon_scythe",
        OnLearned = function(inst, is_onload)
            inst.components.icey2_skill_summon_pact_weapon:AddWeaponPrefab("icey2_pact_weapon_scythe")
        end,

        OnForget = function(inst)
            inst.components.icey2_skill_summon_pact_weapon:RemoveWeaponPrefab("icey2_pact_weapon_scythe")
        end,

        -- Root = true,
        Ingredients = {
            Ingredient("flint", 3),
            Ingredient("twigs", 1),
            Ingredient(CHARACTER_INGREDIENT.SANITY, 50)
        },
        Tech = TECH.SCIENCE_TWO,
    },

    {
        Name = "upgrade_pact_weapon_scythe_1",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        RequiredSkills = { "new_pact_weapon_scythe" },
        Ingredients = { Ingredient("icey2_blood_metal", 3), },
        Tech = TECH.SCIENCE_TWO,
    },

    {
        Name = "upgrade_pact_weapon_scythe_2",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        RequiredSkills = { "upgrade_pact_weapon_scythe_1" },
        Ingredients = { Ingredient("icey2_blood_metal", 5), },
        Tech = TECH.SCIENCE_TWO,
    },

    {
        Name = "upgrade_pact_weapon_scythe_3",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        RequiredSkills = { "upgrade_pact_weapon_scythe_2" },
        Ingredients = { Ingredient("icey2_blood_metal", 7), },
        Tech = TECH.SCIENCE_TWO,
    },


    {
        Name = "new_pact_weapon_gunlance",
        OnLearned = function(inst, is_onload)
            inst.components.icey2_skill_summon_pact_weapon:AddWeaponPrefab("icey2_pact_weapon_gunlance")
        end,

        OnForget = function(inst)
            inst.components.icey2_skill_summon_pact_weapon:RemoveWeaponPrefab("icey2_pact_weapon_gunlance")
        end,

        -- Root = true,
        Ingredients = {
            Ingredient("blowdart_pipe", 6),
            Ingredient("boards", 4),
            Ingredient(CHARACTER_INGREDIENT.SANITY, 50)
        },
        Tech = TECH.MAGIC_TWO,
    },

    {
        Name = "upgrade_pact_weapon_gunlance_1",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        RequiredSkills = { "new_pact_weapon_gunlance" },
        Ingredients = { Ingredient("icey2_blood_metal", 3), },
        Tech = TECH.MAGIC_TWO,
    },

    {
        Name = "upgrade_pact_weapon_gunlance_2",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        RequiredSkills = { "upgrade_pact_weapon_gunlance_1" },
        Ingredients = { Ingredient("icey2_blood_metal", 5), },
        Tech = TECH.MAGIC_TWO,
    },

    {
        Name = "upgrade_pact_weapon_gunlance_3",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        RequiredSkills = { "upgrade_pact_weapon_gunlance_2" },
        Ingredients = { Ingredient("icey2_blood_metal", 7), },
        Tech = TECH.MAGIC_TWO,
    },

    {
        Name = "new_pact_weapon_chainsaw",
        OnLearned = function(inst, is_onload)
            inst.components.icey2_skill_summon_pact_weapon:AddWeaponPrefab("icey2_pact_weapon_chainsaw")
        end,

        OnForget = function(inst)
            inst.components.icey2_skill_summon_pact_weapon:RemoveWeaponPrefab("icey2_pact_weapon_chainsaw")
        end,

        -- Root = true,
        Ingredients = {
            Ingredient("boards", 4),
            Ingredient("flint", 4),
            Ingredient(CHARACTER_INGREDIENT.SANITY, 50)
        },
        Tech = TECH.MAGIC_THREE,
    },

    {
        Name = "upgrade_pact_weapon_chainsaw_1",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        RequiredSkills = { "new_pact_weapon_chainsaw" },
        Ingredients = { Ingredient("icey2_blood_metal", 3), },
        Tech = TECH.MAGIC_THREE,
    },

    {
        Name = "upgrade_pact_weapon_chainsaw_2",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        RequiredSkills = { "upgrade_pact_weapon_chainsaw_1" },
        Ingredients = { Ingredient("icey2_blood_metal", 5), },
        Tech = TECH.MAGIC_THREE,
    },

    {
        Name = "upgrade_pact_weapon_chainsaw_3",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        RequiredSkills = { "upgrade_pact_weapon_chainsaw_2" },
        Ingredients = { Ingredient("icey2_blood_metal", 7), },
        Tech = TECH.MAGIC_THREE,
    },

    {
        Name = "phantom_sword",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        OnPressed = CastSkillByComponentWrapper("icey2_skill_phantom_sword"),

        -- Root = true,
        Ingredients = { Ingredient("moonrocknugget", 5), },
    },

    {
        Name = "battle_focus",
        OnLearned = PassiveSkillOnLearnedWrapper("icey2_skill_battle_focus"),

        OnForget = PassiveSkillOnForgetWrapper("icey2_skill_battle_focus"),

        -- Root = true,

        Ingredients = { Ingredient("bluegem", 1), },
        Tech = TECH.SCIENCE_TWO,
    },


    {
        Name = "parry",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        OnPressed = function(inst, x, y, z, ent)
            local can_cast, reason = inst.components.icey2_skill_parry:CanStartParry(x, y, z, ent)

            if can_cast then
                inst.components.icey2_skill_parry:StartParry()
            else
                -- print("icey2_skill_parry start parry failed, reason: " .. tostring(reason))
            end
        end,

        OnReleased = function(inst, x, y, z, ent)
            local can_cast, reason = inst.components.icey2_skill_parry:CanStopParry(x, y, z, ent)

            if can_cast then
                inst.components.icey2_skill_parry:StopParry()
            else
                -- print("icey2_skill_parry stop parry failed, reason: " .. tostring(reason))
            end
        end,

        Ingredients = { Ingredient("rocks", 10), Ingredient(CHARACTER_INGREDIENT.SANITY, 50) },
        Tech = TECH.SCIENCE_ONE,

        -- Root = true,
    },
}

-- Check if has duplicate skill names
local exists_skill_names = {}
for _, data in pairs(ICEY2_SKILL_DEFINES) do
    assert(exists_skill_names[data.Name] ~= true)

    exists_skill_names[data.Name] = true
end

GLOBAL.ICEY2_SKILL_DEFINES = ICEY2_SKILL_DEFINES
