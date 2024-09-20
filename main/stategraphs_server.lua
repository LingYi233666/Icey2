AddStategraphState("wilson", State {
    name = "icey2_dodge",
    tags = { "busy", "evade", "dodge", "no_stun", "nopredict", "nointerrupt" },

    onenter = function(inst, data)
        -- inst.AnimState:PlayAnimation("atk_leap_pre")

        local equip =
            inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

        if equip then
            inst.AnimState:PlayAnimation("atk_leap_lag")
        else
            inst.AnimState:PlayAnimation("icey2_speedrun_pre")
            inst.AnimState:PushAnimation("icey2_speedrun_loop", true)
        end

        inst.sg.statemem.equip = equip

        inst.components.icey2_skill_dodge:OnDodgeStart(data.pos)

        inst.sg:SetTimeout(0.2)
    end,

    onupdate = function(inst) inst.components.icey2_skill_dodge:OnDodging() end,

    timeline = {},

    ontimeout = function(inst)
        if inst.sg.statemem.equip then
            inst.AnimState:PlayAnimation("pickup_pst")
        else
            inst.AnimState:PlayAnimation("icey2_speedrun_pst")
        end
        inst.sg:GoToState("idle", true)
    end,

    onexit = function(inst) inst.components.icey2_skill_dodge:OnDodgeStop() end
})

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
                if inst:HasTag("icey2_skill_unarmoured_movement") then
                    handle_by_old = false
                    inst.sg:GoToState("icey2_skill_unarmoured_movement_stop")
                else

                end
            end
        elseif not is_moving and should_move then
            if inst:HasTag("icey2_skill_unarmoured_movement") then
                -- V2C: Added "dir" param so we don't have to add "canrotate" to all interruptible states
                if data and data.dir then
                    inst.components.locomotor:SetMoveDir(data.dir)
                end
                handle_by_old = false
                inst.sg:GoToState("icey2_skill_unarmoured_movement_start")
            else

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

AddStategraphState("wilson", State {
    name = "icey2_skill_unarmoured_movement_start",
    tags = { "moving", "running", "canrotate", "autopredict" },

    onenter = function(inst)
        if not inst:HasTag("icey2_skill_unarmoured_movement") then
            inst.sg:GoToState("run_start")
            return
        end

        inst.components.locomotor:RunForward()
        inst.AnimState:PlayAnimation(Icey2Basic.GetUnarmouredMovementAnim(inst, "pre"))

        inst.sg.mem.footsteps = 0
    end,

    onupdate = function(inst) inst.components.locomotor:RunForward() end,

    timeline = {
        TimeEvent(5 * FRAMES, function(inst)
            DoRunSounds(inst)
            DoFoleySounds(inst)
        end)
    },

    events = {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("icey2_skill_unarmoured_movement")
            end
        end)
    }
})

