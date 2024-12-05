-- for i = 1, 100 do
--     local name = "DEBUG_SKILL_" .. i
--     ICEY2_SKILL_DEFINES[name] = {}
--     STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC[name] = {
--         TITLE = name,
--         DESC = "This is " .. name,
--     }
-- end


local function EmitLaserAtPoint(start_pos, target_pos, segment_len, forward_len)
    local delta_pos = target_pos - start_pos
    local delta_pos_norm = delta_pos:GetNormalized()

    if forward_len then
        TheWorld:StartThread(function()
            local delta_xz = Vector3(delta_pos.x, 0, delta_pos.z)
            local delta_xz_norm = delta_xz:GetNormalized()
            local move_dist = 1
            local cnt = delta_xz:Length() / move_dist
            for i = 0, cnt do
                local this_target_pos = start_pos + delta_xz_norm * move_dist * i
                this_target_pos.y = target_pos.y
                EmitLaserAtPoint(start_pos, this_target_pos, segment_len)
                Sleep(0)
            end
            EmitLaserAtPoint(start_pos, target_pos, segment_len)
        end)
        return
    end


    local emit_cnt = delta_pos:Length() / segment_len

    for i = 0, emit_cnt do
        local pos = start_pos + delta_pos_norm * segment_len * i
        local vel = delta_pos_norm * 0.3
        local fx = SpawnAt("test_laser_beam_fx", pos)
        fx.vfx:SetEmitVelocity(vel.x, vel.y, vel.z)

        fx:DoTaskInTime(0.1, fx.Remove)
    end
end


-- c_test_laser()
-- c_test_laser(1,5)
function GLOBAL.c_test_laser(segment_len, forward_len)
    local start_pos = ThePlayer:GetPosition() + Vector3(0, 1, 0)
    local target_pos = TheInput:GetWorldPosition()
    segment_len = segment_len or 0.3
    EmitLaserAtPoint(start_pos, target_pos, segment_len, forward_len)
end

-- ThePlayer.AnimState:AddOverrideBuild("waxwell_minion_spawn") ThePlayer.AnimState:AddOverrideBuild("waxwell_minion_appear")
-- ThePlayer.AnimState:PlayAnimation("minion_spawn")
-- ThePlayer.AnimState:PlayAnimation("ready_stance_pre") ThePlayer.AnimState:PushAnimation("ready_stance_loop", true)
--
-- ThePlayer.AnimState:PlayAnimation("ready_stance_pst")
