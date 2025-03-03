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
        -- "icey2_pact_weapon_scythe",

        -- These are for testing.
        -- "spear",
        -- "hambat",
        -- "tentaclespike",
    }

    self.pact_weapon_savedatas = {}
    self.pact_weapon_last_remove_time = {}


    self.linked_weapons = {}

    self.restrictedtag = "icey2_skill_summon_pact_weapon_" .. self.inst.GUID

    self.inst:AddTag(self.restrictedtag)

    -- self._regive_weapon_task = nil
    -- self._on_linked_weapon_dropped_fn = nil
    -- self._on_linked_weapon_pickup_fn = nil
    -- self._on_linked_weapon_equipped_fn = nil
    -- self._on_linked_weapon_removed_fn = nil

    self.weapon_event_listeners = {}
    self.regive_weapon_tasks = {}

    self.inst:ListenForEvent("death", function()
        self:UnlinkAllWeapons(true)
    end)
    self.inst:ListenForEvent("onremove", function()
        self:UnlinkAllWeapons(true)
    end)
    self.inst:ListenForEvent("playerdeactivated", function()
        self:UnlinkAllWeapons(true)
    end)
    self.inst:DoTaskInTime(1, function()
        print("re-summon weapons")
        dumptable(self.linked_weapon_prefabs_tmp)
        if self.linked_weapon_prefabs_tmp then
            for _, v in pairs(self.linked_weapon_prefabs_tmp) do
                self:SummonWeapon(v)
            end
        end
        self.linked_weapon_prefabs_tmp = nil
    end)

    self:UpdateJsonData()

    self.use_icey2_reroll_data_handler = true
end)


function Icey2SkillSummonPactWeapon:UpdateJsonData()
    local options_clone = shallowcopy(self.pact_weapon_options)
    local exists_weapon_prefabs = {}

    for _, v in pairs(self.linked_weapons) do
        if v and v:IsValid() then
            table.insert(exists_weapon_prefabs, v.prefab)
        end
    end

    local options_js_value = json.encode(options_clone)
    local exists_weapon_prefabs_js_value = json.encode(exists_weapon_prefabs)
    self.inst.replica.icey2_skill_summon_pact_weapon:SetWeaponOptionsJson(options_js_value)
    self.inst.replica.icey2_skill_summon_pact_weapon:SetExistsWeaponPrefabsJson(exists_weapon_prefabs_js_value)
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

function Icey2SkillSummonPactWeapon:InitEventListeners(weapon)
    self.weapon_event_listeners[weapon] = {
        {
            "dropitem",
            function(_, data)
                if data.item == weapon then
                    print("Drop pact weapon:", data.item)

                    self:StartRegiveTask(weapon)
                end
            end
        },

        {
            "itemget",
            function(_, data)
                if data.item == weapon then
                    print("Pickup my pact weapon:", data.item)

                    self:StopRegiveTask(weapon)
                end
            end,
        },

        {
            "onremove",
            function()
                local prefab = weapon.prefab
                self:UnlinkWeapon(weapon)
                self.pact_weapon_savedatas[prefab] = nil
            end,
            weapon,
        }
    }


    for _, data in pairs(self.weapon_event_listeners[weapon]) do
        self.inst:ListenForEvent(data[1], data[2], data[3])
    end
end

function Icey2SkillSummonPactWeapon:RemoveEventListeners(weapon)
    for _, data in pairs(self.weapon_event_listeners[weapon]) do
        self.inst:RemoveEventCallback(data[1], data[2], data[3])
    end
    self.weapon_event_listeners[weapon] = nil
end

function Icey2SkillSummonPactWeapon:LinkWeapon(weapon)
    self:UnlinkWeapon(weapon, true)

    table.insert(self.linked_weapons, weapon)

    weapon.persists = false
    weapon.components.equippable.restrictedtag = self.restrictedtag
    weapon.components.equippable.refuse_on_restrict = true

    self:InitEventListeners(weapon)
    self:UpdateJsonData()
end

function Icey2SkillSummonPactWeapon:UnlinkWeapon(weapon_or_prefab, remove_weapon)
    local weapon
    if type(weapon_or_prefab) == "string" then
        for _, v in pairs(self.linked_weapons) do
            if v.prefab == weapon_or_prefab then
                weapon = v
                break
            end
        end

        if weapon == nil then
            -- print(weapon_or_prefab, "is not in self.linked_weapons, exists weapons are:")
            -- dumptable(self.linked_weapons)
            return
        end
    else
        weapon = weapon_or_prefab

        if not table.contains(self.linked_weapons, weapon) then
            -- print(weapon, "is not in self.linked_weapons, exists weapons are:")
            -- dumptable(self.linked_weapons)
            return
        end
    end

    weapon.components.equippable.restrictedtag = nil
    weapon.components.equippable.refuse_on_restrict = false

    table.removearrayvalue(self.linked_weapons, weapon)

    self:RemoveEventListeners(weapon)
    self:StopRegiveTask(weapon)

    weapon:PushEvent("icey2_unlink_pact_weapon", { old_owner = self.inst })

    if remove_weapon and weapon:IsValid() then
        self.pact_weapon_savedatas[weapon.prefab] = self:WeaponToData(weapon)
        self.pact_weapon_last_remove_time[weapon.prefab] = GetTime()
        weapon:Remove()
    end

    self:UpdateJsonData()
