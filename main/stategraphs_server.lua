AddStategraphPostInit("wilson", function(sg)
    local old_locomote = sg.events["locomote"].fn
    sg.events["locomote"].fn = function(inst, data)
        if inst.sg:HasStateTag("busy") or
            inst.sg:HasStateTag("overridelocomote") then
            return
        end

        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()

        local handle_by_old = true

        if inst:HasTag("ingym") then

        elseif inst.sg:HasStateTag("bedroll") or inst.sg:HasStateTag("tent") or
            inst.sg:HasStateTag("waking") then -- wakeup on locomote

        elseif is_moving and not should_move then
            if inst:HasTag("acting") then

            else
                if not (inst.components.rider and inst.components.rider:IsRiding()) then
                    -- if inst:HasTag("icey2_skill_unarmoured_movement") then
                    --     handle_by_old = false
                    --     inst.sg:GoToState("icey2_skill_unarmoured_movement_stop")
                    -- else
                    if Icey2Basic.IsCarryingGunlance(inst, true) then
                        handle_by_old = false
                        inst.sg:GoToState("icey2_gunlance_ranged_run_stop")
                    end
                end
            end
        elseif not is_moving and should_move then
            if not (inst.components.rider and inst.components.rider:IsRiding()) then
                -- if inst:HasTag("icey2_skill_unarmoured_movement") then
                --     -- V2C: Added "dir" param so we don't have to add "canrotate" to all interruptible states
                --     if data and data.dir then
                --         inst.components.locomotor:SetMoveDir(data.dir)
                --     end
                --     handle_by_old = false
                --     inst.sg:GoToState("icey2_skill_unarmoured_movement_start")
                -- else
                if Icey2Basic.IsCarryingGunlance(inst, true) then
                    if data and data.dir then
                        inst.components.locomotor:SetMoveDir(data.dir)
                    end
                    handle_by_old = false
                    inst.sg:GoToState("icey2_gunlance_ranged_run_start")
                end
            end
        elseif data.force_idle_state and
            not (is_moving or should_move or inst.sg:HasStateTag("idle") or
                inst:HasTag("is_furling")) then

        end

        if handle_by_old then
            return old_locomote(inst, data)
        else

        end
    end
end)

-- Aoe weapon
AddStategraphPostInit("wilson", function(sg)
    local old_CASTAOE = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate = function(inst, action)
        local weapon = action.invobject
        if weapon and weapon:HasTag("icey2_aoeweapon") then
            local can_cast = weapon.components.aoetargeting:IsEnabled() and
                (weapon.components.rechargeable == nil or
                    weapon.components.rechargeable:IsCharged())

            if can_cast then
                if weapon.prefab == "icey2_pact_weapon_rapier" then
                    return "icey2_aoeweapon_flurry_lunge_pre"
                elseif weapon.prefab == "icey2_pact_weapon_chainsaw" then
                    return "attack"
                elseif weapon.prefab == "icey2_pact_weapon_hammer" then
                    return "icey2_ground_slam"
                end
            else
                return
            end
        end
        return old_CASTAOE(inst, action)
    end
end)


-- attack
AddStategraphPostInit("wilson", function(sg)
    local old_ATTACK = sg.actionhandlers[ACTIONS.ATTACK].deststate
    sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action)
        local old_rets = old_ATTACK(inst, action)
        local weapon = inst.components.combat:GetWeapon()
        if old_rets ~= nil
            and weapon
            and not (inst.components.rider and inst.components.rider:IsRiding()) then
            if Icey2Basic.IsCarryingGunlance(inst, true) then
                return "icey2_gunlance_ranged_attack"
            elseif Icey2Basic.IsCarryingGunlance(inst, false) then
                return "icey2_gunlance_melee_attack"
            elseif weapon.prefab == "icey2_pact_weapon_chainsaw" and not weapon:HasTag("without_pan") then
                return "icey2_chainsaw_attack"
            elseif weapon.prefab == "icey2_pact_weapon_hammer" then
                return "icey2_hammer_attack"
            elseif weapon.prefab == "icey2_test_shooter" then
                return "icey2_test_shoot_stream"
            end
        end

        return old_rets
    end
end)


-- idle
AddStategraphPostInit("wilson", function(sg)
    local function ModifyIdleState_Gunlance(state)
        local old_onenter = state.onenter

        state.onenter = function(inst, ...)
            local ret = old_onenter(inst, ...)
            if not (inst.components.rider and inst.components.rider:IsRiding())
                and Icey2Basic.IsCarryingGunlance(inst, true) then
                inst.sg:GoToState("icey2_gunlance_ranged_idle")
            end

            return ret
        end
    end

    local states_idle = {
        sg.states["idle"],
        sg.states["funnyidle"]
    }

    for _, state in pairs(states_idle) do
        ModifyIdleState_Gunlance(state)
    end
end)

-- eat
AddStategraphPostInit("wilson", function(sg)
    -- local old_EAT = sg.actionhandlers[ACTIONS.EAT].deststate
    -- sg.actionhandlers[ACTIONS.EAT].deststate = function(inst, action)
    --     local old_rets = old_EAT(inst, action)

    --     local feed = action.invobject
    --     if old_rets ~= nil and feed:HasTag("blood_metal") then
    --         return "eat"
    --     end
    --     return old_rets
    -- end


    local eat_SG = sg.states["eat"]
    if eat_SG then
        local old_onenter = eat_SG.onenter
        local old_onexit = eat_SG.onexit

        eat_SG.onenter = function(inst, data, ...)
            old_onenter(inst, data, ...)


            local feed
            local bufferedaction = inst:GetBufferedAction()
            if data and data.feed then
                feed = data.feed
            elseif bufferedaction and bufferedaction.invobject then
                feed = bufferedaction.invobject
            end

            if feed and feed:HasTag("blood_metal") then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating")
                inst.SoundEmitter:PlaySound("icey2_sfx/prefabs/blood_metal/eat_loop", "electric")

                -- inst.sg.statemem.soulfx = SpawnPrefab("wortox_eat_soul_fx")
                -- inst.sg.statemem.soulfx.entity:SetParent(inst.entity)
                -- if inst.components.rider:IsRiding() then
                --     inst.sg.statemem.soulfx:MakeMounted()
                -- end

                inst.sg.statemem.elec_vfx = inst:SpawnChild("icey2_eat_metal_blood_vfx")
                inst.sg.statemem.elec_vfx.entity:AddFollower()
                inst.sg.statemem.elec_vfx.Follower:FollowSymbol(inst.GUID, "face", 0, 60, 0)
            end
        end

        eat_SG.onexit = function(inst, ...)
            old_onexit(inst, ...)
            inst.SoundEmitter:KillSound("electric")

            if inst.sg.statemem.elec_vfx and inst.sg.statemem.elec_vfx:IsValid() then
                inst.sg.statemem.elec_vfx:Remove()
            end
        end
    end
end)

