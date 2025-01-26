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

    HUNGER_IS_ELECTRICITY = {
        Root = true,
    },

    FORCE_SHIELD = {
        OnLearned = PassiveSkillOnLearnedWrapper("icey2_skill_shield"),

        OnForget = PassiveSkillOnForgetWrapper("icey2_skill_shield"),

        Root = true,
    },

    DODGE = {
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        OnPressed = CastSkillByComponentWrapper("icey2_skill_dodge"),

        Root = true,
    },

    SUMMON_PACT_WEAPON = {
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

    NEW_PACT_WEAPON_SCYTHE = {
        OnLearned = function(inst, is_onload)
            inst.components.icey2_skill_summon_pact_weapon:AddWeaponPrefab("icey2_pact_weapon_scythe")
        end,

        OnForget = function(inst)
            inst.components.icey2_skill_summon_pact_weapon:RemoveWeaponPrefab("icey2_pact_weapon_scythe")
        end,

        -- Root = true,
        Ingredients = { Ingredient("flint", 3), Ingredient("twigs", 1), Ingredient(CHARACTER_INGREDIENT.SANITY, 50) },
        Tech = TECH.MAGIC_TWO,
    },

    PHANTOM_SWORD = {
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        OnPressed = CastSkillByComponentWrapper("icey2_skill_phantom_sword"),

        -- Root = true,
        Ingredients = { Ingredient("moonrocknugget", 5), },
    },

    BATTLE_FOCUS = {
        OnLearned = PassiveSkillOnLearnedWrapper("icey2_skill_battle_focus"),

        OnForget = PassiveSkillOnForgetWrapper("icey2_skill_battle_focus"),

        -- Root = true,

        Ingredients = { Ingredient("bluegem", 1), },
        Tech = TECH.SCIENCE_TWO,
    },


    PARRY = {
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

GLOBAL.ICEY2_SKILL_DEFINES = ICEY2_SKILL_DEFINES
