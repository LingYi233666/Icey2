local Icey2SkillBase_Active = require("components/icey2_skill_base_active")

local Icey2SkillDodge = Class(Icey2SkillBase_Active, function(self, inst)
    Icey2SkillBase_Active._ctor(self, inst)

    ------------------------------------------
    self.can_cast_while_busy = true
    self.costs.hunger = 1
    self.cooldown = 0.2

    ------------------------------------------
end)

return Icey2SkillDodge
