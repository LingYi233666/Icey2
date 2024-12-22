local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local Icey2SkillShieldMetrics = Class(Widget, function(self, owner)
    Widget._ctor(self, "Icey2SkillShieldMetrics")

    self.owner = owner

    self.bg = self:AddChild(UIAnim())
    self.bg:GetAnimState():SetBank("icey2_skill_shield_metrics")
    self.bg:GetAnimState():SetBuild("icey2_skill_shield_metrics")
    self.bg:GetAnimState():PlayAnimation("bg")
    self.bg:SetScale(0.5)

    self.bar = self:AddChild(UIAnim())
    self.bar:GetAnimState():SetBank("icey2_skill_shield_metrics")
    self.bar:GetAnimState():SetBuild("icey2_skill_shield_metrics")
    self.bar:SetPosition(0, -2)
    self.bar:SetScale(0.5)


    -- self.inst:ListenForEvent("isghostmodedirty", function()
    --     print("isghostmodedirty", owner.player_classified.isghostmode:value())
    --     if owner.player_classified and owner.player_classified.isghostmode:value() then
    --         self:Hide()
    --     else
    --         self:Show()
    --     end
    -- end, owner)

    -- self.inst:DoP

    self:StartUpdating()
end)

function Icey2SkillShieldMetrics:SetMetrics(cur_value, max_value)
    self.bar:GetAnimState():SetPercent("bar", cur_value / max_value)

    self.bar:SetTooltip(STRINGS.ICEY2_UI.SHIELD_METRICS.TIP:format(cur_value, max_value))
end

function Icey2SkillShieldMetrics:OnUpdate(dt)
    local cmp = self.owner.replica.icey2_skill_shield
    self:SetMetrics(cmp:GetCurrent(), cmp:GetMax())
end

return Icey2SkillShieldMetrics