-- hammer
AddStategraphPostInit("wilson", function(sg)
    local old_HAMMER = sg.actionhandlers[ACTIONS.HAMMER].deststate
    sg.actionhandlers[ACTIONS.HAMMER].deststate = function(inst, action)
        local old_rets = old_HAMMER(inst, action)

        if old_rets ~= nil then
            local equip = action.invobject
            if equip and equip.prefab == "icey2_pact_weapon_hammer" then
                return "icey2_hammer_attack"
            end
        end
        return old_rets
    end
end)

-- attacked
-- AddStategraphPostInit("wilson", function(sg)
--     local old_attacked = sg.events["attacked"].fn
--     sg.events["attacked"].fn = function(inst, data)
--         if not inst.components.health:IsDead() and not inst.sg:HasStateTag("drowning") and not inst.sg:HasStateTag("falling") then
--             local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

--             if equip and equip:HasTag("icey2_parry_anim_hit") then
--                 inst.sg:GoToState("hit")
--             end
--         end

--         return old_attacked(inst, data)
--     end
-- end)


-----------------------------------------------------------------------------
-- Skill: dodge
AddStategraphState("wilson", State {
    name = "icey2_dodge",
    tags = { "busy", "nopredict", "nointerrupt", "noattack", "iframeskeepaggro" },

    onenter = function(inst, data)
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

        if equip then
            -- inst.AnimState:PlayAnimation("atk_leap_pre")
            inst.AnimState:PlayAnimation("atk_leap_lag")
        else
            inst.AnimState:PlayAnimation("icey2_speedrun_pre")
            inst.AnimState:PushAnimation("icey2_speedrun_loop", true)
        end

        inst.sg.statemem.equip = equip

        inst.components.icey2_skill_dodge:OnDodgeStart(data.pos)

        inst.sg:SetTimeout(0.2)
    end,

    onupdate = function(inst)
        inst.components.icey2_skill_dodge:OnDodging()
    end,

    timeline = {},

    ontimeout = function(inst)
        if inst.sg.statemem.equip then
            inst.AnimState:PlayAnimation("pickup_pst")
        else
            inst.AnimState:PlayAnimation("icey2_speedrun_pst")
        end

        -- print("OnDodgeStop ontimeout")
        inst.components.icey2_skill_dodge:OnDodgeStop()
        inst.sg.statemem.dodge_stop = true
        inst.sg:GoToState("idle", true)
    end,

    onexit = function(inst)
        if not inst.sg.statemem.dodge_stop then
            -- print("OnDodgeStop onexit")

            inst.components.icey2_skill_dodge:OnDodgeStop()
        end
    end
})

AddStategraphState("wilson", State {
    name = "icey2_dodge_riding",
    tags = { "busy", "pausepredict", "nointerrupt" },

    onenter = function(inst, data)
        inst.AnimState:PlayAnimation("run_pre")
        inst.AnimState:PushAnimation("run_loop", true)

        inst.sg.statemem.update = false
        inst.sg.statemem.last_step_time = GetTime()

        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(false)
        end
        inst.components.icey2_skill_dodge:OnDodgeStart(data.pos)

        SendModRPCToClient(CLIENT_MOD_RPC["icey2_rpc"]["goto_state_icey2_dodge_riding"], inst.userid, data.pos.x,
            data.pos.y,
            data.pos.z)

        inst.sg:SetTimeout(20 * FRAMES)
    end,

    onupdate = function(inst)
        if inst.sg.statemem.update then
            inst.components.icey2_skill_dodge:OnDodging()

            if GetTime() - inst.sg.statemem.last_step_time >= 2 * FRAMES then
                PlayFootstep(inst)
                inst.SoundEmitter:PlaySound("dontstarve/beefalo/walk", nil, 0.5)
                inst.sg.statemem.last_step_time = GetTime()
            end
        end
    end,

    timeline = {
        TimeEvent(2 * FRAMES, function(inst)
            PlayFootstep(inst)
            inst.SoundEmitter:PlaySound("dontstarve/beefalo/walk", nil, 0.5)
        end),

        TimeEvent(4 * FRAMES, function(inst)
            inst.sg.statemem.update = true
        end),
    },

    ontimeout = function(inst)
        inst.sg.statemem.update = false

        inst.components.icey2_skill_dodge:OnDodgeStop()
        inst.sg.statemem.dodge_stop = true

        inst.AnimState:PlayAnimation("run_pst")
        inst.sg:GoToState("idle", true)
    end,

    onexit = function(inst)
        if not inst.sg.statemem.dodge_stop then
            inst.components.icey2_skill_dodge:OnDodgeStop()
        end
        inst.components.playercontroller:Enable(true)
    end
})

-----------------------------------------------------------------------------
-- skill: parry
AddStategraphState("wilson", State {
    name = "icey2_parry_pre",
    tags = { "preparrying", "parrying", "busy", "nomorph", "nopredict" },

    onenter = function(inst, data)
        inst.sg.statemem.isshield = true

        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("shieldparry_pre")
        inst.AnimState:PushAnimation("shieldparry_loop", true)

        inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())

        inst.sg.statemem.parrytime = 99999
        inst.components.combat.redirectdamagefn = function(inst, attacker, damage, weapon, stimuli, spdamage)
            return inst.components.icey2_skill_parry
                and inst.components.icey2_skill_parry:TryParry(attacker, damage, weapon, stimuli, spdamage)
        end

        local s = 0.4

        local fxs = {
            SpawnPrefab("icey2_parry_shield_shining_fx"),
            SpawnPrefab("icey2_parry_shield_shining_fx"),
            SpawnPrefab("icey2_parry_shield_shining_fx")
        }

        for _, fx in pairs(fxs) do
            fx.entity:AddFollower()
            fx.Transform:SetScale(s, s, s)

            fx:ListenForEvent("animover", function()
                if not inst.AnimState:IsCurrentAnimation("shieldparry_pre")
                    and not inst.AnimState:IsCurrentAnimation("shieldparry_loop")
                    and not inst.AnimState:IsCurrentAnimation("shieldparry_pst")
                    and not inst.AnimState:IsCurrentAnimation("shieldparryblock") then
                    fx:Remove()
                end
            end, inst)
        end

        fxs[1].Follower:FollowSymbol(inst.GUID, "swap_shield", 0, 0, 0, nil, nil, 1)
        fxs[2].Follower:FollowSymbol(inst.GUID, "swap_shield", 35, -45, 0, nil, nil, 2)
        fxs[3].Follower:FollowSymbol(inst.GUID, "swap_shield", 59, -30, -0.05, nil, nil, 3)
    end,

    ontimeout = function(inst)
        inst.sg.statemem.parrying = true
        inst.sg:GoToState("parry_idle", {
            duration = inst.sg.statemem.parrytime,
            pauseframes = 30,
            isshield = inst.sg.statemem.isshield
        })
    end,


    timeline = {
        TimeEvent(0 * FRAMES, function(inst)

        end),
    },

    onexit = function(inst)
        if not inst.sg.statemem.parrying then
            inst.components.combat.redirectdamagefn = nil
        end
    end,


})
-------------------------------------------------------------------------------------------

