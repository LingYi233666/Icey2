local Icey2BonusArea = Class(function(self, inst)
    self.inst = inst

    self.radius = 6
    self.testfn = nil
    self.circle_prefab = nil
    self.bonus_damage_mult = 1
    self.bonus_damage_planar = 5

    self.end_time = nil
    self.circle_fx = nil
    self.buffered_creatures = {}
end)

function Icey2BonusArea:Start(duration)
    if duration then
        self.end_time = GetTime() + duration
    else
        self.end_time = nil
    end

    if self.circle_fx and self.circle_fx:IsValid() then
        self.circle_fx:Remove()
    end

    if self.circle_prefab then
        self.circle_fx = self.inst:SpawnChild(self.circle_prefab)
    end

    self.inst:StartUpdatingComponent(self)
end

function Icey2BonusArea:CheckToRemove(remove_all)
    local ents_to_be_removed = {}

    for ent, _ in pairs(self.buffered_creatures) do
        if remove_all or not self:CanBeBuffered(ent) then
            table.insert(ents_to_be_removed, ent)
        end
    end

    for _, v in pairs(ents_to_be_removed) do
        if v:IsValid() then
            -- Remove buffer of target
            if v.components.combat then
                v.components.combat.externaldamagemultipliers:RemoveModifier(self.inst, self.inst.prefab)
            end

            if v.components.planardamage then
                v.components.planardamage:RemoveBonus(self.inst, self.inst.prefab)
            end
        end
        self.buffered_creatures[v] = nil

        print(self.inst, "Remove area member:", v)
    end
end

function Icey2BonusArea:Stop()
    self.inst:StopUpdatingComponent(self)
    self:CheckToRemove(true)

    if self.circle_fx and self.circle_fx:IsValid() then
        if self.circle_fx.KillFX then
            self.circle_fx:KillFX()
        else
            self.circle_fx:Remove()
        end
    end
    self.circle_fx = nil
end

function Icey2BonusArea:CanBeBuffered(target)
    return target
        and target:IsValid()
        and target:IsNear(self.inst, self.radius)
        and (self.testfn == nil or self.testfn(self.inst, target))
end

function Icey2BonusArea:OnUpdate(dt)
    if self.end_time and GetTime() >= self.end_time then
        self:Stop()
        return
    end


    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.radius, nil, { "INLIMBO", "FX" })

    for _, v in pairs(ents) do
        if self.buffered_creatures[v] == nil and self:CanBeBuffered(v) then
            -- Buffer target
            if v.components.combat then
                v.components.combat.externaldamagemultipliers:SetModifier(self.inst, self.bonus_damage_mult,
                    self.inst.prefab)
            end

            if not v.components.planardamage then
                v:AddComponent("planardamage")
            end
            v.components.planardamage:AddBonus(self.inst, self.bonus_damage_planar, self .. prefab)

            self.buffered_creatures[v] = true

            print(self.inst, "New area member:", v)
        end
    end

    self:CheckToRemove()
end

return Icey2BonusArea