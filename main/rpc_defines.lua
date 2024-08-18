AddModRPCHandler("icey2_rpc", "cast_skill", function(inst, name, pressed, x, y, z, ent)
    local skill_name_upper = name:upper()
    local skill_name_lower = name:lower()

    local data = GLOBAL.ICEY2_SKILL_DEFINES[skill_name_upper]
    local is_learned = inst.components.icey2_skiller:IsLearned(skill_name_lower)


    if is_learned then
        if pressed then
            if data.OnPressed then
                data.OnPressed(inst, x, y, z, ent)
            end
        else
            if data.OnReleased then
                data.OnReleased(inst, x, y, z, ent)
            end
        end
    end
end)

AddModRPCHandler("icey2_rpc", "debug_test_phantom_sword", function(inst, x, y, z, ent)
    GLOBAL.ICEY2_SKILL_DEFINES.PHANTOM_SWORD.OnPressed(inst, x, y, z, ent)
end)
