local SourceModifierList = require("util/sourcemodifierlist")
local Icey2SkillBase_Active = require("components/icey2_skill_base_active")


local function DefaultParryTestFnWrapper(self)
    local function TestFn(player, attacker, damage, weapon, stimuli, spdamage)
        if not (player.components.icey2_skill_shield
                and player.components.icey2_skill_shield:IsEnabled()) then
            return
        end

        if not attacker then
            return
        end

        local all_damage = Icey2Basic.DamageSum(damage, spdamage)

        print("TestFn all_damage:", all_damage)

        local cur_shield = player.components.icey2_skill_shield.current
        local cost_shield = self:GetShieldRequired(all_damage)
        local tar_deg = Icey2Basic.GetFaceAngle(player, attacker)


        local base_judge = (player.sg
            and player.sg:HasStateTag("parrying")
            and -self.parry_degree / 2 <= tar_deg
            and tar_deg <= self.parry_degree / 2)

        if not base_judge then
            return
        end


        return (cost_shield <= cur_shield) and self.parry_target or self.shield_break_target
    end

    return TestFn
end

local Icey2SkillParry = Class(Icey2SkillBase_Active, function(self, inst)
    Icey2SkillBase_Active._ctor(self, inst)

    ------------------------------------------
    self.can_cast_while_wearing_armor = true
    self.cooldown = 0
    ------------------------------------------

    self.parry_start_time = nil
    self.parry_degree = 150
    self.good_parry_time_threshold = 0.33
    self.shield_consume_factors = { 0.4, 0.5 }
    self.parry_history = {}

    self.parrytestfn = DefaultParryTestFnWrapper(self)
    self.parrycallback = nil

    self.parry_target = inst:SpawnChild("icey2_parry_target")
    self.shield_break_target = inst:SpawnChild("icey2_parry_target")

    ----------------------------------------------------------------------------------

    self._on_attacked = function(inst, data)
        local all_damage = Icey2Basic.DamageSum(data.damage, data.spdamage)
        local redirected = data.redirected
        local attacker = data.attacker

        if redirected then
            if redirected == self.parry_target then
                if self:GetTimeSinceParry() <= self.good_parry_time_threshold then
                    data.is_good_parry = true
                    inst.SoundEmitter:PlaySound("dontstarve/creatures/lava_arena/trails/hide_pre", nil, 0.5)
                    inst:SpawnChild("icey2_greatparry_vfx").Transform:SetPosition(0.5, 0, 0)
                end

                print("Parry all damage:", all_damage)

                inst.components.icey2_skill_shield:DoDelta(-self:GetShieldRequired(all_damage))

                table.insert(self.parry_history, MergeMaps(data, { time = GetTime() }))

                if self.parrycallback then
                    self.parrycallback(inst, data)
                end
            elseif redirected == self.shield_break_target then
                local cur_shield = inst.components.icey2_skill_shield.current

                inst.components.icey2_skill_shield:DoDelta(-cur_shield)
                inst.components.icey2_skill_shield:Pause(10)

                inst.SoundEmitter:PlaySound("icey2_sfx/skill/parry/shield_break")
                -- inst.SoundEmitter:PlaySound("icey2_sfx/skill/parry/shield_break2")


                -- Spawn shield break shards
                local shard_fx = inst:SpawnChild("icey2_shield_break_shard_vfx")
                -- shard_fx.Transform:SetPosition(1, 0, 0)
                shard_fx:DoTaskInTime(4 * FRAMES, shard_fx.Remove)

                local fx = inst:SpawnChild("icey2_shield_break_fx")

                if not inst.components.health:IsDead() then
                    inst.sg:GoToState("hit")
                end
            end
        end
    end

    self._not_parry_state = function()
        if not (inst.sg:HasStateTag("preparrying") or inst.sg:HasStateTag("parrying")) then
            self:StopParry()
        end
    end

    self._force_stop = function()
        self:StopParry()
    end
end)

function Icey2SkillParry:TryParry(attacker, damage, weapon, stimuli, spdamage)
    return self.parrytestfn ~= nil and self.parrytestfn(self.inst, attacker, damage, weapon, stimuli, spdamage)
