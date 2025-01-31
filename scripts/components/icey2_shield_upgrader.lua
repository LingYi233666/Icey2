local Icey2ShieldUpgrader = Class(function(self, inst)
    self.inst = inst

    self.bonus_shield = 10
    self.bonus_max_damage_absorb = 10
    self.fullfil_shield = true
    self.emit_fx = true
end)


function Icey2ShieldUpgrader:Use(target, doer)
    if not target.components.icey2_skill_shield then
        return
    end

    local ceil_shield = 250
    local add_shield = math.min(ceil_shield - target.components.icey2_skill_shield.max, self.bonus_shield)

    if add_shield > 0 then
        target.components.icey2_skill_shield:SetMaxShield(target.components.icey2_skill_shield.max + add_shield)
    end

    local ceil_absorb = 150
    local add_absorb = math.min(ceil_absorb - target.components.icey2_skill_shield.max_damage_absorb,
        self.bonus_max_damage_absorb)

    if add_absorb > 0 then
        target.components.icey2_skill_shield.max_damage_absorb = target.components.icey2_skill_shield
            .max_damage_absorb + add_absorb
    end

    if self.fullfil_shield then
        target.components.icey2_skill_shield:SetPercent(1)
    end

    if self.emit_fx then
        -- mode, duration, speed, scale, source_or_pt, maxDist
        target:ShakeCamera(CAMERASHAKE.FULL, 0.6, 0.03, 0.3, nil, 40)
        SendModRPCToClient(CLIENT_MOD_RPC["icey2_rpc"]["push_shield_charge_anim"], target.userid)
    end

    if self.inst.components.stackable then
        self.inst.components.stackable:Get():Remove()
    else
        self.inst:Remove()
    end

    return true
end

return Icey2ShieldUpgrader
