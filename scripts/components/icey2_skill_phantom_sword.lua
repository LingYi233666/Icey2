local Icey2SkillPhantomSword = Class(function(self, inst)
    self.inst = inst

    self.num_swords = 5

    self.cast_distance = 16

    self.magic_cost = 5

    self.cooldown = 0.25
    self.cooldown_timer_name = "icey2_skill_phantom_sword"

    self.possibile_targets = {}
end)

function Icey2SkillPhantomSword:SearchPossibleTargets()
    self.possibile_targets = {}

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.cast_distance, { "_combat", "_health" }, { "INLIMBO" })
    for _, v in pairs(ents) do
        if self:IsValidTarget(v) then
            if v:HasTag("hostile") or v:HasTag("monster") or v.components.combat:TargetIs(self.inst) then
                table.insert(self.possibile_targets, v)
            end
        end
    end

    return #self.possibile_targets > 0
end

function Icey2SkillPhantomSword:IsValidTarget(target)
    return target
        and self.inst.components.combat:CanTarget(target)
        and not self.inst.components.combat:IsAlly(target)
        and target:IsNear(self.inst, self.cast_distance)
end

function Icey2SkillPhantomSword:CanCast(target)
    if self.inst.components.health:IsDead()
        or self.inst:HasTag("playerghost")
        or self.inst.sg:HasStateTag("dead") then
        return false, "PLAYER_DEAD"
    end

    if self.inst.components.timer:TimerExists(self.cooldown_timer_name) then
        return false, "COOLDOWN"
    end

    if target == nil and not self:SearchPossibleTargets() then
        return false, "NO_TARGET"
    elseif target and not self:IsValidTarget(target) then
        return false, "INVALID_TARGET"
    end

    -- TODO: Not enough magic

    return true
end

function Icey2SkillPhantomSword:Cast(target)
    if target ~= nil then
        self.possibile_targets = { target }
    end

    if #self.possibile_targets > 0 then
        for i = 1, self.num_swords do
            SpawnAt("icey2_phantom_sword", self.inst, nil, { 0, 0.6, 0 }):Launch(self.inst,
                                                                                 GetRandomItem(self.possibile_targets))
        end

        -- self.inst.SoundEmitter:PlaySound("icey2_sfx/skill/phantom_sword/release")
        self.inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/fireball")
        self.inst.components.timer:StartTimer(self.cooldown_timer_name, self.cooldown)
    end

    self.possibile_targets = {}
end

return Icey2SkillPhantomSword
