local Icey2ElasticityForce = Class(function(self, inst)
    self.inst = inst

    self.elasticity_factor = 1
    self.friction_factor = 0.01

    self.max_speed = 40
    self.min_speed = 0
end)


function Icey2ElasticityForce:GetElasticityAcceleration(source)
    if not (source and source:IsValid()) then
        return Vector3(0, 0, 0)
    end

    local delta = source:GetPosition() - self.inst:GetPosition()
    local direction = delta:GetNormalized()
    local dist_sq = delta:LengthSq()

    return direction * dist_sq * self.elasticity_factor
end

function Icey2ElasticityForce:GetFrictionAcceleration(vel)
    local direction = -vel:GetNormalized()
    local num       = vel:LengthSq() * self.friction_factor

    return direction * num
end

function Icey2ElasticityForce:GetAfterVel(source, vel_override, dt, is_motor_vel)
    local cur_vel = nil
    if vel_override then
        cur_vel = vel_override
    else
        cur_vel = is_motor_vel and Vector3(self.inst.Physics:GetMotorVel()) or Vector3(self.inst.Physics:GetVelocity())
    end

    if is_motor_vel then
        local my_pos = self.inst:GetPosition()
        cur_vel.x, cur_vel.y, cur_vel.z = self.inst.entity:LocalToWorldSpace(cur_vel.x, cur_vel.y, cur_vel.z)
        cur_vel = cur_vel - my_pos

        local dv_1 = self:GetElasticityAcceleration(source) * dt
        local dv_2 = self:GetFrictionAcceleration(cur_vel) * dt

        cur_vel = cur_vel + dv_1 + dv_2

        local direction = cur_vel:GetNormalized()
        local cur_speed = cur_vel:Length()

        cur_speed = math.clamp(cur_speed, self.min_speed, self.max_speed)
        cur_vel = direction * cur_speed

        cur_vel = cur_vel + my_pos
        cur_vel.x, cur_vel.y, cur_vel.z = self.inst.entity:WorldToLocalSpace(cur_vel.x, cur_vel.y, cur_vel.z)

        return cur_vel
    else
        -- return self:GetFrictionAcceleration(cur_vel + self:GetElasticityAcceleration(source) * dt)
    end
end

return Icey2ElasticityForce