local function DoEquipmentFoleySounds(inst)
    for k, v in pairs(inst.components.inventory.equipslots) do
        if v.foleysound ~= nil then
            inst.SoundEmitter:PlaySound(v.foleysound, nil, nil, true)
        end
    end
end

local function DoFoleySounds(inst)
    DoEquipmentFoleySounds(inst)
    if inst.foleysound ~= nil then
        inst.SoundEmitter:PlaySound(inst.foleysound, nil, nil, true)
    end
end

local function DoMountedFoleySounds(inst)
    DoEquipmentFoleySounds(inst)
    local saddle = inst.components.rider:GetSaddle()
    if saddle ~= nil and saddle.mounted_foleysound ~= nil then
        inst.SoundEmitter:PlaySound(saddle.mounted_foleysound, nil, nil, true)
    end
end

local DoRunSounds = function(inst)
    if inst.sg.mem.footsteps > 3 then
        PlayFootstep(inst, .6, true)
    else
        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
        PlayFootstep(inst, 1, true)
    end
end

-------------------------------------------------------------------------------------------
-- -- Locomote: unarmored movement
-- AddStategraphState("wilson", State {
--     name = "icey2_skill_unarmoured_movement_start",
--     tags = { "moving", "running", "canrotate", "autopredict" },

--     onenter = function(inst)
--         if not inst:HasTag("icey2_skill_unarmoured_movement") then
--             inst.sg:GoToState("run_start")
--             return
--         end

--         inst.components.locomotor:RunForward()
--         inst.AnimState:PlayAnimation(Icey2Basic.GetUnarmouredMovementAnim(inst, "pre"))

--         inst.sg.mem.footsteps = 0
--     end,

--     onupdate = function(inst) inst.components.locomotor:RunForward() end,

--     timeline = {
--         TimeEvent(5 * FRAMES, function(inst)
--             DoRunSounds(inst)
--             DoFoleySounds(inst)
--         end)
--     },

--     events = {
--         EventHandler("animover", function(inst)
--             if inst.AnimState:AnimDone() then
--                 inst.sg:GoToState("icey2_skill_unarmoured_movement")
--             end
--         end)
--     }
-- })

-- AddStategraphState("wilson", State {
--     name = "icey2_skill_unarmoured_movement",
--     tags = { "moving", "running", "canrotate", "autopredict" },

--     onenter = function(inst)
--         inst.components.locomotor:RunForward()

--         local anim = Icey2Basic.GetUnarmouredMovementAnim(inst, "loop")
--         if not inst.AnimState:IsCurrentAnimation(anim) then
--             inst.AnimState:PlayAnimation(anim, true)
--         end

--         inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
--     end,

--     onupdate = function(inst)
--         if not inst:HasTag("icey2_skill_unarmoured_movement") then
--             inst.sg:GoToState("run_start")
--             return
--         end
--         inst.components.locomotor:RunForward()
--     end,

--     timeline = {
--         TimeEvent(5 * FRAMES, function(inst)
--             DoRunSounds(inst)
--             DoFoleySounds(inst)
--         end),
--         TimeEvent(9 * FRAMES, function(inst)
--             DoRunSounds(inst)
--             DoFoleySounds(inst)
--         end),
--         TimeEvent(13 * FRAMES, function(inst)
--             DoRunSounds(inst)
--             DoFoleySounds(inst)
--         end),
--         TimeEvent(14 * FRAMES, function(inst)
--             DoRunSounds(inst)
--             DoFoleySounds(inst)
--         end),
--         TimeEvent(17 * FRAMES, function(inst)
--             DoRunSounds(inst)
--             DoFoleySounds(inst)
--         end)
--     },

--     events = {
--         -- EventHandler("gogglevision", function(inst, data)
--         --     if data.enabled then
--         --         if inst.sg.statemem.sandstorm then
--         --             inst.sg:GoToState("run")
--         --         end
--         --     elseif not (inst.sg.statemem.riding or inst.sg.statemem.heavy or
--         --         inst.sg.statemem.iswere or inst.sg.statemem.sandstorm) and
--         --         inst:IsInAnyStormOrCloud() then
--         --         inst.sg:GoToState("run")
--         --     end
--         -- end), EventHandler("stormlevel", function(inst, data)
--         --     if data.level < TUNING.SANDSTORM_FULL_LEVEL then
--         --         if inst.sg.statemem.sandstorm then
--         --             inst.sg:GoToState("run")
--         --         end
--         --     elseif not (inst.sg.statemem.riding or inst.sg.statemem.heavy or
--         --         inst.sg.statemem.iswere or inst.sg.statemem.sandstorm or
--         --         inst.components.playervision:HasGoggleVision()) then
--         --         inst.sg:GoToState("run")
--         --     end
--         -- end), EventHandler("miasmalevel", function(inst, data)
--         --     if data.level < 1 then
--         --         if inst.sg.statemem.sandstorm then
--         --             inst.sg:GoToState("run")
--         --         end
--         --     elseif not (inst.sg.statemem.riding or inst.sg.statemem.heavy or
--         --         inst.sg.statemem.iswere or inst.sg.statemem.sandstorm or
--         --         inst.components.playervision:HasGoggleVision()) then
--         --         inst.sg:GoToState("run")
--         --     end
--         -- end), EventHandler("carefulwalking", function(inst, data)
--         --     if not data.careful then
--         --         if inst.sg.statemem.careful then
--         --             inst.sg:GoToState("run")
--         --         end
--         --     elseif not (inst.sg.statemem.riding or inst.sg.statemem.heavy or
--         --         inst.sg.statemem.sandstorm or inst.sg.statemem.groggy or
--         --         inst.sg.statemem.careful or inst.sg.statemem.iswere) then
--         --         inst.sg:GoToState("run")
--         --     end
--         -- end)
--     },

--     ontimeout = function(inst)
--         inst.sg:GoToState("icey2_skill_unarmoured_movement")
--     end
-- })

-- AddStategraphState("wilson", State {
--     name = "icey2_skill_unarmoured_movement_stop",
--     tags = { "canrotate", "idle", "autopredict" },

--     onenter = function(inst)
--         inst.components.locomotor:Stop()
--         inst.AnimState:PlayAnimation(Icey2Basic.GetUnarmouredMovementAnim(inst, "pst"))
--     end,

--     timeline = {},

--     events = {
--         EventHandler("animover", function(inst)
--             if inst.AnimState:AnimDone() then
--                 inst.sg:GoToState("idle")
--             end
--         end)
--     }
-- })
-------------------------------------------------------------------------------------------

