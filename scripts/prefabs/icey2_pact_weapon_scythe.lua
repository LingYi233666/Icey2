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

    -- inst:AddComponent("icey2_aoeweapon_flurry_lunge")
    -- inst.components.icey2_aoeweapon_flurry_lunge:SetOnHitFn(OnSpellHit)


    -- Icey2WeaponSkill.AddAoetargetingServer(inst, SpellFn)

    MakeHauntableLaunch(inst)

    return inst
end

----------------------------------------------------------------
local buff_radius = 6

local function CanBeBuffered(inst, target)
    return target
        and target:IsValid()
        and target.components.combat
        and target == inst.owner
        and target:IsNear(inst, buff_radius)
end

local function BufferTask(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, buff_radius, { "_combat" }, { "INLIMBO" })

    for _, v in pairs(ents) do
        if inst.buffered_creatures[v] == nil and CanBeBuffered(inst, v) then
            -- Buffer target
            -- v.components.combat.externaldamagemultipliers:SetModifier(inst, 1.1, inst.prefab)
            if not v.components.planardamage then
                v:AddComponent("planardamage")
            end
            v.components.planardamage:AddBonus(inst, 5, inst.prefab)

            inst.buffered_creatures[v] = true
        end
    end

    local ents_to_be_removed = {}

    for ent, _ in pairs(inst.buffered_creatures) do
        if not CanBeBuffered(inst, ent) then
            table.insert(ents_to_be_removed, ent)
        end
    end

    for _, v in pairs(ents_to_be_removed) do
        if v:IsValid() then
            -- Remove buffer of target
            -- v.components.combat.externaldamagemultipliers:RemoveModifier(inst, inst.prefab)
            v.components.planardamage:RemoveBonus(inst, inst.prefab)
        end
        inst.buffered_creatures[v] = nil
    end
end


local function KillFX(inst)
    if inst.components.timer:TimerExists("killfx") then
        inst.components.timer:StopTimer("killfx")
    end

    if inst.buffer_task then
        inst.buffer_task:Cancel()
        inst.buffer_task = nil
    end

    -- inst.AnimState:PlayAnimation("")
    -- inst:ListenForEvent("animover", inst.Remove)

    inst:Remove()
end

local function SetOwner(inst, owner)
    inst.owner = owner

    inst._on_owner_invalid = function()
        inst:RemoveEventCallback("onremove", inst._on_owner_invalid, owner)
        inst:RemoveEventCallback("playerdeactivated", inst._on_owner_invalid, owner)
        inst:RemoveEventCallback("death", inst._on_owner_invalid, owner)

        inst:KillFX()
    end

    inst:ListenForEvent("onremove", inst._on_owner_invalid, owner)
    inst:ListenForEvent("playerdeactivated", inst._on_owner_invalid, owner)
    inst:ListenForEvent("death", inst._on_owner_invalid, owner)
end

local function TotemTimerDone(inst, data)
    if data.name == "killfx" then
        inst:KillFX()
    end
end

local function totemfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("icey2_pact_weapon_scythe")
    inst.AnimState:SetBuild("icey2_pact_weapon_scythe")
    inst.AnimState:PlayAnimation("totem")

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.buffered_creatures = {}
    inst.buffer_task = inst:DoPeriodicTask(0, BufferTask)


    inst.KillFX = KillFX
    inst.SetOwner = SetOwner


    -- May be do damage to nearby enemies ?
    -- inst:AddComponent("weapon")
    -- inst.components.weapon:SetDamage(17)

    -- inst:AddComponent("icey2_spdamage_force")
    -- inst.components.icey2_spdamage_force:SetBaseDamage(17)

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("killfx", 10)

    inst:ListenForEvent("timerdone", TotemTimerDone)

    return inst
end

return Prefab("icey2_pact_weapon_scythe", fn, assets),
    Prefab("icey2_pact_weapon_scythe_totem", totemfn, assets)
