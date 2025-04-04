local function GetNum(params, ...)
    local result = 0

    for _, val in pairs({ ... }) do
        if type(val) == "string" then
            result = result + (params[val] or 0)
        elseif type(val) == "table" then
            for _, v in pairs(val) do
                result = result + (params[v] or 0)
            end
        end
    end

    return result
end

-- For foods can't be cooked,but can get by other ways
local function CantCookTestFn()
    return false
end

local function CookTime(t)
    -- Quick cook debug
    -- return 2 * FRAMES / 20.0

    return t / 20.0
end


-- 1 cooktime = 20 seconds
-- oneat_desc = STRINGS.UI.COOKBOOK.FOOD_EFFECTS_SWAP_HEALTH_AND_SANITY,
-- potlevel = "low",
-- unlock = {"meat","meat","snake_bone","snake_bone"},
local foods = {

}

for k, v in pairs(foods) do
    v.name = k
    v.weight = v.weight or 1
    v.priority = v.priority or 0
    v.test = v.test or CantCookTestFn

    v.overridebuild = "icey2_ckptfoods"
    -- v.cookbook_atlas = "images/inventoryimages/"..k..".xml"
    v.cookbook_atlas = "images/ui/cookbook_images/" .. k .. ".xml"
end

return foods
