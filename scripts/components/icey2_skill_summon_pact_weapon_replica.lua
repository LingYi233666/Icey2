-- local function CreateSpeelBook()
--     local inst = CreateEntity()

--     inst.entity:AddTransform()

--     inst:AddTag("NOCLICK")
--     inst:AddTag("INLIMBO")
--     inst:AddTag("classified")


--     inst:AddComponent("spellbook")
--     inst.components.spellbook:SetRequiredTag("icey2")
--     inst.components.spellbook:SetRadius(100)
--     inst.components.spellbook:SetFocusRadius(102) --UIAnimButton don't use focus radius SPELLBOOK_FOCUS_RADIUS)

--     return inst
-- end

-- ThePlayer.replica.icey2_skill_summon_pact_weapon.pact_weapon_options
local Icey2SkillSummonPactWeapon = Class(function(self, inst)
    self.inst = inst

    self.pact_weapon_options = {}

    self._pact_weapon_options_json = net_string(inst.GUID, "Icey2SkillSummonPactWeapon._pact_weapon_options_json",
        "Icey2SkillSummonPactWeapon._pact_weapon_options_json")
    self._linked_weapon = net_entity(inst.GUID, " Icey2SkillSummonPactWeapon._linked_weapon")

    if not TheNet:IsDedicated() then
        -- self.speelbook = CreateSpeelBook()
        -- self.inst:AddChild(self.speelbook)

        inst:ListenForEvent("Icey2SkillSummonPactWeapon._pact_weapon_options_json", function()
            self.pact_weapon_options = json.decode(self._pact_weapon_options_json:value())
        end)
    end
end)

function Icey2SkillSummonPactWeapon:SetWeaponOptionsJson(json_data)
    self._pact_weapon_options_json:set(json_data)
end

function Icey2SkillSummonPactWeapon:SetLinkedWeapon(wp)
    self._linked_weapon:set(wp)
end

function Icey2SkillSummonPactWeapon:CreateWheelItems()
    self.wheel_items = {}

    local options = deepcopy(self.pact_weapon_options)
    if self._linked_weapon:value() ~= nil then
        table.insert(options, "remove_pact_weapon")
    end

    for _, v in pairs(options) do
        local label
        if v == "remove_pact_weapon" then
            label = STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC.SUMMON_PACT_WEAPON.WHEEL_INFO.REMOVE
        else
            label = STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC.SUMMON_PACT_WEAPON.WHEEL_INFO.GENERAL ..
                (STRINGS.NAMES[v:upper()] or "MISSING_NAME")
        end

        table.insert(self.wheel_items, {
            label = label,
            onselect = function(inst)
                -- print("onselect", inst, v)
            end,
            execute = function(inst)
                -- print("execute", inst, v)
                if v == "remove_pact_weapon" then
                    SendModRPCToServer(MOD_RPC["icey2_rpc"]["remove_pact_weapon"])
                else
                    SendModRPCToServer(MOD_RPC["icey2_rpc"]["summon_pact_weapon"], v)
                end
            end,
            bank = "spell_icons_willow",
            build = "spell_icons_willow",
            anims =
            {
                idle = { anim = "fire_throw" },
                focus = { anim = "fire_throw_focus", loop = true },
                down = { anim = "fire_throw_pressed" },
            },
            widget_scale = 0.6,
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
            ThePlayer.HUD.controls.spellwheel:SetItems(itemscpy, 100, 102)
            ThePlayer.HUD.controls.spellwheel:Open()
        end
    end
end

function Icey2SkillSummonPactWeapon:ClosePactWeaponsWheel()
    ThePlayer.HUD.controls.spellwheel:Close()
end

return Icey2SkillSummonPactWeapon
