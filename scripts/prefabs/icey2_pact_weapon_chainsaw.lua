local assets =
{
    Asset("ANIM", "anim/icey2_pact_weapon_chainsaw.zip"),
    Asset("IMAGE", "images/inventoryimages/icey2_pact_weapon_chainsaw.tex"),
    Asset("ATLAS", "images/inventoryimages/icey2_pact_weapon_chainsaw.xml"),
}

local FX_DEFS_NORMAL =
{
    { anim = "swap_loop", speed = 2 },
}

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
    inst.swapanims = {}
    for _, data in pairs(fx_defines) do
        local fx = inst:SpawnChild("icey2_pact_weapon_chainsaw_swapanim")

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
        if fx_defines[k].speed then
            v.AnimState:SetDeltaTimeMultiplier(fx_defines[k].speed)
        end
        v.Follower:FollowSymbol(owner.GUID, symbol, nil, nil, nil, true, nil, fx_defines[k].frame_begin,
            fx_defines[k].frame_end)
    end
end


local function OnEquip(inst, owner)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("swap_object")
    AttachSwapAnims(inst, owner, "swap_object", FX_DEFS_NORMAL)

    if owner.components.combat then
        if inst.components.icey2_aoeweapon_launch_chainsaw:GetProjectile() then
            owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
        else
            owner.components.combat:SetAttackPeriod(17 * FRAMES)
        end
    end

    inst._attacked_callback = function(_, data)
        if inst.components.icey2_aoeweapon_launch_chainsaw:GetProjectile() then
            local rand_value = math.random()

            local level      = inst.components.icey2_upgradable:GetLevel()
            if level >= 3 then
                rand_value = math.max(rand_value, math.random())
            end

            if Icey2Basic.IsWearingArmor(owner) or math.max(0.5, data.damage / 100) > rand_value then
                inst.components.icey2_aoeweapon_launch_chainsaw:Return()
                inst.components.rechargeable:Discharge(1)
            end
        end
    end

    inst:ListenForEvent("attacked", inst._attacked_callback, owner)
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    DetachSwapAnims(inst)
    -- inst.components.icey2_aoeweapon_launch_chainsaw:Return()

    if owner.components.combat then
        owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
    end

    inst:RemoveEventCallback("attacked", inst._attacked_callback, owner)
    inst._attacked_callback = nil
end


local function OnAttackMelee(inst, attacker, target)
    -- if attacker.sg and attacker.sg.statemem and attacker.sg.statemem.emit_fx then
    --     local start_pos = target:GetPosition()
    --     start_pos.y = start_pos.y + GetRandomMinMax(0.8, 2)

    --     local fx = SpawnAt("icey2_chainsaw_hit_fx", start_pos)
    --     fx:FaceAwayFromPoint(attacker:GetPosition(), true)

    --     -- attacker.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_chainsaw/hit")
    -- end

    if attacker.sg and attacker.sg.statemem then
        if attacker.sg.statemem.emit_fx then
            local start_pos = target:GetPosition()
            start_pos.y = start_pos.y + GetRandomMinMax(0.8, 2)

            local fx = SpawnAt("icey2_chainsaw_hit_fx", start_pos)
            fx:FaceAwayFromPoint(attacker:GetPosition(), true)

            if attacker.sg.statemem.hide_anim then
                fx.AnimState:SetMultColour(0, 0, 0, 0)
            end
        end
    end
end

local function SpellFn(inst, doer, pos)
    if inst.components.icey2_aoeweapon_launch_chainsaw:GetProjectile() then
        inst.components.icey2_aoeweapon_launch_chainsaw:Return()
    else
        local consume_hunger = 10
        if doer.components.hunger.current > consume_hunger then
            inst.components.icey2_aoeweapon_launch_chainsaw:Launch(pos, doer)
            doer.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_chainsaw/launch")

            doer.components.hunger:DoDelta(-consume_hunger, true)
        end
    end

    inst.components.rechargeable:Discharge(1)
end

local function OnLaunch(inst, doer, target_pos)
    inst:AddTag("without_pan")
    inst.swapanims[1].AnimState:HideSymbol("proj")

    if inst.components.equippable:IsEquipped() then
        local owner = inst.components.inventoryitem.owner
        if owner then
            owner.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
        end
    end

    inst.components.icey2_upgradable:CheckSkill()

    inst._on_owner_chop = function(_, data)
        local action = data.action
        if not (action and action.action == ACTIONS.CHOP) then
            return
        end

        local target = action.target
        if not (target and target:IsValid()) then
            return
        end

        local proj = inst.components.icey2_aoeweapon_launch_chainsaw:GetProjectile()
        if proj == nil then
            return
        end

        local level = inst.components.icey2_upgradable:GetLevel()
        if level < 1 then
            return
        end

        if inst.last_rotate_time == nil or GetTime() - inst.last_rotate_time > 1 then
            proj:SetEmergencyDestination(target:GetPosition())
            inst.last_rotate_time = GetTime()
        end
    end

    inst._on_owner_attack = function(_, data)
        local target = data.target
        if not (target and target:IsValid()) then
            return
        end

        local proj = inst.components.icey2_aoeweapon_launch_chainsaw:GetProjectile()
        if proj == nil then
            return
        end

        if data.weapon == proj then
            return
        end

        local level = inst.components.icey2_upgradable:GetLevel()
        if level < 2 then
            return
        end

        if inst.last_rotate_time == nil or GetTime() - inst.last_rotate_time > 1 then
            proj:SetEmergencyDestination(target:GetPosition())
            inst.last_rotate_time = GetTime()
        end
    end

    inst:ListenForEvent("performaction", inst._on_owner_chop, doer)
    inst:ListenForEvent("onhitother", inst._on_owner_attack, doer)
