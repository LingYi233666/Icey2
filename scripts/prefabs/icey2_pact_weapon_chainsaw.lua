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
        if data.damage / 100 > math.random() then
            if inst.components.icey2_aoeweapon_launch_chainsaw:GetProjectile() then
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
    if attacker.sg and attacker.sg.statemem and attacker.sg.statemem.emit_fx then
        local start_pos = target:GetPosition()
        start_pos.y = start_pos.y + GetRandomMinMax(0.8, 2)

        local fx = SpawnAt("icey2_supply_ball_shield_spawn", start_pos)
        fx:FaceAwayFromPoint(attacker:GetPosition(), true)
        fx:SpawnChild("icey2_melee_hit_vfx")

        -- attacker.SoundEmitter:PlaySound("icey2_sfx/skill/new_pact_weapon_chainsaw/hit")
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
end

local function SupplyBallDataFn(inst, player, target, addition)
    local percent = player.components.icey2_skill_battle_focus and
        player.components.icey2_skill_battle_focus:GetPercent() or 0

    if percent >= 1 and addition > 1.1 then

    end
end

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

    CreateSwapAnims(inst, FX_DEFS_NORMAL)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(13)
    inst.components.weapon:SetOnAttack(OnAttackMelee)

    inst:AddComponent("icey2_spdamage_force")
    inst.components.icey2_spdamage_force:SetBaseDamage(12.5)

    inst:AddComponent("inspectable")

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
