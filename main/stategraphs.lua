AddStategraphState("wilson",
    State
    {
        name = "icey2_dodge",
        tags = { "busy", "evade", "dodge", "no_stun", "nopredict" },

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("atk_leap_pre")
            inst.AnimState:PushAnimation("atk_leap_lag", false)

            inst.components.icey2_skill_dodge:OnDodgeStart(data.pos)

            inst.sg:SetTimeout(0.3)
        end,

        onupdate = function(inst)
            inst.components.icey2_skill_dodge:OnDodging()
        end,

        timeline =
        {

        },

        ontimeout = function(inst)
            inst.AnimState:PlayAnimation("pickup_pst")
            inst.sg:GoToState("idle", true)
        end,

        onexit = function(inst)
            inst.components.icey2_skill_dodge:OnDodgeStop()
        end,
    }
)
