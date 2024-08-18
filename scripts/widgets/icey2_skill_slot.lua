local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"

local Icey2SkillSlot = Class(ImageButton, function(self, skill_name, atlas, image)
    assert(skill_name ~= nil)
    assert(ICEY2_SKILL_DEFINES[skill_name] ~= nil)

    atlas = atlas or "images/ui/skill_slot/sample.xml"
    image = image or "sample.tex"

    local search_result = softresolvefilepath(atlas)

    if search_result == nil then
        print("Icey2SkillSlot Can't find " .. atlas .. ",use default...")

        atlas = "images/ui/skill_slot/sample.xml"
        image = "sample.tex"
    end

    ImageButton._ctor(self, atlas, image, image, image, image, image)

    -- self:SetNormalScale(0.55)
    -- self:SetFocusScale(0.55)
end)


return Icey2SkillSlot
