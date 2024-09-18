local Icey2SkillBase_Active = require("components/icey2_skill_base_active")


local Icey2SkillSummonPactWeapon = Class(Icey2SkillBase_Active, function(self, inst)
    Icey2SkillBase_Active._ctor(self, inst)

    ------------------------------------------
    -- self.cooldown = 0.5

    ------------------------------------------

    self.pact_weapon_options = {
        -- "icey2_repair",
        -- "icey2_greatsword",
        -- "icey2_greatsickle",

        "spear",
        "hambat",
        "tentaclespike",
    }

    self.pact_weapon_savedatas = {

    }


    self.linked_weapon = nil

    self.restrictedtag = "icey2_skill_summon_pact_weapon_" .. self.inst.GUID

    self.inst:AddTag(self.restrictedtag)

    self._regive_weapon_task = nil
    self._on_linked_weapon_dropped_fn = nil
    self._on_linked_weapon_pickup_fn = nil
    self._on_linked_weapon_equipped_fn = nil
    self._on_linked_weapon_removed_fn = nil

    self.inst:ListenForEvent("death", function()
        self:UnlinkWeapon(true)
    end)
    self.inst:ListenForEvent("onremove", function()
        self:UnlinkWeapon(true)
    end)
    self.inst:ListenForEvent("playerdeactivated", function()
        self:UnlinkWeapon(true)
    end)

    self:UpdateJsonData()
end)


function Icey2SkillSummonPactWeapon:UpdateJsonData()
    local pact_weapon_options_json = json.encode(self.pact_weapon_options)
    self.inst.replica.icey2_skill_summon_pact_weapon:SetWeaponOptionsJson(pact_weapon_options_json)
end

function Icey2SkillSummonPactWeapon:LinkWeapon(weapon)
    self:UnlinkWeapon(true)

    self.linked_weapon = weapon

    weapon.persists = false
    weapon.components.equippable.restrictedtag = self.restrictedtag
    weapon.components.equippable.refuse_on_restrict = true

    self._on_linked_weapon_dropped_fn = function(_, data)
        if self.ignore_drop_handler then
            return
        end

        if data.item == weapon then
            if data.item == weapon then
                print("Drop weapon:", data.item)
            end

            if self._regive_weapon_task then
                return
            end

            if not self:ReturnWeaponToOwner(weapon) then
                self:StartRegiveTask()
            end
        end
    end

    self._on_linked_weapon_pickup_fn = function(_, data)
        if data.item == weapon then
            print("Pickup weapon:", data.item)

            self:StopRegiveTask()
        end
    end

    self._on_linked_weapon_equipped_fn = function(_, data)
        local owner = weapon.components.inventoryitem.owner
        if owner ~= self.inst then
            print(weapon, "is equipped by someone else !")
            self:StartRegiveTask()
        end
    end

    self._on_linked_weapon_removed_fn = function(_, data)
        local prefab = weapon.prefab
        self:UnlinkWeapon()
        self.pact_weapon_savedatas[prefab] = nil
    end

    self.inst:ListenForEvent("dropitem", self._on_linked_weapon_dropped_fn)
    self.inst:ListenForEvent("itemget", self._on_linked_weapon_pickup_fn)
    self.inst:ListenForEvent("equipped", self._on_linked_weapon_equipped_fn, weapon)
    self.inst:ListenForEvent("onremove", self._on_linked_weapon_removed_fn, weapon)

    self.inst.replica.icey2_skill_summon_pact_weapon:SetLinkedWeapon(weapon)
end

