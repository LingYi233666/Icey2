local Icey2SkillBase_Active = require("components/icey2_skill_base_active")

local Icey2SkillDodge = Class(Icey2SkillBase_Active, function(self, inst)
    Icey2SkillBase_Active._ctor(self, inst)

    ------------------------------------------
    self.can_cast_while_busy = true
    self.costs.hunger = 1
    self.cooldown = 0.33

    ------------------------------------------

    self.search_dist = 3
    self.dodge_speed = 25
    self.max_dodge_charge = 1
    self.dodge_charge = 1
end)

function Icey2SkillDodge:DoDeltaCharge(delta)
    self.dodge_charge = math.clamp(self.dodge_charge + delta, 0, self.max_dodge_charge)
    if self.dodge_charge < self.max_dodge_charge then
        -- TODO:Prepare to recharge
    end
end

function Icey2SkillDodge:SearchCreaturesAutoToAttack()
    local creatures = {}
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.search_dist, { "_combat", "_health" }, { "INLIMBO" })
    for _, v in pairs(ents) do
        if self.inst.components.combat:CanTarget(v)
            and v.components.combat:TargetIs(self.inst)
            and (v:HasTag("abouttoattack") or (v.sg and v.sg:HasStateTag("abouttoattack"))) then
            table.insert(creatures, v)
        end
    end

    return creatures
end

function Icey2SkillDodge:CounterBack(target)
    local shadow = SpawnPrefab("icey2_clone_dodge_counter_back")
    local dmg, spdmg = self.inst.component.combat:CalcDamage(target, self.inst.component.combat:GetWeapon(), 2)

    shadow.components.planardamage:SetBaseDamage(dmg + (spdmg.planar or 0))
    shadow:SetSuitablePosition(target)
    shadow:CounterBack(target)
end

function Icey2SkillDodge:IsWearingArmor()
    for k, v in pairs(self.inst.components.inventory.equipslots) do
        if v.components.armor ~= nil and not v:HasTag("ignore_icey2_unarmoured_defence_limit") then
            return true
        end
    end
end

function Icey2SkillDodge:OnDodgeStart(target_pos)
    self.inst.components.locomotor:Stop()

    self.inst:ForceFacePoint(target_pos)
    self.inst.Physics:SetMotorVelOverride(self.dodge_speed, 0, 0)

    if not self:IsWearingArmor() then
        self.inst.components.health:SetInvincible(true)

        local enemies = self:SearchCreaturesAutoToAttack()
        if #enemies > 0 then
            self:CounterBack(enemies[1])
        end

        self.inst.AnimState:SetMultColour(0.1, 0.1, 0.9, 0.5)
    end

    self.inst.SoundEmitter:PlaySound("")
end

function Icey2SkillDodge:OnDodging()
    self.inst.Physics:SetMotorVelOverride(self.dodge_speed, 0, 0)
end

function Icey2SkillDodge:OnDodgeStop()
    self.inst.Physics:ClearMotorVelOverride()
    self.inst.Physics:Stop()
    self.inst.components.health:SetInvincible(false)

    self.inst.AnimState:SetMultColour(1, 1, 1, 1)
end

function Icey2SkillDodge:CanCast(x, y, z, target)
    local success, reason = Icey2SkillBase_Active.CanCast(self, x, y, z, target)
    if not success then
        return false, reason
    end

    if self.dodge_charge < 1 then
        return false, "NOT_ENOUGH_DODGE_CHARGE"
    end

    return true
end

function Icey2SkillDodge:Cast(x, y, z, target)
    Icey2SkillBase_Active.Cast(self, x, y, z, target)

    self.inst.sg:GoToState("icey2_dodge", { pos = Vector3(x, y, z) })
end

return Icey2SkillDodge