end

local function OnReturn(inst, doer, projectile)
    inst:RemoveTag("without_pan")

    inst.swapanims[1].AnimState:ShowSymbol("proj")

    local s = 0.4
    SpawnAt("icey2_explode_lunar", projectile, { s, s, s })
    ShakeAllCameras(CAMERASHAKE.VERTICAL, .5, .015, .8, inst, 20)

    if inst.components.equippable:IsEquipped() then
        local owner = inst.components.inventoryitem.owner
        if owner then
            owner.components.combat:SetAttackPeriod(17 * FRAMES)
        end
    end

    inst:RemoveEventCallback("performaction", inst._on_owner_chop, doer)
    inst:RemoveEventCallback("onhitother", inst._on_owner_attack, doer)
    inst._on_owner_chop = nil
    inst._on_owner_attack = nil
end

local function SupplyBallDataFn(inst, player, target, addition)
    local percent = player.components.icey2_skill_battle_focus and
        player.components.icey2_skill_battle_focus:GetPercent() or 0

    if percent >= 1 and addition > 1.1 then

    end
end

local function ApplyLevelFn(inst, new_level, old_level)
    if new_level >= 1 then
        inst.components.named:SetName(STRINGS.NAMES.ICEY2_PACT_WEAPON_CHAINSAW .. "+" .. tostring(new_level))
    else
        inst.components.named:SetName(STRINGS.NAMES.ICEY2_PACT_WEAPON_CHAINSAW)
    end

    inst.components.icey2_spdamage_force:SetBaseDamage(1 + new_level * 3)
    if new_level >= 3 then
        inst.components.planardamage:SetBaseDamage(1)
    else
        inst.components.planardamage:SetBaseDamage(0)
    end

    local proj = inst.components.icey2_aoeweapon_launch_chainsaw:GetProjectile()
    if proj ~= nil then
        proj.components.icey2_spdamage_force:SetBaseDamage(1 + new_level * 2)
        if new_level >= 3 then
            proj.components.planardamage:SetBaseDamage(1)
        else
            proj.components.planardamage:SetBaseDamage(0)
        end
    end
end

local SKILL_TAB = {
    upgrade_pact_weapon_chainsaw_1 = 1,
    upgrade_pact_weapon_chainsaw_2 = 2,
    upgrade_pact_weapon_chainsaw_3 = 3,
}


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("icey2_pact_weapon_chainsaw")
    inst.AnimState:SetBuild("icey2_pact_weapon_chainsaw")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:SetLightOverride(0.6)

    inst.AnimState:SetSymbolMultColour("swap_rolling_fx", 0, 0, 0, 0)

    inst:AddTag("icey2_pact_weapon")

    MakeInventoryFloatable(inst, "med", 0.05, { 1.1, 0.5, 1.1 }, true, -9)


    Icey2WeaponSkill.AddAoetargetingClient(inst, "line", nil, 12)
    inst.components.aoetargeting.reticule.reticuleprefab = "reticulelong"
    inst.components.aoetargeting.reticule.pingprefab = "reticulelongping"
    inst.components.aoetargeting:SetAlwaysValid(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.hunger_burn_rate = 0.5

    CreateSwapAnims(inst, FX_DEFS_NORMAL)


    -- Note: Chainsaw will deal 3 damage in one attack SG
    -- Damage is:
    --  17 + force damage + planar damage
    --  8.5 + force damage + planar damage
    --  8.5 + force damage + planar damage

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(17)
    inst.components.weapon:SetOnAttack(OnAttackMelee)

    inst:AddComponent("icey2_spdamage_force")

    inst:AddComponent("planardamage")

    inst:AddComponent("inspectable")

    inst:AddComponent("named")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "icey2_pact_weapon_chainsaw"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/icey2_pact_weapon_chainsaw.xml"
    inst.components.inventoryitem.canonlygoinpocket = true

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("icey2_aoeweapon_launch_chainsaw")
    inst.components.icey2_aoeweapon_launch_chainsaw.onlaunch = OnLaunch
    inst.components.icey2_aoeweapon_launch_chainsaw.onreturn = OnReturn

    inst:AddComponent("icey2_supply_ball_override")
    -- inst.components.icey2_supply_ball_override.getdatafn = SupplyBallDataFn

    inst:AddComponent("icey2_upgradable")
    inst.components.icey2_upgradable:SetApplyFn(ApplyLevelFn)
    inst.components.icey2_upgradable:SetSkillTab(SKILL_TAB)
    inst.components.icey2_upgradable:SetLevel(0)

    Icey2WeaponSkill.AddAoetargetingServer(inst, SpellFn)

    MakeHauntableLaunch(inst)

    return inst
end

local function swapanimfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("icey2_pact_weapon_chainsaw")
    inst.AnimState:SetBuild("icey2_pact_weapon_chainsaw")

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



return Prefab("icey2_pact_weapon_chainsaw", fn, assets),
    Prefab("icey2_pact_weapon_chainsaw_swapanim", swapanimfn, assets)
