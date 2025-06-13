local Icey2MainMenu = require("screens/icey2_main_menu")

AddModRPCHandler("icey2_rpc", "cast_skill", function(inst, name, pressed, x, y, z, ent)
    local data = Icey2Basic.GetSkillDefine(name)
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


AddModRPCHandler("icey2_rpc", "remove_pact_weapon", function(inst, prefabname_or_ent)
    if inst.components.icey2_skill_summon_pact_weapon then
        inst.components.icey2_skill_summon_pact_weapon:UnlinkWeapon(prefabname_or_ent, true)
    end
end)

AddModRPCHandler("icey2_rpc", "remove_all_pact_weapon", function(inst)
    if inst.components.icey2_skill_summon_pact_weapon then
        inst.components.icey2_skill_summon_pact_weapon:UnlinkAllWeapons(true)
    end
end)

--  SendModRPCToServer(MOD_RPC["icey2_rpc"]["learn_skill"], "NEW_PACT_WEAPON_SCYTHE", 0.4,true)
-- SendModRPCToServer(MOD_RPC["icey2_rpc"]["learn_skill"], "NEW_PACT_WEAPON_SCYTHE",true,1)
-- SendModRPCToServer(MOD_RPC["icey2_rpc"]["learn_skill"], "BATTLE_FOCUS",true,1)
AddModRPCHandler("icey2_rpc", "learn_skill", function(inst, skill_name, show_anim, show_emote, emote_anim)
    if inst.components.icey2_skiller and inst.components.icey2_skiller:Learn(skill_name) then
        if show_emote then
            -- inst.sg:GoToState("emote", { anim = "emote_swoon" })
            -- inst.AnimState:SetTime(1)

            -- inst.sg:GoToState("emote", { anim = "emoteXL_happycheer" })
            emote_anim = emote_anim or "emote_swoon"
            inst.sg:GoToState("emote", { anim = emote_anim })

            if type(show_emote) == "number" then
                inst.AnimState:SetTime(show_emote)
            end
        end
        if show_anim then
            if type(show_anim) == "number" then
                inst:DoTaskInTime(show_anim, function()
                    SendModRPCToClient(CLIENT_MOD_RPC["icey2_rpc"]["play_skill_learned_anim"], inst.userid, skill_name)
                end)
            else
                SendModRPCToClient(CLIENT_MOD_RPC["icey2_rpc"]["play_skill_learned_anim"], inst.userid, skill_name)
            end
        end
    end
end)


AddClientModRPCHandler("icey2_rpc", "play_skill_learned_anim", function(skill_name)
    local screen = Icey2MainMenu(ThePlayer)
    TheFrontEnd:PushScreen(screen)

    screen:PlaySkillLearnedAnim_Part1(skill_name)
end)

AddModRPCHandler("icey2_rpc", "update_mouse_position", function(inst, x, z)
    if inst.components.icey2_control_key_helper then
        inst.components.icey2_control_key_helper:SetMousePosition(Vector3(x, 0, z))
    end
end)

AddClientModRPCHandler("icey2_rpc", "push_shield_charge_anim", function()
    if ThePlayer
        and ThePlayer.HUD
        and ThePlayer.HUD.controls
        and ThePlayer.HUD.controls.secondary_status
        and ThePlayer.HUD.controls.secondary_status.icey2_skill_shield_metrics then
        ThePlayer.HUD.controls.secondary_status.icey2_skill_shield_metrics:PushChargeShield()
    end
end)

AddClientModRPCHandler("icey2_rpc", "start_soul_absorb_circle", function()
    if ThePlayer
        and ThePlayer.HUD
        and ThePlayer.HUD.controls
        and ThePlayer.HUD.controls.icey2_soul_absorb_circle then
        ThePlayer.HUD.controls.icey2_soul_absorb_circle:Start()
    end
end)

AddClientModRPCHandler("icey2_rpc", "play_install_dodge_charge_chip_anim", function()
    if ThePlayer
        and ThePlayer.HUD
        and ThePlayer.HUD.controls
        and ThePlayer.HUD.controls.secondary_status
        and ThePlayer.HUD.controls.secondary_status.icey2_skill_shield_metrics then
        ThePlayer.HUD.controls.secondary_status.icey2_skill_shield_metrics:PlayChipInstallAnim()
    end
end)

AddClientModRPCHandler("icey2_rpc", "force_face_point", function(x, y, z)
    if ThePlayer and ThePlayer:IsValid() then
        ThePlayer:ForceFacePoint(x, y, z)
    end
end)

AddClientModRPCHandler("icey2_rpc", "goto_state_icey2_dodge_riding", function(x, y, z)
    if ThePlayer
        and ThePlayer:IsValid()
        and ThePlayer.sg
        and ThePlayer.sg.sg
        and ThePlayer.sg.sg.name == "wilson_client" then
        ThePlayer.sg:GoToState("icey2_dodge_riding", { pos = Vector3(x, y, z) })
    end
end)
