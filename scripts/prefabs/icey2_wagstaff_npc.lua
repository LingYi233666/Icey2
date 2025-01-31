local assets =
{
    Asset("ANIM", "anim/player_actions.zip"),
    Asset("ANIM", "anim/player_idles.zip"),
    Asset("ANIM", "anim/player_emote_extra.zip"),
    Asset("ANIM", "anim/wagstaff_face_swap.zip"),
    Asset("ANIM", "anim/hat_gogglesnormal.zip"),
    Asset("ANIM", "anim/wagstaff.zip"),
    Asset("ANIM", "anim/player_notes.zip"),
}


local SHADER_CUTOFF_HEIGHT = -0.125


local function WagErode(inst, time, erodein, removewhendone)
    local time_to_erode = time or 1
    local tick_time     = TheSim:GetTickTime()

    inst:StartThread(function()
        local ticks = 0
        while ticks * tick_time < time_to_erode do
            local erode_amount = ticks * tick_time / time_to_erode
            if erodein then
                erode_amount = 1 - erode_amount
            end
            inst.AnimState:SetErosionParams(erode_amount, SHADER_CUTOFF_HEIGHT, -1.0)
            ticks = ticks + 1

            local truetest = erode_amount
            local falsetest = 1 - erode_amount
            if erodein then
                truetest = 1 - erode_amount
                falsetest = erode_amount
            end

            if inst.shadow == true then
                if math.random() < truetest then
                    if inst.DynamicShadow then
                        inst.DynamicShadow:Enable(false)
                    end
                    inst.shadow = false
                    inst.Light:Enable(false)
                end
            else
                if math.random() < falsetest then
                    if inst.DynamicShadow then
                        inst.DynamicShadow:Enable(true)
                    end
                    inst.shadow = true
                    inst.Light:Enable(true)
                end
            end

            if ticks * tick_time > time_to_erode then
                if erodein then
                    if inst.DynamicShadow then
                        inst.DynamicShadow:Enable(true)
                    end
                    inst.shadow = true
                    inst.Light:Enable(true)
                else
                    if inst.DynamicShadow then
                        inst.DynamicShadow:Enable(false)
                    end
                    inst.shadow = false
                    inst.Light:Enable(false)
                end
                if removewhendone then
                    inst:Remove()
                end
            end

            Yield()
        end
    end)
end

local function OnTimerDone(inst, data)
    if data.name == "fadeout" then
        WagErode(inst, 3.5, false, true)
    end
end

local function WagstaffShowUp(inst)
    inst:Show()
    WagErode(inst, 1, true, false)

    inst.SoundEmitter:PlaySound("moonstorm/common/alterguardian_contained/static_LP", "wagstaffnpc_static_loop")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:SetPrefabNameOverride("wagstaff_npc")

    MakeCharacterPhysics(inst, 75, .5)
    RemovePhysicsColliders(inst)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.DynamicShadow:Enable(false)
    inst.shadow = true
    inst.Transform:SetFourFaced()

    inst:AddTag("nomagic")
    inst:AddTag("character")
    inst:AddTag("wagstaff_npc")
    inst:AddTag("moistureimmunity")

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("wagstaff")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:Hide("hat")
    inst.AnimState:Hide("ARM_carry")

    inst.AnimState:OverrideSymbol("face", "wagstaff_face_swap", "face")
    inst.AnimState:OverrideSymbol("swap_hat", "hat_gogglesnormal", "swap_hat")
    inst.AnimState:Show("HAT")

    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(1)
    inst.Light:SetColour(255 / 255, 200 / 255, 200 / 255)
    inst.Light:Enable(false)

    local talker = inst:AddComponent("talker")
    talker.fontsize = 35
    talker.font = TALKINGFONT
    talker.offset = Vector3(0, -400, 0)
    talker.name_colour = Vector3(231 / 256, 165 / 256, 75 / 256)
    talker.chaticon = "npcchatflair_wagstaff"
    talker:MakeChatter()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end


    inst.persists = false



    inst:AddComponent("timer")

    inst:AddComponent("knownlocations")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 3

    inst:AddComponent("inspectable")

    inst:SetStateGraph("SGwagstaff_npc")

    local wagstaff_npcbrain = require "brains/icey2_wagstaff_npc_skull_pile_brain"
    inst:SetBrain(wagstaff_npcbrain)


    inst:Hide()
    inst.AnimState:SetErosionParams(0, SHADER_CUTOFF_HEIGHT, -1.0)
    inst:DoTaskInTime(0, WagstaffShowUp)
    inst:ListenForEvent("timerdone", OnTimerDone)

    return inst
end

return Prefab("icey2_wagstaff_npc_skull_pile", fn, assets)
