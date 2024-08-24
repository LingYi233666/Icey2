local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local Icey2SkillSlot = require "widgets/icey2_skill_slot"
local Icey2KeyConfigDialog = require "screens/icey2_key_config_dialog"

local Icey2SkillTab = Class(Widget, function(self, owner, config)
    Widget._ctor(self, "Icey2SkillTab")

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
            peek_percent            = 0.3,
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
                widget:SetOnClick(function()
                    self:OnSkillSlotClick(widget)
                end)
            end,
            scrollbar_offset        = 15,
            scrollbar_height_offset = 0,
        }
    ))
    self.scroll_list:SetPosition(-140, 0)

    -- self.skill_title = self:AddChild(TEMPLATES.ScreenTitle(""))
    self.skill_title = self:AddChild(Text(TITLEFONT, 34))
    self.skill_title:SetColour(UICOLOURS.GOLD_SELECTED)
    self.skill_title:SetPosition(295, 200)
    self.skill_title:Hide()

    self.skill_desc = self:AddChild(Text(NUMBERFONT, 25))
    self.skill_desc:SetColour(UICOLOURS.GOLD_SELECTED)
    self.skill_desc:SetVAlign(ANCHOR_TOP)
    self.skill_desc:SetHAlign(ANCHOR_LEFT)
    self.skill_desc:Hide()

    self.skill_key_config_button = self:AddChild(TEMPLATES.StandardButton(nil,
                                                                          STRINGS.ICEY2_UI.SKILL_TAB.KEY_CONFIG,
                                                                          { 140, 50 }))
    self.skill_key_config_button:Hide()
    self.skill_key_config_button:SetPosition(295, -180)

    self:FreshData()
end)

local function IsCastByButton(name)
    local data = ICEY2_SKILL_DEFINES[name]
    return data and (data.OnPressed or data.OnReleased or data.OnPressed_client or data.OnReleased_client)
end

function Icey2SkillTab:FreshData(new_data)
    if new_data == nil then
        self.data = {}
        for name, v in pairs(ICEY2_SKILL_DEFINES) do
            table.insert(self.data, { name = name, })
        end
        table.sort(self.data, function(a, b)
            local a_cast_value = IsCastByButton(a.name) and 1 or 0
            local b_cast_value = IsCastByButton(b.name) and 1 or 0

            return a_cast_value > b_cast_value and a.name < b.name
        end)
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

function Icey2SkillTab:UpdateSkillDescPos(x, y)
    local text_w, text_h = self.skill_desc:GetRegionSize()
    self.skill_desc:SetPosition(x + text_w / 2, y - text_h / 2)
end

function Icey2SkillTab:UpdateSkillDesc(str)
    self.skill_desc:SetMultilineTruncatedString(str, 14, 260, 163, true)

    self:UpdateSkillDescPos(170, 180)
end

function Icey2SkillTab:OnSkillSlotClick(widget)
    self.current_skill_name = widget and widget.skill_name

    if self.current_skill_name then
        local is_learned = self.owner.replica.icey2_skiller:IsLearned(self.current_skill_name)

        self.skill_title:Show()
        if is_learned then
            self.skill_title:SetString(STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC[widget.skill_name].TITLE)
        else
            self.skill_title:SetString(STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC.UNKNWON.TITLE)
        end

        self.skill_desc:Show()
        if is_learned then
            self:UpdateSkillDesc(STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC[widget.skill_name].DESC)
        else
            self:UpdateSkillDesc(STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC.UNKNWON.DESC)
        end

        if is_learned and IsCastByButton(self.current_skill_name) then
            self.skill_key_config_button:Show()
            self.skill_key_config_button:SetOnClick(function()
                TheFrontEnd:PushScreen(Icey2KeyConfigDialog(self.owner, self.current_skill_name))
            end)
        else
            self.skill_key_config_button:Hide()
            self.skill_key_config_button:SetOnClick(nil)
        end
    else
        self.skill_title:Hide()
        self.skill_desc:Hide()
        self.skill_key_config_button:Hide()
    end
end

return Icey2SkillTab
