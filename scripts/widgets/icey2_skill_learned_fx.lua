local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"

local Icey2SkillLearnedFX = Class(Widget, function(self, skillname)
    Widget._ctor(self, "Icey2SkillLearnedFX")

    skillname = skillname:lower()


    -- self.bg = self:AddChild(Image("images/ui/skill_slot/sample.xml", "sample.tex"))
    -- self.bg:SetScale(0.5, 0.5)

    self.icon = self:AddChild(Image())
    self.icon:Hide()

    local circle_s = 0.6

    self.circle_up = self:AddChild(UIAnim())
    self.circle_up:GetAnimState():SetBank("icey2_new_skill_circle")
    self.circle_up:GetAnimState():SetBuild("icey2_new_skill_circle")
    self.circle_up:GetAnimState():PlayAnimation("idle_front", true)
    self.circle_up:SetScale(circle_s, circle_s)
    self.circle_up:MoveToFront()

    self.circle_down = self:AddChild(UIAnim())
    self.circle_down:GetAnimState():SetBank("icey2_new_skill_circle")
    self.circle_down:GetAnimState():SetBuild("icey2_new_skill_circle")
    self.circle_down:GetAnimState():PlayAnimation("idle_rear", true)
    self.circle_down:SetScale(circle_s, circle_s)
    self.circle_down:MoveToBack()

    -------------------------------------------------------------------------

    local atlas = "images/ui/skill_slot/" .. skillname .. ".xml"
    local image = skillname .. ".tex"

    local search_result = softresolvefilepath(atlas)

    if search_result == nil then

    else
        self.icon:SetTexture(atlas, image)
        self.icon:SetSize(55, 55)
        self.icon:Show()
    end
end)


return Icey2SkillLearnedFX
