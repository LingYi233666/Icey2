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

function Icey2Basic.IsCarryingGunlance(inst, is_ranged)
    local hand_inv = nil

    if inst.components.inventory then
        hand_inv = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    elseif inst.replica.inventory then
        hand_inv = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    end

    if is_ranged == nil then
        return hand_inv
            and hand_inv.prefab == "icey2_pact_weapon_gunlance"
    end

    if is_ranged == true then
        return hand_inv
            and hand_inv.prefab == "icey2_pact_weapon_gunlance"
            and hand_inv:HasTag("icey2_pact_weapon_gunlance_ranged")
    end



    return hand_inv
        and hand_inv.prefab == "icey2_pact_weapon_gunlance"
        and not hand_inv:HasTag("icey2_pact_weapon_gunlance_ranged")
end

function Icey2Basic.GetFaceVector(inst)
    local angle = (inst.Transform:GetRotation() + 90) * DEGREES
    local sinangle = math.sin(angle)
    local cosangle = math.cos(angle)

    return Vector3(sinangle, 0, cosangle)
end

function Icey2Basic.GetFaceAngle(inst, target)
    local myangle = inst:GetRotation()
    local faceguyangle = inst:GetAngleToPoint(target:GetPosition():Get())
    local deltaangle = math.abs(myangle - faceguyangle)
    if deltaangle > 180 then
        deltaangle = 360 - deltaangle
    end

    return deltaangle
end

GLOBAL.Icey2Basic = Icey2Basic
