local function SaveForRerollWrapper(old_fn)
    local function SaveForReroll(inst, ...)
        local data = old_fn(inst, ...)

        if inst.prefab == "icey2" then
            inst.components.icey2_reroll_data_handler:UpdateMemory()
            data.icey2_reroll_data_handler = inst.components.icey2_reroll_data_handler:OnSave()
        else
            data.icey2_reroll_data_handler = inst.components.icey2_reroll_data_handler:OnSave()
        end

        print(inst, "save for reroll !  data.icey2_reroll_data_handler:")
        dumptable(data.icey2_reroll_data_handler)

        return data
    end

    return SaveForReroll
end

local function LoadForRerollWrapper(old_fn)
    local function LoadForReroll(inst, data, ...)
        old_fn(inst, data, ...)

        print(inst, "load for reroll !  data.icey2_reroll_data_handler:")
        dumptable(data.icey2_reroll_data_handler)

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

    return LoadForReroll
end


AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return
    end

    if inst.prefab == "icey2" or inst.prefab == "wonkey" then
        inst:AddComponent("icey2_reroll_data_handler")

        inst.SaveForReroll = SaveForRerollWrapper(inst.SaveForReroll)
        inst.LoadForReroll = LoadForRerollWrapper(inst.LoadForReroll)
    end
end)

AddPrefabPostInit("forest", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("icey2_skull_pile_spawner")
end)

AddPrefabPostInit("chess_junk", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    if inst.components.lootdropper then
        inst.components.lootdropper:AddChanceLoot("icey2_blood_metal", 0.05)
    end
end)


for _, v in pairs({ "knight_nightmare", "bishop_nightmare", "rook_nightmare" }) do
    AddPrefabPostInit(v, function(inst)
        if not TheWorld.ismastersim then
            return inst
        end

        if inst.components.lootdropper then
            inst.components.lootdropper:AddChanceLoot("icey2_blood_metal", 0.01)
        end
    end)
end
