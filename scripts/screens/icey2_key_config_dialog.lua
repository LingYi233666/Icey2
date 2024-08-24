local PopupDialogScreen = require "screens/redux/popupdialog"

local Icey2KeyConfigDialog = Class(PopupDialogScreen, function(self, owner, target_skill_name)
    PopupDialogScreen._ctor(
        self,
        STRINGS.ICEY2_UI.KEY_CONFIG_DIALOG.TITLE,
        STRINGS.ICEY2_UI.KEY_CONFIG_DIALOG.TEXT_BEFORE,
        {
            -- Buttons:
            {
                text = STRINGS.ICEY2_UI.KEY_CONFIG_DIALOG.DO_SET_SKILL_KEY,
                cb = function()
                    if self.selected_key then
                        self.owner.replica.icey2_skiller:SetKeyHandler(self.selected_key, self.target_skill_name, true)
                        self.owner.replica.icey2_skiller:PrintKeyHandler()
                        self.owner:PushEvent("icey2_skiller_ui_update")
                    else
                        print("key_select_ui No setting !")
                    end
                    TheFrontEnd:PopScreen(self)
                end
            },
            {
                text = STRINGS.ICEY2_UI.KEY_CONFIG_DIALOG.CLEAR_SKILL_KEY,
                cb = function()
                    self.owner.replica.icey2_skiller:RemoveKeyHandler(self.target_skill_name, true)
                    self.owner.replica.icey2_skiller:PrintKeyHandler()
                    self.owner:PushEvent("icey2_skiller_ui_update")
                    TheFrontEnd:PopScreen(self)
                end
            },
            {
                text = STRINGS.ICEY2_UI.KEY_CONFIG_DIALOG.SET_KEY_CANCEL,
                cb = function()
                    TheFrontEnd:PopScreen(self)
                end
            },
        }
    )

    self.owner = owner
    self.selected_key = nil
    self.target_skill_name = target_skill_name
end)

local function sub_chinese(str, start, end_)
    local sub_str = ""
    local count = 0
    local len = string.len(str)
    for i = 1, len do
        local byte = string.byte(str, i)
        if byte > 0x7F then
            count = count + 1
            if count >= start and count <= end_ then
                local s = string.sub(str, i, i + 2)
                sub_str = sub_str .. s
                i = i + 2
            elseif count > end_ then
                break
            end
        else
            if count >= start and count <= end_ then
                sub_str = sub_str .. string.sub(str, i, i)
            elseif count > end_ then
                break
            end
        end
    end
    return sub_str
end

function Icey2KeyConfigDialog:OnRawKey(key, down)
    local key_str = STRINGS.UI.CONTROLSSCREEN.INPUTS[1][key]
    if key_str then
        self.selected_key = key
        -- if key_str:utf8len() >= 2 and sub_chinese(key_str, key_str:utf8len() - 1, key_str:utf8len()) == "键" then

        -- else
        --     key_str = key_str .. "键"
        -- end
        self.dialog.body:SetString(string.format(STRINGS.ICEY2_UI.KEY_CONFIG_DIALOG.TEXT_AFTER, key_str))
    end

    if Icey2KeyConfigDialog._base.OnRawKey(self, key, down) then
        return true
    end
end

return Icey2KeyConfigDialog
