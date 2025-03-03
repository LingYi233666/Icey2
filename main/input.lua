local function IsHUDScreen()
    local defaultscreen = false
    if TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name and
        type(TheFrontEnd:GetActiveScreen().name) == "string" and
        TheFrontEnd:GetActiveScreen().name == "HUD" then
        defaultscreen = true
    end
    return defaultscreen
end

local function HandleInputToCastSkills(key_or_mouse_button, down, unused_x,
                                       unused_y)
    -- Handle normal skill casting
    if ThePlayer and ThePlayer:IsValid() and ThePlayer.replica and
        ThePlayer.replica.icey2_skiller then
        local name =
            ThePlayer.replica.icey2_skiller.input_handler[key_or_mouse_button]
        local skill_define = name and Icey2Basic.GetSkillDefine(name)

        if skill_define and ThePlayer.replica.icey2_skiller:IsLearned(name) then
            local x, y, z = TheInput:GetWorldPosition():Get()
            local ent = TheInput:GetWorldEntityUnderMouse()

            if skill_define.OnPressed_Client and down then
                skill_define.OnPressed_Client(ThePlayer, x, y, z, ent)
            end
            if skill_define.OnReleased_Client and not down then
                skill_define.OnReleased_Client(ThePlayer, x, y, z, ent)
            end
            SendModRPCToServer(MOD_RPC["icey2_rpc"]["cast_skill"], name, down,
                x, y, z, ent)
        end
    end
end

TheInput:AddKeyHandler(function(key, down)
    if not IsHUDScreen() then return end

    HandleInputToCastSkills(key, down)
end)

TheInput:AddMouseButtonHandler(function(button, down, x, y)
    if not IsHUDScreen() then return end

    HandleInputToCastSkills(button, down)
end)
