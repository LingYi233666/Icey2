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

ICEY2_SKILL_DEFINES = {
    PHANTOM_SWORD = {
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        OnPressed = CastSkillByComponentWrapper("icey2_skill_phantom_sword"),

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
            inst.replica.icey2_skill_summon_pact_weapon:ShowPactWeaponsWheel()
        end,

        DescFn = function(inst)
            return STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC.SUMMON_PACT_WEAPON.DESC ..
                "\n\n" .. STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC.SUMMON_PACT_WEAPON.DESC_TIP_MORE_WEAPON
        end,


        Root = true,
    }
}

GLOBAL.ICEY2_SKILL_DEFINES = ICEY2_SKILL_DEFINES
