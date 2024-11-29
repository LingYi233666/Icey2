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
    if not right and target and target:HasTag("pickable") then
        table.insert(actions, ACTIONS.ICEY2_SCYTHE)
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.ICEY2_SCYTHE, "scythe"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.ICEY2_SCYTHE, "scythe"))