-- Locomote: carry gunlance with range attack form

AddStategraphState("wilson", State {
    name = "icey2_gunlance_ranged_run_start",
    tags = { "moving", "running", "canrotate", "autopredict" },

    onenter = function(inst)
        if not Icey2Basic.IsCarryingGunlance(inst, true) then
            inst.sg:GoToState("run_start")
            return
        end

        inst.Transform:SetEightFaced()
        inst.components.locomotor:RunForward()
        inst.AnimState:PlayAnimation("walk_tf2minigun_pre")

        inst.sg.mem.footsteps = 0
    end,

    onupdate = function(inst)
        inst.components.locomotor:RunForward()
    end,

    timeline = {
        TimeEvent(0 * FRAMES, function(inst)
            DoRunSounds(inst)
            DoFoleySounds(inst)
        end),
        TimeEvent(4 * FRAMES, function(inst)
            DoRunSounds(inst)
            DoFoleySounds(inst)
        end)
    },

    events = {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("icey2_gunlance_ranged_run")
            end
        end)
    },
    onexit = function(inst)
        inst.Transform:SetFourFaced()
    end,
})

AddStategraphState("wilson", State {
    name = "icey2_gunlance_ranged_run",
    tags = { "moving", "running", "canrotate", "autopredict" },

    onenter = function(inst)
        inst.Transform:SetEightFaced()

        inst.components.locomotor:RunForward()

        local anim = "walk_tf2minigun_loop"
        if not inst.AnimState:IsCurrentAnimation(anim) then
            inst.AnimState:PlayAnimation(anim, true)
        end

        inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
    end,

    onupdate = function(inst)
        if not Icey2Basic.IsCarryingGunlance(inst, true) then
            inst.sg:GoToState("run_start")
            return
        end
        inst.components.locomotor:RunForward()
    end,

    timeline = {
        TimeEvent(5 * FRAMES, function(inst)
            DoRunSounds(inst)
            DoFoleySounds(inst)
        end),
        TimeEvent(9 * FRAMES, function(inst)
            DoRunSounds(inst)
            DoFoleySounds(inst)
        end),
        TimeEvent(13 * FRAMES, function(inst)
            DoRunSounds(inst)
            DoFoleySounds(inst)
        end),
        TimeEvent(14 * FRAMES, function(inst)
            DoRunSounds(inst)
            DoFoleySounds(inst)
        end),
        TimeEvent(17 * FRAMES, function(inst)
            DoRunSounds(inst)
            DoFoleySounds(inst)
        end)
    },

    events = {

    },

    ontimeout = function(inst)
        inst.sg:GoToState("icey2_gunlance_ranged_run")
    end,

    onexit = function(inst)
        inst.Transform:SetFourFaced()
    end,
})

AddStategraphState("wilson", State {
    name = "icey2_gunlance_ranged_run_stop",
    tags = { "canrotate", "idle", "autopredict" },

    onenter = function(inst)
        inst.Transform:SetEightFaced()

        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("walk_tf2minigun_pst")
    end,

    timeline = {},

    events = {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    },

    onexit = function(inst)
        inst.Transform:SetFourFaced()
    end,
})

-------------------------------------------------------------------------------------------
-- Idle: carry gunlance with range attack form
AddStategraphState("wilson", State {
    name = "icey2_gunlance_ranged_idle",
    tags = { "idle", "canrotate", "notalking" },

    onenter = function(inst)
        inst.Transform:SetEightFaced()
        inst.AnimState:PlayAnimation("tf2minigun_shoot_pre", true)
    end,

    events =
    {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("icey2_gunlance_ranged_idle")
            end
        end),

        EventHandler("ontalk", function(inst)

        end),
    },

    onexit = function(inst)
        inst.Transform:SetFourFaced()
    end,
})

-----------------------------------------------------------------------------
-- attack: gunlance with range attack form
AddStategraphState("wilson", State {
    name = "icey2_gunlance_ranged_attack",
    tags = { "attack", "notalking", "abouttoattack", "autopredict" }, -- "autopredict"

    onenter = function(inst)
        if inst.components.combat:InCooldown() then
            inst.sg:RemoveStateTag("abouttoattack")
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle", true)
            return
        end

        local buffaction = inst:GetBufferedAction()
        local target = buffaction and buffaction.target or nil
        inst.components.combat:SetTarget(target)
        inst.components.combat:StartAttack()
        inst.components.locomotor:Stop()

        if target and target:IsValid() then
            inst:ForceFacePoint(target.Transform:GetWorldPosition())
            inst.sg.statemem.attacktarget = target
            inst.sg.statemem.retarget = target
        end

        -- inst.sg.statemem.chained = inst.AnimState:IsCurrentAnimation("tf2minigun_shoot")
        -- inst.sg.statemem.chained = (inst.sg.laststate == inst.sg.currentstate)
        inst.sg.statemem.chained = true

        inst.Transform:SetEightFaced()
        if not inst.AnimState:IsCurrentAnimation("tf2minigun_shoot") then
            inst.AnimState:PlayAnimation("tf2minigun_shoot", true)
        end

        local timeout = 33
        if not inst.sg.statemem.chained then

        else
            timeout = 12
        end

        inst.sg:SetTimeout(timeout * FRAMES)
    end,

    timeline =
    {
        -- not chained
        TimeEvent(1 * FRAMES, function(inst)
            if not inst.sg.statemem.chained then
                -- inst.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_gunlance/aim", "aim", nil, true)
            end
        end),

        -- chained
        TimeEvent(3 * FRAMES, function(inst)
            if inst.sg.statemem.chained then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),

        -- chained
        TimeEvent(4 * FRAMES, function(inst)
            if inst.sg.statemem.chained then
                inst.sg:RemoveStateTag("attack")
                inst.sg:AddStateTag("idle")
            end
        end),

        -- not chained
        TimeEvent(20 * FRAMES, function(inst)
            if not inst.sg.statemem.chained then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),

        -- not chained
        TimeEvent(21 * FRAMES, function(inst)
            if not inst.sg.statemem.chained then
                inst.sg:RemoveStateTag("attack")
                inst.sg:AddStateTag("idle")
            end
        end),


    },

    ontimeout = function(inst)
        inst.sg:GoToState("idle")
    end,

    events =
    {
        EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
    },

    onexit = function(inst)
        inst.components.combat:SetTarget(nil)
        if inst.sg:HasStateTag("abouttoattack") then
            inst.components.combat:CancelAttack()
        end
        inst.Transform:SetFourFaced()

        inst.SoundEmitter:KillSound("aim")
    end,
})


