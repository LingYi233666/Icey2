local AOEWeapon_Base = require("components/aoeweapon_base")

local Icey2AOEWeapon_GroundSlam = Class(AOEWeapon_Base, function(self, inst)
    AOEWeapon_Base._ctor(self, inst)

    self.startfn = nil
    self.stopfn = nil

    self.attacker = nil
    self.colour_percent = 0
    self.default_colour = Vector3(96 / 255, 249 / 255, 255 / 255)
    self.search_distance = 2.5
    self.ignite_distance = 4
    self.num_ground_lightning = 5

    -- SetOnHitFn
    inst:AddTag("icey2_aoeweapon")


    inst:ListenForEvent("onremove", function()
        self:PopAddColour()
    end)
end)

function Icey2AOEWeapon_GroundSlam:OnStart(attacker, pos)
    return self.startfn and self.startfn(self.inst, attacker, pos)
end

function Icey2AOEWeapon_GroundSlam:OnStop(attacker)
    return self.stopfn and self.stopfn(self.inst, attacker)
end

function Icey2AOEWeapon_GroundSlam:IsValidTarget(attacker, target)
    return target
        and not target:HasOneOfTags(self.notags)
        and target:HasOneOfTags(self.combinedtags)
        and (
            (attacker.components.combat:CanTarget(target)
                and not attacker.components.combat:IsAlly(target))
            or (target.components.workable
                and target.components.workable:CanBeWorked()
                and self.workactions[target.components.workable:GetWorkAction()])
        )
end

function Icey2AOEWeapon_GroundSlam:SearchPossibleTargets(attacker, target_pos)
    local possible_targets = {}

    local ents = TheSim:FindEntities(target_pos.x, target_pos.y, target_pos.z, self.search_distance, nil,
        self.notags, self.combinedtags)

    for _, v in pairs(ents) do
        if self:IsValidTarget(attacker, v) then
            table.insert(possible_targets, v)
        end
    end


    return possible_targets
end

function Icey2AOEWeapon_GroundSlam:DoAreaAttack(attacker, pos)
    pos = pos or attacker:GetPosition()

    local possible_targets = self:SearchPossibleTargets(attacker, pos)

    for _, v in pairs(possible_targets) do
        if v.components.workable
            and v.components.workable:CanBeWorked()
            and self.workactions[v.components.workable:GetWorkAction()] then
            v.components.workable:WorkedBy(attacker, 10)
        else
            self:OnHit(attacker, v)
        end
    end
end

function Icey2AOEWeapon_GroundSlam:TossNearbyItems(attacker, pos)
    pos = pos or attacker:GetPosition()

    --Tossing
    local toss_targets = TheSim:FindEntities(pos.x, 0, pos.z, self.search_distance + 2, { "_inventoryitem" },
        { "locomotor", "INLIMBO" })
    for _, toss_target in ipairs(toss_targets) do
        local toss_targetrangesq = self.search_distance + toss_target:GetPhysicsRadius(0.5)
        toss_targetrangesq = toss_targetrangesq * toss_targetrangesq

        local vx, vy, vz = toss_target.Transform:GetWorldPosition()
        local lensq = distsq(vx, vz, pos.x, pos.z)
        if lensq < toss_targetrangesq and vy < 0.2 then
            self:OnToss(attacker, toss_target, nil, 1.5 - lensq / toss_targetrangesq, math.sqrt(lensq))
        end
    end
end

function Icey2AOEWeapon_GroundSlam:IgniteNearbyThings(attacker, pos, delay)
    if delay then
        self.inst:DoTaskInTime(delay, function() self:IgniteNearbyThings(attacker, pos) end)
        return
    end

    pos = pos or attacker:GetPosition()

    local ents = TheSim:FindEntities(pos.x, 0, pos.z, self.ignite_distance + 2, nil, { "INLIMBO" })
    for _, v in ipairs(ents) do
        if v ~= attacker
            and v.components.burnable
            and not v.components.burnable:IsBurning()
            and not v:HasTag("burnt") then
            local rangesq = self.ignite_distance + v:GetPhysicsRadius(0.5)
            rangesq = rangesq * rangesq

            local vx, vy, vz = v.Transform:GetWorldPosition()
            if distsq(vx, vz, pos.x, pos.z) < rangesq then
                v.components.burnable:Ignite()
            end
        end
    end
end

function Icey2AOEWeapon_GroundSlam:SpawnFX(pos)
    SpawnAt("icey2_superjump_land_fx2", pos)

    local step = 360 / self.num_ground_lightning
    local deg_start = math.random() * 360
    local radius = 3

    for i = 1, self.num_ground_lightning do
        local deg = deg_start + (i - 1) * step + math.random(-10, 10)
        local rad = deg * DEGREES
        local offset = Vector3(math.cos(rad), 0, math.sin(rad)) * radius

        local fx = SpawnAt("icey2_ground_lightning_fx", pos, nil, offset)

        local look_at_deg = math.atan2(-offset.z, offset.x) * RADIANS - 90
        fx.Transform:SetRotation(look_at_deg)
    end
end

--

function Icey2AOEWeapon_GroundSlam:UpdateAddColour()
    if self.attacker and self.attacker:IsValid() then
        local current_colour = self.default_colour * self.colour_percent
        self.attacker.AnimState:SetAddColour(current_colour.x, current_colour.y, current_colour.z, 1)
    end
end

function Icey2AOEWeapon_GroundSlam:PushAddColour(attacker)
    self:PopAddColour()

    self.attacker = attacker
    self.colour_percent = 1

    self:UpdateAddColour()

    self.inst:StartUpdatingComponent(self)
end

function Icey2AOEWeapon_GroundSlam:PopAddColour()
    self.inst:StopUpdatingComponent(self)

    self.colour_percent = 0
    self:UpdateAddColour()
    self.attacker = nil
end

function Icey2AOEWeapon_GroundSlam:OnUpdate(dt)
    self.colour_percent = math.clamp(self.colour_percent - dt * 3, 0, 1)
    if self.colour_percent <= 0 then
        self:PopAddColour()
    else
        self:UpdateAddColour()
    end
end

return Icey2AOEWeapon_GroundSlam
