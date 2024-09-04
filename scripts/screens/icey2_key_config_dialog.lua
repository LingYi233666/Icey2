local PopupDialogScreen = require "screens/redux/popupdialog"

local Icey2KeyConfigDialog = Class(PopupDialogScreen,
                                   function(self, owner, target_skill_name)
    PopupDialogScreen._ctor(self, STRINGS.ICEY2_UI.KEY_CONFIG_DIALOG.TITLE,
                            STRINGS.ICEY2_UI.KEY_CONFIG_DIALOG.TEXT_BEFORE, {
        -- Buttons:
        {
            text = STRINGS.ICEY2_UI.KEY_CONFIG_DIALOG.DO_SET_SKILL_KEY,
            cb = function()
                if self.selected_button then
                    self.owner.replica.icey2_skiller:SetInputHandler(
                        self.selected_button, self.target_skill_name, true)
                    self.owner.replica.icey2_skiller:PrintInputHandler()
                    self.owner:PushEvent("icey2_skiller_ui_update")
                else
                    print("key_select_ui No setting !")
                end
                TheFrontEnd:PopScreen(self)
            end
        }, {
            text = STRINGS.ICEY2_UI.KEY_CONFIG_DIALOG.CLEAR_SKILL_KEY,
            cb = function()
                self.owner.replica.icey2_skiller:RemoveInputHandler(
                    self.target_skill_name, true)
                self.owner.replica.icey2_skiller:PrintInputHandler()
                self.owner:PushEvent("icey2_skiller_ui_update")
                TheFrontEnd:PopScreen(self)
            end
        }, {
            text = STRINGS.ICEY2_UI.KEY_CONFIG_DIALOG.SET_KEY_CANCEL,
            cb = function() TheFrontEnd:PopScreen(self) end
        }
    })

    self.owner = owner
    self.selected_button = nil
    self.target_skill_name = target_skill_name
end)

function Icey2KeyConfigDialog:OnRawKey(key, down)
    if down then
        local key_str = STRINGS.UI.CONTROLSSCREEN.INPUTS[1][key]
        if key_str then
            self.selected_button = key
            self.dialog.body:SetString(string.format(STRINGS.ICEY2_UI
                                                         .KEY_CONFIG_DIALOG
                                                         .TEXT_AFTER, key_str))
        end
    end

    if Icey2KeyConfigDialog._base.OnRawKey(self, key, down) then return true end
end

function Icey2KeyConfigDialog:OnMouseButton(mousebutton, down, x, y)
    local valid_mousebuttons = {
        -- MOUSEBUTTON_LEFT,
        -- MOUSEBUTTON_RIGHT,
        MOUSEBUTTON_MIDDLE, -- MOUSEBUTTON_MIDDLE
        1005, -- "Mouse Button 4",
        1006 -- "Mouse Button 5",
    }

    -- local hud_entity = TheInput:GetHUDEntityUnderMouse()

    local entitiesundermouse = TheInput:GetAllEntitiesUnderMouse()
    local hud_entity_is_button = false

    -- print("hud_entity:", hud_entity, hud_entity.widget)

    -- for _, hud_entity in pairs(entitiesundermouse) do
    --     print("hud_entity:", hud_entity, hud_entity.widget)

    --     for k, v in pairs(self.dialog.actions.items) do
    --         if hud_entity.widget == v then
    --             hud_entity_is_button = true
    --             break
    --         end
    --     end
    -- end

    if down and not hud_entity_is_button and
        table.contains(valid_mousebuttons, mousebutton) then
        local button_str = STRINGS.UI.CONTROLSSCREEN.INPUTS[1][mousebutton]
        if button_str then
            self.selected_button = mousebutton
            self.dialog.body:SetString(string.format(STRINGS.ICEY2_UI
                                                         .KEY_CONFIG_DIALOG
                                                         .TEXT_AFTER, button_str))
        end
    end

    if Icey2KeyConfigDialog._base.OnMouseButton(self, mousebutton, down, x, y) then
        return true
    end
end

return Icey2KeyConfigDialog
