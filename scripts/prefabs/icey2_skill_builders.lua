local function OnBuiltFn(inst, builder)
    if inst.skill_name
        and Icey2Basic.GetSkillDefine(inst.skill_name)
        and builder.components.icey2_skiller then
        if builder.components.icey2_skiller:IsLearned(inst.skill_name) then

        else
            builder.components.icey2_skiller:Learn(inst.skill_name)
            builder.sg:GoToState("emote", { anim = "emote_swoon" })
            builder.AnimState:SetTime(1)

            SendModRPCToClient(CLIENT_MOD_RPC["icey2_rpc"]["play_skill_learned_anim"], builder.userid, inst.skill_name)
        end
    end

    inst:Remove()
end

local function common_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.OnBuiltFn = OnBuiltFn

    inst:DoTaskInTime(0, inst.Remove)

    return inst
end

local function MakeSkillBuilder(skill_name)
    local prefabname = "icey2_skill_builder_" .. skill_name:lower()
    local assets = {
        Asset("IMAGE", "images/inventoryimages/" .. prefabname .. ".tex"),
        Asset("ATLAS", "images/inventoryimages/" .. prefabname .. ".xml"),
    }

    local function fn()
        local inst = common_fn()

        inst.skill_name = skill_name
        return inst
    end


    return Prefab(prefabname, fn, assets)
end

local bundle = {}

for _, data in pairs(ICEY2_SKILL_DEFINES) do
    if data.Ingredients then
        table.insert(bundle, MakeSkillBuilder(data.Name))
    end
end

return unpack(bundle)
