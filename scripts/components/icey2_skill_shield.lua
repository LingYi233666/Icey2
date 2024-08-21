local Icey2Shield = Class(function(self, inst)
    self.inst = inst

    self.current = 100
    self.max = 100

    self.max_damage_absorb = 20
    self.effect_factor = 1
end)

function Icey2Shield:SetVal(current)
    self.current = math.clamp(current, 0, self.max)
end

function Icey2Shield:DoDelta(amount)
    local old = self.current
    self:SetVal(self.current + amount)

    self.inst:PushEvent("icey2_shield_delta", { old = old })
end

function Icey2Shield:GetPercent()
    return self.current / self.max
end

function Icey2Shield:RedirectDamageToShield(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
    if ignore_absorb or ignore_invincible or amount >= 0 or overtime or afflicter == nil then
        return amount
    end

    local absorbtion = math.min(math.min(self.max_damage_absorb, self.current * self.effect_factor), -amount)
    absorbtion = math.max(0, absorbtion)

    self:DoDelta(-absorbtion / self.effect_factor)

    ---- FX -----

    --------------

    --print(string.format("Trading %2.2f moisture for %2.2f life! Took %2.2f damage. Original damage was %2.2f.", absorbtion * rate, absorbtion, amount + absorbtion, amount))

    return amount + absorbtion
end

return Icey2Shield
