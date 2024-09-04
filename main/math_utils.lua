Icey2Math = {}

function Icey2Math.SumDices(num_dice, dice_max_value, advantage_or_disadvantage)
    local result = 0

    if advantage_or_disadvantage == nil or advantage_or_disadvantage == 0 then
        if type(num_dice) == "number" then
            for i = 1, num_dice do
                result = result + math.random(1, dice_max_value)
            end
        elseif type(num_dice) == "table" then
            for _, v in pairs(num_dice) do
                result = result + Icey2Math.SumDices(v[1], v[2])
            end
        end
    elseif advantage_or_disadvantage > 0 then
        result = math.max(Icey2Math.SumDices(num_dice, dice_max_value),
                          Icey2Math.SumDices(num_dice, dice_max_value))
    elseif advantage_or_disadvantage < 0 then
        result = math.min(Icey2Math.SumDices(num_dice, dice_max_value),
                          Icey2Math.SumDices(num_dice, dice_max_value))
    end

    return result
end

GLOBAL.Icey2Math = Icey2Math
