local Icey2SkillDodge = Class(function(self, inst)
    self.inst = inst

    self._dodge_charge = net_tinybyte(inst.GUID, "Icey2SkillDodge._dodge_charge", "Icey2SkillDodge._dodge_charge")
    self._max_dodge_charge = net_tinybyte(inst.GUID, "Icey2SkillDodge._max_dodge_charge",
        "Icey2SkillDodge._max_dodge_charge")
end)

function Icey2SkillDodge:SetCharge(v)
    self._dodge_charge:set(v)
end

function Icey2SkillDodge:SetMaxCharge(c)
    self._max_dodge_charge:set(c)
end

function Icey2SkillDodge:GetCharge()
    return self._dodge_charge:value()
end

function Icey2SkillDodge:GetMaxCharge()
    return self._max_dodge_charge:value()
end

return Icey2SkillDodge
