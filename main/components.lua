AddReplicableComponent("icey2_skiller")
AddReplicableComponent("icey2_skill_summon_pact_weapon")
AddReplicableComponent("icey2_skill_shield")
AddReplicableComponent("icey2_skill_parry")
AddReplicableComponent("icey2_versatile_weapon")
AddReplicableComponent("icey2_skill_dodge")


AddComponentPostInit("stageactingprop", function(self)
    local play_commonfns = require("play_commonfn")

    local my_scripts = {}

    my_scripts.ICEY2_SELF_ACT = {
        cast = { "icey2" },
        lines = {
            { actionfn = play_commonfns.actorsbow, duration = 2.5, },

            {
                roles = { "icey2" },
                duration = 3.0,
                line = STRINGS.STAGEACTOR.ICEY2_SELF_ACT[1]
            },

            {
                roles = { "icey2" },
                duration = 3.0,
                line = STRINGS.STAGEACTOR.ICEY2_SELF_ACT[2]
            },

            {
                roles = { "icey2" },
                duration = 1.0,
                anim = { "hit", "idle_loop" },
                animtype = "loop",
                line = STRINGS.STAGEACTOR.ICEY2_SELF_ACT[3],
                castsound = {
                    icey2 = "dontstarve/characters/wendy/hurt"
                },
            },

            {
                roles = { "icey2" },
                duration = 3.0,
                anim = { "idle_sanity_pre", "idle_sanity_loop" },
                animtype = "loop",
                line = STRINGS.STAGEACTOR.ICEY2_SELF_ACT[4]
            },

            {
                roles = { "icey2" },
                duration = 5.0,
                anim = { "idle_sanity_loop" },
                animtype = "loop",
                line = STRINGS.STAGEACTOR.ICEY2_SELF_ACT[5]
            },

            {
                roles = { "icey2" },
                anim = { "emote_laugh", "idle_loop" },
                animtype = "loop",
                duration = 3.0,
                line = STRINGS.STAGEACTOR.ICEY2_SELF_ACT[6]
            },
        },
    }

    for i = 7, 20 do
        local data = {
            roles = { "icey2" },
            duration = 3.0,
            line = STRINGS.STAGEACTOR.ICEY2_SELF_ACT[i]
        }

        if i == 8 then
            data.anim = { "wendy_commune_pre", "wendy_commune_pst", "idle_loop" }
            data.animtype = "loop"
        elseif i == 10 then
            data.anim = { "idle_wx", "idle_loop" }
            data.animtype = "loop"
        elseif i == 12 then
            data.anim = { "emote_flex", "idle_loop" }
            data.animtype = "loop"
        elseif i == 14 then
            data.anim = { "emoteXL_waving4", "idle_loop" }
            data.animtype = "loop"
        elseif i == 16 then
            data.anim = { "emote_pre_sit1", "emote_loop_sit1" }
            data.animtype = "loop"
        elseif i == 18 then
            data.actionfn = function(inst, line, cast)
                -- fx = "tears", fxdelay =
                if cast == nil then
                    return
                end

                local caster_data = cast.icey2
                if caster_data == nil then
                    return
                end

                local castmember = caster_data.castmember
                if castmember == nil then
                    return
                end

                castmember:DoTaskInTime(17 * FRAMES, function()
                    local fx = SpawnPrefab("tears")
                    if fx ~= nil then
                        fx.entity:SetParent(castmember.entity)
                        fx.entity:AddFollower()
                        fx.Follower:FollowSymbol(castmember.GUID, "emotefx", 0, 0, 0)
                    end
                end)
            end
            data.anim = { "emoteXL_sad", "idle_loop" }
            data.animtype = "loop"
        elseif i == 20 then
            data.anim = { "emote_swoon", "idle_loop" } -- TODO
            data.animtype = "loop"
        end

        table.insert(my_scripts.ICEY2_SELF_ACT.lines, data)
    end

    local tail_datas = {
        {
            roles = { "icey2" },
            anim = { "idle_sanity_pre", "idle_sanity_loop" },
            animtype = "loop",
            duration = 5.0,
            line = STRINGS.STAGEACTOR.ICEY2_SELF_ACT[21],
        },

        {
            roles = { "icey2" },
            anim = { "emoteXL_facepalm", "idle_loop" },
            animtype = "loop",
            duration = 3.0,
            line = STRINGS.STAGEACTOR.ICEY2_SELF_ACT[22]
        },

        { actionfn = play_commonfns.actorsbow, duration = 0.2, },
    }

    for _, v in pairs(tail_datas) do
        table.insert(my_scripts.ICEY2_SELF_ACT.lines, v)
    end

    for script_name, script_data in pairs(my_scripts) do
        self:AddGeneralScript(script_name, script_data)
    end
end)
