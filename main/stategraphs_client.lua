-- locomote
AddStategraphPostInit("wilson_client", function(sg)
    local old_locomote = sg.events["locomote"].fn
    sg.events["locomote"].fn = function(inst, data)
        --#HACK for hopping prediction: ignore busy when boathopping... (?_?)
        if (inst.sg:HasStateTag("busy") or inst:HasTag("busy")) and
            not (inst.sg:HasStateTag("boathopping") or inst:HasTag("boathopping")) then
            return
        elseif inst.sg:HasStateTag("overridelocomote") then
            return
        end

        local is_moving = inst.sg:HasStateTag("moving")
        local should_move = inst.components.locomotor:WantsToMoveForward()

        local handle_by_old = true


        if inst:HasTag("ingym") then

        elseif inst:HasTag("sleeping") then

        elseif not inst.entity:CanPredictMovement() then

        elseif is_moving and not should_move then
            if not (inst.components.rider and inst.components.rider:IsRiding()) then
                if inst:HasTag("icey2_skill_unarmoured_movement") then
                    handle_by_old = false
                    inst.sg:GoToState("icey2_skill_unarmoured_movement_stop")
                elseif Icey2Basic.IsCarryingGunlance(inst, true) then
                    handle_by_old = false
                    inst.sg:GoToState("icey2_gunlance_ranged_run_stop")
                end
            end
        elseif not is_moving and should_move then
            if not (inst.components.rider and inst.components.rider:IsRiding()) then
                if data and data.dir then
                    if inst.components.locomotor then
                        inst.components.locomotor:SetMoveDir(data.dir)
                    else
                        inst.Transform:SetRotation(data.dir)
                    end
                end

                if inst:HasTag("icey2_skill_unarmoured_movement") then
                    handle_by_old = false
                    inst.sg:GoToState("icey2_skill_unarmoured_movement_start")
                elseif Icey2Basic.IsCarryingGunlance(inst, true) then
                    handle_by_old = false
                    inst.sg:GoToState("icey2_gunlance_ranged_run_start")
                end
            end
        end


        if handle_by_old then
            return old_locomote(inst, data)
        else

        end
    end
end)

-- castaoe
AddStategraphPostInit("wilson_client", function(sg)
    local old_CASTAOE = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate = function(inst, action)
        local weapon = action.invobject
        if weapon and weapon:HasTag("icey2_aoeweapon") then
            local can_cast = weapon.components.aoetargeting:IsEnabled()

            if can_cast then
                if weapon.prefab == "icey2_pact_weapon_rapier" then
                    inst:PerformPreviewBufferedAction()
                    return
                end
            else
                return
            end
        end
        return old_CASTAOE(inst, action)
    end
end)

-- attack
AddStategraphPostInit("wilson_client", function(sg)
    local old_ATTACK = sg.actionhandlers[ACTIONS.ATTACK].deststate
    sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action)
        local old_rets = old_ATTACK(inst, action)
        if old_rets ~= nil
            and not (inst.components.rider and inst.components.rider:IsRiding())
            and Icey2Basic.IsCarryingGunlance(inst, true) then
            return "icey2_gunlance_ranged_attack"
        end

        return old_rets
    end
end)


-- idle
AddStategraphPostInit("wilson_client", function(sg)
    local function ModifyIdleState_Gunlance(state)
        local old_onenter = state.onenter

        state.onenter = function(inst, pushanim, ...)
            local ret = old_onenter(inst, pushanim, ...)
            if pushanim ~= "noanim"
                and not (inst.components.rider and inst.components.rider:IsRiding())
                and Icey2Basic.IsCarryingGunlance(inst, true) then
                inst.sg:GoToState("icey2_gunlance_ranged_idle")
            end

            return ret
        end
    end

    local states_idle = {
        sg.states["idle"],
    }

    for _, state in pairs(states_idle) do
        ModifyIdleState_Gunlance(state)
    end
end)

-- eat
AddStategraphPostInit("wilson_client", function(sg)
    local old_EAT = sg.actionhandlers[ACTIONS.EAT].deststate
    sg.actionhandlers[ACTIONS.EAT].deststate = function(inst, action)
        local old_rets = old_EAT(inst, action)

        local feed = action.invobject
        if old_rets ~= nil and feed:HasTag("blood_metal") then
            return "eat"
        end
        return old_rets
    end
end)

-------------------------------------------------------------------------------------------

local function DoEquipmentFoleySounds(inst)
    local inventory = inst.replica.inventory
    if inventory ~= nil then
        for k, v in pairs(inventory:GetEquips()) do
            if v.foleysound ~= nil then
                inst.SoundEmitter:PlaySound(v.foleysound, nil, nil, true)
            end
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
    local rider = inst.replica.rider
    local saddle = rider ~= nil and rider:GetSaddle() or nil
    if saddle ~= nil and saddle.mounted_foleysound ~= nil then
        inst.SoundEmitter:PlaySound(saddle.mounted_foleysound, nil, nil, true)
    end
