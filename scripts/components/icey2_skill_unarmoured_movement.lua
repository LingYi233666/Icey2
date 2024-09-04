local Icey2SkillBase_Passive = require("components/icey2_skill_base_passive")

local Icey2SkillUnarmouredMovement = Class(Icey2SkillBase_Passive,
                                           function(self, inst)
    Icey2SkillBase_Passive._ctor(self, inst)

    self.bonus = 1.1

    self.inst:ListenForEvent("equip", function() self:Check() end)
    self.inst:ListenForEvent("unequip", function() self:Check() end)
    self.inst:ListenForEvent("death", function() self:Check() end)
    self.inst:ListenForEvent("respawnfromghost", function() self:Check() end)

    self.inst:DoTaskInTime(0, function() self:Check() end)
end)

function Icey2SkillUnarmouredMovement:Enable()
    Icey2SkillBase_Passive.Enable(self)
    self:Check()
end

function Icey2SkillUnarmouredMovement:Disable()
    Icey2SkillBase_Passive.Disable(self)
    self:Check()
end

function Icey2SkillUnarmouredMovement:SetBonus(v)
    self.bonus = v
    self:Check()
end

function Icey2SkillUnarmouredMovement:IsDead()
    return
        (self.inst.components.health and self.inst.components.health:IsDead()) or
            self.inst:HasTag("playerghost") or
            (self.inst.sg and self.inst.sg:HasStateTag("dead"))
end

function Icey2SkillUnarmouredMovement:Check()
    if self:IsEnabled() and not self:IsDead() and
        not Icey2Normal.IsWearingArmor(self.inst) and
        not self.inst.components.rider:IsRiding() then
        self.inst:AddTag("icey2_skill_unarmoured_movement")

        self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst,
                                                                  "icey2_skill_unarmoured_movement",
                                                                  self.bonus)
    else
        self.inst:RemoveTag("icey2_skill_unarmoured_movement")

        self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst,
                                                                     "icey2_skill_unarmoured_movement")
    end
end

return Icey2SkillUnarmouredMovement
