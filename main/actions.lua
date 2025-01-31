AddAction("ICEY2_SCYTHE", "ICEY2_SCYTHE", function(act)
    if act.invobject ~= nil and act.invobject.components.icey2_scythe then
        -- Should I consider my pact weapon is a mimic ?
        -- if act.invobject.components.itemmimic and act.invobject.components.itemmimic.fail_as_invobject then
        --     return false, "ITEMMIMIC"
        -- end
        local success = act.invobject.components.icey2_scythe:DoScythe(act.doer, act.target)
        return success
    end

    return false
end)
-- ACTIONS.ICEY2_SCYTHE.priority = 0
ACTIONS.ICEY2_SCYTHE.rmb = false

AddComponentAction("EQUIPPED", "icey2_scythe", function(inst, doer, target, actions, right)
    local cant_scythe_tags = { "plant", "lichen", "oceanvine", "kelp" }
    if not right and target and target:HasTag("pickable") and target:HasOneOfTags(cant_scythe_tags) then
        table.insert(actions, ACTIONS.ICEY2_SCYTHE)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.ICEY2_SCYTHE, "scythe"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.ICEY2_SCYTHE, "scythe"))



AddAction("ICEY2_VERSATILE_WEAPON_CHANGE_FORM", "ICEY2_VERSATILE_WEAPON_CHANGE_FORM", function(act)
    if act.invobject ~= nil and act.invobject.components.icey2_versatile_weapon then
        act.invobject.components.icey2_versatile_weapon:SwitchForm()
        return true
    end

    return false
end)
ACTIONS.ICEY2_VERSATILE_WEAPON_CHANGE_FORM.rmb = true
ACTIONS.ICEY2_VERSATILE_WEAPON_CHANGE_FORM.do_not_locomote = true
ACTIONS.ICEY2_VERSATILE_WEAPON_CHANGE_FORM.customarrivecheck = function() return true end
ACTIONS.ICEY2_VERSATILE_WEAPON_CHANGE_FORM.stroverridefn = function(act)
    local item = act.invobject
    if item == nil or STRINGS.ACTIONS.ICEY2_VERSATILE_WEAPON_CHANGE_FORM[item.prefab:upper()] == nil then
        return STRINGS.ACTIONS.ICEY2_VERSATILE_WEAPON_CHANGE_FORM.GENERIC
    end

    local cur_form = act.invobject.replica.icey2_versatile_weapon:GetCurForm()
    if STRINGS.ACTIONS.ICEY2_VERSATILE_WEAPON_CHANGE_FORM[item.prefab:upper()][cur_form] == nil then
        return STRINGS.ACTIONS.ICEY2_VERSATILE_WEAPON_CHANGE_FORM.GENERIC
    end

    return STRINGS.ACTIONS.ICEY2_VERSATILE_WEAPON_CHANGE_FORM[item.prefab:upper()][cur_form]
end

AddComponentAction("POINT", "icey2_versatile_weapon", function(inst, doer, pos, actions, right, target)
    if right and doer:HasTag("player") then
        table.insert(actions, ACTIONS.ICEY2_VERSATILE_WEAPON_CHANGE_FORM)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.ICEY2_VERSATILE_WEAPON_CHANGE_FORM, "domediumaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.ICEY2_VERSATILE_WEAPON_CHANGE_FORM, "domediumaction"))



AddAction("ICEY2_UPGRADE_SHIELD", "ICEY2_UPGRADE_SHIELD", function(act)
    if act.invobject ~= nil and act.invobject.components.icey2_shield_upgrader then
        return act.invobject.components.icey2_shield_upgrader:Use(act.target or act.doer, act.doer)
    end

    return false
end)

AddComponentAction("INVENTORY", "icey2_shield_upgrader", function(inst, doer, actions, right)
    if doer and doer:HasTag("player") and doer:HasTag("icey2") then
        table.insert(actions, ACTIONS.ICEY2_UPGRADE_SHIELD)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.ICEY2_UPGRADE_SHIELD, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.ICEY2_UPGRADE_SHIELD, "dolongaction"))