AddStategraphState("wilson", State {
    name = "icey2_skill_unarmoured_movement",
    tags = { "moving", "running", "canrotate", "autopredict" },

    onenter = function(inst)
        inst.components.locomotor:RunForward()

        local anim = Icey2Basic.GetUnarmouredMovementAnim(inst, "loop")
        if not inst.AnimState:IsCurrentAnimation(anim) then
            inst.AnimState:PlayAnimation(anim, true)
        end

        inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
    end,

    onupdate = function(inst)
        if not inst:HasTag("icey2_skill_unarmoured_movement") then
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
        -- EventHandler("gogglevision", function(inst, data)
        --     if data.enabled then
        --         if inst.sg.statemem.sandstorm then
        --             inst.sg:GoToState("run")
        --         end
        --     elseif not (inst.sg.statemem.riding or inst.sg.statemem.heavy or
        --         inst.sg.statemem.iswere or inst.sg.statemem.sandstorm) and
        --         inst:IsInAnyStormOrCloud() then
        --         inst.sg:GoToState("run")
        --     end
        -- end), EventHandler("stormlevel", function(inst, data)
        --     if data.level < TUNING.SANDSTORM_FULL_LEVEL then
        --         if inst.sg.statemem.sandstorm then
        --             inst.sg:GoToState("run")
        --         end
        --     elseif not (inst.sg.statemem.riding or inst.sg.statemem.heavy or
        --         inst.sg.statemem.iswere or inst.sg.statemem.sandstorm or
        --         inst.components.playervision:HasGoggleVision()) then
        --         inst.sg:GoToState("run")
        --     end
        -- end), EventHandler("miasmalevel", function(inst, data)
        --     if data.level < 1 then
        --         if inst.sg.statemem.sandstorm then
        --             inst.sg:GoToState("run")
        --         end
        --     elseif not (inst.sg.statemem.riding or inst.sg.statemem.heavy or
        --         inst.sg.statemem.iswere or inst.sg.statemem.sandstorm or
        --         inst.components.playervision:HasGoggleVision()) then
        --         inst.sg:GoToState("run")
        --     end
        -- end), EventHandler("carefulwalking", function(inst, data)
        --     if not data.careful then
        --         if inst.sg.statemem.careful then
        --             inst.sg:GoToState("run")
        --         end
        --     elseif not (inst.sg.statemem.riding or inst.sg.statemem.heavy or
        --         inst.sg.statemem.sandstorm or inst.sg.statemem.groggy or
        --         inst.sg.statemem.careful or inst.sg.statemem.iswere) then
        --         inst.sg:GoToState("run")
        --     end
        -- end)
    },

    ontimeout = function(inst)
        inst.sg:GoToState("icey2_skill_unarmoured_movement")
    end
})

AddStategraphState("wilson", State {
    name = "icey2_skill_unarmoured_movement_stop",
    tags = { "canrotate", "idle", "autopredict" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation(Icey2Basic.GetUnarmouredMovementAnim(inst, "pst"))
    end,

    timeline = {},

    events = {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end)
    }
})


AddStategraphState("wilson", State {
    name = "icey2_aoeweapon_flurry_lunge_pre",
    tags = { "aoe", "doing", "busy", "nopredict" },

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("lunge_pre")
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
            local search_success = weapon.components.icey2_aoeweapon_flurry_lunge:SearchPossibleTargets(inst,
                data.target_pos)

            if not search_success then
                inst.sg:GoToState("idle")
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


            inst.components.health:SetInvincible(true)
            weapon.components.icey2_aoeweapon_flurry_lunge:TeleportNearTarget(inst, target)

            inst.sg.statemem.weapon = weapon
            inst.sg.statemem.middle_pos = data.middle_pos
            inst.sg.statemem.target = target

            inst.sg:SetTimeout(8 * FRAMES)

            failed = false
        end

        if failed then
            inst.sg:GoToState("idle")
        end
    end,

    ontimeout = function(inst)
        local weapon = inst.sg.statemem.weapon
        local target = weapon:PopTarget(inst)
        if target then
            inst.sg:GoToState("icey2_aoeweapon_flurry_lunge", {
                middle_pos = inst.sg.statemem.middle_pos,
                weapon = weapon,
                target = target,
            })
        else
            if inst.sg.statemem.middle_pos then
                inst.sg:GoToState("idle", true)
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
    end,
})

AddStategraphState("wilson", State {
    name = "icey2_aoeweapon_flurry_lunge_final",
    tags = { "attack", "abouttoattack", "busy", "nopredict" },

    onenter = function(inst, data)
        inst.sg.statemem.weapon = data.weapon

        if not data.weapon then
            inst.sg:GoToState("idle")
            return
        end

        inst.Transform:SetEightFaced()
        inst.AnimState:PlayAnimation("atk_leap")
        -- inst.SoundEmitter:PlaySound()

        -- inst:ForceFacePoint(inst.sg.statemem.targetpos)
    end,

    timeline = {
        TimeEvent(13 * FRAMES, function(inst)
            -- inst.SoundEmitter:PlaySound()

            if inst.sg.statemem.weapon and inst.sg.statemem.weapon:IsValid() then
                inst.sg.statemem.weapon.components.icey2_aoeweapon_flurry_lunge:FinalBlow(inst)
            end
        end),

        TimeEvent(18 * FRAMES, function(inst)
            inst.sg:RemoveStateTag("abouttoattack")
            inst.sg:GoToState("idle", true)
        end),
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
    end,
})
