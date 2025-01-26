local assets =
{
    Asset("ANIM", "anim/gravestones.zip"),
}


local LOOTS =
{
    -- nightmarefuel = 1,
    -- amulet = 1,
    -- gears = 1,
    -- redgem = 5,
    -- bluegem = 5,
    trinket_6 = 1,
}

local KNOWS_ICEY1_LOOKUP = {
    icey = true,
    icey2 = true,
}

local PREFAB_NAME_OVERRIDE = "mound"

local function PushMusic(inst)
    local id = inst.GUID
    local sound_index = "icey1_mound_" .. tostring(id)
    local task_index = "kill_" .. sound_index .. "_task"

    if ThePlayer == nil or inst:HasTag("dug") or (TheFocalPoint and TheFocalPoint.SoundEmitter:PlayingSound("danger")) then
        inst._playingmusic = false
    elseif ThePlayer:IsNear(inst, inst._playingmusic and 25 or 20) then
        inst._playingmusic = true
    elseif inst._playingmusic and not ThePlayer:IsNear(inst, 30) then
        inst._playingmusic = false
    end

    if inst._playingmusic then
        if not TheFocalPoint.SoundEmitter:PlayingSound(sound_index) then
            TheFocalPoint.SoundEmitter:PlaySound("icey2_bgm/bgm/icey1_mound", sound_index)
        end

        if TheFocalPoint[task_index] then
            TheFocalPoint[task_index]:Cancel()
        end
        TheFocalPoint[task_index] = TheFocalPoint:DoTaskInTime(5, function()
            if TheFocalPoint.SoundEmitter:PlayingSound(sound_index) then
                TheFocalPoint.SoundEmitter:KillSound(sound_index)
            end
        end)
    end

    if not inst._playingmusic then
        if TheFocalPoint[task_index] then
            TheFocalPoint[task_index]:Cancel()
            TheFocalPoint[task_index] = nil
        end

        if TheFocalPoint.SoundEmitter:PlayingSound(sound_index) then
            TheFocalPoint.SoundEmitter:KillSound(sound_index)
        end
    end
end


local function OnFinishCallback(inst, worker)
    inst:AddTag("dug")
    inst.AnimState:PlayAnimation("dug")
    inst:RemoveComponent("workable")

    if worker ~= nil then
        if worker.components.sanity ~= nil then
            worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
        end

        local item = weighted_random_choice(LOOTS)
        if item ~= nil then
            inst.components.lootdropper:SpawnLootPrefab(item)
        end
    end
end

local function DisplayNameFn(inst)
    if ThePlayer ~= nil and KNOWS_ICEY1_LOOKUP[ThePlayer.prefab] then
        return STRINGS.NAMES[string.upper(inst.prefab)]
    else
        return STRINGS.NAMES[string.upper(PREFAB_NAME_OVERRIDE)]
    end
end


local function DescriptionFn(inst, viewer)
    if viewer.prefab == "icey" or viewer.prefab == "icey2" then
        local dug = (inst.components.workable == nil)
        if dug then
            return STRINGS.CHARACTERS.ICEY2.DESCRIBE.ICEY1_MOUND.DUG
        end

        return STRINGS.CHARACTERS.ICEY2.DESCRIBE.ICEY1_MOUND.GENERIC
    end


    return nil
end

local function GetStatus(inst)
    if not inst.components.workable then
        return "DUG"
    end
end

local function OnSave(inst, data)
    if inst.components.workable == nil then
        data.dug = true
    end
end

local function OnLoad(inst, data)
    if data ~= nil and data.dug or inst.components.workable == nil then
        inst:RemoveComponent("workable")
        inst:AddTag("dug")
        inst.AnimState:PlayAnimation("dug")
    end
end

local function OnHaunt(inst, haunter)
    return true
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("gravestone")
    inst.AnimState:SetBuild("gravestones")
    inst.AnimState:PlayAnimation("gravedirt")

    inst:AddTag("grave")
    inst:AddTag("buried")

    inst.scrapbook_anim = "gravedirt"

    inst:SetPrefabNameOverride(PREFAB_NAME_OVERRIDE)
    inst.displaynamefn = DisplayNameFn


    if not TheNet:IsDedicated() then
        inst._musictask = inst:DoPeriodicTask(1, PushMusic)
        PushMusic(inst)
    end


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.descriptionfn = DescriptionFn
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnFinishCallback)

    inst:AddComponent("lootdropper")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("icey1_mound", fn, assets)
