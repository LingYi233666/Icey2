Icey2Basic = {}

function Icey2Basic.IsWearingArmor(inst)
    for k, v in pairs(inst.components.inventory.equipslots) do
        if v.components.armor ~= nil and
            not v:HasTag("ignore_icey2_unarmoured_defence_limit") then
            return true
        end
    end

    return false
end

function Icey2Basic.GetUnarmouredMovementAnim(inst, state)
    local hands = nil

    if inst.components.inventory then
        hands = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    elseif inst.replica.inventory then
        hands = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    end


    if state == "pre" then
        if hands then
            return "icey2_speedrun_withitem_pre"
        else
            return "icey2_speedrun_pre"
        end
    elseif state == "loop" then
        if hands then
            return "icey2_speedrun_withitem_loop"
        else
            return "icey2_speedrun_loop"
        end
    elseif state == "pst" then
        if hands then
            return "icey2_speedrun_withitem_pst"
        else
            return "icey2_speedrun_pst"
        end
    end
end

GLOBAL.Icey2Basic = Icey2Basic