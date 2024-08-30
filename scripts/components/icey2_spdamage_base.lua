local SourceModifierList = require("util/sourcemodifierlist")

local Icey2SpDamageBase = Class(function(self, inst)
    self.inst = inst
    self.basedamage = 0
    self.externalmultipliers = SourceModifierList(inst)
    self.externalbonuses = SourceModifierList(inst, 0, SourceModifierList.additive)
end)

function Icey2SpDamageBase:SetBaseDamage(damage)
    self.basedamage = damage
end

function Icey2SpDamageBase:GetBaseDamage()
    return self.basedamage
end

function Icey2SpDamageBase:GetDamage()
    return self.basedamage * self.externalmultipliers:Get() + self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function Icey2SpDamageBase:AddMultiplier(src, mult, key)
    self.externalmultipliers:SetModifier(src, mult, key)
end

function Icey2SpDamageBase:RemoveMultiplier(src, key)
    self.externalmultipliers:RemoveModifier(src, key)
end

function Icey2SpDamageBase:GetMultiplier()
    return self.externalmultipliers:Get()
end

--------------------------------------------------------------------------

function Icey2SpDamageBase:AddBonus(src, bonus, key)
    self.externalbonuses:SetModifier(src, bonus, key)
end

function Icey2SpDamageBase:RemoveBonus(src, key)
    self.externalbonuses:RemoveModifier(src, key)
end

function Icey2SpDamageBase:GetBonus()
    return self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function Icey2SpDamageBase:GetDebugString()
    return string.format("Damage=%.2f [%.2fx%.2f+%.2f]", self:GetDamage(), self:GetBaseDamage(), self:GetMultiplier(),
        self:GetBonus())
end

return Icey2SpDamageBase
