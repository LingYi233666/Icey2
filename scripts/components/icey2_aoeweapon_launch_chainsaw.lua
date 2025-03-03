local AOEWeapon_Base = require("components/aoeweapon_base")

local Icey2AOEWeapon_LaunchChainsaw = Class(AOEWeapon_Base, function(self, inst)
    AOEWeapon_Base._ctor(self, inst)

    self.doer = nil
    self.projectile = nil

    self.onlaunch = nil
    self.onreturn = nil
    -- self.duration =

    inst:AddTag("icey2_aoeweapon")
end)

function Icey2AOEWeapon_LaunchChainsaw:GetProjectile()
    return self.projectile
end

function Icey2AOEWeapon_LaunchChainsaw:Launch(target_pos, doer)
    self:Return()

    self.doer = doer
    self.projectile = SpawnAt("icey2_pact_weapon_chainsaw_projectile", doer)
    self.projectile.components.complexprojectile:Launch(target_pos, doer)


    if self.onlaunch then
        self.onlaunch(self.inst, doer, target_pos)
    end

    self._callback = function()
        self:Return()
    end

    self.inst:ListenForEvent("onremove", self._callback)
    self.inst:ListenForEvent("onremove", self._callback, self.projectile)
    self.inst:ListenForEvent("onremove", self._callback, self.doer)
    self.inst:ListenForEvent("death", self._callback, self.doer)
    self.inst:ListenForEvent("playerdeactivated", self._callback, self.doer)
end

function Icey2AOEWeapon_LaunchChainsaw:Return()
    if self.projectile and self.projectile:IsValid() then
        self.inst:RemoveEventCallback("onremove", self._callback)
        self.inst:RemoveEventCallback("onremove", self._callback, self.projectile)
        self.inst:RemoveEventCallback("onremove", self._callback, self.doer)
        self.inst:RemoveEventCallback("death", self._callback, self.doer)
        self.inst:RemoveEventCallback("playerdeactivated", self._callback, self.doer)
        self._callback = nil

        if self.onreturn then
            self.onreturn(self.inst, self.doer, self.projectile)
        end
        self.projectile:Remove()
    end
    self.projectile = nil
    self.doer = nil
end

return Icey2AOEWeapon_LaunchChainsaw
