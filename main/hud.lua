local Widget = require "widgets/widget"
local Icey2MainMenu = require("screens/icey2_main_menu")
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/redux/templates"
local Icey2SkillShieldBadge = require "widgets/icey2_skill_shield_badge"
local Icey2SkillShieldMetrics = require "widgets/icey2_skill_shield_metrics"
local Icey2SoulAbsorbCircle = require "widgets/icey2_soul_absorb_circle"

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
                { 140, 60 }
            )
        )

        self.Icey2MenuCaller:SetPosition(75, 28)
    end
end)
-- ThePlayer.HUD.controls.status.icey2_soul_absorb_circle:Start()
-- AddClassPostConstruct("widgets/statusdisplays", function(self)
--     if self.owner:HasTag("icey2") then
--         self.icey2_soul_absorb_circle = self:AddChild(Icey2SoulAbsorbCircle(self.owner))

--         local pos = self.heart:GetPosition()
--         self.icey2_soul_absorb_circle:SetPosition(pos)
--         self.icey2_soul_absorb_circle:MoveToFront()
--     end
-- end)

AddClassPostConstruct("widgets/controls", function(self)
    if self.owner:HasTag("icey2") then
        self.icey2_soul_absorb_circle = self:AddChild(Icey2SoulAbsorbCircle(self.owner))
        self.icey2_soul_absorb_circle:SetClickable(false)
        -- local pos_status = self.status:GetPosition()
        -- local pos_heart = self.status.heart:GetPosition()
        -- self.icey2_soul_absorb_circle:SetPosition(pos_status + pos_heart)


        local pos = self.status.heart:GetWorldPosition()
        self.icey2_soul_absorb_circle:SetPosition(pos)

        self.icey2_soul_absorb_circle:MoveToFront()
    end
end)


AddClassPostConstruct("widgets/secondarystatusdisplays", function(self)
    if self.owner:HasTag("icey2") then
        self.icey2_skill_shield_metrics = self:AddChild(Icey2SkillShieldMetrics(self.owner))
        self.icey2_skill_shield_metrics:SetPosition(60, -80)
        self.icey2_skill_shield_metrics:MoveToFront()
    end
end)

AddPrefabPostInit("player_classified", function(inst)
    inst:ListenForEvent("isghostmodedirty", function(inst, data)
        if inst._parent
            and inst._parent.HUD
            and inst._parent.HUD.controls
            and inst._parent.HUD.controls.secondary_status
            and inst._parent.HUD.controls.secondary_status.icey2_skill_shield_metrics then
            if inst.isghostmode:value() then
                inst._parent.HUD.controls.secondary_status.icey2_skill_shield_metrics:Hide()
            else
                inst._parent.HUD.controls.secondary_status.icey2_skill_shield_metrics:Show()
            end
        end
    end)
end)

-- AddClassPostConstruct("widgets/redux/craftingmenu_details", function(self)
--     local old_PopulateRecipeDetailPanel = self.PopulateRecipeDetailPanel

--     self.PopulateRecipeDetailPanel = function(self, data, ...)
--         local old_ret = old_PopulateRecipeDetailPanel(self, data, ...)

--         if data
--             and data.recipe
--             and data.recipe.name
--             and data.recipe.name:starts("icey2_skill_builder_") then
--             self.skins_spinner.spinner_bg:SetTint(0, 0, 0, 0.7)
--         end

--         return old_ret
--     end
-- end)

AddClassPostConstruct("widgets/ingredientui",
    function(self, atlas, image, quantity, on_hand, has_enough, name, owner, recipe_type, quant_text_scale,
             ingredient_recipe)
        if IsIcey2SkillIngredient(recipe_type) then
            self.quant:Hide()
        end
    end
)
