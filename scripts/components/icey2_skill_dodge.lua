local Icey2SkillBase_Active = require("components/icey2_skill_base_active")

local Icey2SkillDodge = Class(Icey2SkillBase_Active, function(self, inst)
    Icey2SkillBase_Active._ctor(self, inst)

    ------------------------------------------
    self.can_cast_while_busy = true
    self.costs.hunger = 1
    self.cooldown = 0.33

    ------------------------------------------

    self.search_dist = 5
    self.dodge_speed = 40

    self.max_dodge_charge = 1
    self.dodge_charge = 1
    self.recharge_rate = 3

    self:SetMaxCharge(self.max_dodge_charge)
end)

function Icey2SkillDodge:DoDeltaCharge(delta)
    self.dodge_charge = math.clamp(self.dodge_charge + delta, 0, self.max_dodge_charge)
    self.inst.replica.icey2_skill_dodge:SetCharge(math.floor(self.dodge_charge))
end

-- print( ThePlayer.components.icey2_skill_dodge.dodge_charge)
-- ThePlayer.components.icey2_skill_dodge:SetMaxCharge(3)
function Icey2SkillDodge:SetMaxCharge(c)
    self.max_dodge_charge = c
    self.inst.replica.icey2_skill_dodge:SetMaxCharge(c)

    self:DoDeltaCharge(0)

    if self.max_dodge_charge > self.dodge_charge then
        self:StartRecharge()
    end
end

function Icey2SkillDodge:RechageTask()
    self:DoDeltaCharge(FRAMES * self.recharge_rate)
end

function Icey2SkillDodge:StartRecharge(delay)
    self:StopRecharge()

    if delay and delay >= 0 then
        self.delay_recharge_task = self.inst:DoTaskInTime(delay, function()
            self:StartRecharge()
        end)
    else
        self.recharge_task = self.inst:DoPeriodicTask(0, function()
            self:RechageTask()
            if self.dodge_charge >= self.max_dodge_charge then
                self:StopRecharge()
            end
        end)
    end
end

function Icey2SkillDodge:StopRecharge()
    if self.delay_recharge_task then
        self.delay_recharge_task:Cancel()
        self.delay_recharge_task = nil
    end

    if self.recharge_task then
        self.recharge_task:Cancel()
        self.recharge_task = nil
    end
end

function Icey2SkillDodge:SearchCreaturesAutoToAttack()
    local creatures = {}
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.search_dist,
        { "_combat", "_health" }, { "INLIMBO" })
    for _, v in pairs(ents) do
        if self.inst.components.combat:CanTarget(v) and
            v.components.combat:TargetIs(self.inst) and
            (v:HasTag("attack") or (v.sg and v.sg:HasStateTag("attack"))) then
            table.insert(creatures, v)
        end
    end

    return creatures
end

function Icey2SkillDodge:CounterBack(target)
    local shadow = SpawnPrefab("icey2_clone_dodge_counter_back")
    local dmg, spdmg = self.inst.components.combat:CalcDamage(target, self.inst.components.combat:GetWeapon(), 1.5)

    spdmg = spdmg or {}
    spdmg.icey2_spdamage_force = (spdmg.icey2_spdamage_force or 0) + dmg
    dmg = 0

    -- shadow.AnimState:OverrideSymbol("swap_object", "swap_nightmaresword", "swap_nightmaresword")

    shadow.AnimState:OverrideSymbol("swap_object", "swap_icey2_pact_weapon_great_sword",
        "swap_icey2_pact_weapon_great_sword")

    shadow:SetSuitablePosition(target)
    shadow:CounterBack(self.inst, target, dmg, spdmg)
end

function Icey2SkillDodge:HasSuitableWeapon()
    local weapon = self.inst.components.combat:GetWeapon()
    return weapon and not weapon.components.weapon.projectile
end

local function ForceStopHeavyLifting(inst)
    if inst.components.inventory:IsHeavyLifting() then
        inst.components.inventory:DropItem(
            inst.components.inventory:Unequip(EQUIPSLOTS.BODY),
            true,
            true
        )
    end
end

