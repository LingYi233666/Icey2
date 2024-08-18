local function IsHUDScreen()
    local defaultscreen = false
    if TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name and type(TheFrontEnd:GetActiveScreen().name) == "string" and TheFrontEnd:GetActiveScreen().name == "HUD" then
        defaultscreen = true
    end
    return defaultscreen
end



TheInput:AddKeyHandler(function(key, down)
    if not IsHUDScreen() then
        return
    end

    -- DEBUG TEST
    if key == KEY_R then
        local x, y, z = TheInput:GetWorldPosition():Get()
        local ent = TheInput:GetWorldEntityUnderMouse()
        SendModRPCToServer(MOD_RPC["icey2_rpc"]["debug_test_phantom_sword"], x, y, z, ent)
    end


    -- Handle normal skill casting
    if ThePlayer and ThePlayer:IsValid() and ThePlayer.replica and ThePlayer.replica.icey2_skiller then
        local name = ThePlayer.replica.icey2_skiller.keyhandler[key]
        local node = name and ICEY2_SKILL_DEFINES[name]

        if node and ThePlayer.replica.icey2_skiller:IsLearned(name) then
            local x, y, z = TheInput:GetWorldPosition():Get()
            local ent = TheInput:GetWorldEntityUnderMouse()

            if node.OnPressed_Client and down then
                node.OnPressed_Client(ThePlayer, x, y, z, ent)
            end
            if node.OnReleased_Client and not down then
                node.OnReleased_Client(ThePlayer, x, y, z, ent)
            end
            SendModRPCToServer(MOD_RPC["icey2_rpc"]["cast_skill"], name, down, x, y, z, ent)
        end
    end
end)
