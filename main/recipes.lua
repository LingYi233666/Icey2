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


---------------- Add skill builder recipes --------------------

for skill_name, data in pairs(ICEY2_SKILL_DEFINES) do
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

                    return true
                end,
                nounlock = true,
            },
            { "CHARACTER", }
        )
    end
end

---------------------------------------------------------------
