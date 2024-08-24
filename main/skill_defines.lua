local function CastSkillByComponent(cmp_name, inst, x, y, z, ent)
    local cmp = inst.components[cmp_name]

    if cmp then
        local can_cast, reason = cmp:CanCast(ent)

        if can_cast then
            cmp:Cast(ent)
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
        OnLearned = function(inst, is_onload)

        end,

        OnForget = function(inst)

        end,

        OnPressed = CastSkillByComponentWrapper("icey2_skill_phantom_sword"),
    },
}



GLOBAL.ICEY2_SKILL_DEFINES = ICEY2_SKILL_DEFINES
