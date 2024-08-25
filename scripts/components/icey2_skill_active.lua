local Icey2SkillActive = Class(function(self, inst)
    self.inst = inst

    self.can_cast_while_dead = false
    self.can_cast_while_busy = false
end)


function Icey2SkillActive:IsDead()
    return (self.inst.components.health and self.inst.components.health:IsDead())
        or self.inst:HasTag("playerghost")
        or (self.inst.sg and self.inst.sg:HasStateTag("dead"))
end

function Icey2SkillActive:IsBusy()
    return self.inst:HasTag("busy")
        or (self.inst.sg and self.inst.sg:HasStateTag("busy"))
end

function Icey2SkillActive:CanCast(x, y, z, target)
    if not self.can_cast_while_dead and self:IsDead() then
        return false, "PLAYER_DEAD"
    end

    if not self.can_cast_while_busy and self:IsBusy() then
        return false, "PLAYER_BUSY"
    end


    return true
end

return Icey2SkillActive
