local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local Icey2SkillSlot = require "widgets/icey2_skill_slot"
local Icey2KeyConfigDialog = require "screens/icey2_key_config_dialog"
local Icey2SkillLearnedFX = require "widgets/icey2_skill_learned_fx"

local easing = require("easing")

local Icey2SkillTab = Class(Widget, function(self, owner, config)
    Widget._ctor(self, "Icey2SkillTab")

    self.owner = owner

    self.data = {}
    self.config = config

    self.scroll_list = self:AddChild(TEMPLATES.ScrollingGrid(self.data, {
        context = {},
        widget_width = self.config.widget_width,
        widget_height = self.config.widget_height,
        num_visible_rows = self.config.num_visible_rows,
        num_columns = self.config.num_columns,
        peek_percent = 0.3,
        item_ctor_fn = function(context, i)
            local widget = Icey2SkillSlot()
            return widget
        end,
        apply_fn = function(context, widget, data, index)
            if widget == nil then
                return
            elseif data == nil then
                widget:Hide()
                return
            else
                widget:Show()
            end

            widget:SetSkillName(data.name)
            widget:EnableIcon(self.owner.replica.icey2_skiller:IsLearned(
                data.name))
            widget:SetOnClick(function()
                self:OnSkillSlotClick(widget)
            end)
            -- if data.name == "PHANTOM_SWORD" then
            --     ThePlayer.HUD.debug_slot = widget
            -- end
        end,
        scrollbar_offset = 15,
        scrollbar_height_offset = 0
    }))
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

    self.skill_key_config_button = self:AddChild(
        TEMPLATES.StandardButton(nil,
            STRINGS.ICEY2_UI
            .SKILL_TAB
            .KEY_CONFIG,
            { 140, 50 }))
    self.skill_key_config_button:Hide()
    self.skill_key_config_button:SetPosition(295, -180)

    self:FreshData()
end)

local function IsCastByButton(name)
    local data = ICEY2_SKILL_DEFINES[name]
    return data and
        (data.OnPressed or data.OnReleased or data.OnPressed_Client or
            data.OnReleased_Client)
end

function Icey2SkillTab:ModifySlideBar()
    self.scroll_list.up_button:Hide()
    self.scroll_list.down_button:Hide()
    self.scroll_list.scroll_bar_container:Show()
    self.scroll_list.scroll_bar_line:Show()
    self.scroll_list.scroll_bar_line:ScaleToSize(11, self.config.bar_height)
    self.scroll_list.position_marker:Hide()
end

function Icey2SkillTab:FreshData(new_data)
    if new_data == nil then
        self.data = {}
        for name, v in pairs(ICEY2_SKILL_DEFINES) do
            table.insert(self.data, { name = name })
        end
        table.sort(self.data, function(a, b)
            local a_cast_value = IsCastByButton(a.name) and 1 or 0
            local b_cast_value = IsCastByButton(b.name) and 1 or 0

            return a_cast_value > b_cast_value or a.name < b.name
            -- return a.name > b.name
        end)
    else
        self.data = new_data
    end

    self.scroll_list:SetItemsData(self.data)
    self:ModifySlideBar()
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
            local desc = ""
            if ICEY2_SKILL_DEFINES[widget.skill_name].DescFn then
                desc = ICEY2_SKILL_DEFINES[widget.skill_name].DescFn(self.owner)
            else
                desc = STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC[widget.skill_name].DESC
            end

            self:UpdateSkillDesc(desc)
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

