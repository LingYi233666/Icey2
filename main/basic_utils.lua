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

GLOBAL.Icey2Basic = Icey2Basic