-----------------------------------------------------------------------------
-- attack: gunlance with melee attack form
AddStategraphState("wilson", State {
    name = "icey2_gunlance_melee_attack",
    tags = { "attack", "notalking", "abouttoattack", "autopredict" },

    onenter = function(inst)
        if inst.components.combat:InCooldown() then
            inst.sg:RemoveStateTag("abouttoattack")
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle", true)
            return
        end


        local buffaction = inst:GetBufferedAction()
        local target = buffaction ~= nil and buffaction.target or nil
        inst.components.combat:SetTarget(target)
        inst.components.combat:StartAttack()
        inst.components.locomotor:Stop()
        local cooldown = inst.components.combat.min_attack_period


        inst.AnimState:PlayAnimation("atk_pre")
        inst.AnimState:PushAnimation("atk", false)

        inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)

        cooldown = math.max(cooldown, 17 * FRAMES)

        inst.sg:SetTimeout(cooldown)

        if target ~= nil then
            inst.components.combat:BattleCry()
            if target:IsValid() then
                inst:FacePoint(target:GetPosition())
                inst.sg.statemem.attacktarget = target
                inst.sg.statemem.retarget = target
            end
        end
    end,



    timeline =
    {
        TimeEvent(2 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_gunlance/swipe", nil, 0.4, true)
        end),

        TimeEvent(8 * FRAMES, function(inst)
            inst:PerformBufferedAction()
            inst.sg:RemoveStateTag("abouttoattack")
        end),
    },


    ontimeout = function(inst)
        inst.sg:RemoveStateTag("attack")
        inst.sg:AddStateTag("idle")
    end,

    events =
    {
        EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        inst.components.combat:SetTarget(nil)
        if inst.sg:HasStateTag("abouttoattack") then
            inst.components.combat:CancelAttack()
        end
    end,
})


-----------------------------------------------------------------------------
--- chainsaw attack
AddStategraphState("wilson", State {
    name = "icey2_chainsaw_attack",
    tags = { "attack", "notalking", "abouttoattack", "autopredict" },

    onenter = function(inst)
        if inst.components.combat:InCooldown() then
            inst.sg:RemoveStateTag("abouttoattack")
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle", true)
            return
        end

        local buffaction = inst:GetBufferedAction()
        local target = buffaction ~= nil and buffaction.target or nil
        local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        inst.components.combat:SetTarget(target)
        inst.components.combat:StartAttack()
        inst.components.locomotor:Stop()
        local cooldown = inst.components.combat.min_attack_period

        inst.AnimState:PlayAnimation("atk_pre")
        inst.AnimState:PushAnimation("atk", false)

        -- if weapon and weapon:IsValid()
        --     and weapon.components.icey2_aoeweapon_launch_chainsaw
        --     and not weapon.components.icey2_aoeweapon_launch_chainsaw:GetProjectile() then
        --     inst.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_chainsaw/swipe", nil, nil, true)
        -- else
        --     inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)
        -- end
        inst.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_chainsaw/swipe", nil, nil, true)

        cooldown = math.max(cooldown, 17 * FRAMES)

        inst.sg:SetTimeout(cooldown)

        if target ~= nil then
            inst.components.combat:BattleCry()
            if target:IsValid() then
                inst:FacePoint(target:GetPosition())
                inst.sg.statemem.attacktarget = target
                inst.sg.statemem.retarget = target
            end
        end

        inst.sg.statemem.weapon = weapon
        inst.sg.statemem.emit_fx = true
        inst.sg.statemem.no_battle_focus_progress = false
    end,

    timeline =
    {
        TimeEvent(8 * FRAMES, function(inst)
            inst:PerformBufferedAction()

            inst.sg:RemoveStateTag("abouttoattack")

            inst.sg.statemem.emit_fx = false
            -- inst.sg.statemem.hide_anim = true
            inst.sg.statemem.no_battle_focus_progress = true
        end),
        TimeEvent(9 * FRAMES, function(inst)
            local weapon = inst.sg.statemem.weapon
            if weapon and weapon:IsValid()
                and weapon.components.icey2_aoeweapon_launch_chainsaw
                and not weapon.components.icey2_aoeweapon_launch_chainsaw:GetProjectile() then
                inst.components.combat:DoAttack(inst.sg.statemem.attacktarget, nil, nil, nil, 0.5)
            end
        end),
        TimeEvent(10 * FRAMES, function(inst)
            local weapon = inst.sg.statemem.weapon
            if weapon and weapon:IsValid()
                and weapon.components.icey2_aoeweapon_launch_chainsaw
                and not weapon.components.icey2_aoeweapon_launch_chainsaw:GetProjectile() then
                inst.components.combat:DoAttack(inst.sg.statemem.attacktarget, nil, nil, nil, 0.5)
            end
        end),
    },

    ontimeout = function(inst)
        inst.sg:RemoveStateTag("attack")
        inst.sg:AddStateTag("idle")
    end,

    events =
    {
        EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        inst.components.combat:SetTarget(nil)
        if inst.sg:HasStateTag("abouttoattack") then
            inst.components.combat:CancelAttack()
        end
    end,
})


