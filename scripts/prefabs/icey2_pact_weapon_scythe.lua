local assets =
{
    Asset("ANIM", "anim/icey2_pact_weapon_scythe.zip"),
    -- Asset("ANIM", "anim/swap_icey2_pact_weapon_scythe.zip"),
    Asset("ANIM", "anim/swap_lucy_axe.zip"),
    Asset("ANIM", "anim/lavaarena_lucy.zip"),
    Asset("ANIM", "anim/icey2_pact_weapon_scythe_spin.zip"),

    Asset("IMAGE", "images/inventoryimages/icey2_pact_weapon_scythe.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_pact_weapon_scythe.xml"),
}

-- local FX_DEFS =
-- {
--     -- { anim = "swap_loop_1", frame_begin = 0, frame_end = 2 },
--     -- { anim = "swap_loop_3", frame_begin = 2 },
--     -- { anim = "swap_loop_6", frame_begin = 5 },
--     -- { anim = "swap_loop_7", frame_begin = 6 },
--     -- { anim = "swap_loop_8", frame_begin = 7 },


-- }

local FX_DEFS_NORMAL =
{
    { anim = "swap_loop_1", frame_begin = 0, frame_end = 2 },
    { anim = "swap_loop_3", frame_begin = 2 },
    { anim = "swap_loop_6", frame_begin = 5 },
    { anim = "swap_loop_7", frame_begin = 6 },
    { anim = "swap_loop_8", frame_begin = 7 },
}

local FX_DEFS_PARRY =
{
    { anim = "swap_loop_1",   frame_begin = 0 },
    { anim = "swap_loop_6_4", frame_begin = 1 }, --up
    { anim = "swap_loop_3",   frame_begin = 2, frame_end = 4 },
    { anim = "swap_loop_6",   frame_begin = 5 },
    { anim = "swap_loop_7",   frame_begin = 6 },
    { anim = "swap_loop_6",   frame_begin = 7 },                 -- down
    { anim = "swap_loop_8",   frame_begin = 8, frame_end = 11 }, -- side


    -- { anim = "swap_loop_1",  frame_begin = 0 },
    -- { anim = "swap_parry_1", frame_begin = 1 }, --side
    -- { anim = "swap_parry_2", frame_begin = 2 }, --down
    -- { anim = "swap_parry_3", frame_begin = 3 }, --up
    -- { anim = "swap_loop_1",  frame_begin = 5, frame_end = 11 },
}


-- local function DetachSwapAnims(inst)
--     if inst.swapanims then
--         for _, v in pairs(inst.swapanims) do
--             v:Remove()
--         end
--     end

--     inst.swapanims = {}
-- end

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

local function CreateSwapAnims(inst, fx_defines)
    -- DetachSwapAnims(inst)
    inst.swapanims = {}
    for _, data in pairs(fx_defines) do
        local fx = inst:SpawnChild("icey2_pact_weapon_scythe_swapanim")
        fx.AnimState:PlayAnimation(data.anim, true)
        fx:Hide()

        table.insert(inst.swapanims, fx)
    end
end

local function AttachSwapAnims(inst, owner, symbol, fx_defines)
    for k, v in pairs(inst.swapanims) do
        owner:AddChild(v)

        v.components.highlightchild:SetOwner(owner)
        if owner.components.colouradder ~= nil then
            owner.components.colouradder:AttachChild(v)
        end

        if not v.Follower then
            v.entity:AddFollower()
        end

        v:Show()
        v.AnimState:PlayAnimation(fx_defines[k].anim, true)
        v.Follower:FollowSymbol(owner.GUID, symbol, nil, nil, nil, true, nil, fx_defines[k].frame_begin,
            fx_defines[k].frame_end)
    end
end

-- ThePlayer.sg:GoToState("parry_pre") ThePlayer.sg:AddStateTag("parrying") ThePlayer.sg.statemem.parrytime = 99999
local function OnEquip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("swap_object")
    -- owner.AnimState:OverrideSymbol("swap_object", "icey2_pact_weapon_scythe", "swap_scythe")


    AttachSwapAnims(inst, owner, "swap_object", FX_DEFS_NORMAL)

    -- inst._on_owner_state_change = function(_, data)
    --     local statename = data.statename
    --     if owner.sg:HasStateTag("preparrying") or owner.sg:HasStateTag("parrying") then
    --         print("swap to parry anim")
    --         AttachSwapAnims(inst, owner, "swap_object", FX_DEFS_PARRY)
    --     else
    --         AttachSwapAnims(inst, owner, "swap_object", FX_DEFS_NORMAL)
    --     end
    -- end

    -- inst:ListenForEvent("newstate", inst._on_owner_state_change, owner)
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    -- inst:RemoveEventCallback("newstate", inst._on_owner_state_change, owner)
    -- inst._on_owner_state_change = nil

    DetachSwapAnims(inst)
