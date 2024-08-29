local SourceModifierList = require("util/sourcemodifierlist")

local Icey2SkillShield = Class(function(self, inst)
    self.inst = inst

    self.current = 100
    self.max = 100

    self.max_damage_absorb = 99999
    self.effect_factor = 1

    self.recover_rate = SourceModifierList(inst, 0, SourceModifierList.additive)
    self.recover_rate:SetModifier(inst, 1, "base")
end)

function Icey2SkillShield:SetVal(current)
    self.current = math.clamp(current, 0, self.max)
end

function Icey2SkillShield:SetMaxShield(val)
    self.max = val
    self:DoDelta(0)
end

function Icey2SkillShield:DoDelta(amount)
    local old = self.current
    self:SetVal(self.current + amount)

    self.inst:PushEvent("icey2_shield_delta", { old = old })
end

function Icey2SkillShield:GetPercent()
    return self.current / self.max
end

function Icey2SkillShield:IsWearingArmor()
    for k, v in pairs(self.inst.components.inventory.equipslots) do
        if v.components.armor ~= nil and not v:HasTag("ignore_icey2_unarmoured_defence_limit") then
            return true
        end
    end
end

function Icey2SkillShield:RedirectDamageToShield(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    if ignore_absorb or ignore_invincible or amount >= 0 or overtime or afflicter == nil then
        return amount
    end

    if self:IsWearingArmor() then
        return amount
    end

    local absorbtion = math.min(math.min(self.max_damage_absorb, self.current * self.effect_factor), -amount)
    absorbtion = math.max(0, absorbtion)

    self:DoDelta(-absorbtion / self.effect_factor)

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

function Icey2SkillShield:OnSave()
    local data = {}
    data.current = self.current

    return data
end

function Icey2SkillShield:OnLoad(data)
    if data ~= nil then
        if data.current ~= nil then
            self:SetVal(data.current)
        end
    end
end

function Icey2SkillShield:OnUpdate(dt)
    if self.current < self.max then
        self:DoDelta(self:GetRecoverRate() * dt)
    end
end

return Icey2SkillShield
