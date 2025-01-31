local Icey2DodgeChargeUpgrader = Class(function(self, inst)
    self.inst = inst
    self.add_value = 1
    self.suit_value = 1
end)

function Icey2DodgeChargeUpgrader:TryUpdate(target)
    if target and target:IsValid()
        and target.components.icey2_skill_dodge
        and target.components.icey2_skill_dodge.max_dodge_charge <= self.suit_value then
        local set_value = target.components.icey2_skill_dodge.max_dodge_charge + self.add_value
        target.components.icey2_skill_dodge:SetMaxCharge(set_value)


        if self.inst.components.stackable then
            self.inst.components.stackable:Get():Remove()
        else
            self.inst:Remove()
        end
        return true
    end

    return false
end

return Icey2DodgeChargeUpgrader
