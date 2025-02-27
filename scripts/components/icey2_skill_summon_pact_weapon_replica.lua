-- ThePlayer.replica.icey2_skill_summon_pact_weapon.pact_weapon_options
local Icey2SkillSummonPactWeapon = Class(function(self, inst)
    self.inst = inst

    self.pact_weapon_options = {}
    self.exists_weapon_prefabs = {}
    self._pact_weapon_options_json = net_string(inst.GUID, "Icey2SkillSummonPactWeapon._pact_weapon_options_json",
        "Icey2SkillSummonPactWeapon._pact_weapon_options_json")
    -- self._linked_weapon = net_entity(inst.GUID, " Icey2SkillSummonPactWeapon._linked_weapon")
    self._exists_weapon_prefabs_json = net_string(inst.GUID, "Icey2SkillSummonPactWeapon._exists_weapon_prefabs_json",
        "Icey2SkillSummonPactWeapon._exists_weapon_prefabs_json")

    if not TheNet:IsDedicated() then
        -- self.speelbook = CreateSpeelBook()
        -- self.inst:AddChild(self.speelbook)

        inst:ListenForEvent("Icey2SkillSummonPactWeapon._pact_weapon_options_json", function()
            self.pact_weapon_options = json.decode(self._pact_weapon_options_json:value())
        end)

        inst:ListenForEvent("Icey2SkillSummonPactWeapon._exists_weapon_prefabs_json", function()
            self.exists_weapon_prefabs = json.decode(self._exists_weapon_prefabs_json:value())
        end)
    end
end)

function Icey2SkillSummonPactWeapon:SetWeaponOptionsJson(json_data)
    self._pact_weapon_options_json:set(json_data)
end

function Icey2SkillSummonPactWeapon:SetExistsWeaponPrefabsJson(json_data)
    self._exists_weapon_prefabs_json:set(json_data)
end

-- function Icey2SkillSummonPactWeapon:SetLinkedWeapon(wp)
--     self._linked_weapon:set(wp)
-- end

function Icey2SkillSummonPactWeapon:CreateWheelItems()
    self.wheel_items = {}

    local manual_sort = {
        "icey2_pact_weapon_rapier",
        "icey2_pact_weapon_scythe",
        "icey2_pact_weapon_gunlance",
        "icey2_pact_weapon_chainsaw",
    }

    local function GetIndex(prefab)
        for k, v in pairs(manual_sort) do
            if v == prefab then
                return k
            end
        end

        return #manual_sort + 1
    end

    local function cmp_fn(p1, p2)
        return GetIndex(p1:lower()) < GetIndex(p2:lower())
    end

    local options = deepcopy(self.pact_weapon_options)
    table.sort(options, cmp_fn)

    if #self.exists_weapon_prefabs > 0 then
        table.insert(options, "remove_all")
    end

    for _, v in pairs(options) do
        local label, execute_fn
        -- if v == "remove_pact_weapon" then
        --     label = STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC.SUMMON_PACT_WEAPON.WHEEL_INFO.REMOVE
        -- else
        --     label = STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC.SUMMON_PACT_WEAPON.WHEEL_INFO.GENERAL ..
        --         (STRINGS.NAMES[v:upper()] or "MISSING_NAME")
        -- end

        local is_remove_select = false
        if v == "remove_all" then
            label = STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC.SUMMON_PACT_WEAPON.WHEEL_INFO.REMOVE_ALL

            execute_fn = function(inst)
                SendModRPCToServer(MOD_RPC["icey2_rpc"]["remove_all_pact_weapon"])
            end
        elseif table.contains(self.exists_weapon_prefabs, v) then
            label = STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC.SUMMON_PACT_WEAPON.WHEEL_INFO.REMOVE ..
                (STRINGS.NAMES[v:upper()] or "MISSING_NAME")

            execute_fn = function(inst)
                SendModRPCToServer(MOD_RPC["icey2_rpc"]["remove_pact_weapon"], v)
            end

            is_remove_select = true
        else
            label = STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC.SUMMON_PACT_WEAPON.WHEEL_INFO.GENERAL ..
                (STRINGS.NAMES[v:upper()] or "MISSING_NAME")

            execute_fn = function(inst)
                SendModRPCToServer(MOD_RPC["icey2_rpc"]["summon_pact_weapon"], v)
            end
        end

        local idle_anim_name = v:lower()
        if is_remove_select then
            idle_anim_name = idle_anim_name .. "_remove"
        end

        table.insert(self.wheel_items, {
            label = label,
            execute = execute_fn,
            bank = "icey2_pact_weapon_wheel",
            build = "icey2_pact_weapon_wheel",
            anims =
            {
                -- idle = { anim = "fire_throw" },
                -- focus = { anim = "fire_throw_focus", loop = true },
                -- down = { anim = "fire_throw_pressed" },

                idle = { anim = idle_anim_name },
            },
            widget_scale = 0.2,
        })
    end
end

function Icey2SkillSummonPactWeapon:ShowPactWeaponsWheel(delay)
    if delay then
        self.inst:DoTaskInTime(delay, function()
            self:ShowPactWeaponsWheel()
        end)
    else
        if ThePlayer.HUD.controls.spellwheel:IsOpen() then
            ThePlayer.HUD.controls.spellwheel:Close()
        else
            self:CreateWheelItems()

            local itemscpy = {}
            for i, v in ipairs(self.wheel_items) do
                itemscpy[i] = shallowcopy(v)
                if v.execute ~= nil then
                    itemscpy[i].execute = function()
                        v.execute(self.inst)
                    end
                    itemscpy[i].onfocus = function()
                        for j, v in ipairs(self.wheel_items) do
                            v.selected = i == j or nil
                        end
                    end
                end
            end
            ThePlayer.HUD.controls.spellwheel:SetScale(TheFrontEnd:GetProportionalHUDScale()) --instead of GetHUDScale(), because parent already has SCALEMODE_PROPORTIONAL
            ThePlayer.HUD.controls.spellwheel:SetItems(itemscpy, 140, 144)
            ThePlayer.HUD.controls.spellwheel:Open()
        end
    end
end

function Icey2SkillSummonPactWeapon:ClosePactWeaponsWheel()
    ThePlayer.HUD.controls.spellwheel:Close()
end

return Icey2SkillSummonPactWeapon