function Icey2SkillDodge:OnDodgeStart(target_pos)
    ForceStopHeavyLifting(self.inst)

    self.start_pos = self.inst:GetPosition()
    self.start_platform = self.inst:GetCurrentPlatform()

    self.inst.components.locomotor:Stop()

    self.inst:ForceFacePoint(target_pos)
    self.inst.Physics:SetMotorVelOverride(self.dodge_speed, 0, 0)

    self.inst.components.health:SetInvincible(true)

    self.inst.AnimState:SetMultColour(0 / 255, 229 / 255, 232 / 255, 0.3)

    -- icey_speedrun
    local fx1 = self.inst:SpawnChild("icey2_dodge_vfx")
    local equip = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if equip == nil then
        fx1._offset2_y:set(0.5)
    end
    self.dodge_fx = { fx1 }

    if not Icey2Basic.IsWearingArmor(self.inst) and self:HasSuitableWeapon() then
        local enemies = self:SearchCreaturesAutoToAttack()
        if #enemies > 0 then
            self:CounterBack(enemies[1])
        end
    end

    self.inst.SoundEmitter:PlaySound("icey2_sfx/skill/dodge/dodge")
end

function Icey2SkillDodge:OnDodging()
    self.inst.Physics:SetMotorVelOverride(self.dodge_speed, 0, 0)
end

function Icey2SkillDodge:OnDodgeStop()
    self.inst.Physics:ClearMotorVelOverride()
    self.inst.Physics:Stop()

    self.inst.AnimState:SetMultColour(1, 1, 1, 1)

    if self.dodge_fx then
        for _, v in pairs(self.dodge_fx) do v:Remove() end
        self.dodge_fx = nil
    end

    -- Check if icey is on ocean or invalid tiles
    local x, y, z = self.inst.Transform:GetWorldPosition()
    if self.inst.components.drownable:IsOverWater() then
        print(self.inst, "drownable trigger!")

        if self.start_platform then
            x, y, z = self.start_platform.Transform:GetWorldPosition()
        elseif self.start_pos then
            x, y, z = self.start_pos:Get()
        end
        y = 0

        print("return to", x, y, z)
        self.inst.Transform:SetPosition(x, y, z)

        -- if self.inst.components.walkableplatformplayer then
        --     self.inst.components.walkableplatformplayer:TestForPlatform()
        -- end

        local platform = TheWorld.Map:GetPlatformAtPoint(x, z)
        print("platform:", platform)
        -- if platform and self.inst.components.walkableplatformplayer then
        --     print("GetOnPlatform !")
        --     self.inst.components.walkableplatformplayer:GetOnPlatform(platform)
        -- end

        if platform and platform.components.walkableplatform then
            print("SetEntitiesOnPlatform !")
            platform.components.walkableplatform:SetEntitiesOnPlatform()
        end

        print("is over water:", self.inst.components.drownable:IsOverWater())
        print("current sg:", self.inst.sg.currentstate.name)
    end
    self.start_pos = nil
    self.start_platform = nil

    self.inst.components.health:SetInvincible(false)
end

function Icey2SkillDodge:CanCast(x, y, z, target)
    local success, reason = Icey2SkillBase_Active.CanCast(self, x, y, z, target)
    if not success then
        return false, reason
    end

    if self.dodge_charge < 1 then
        return false, "NOT_ENOUGH_DODGE_CHARGE"
    end

    return true
end

function Icey2SkillDodge:Cast(x, y, z, target)
    if TUNING.ICEY2_DODGE_DIRECTION == 2 then
        x, y, z = (self.inst:GetPosition() + Icey2Basic.GetFaceVector(self.inst) * 5):Get()
    end

    Icey2SkillBase_Active.Cast(self, x, y, z, target)

    self:DoDeltaCharge(-1)
    if self.dodge_charge < self.max_dodge_charge then
        self:StartRecharge(0.5)
    end
    self.inst.sg:GoToState("icey2_dodge", { pos = Vector3(x, y, z) })
end

function Icey2SkillDodge:OnSave()
    local data = Icey2SkillBase_Active.OnSave(self)

    data.dodge_charge = self.dodge_charge
    data.max_dodge_charge = self.max_dodge_charge

    return data
end

function Icey2SkillDodge:OnLoad(data)
    Icey2SkillBase_Active.OnLoad(self, data)

    if data.dodge_charge ~= nil then
        self.dodge_charge = data.dodge_charge
    end

    if data.max_dodge_charge ~= nil then
        self:SetMaxCharge(data.max_dodge_charge)
    end
end

return Icey2SkillDodge
