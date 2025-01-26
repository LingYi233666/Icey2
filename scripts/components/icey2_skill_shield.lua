local SourceModifierList = require("util/sourcemodifierlist")
local Icey2SkillBase_Passive = require("components/icey2_skill_base_passive")

-- local function oncurrent(self, current)
--     self.inst.replica.icey2_skill_shield:SetVal(current)
-- end

-- local function onmax(self, max)
--     self.inst.replica.icey2_skill_shield:SetMax(max)
-- end

local Icey2SkillShield = Class(Icey2SkillBase_Passive, function(self, inst)
    Icey2SkillBase_Passive._ctor(self, inst)

    self.current = 100
    self.max = 100

    self.max_damage_absorb = 51

    self.recover_rate = SourceModifierList(inst, 0, SourceModifierList.additive)
    self.recover_rate:SetModifier(inst, 1, "base")

    inst:StartUpdatingComponent(self)

    inst:DoTaskInTime(1, function()
        self:UpdateReplica()
    end)

    self.use_icey2_reroll_data_handler = true
end)

function Icey2SkillShield:Enable()
    Icey2SkillBase_Passive.Enable(self)
    self.inst.components.health.deltamodifierfn =
        function(inst, amount, overtime, cause, ignore_invincible, afflicter,
                 ignore_absorb)
            return self:RedirectDamageToShield(amount, overtime, cause,
                ignore_invincible, afflicter,
                ignore_absorb)
        end
end

function Icey2SkillShield:Disable()
    Icey2SkillBase_Passive.Disable(self)

    self.inst.components.health.deltamodifierfn = nil
end

function Icey2SkillShield:UpdateReplica()
    self.inst.replica.icey2_skill_shield:SetMax(self.max)
    self.inst.replica.icey2_skill_shield:SetVal(self.current)
end

function Icey2SkillShield:SetVal(current)
    self.current = math.clamp(current, 0, self.max)
    self.inst.replica.icey2_skill_shield:SetVal(self.current)
end

function Icey2SkillShield:SetMaxDamageAbsorb(val)
    self.max_damage_absorb = val
end

function Icey2SkillShield:SetMaxShield(val)
    self.max = val
    self.inst.replica.icey2_skill_shield:SetMax(self.max)
    self:DoDelta(0)
end

function Icey2SkillShield:DoDelta(amount)
    local old = self.current
    self:SetVal(self.current + amount)

    self.inst:PushEvent("icey2_shield_delta", { old = old })
end

function Icey2SkillShield:SetPercent(percent)
    local val = self.max * percent
    self:SetVal(val)
end

function Icey2SkillShield:GetPercent()
    return self.current / self.max
end

function Icey2SkillShield:RedirectDamageToShield(amount, overtime, cause,
                                                 ignore_invincible, afflicter,
                                                 ignore_absorb)
    if ignore_absorb
        or ignore_invincible
        or amount >= 0
        or overtime
        or afflicter == nil then
        return amount
    end

    if Icey2Basic.IsWearingArmor(self.inst) then
        return amount
    end

    -- if self.inst.sg:HasStateTag("preparrying") or self.inst.sg:HasStateTag("parrying") then
    --     return amount
    -- end

    if self.inst.components.icey2_skill_parry and self.inst.components.icey2_skill_parry:IsParrying() then
        return amount
    end

    local absorbtion = math.min(math.min(self.max_damage_absorb, self.current), -amount)
    absorbtion = math.max(0, absorbtion)

    self:DoDelta(-absorbtion)
    self:Pause(math.clamp(absorbtion / 10, 1, 5))

    ---- FX -----
    -- name = "shadow_shield"..tostring(j + i),
    -- bank = "stalker_shield",
    -- build = "stalker_shield",
    -- anim = "idle"..tostring(i),
    --------------

    return amount + absorbtion
end

function Icey2SkillShield:GetRecoverRate()
    return self.recover_rate:Get()
end

function Icey2SkillShield:IsPaused()
    return self.paused
end

function Icey2SkillShield:Pause(duration)
    self.paused = true
    if self.resume_time == nil then
        self.resume_time = GetTime() + duration
    else
        self.resume_time = math.max(self.resume_time, GetTime() + duration)
    end
end

function Icey2SkillShield:Resume()
    self.paused = false
    self.resume_time = nil
end

function Icey2SkillShield:OnSave()
    local data = Icey2SkillBase_Passive.OnSave(self)

    data.current = self.current
    data.max = self.max
    data.max_damage_absorb = self.max_damage_absorb

    return data
end

function Icey2SkillShield:OnLoad(data)
    Icey2SkillBase_Passive.OnLoad(self, data)
    if data ~= nil then
        if data.max ~= nil then
            self:SetMaxShield(data.max)
        end

        if data.current ~= nil then
            self:SetVal(data.current)
        end

        if data.max_damage_absorb ~= nil then
            self.max_damage_absorb = data.max_damage_absorb
        end
    end
end

function Icey2SkillShield:OnUpdate(dt)
    if self.paused then
        if self.resume_time and GetTime() >= self.resume_time then
            self:Resume()
        else
            return
        end
    end

    if self.current < self.max then
        self:DoDelta(self:GetRecoverRate() * dt)
    end
end

function Icey2SkillShield:GetDebugString()
    local base = string.format("%d / %d (%.2f%%), max damage absorb: %d",
        self.current,
        self.max,
        100 * self:GetPercent(),
        self.max_damage_absorb)

    return base
end

return Icey2SkillShield