-----------------------------------------------------------------------------
-- attack: hammer attack
AddStategraphState("wilson", State {
    name = "icey2_hammer_attack",
    tags = { "attack", "notalking", "abouttoattack", "autopredict" },

    onenter = function(inst)
        local buffaction = inst:GetBufferedAction()
        local cooldown = inst.components.combat.min_attack_period

        if buffaction then
            local target = buffaction.target
            inst.sg.statemem.actiontarget = target

            if buffaction.action == ACTIONS.ATTACK then
                if inst.components.combat:InCooldown() then
                    inst.sg:RemoveStateTag("abouttoattack")
                    inst:ClearBufferedAction()
                    inst.sg:GoToState("idle", true)
                    return
                end

                inst.components.combat:SetTarget(target)
                inst.components.combat:StartAttack()
                inst.components.locomotor:Stop()

                if target ~= nil then
                    inst.components.combat:BattleCry()
                    if target:IsValid() then
                        inst:FacePoint(target:GetPosition())
                        inst.sg.statemem.attacktarget = target
                        inst.sg.statemem.retarget = target
                    end
                end
            elseif buffaction.action == ACTIONS.HAMMER then
                inst.sg.statemem.is_hammer = true
            end
        end

        inst.AnimState:PlayAnimation("atk_pre")
        inst.AnimState:PushAnimation("atk", false)

        inst.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_hammer/swipe", nil, nil, true)

        cooldown = math.max(cooldown, 23 * FRAMES)

        inst.sg:SetTimeout(cooldown)
    end,



    timeline =
    {
        TimeEvent(8 * FRAMES, function(inst)
            local function emit_fn(ent)
                if ent ~= nil
                    and ent:IsValid()
                    and ent == inst.sg.statemem.actiontarget then
                    local spark = SpawnPrefab("hitsparks_fx")
                    spark:Setup(inst, ent)

                    inst.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_hammer/hit")
                end
            end

            if inst.sg.statemem.is_hammer then
                emit_fn(inst.sg.statemem.actiontarget)
            end

            local function callback(_, data)
                emit_fn(data.target)
            end
            inst:ListenForEvent("onhitother", callback)
            inst:PerformBufferedAction()
            inst:RemoveEventCallback("onhitother", callback)

            inst.sg:RemoveStateTag("abouttoattack")
        end),
    },


    ontimeout = function(inst)
        inst.sg:RemoveStateTag("attack")
        inst.sg:AddStateTag("idle")
    end,

    events =
    {
        EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        inst.components.combat:SetTarget(nil)
        if inst.sg:HasStateTag("abouttoattack") then
            inst.components.combat:CancelAttack()
        end
    end,
})

-----------------------------------------------------------------------------
-- aoe: flurry_lunge
AddStategraphState("wilson", State {
    name = "icey2_aoeweapon_flurry_lunge_pre",
    tags = { "aoe", "doing", "busy", "nopredict" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("lunge_pre")

        -- local weapon = inst.components.combat:GetWeapon()
        -- if weapon then
        --     local search_success = weapon.components.icey2_aoeweapon_flurry_lunge:SearchPossibleTargets(inst,
        --         data.target_pos)

        --     if not search_success then
        --         inst.sg:GoToState("idle")
        --         return
        --     end
        -- end
    end,

    timeline =
    {
        TimeEvent(4 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/twirl")
        end),
    },

    events =
    {
        EventHandler("icey2_aoeweapon_flurry_lunge_trigger", function(inst, data)
            local weapon = data.weapon

            if not (weapon and weapon:IsValid()) then
                inst.sg:GoToState("idle")
                return
            end

            local search_success = weapon.components.icey2_aoeweapon_flurry_lunge:SearchPossibleTargets(inst,
                data.target_pos)

            weapon.components.icey2_aoeweapon_flurry_lunge:SpawnFlashFX(inst)

            if not search_success then
                -- inst.sg:GoToState("idle")
                inst.Transform:SetPosition(data.target_pos:Get())
                inst.sg:GoToState("icey2_aoeweapon_flurry_lunge_final", { weapon = weapon })
                return
            end

            local target = weapon.components.icey2_aoeweapon_flurry_lunge:PopTarget(inst)

            if target then
                inst.sg:GoToState("icey2_aoeweapon_flurry_lunge", {
                    middle_pos = data.target_pos,
                    weapon = weapon,
                    target = target,
                })
            else
                inst.sg:GoToState("idle")
            end
        end),

        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                if inst.AnimState:IsCurrentAnimation("lunge_pre") then
                    inst.AnimState:PlayAnimation("lunge_lag")
                    inst:PerformBufferedAction()
                else
                    inst.sg:GoToState("idle")
                end
            end
        end),

        EventHandler("equip", function(inst)
            inst.sg:GoToState("idle")
        end),

        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
    },
})


AddStategraphState("wilson", State {
    name = "icey2_aoeweapon_flurry_lunge",
    tags = { "aoe", "doing", "busy", "nopredict", },

    onenter = function(inst, data)
        local weapon = data.weapon
        local target = data.target
        local failed = true

        if weapon and target and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == weapon then
            inst.AnimState:PlayAnimation("lunge_pst")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/fireball")

            inst.components.health:SetInvincible(true)

            weapon.components.icey2_aoeweapon_flurry_lunge:SpawnFlashFX(inst)
            weapon.components.icey2_aoeweapon_flurry_lunge:TeleportNearTarget(inst, target)

            inst.sg.statemem.weapon = weapon
            inst.sg.statemem.middle_pos = data.middle_pos
            inst.sg.statemem.target = target
            inst.sg.statemem.flash = 1

            local r, g, b = 96 / 255, 249 / 255, 255 / 255
            inst.sg.statemem.rgb = Vector3(r, g, b)
            inst.components.colouradder:PushColour("lunge", r, g, b, 0)

            inst.sg:SetTimeout(8 * FRAMES)

            failed = false
        end

        if failed then
            inst.sg:GoToState("idle")
        end
    end,

    onupdate = function(inst)
        if inst.sg.statemem.flash and inst.sg.statemem.flash > 0 then
            inst.sg.statemem.flash = math.max(0, inst.sg.statemem.flash - .1)

            local r, g, b = (inst.sg.statemem.rgb * inst.sg.statemem.flash):Get()
            inst.components.colouradder:PushColour("lunge", r, g, b, 0)
        end
    end,

    ontimeout = function(inst)
        local weapon = inst.sg.statemem.weapon

        if not (weapon and weapon:IsValid()) then
            inst.sg:GoToState("idle")
            return
        end

        local target = weapon.components.icey2_aoeweapon_flurry_lunge:PopTarget(inst)
        if target then
            inst.sg:GoToState("icey2_aoeweapon_flurry_lunge", {
                middle_pos = inst.sg.statemem.middle_pos,
                weapon = weapon,
                target = target,
            })
        else
            if inst.sg.statemem.middle_pos then
                weapon.components.icey2_aoeweapon_flurry_lunge:SpawnFlashFX(inst)
                inst.Transform:SetPosition(inst.sg.statemem.middle_pos:Get())
                inst.sg:GoToState("icey2_aoeweapon_flurry_lunge_final", { weapon = weapon })
            else
                inst.sg:GoToState("idle", true)
            end
        end
    end,

    timeline =
    {
        TimeEvent(3 * FRAMES, function(inst)
            inst.sg.statemem.weapon.components.icey2_aoeweapon_flurry_lunge:Attack(inst, inst.sg.statemem.target)
        end),
    },

    events = {
        EventHandler("equip", function(inst)
            inst.sg:GoToState("idle")
        end),
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
    },

    onexit = function(inst)
        -- inst.components.bloomer:PopBloom("lunge")
        -- inst.components.colouradder:PopColour("lunge")
        inst.components.health:SetInvincible(false)
        inst.components.colouradder:PopColour("lunge")
    end,
})

AddStategraphState("wilson", State {
    name = "icey2_aoeweapon_flurry_lunge_final",
    -- tags = { "aoe", "attack", "abouttoattack", "busy", "nopredict" },
    -- tags = { "aoe", "attack", "abouttoattack", "nopredict" },
    tags = { "aoe", "attack", "abouttoattack", },


    onenter = function(inst, data)
        inst.sg.statemem.weapon = data.weapon

        if not (data.weapon and data.weapon:IsValid()) then
            inst.sg:GoToState("idle")
            return
        end

        inst.Transform:SetEightFaced()


        inst.AnimState:PlayAnimation("atk_leap")

        -- inst.AnimState:PlayAnimation("superjump_land")
        -- inst.AnimState:SetTime(FRAMES * 4)

        inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")

        -- inst:ForceFacePoint(inst.sg.statemem.targetpos)

        local r, g, b = 96 / 255, 249 / 255, 255 / 255
        inst.sg.statemem.rgb = Vector3(r, g, b)
        inst.components.colouradder:PushColour("superjump", r, g, b, 0)

        -- inst.AnimState:SetDeltaTimeMultiplier(0.5)

        -- inst.sg.statemem.vfx = inst:SpawnChild("icey2_superjump_land_vfx")


        if inst.sg.statemem.weapon and inst.sg.statemem.weapon:IsValid() then
            inst.sg.statemem.weapon.components.icey2_aoeweapon_flurry_lunge:StartFinalBlow(inst)
        end

        inst.components.health:SetInvincible(true)
    end,

    onupdate = function(inst)
        if inst.sg.statemem.flash and inst.sg.statemem.flash > 0 then
            inst.sg.statemem.flash = math.max(0, inst.sg.statemem.flash - .1)

            local r, g, b = (inst.sg.statemem.rgb * inst.sg.statemem.flash):Get()
            inst.components.colouradder:PushColour("superjump", r, g, b, 0)
        end
    end,

    timeline = {
        TimeEvent(10 * FRAMES, function(inst)
            inst.sg.statemem.flash = 1
        end),

        TimeEvent(13 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/destroy_smoke")
            ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)

            if inst.sg.statemem.weapon and inst.sg.statemem.weapon:IsValid() then
                inst.sg.statemem.weapon.components.icey2_aoeweapon_flurry_lunge:FinalBlow(inst)
            end

            -- inst.components.health:SetInvincible(false)

            -- SpawnAt("moonpulse_fx", inst, { 0.5, 0.5, 0, 5 })
        end),

        TimeEvent(15 * FRAMES, function(inst)
            for i = 0, 2 do
                local emitfx = inst:SpawnChild("icey2_weapon_change_vfx")
                emitfx.entity:AddFollower()
                emitfx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -i * 100, 0, true)
                emitfx:DoTaskInTime(0.5, emitfx.Remove)
            end
        end),

        TimeEvent(16 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("abouttoattack")
        end),

        TimeEvent(16 * FRAMES, function(inst)
            if inst.sg.statemem.weapon and inst.sg.statemem.weapon:IsValid() then
                inst.sg.statemem.weapon.components.icey2_aoeweapon_flurry_lunge:StopFinalBlow(inst, true)
                inst.sg.statemem.run_stop_fn = true
            end

            -- inst.sg:GoToState("idle", true)
            inst.sg:AddStateTag("idle")
        end),

        -- TimeEvent(0 * FRAMES, function(inst)
        --     inst.sg.statemem.flash = 1
        --     inst.SoundEmitter:PlaySound("dontstarve/common/destroy_smoke")
        -- end),

        -- TimeEvent(1 * FRAMES, function(inst)
        --     inst.sg.statemem.flash = 1
        --     inst.SoundEmitter:PlaySound("dontstarve/common/destroy_smoke")

        --     local fx = SpawnAt("icey2_shiny_explode_fx", inst)
        --     fx.AnimState:SetDeltaTimeMultiplier(1.5)
        -- end),

        -- TimeEvent(4 * FRAMES, function(inst)
        --     ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)

        --     if inst.sg.statemem.weapon and inst.sg.statemem.weapon:IsValid() then
        --         inst.sg.statemem.weapon.components.icey2_aoeweapon_flurry_lunge:FinalBlow(inst)
        --     end

        --     inst.AnimState:SetDeltaTimeMultiplier(1)
        -- end),

        -- TimeEvent(6 * FRAMES, function(inst)
        --     if inst.sg.statemem.vfx and inst.sg.statemem.vfx:IsValid() then
        --         inst.sg.statemem.vfx:Remove()
        --     end
        -- end),

        -- TimeEvent(15 * FRAMES, function(inst)
        --     inst.sg:RemoveStateTag("abouttoattack")
        --     inst.sg:GoToState("idle", true)
        -- end),
    },

    events = {
        EventHandler("equip", function(inst)
            inst.sg:GoToState("idle")
        end),
        EventHandler("unequip", function(inst)
            inst.sg:GoToState("idle")
        end),
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

    onexit = function(inst)
        inst.Transform:SetFourFaced()
        inst.AnimState:SetDeltaTimeMultiplier(1)
        inst.components.colouradder:PopColour("superjump")

        if inst.sg.statemem.vfx and inst.sg.statemem.vfx:IsValid() then
            inst.sg.statemem.vfx:Remove()
        end

        if inst.sg.statemem.weapon
            and inst.sg.statemem.weapon:IsValid()
            and not inst.sg.statemem.run_stop_fn then
            inst.sg.statemem.weapon.components.icey2_aoeweapon_flurry_lunge:StopFinalBlow(inst, false)
        end

        inst.components.health:SetInvincible(false)
    end,
})

