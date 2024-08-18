local Widget = require "widgets/widget"
local Icey2MainMenu = require("screens/icey2_main_menu")
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"

AddClassPostConstruct("widgets/controls", function(self)
    if self.owner:HasTag("icey2") then
        self.Icey2MenuCaller_root = self:AddChild(Widget("Icey2MenuCaller_root"))
        self.Icey2MenuCaller_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
        self.Icey2MenuCaller_root:SetHAnchor(ANCHOR_LEFT)
        self.Icey2MenuCaller_root:SetVAnchor(ANCHOR_BOTTOM)
        self.Icey2MenuCaller_root:SetMaxPropUpscale(MAX_HUD_SCALE)

        -- self.Icey2MenuCaller = self:AddChild(ImageButton())
        self.Icey2MenuCaller = self.Icey2MenuCaller_root:AddChild(
            TEMPLATES.StandardButton(
                function()
                    TheFrontEnd:PushScreen(Icey2MainMenu(self.owner))
                end,
                STRINGS.ICEY2_UI.MAIN_MENU.CALLER_TEXT,
                { 120, 60 }
            )
        )

        self.Icey2MenuCaller:SetPosition(60, 28)
    end
end)
