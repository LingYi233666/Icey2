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

local function PlayMooseFootstep(inst, volume, ispredicted)
    --moose footstep always full volume
    inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/footstep", nil, nil, ispredicted)
    PlayFootstep(inst, volume, ispredicted)
end

local function DoMooseRunSounds(inst)
    --moose footstep always full volume
    inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/moose/footstep", nil, nil, true)
    DoRunSounds(inst)
end

local function DoMountSound(inst, mount, sound)
    if mount ~= nil and mount.sounds ~= nil then
        inst.SoundEmitter:PlaySound(mount.sounds[sound], nil, nil, true)
    end
end



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
            if inst:HasTag("icey2_skill_unarmoured_movement") then
                handle_by_old = false
                inst.sg:GoToState("icey2_skill_unarmoured_movement_stop")
            else

            end
        elseif not is_moving and should_move then
            --V2C: Added "dir" param so we don't have to add "canrotate" to all interruptible states
            if data and data.dir then
                if inst.components.locomotor then
                    inst.components.locomotor:SetMoveDir(data.dir)
                else
                    inst.Transform:SetRotation(data.dir)
                end
            end
            handle_by_old = false
            inst.sg:GoToState("icey2_skill_unarmoured_movement_start")
        end


        if handle_by_old then
            return old_locomote(inst, data)
        else

        end
    end
end)

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