end

local function HarvestPickable(inst, ent, doer)
    if ent.components.pickable.picksound ~= nil then
        doer.SoundEmitter:PlaySound(ent.components.pickable.picksound)
    end

    local level = inst.components.icey2_upgradable:GetLevel()

    if level < 1 then
        local success, loot = ent.components.pickable:Pick(TheWorld)

        if loot ~= nil then
            for i, item in ipairs(loot) do
                Launch(item, doer, 1.5)
            end
        end
    else
        local success, loot = ent.components.pickable:Pick(doer)
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

local function AutoEquipAnotherWeapon(inst, owner)

end


local function ProjectileOnThrown(inst, thrower)
    inst.launch_time = GetTime()

    -- inst.AnimState:PlayAnimation("spin_loop", true)
    -- inst.AnimState:SetPercent("height_controller", 110 / 1000)
    inst.AnimState:SetPercent("height_controller", 0)

    inst.rolling_fx = inst:SpawnChild("icey2_pact_weapon_scythe_rolling")
    inst.tail_vfx = inst:SpawnChild("icey2_scythe_tail_vfx")

    inst.rolling_fx.Transform:SetPosition(0, 1, 0)
    local s = 1.1
    inst.rolling_fx.AnimState:SetScale(s, s, s)

    if not inst.tail_vfx.Follower then
        inst.tail_vfx.entity:AddFollower()
    end
    inst.tail_vfx.Follower:FollowSymbol(inst.GUID, "swap_rolling_fx", 0, -110, 0)

    inst.SoundEmitter:PlaySound("wilson_rework/torch/torch_spin", "spin_loop")

    inst.components.inventoryitem.canbepickedup = false

    inst.attacked_targets = {}

    AutoEquipAnotherWeapon(inst, thrower)


    inst:AddTag("FX")
    inst:AddTag("icey2_pact_weapon_no_regive")
end

local function TryAreaAttack(inst, radius, instancemult, hitfx)
    local victims = {}
    if inst.owner and inst.owner:IsValid() then
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, radius, { "_combat" }, { "INLIMBO", "FX" })

        for _, v in pairs(ents) do
            if not inst.attacked_targets[v]
                and inst.owner.components.combat:CanTarget(v)
                and not inst.owner.components.combat:IsAlly(v) then
                inst.owner.components.combat:DoAttack(v, inst, inst, nil, instancemult, 99999, inst:GetPosition())
                if hitfx and GetTime() - (inst.last_spin_hit_time or 0) > 2 * FRAMES then
                    local height_controller = SpawnAt("icey2_height_controller", v)
                    local fx = height_controller:SpawnChild("icey2_leaf_hitfx")
                    if not fx.Follower then
                        fx.entity:AddFollower()
                    end
                    fx.Follower:FollowSymbol(height_controller.GUID, "swap_rolling_fx", 0, 100, 0)

                    height_controller:ListenForEvent("animover", function()
                        fx:Remove()
                        height_controller:Remove()
                    end, fx)

                    inst.last_spin_hit_time = GetTime()
                end
                table.insert(victims, v)
                inst.attacked_targets[v] = true
            end
        end
    end

    return victims
end

local function ProjectileOnUpdate(inst)
    local dt = FRAMES
    local speed = inst.components.complexprojectile.horizontalSpeed
    inst.Physics:SetMotorVel(speed, 0, 0)

    if GetTime() - inst.launch_time > 0.63 then
        inst.components.complexprojectile:Hit()
        return
    end

    local victims = TryAreaAttack(inst, 2, 0.75, true)

    return true
end

local function ProjectileOnHit(inst)
    if inst.rolling_fx and inst.rolling_fx:IsValid() then
        inst.rolling_fx:Remove()
    end
    inst.rolling_fx = nil

    if inst.tail_vfx and inst.tail_vfx:IsValid() then
        inst.tail_vfx:Remove()
    end
    inst.tail_vfx = nil

    inst.AnimState:PlayAnimation("idle")

    inst.SoundEmitter:KillSound("spin_loop")
    inst.SoundEmitter:PlaySound("wilson_rework/torch/stick_ground")

    inst.components.inventoryitem.canbepickedup = true

    -- Spawn fxs, hit enemies
    inst.attacked_targets = {}
    TryAreaAttack(inst, 1, 1)
    inst.attacked_targets = nil

    SpawnAt("icey2_explode_lunar", inst, { 0.5, 0.5, 0.5 })

    ShakeAllCameras(CAMERASHAKE.VERTICAL, .5, .015, .8, inst, 20)

    -- Bonus area start
    inst.components.icey2_bonus_area:Start(300)


    inst:RemoveTag("FX")
    inst:EnableComplexProjectile(false)