function Icey2SkillSummonPactWeapon:UnlinkWeapon(remove_weapon)
    if self.linked_weapon then
        local weapon = self.linked_weapon

        weapon.components.equippable.restrictedtag = nil
        weapon.components.equippable.refuse_on_restrict = false

        self:StopRegiveTask()
        self.inst:RemoveEventCallback("dropitem", self._on_linked_weapon_dropped_fn)
        self.inst:RemoveEventCallback("itemget", self._on_linked_weapon_pickup_fn)
        self.inst:RemoveEventCallback("equipped", self._on_linked_weapon_equipped_fn, weapon)
        self.inst:RemoveEventCallback("onremove", self._on_linked_weapon_removed_fn, weapon)

        self.linked_weapon = nil

        self._regive_weapon_task = nil
        self._on_linked_weapon_dropped_fn = nil
        self._on_linked_weapon_pickup_fn = nil
        self._on_linked_weapon_equipped_fn = nil
        self._on_linked_weapon_removed_fn = nil

        weapon:PushEvent("icey2_unlink_pact_weapon", { old_owner = self.inst })

        if remove_weapon and weapon:IsValid() then
            self.pact_weapon_savedatas[weapon.prefab] = self:WeaponToData(weapon)
            weapon:Remove()
        end
    end

    self.inst.replica.icey2_skill_summon_pact_weapon:SetLinkedWeapon(nil)
end

function Icey2SkillSummonPactWeapon:ReturnWeaponToOwner(weapon)
    -- self.ignore_drop_handler = true
    local hands = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

    if self.inst.components.inventory:IsFull() and hands ~= nil then
        return false
    end

    if hands == nil and self.inst.components.inventory:Equip(weapon) then
        self.ignore_drop_handler = false
        return true
    end

    if self.inst.components.inventory:GiveItem(weapon) then
        self.ignore_drop_handler = false
        return true
    end

    self.ignore_drop_handler = false
    return false
end

function Icey2SkillSummonPactWeapon:WeaponToData(weapon)
    return weapon:GetSaveRecord()
end

function Icey2SkillSummonPactWeapon:DataToWeapon(weapondata)
    local entity = SpawnSaveRecord(weapondata)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    entity.Transform:SetPosition(x, y, z)

    return entity
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
            self:UnlinkWeapon(true)
            return
        end

        if self.inst:IsNear(self.linked_weapon, 6) then
            if self:ReturnWeaponToOwner(self.linked_weapon) then
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

-- ThePlayer.components.icey2_skill_summon_pact_weapon:SummonWeapon("spear")
function Icey2SkillSummonPactWeapon:SummonWeapon(prefab)
    if not table.contains(self.pact_weapon_options, prefab) then
        return
    end

    local weapon
    if self.pact_weapon_savedatas[prefab] ~= nil then
        weapon = self:DataToWeapon(self.pact_weapon_savedatas[prefab])
    else
        weapon = SpawnAt(prefab, self.inst)
    end

    if weapon == nil then
        return
    end

    self:LinkWeapon(weapon)
    if not self.inst.components.inventory:Equip(weapon) then
        self:StartRegiveTask()
    end
end

-- function Icey2SkillSummonPactWeapon:Cast(x, y, z, target)
--     Icey2SkillBase_Active.Cast(self, x, y, z, target)
-- end

function Icey2SkillSummonPactWeapon:OnSave()
    local data = Icey2SkillBase_Active.OnSave(self)

    if self.linked_weapon then
        data.linked_weapon_prefab = self.linked_weapon.prefab
        self.pact_weapon_savedatas[self.linked_weapon.prefab] = self:WeaponToData(self.linked_weapon)
    end
    data.pact_weapon_savedatas = self.pact_weapon_savedatas

    print("Icey2SkillSummonPactWeapon:OnSave() pact_weapon_savedatas = ")
    dumptable(self.pact_weapon_savedatas)

    return data
end

function Icey2SkillSummonPactWeapon:OnLoad(data)
    Icey2SkillBase_Active.OnLoad(self, data)

    if data ~= nil then
        if data.pact_weapon_savedatas ~= nil then
            self.pact_weapon_savedatas = data.pact_weapon_savedatas
        end
        if data.linked_weapon_prefab ~= nil then
            self:SummonWeapon(data.linked_weapon_prefab)
        end
    end

    print("Icey2SkillSummonPactWeapon:OnLoad() pact_weapon_savedatas = ")
    dumptable(self.pact_weapon_savedatas)
end

function Icey2SkillSummonPactWeapon:OnUpdate()

end

return Icey2SkillSummonPactWeapon
