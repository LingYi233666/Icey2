local Icey2SkillBase_Active = require("components/icey2_skill_base_active")

local Icey2SkillPhantomSword = Class(Icey2SkillBase_Active, function(self, inst)
    Icey2SkillBase_Active._ctor(self, inst)

    ------------------------------------------
    self.can_cast_while_busy = true
    self.can_cast_while_riding = true
    self.can_cast_while_wearing_armor = true
    self.costs.hunger = 1
    self.cooldown = 0.5

    ------------------------------------------

    self.num_swords = 5
    self.cast_distance = 25
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

function Icey2SkillPhantomSword:CanCast(x, y, z, target)
    local success, reason = Icey2SkillBase_Active.CanCast(self, x, y, z, target)
    if not success then
        return false, reason
    end

    if target == nil and not self:SearchPossibleTargets() then
        return false, "NO_TARGET"
    elseif target and not self:IsValidTarget(target) then
        return false, "INVALID_TARGET"
    end

    return true
end

function Icey2SkillPhantomSword:Cast(x, y, z, target)
    Icey2SkillBase_Active.Cast(self, x, y, z, target)

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
    end

    self.possibile_targets = {}
end

return Icey2SkillPhantomSword
