Icey2Math = {}

function Icey2Math.SumDices(num_dice, dice_max_value)
    local result = 0

    if type(num_dice) == "number" then
        for i = 1, num_dice do
            result = result + math.random(1, dice_max_value)
        end
    elseif type(num_dice) == "table" then
        for _, v in pairs(num_dice) do
            result = result + Icey2Math.SumDices(v[1], v[2])
        end
    end

    return result
end

GLOBAL.Icey2Math = Icey2Math
