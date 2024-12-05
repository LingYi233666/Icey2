local assets =
{
    Asset("ANIM", "anim/icey2_pact_weapon_scythe.zip"),
    -- Asset("ANIM", "anim/swap_icey2_pact_weapon_scythe.zip"),

    Asset("IMAGE", "images/inventoryimages/icey2_pact_weapon_scythe.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_pact_weapon_scythe.xml"),
}

local FX_DEFS =
{
    { anim = "swap_loop_1", frame_begin = 0, frame_end = 2 },
    { anim = "swap_loop_3", frame_begin = 2 },
    { anim = "swap_loop_6", frame_begin = 5 },
    { anim = "swap_loop_7", frame_begin = 6 },
    { anim = "swap_loop_8", frame_begin = 7 },
}

local function CreateSwapAnims(inst)
    inst.swapanims = {}

    -- local indexes = { 1, 3, 6, 7, 8 }
    -- for _, index in pairs(indexes) do
    --     inst.swapanims[index] = inst:SpawnChild("icey2_pact_weapon_scythe_swapanim_" .. index)
    --     inst.swapanims[index]:Hide()
    -- end


    for _, data in pairs(FX_DEFS) do
        local fx = inst:SpawnChild("icey2_pact_weapon_scythe_swapanim")
        fx.AnimState:PlayAnimation(data.anim, true)
        fx:Hide()

        table.insert(inst.swapanims, fx)
    end
end

local function AttachSwapAnims(inst, owner)
    for k, v in pairs(inst.swapanims) do
        owner:AddChild(v)

        v.components.highlightchild:SetOwner(owner)
        if owner.components.colouradder ~= nil then
            owner.components.colouradder:AttachChild(v)
        end

        if not v.Follower then
            v.entity:AddFollower()
        end

        v.Follower:FollowSymbol(owner.GUID, "swap_object", nil, nil, nil, true, nil, FX_DEFS[k].frame_begin,
            FX_DEFS[k].frame_end)

        v:Show()
    end
end

local function DetachSwapAnims(inst, old_owner)
    for _, v in pairs(inst.swapanims) do
        v.Follower:StopFollowing()

        inst:AddChild(v)

        v.components.highlightchild:SetOwner(nil)
        if old_owner and old_owner.components.colouradder ~= nil then
            old_owner.components.colouradder:DetachChild(v)
        end

        v:Hide()
    end
end

local function OnEquip(inst, owner)
    -- owner.AnimState:OverrideSymbol("swap_object", "swap_icey2_pact_weapon_scythe", "swap_icey2_pact_weapon_scythe")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("swap_object")

    AttachSwapAnims(inst, owner)

    inst.components.icey2_bonus_area:Stop()
    inst:RemoveTag("icey2_pact_weapon_no_regive")
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    DetachSwapAnims(inst, owner)
end

local function HarvestPickable(inst, ent, doer)
    if ent.components.pickable.picksound ~= nil then
        doer.SoundEmitter:PlaySound(ent.components.pickable.picksound)
    end

    local success, loot = ent.components.pickable:Pick(TheWorld)

    if loot ~= nil then
        for i, item in ipairs(loot) do
            Launch(item, doer, 1.5)
        end
    end
end

local function IsEntityInFront(inst, entity, doer_rotation, doer_pos)
    local facing = Vector3(math.cos(-doer_rotation / RADIANS), 0, math.sin(-doer_rotation / RADIANS))

    return IsWithinAngle(doer_pos, facing, 165 * DEGREES, entity:GetPosition())
end

local function DoScythe(inst, doer, target)
    local doer_pos = doer:GetPosition()
    local x, y, z = doer_pos:Get()

    local doer_rotation = doer.Transform:GetRotation()

    local ents = TheSim:FindEntities(x, y, z, 4, { "pickable" }, { "INLIMBO", "FX" },
        { "plant", "lichen", "oceanvine", "kelp" })

    for _, ent in pairs(ents) do
        if ent:IsValid()
            and ent.components.pickable ~= nil
            and IsEntityInFront(inst, ent, doer_rotation, doer_pos) then
            HarvestPickable(inst, ent, doer)
        end
    end

    return true
end