end

function Icey2SkillSummonPactWeapon:UnlinkAllWeapons(remove_weapon)
    local tmp = shallowcopy(self.linked_weapons)

    for _, v in pairs(tmp) do
        self:UnlinkWeapon(v, remove_weapon)
    end
end

function Icey2SkillSummonPactWeapon:ReturnWeaponToOwner(weapon)
    local hands = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

    if self.inst.components.inventory:IsFull() and hands ~= nil then
        return false
    end

    if hands == nil and self.inst.components.inventory:Equip(weapon) then
        return true
    end

    if self.inst.components.inventory:GiveItem(weapon) then
        return true
    end

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

function Icey2SkillSummonPactWeapon:StartRegiveTask(weapon)
    if weapon and weapon:IsValid() and weapon:HasTag("icey2_pact_weapon_no_regive") then
        return
    end


    -- self:StopRegiveTask(weapon)
    if self.regive_weapon_tasks[weapon] then
        return
    end

    self.regive_weapon_tasks[weapon] = self.inst:DoPeriodicTask(0, function()
        if not (weapon and weapon:IsValid()) then
            self:StopRegiveTask(weapon)
            return
        end

        if weapon:HasTag("icey2_pact_weapon_no_regive") then
            self:StopRegiveTask(weapon)
            return
        end

        if weapon.components.inventoryitem.owner == self.inst then
            self:StopRegiveTask(weapon)
            return
        end

        if not self.inst:IsNear(weapon, 30) then
            self:UnlinkWeapon(weapon, true)
            return
        end

        if self.inst:IsNear(weapon, 6) then
            if self:ReturnWeaponToOwner(weapon) then
                self:StopRegiveTask(weapon)
            end
        end
    end)
end

function Icey2SkillSummonPactWeapon:StopRegiveTask(weapon)
    if self.regive_weapon_tasks[weapon] then
        self.regive_weapon_tasks[weapon]:Cancel()
        self.regive_weapon_tasks[weapon] = nil
    end
    -- if self._regive_weapon_task then
    --     self._regive_weapon_task:Cancel()
    --     self._regive_weapon_task = nil
    -- end
end

-- ThePlayer.components.icey2_skill_summon_pact_weapon:SummonWeapon("spear")
function Icey2SkillSummonPactWeapon:SummonWeapon(prefab, emit_fx)
    if not table.contains(self.pact_weapon_options, prefab) then
        print(prefab, "is not contained by pact_weapon_options")
        print("pact_weapon_options are follows:")
        dumptable(self.pact_weapon_options)
        return
    end

    for _, v in pairs(self.linked_weapons) do
        if v.prefab == prefab then
            print("You already have a", prefab, "it's", v)
            return
        end
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

            local factor = weapon.components.rechargeable.total / weapon.components.rechargeable:GetChargeTime()
            weapon.components.rechargeable:SetCharge(weapon.components.rechargeable:GetCharge() + duration * factor)
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

function Icey2SkillSummonPactWeapon:SaveForReroll()
    local data = self:OnSave()
    data.linked_weapon_prefabs = nil

    return data
end

function Icey2SkillSummonPactWeapon:OnSave()
    local data = Icey2SkillBase_Active.OnSave(self)

    -- if self.linked_weapon then
    --     data.linked_weapon_prefab = self.linked_weapon.prefab
    --     self.pact_weapon_savedatas[self.linked_weapon.prefab] = self:WeaponToData(self.linked_weapon)
    -- end

    if #self.linked_weapons > 0 then
        data.linked_weapon_prefabs = {}
        for _, v in pairs(self.linked_weapons) do
            if v and v:IsValid() then
                table.insert(data.linked_weapon_prefabs, v.prefab)
                self.pact_weapon_savedatas[v.prefab] = self:WeaponToData(v)
            end
        end
    end

    -- self:UnlinkAllWeapons(true)



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
        -- if data.linked_weapon_prefab ~= nil then
        --     self:SummonWeapon(data.linked_weapon_prefab)
        -- end

        print("Loading data.linked_weapon_prefabs")
        if data.linked_weapon_prefabs ~= nil then
            self.linked_weapon_prefabs_tmp = deepcopy(data.linked_weapon_prefabs)
        end
        dumptable(data.linked_weapon_prefabs)
        dumptable(self.linked_weapon_prefabs_tmp)
    end

    -- print("Icey2SkillSummonPactWeapon:OnLoad() pact_weapon_savedatas = ")
    -- dumptable(self.pact_weapon_savedatas)
end

return Icey2SkillSummonPactWeapon
