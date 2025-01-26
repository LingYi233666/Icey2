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
                    if inst:HasTag("icey2_skill_unarmoured_movement") then
                        handle_by_old = false
                        inst.sg:GoToState("icey2_skill_unarmoured_movement_stop")
                    elseif Icey2Basic.IsCarryingGunlance(inst, true) then
                        handle_by_old = false
                        inst.sg:GoToState("icey2_gunlance_ranged_run_stop")
                    end
                end
            end
        elseif not is_moving and should_move then
            if not (inst.components.rider and inst.components.rider:IsRiding()) then
                if inst:HasTag("icey2_skill_unarmoured_movement") then
                    -- V2C: Added "dir" param so we don't have to add "canrotate" to all interruptible states
                    if data and data.dir then
                        inst.components.locomotor:SetMoveDir(data.dir)
                    end
                    handle_by_old = false
                    inst.sg:GoToState("icey2_skill_unarmoured_movement_start")
                elseif Icey2Basic.IsCarryingGunlance(inst, true) then
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
        if old_rets ~= nil
            and not (inst.components.rider and inst.components.rider:IsRiding()) then
            if Icey2Basic.IsCarryingGunlance(inst, true) then
                return "icey2_gunlance_ranged_attack"
            elseif Icey2Basic.IsCarryingGunlance(inst, false) then
                return "icey2_gunlance_melee_attack"
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


-----------------------------------------------------------------------------
-- Skill: dodge
AddStategraphState("wilson", State {
    name = "icey2_dodge",
    tags = { "busy", "evade", "dodge", "no_stun", "nopredict", "nointerrupt" },

    onenter = function(inst, data)
        -- inst.AnimState:PlayAnimation("atk_leap_pre")

        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

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
        inst.sg:GoToState("idle", true)
    end,

    onexit = function(inst)
        inst.components.icey2_skill_dodge:OnDodgeStop()
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
        inst.components.combat.redirectdamagefn = function(inst, attacker, damage, weapon, stimuli)
            return inst.components.icey2_skill_parry
                and inst.components.icey2_skill_parry:TryParry(attacker, damage, weapon, stimuli)
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
-- Locomote: unarmored movement
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
    tags = { "attack", "abouttoattack", "notalking" },

    onenter = function(inst)
        if inst.components.combat:InCooldown() then
            inst.sg:RemoveStateTag("abouttoattack")
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle", true)
            return
        end

        local buffaction = inst:GetBufferedAction()
        local target = buffaction and buffaction.target or nil
        if target and target:IsValid() then
            inst:ForceFacePoint(target.Transform:GetWorldPosition())
            inst.sg.statemem.attacktarget = target
            inst.sg.statemem.retarget = target
        end

        -- inst.sg.statemem.chained = inst.AnimState:IsCurrentAnimation("tf2minigun_shoot")

        inst.sg.statemem.chained = (inst.sg.laststate == inst.sg.currentstate)

        inst.Transform:SetEightFaced()
        if not inst.AnimState:IsCurrentAnimation("tf2minigun_shoot") then
            inst.AnimState:PlayAnimation("tf2minigun_shoot", true)
        end

        local timeout = 33
        if not inst.sg.statemem.chained then

        else
            timeout = 12
        end

        inst.components.combat:StartAttack()
        inst.components.combat:SetTarget(target)
        inst.components.locomotor:Stop()

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

        TimeEvent(20 * FRAMES, function(inst)
            if not inst.sg.statemem.chained then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),

        TimeEvent(21 * FRAMES, function(inst)
            if not inst.sg.statemem.chained then
                inst.sg:RemoveStateTag("attack")
                inst.sg:AddStateTag("idle")
            end
        end),

        -- chained
        TimeEvent(3 * FRAMES, function(inst)
            if inst.sg.statemem.chained then
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end
        end),

        TimeEvent(4 * FRAMES, function(inst)
            if inst.sg.statemem.chained then
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
        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        inst.components.combat:SetTarget(target)
        inst.components.combat:StartAttack()
        inst.components.locomotor:Stop()
        local cooldown = inst.components.combat.min_attack_period


        if equip ~= nil and equip.components.weapon ~= nil and not equip:HasTag("punch") then
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)

            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon", nil, nil, true)

            cooldown = math.max(cooldown, 17 * FRAMES)
        end

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
            inst.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_gunlance/swipe", nil, 0.5, true)
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
    tags = { "aoe", "attack", "abouttoattack", "busy", "nopredict" },

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

            inst.components.health:SetInvincible(false)

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

            inst.sg:GoToState("idle", true)
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
