local AOEWeapon_Base = require("components/aoeweapon_base")

local Icey2AOEWeapon_FlurryLunge = Class(AOEWeapon_Base, function(self, inst)
    AOEWeapon_Base._ctor(self, inst)

    self.search_distance = 6
    self.search_distance_final = 2
    self.possibile_targets = {}
    self.max_lunge_count = 5
    self.is_final_blow = false

    self:SetTags("_combat")
    self:SetWorkActions()

    inst:AddTag("icey2_aoeweapon")
end)

function Icey2AOEWeapon_FlurryLunge:GetMaxLungeCount()
    return self.max_lunge_count
end

function Icey2AOEWeapon_FlurryLunge:IsValidTarget(attacker, target)
    return target
        and not target:HasOneOfTags(self.notags)
        and attacker.components.combat:CanTarget(target)
        and not attacker.components.combat:IsAlly(target)
end

function Icey2AOEWeapon_FlurryLunge:SearchPossibleTargets(attacker, target_pos, dist_override, max_cnt_override)
    self.possibile_targets = {}

    local ents = TheSim:FindEntities(target_pos.x, target_pos.y, target_pos.z, dist_override or self.search_distance, nil,
        self.notags, self.combinedtags)

    for _, v in pairs(ents) do
        if self:IsValidTarget(attacker, v) then
            -- if v:HasTag("hostile") or v:HasTag("monster") or v.components.combat:TargetIs(self.inst) then
            --     table.insert(self.possibile_targets, v)
            -- end
            table.insert(self.possibile_targets, v)
        end
    end

    local max_cnt = max_cnt_override or self.max_lunge_count
    while #self.possibile_targets > max_cnt do
        table.remove(self.possibile_targets, math.random(#self.possibile_targets))
    end

    return #self.possibile_targets > 0
end

function Icey2AOEWeapon_FlurryLunge:PopTarget(attacker)
    -- if #self.possibile_targets > 0 then
    --     return table.remove(self.possibile_targets, 1)
    -- end

    while #self.possibile_targets > 0 do
        local target = table.remove(self.possibile_targets, 1)
        if self:IsValidTarget(attacker, target) and target:IsNear(attacker, 33) then
            return target
        end
    end
end

function Icey2AOEWeapon_FlurryLunge:FindPosNearTarget(attacker, target)
    -- local radius = math.clamp(attacker:GetPhysicsRadius(0) + target:GetPhysicsRadius(0), 0.5,
    --     attacker.components.combat:GetHitRange() - 0.1)

    local hitrange = attacker.components.combat:GetHitRange()
    local radius = math.clamp(hitrange - target:GetPhysicsRadius(0), 1, hitrange - 0.1)
    local offset = Vector3FromTheta(math.random() * PI2, radius)
    return target:GetPosition() + offset
end

function Icey2AOEWeapon_FlurryLunge:TeleportNearTarget(attacker, target)
    attacker.Transform:SetPosition(self:FindPosNearTarget(attacker, target):Get())
    attacker:ForceFacePoint(target:GetPosition())
end

function Icey2AOEWeapon_FlurryLunge:Attack(attacker, target)
    if not self.inst.components.icey2_spdamage_force then
        self.inst:AddComponent("icey2_spdamage_force")
    end
    self.inst.components.icey2_spdamage_force:AddBonus(self.inst, Icey2Math.SumDices(4, 8), "Icey2AOEWeapon_FlurryLunge")

    self:OnHit(attacker, target)

    self.inst.components.icey2_spdamage_force:RemoveBonus(self.inst, "Icey2AOEWeapon_FlurryLunge")
end

function Icey2AOEWeapon_FlurryLunge:FinalBlow(attacker)
    self.is_final_blow = true

    self:SearchPossibleTargets(attacker, attacker:GetPosition(), self.search_distance_final, 99999)
    for _, v in pairs(self.possibile_targets) do
        self:OnHit(attacker, v)
    end

    self.possibile_targets = {}

    self.is_final_blow = false
end

return Icey2AOEWeapon_FlurryLunge
