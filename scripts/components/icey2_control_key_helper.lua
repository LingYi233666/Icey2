local Icey2ControlKeyHelper = Class(function(self, inst)
    self.inst = inst

    if not TheNet:IsDedicated() then
        self.last_update_time = 0
        self.moving_dir_client = nil
        self.mouse_pos_client = nil
        self.mouse_target_client = nil

        -- local move_control_keys = {
        --     CONTROL_MOVE_UP, CONTROL_MOVE_DOWN, CONTROL_MOVE_LEFT, CONTROL_MOVE_RIGHT
        -- }

        -- self.handler = TheInput:AddGeneralControlHandler(function(control, pressed)
        --     if table.contains(move_control_keys, control) then
        --         local dir = Vector3(0, 0, 0)
        --         local xdir = TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) -
        --             TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)
        --         local ydir = TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) -
        --             TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
        --         local deadzone = TUNING.CONTROLLER_DEADZONE_RADIUS
        --         if math.abs(xdir) >= deadzone or math.abs(ydir) >= deadzone then
        --             dir = TheCamera:GetRightVec() * xdir - TheCamera:GetDownVec() * ydir
        --             dir:Normalize()
        --         end

        --         self.moving_dir_client = dir
        --         SendModRPCToServer(MOD_RPC["icey2_rpc"]["update_moving_direct_vector"], dir.x, dir.z)
        --     end
        -- end)

        -- self.task = inst:DoPeriodicTask(0, function()
        --     if ThePlayer ~= self.inst then
        --         return
        --     end

        --     local pos = TheInput:GetWorldPosition()
        --     local target = TheInput:GetWorldEntityUnderMouse()

        --     self.mouse_pos_client = pos
        --     self.mouse_target_client = target

        --     if GetTime() - self.last_update_time > 0.2 then
        --         SendModRPCToServer(MOD_RPC["icey2_rpc"]["update_mouse_position"], pos.x, pos.z)
        --         -- SendModRPCToServer(MOD_RPC["icey2_rpc"]["update_mouse_entity"], target)
        --         self.last_update_time = GetTime()
        --     end
        -- end)

        self.inst:StartUpdatingComponent(self)
    else
        self.moving_dir_server = Vector3(0, 0, 0)
        self.mouse_pos_server = Vector3(0, 0, 0)
        self.mouse_target_server = nil
    end
end)

function Icey2ControlKeyHelper:SetMovingDirectVector(vec)
    self.moving_dir_server = vec
end

function Icey2ControlKeyHelper:SetMousePosition(pos)
    self.mouse_pos_server = pos
end

function Icey2ControlKeyHelper:SetEntityUnderMouse(tar)
    self.mouse_target_server = tar
end

function Icey2ControlKeyHelper:GetMovingDirectVector()
    return self.moving_dir_client or self.moving_dir_server
end

function Icey2ControlKeyHelper:GetMousePosition()
    return self.mouse_pos_client or self.mouse_pos_server
end

function Icey2ControlKeyHelper:GetEntityUnderMouse()
    return self.mouse_target_client or self.mouse_target_server
end

-- function Icey2ControlKeyHelper:GetDebugString()
--     return string.format("Direct:%s Mouse:%s Entity:%s",
--         tostring(self:GetMovingDirectVector()),
--         tostring(self:GetMousePosition()),
--         tostring(self:GetEntityUnderMouse()))
-- end

function Icey2ControlKeyHelper:OnUpdate(dt)
    if ThePlayer == nil or ThePlayer ~= self.inst then
        return
    end

    local pos = TheInput:GetWorldPosition()
    local target = TheInput:GetWorldEntityUnderMouse()

    self.mouse_pos_client = pos
    self.mouse_target_client = target

    if GetTime() - self.last_update_time > 0.2 then
        SendModRPCToServer(MOD_RPC["icey2_rpc"]["update_mouse_position"], pos.x, pos.z)
        -- SendModRPCToServer(MOD_RPC["icey2_rpc"]["update_mouse_entity"], target)
        self.last_update_time = GetTime()
    end
end

return Icey2ControlKeyHelper
