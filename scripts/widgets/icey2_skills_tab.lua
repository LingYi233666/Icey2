local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local Icey2SkillSlot = require "widgets/icey2_skill_slot"

local Icey2SkillsTab = Class(Widget, function(self, owner, config)
    Widget._ctor(self, "Icey2SkillsTab")

    self.owner = owner

    self.data = {}
    self.config = config


    self.scroll_list = self:AddChild(TEMPLATES.ScrollingGrid(
        self.data,
        {
            context                 = {},
            widget_width            = self.config.widget_width,
            widget_height           = self.config.widget_height,
            num_visible_rows        = self.config.num_visible_rows,
            num_columns             = self.config.num_columns,
            item_ctor_fn            = function(context, i)
                local widget = Icey2SkillSlot()
                return widget
            end,
            apply_fn                = function(context, widget, data, index)
                if widget == nil then
                    return
                elseif data == nil then
                    widget:Hide()
                    return
                else
                    widget:Show()
                end

                widget:SetSkillName(data.name)
            end,
            scrollbar_offset        = 15,
            scrollbar_height_offset = 0,
        }
    ))

    self:FreshData()
end)

function Icey2SkillsTab:FreshData(new_data)
    if new_data == nil then
        self.data = {}
        for name, v in pairs(ICEY2_SKILL_DEFINES) do
            table.insert(self.data, { name = name, })
        end
    else
        self.data = new_data
    end

    self.scroll_list:SetItemsData(self.data)
    self.scroll_list.up_button:Hide()
    self.scroll_list.down_button:Hide()
    self.scroll_list.scroll_bar_container:Show()
    self.scroll_list.scroll_bar_line:Show()
    self.scroll_list.scroll_bar_line:ScaleToSize(11, self.config.bar_height)
    self.scroll_list.position_marker:Hide()
end

return Icey2SkillsTab
