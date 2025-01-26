local Icey2StatusBonus = Class(function(self, inst)
    self.inst = inst

    self.base_value = {
        hunger                 = TUNING.ICEY2_HUNGER,
        health                 = TUNING.ICEY2_HEALTH,
        sanity                 = TUNING.ICEY2_SANITY,
        normal_defense_percent = 0,
        planar_defense         = 0,
    }

    self.bonus_value = {
        hunger                 = 0,
        health                 = 0,
        sanity                 = 0,
        normal_defense_percent = 0,
        planar_defense         = 0,
    }

    self.use_icey2_reroll_data_handler = true
end)

function Icey2StatusBonus:AddBonus(dtype, val)
    self.bonus_value[dtype] = math.max(self.bonus_value[dtype] + val, 0)

    self:Apply()
end

function Icey2StatusBonus:Apply()
    local hunger_percent = self.inst.components.hunger:GetPercent()
    local health_percent = self.inst.components.health:GetPercent()
    local sanity_percent = self.inst.components.sanity:GetPercent()

    self.inst.components.hunger.max = self.base_value.hunger + self.bonus_value.hunger
    self.inst.components.health.maxhealth = self.base_value.health + self.bonus_value.health
    self.inst.components.sanity.max = self.base_value.sanity + self.bonus_value.sanity

    self.inst.components.hunger:SetPercent(hunger_percent)
    self.inst.components.health:SetPercent(health_percent)
    self.inst.components.sanity:SetPercent(sanity_percent)

    self.inst.components.combat.externaldamagetakenmultipliers:SetModifier(self.inst,
        math.max(0, 1 - (self.base_value.normal_defense_percent + self.bonus_value.normal_defense_percent)),
        "icey2_status_bonus")

    self.inst.components.planardefense:AddBonus(self.inst,
        self.base_value.planar_defense + self.bonus_value.planar_defense, "icey2_status_bonus")
end

function Icey2StatusBonus:OnSave()
    local data = {
        bonus_value = self.bonus_value,
        old_percent = {
            hunger = self.inst.components.hunger:GetPercent(),
            health = self.inst.components.health:GetPercent(),
            sanity = self.inst.components.sanity:GetPercent(),
        },
    }

    return data
end

function Icey2StatusBonus:OnLoad(data)
    if data ~= nil then
        if data.bonus_value ~= nil then
            self.bonus_value = data.bonus_value
        end
    end

    self:Apply()

    if data ~= nil then
        if data.old_percent ~= nil then
            if data.old_percent.hunger ~= nil then
                self.inst.components.hunger:SetPercent(data.old_percent.hunger)
            end
            if data.old_percent.health ~= nil then
                self.inst.components.health:SetPercent(data.old_percent.health)
            end
            if data.old_percent.sanity ~= nil then
                self.inst.components.sanity:SetPercent(data.old_percent.sanity)
            end
        end
    end
end

return Icey2StatusBonus
