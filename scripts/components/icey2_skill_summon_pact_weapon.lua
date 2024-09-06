local Icey2SkillBase_Active = require("components/icey2_skill_base_active")

local Icey2SkillSummonPactWeapon = Class(Icey2SkillBase_Active, function(self, inst)
    Icey2SkillBase_Active._ctor(self, inst)

    ------------------------------------------
    self.cooldown = 0.5

    ------------------------------------------

    self.pact_weapon_options = {
        "icey2_repair",
        -- "icey2_greatsword",
        -- "icey2_greatsickle",
    }

    self.linked_weapon = nil

    self._regive_weapon_task = nil
    self._on_linked_weapon_dropped_fn = nil
    self._on_linked_weapon_pickup_fn = nil
    self._on_linked_weapon_removed_fn = nil
end)

function Icey2SkillSummonPactWeapon:LinkWeapon(weapon)
    self:UnlinkWeapon()

    self.linked_weapon = weapon

    self._on_linked_weapon_dropped_fn = function(_, data)
        if self._regive_weapon_task then
            return
        end

        if data.item == weapon then
            if not self.inst.components.inventory:GiveItem(weapon) then
                self:StartRegiveTask()
            end
        end
    end

    self._on_linked_weapon_pickup_fn = function(_, data)
        if data.item == weapon and self._regive_weapon_task then
            self:StopRegiveTask()
        end
    end

    self._on_linked_weapon_removed_fn = function(_, data)
        self:UnlinkWeapon()
    end

    self.inst:ListenForEvent("dropitem", self._on_linked_weapon_dropped_fn)
    self.inst:ListenForEvent("itemget", self._on_linked_weapon_pickup_fn)
    self.inst:ListenForEvent("onremove", self._on_linked_weapon_removed_fn, weapon)
end

function Icey2SkillSummonPactWeapon:UnlinkWeapon(remove_weapon)
    if self.linked_weapon then
        local weapon = self.linked_weapon

        self:StopRegiveTask()
        self.inst:RemoveEventCallback("dropitem", self._on_linked_weapon_dropped_fn)
        self.inst:RemoveEventCallback("itemget", self._on_linked_weapon_pickup_fn)
        self.inst:RemoveEventCallback("onremove", self._on_linked_weapon_removed_fn)

        self.linked_weapon = nil

        self._regive_weapon_task = nil
        self._on_linked_weapon_dropped_fn = nil
        self._on_linked_weapon_pickup_fn = nil
        self._on_linked_weapon_removed_fn = nil

        weapon:PushEvent("icey2_unlink_pact_weapon", { old_owner = self.inst })

        if remove_weapon and weapon:IsValid() then
            weapon:Remove()
        end
    end
end

function Icey2SkillSummonPactWeapon:WeaponToData()
    if self.linked_weapon then
        local weapondata = self.linked_weapon:GetSaveRecord()
        self.linked_weapon:Remove()

        return weapondata
    end
end

function Icey2SkillSummonPactWeapon:DataToWeapon(weapondata)
    local entity = SpawnSaveRecord(weapondata)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    entity.Transform:SetPosition(x, y, z)

    self:LinkWeapon(entity)

    self.inst.components.inventory:GiveItem(entity)
end

function Icey2SkillSummonPactWeapon:StartRegiveTask()
    self._regive_weapon_task = self.inst:DoPeriodicTask(0, function()
        if not (self.linked_weapon and self.linked_weapon:IsValid()) then
            self:StopRegiveTask()
            return
        end

        if self.linked_weapon.components.inventoryitem.owner == self.inst then
            self:StopRegiveTask()
            return
        end

        if not self.inst:IsNear(self.linked_weapon, 30) then
            self:UnlinkWeapon()
            return
        end

        if self.inst:IsNear(self.linked_weapon, 6) then
            if self.inst.components.inventory:GiveItem(self.linked_weapon) then
                self:StopRegiveTask()
            end
        end
    end)
end

function Icey2SkillSummonPactWeapon:StopRegiveTask()
    if self._regive_weapon_task then
        self._regive_weapon_task:Cancel()
        self._regive_weapon_task = nil
    end
end

function Icey2SkillSummonPactWeapon:ShowPactWeaponsWheel()

end

function Icey2SkillSummonPactWeapon:Cast(x, y, z, target)
    Icey2SkillBase_Active.Cast(self, x, y, z, target)

    self:ShowPactWeaponsWheel()
end

function Icey2SkillSummonPactWeapon:OnSave()
    local data = Icey2SkillBase_Active.OnSave(self)
    if self.linked_weapon and self.linked_weapon:IsValid() then
        data.weapondata = self:WeaponToData()
    end

    return data
end

function Icey2SkillSummonPactWeapon:OnLoad(data)
    Icey2SkillBase_Active.OnLoad(self, data)

    if data ~= nil then
        if data.weapondata ~= nil then
            self:DataToWeapon(data.weapondata)
        end
    end
end

return Icey2SkillSummonPactWeapon
