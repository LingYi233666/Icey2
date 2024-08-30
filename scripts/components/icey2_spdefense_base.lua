local SourceModifierList = require("util/sourcemodifierlist")

local Icey2SpDefenseBase = Class(function(self, inst)
	self.inst = inst
	self.basedefense = 0
	self.externalmultipliers = SourceModifierList(inst)
	self.externalbonuses = SourceModifierList(inst, 0, SourceModifierList.additive)
end)

function Icey2SpDefenseBase:SetBaseDefense(defense)
	self.basedefense = defense
end

function Icey2SpDefenseBase:GetBaseDefense()
	return self.basedefense
end

function Icey2SpDefenseBase:GetDefense()
	return self.basedefense * self.externalmultipliers:Get() + self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function Icey2SpDefenseBase:AddMultiplier(src, mult, key)
	self.externalmultipliers:SetModifier(src, mult, key)
end

function Icey2SpDefenseBase:RemoveMultiplier(src, key)
	self.externalmultipliers:RemoveModifier(src, key)
end

function Icey2SpDefenseBase:GetMultiplier()
	return self.externalmultipliers:Get()
end

--------------------------------------------------------------------------

function Icey2SpDefenseBase:AddBonus(src, bonus, key)
	self.externalbonuses:SetModifier(src, bonus, key)
end

function Icey2SpDefenseBase:RemoveBonus(src, key)
	self.externalbonuses:RemoveModifier(src, key)
end

function Icey2SpDefenseBase:GetBonus()
	return self.externalbonuses:Get()
end

--------------------------------------------------------------------------

function Icey2SpDefenseBase:GetDebugString()
	return string.format("Defense=%.2f [%.2fx%.2f+%.2f]", self:GetDefense(), self:GetBaseDefense(), self:GetMultiplier(),
		self:GetBonus())
end

return Icey2SpDefenseBase