end

local function EnableComplexProjectile(inst, enable)
    if enable and not inst.components.complexprojectile then
        inst:AddComponent("complexprojectile")
        inst.components.complexprojectile:SetOnLaunch(ProjectileOnThrown)
        inst.components.complexprojectile:SetOnUpdate(ProjectileOnUpdate)
        inst.components.complexprojectile:SetOnHit(ProjectileOnHit)
        inst.components.complexprojectile:SetHorizontalSpeed(18)
        inst.components.complexprojectile.ismeleeweapon = true
    elseif not enable and inst.components.complexprojectile then
        inst:RemoveComponent("complexprojectile")
    end
end


local function BonusAreaTest(inst, target)
    return target.components.combat
        and (target == inst.owner
            or (inst.owner and inst.owner.components.combat:IsAlly(target)))
end

local function SpellFn(inst, doer, pos)
    local proj = doer.components.inventory:DropItem(inst, false)
    if proj then
        local x, y, z = doer.Transform:GetWorldPosition()

        inst.owner = doer

        proj.Physics:Stop()
        proj.Transform:SetPosition(x, y, z)

        inst:EnableComplexProjectile(true)
        inst.components.complexprojectile:Launch(pos, doer)

        if Icey2Basic.IsWearingArmor(doer) then
            inst.components.rechargeable:Discharge(10)
        else
            inst.components.rechargeable:Discharge(1)
        end
    end
end

local function OnPickUp(inst)
    inst.components.icey2_bonus_area:Stop()
    inst:RemoveTag("icey2_pact_weapon_no_regive")
end

local function OnBonusAreaStart(inst)
    -- inst.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_activate")
    inst.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_lp", "loop")
end

local function OnBonusAreaStop(inst)
    inst:RemoveTag("icey2_pact_weapon_no_regive")
    if inst.owner
        and inst.owner:IsValid()
        and inst.components.inventoryitem.owner ~= inst.owner
        and inst.owner.components.icey2_skill_summon_pact_weapon then
        inst.owner.components.icey2_skill_summon_pact_weapon:StartRegiveTask(inst)
    end
    -- inst.SoundEmitter:PlaySound("meta2/voidcloth_umbrella/barrier_close")
    inst.SoundEmitter:KillSound("loop")
end

local function ApplyLevelFn(inst, new_level, old_level)
    if new_level >= 1 then
        inst.components.named:SetName(STRINGS.NAMES.ICEY2_PACT_WEAPON_SCYTHE .. "+" .. tostring(new_level))
    else
        inst.components.named:SetName(STRINGS.NAMES.ICEY2_PACT_WEAPON_SCYTHE)
    end

    inst.components.icey2_spdamage_force:SetBaseDamage(1 + new_level * 5)
    if new_level >= 3 then
        inst.components.planardamage:SetBaseDamage(1)
    else
        inst.components.planardamage:SetBaseDamage(0)
    end

    inst.components.icey2_bonus_area.bonus_damage_force = 3 * (new_level + 1)
    inst.components.icey2_bonus_area:CheckToRemove(true)
end

