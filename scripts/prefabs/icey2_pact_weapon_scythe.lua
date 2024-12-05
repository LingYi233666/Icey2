local assets =
{
    Asset("ANIM", "anim/icey2_pact_weapon_scythe.zip"),
    Asset("ANIM", "anim/swap_icey2_pact_weapon_scythe.zip"),

    Asset("IMAGE", "images/inventoryimages/icey2_pact_weapon_scythe.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_pact_weapon_scythe.xml"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_icey2_pact_weapon_scythe", "swap_icey2_pact_weapon_scythe")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    owner.AnimState:SetSymbolLightOverride("swap_object", 0.6)

    inst.components.icey2_bonus_area:Stop()
    inst:RemoveTag("icey2_pact_weapon_no_regive")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    owner.AnimState:SetSymbolLightOverride("swap_object", 0)
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
    inst.rolling_fx:FollowSymbol(inst.GUID, "swap_rolling_fx", 0, 0, 0)

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

    -- inst:AddTag("sharp")

    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)


    -- Icey2WeaponSkill.AddAoetargetingClient(inst, "point", nil, 12)
    -- inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe_1_6"
    -- inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping_1_6"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(17)

    inst:AddComponent("icey2_spdamage_force")
    inst.components.icey2_spdamage_force:SetBaseDamage(17)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "icey2_pact_weapon_scythe"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_pact_weapon_scythe.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

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

local function height_controller_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeProjectilePhysics(inst)

    inst.AnimState:SetBank("icey2_pact_weapon_scythe")
    inst.AnimState:SetBuild("icey2_pact_weapon_scythe")
    -- inst.AnimState:PlayAnimation("controller")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SetHeight = function(inst, height_pixel)
        local max_height_pixel = 1000
        inst.AnimState:SetPercent("controller", height_pixel / max_height_pixel)
    end


    return inst
end

local function rollingfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeProjectilePhysics(inst)

    inst.Transform:SetEightFaced()

    inst.AnimState:SetBank("icey2_pact_weapon_scythe")
    inst.AnimState:SetBuild("icey2_pact_weapon_scythe")
    inst.AnimState:PlayAnimation("rolling", true)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst.persists = false

    return inst
end

return Prefab("icey2_pact_weapon_scythe", fn, assets),
    -- Prefab("icey2_pact_weapon_scythe_height_controller", height_controller_fn, assets)
    Prefab("icey2_pact_weapon_scythe_rolling", rollingfn, assets)