AddStategraphState("wilson",
    State
    {
        name = "icey2_circle_attack_pre",
        tags = { "aoe", "attack", "abouttoattack" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation("chop_pre")
            inst.AnimState:PushAnimation("chop_lag", false)

            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")

            inst.sg:SetTimeout(2)
        end,

        ontimeout = function(inst)
            -- inst.sg:GoToState("icey2_circle_attack")
            inst.sg:GoToState("idle")
        end,

        timeline = {
            TimeEvent(33 * FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },

        events = {
            EventHandler("icey2_start_circle_attack", function(inst, data)
                inst.sg:GoToState("icey2_circle_attack")
            end),
        },

        onexit = function(inst)

        end,
    }
)

AddStategraphState("wilson",
    State
    {
        name = "icey2_circle_attack",
        tags = { "aoe", "attack", "abouttoattack" },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.Transform:SetTwoFaced()

            inst.AnimState:SetDeltaTimeMultiplier(1.5)
            inst.AnimState:PlayAnimation("icey2atk_circle0")
            inst.AnimState:PushAnimation("icey2atk_circle2", false)
            inst.AnimState:PushAnimation("icey2atk_circle3", false)

            -- inst.SoundEmitter:PlaySound("gale_sfx/character/gale_harpy_whirl")

            local fx = SpawnAt("icey2_circle_attack_fx", inst)
            fx.Transform:SetRotation(inst.Transform:GetRotation())
        end,

        onupdate = function(inst)
            local bufferedaction = inst:GetBufferedAction()
            if bufferedaction ~= nil then
                inst.sg:GoToState("idle", true)
            end
        end,

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("icey2_circle_attack")
                end
            end),
        },

        timeline = {
            -- TimeEvent(1 * FRAMES, function(inst)
            --     ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.5, inst, 40)
            -- end),

            -- TimeEvent(3 * FRAMES, function(inst)
            --     ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.5, inst, 40)
            -- end),

            -- TimeEvent(6 * FRAMES, function(inst)
            --     ShakeAllCameras(CAMERASHAKE.FULL, .35, .02, 0.5, inst, 40)
            -- end),
        },

        onexit = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(1)
            inst.Transform:SetFourFaced()
        end,
    }
)