local function ProjectileOnThrown(inst, thrower)
    inst.launch_time = GetTime()

    -- inst.AnimState:PlayAnimation("spin_loop", true)
    inst.AnimState:SetPercent("height_controller", 200 / 1000)

    inst.rolling_fx = inst:SpawnChild("icey2_pact_weapon_scythe_rolling")
    if not inst.rolling_fx.Follower then
        inst.rolling_fx.entity:AddFollower()
    end
    inst.rolling_fx.Follower:FollowSymbol(inst.GUID, "swap_rolling_fx", 0, 0, 0)

    inst.SoundEmitter:PlaySound("wilson_rework/torch/torch_spin", "spin_loop")

    inst.components.inventoryitem.canbepickedup = false


    inst:AddTag("FX")
    inst:AddTag("icey2_pact_weapon_no_regive")
end

local function ProjectileOnUpdate(inst)
    local dt = FRAMES
    local speed = inst.components.complexprojectile.horizontalSpeed
    inst.Physics:SetMotorVel(speed, 0, 0)

    if GetTime() - inst.launch_time > 1 then
        inst.components.complexprojectile:Hit()
        return
    end

    -- TODO: Hit enemies
end

local function ProjectileOnHit(inst)
    if inst.rolling_fx and inst.rolling_fx:IsValid() then
        inst.rolling_fx:Remove()
    end
    inst.rolling_fx = nil

    inst.AnimState:PlayAnimation("idle")

    inst.SoundEmitter:KillSound("spin_loop")
    inst.SoundEmitter:PlaySound("wilson_rework/torch/stick_ground")

    inst.components.inventoryitem.canbepickedup = true

    -- TODO: Spawn fxs, hit enemies
    SpawnAt("explode_small", inst)

    -- Bonus area start
    inst.components.icey2_bonus_area:Start(10)

    inst:RemoveTag("FX")
end

local function BonusAreaTest(inst, target)
    return target.components.combat
        and target == inst.owner
end



local function OnSpellHit(inst, doer, target)

end

local function SpellFn(inst, doer, pos)

end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("icey2_pact_weapon_scythe")
    inst.AnimState:SetBuild("icey2_pact_weapon_scythe")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("special_action_toss")

    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)


    -- Icey2WeaponSkill.AddAoetargetingClient(inst, "point", nil, 12)
    -- inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe_1_6"
    -- inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping_1_6"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    CreateSwapAnims(inst)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(34)

    inst:AddComponent("icey2_spdamage_force")
    inst.components.icey2_spdamage_force:SetBaseDamage(17)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "icey2_pact_weapon_scythe"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_pact_weapon_scythe.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("icey2_scythe")
    inst.components.icey2_scythe:SetDoScytheFn(DoScythe)

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetOnLaunch(ProjectileOnThrown)
    inst.components.complexprojectile:SetOnUpdate(ProjectileOnUpdate)
    inst.components.complexprojectile:SetOnHit(ProjectileOnHit)
    inst.components.complexprojectile.ismeleeweapon = true

    inst:AddComponent("icey2_bonus_area")
    inst.components.icey2_bonus_area.radius = 6
    inst.components.icey2_bonus_area.circle_prefab = "icey2_circle_mark_iceyblue_6"
    inst.components.icey2_bonus_area.testfn = BonusAreaTest

    -- inst:AddComponent("icey2_aoeweapon_flurry_lunge")
    -- inst.components.icey2_aoeweapon_flurry_lunge:SetOnHitFn(OnSpellHit)


    -- Icey2WeaponSkill.AddAoetargetingServer(inst, SpellFn)

    MakeHauntableLaunch(inst)

    return inst
end


local function rollingfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetEightFaced()

    inst.AnimState:SetBank("icey2_pact_weapon_scythe")
    inst.AnimState:SetBuild("icey2_pact_weapon_scythe")
    inst.AnimState:PlayAnimation("rolling", true)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function swapanimfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("icey2_pact_weapon_scythe")
    inst.AnimState:SetBuild("icey2_pact_weapon_scythe")

    inst.AnimState:SetLightOverride(0.6)

    inst:AddComponent("highlightchild")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("colouradder")

    inst.persists = false

    return inst
end



return Prefab("icey2_pact_weapon_scythe", fn, assets),
    Prefab("icey2_pact_weapon_scythe_rolling", rollingfn, assets),
    Prefab("icey2_pact_weapon_scythe_swapanim", swapanimfn, assets)