end

local function DoRunSounds(inst)
    if inst.sg.mem.footsteps > 3 then
        PlayFootstep(inst, .6, true)
    else
        inst.sg.mem.footsteps = inst.sg.mem.footsteps + 1
        PlayFootstep(inst, 1, true)
    end
end

local function DoMountSound(inst, mount, sound)
    if mount ~= nil and mount.sounds ~= nil then
        inst.SoundEmitter:PlaySound(mount.sounds[sound], nil, nil, true)
    end
end




-------------------------------------------------------------------------------------------
-- Locomote: unarmored movement
AddStategraphState("wilson_client",
    State {
        name = "icey2_skill_unarmoured_movement_start",
        tags = { "moving", "running", "canrotate" },

        onenter = function(inst)
            if not inst:HasTag("icey2_skill_unarmoured_movement") then
                inst.sg:GoToState("run_start")
                return
            end

            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation(Icey2Basic.GetUnarmouredMovementAnim(inst, "pre"))

            inst.sg.mem.footsteps = 0
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst)
                DoRunSounds(inst)
                DoFoleySounds(inst)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("icey2_skill_unarmoured_movement")
                end
            end),
        },
    }
)

AddStategraphState("wilson_client",
    State {
        name = "icey2_skill_unarmoured_movement",
        tags = { "moving", "running", "canrotate" },

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

        timeline =
        {
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
            end),

        },

        ontimeout = function(inst)
            inst.sg:GoToState("icey2_skill_unarmoured_movement")
        end,
    }
)

AddStategraphState("wilson_client",
    State {
        name = "icey2_skill_unarmoured_movement",
        tags = { "canrotate", "idle", },

        onenter = function(inst)
            inst.components.locomotor:Stop()

            inst.AnimState:PlayAnimation(Icey2Basic.GetUnarmouredMovementAnim(inst, "pst"))
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    }
)


-------------------------------------------------------------------------------------------
-- Locomote: carry gunlance with range attack form
AddStategraphState("wilson_client", State {
    name = "icey2_gunlance_ranged_run_start",
    tags = { "moving", "running", "canrotate" },

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

    events =
    {
        EventHandler("animover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("icey2_gunlance_ranged_run")
            end
        end),
    },

    onexit = function(inst)
        inst.Transform:SetFourFaced()
    end,
})

AddStategraphState("wilson_client", State {
    name = "icey2_gunlance_ranged_run",
    tags = { "moving", "running", "canrotate" },

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

    timeline =
    {
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
        end),
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

AddStategraphState("wilson_client", State {
    name = "icey2_gunlance_ranged_run_stop",
    tags = { "canrotate", "idle" },

    onenter = function(inst)
        inst.Transform:SetEightFaced()

        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("walk_tf2minigun_pst")
    end,

    timeline =
    {
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
        inst.Transform:SetFourFaced()
    end,
})


-------------------------------------------------------------------------------------------
-- Idle: carry gunlance with range attack form
AddStategraphState("wilson_client", State {
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
    },

    onexit = function(inst)
        inst.Transform:SetFourFaced()
    end,
})


-----------------------------------------------------------------------------
-- attack: gunlance with range attack form
AddStategraphState("wilson_client", State {
    name = "icey2_gunlance_ranged_attack",
    tags = { "attack", "notalking", "abouttoattack" },

    onenter = function(inst)
        local combat = inst.replica.combat
        if combat:InCooldown() then
            inst.sg:RemoveStateTag("abouttoattack")
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle", true)
            return
        end

        combat:StartAttack()

        inst.components.locomotor:Stop()

        inst.sg.statemem.chained = (inst.sg.laststate == inst.sg.currentstate)


        inst.Transform:SetEightFaced()
        if not inst.AnimState:IsCurrentAnimation("tf2minigun_shoot") then
            inst.AnimState:PlayAnimation("tf2minigun_shoot", true)
        end

        local buffaction = inst:GetBufferedAction()
        if buffaction ~= nil then
            inst:PerformPreviewBufferedAction()

            if buffaction.target ~= nil and buffaction.target:IsValid() then
                inst:FacePoint(buffaction.target:GetPosition())
                inst.sg.statemem.attacktarget = buffaction.target
                inst.sg.statemem.retarget = buffaction.target
            end
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
                inst.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_gunlance/aim", "aim", nil, true)
            end
        end),

        -- chained
        TimeEvent(3 * FRAMES, function(inst)
            if inst.sg.statemem.chained then
                inst:ClearBufferedAction()
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
                inst:ClearBufferedAction()
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

    },

    onexit = function(inst)
        if inst.sg:HasStateTag("abouttoattack") then
            inst.replica.combat:CancelAttack()
        end

        inst.Transform:SetFourFaced()

        inst.SoundEmitter:KillSound("aim")
    end,
})
