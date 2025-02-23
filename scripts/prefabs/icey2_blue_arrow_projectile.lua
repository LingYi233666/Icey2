local assets =
{
    Asset("ANIM", "anim/lavaarena_blowdart_attacks.zip"),
}

local function OnLaunch(inst)
    inst.start_time = GetTime()
    inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)
end

local function OnHit(inst, attacker, target)
    local self = inst.components.complexprojectile
    if attacker and target and self.owningweapon then
        if attacker ~= nil and attacker.components.combat ~= nil then
            local old_ignorehitrange = attacker.components.combat.ignorehitrange

            attacker.components.combat.ignorehitrange = true
            attacker.components.combat:DoAttack(target, self.owningweapon, inst, self.stimuli)
            attacker.components.combat.ignorehitrange = old_ignorehitrange
        end
    end
    inst:Remove()
end

local function OnUpdateFn(inst, dt)
    dt = dt or FRAMES

    local self = inst.components.complexprojectile

    if GetTime() - inst.start_time > 2 then
        self:Hit()
        return true
    end


    local hit_pos = inst:GetPosition()
    local x, y, z = hit_pos:Get()

    inst.Physics:SetMotorVel(inst.components.complexprojectile.horizontalSpeed, 0, 0)

    for k, v in pairs(TheSim:FindEntities(x, y, z, 4, { "_combat" })) do
        local rad = 0.5

        if self.attacker.components.combat:CanTarget(v) and not self.attacker.components.combat:IsAlly(v) then
            local hit_dist = rad + v:GetPhysicsRadius(0)
            local curr_dist = (hit_pos - v:GetPosition()):Length()

            if curr_dist <= hit_dist then
                self:Hit(v)
                break
            end
        end
    end



    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeProjectilePhysics(inst)

    inst.AnimState:SetBank("lavaarena_blowdart_attacks")
    inst.AnimState:SetBuild("lavaarena_blowdart_attacks")
    inst.AnimState:PlayAnimation("attack_3", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetAddColour(0, 220 / 255, 230 / 255, 1)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

    inst.AnimState:SetLightOverride(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetOnLaunch(OnLaunch)
    inst.components.complexprojectile:SetOnHit(OnHit)
    inst.components.complexprojectile:SetHorizontalSpeed(30)
    inst.components.complexprojectile.onupdatefn = OnUpdateFn

    return inst
end


return Prefab("icey2_blue_arrow_projectile", fn, assets)
