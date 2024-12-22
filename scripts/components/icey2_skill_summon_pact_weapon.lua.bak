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

        "icey2_pact_weapon_rapier",
        "icey2_pact_weapon_scythe",

        -- These are for testing.
        "spear",
        "hambat",
        "tentaclespike",
    }

    self.pact_weapon_can_use = {}
    self.pact_weapon_savedatas = {}
    self.pact_weapon_last_remove_time = {}


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
    local options_clone = shallowcopy(self.pact_weapon_options)

    for prefab, enable in pairs(self.pact_weapon_can_use) do
        if enable == false then
            table.removearrayvalue(options_clone, prefab)
        end
    end

    local js_value = json.encode(options_clone)
    self.inst.replica.icey2_skill_summon_pact_weapon:SetWeaponOptionsJson(js_value)
end

function Icey2SkillSummonPactWeapon:AddWeaponPrefab(prefab)
    if table.contains(self.pact_weapon_options, prefab) then
        print(prefab .. " is already exists in pact weapon options")
        return
    end

    table.insert(self.pact_weapon_options, prefab)
    table.sort(self.pact_weapon_options)

    self:UpdateJsonData()
end

function Icey2SkillSummonPactWeapon:RemoveWeaponPrefab(prefab)
    if not table.contains(self.pact_weapon_options, prefab) then
        print(prefab .. " not exist in pact weapon options")
        return
    end

    table.removearrayvalue(self.pact_weapon_options, prefab)

    self:UpdateJsonData()
end

-- For scythe
function Icey2SkillSummonPactWeapon:SetWeaponCanUse(prefab, enable)
    if enable then
        self.pact_weapon_can_use[prefab] = nil
    else
        self.pact_weapon_can_use[prefab] = false
    end
    self:UpdateJsonData()
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
            print("Drop pact weapon:", data.item)

            if self._regive_weapon_task then
                return
            end

            -- if not self:ReturnWeaponToOwner(weapon) then
            --     self:StartRegiveTask()
            -- end
            self:StartRegiveTask()
        end
    end

    self._on_linked_weapon_pickup_fn = function(_, data)
        if data.item == weapon then
            print("Pickup my pact weapon:", data.item)

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
            self.pact_weapon_last_remove_time[weapon.prefab] = GetTime()
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
    if self.linked_weapon
        and self.linked_weapon:IsValid()
        and self.linked_weapon:HasTag("icey2_pact_weapon_no_regive") then
        return
    end

    self._regive_weapon_task = self.inst:DoPeriodicTask(0, function()
        if not (self.linked_weapon and self.linked_weapon:IsValid()) then
            self:StopRegiveTask()
            return
        end

        if self.linked_weapon
            and self.linked_weapon:IsValid()
            and self.linked_weapon:HasTag("icey2_pact_weapon_no_regive") then
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
function Icey2SkillSummonPactWeapon:SummonWeapon(prefab, emit_fx)
    if not table.contains(self.pact_weapon_options, prefab) then
        return
    end

    local weapon
    if self.pact_weapon_savedatas[prefab] ~= nil then
        weapon = self:DataToWeapon(self.pact_weapon_savedatas[prefab])
        if weapon == nil then
            return
        end

        if weapon.components.rechargeable
            and not weapon.components.rechargeable:IsCharged()
            and self.pact_weapon_last_remove_time[prefab] ~= nil then
            -- When weapon is not summoned, its skill cd is not calculated,
            -- so I add this, apply duration to skill cd.
            local duration = math.max(0, GetTime() - self.pact_weapon_last_remove_time[prefab])
            weapon.components.rechargeable:SetCharge(weapon.components.rechargeable:GetCharge() + duration)
        end
    else
        weapon = SpawnAt(prefab, self.inst)
    end

    if weapon == nil then
        return
    end

    self:LinkWeapon(weapon)
    if not self.inst.components.inventory:Equip(weapon) then
        self:StartRegiveTask()
    else
        if emit_fx then
            local fx = self.inst:SpawnChild("icey2_pact_weapon_rapier_emit_fx")
            fx.entity:AddFollower()
            fx.Follower:FollowSymbol(self.inst.GUID, "swap_object", nil, nil, nil, true)
        end
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
    data.pact_weapon_time_since_remove = {}
    for prefab, last_remove_time in pairs(self.pact_weapon_last_remove_time) do
        data.pact_weapon_time_since_remove[prefab] = GetTime() - last_remove_time
    end

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
        if data.pact_weapon_time_since_remove ~= nil then
            for prefab, time_since_remove in pairs(data.pact_weapon_time_since_remove) do
                self.pact_weapon_last_remove_time[prefab] = GetTime() - time_since_remove
            end
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