end

function Icey2SkillParry:CanStartParry(x, y, z, target)
    local success, reason = Icey2SkillBase_Active.CanCast(self, x, y, z, target)
    if not success then
        return false, reason
    end

    local equip = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if equip and equip:HasTag("NO_ICEY2_PARRY") then
        return false, "EQUIP_SPECIAL_TAG"
    end

    if not (self.inst.components.icey2_skill_shield and self.inst.components.icey2_skill_shield.current > 0) then
        return false, "OUT_OF_SHIELD"
    end

    if self:IsParrying() then
        return false, "ALREADY_PARRYING"
    end

    return true
end

function Icey2SkillParry:CanStopParry(x, y, z, target)
    if not self:IsParrying() then
        return false, "NOT_PARRYING"
    end

    return true
end

function Icey2SkillParry:StartParry()
    self.parry_start_time = GetTime()

    self.rotate_task = self.inst:DoPeriodicTask(0, function()
        self.inst:ForceFacePoint(self.inst.components.icey2_control_key_helper:GetMousePosition())
    end)

    self.inst.AnimState:Show("ARM_carry")
    self.inst.AnimState:Hide("ARM_normal")
    self.inst.AnimState:HideSymbol("swap_object")
    self.inst.AnimState:OverrideSymbol("swap_shield", "swap_icey2_parry_shield", "swap_shield")
    self.inst.AnimState:SetSymbolLightOverride("swap_shield", 1)
    -- self.inst.AnimState:SetSymbolAddColour("swap_shield", 96 / 255, 249 / 255, 255 / 255, 1)

    self.inst.sg:GoToState("icey2_parry_pre")
    self.inst:ListenForEvent("attacked", self._on_attacked)
    self.inst:ListenForEvent("newstate", self._not_parry_state)
end

function Icey2SkillParry:StopParry()
    if self.rotate_task then
        self.rotate_task:Cancel()
        self.rotate_task = nil
    end

    self.inst.AnimState:ClearOverrideSymbol("swap_shield")
    self.inst.AnimState:SetSymbolLightOverride("swap_shield", 0)
    self.inst.AnimState:SetSymbolAddColour("swap_shield", 0, 0, 0, 0)

    if self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) == nil then
        self.inst.AnimState:Hide("ARM_carry")
        self.inst.AnimState:Show("ARM_normal")
    end

    self.inst.AnimState:ShowSymbol("swap_object")


    if self.inst.sg:HasStateTag("preparrying") or self.inst.sg:HasStateTag("parrying") then
        -- local counter_target = nil
        -- for i = #self.parry_history, 1, -1 do
        --     local parrydata = self.parry_history[i]
        --     if parrydata.time - self.parry_start_time <= self.good_parry_time_threshold
        --         and self.inst.components.combat:CanTarget(parrydata.attacker) then
        --         counter_target = parrydata.attacker
        --     end
        -- end


        -- if counter_target and counter_target:IsNear(self.inst, self.inst.components.combat:GetAttackRange() + 1.3) then
        --     self.inst.sg:GoToState("gale_parry_counter_near", { target = counter_target })
        -- else
        --     self.inst.AnimState:PlayAnimation("parry_pst")
        --     self.inst.sg:GoToState("idle", true)
        -- end




        self.inst.AnimState:PlayAnimation("shieldparry_pst")
        self.inst.sg:GoToState("idle", true)
    end

    self.inst:RemoveEventCallback("attacked", self._on_attacked)
    self.inst:RemoveEventCallback("newstate", self._not_parry_state)

    self.parry_history = {}
    self.parry_start_time = nil
end

function Icey2SkillParry:IsParrying()
    return self.parry_start_time ~= nil
end

function Icey2SkillParry:GetTimeSinceParry()
    return GetTime() - self.parry_start_time
end

function Icey2SkillParry:GetShieldRequired(damage)
    return self:GetTimeSinceParry() < self.good_parry_time_threshold
        and (self.shield_consume_factors[1] * damage)
        or (self.shield_consume_factors[2] * damage)
end

return Icey2SkillParry
