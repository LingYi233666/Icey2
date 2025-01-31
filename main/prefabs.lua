local function GaleSaveForRerollWrapper(old_fn)
    local function GaleSaveForReroll(inst, ...)
        local data = old_fn(inst, ...)

        if inst.prefab == "icey2" then
            inst.components.icey2_reroll_data_handler:UpdateMemory()
            data.icey2_reroll_data_handler = inst.components.icey2_reroll_data_handler:OnSave()
        else
            data.icey2_reroll_data_handler = inst.components.icey2_reroll_data_handler:OnSave()
        end

        return data
    end

    return GaleSaveForReroll
end

local function GaleLoadForRerollWrapper(old_fn)
    local function GaleLoadForReroll(inst, data, ...)
        old_fn(inst, data, ...)

        if inst.prefab == "icey2" then
            if data.icey2_reroll_data_handler ~= nil then
                inst.components.icey2_reroll_data_handler:OnLoad(data.icey2_reroll_data_handler)
                inst.components.icey2_reroll_data_handler:ApplyMemory()
            end
        else
            if data.icey2_reroll_data_handler ~= nil then
                inst.components.icey2_reroll_data_handler:OnLoad(data.icey2_reroll_data_handler)
            end
        end
    end

    return GaleLoadForReroll
end


AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return
    end

    if inst.prefab == "icey2" or inst.prefab == "wonkey" then
        inst:AddComponent("icey2_reroll_data_handler")

        inst.SaveForReroll = GaleSaveForRerollWrapper(inst.SaveForReroll)
        inst.LoadForReroll = GaleLoadForRerollWrapper(inst.LoadForReroll)
    end
end)

AddPrefabPostInit("forest", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("icey2_skull_pile_spawner")
end)
