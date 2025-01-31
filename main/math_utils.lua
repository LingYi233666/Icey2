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

function Icey2Math.RadiansBetweenVectors(v1, v2)
    local result = math.atan2(v1:Cross(v2):Length(), v1:Dot(v2))
    return result
end

-- NOTE: DST coordinates is Front-X, Left-Z, Up-Y
-- Params:
--  theta: radiance between y-axis and direction
--  phi:  radiance between x-axis and direction
function Icey2Math.CustomSphereEmitter(radius_min, radius_max, theta_min, theta_max, phi_min, phi_max)
    local function fn()
        local radius = GetRandomMinMax(radius_min, radius_max)
        local theta = GetRandomMinMax(theta_min, theta_max)
        local phi = GetRandomMinMax(phi_min, phi_max)

        return radius * math.sin(theta) * math.cos(phi),
            radius * math.cos(theta),
            radius * math.sin(theta) * math.sin(phi)
    end

    return fn
end

function Icey2Math.GetVoxelCellIndex(point, voxel_size)
    local x = math.floor(point.x / voxel_size)
    local y = math.floor(point.y / voxel_size)
    local z = math.floor(point.z / voxel_size)
    return bit.lshift(x, 42) + bit.lshift(y, 21) + z
end

GLOBAL.Icey2Math = Icey2Math
