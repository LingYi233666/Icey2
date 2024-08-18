local Icey2SkillPhantomSword = Class(function(self, inst)
    self.inst = inst

    self.num_swords = 5
    self.magic_cost = 5
    self.cooldown = 0.25
    self.cooldown_timer_name = "icey2_skill_phantom_sword"
end)

function Icey2SkillPhantomSword:IsValidTarget(target)
    return target
        and self.inst.components.combat:CanTarget(target)
        and not self.inst.components.combat:IsAlly(target)
end

function Icey2SkillPhantomSword:CanCast(target)
    if self.inst.components.health:IsDead()
        or self.inst:HasTag("playerghost")
        or self.inst.sg:HasStateTag("dead") then
        return false, "PLAYER_DEAD"
    end

    if not self:IsValidTarget(target) then
        return false, "INVALID_TARGET"
    end

    if self.inst.components.timer:TimerExists(self.cooldown_timer_name) then
        return false, "COOLDOWN"
    end

    -- TODO: Not enough magic

    return true
end

function Icey2SkillPhantomSword:Cast(target)
    for i = 1, self.num_swords do
        SpawnAt("icey2_phantom_sword", self.inst, nil, { 0, 0.6, 0 }):Launch(self.inst, target)
    end

    -- self.inst.SoundEmitter:PlaySound("icey2_sfx/skill/phantom_sword/release")
    self.inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/fireball")
    self.inst.components.timer:StartTimer(self.cooldown_timer_name, self.cooldown)
end

return Icey2SkillPhantomSword
