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

    self.skill_name = skill_name

    local imagename = skill_name:lower()

    local atlas = "images/ui/skill_slot/" .. imagename .. ".xml"
    local image = imagename .. ".tex"

    local search_result = softresolvefilepath(atlas)

    if search_result == nil then
        print("Icey2SkillSlot Can't find " .. atlas .. ",use default...")
    else
        -- self:SetTextures(atlas, image, image, image, image, image)
    end
end

return Icey2SkillSlot