AddStategraphState("wilson",
    State {
        name = "icey2_ground_slam",
        tags = { "aoe", "doing", "busy", "nopredict", "noattack" },

        onenter = function(inst)
            inst.Physics:Stop()

            local function callback(_, data)
                inst.sg.statemem.weapon = data.weapon
                inst.sg.statemem.target_pos = data.target_pos
            end

            inst:ListenForEvent("icey2_ground_slam", callback)
            inst:PerformBufferedAction()
            inst:RemoveEventCallback("icey2_ground_slam", callback)

            local weapon = inst.sg.statemem.weapon
            local target_pos = inst.sg.statemem.target_pos
            if weapon == nil
                or not weapon:IsValid()
                or weapon.components.icey2_aoeweapon_ground_slam == nil
                or target_pos == nil then
                inst.sg:GoToState("idle")
                return
            end

            local my_pos = inst:GetPosition()
            local speed = (target_pos - my_pos):Length() / (14 * FRAMES)
            inst.sg.statemem.speed = speed
            inst:ForceFacePoint(target_pos)

            inst.AnimState:PlayAnimation("jumpout")
            inst.AnimState:SetTime(4 * FRAMES)


            -- inst.SoundEmitter:PlaySound("spark_hammer/sfx/enm_hand_jump")
            inst.SoundEmitter:PlaySound("dontstarve/common/deathpoof")

            inst.components.health:SetInvincible(true)
            weapon.components.icey2_aoeweapon_ground_slam:OnStart(inst, target_pos)
        end,

        onupdate = function(inst)
            if inst.sg.statemem.speed > 0 then
                inst.Physics:SetMotorVel(inst.sg.statemem.speed, 0, 0)
            end
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
                local weapon = inst.sg.statemem.weapon
                if weapon and weapon:IsValid() and weapon.components.icey2_aoeweapon_ground_slam then
                    weapon.components.icey2_aoeweapon_ground_slam:PushAddColour(inst)
                end
            end),

            TimeEvent(14 * FRAMES, function(inst)
                inst.sg.statemem.speed = 0
                inst.Physics:Stop()


                local weapon = inst.sg.statemem.weapon
                if weapon and weapon:IsValid() and weapon.components.icey2_aoeweapon_ground_slam then
                    weapon.components.icey2_aoeweapon_ground_slam:DoAreaAttack(inst)
                    weapon.components.icey2_aoeweapon_ground_slam:TossNearbyItems(inst)
                    weapon.components.icey2_aoeweapon_ground_slam:IgniteNearbyThings(inst, inst:GetPosition(), 0.33)
                    weapon.components.icey2_aoeweapon_ground_slam:SpawnFX(inst, inst:GetPosition())
                end

                ShakeAllCameras(CAMERASHAKE.VERTICAL, .7, .015, .8, inst, 20)
                inst.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_hammer/hit_ground")

                if Icey2Basic.IsWearingArmor(inst) then
                    inst.sg:GoToState("slip_fall")
                    -- inst.AnimState:SetTime(10 * FRAMES)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
            inst.Physics:Stop()
            inst.components.health:SetInvincible(false)
            local weapon = inst.sg.statemem.weapon
            if weapon and weapon:IsValid() and weapon.components.icey2_aoeweapon_ground_slam then
                weapon.components.icey2_aoeweapon_ground_slam:OnStop(inst)
            end
        end
    }
)
--------------------------------------------------------------------------


local START_SHOOT_TIME = 10 * FRAMES
local FREE_TIME = 11 * FRAMES
local WITHDRAW_GUN_TIME = 15 * FRAMES
local CHAIN_IN_ADVANCE_TIME = 10 * FRAMES

AddStategraphState("wilson", State {
    name = "icey2_test_shoot_stream",
    tags = { "attack", "notalking", "abouttoattack", "autopredict" },

    onenter = function(inst)
        if inst.components.combat:InCooldown() then
            inst.sg:RemoveStateTag("abouttoattack")
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle", true)
            return
        end

        local buffaction = inst:GetBufferedAction()
        local target = buffaction ~= nil and buffaction.target or nil
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        inst.components.combat:SetTarget(target)
        inst.components.combat:StartAttack()
        inst.components.locomotor:Stop()


        if target ~= nil and target:IsValid() then
            inst:FacePoint(target.Transform:GetWorldPosition())
            inst.sg.statemem.attacktarget = target
            inst.sg.statemem.retarget = target
        end

        inst.sg.statemem.chained = inst.AnimState:IsCurrentAnimation("hand_shoot")
        -- inst.sg.statemem.chained = (inst.sg.laststate == inst.sg.currentstate)

        inst.AnimState:PlayAnimation("hand_shoot")

        if inst.sg.statemem.chained then
            inst.AnimState:SetTime(CHAIN_IN_ADVANCE_TIME)
        end

        local timeout = inst.components.combat.min_attack_period
        if not inst.sg.statemem.chained then
            timeout = math.max(timeout, FREE_TIME)
        else
            timeout = math.max(timeout, FREE_TIME - CHAIN_IN_ADVANCE_TIME)
        end

        inst.sg:SetTimeout(timeout)
    end,


    ontimeout = function(inst)
        inst.sg:RemoveStateTag("attack")
        inst.sg:AddStateTag("idle")
    end,

    timeline =
    {
        TimeEvent(START_SHOOT_TIME - CHAIN_IN_ADVANCE_TIME, function(inst)
            if inst.sg.statemem.chained then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),

        TimeEvent(WITHDRAW_GUN_TIME - CHAIN_IN_ADVANCE_TIME, function(inst)
            if inst.sg.statemem.chained then
                inst.AnimState:SetTime(27 * FRAMES)
            end
        end),

        TimeEvent(START_SHOOT_TIME, function(inst)
            if not inst.sg.statemem.chained then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),

        TimeEvent(WITHDRAW_GUN_TIME, function(inst)
            if not inst.sg.statemem.chained then
                inst.AnimState:SetTime(27 * FRAMES)
            end
        end),
    },

    events =
    {
        EventHandler("equip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },


    onexit = function(inst)
        inst.components.combat:SetTarget(nil)
        if inst.sg:HasStateTag("abouttoattack") then
            inst.components.combat:CancelAttack()
        end
    end,
})
