local function Icey2ModAddRecipe2(name, ingredients, tech, config, filters, ...)
    -- For quick search build image
    if config then
        if config.atlas == nil and config.image == nil then
            config.image = name .. ".tex"
            config.atlas = "images/inventoryimages/" .. name .. ".xml"
        end
    end

    return AddRecipe2(name, ingredients, tech, config, filters, ...)
end

local function AddRecipeWithManyIngredients(name, list_ingredients, tech, config, filters, ...)
    if not config then
        config = {}
    end

    config.product = name
    if config.atlas == nil and config.image == nil then
        config.image = name .. ".tex"
        config.atlas = "images/inventoryimages/" .. name .. ".xml"
    end

    for k, ingredients in pairs(list_ingredients) do
        Icey2ModAddRecipe2(
            name .. "_plan" .. k,
            ingredients,
            tech,
            config,
            filters,
            ...
        )
    end
end

---------------- Modify CHARACTER_INGREDIENT ----------------
-- seems no need for this code, because we can handle it in hack of "IsCharacterIngredient"
-- for _, data in pairs(ICEY2_SKILL_DEFINES) do
--     local name = data.Name
--     GLOBAL.CHARACTER_INGREDIENT[name] = name
-- end

local is_icey2_skill_ingredient = nil
function IsIcey2SkillIngredient(ingredienttype)
    if is_icey2_skill_ingredient == nil then
        is_icey2_skill_ingredient = {}
        for _, data in pairs(ICEY2_SKILL_DEFINES) do
            local name = "icey2_skill_builder_" .. data.Name
            is_icey2_skill_ingredient[name] = true
        end
    end

    return ingredienttype ~= nil and is_icey2_skill_ingredient[ingredienttype]
end

GLOBAL.IsIcey2SkillIngredient = IsIcey2SkillIngredient

local old_IsCharacterIngredient = GLOBAL.IsCharacterIngredient
function GLOBAL.IsCharacterIngredient(ingredienttype)
    return IsIcey2SkillIngredient(ingredienttype) or old_IsCharacterIngredient(ingredienttype)
end

-------------------------------------------------------------

-- Icey2ModAddRecipe2(
--     "icey2_blood_metal",
--     {
--         Ingredient(CHARACTER_INGREDIENT.HEALTH, 245),
--         Ingredient("transistor", 2),
--         Ingredient("gears", 1),
--     },
--     TECH.NONE,
--     {
--         builder_tag = "icey2"
--     },
--     { "CHARACTER", }
-- )

AddRecipeWithManyIngredients(
    "icey2_energy_tank",
    {
        { Ingredient("slurtle_shellpieces", 6), Ingredient("transistor", 2), Ingredient("gears", 1), },
        { Ingredient("cookiecuttershell", 4),   Ingredient("transistor", 2), Ingredient("gears", 1), },
        { Ingredient("bluegem", 1),             Ingredient("transistor", 2), },
        { Ingredient("dragon_scales", 1),       Ingredient("transistor", 1), },
        { Ingredient("dreadstone", 1),          Ingredient("transistor", 2), },
    },
    TECH.NONE,
    {
        builder_tag = "icey2",
    },
    { "CHARACTER", }
)


---------------- Dodge charge upgrade ----------------

local dodge_charge_upgrade_chips_recipe = {
    { Ingredient("wintersfeastfuel", 3),    Ingredient("crumbs", 12),   Ingredient("gears", 1),        Ingredient("wagpunk_bits", 3), },
    { Ingredient("rabbitkingspear", 1),     Ingredient("gears", 1),     Ingredient("wagpunk_bits", 3), },
    { Ingredient("goose_feather", 8),       Ingredient("gears", 1),     Ingredient("wagpunk_bits", 3), },
    { Ingredient("townportaltalisman", 12), Ingredient("gears", 1),     Ingredient("wagpunk_bits", 3), },
    { Ingredient("walrus_tusk", 2),         Ingredient("gears", 1),     Ingredient("wagpunk_bits", 3), },
    { Ingredient("feather_crow", 8),        Ingredient("boneshard", 6), Ingredient("gears", 1),        Ingredient("wagpunk_bits", 3), },
}

for i, recipe in pairs(dodge_charge_upgrade_chips_recipe) do
    local builder_tag = "icey2_dodge_charge_chip_" .. i .. "_builder"
    Icey2ModAddRecipe2(
        "icey2_dodge_charge_chip_" .. i,
        recipe,
        TECH.NONE,
        {
            builder_tag = builder_tag,
            image = "wx78module_movespeed2.tex",
            sg_state = "applyupgrademodule",
            canbuild = function(inst, builder)
                if not builder:HasTag(builder_tag) then
                    return false, "DODGE_CHARGE_CHIP_ONLY_ONCE"
                end

                if not builder.components.icey2_skill_dodge then
                    return false, nil
                end

                if builder.components.icey2_skill_dodge.max_dodge_charge >= 4 then
                    return false, "MAX_DODGE_CHARGE"
                end

                return true
            end,
        },
        { "CHARACTER", }
    )
end

---------------- Add skill builder recipes --------------------

for _, data in pairs(ICEY2_SKILL_DEFINES) do
    local skill_name = data.Name
    if data.Ingredients then
        Icey2ModAddRecipe2(
            "icey2_skill_builder_" .. skill_name:lower(),
            data.Ingredients,
            data.Tech or TECH.NONE,
            {
                builder_tag = "icey2",
                canbuild = function(inst, builder)
                    if not builder.components.icey2_skiller then
                        return false, nil
                    end

                    if builder.components.icey2_skiller:IsLearned(skill_name) then
                        return false, "SKILL_ALREADY_LEARNED"
                    end

                    -- if data.RequiredSkills then
                    --     for _, v in pairs(data.RequiredSkills) do
                    --         if not builder.components.icey2_skiller:IsLearned(v) then
                    --             return false, "PRE_SKILL_REQUIRED"
                    --         end
                    --     end
                    -- end

                    return true
                end,
                nounlock = true,
            },
            { "CHARACTER", }
        )
    end
end

---------------------------------------------------------------
