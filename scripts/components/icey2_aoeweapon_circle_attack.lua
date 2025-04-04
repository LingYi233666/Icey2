local AOEWeapon_Base = require("components/aoeweapon_base")

local Icey2AOEWeapon_CircleAttack = Class(AOEWeapon_Base, function(self, inst)
    AOEWeapon_Base._ctor(self, inst)

    self.doer = nil
    self.duration = nil

    inst:AddTag("icey2_aoeweapon")
end)

function Icey2AOEWeapon_CircleAttack:Start(doer, duration)
    if not doer and doer:IsValid() then
        return
    end

    self:Stop()

    self.doer = doer
    self.duration = duration
    self._stop_when_need = function()
        self:Stop()
    end

    self.inst:ListenForEvent("death", self._stop_when_need, doer)

    self.inst:StartUpdatingComponent(self)
end

function Icey2AOEWeapon_CircleAttack:Stop()
    if not self.doer then
        return
    end

    self.inst:RemoveEventCallback("death", self._stop_when_need, self.doer)

    self.inst:StopUpdatingComponent(self)

    self.doer = nil
    self.duration = nil
    self._stop_when_need = nil
end

function Icey2AOEWeapon_CircleAttack:OnUpdate(dt)
    self.duration = self.duration - dt
    if self.duration <= 0 then
        self:Stop()
    end
end

return Icey2AOEWeapon_CircleAttack
