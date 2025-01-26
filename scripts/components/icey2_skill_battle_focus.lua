local SourceModifierList = require("util/sourcemodifierlist")
local Icey2SkillBase_Passive = require("components/icey2_skill_base_passive")


local Icey2SkillBattleFocus = Class(Icey2SkillBase_Passive, function(self, inst)
    Icey2SkillBase_Passive._ctor(self, inst)

    self.current = 0
    self.max = 100

    -- data = {
    --     target = self.inst,
    --     damage = damage,
    --     damageresolved = damageresolved,
    --     stimuli = stimuli,
    --     spdamage = spdamage,
    --     weapon = weapon,
    --     redirected = damageredirecttarget
    -- }

    self._on_hit_other = function(_, data)
        -- print("on hit other", data.redirected, data.weapon)
        -- redirected to another target
        if data.redirected then
            return
        end

        local addition = 10

        local weapon = data.weapon
        local target = data.target
        -- projectile or ranged weapon
        if weapon then
            if weapon.components.projectile
                or weapon.components.complexprojectile
                or weapon.components.weapon:CanRangedAttack() then
                addition = addition * 0
            end
        end

        if inst.sg and inst.sg:HasStateTag("aoe") then
            addition = addition * 0
        end

        -- riding
        if inst.components.rider and inst.components.rider:IsRiding() then
            addition = addition * 0
        end

        if not target
            or not target.components.combat
            or (target.components.combat:CalcDamage(self.inst) <= 0.01 and target.prefab ~= "dummytarget") then
            addition = addition * 0
        end

        if Icey2Basic.IsWearingArmor(inst) then
            addition = addition * 0
        end

        local ball_data = self:GetSupplyBallData(weapon, target, addition)
        if ball_data and ball_data.prefabs then
            local start_pos = target:GetPosition()
            start_pos.y = start_pos.y + GetRandomMinMax(0.8, 2)

            -- for i = 1, (ball_data.count or 1) do
            --     SpawnPrefab(ball_data.prefab):Setup(self.inst, start_pos)
            -- end

            for _, prefab_and_cnt in pairs(ball_data.prefabs) do
                for i = 1, prefab_and_cnt[2] do
                    SpawnPrefab(prefab_and_cnt[1]):Setup(self.inst, start_pos)
                end
            end

            if ball_data.fx_prefab then
                local fx = SpawnAt(ball_data.fx_prefab, start_pos)
                fx:FaceAwayFromPoint(self.inst:GetPosition(), true)
            end
        end


        self:RefreshAttackTime()
        self:DoDelta(addition)
    end

    self._on_attacked = function(_, data)
        if data.redirected then
            return
        end

        -- TODO: Play a sfx here
        self:SetVal(0)
    end
end)

function Icey2SkillBattleFocus:GetSupplyBallData(weapon, target, addition)
    if weapon and weapon.components.icey2_supply_ball_override then
        return weapon.components.icey2_supply_ball_override:GetData(self.inst, target, addition)
    end

    if addition < 1.1 then
        return
    end

    local supply_chance = {}

    if self:GetPercent() >= 0.5 and self.inst.components.icey2_skill_shield then
        local p = self.inst.components.icey2_skill_shield:GetPercent()
        if p < 1 then
            supply_chance.icey2_supply_ball_shield = 1 - p
        else
            -- supply_chance.icey2_supply_ball_shield = 0.001
        end
    end

    if self:GetPercent() >= 1 and self.inst.components.health then
        local p = self.inst.components.health:GetPercent()
        if p < 1 then
            supply_chance.icey2_supply_ball_health = (1 - p) * 0.33
        else
            -- supply_chance.icey2_supply_ball_health = 0.001
        end
    end

    local spawn_fx_map = {
        icey2_supply_ball_shield = "icey2_supply_ball_shield_spawn",
        icey2_supply_ball_health = "icey2_supply_ball_health_spawn",
    }

    if GetTableSize(supply_chance) > 0 then
        local prefab = weighted_random_choice(supply_chance)
        -- if prefab then
        --     return {
        --         prefab = prefab,
        --         count = 1,
        --         fx_prefab = spawn_fx_map[prefab],
        --     }
        -- end

        return {
            prefabs = { { prefab, 1 } },
            fx_prefab = spawn_fx_map[prefab],
        }
    end
end

function Icey2SkillBattleFocus:Enable()
    Icey2SkillBase_Passive.Enable(self)

    self.inst:ListenForEvent("onhitother", self._on_hit_other)
    self.inst:ListenForEvent("attacked", self._on_attacked)
    self.inst:StartUpdatingComponent(self)
end

function Icey2SkillBattleFocus:Disable()
    Icey2SkillBase_Passive.Disable(self)

    self.inst:RemoveEventCallback("onhitother", self._on_hit_other)
    self.inst:RemoveEventCallback("attacked", self._on_attacked)
    self.inst:StopUpdatingComponent(self)
    self:SetVal(0)
end

function Icey2SkillBattleFocus:SetVal(current)
    local old_current = self.current
    self.current = math.clamp(current, 0, self.max)

    if old_current < self.max and self.current >= self.max then
        -- Start battle focus bonus
        self.inst.components.icey2_spdamage_force:AddBonus(self.inst, 8.5, "icey2_skill_battle_focus")
        self.inst.components.sanity.neg_aura_modifiers:SetModifier(self.inst, 0.5, "icey2_skill_battle_focus")
        self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, "icey2_skill_battle_focus", 1.05)
    elseif old_current >= self.max and self.current < self.max then
        -- Stop battle focus bonus
        self.inst.components.icey2_spdamage_force:RemoveBonus(self.inst, "icey2_skill_battle_focus")
        self.inst.components.sanity.neg_aura_modifiers:RemoveModifier(self.inst, "icey2_skill_battle_focus")
        self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, "icey2_skill_battle_focus")
    end
end

function Icey2SkillBattleFocus:DoDelta(amount)
    local old = self.current
    self:SetVal(self.current + amount)

    self.inst:PushEvent("icey2_battle_focus_delta", { old = old })
end

function Icey2SkillBattleFocus:GetPercent()
    return self.current / self.max
end

function Icey2SkillBattleFocus:RefreshAttackTime()
    self.last_valid_attack_time = GetTime()
end

function Icey2SkillBattleFocus:GetTimeSinceLastValidAttack()
    if self.last_valid_attack_time then
        return GetTime() - self.last_valid_attack_time
    end

    return -1
end

function Icey2SkillBattleFocus:OnUpdate(dt)
    if self.current > 0 and self:GetTimeSinceLastValidAttack() > 10 then
        -- TODO: Play a sfx here ?
        self:DoDelta(-20 * dt)
    end
end

function Icey2SkillBattleFocus:GetDebugString()
    local base = string.format("%d / %d (%.2f%%)", self.current, self.max, 100 * self:GetPercent())
    if self.current > 0 then
        local t = self:GetTimeSinceLastValidAttack()
        base = base .. string.format(", time since last attack: %.2f", t)
    end


    return base
end

return Icey2SkillBattleFocus
