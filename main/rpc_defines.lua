local Icey2MainMenu = require("screens/icey2_main_menu")

AddModRPCHandler("icey2_rpc", "cast_skill", function(inst, name, pressed, x, y, z, ent)
    local data = ICEY2_SKILL_DEFINES[name]
    local is_learned = inst.components.icey2_skiller:IsLearned(name)


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

AddModRPCHandler("icey2_rpc", "summon_pact_weapon", function(inst, prefabname)
    if inst.components.icey2_skill_summon_pact_weapon then
        inst.components.icey2_skill_summon_pact_weapon:SummonWeapon(prefabname)
    end
end)


AddModRPCHandler("icey2_rpc", "remove_pact_weapon", function(inst)
    if inst.components.icey2_skill_summon_pact_weapon then
        inst.components.icey2_skill_summon_pact_weapon:UnlinkWeapon(true)
    end
end)



AddClientModRPCHandler("icey2_rpc", "play_skill_learned_anim", function(name)
    local screen = Icey2MainMenu(ThePlayer)
    TheFrontEnd:PushScreen(screen)

    screen:PlaySkillLearnedAnim_Part1(name)
end)

-- SendModRPCToClient(CLIENT_MOD_RPC["icey2_rpc"]["play_skill_learned_anim"], ThePlayer.userid, "PHANTOM_SWORD")

-- AddModRPCHandler("icey2_rpc", "debug_test_phantom_sword", function(inst, x, y, z, ent)
--     ICEY2_SKILL_DEFINES.PHANTOM_SWORD.OnPressed(inst, x, y, z, ent)
-- end)
