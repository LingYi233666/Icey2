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


local Icey2MainMenu = Class(Screen, function(self, owner)
    Screen._ctor(self, "Icey2MainMenu")

    self.owner = owner

    -- local scr_w, scr_h = TheSim:GetScreenSize()

    -- self.BG_WIDTH = scr_w * 0.72
    -- self.BG_HEIGHT = scr_h * 0.7


    -- self:AddBGAndBars()

    -- self.tab_screens = {
    --     skill_tree = self:AddChild(Icey2SkillGroup(self.owner)),
    -- }

    -- self.headertab_screener = Subscreener(self,
    --                                       self._BuildHeaderTab, self.tab_screens
    -- )
    -- self.headertab_screener:OnMenuButtonSelected("skill_tree")

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

    self.test_bg = self.root:AddChild(Image("images/bg_animated_portal.xml", "bg_plate.tex"))
    self.test_bg:SetSize(900, 450)


    -- self.close_button = self:AddChild(ImageButton("images/global_redux.xml", "close.tex"))
    -- self.close_button:SetOnClick(function() TheFrontEnd:PopScreen(self) end)
    -- self.close_button:SetPosition(self.BG_WIDTH / 2, self.BG_HEIGHT / 2 + 27)

    -- You must push "icey2_skiller_ui_update" event to update this ui (after learn skill,skill tree change,key config,etc)
    -- self.inst:ListenForEvent("icey2_skiller_ui_update", function()
    --                              self:OnUpdate()
    --                          end, self.owner)
    -- self.inst:DoTaskInTime(0, function() self:OnUpdate() end)

    SetAutopaused(true)
end)

function Icey2MainMenu:OnDestroy()
    SetAutopaused(false)

    Icey2MainMenu._base.OnDestroy(self)
end

function Icey2MainMenu:AddBGAndBars()
    local r, g, b = unpack(UICOLOURS.BROWN_DARK)

    self.rect = self:AddChild(Image("images/ui/bufftips/bg_white.xml", "bg_white.tex"))
    self.rect:SetSize(self.BG_WIDTH, self.BG_HEIGHT)
    self.rect:SetTint(r, g, b, 0.6)

    self.bars = {}
    for i = 1, 4 do
        table.insert(self.bars, self:AddChild(Image("images/ui/bufftips/bar.xml", "bar.tex")))
    end

    self.corners = {}
    for i = 1, 4 do
        table.insert(self.corners, self:AddChild(Image("images/ui/bufftips/corner.xml", "corner.tex")))
    end

    local bg_w, bg_h = self.rect:GetSize()

    self.corners[1]:SetPosition(-bg_w / 2, bg_h / 2)
    self.corners[1]:SetRotation(-90)

    self.corners[2]:SetPosition(-bg_w / 2, -bg_h / 2)
    self.corners[2]:SetRotation(-180)

    self.corners[3]:SetPosition(bg_w / 2, -bg_h / 2)
    self.corners[3]:SetRotation(-270)

    self.corners[4]:SetPosition(bg_w / 2, bg_h / 2)

    local bar_width = 16
    local bar_delta = 4
    self.bars[1]:SetPosition(-bg_w / 2 - bar_width / 2 + bar_delta, 0)
    self.bars[1]:SetSize(bar_width, bg_h)

    self.bars[2]:SetPosition(0, -bg_h / 2 - bar_width / 2 + bar_delta / 2)
    self.bars[2]:SetRotation(-90)
    self.bars[2]:SetSize(bar_width, bg_w)

    self.bars[3]:SetPosition(bg_w / 2 + bar_width / 2 - bar_delta, 0)
    self.bars[3]:SetRotation(-180)
    self.bars[3]:SetSize(bar_width, bg_h)

    self.bars[4]:SetPosition(0, bg_h / 2 + bar_width / 2 - bar_delta / 2)
    self.bars[4]:SetRotation(-270)
    self.bars[4]:SetSize(bar_width, bg_w)
end

function Icey2MainMenu:_BuildHeaderTab(subscreener)
    local tabs = {
        { key = "skill_tree",      text = STRINGS.GALE_UI.MENU_SUB_SKILL_TREE, },
        { key = "keyconfig_check", text = STRINGS.GALE_UI.MENU_SUB_KEY_CONFIGED, },
        { key = "flute_list",      text = STRINGS.GALE_UI.MENU_SUB_FLUTE_LIST, },
        { key = "support_them",    text = STRINGS.GALE_UI.MENU_SUB_SUPPORT_THEM, },
        -- { key = "key3", text = "KEY_3", },
    }

    self.header_tabs = self.rect:AddChild(subscreener:MenuContainer(HeaderTabs, tabs))
    self.header_tabs:SetPosition(0, self.BG_HEIGHT / 2 + 27)
    self.header_tabs:MoveToBack()


    return self.header_tabs.menu
end

function Icey2MainMenu:OnUpdate()

end

-- Icey2MainMenu=require("screens/icey2_main_menu") TEST_MAIN=Icey2MainMenu() TheFrontEnd:PushScreen(TEST_MAIN)
-- TheFrontEnd:PopScreen(TEST_MAIN) TEST_MAIN=nil

return Icey2MainMenu
