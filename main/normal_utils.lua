Icey2Normal = {}

function Icey2Normal.IsWearingArmor(inst)
    for k, v in pairs(inst.components.inventory.equipslots) do
        if v.components.armor ~= nil and
            not v:HasTag("ignore_icey2_unarmoured_defence_limit") then
            return true
        end
    end

    return false
end

GLOBAL.Icey2Normal = Icey2Normal
