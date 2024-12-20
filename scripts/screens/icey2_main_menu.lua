local HeaderTabs = require "widgets/redux/headertabs"
local PopupDialogScreen = require "screens/redux/popupdialog"
local Screen = require "widgets/screen"
local SnapshotTab = require "widgets/redux/snapshottab"
local Subscreener = require "screens/redux/subscreener"
local TEMPLATES = require "widgets/redux/templates"
local TextListPopup = require "screens/redux/textlistpopup"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local NineSlice = require "widgets/nineslice"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Icey2SkillSlot = require "widgets/icey2_skill_slot"
local Icey2SkillTab = require "widgets/icey2_skill_tab"
local Icey2SkillLearnedFX = require "widgets/icey2_skill_learned_fx"

local easing = require("easing")

local Icey2MainMenu = Class(Screen, function(self, owner)
    Screen._ctor(self, "Icey2MainMenu")

    self.owner = owner

    self.bg_width, self.bg_height = 800, 450

    self.black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    self.black.image:SetVRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetHRegPoint(ANCHOR_MIDDLE)
    self.black.image:SetVAnchor(ANCHOR_MIDDLE)
    self.black.image:SetHAnchor(ANCHOR_MIDDLE)
    self.black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black.image:SetTint(0, 0, 0, 0)
    self.black:SetOnClick(function() TheFrontEnd:PopScreen(self) end)
    self.black:MoveToBack()


    self.root = self:AddChild(TEMPLATES.ScreenRoot("Icey2MainMenu"))

    self.bg = self.root:AddChild(TEMPLATES.RectangleWindow(self.bg_width, self.bg_height))
    self.bg.top:Hide()
    self.bg:SetPosition(0, -50)

    -- self.close_button = self.bg:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
    -- self.close_button:SetOnClick(function() TheFrontEnd:PopScreen(self) end)
    -- self.close_button:SetPosition(self.bg_width / 2 + 35, self.bg_height / 2 + 35)


    self.tab_screens = {
        skill_tab = self.bg:AddChild(Icey2SkillTab(self.owner, {
            widget_width = 80,
            widget_height = 80,
            num_visible_rows = 5,
            num_columns = 7,
            bar_height = self.bg_height,
        })),
        -- key_config = self.bg:AddChild(Widget("KEY_CONFIG")),
    }

    self.headertab_screener = Subscreener(self,
        self._BuildHeaderTab, self.tab_screens
    )
    self.headertab_screener:OnMenuButtonSelected("skill_tab")

    -- You must push "icey2_skiller_ui_update" event to update this ui (after learn skill,skill tree change,key config,etc)
    -- self.inst:ListenForEvent("icey2_skiller_ui_update", function()
    --                              self:OnUpdate()
    --                          end, self.owner)
    -- self.inst:DoTaskInTime(0, function() self:OnUpdate() end)

    ThePlayer.HUD.controls.Icey2MainMenu = self

    SetAutopaused(true)
end)

function Icey2MainMenu:OnDestroy()
    SetAutopaused(false)

    self:InterruptSkillLearnedAnim(false)

    ThePlayer.HUD.controls.Icey2MainMenu = nil
    Icey2MainMenu._base.OnDestroy(self)
end

function Icey2MainMenu:_BuildHeaderTab(subscreener)
    local tabs = {
        { key = "skill_tab", text = STRINGS.ICEY2_UI.MAIN_MENU.SUB_TITLES.SKILL_TAB, },
        -- { key = "key_config", text = STRINGS.ICEY2_UI.MAIN_MENU.SUB_TITLES.KEY_CONFIG, },
    }

    self.header_tabs = self.bg:AddChild(subscreener:MenuContainer(HeaderTabs, tabs))
    -- self.header_tabs:SetPosition(0, self.bg_height / 2 + 27)
    self.header_tabs:SetPosition(0, self.bg_height / 2 + 22)
    self.header_tabs:MoveToBack()
    local s = 0.8
    self.header_tabs:SetScale(s, s)


    return self.header_tabs.menu
end

local function MyMoveTo(widget, start_pos, end_pos, duration, endfn)
    widget:SetPosition(start_pos.x, start_pos.y, start_pos.z)

    widget.pos_t = 0
    widget.last_update_time = GetStaticTime()
    widget.task = widget.inst:DoPeriodicTask(0, function()
        local valx = easing.inCubic(widget.pos_t, start_pos.x, end_pos.x - start_pos.x, duration)
        local valy = easing.inCubic(widget.pos_t, start_pos.y, end_pos.y - start_pos.y, duration)
        local valz = easing.inCubic(widget.pos_t, start_pos.z, end_pos.z - start_pos.z, duration)
        widget:SetPosition(valx, valy, valz)

        widget.pos_t = widget.pos_t + GetStaticTime() - widget.last_update_time
        widget.last_update_time = GetStaticTime()

        if widget.pos_t >= duration then
            widget:SetPosition(end_pos.x, end_pos.y, end_pos.z)
            if endfn then
                endfn()
            end

            widget.task:Cancel()
            widget.task = nil
        end
    end)
end

-- ThePlayer.HUD.Icey2MainMenu:PlaySkillLearnedAnim_Part1("PHANTOM_SWORD")
function Icey2MainMenu:PlaySkillLearnedAnim_Part1(name, continue_to_part2)
    print("PlaySkillLearnedAnim_Part1")

    self.bg:SetClickable(false)
    self.bg:Hide()

    self.black.image:SetTint(0, 0, 0, 0.6)

    self.skill_learned_fx = self.root:AddChild(Icey2SkillLearnedFX(name))
    self.skill_learned_fx:MoveToFront()

    self.inst:DoTaskInTime(1, function()
        MyMoveTo(self.skill_learned_fx, Vector3(0, 0), Vector3(0, 600), 3, function()
            self.bg:Show()
            self.bg:SetClickable(true)

            self.skill_learned_fx:Kill()
            self.skill_learned_fx = nil

            if continue_to_part2 ~= false then
                self.headertab_screener:OnMenuButtonSelected("skill_tab")
                self.tab_screens.skill_tab:PlaySkillLearnedAnim_Part2(name)
            end
        end)
    end)

    TheFrontEnd:GetSound():PlaySound("icey2_sfx/hud/new_skill_achieved", "icey2_skill_learned_music")
end

function Icey2MainMenu:InterruptSkillLearnedAnim(show_skill)
    if TheFrontEnd:GetSound():PlayingSound("icey2_skill_learned_music") then
        TheFrontEnd:GetSound():KillSound("icey2_skill_learned_music")
    end

    if self.skill_learned_fx then
        self.skill_learned_fx:Kill()
    end
    self.skill_learned_fx = nil

    self.tab_screens.skill_tab:InterruptSkillLearnedAnim(show_skill)

    self.bg:Show()
    self.bg:SetClickable(true)
end

function Icey2MainMenu:OnControl(control, down)
    if Icey2MainMenu._base.OnControl(self, control, down) then return true end


    if not down and (control == CONTROL_CANCEL) then
        TheFrontEnd:PopScreen(self)
        return true
    end
end

function Icey2MainMenu:OnUpdate()

end

-- Icey2MainMenu=require("screens/icey2_main_menu") TEST_MAIN=Icey2MainMenu() TheFrontEnd:PushScreen(TEST_MAIN)
-- TheFrontEnd:PopScreen(TEST_MAIN) TEST_MAIN=nil

return Icey2MainMenu
