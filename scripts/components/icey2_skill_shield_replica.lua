local Icey2SkillShield = Class(function(self, inst)
    self.inst = inst
    self._current = net_ushortint(inst.GUID, "icey2_skill_shield._current")
    self._max = net_ushortint(inst.GUID, "icey2_skill_shield._max")
end)

function Icey2SkillShield:SetMax(max)
    self._max:set(max)
end

function Icey2SkillShield:SetVal(current)
    current = math.max(0, current)
    current = math.min(self._max:value(), current)
    self._current:set(current)
end

function Icey2SkillShield:GetCurrent()
    return self._current:value()
end

function Icey2SkillShield:GetMax()
    return self._max:value()
end

function Icey2SkillShield:GetPercent()
    return self:GetCurrent() / self:GetMax()
end

return Icey2SkillShield
