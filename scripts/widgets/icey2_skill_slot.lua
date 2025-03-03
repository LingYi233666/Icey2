local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"

local Icey2SkillSlot = Class(ImageButton, function(self)
    local atlas = "images/ui/skill_slot/sample.xml"
    local image = "sample.tex"

    ImageButton._ctor(self, atlas, image, image, image, image, image)

    -- self.image:SetTint(0, 0, 0, 0)

    self.icon = self:AddChild(Image())
    self.icon:Hide()

    self.recharge = self:AddChild(UIAnim())
    self.recharge:GetAnimState():SetBank("recharge_meter")
    self.recharge:GetAnimState():SetBuild("recharge_meter")
    self.recharge:GetAnimState():SetMultColour(1, 1, 1, 0.8)
    local s = 0.93
    self.recharge:SetScale(s, s, s)
    self.recharge:Hide()

    local default_scale = 0.5
    self:SetNormalScale(default_scale)
    self:SetFocusScale(default_scale)
end)

function Icey2SkillSlot:SetSkillName(skill_name)
    assert(skill_name ~= nil)
    assert(Icey2Basic.GetSkillDefine(skill_name) ~= nil)



    self.skill_name = skill_name

    local imagename = skill_name:lower()

    local atlas = "images/ui/skill_slot/" .. imagename .. ".xml"
    local image = imagename .. ".tex"

    local search_result = softresolvefilepath(atlas)

    if search_result == nil then
        atlas = "images/ui/skill_slot/unknown.xml"
        image = "unknown.tex"
        search_result = softresolvefilepath(atlas)
    end

    if search_result == nil then
        -- print("Icey2SkillSlot Can't find " .. atlas .. ",use default...")
        self.icon:Hide()
    else
        self.icon:SetTexture(atlas, image)
        self.icon:SetSize(55, 55)
        self.icon:Show()
    end
end

function Icey2SkillSlot:EnableIcon(enable)
    if enable then
        self.icon:SetTint(1, 1, 1, 1)
        self.image:SetTint(1, 1, 1, 1)
    else
        self.icon:SetTint(0, 0, 0, 1)
        self.image:SetTint(0.6, 0.6, 0.6, 1)
    end
    self.image:SetTint(0, 0, 0, 0.25)
end

function Icey2SkillSlot:EnableFlashing(enable)
    if self.flashing_task then
        self.flashing_task:Cancel()
        self.flashing_task = nil
    end
    self.recharge:Hide()

    if enable then
        self.recharge:Show()
        self.recharge:GetAnimState():SetPercent("frame_pst", 0.49)
        -- self.recharge:GetAnimState():PlayAnimation("frame_pst", true)
        -- self.recharge:GetAnimState():SetDeltaTimeMultiplier(5)

        self.flashing_task = self.inst:DoPeriodicTask(FRAMES * 2, function()
            if self.recharge.shown then
                self.recharge:Hide()
            else
                self.recharge:Show()
            end
        end)
    end
end

return Icey2SkillSlot
