local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"

local Icey2SkillSlot = Class(ImageButton, function(self)
    local atlas = "images/ui/skill_slot/sample.xml"
    local image = "sample.tex"

    ImageButton._ctor(self, atlas, image, image, image, image, image)

    local default_scale = 0.5
    self:SetNormalScale(default_scale)
    self:SetFocusScale(default_scale)
end)

function Icey2SkillSlot:SetSkillName(skill_name)
    assert(skill_name ~= nil)
    assert(ICEY2_SKILL_DEFINES[skill_name] ~= nil)

    skill_name = skill_name:lower()
    self.skill_name = skill_name

    local atlas = "images/ui/skill_slot/" .. skill_name .. ".xml"
    local image = skill_name .. ".tex"

    local search_result = softresolvefilepath(atlas)

    if search_result == nil then
        print("Icey2SkillSlot Can't find " .. atlas .. ",use default...")

        atlas = "images/ui/skill_slot/sample.xml"
        image = "sample.tex"
    end

    self:SetTextures(atlas, image, image, image, image, image)
end

return Icey2SkillSlot
