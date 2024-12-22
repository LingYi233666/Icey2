local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

-- Not good to use badge

local Icey2SkillShieldBadge = Class(Badge, function(self, owner)
    Badge._ctor(self, nil, owner, { 10 / 255, 240 / 255, 240 / 255, 1 }, "status_health")

    self.backing:GetAnimState():SetBank("status_meter")
    self.backing:GetAnimState():SetBuild("status_wet")
    self.backing:GetAnimState():Hide("frame")
    self.backing:GetAnimState():Hide("icon")

    self.staminaarrow = self.underNumber:AddChild(UIAnim())
    self.staminaarrow:GetAnimState():SetBank("sanity_arrow")
    self.staminaarrow:GetAnimState():SetBuild("sanity_arrow")
    self.staminaarrow:GetAnimState():PlayAnimation("neutral")
    self.staminaarrow:SetClickable(false)


    self.val = 100
    self.max = 100
    self.penaltypercent = 0

    self:StartUpdating()


    self.inst:ListenForEvent("isghostmodedirty", function()
        if owner.player_classified and owner.player_classified.isghostmode:value() then
            self:Hide()
        else
            self:Show()
        end
    end, owner)
end)

function Icey2SkillShieldBadge:SetPercent(val, max, penaltypercent)
    self.val = val
    self.max = max
    Badge.SetPercent(self, self.val, self.max)

    self.penaltypercent = penaltypercent or 0
end

local RATE_SCALE_ANIM =
{
    [RATE_SCALE.INCREASE_HIGH] = "arrow_loop_increase_most",
    [RATE_SCALE.INCREASE_MED] = "arrow_loop_increase_more",
    [RATE_SCALE.INCREASE_LOW] = "arrow_loop_increase",
    [RATE_SCALE.DECREASE_HIGH] = "arrow_loop_decrease_most",
    [RATE_SCALE.DECREASE_MED] = "arrow_loop_decrease_more",
    [RATE_SCALE.DECREASE_LOW] = "arrow_loop_decrease",
}

function Icey2SkillShieldBadge:OnUpdate(dt)
    local cmp = self.owner.replica.icey2_skill_shield
    self:SetPercent(cmp:GetPercent(), cmp:GetMax())
end

return Icey2SkillShieldBadge