local function MyMoveTo(widget, start_pos, end_pos, duration, endfn)
    widget:SetPosition(start_pos.x, start_pos.y, start_pos.z)

    widget.pos_t = 0
    widget.last_update_time = GetStaticTime()
    widget.task = widget.inst:DoPeriodicTask(0, function()
        local valx = easing.linear(widget.pos_t, start_pos.x,
            end_pos.x - start_pos.x, duration)
        local valy = easing.linear(widget.pos_t, start_pos.y,
            end_pos.y - start_pos.y, duration)
        local valz = easing.linear(widget.pos_t, start_pos.z,
            end_pos.z - start_pos.z, duration)
        widget:SetPosition(valx, valy, valz)

        widget.pos_t = widget.pos_t + GetStaticTime() - widget.last_update_time
        widget.last_update_time = GetStaticTime()

        if widget.pos_t >= duration then
            widget:SetPosition(end_pos.x, end_pos.y, end_pos.z)
            if endfn then endfn() end

            widget.task:Cancel()
            widget.task = nil
        end
    end)
end

function Icey2SkillTab:SpawnUnlockFX(pos)
    local unlockfx = self.scroll_list.list_root.grid:AddChild(UIAnim())
    unlockfx:GetAnimState():SetBank("skill_unlock")
    unlockfx:GetAnimState():SetBuild("skill_unlock")
    unlockfx:GetAnimState():PlayAnimation("idle")
    unlockfx:SetScale(1.3, 1.3)
    unlockfx:SetPosition(pos.x, pos.y)
    unlockfx.inst:ListenForEvent("animover", function() unlockfx:Kill() end)

    TheFrontEnd:GetSound():PlaySound("wilson_rework/ui/unlock_gatedskill")

    return unlockfx
end

-- Fly up wituout menu: 3.7s
-- Fly to slot: 5.8s
-- Static: 3.2s
function Icey2SkillTab:PlaySkillLearnedAnim_Part2(name)
    local target_data = nil
    for k, v in pairs(self.data) do
        if v.name == name then
            target_data = v
            break
        end
    end

    local target_k = self.scroll_list:FindDataIndex(target_data)

    if target_k == nil or target_k <= 0 then
        print("Index not found !")
        return
    end

    -- local row = math.ceil(target_k / self.config.num_columns)
    -- local col = target_k % self.config.num_columns
    -- if col == 0 then
    --     col = self.config.num_columns
    -- end

    -- print("target_k = ", target_k)
    -- print("target row, col = ", row, col)

    self.scroll_list:ScrollToDataIndex(target_k)
    self:ModifySlideBar()

    local index_in_view = nil
    local target_slot = nil
    for k, v in pairs(self.scroll_list.widgets_to_update) do
        if v.skill_name == name then
            index_in_view, target_slot = k, v
            break
        end
    end

    local row = math.ceil(index_in_view / self.config.num_columns)
    local y_offset = 190 + self.config.widget_height * row

    if target_slot == nil then
        print("Target slot widget not found !")
        return
    end

    self:SetClickable(false)
    target_slot:EnableIcon(false)

    local pos = target_slot:GetPosition()

    self.skill_learned_fx = self.scroll_list.list_root.grid:AddChild(Icey2SkillLearnedFX(name))
    self.skill_learned_fx:MoveToFront()

    MyMoveTo(self.skill_learned_fx, Vector3(pos.x, pos.y + y_offset, 0), Vector3(pos.x, pos.y, 0), 5,
        function()
            self.inst:DoTaskInTime(0.6, function()
                self.skill_learned_fx:Kill()
                self.skill_learned_fx = nil

                target_slot:EnableIcon(self.owner.replica.icey2_skiller:IsLearned(name))
                target_slot:EnableFlashing(true)

                self:OnSkillSlotClick(target_slot)
                self:SpawnUnlockFX(pos)

                self.inst:DoTaskInTime(2.9, function()
                    target_slot:EnableFlashing(false)
                    self:SetClickable(true)
                end)
            end)
        end)
end

function Icey2SkillTab:InterruptSkillLearnedAnim(show_skill)
    if self.skill_learned_fx then
        self.skill_learned_fx:Kill()
    end
    self.skill_learned_fx = nil

    self:SetClickable(true)
end

return Icey2SkillTab
