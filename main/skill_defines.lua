GLOBAL.ICEY2_SKILL_DEFINES = {
    PHANTOM_SWORD = {
        OnLearned = function(inst, is_onload)

        end,

        OnForget = function(inst)

        end,

        OnPressed = function(inst, x, y, z, ent)
            if inst.components.icey2_skill_phantom_sword then
                local can_cast, reason = inst.components.icey2_skill_phantom_sword:CanCast(ent)

                if can_cast then
                    inst.components.icey2_skill_phantom_sword:Cast(ent)
                else

                end
            end
        end,
    },
}