local SKILL_TAB = {
    upgrade_pact_weapon_scythe_1 = 1,
    upgrade_pact_weapon_scythe_2 = 2,
    upgrade_pact_weapon_scythe_3 = 3,
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("icey2_pact_weapon_scythe")
    inst.AnimState:SetBuild("icey2_pact_weapon_scythe")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetLightOverride(0.6)

    inst.AnimState:SetSymbolMultColour("swap_rolling_fx", 0, 0, 0, 0)

    inst:AddTag("icey2_pact_weapon")
    inst:AddTag("special_action_toss")
    inst:AddTag("throw_line")

    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)


    Icey2WeaponSkill.AddAoetargetingClient(inst, "line", nil, 12)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticulelong"
    inst.components.aoetargeting.reticule.pingprefab = "reticulelongping"
    inst.components.aoetargeting:SetAlwaysValid(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.EnableComplexProjectile = EnableComplexProjectile

    CreateSwapAnims(inst, FX_DEFS_NORMAL)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(34)

    inst:AddComponent("icey2_spdamage_force")

    inst:AddComponent("planardamage")

    inst:AddComponent("inspectable")

    inst:AddComponent("named")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "icey2_pact_weapon_scythe"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_pact_weapon_scythe.xml"
    inst.components.inventoryitem.canonlygoinpocket = true

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("icey2_scythe")
    inst.components.icey2_scythe:SetDoScytheFn(DoScythe)

    inst:AddComponent("icey2_bonus_area")
    inst.components.icey2_bonus_area.radius = 6
    inst.components.icey2_bonus_area.circle_prefab = "icey2_circle_mark_iceyblue_6"
    -- inst.components.icey2_bonus_area.circle_prefab = "icey2_pact_weapon_scythe_dome"
    inst.components.icey2_bonus_area.testfn = BonusAreaTest

    -- inst:AddComponent("icey2_aoeweapon_throw_scythe")
    -- inst.components.icey2_aoeweapon_throw_scythe:SetOnHitFn(OnSpellHit)

    inst:AddComponent("icey2_upgradable")
    inst.components.icey2_upgradable:SetApplyFn(ApplyLevelFn)
    inst.components.icey2_upgradable:SetSkillTab(SKILL_TAB)
    inst.components.icey2_upgradable:SetLevel(0)


    Icey2WeaponSkill.AddAoetargetingServer(inst, SpellFn)

    inst:ListenForEvent("onputininventory", OnPickUp)
    inst:ListenForEvent("icey2_bonus_area_start", OnBonusAreaStart)
    inst:ListenForEvent("icey2_bonus_area_stop", OnBonusAreaStop)

    MakeHauntableLaunch(inst)

    return inst
end


local function rollingfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- inst.Transform:SetEightFaced()
    inst.Transform:SetSixFaced()


    -- inst.AnimState:SetBank("icey2_pact_weapon_scythe")
    -- inst.AnimState:SetBuild("icey2_pact_weapon_scythe")
    -- inst.AnimState:PlayAnimation("rolling", true)

    inst.AnimState:SetBank("lavaarena_lucy")
    inst.AnimState:SetBuild("icey2_pact_weapon_scythe_spin")
    inst.AnimState:PlayAnimation("spin_loop", true)

    inst.AnimState:SetLightOverride(0.6)

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

local function height_controllerfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("icey2_pact_weapon_scythe")
    inst.AnimState:SetBuild("icey2_pact_weapon_scythe")
    inst.AnimState:SetPercent("height_controller", 0)

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function DomeUpdateFn(inst, dt)
    if ThePlayer and ThePlayer:IsValid() then
        local dist = math.sqrt(ThePlayer:GetDistanceSqToInst(inst))
        local dist_1 = 15
        local dist_2 = 17

        local c = 1
        if dist < dist_1 then
            c = 1
        elseif dist > dist_2 then
            c = 0
        else
            c = Remap(dist, dist_1, dist_2, 1, 0)
        end

        if inst.t < 1 then
            inst.t = math.min(1, inst.t + dt * 3)
        end
        c = c * inst.t
        inst.AnimState:SetMultColour(c, c, c, c)
    end
end

local function dome_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("umbrella_voidcloth")
    inst.AnimState:SetBuild("umbrella_voidcloth")
    inst.AnimState:PlayAnimation("barrier_dome", true)

    inst.AnimState:SetAddColour(0.8, 1, 1, 1)
    inst.AnimState:SetFinalOffset(7)

    inst.scale = 2.5
    inst.t = 0
    inst.AnimState:SetMultColour(0, 0, 0, 0)
    inst.AnimState:SetScale(inst.scale, inst.scale, inst.scale)

    inst:AddTag("FX")

    if not TheNet:IsDedicated() then
        inst:AddComponent("updatelooper")
        inst.components.updatelooper:AddOnUpdateFn(DomeUpdateFn)

        -- inst:AddComponent("distancefade")
        -- inst.components.distancefade:Setup(10, 15)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    -- inst.KillFX = function(inst)
    --     inst:DoPeriodicTask(0, function()
    --         inst.scale = inst.scale - FRAMES * 5
    --         if inst.scale > 0 then
    --             inst.AnimState:SetScale(inst.scale, inst.scale, inst.scale)
    --         else
    --             inst:Remove()
    --         end
    --     end)
    -- end

    return inst
end



return Prefab("icey2_pact_weapon_scythe", fn, assets),
    Prefab("icey2_pact_weapon_scythe_rolling", rollingfn, assets),
    Prefab("icey2_pact_weapon_scythe_swapanim", swapanimfn, assets),
    Prefab("icey2_height_controller", height_controllerfn, assets),
    Prefab("icey2_pact_weapon_scythe_dome", dome_fn, assets)
