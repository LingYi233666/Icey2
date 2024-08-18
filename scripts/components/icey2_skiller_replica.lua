require "json"

local GaleCommon = require("util/gale_common")

local Icey2Skiller = Class(function(self, inst)
    self.inst = inst

    self.learned_skill = {}

    self.keyhandler = {
        -- [KEY_Z] = nil,
        -- [KEY_X] = nil,
        -- [KEY_C] = nil,
        -- [KEY_V] = nil,
    }

    self.json_data = net_string(inst.GUID, "Icey2Skiller.json_data", "icey2_skiller_json_data_dirty")

    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(1, function()
            if self.inst == ThePlayer then
                TheSim:GetPersistentString("mod_config_data/icey2_skiller_keyhandler", function(success, encoded_data)
                    if success then
                        local save_data = json.decode(encoded_data)
                        print("Replica icey2_skiller load key config success:")
                        for k, v in pairs(save_data) do
                            self:SetKeyHandler(v[1], v[2])
                        end

                        self.inst:PushEvent("icey2_skiller_ui_update")
                    else
                        print("Replica icey2_skiller keyhandler load failed !!!")
                    end
                end)
            end
        end)

        inst:ListenForEvent("icey2_skiller_json_data_dirty", function()
            local tab = json.decode(self.json_data:value())
            self.learned_skill = tab.learned_skill or {}

            if self.inst == ThePlayer then
                for key, name in pairs(self.keyhandler) do
                    self:SetKeyHandler(key, name)
                end

                -- update galke skill ui (in menu screen) here
                self.inst:PushEvent("icey2_skiller_ui_update")
            end
        end)
    end

    -- inst:ListenForEvent("onremove",function()
    --     TheSim:SetPersistentString("mod_config_data/icey2_skiller_keyhandler", json.encode(self.keyhandler), true)
    -- end)

    -- inst:ListenForEvent("playerdeactivated",function()
    --     TheSim:SetPersistentString("mod_config_data/icey2_skiller_keyhandler", json.encode(self.keyhandler), true)
    -- end)
end)

function Icey2Skiller:SetJsonData(data)
    self.json_data:set(data)
end

function Icey2Skiller:SetKeyHandler(key, name)
    if name ~= nil and not self:IsLearned(name) then
        return
    end

    for k, v in pairs(self.keyhandler) do
        if v == name then
            self.keyhandler[k] = nil
            print(string.format("Icey2Skiller replica clean old setting:%s,%s", name, GaleCommon.GetStringFromKey(k)))
            break
        end
    end

    self.keyhandler[key] = name

    if name ~= nil then
        print(string.format("Icey2Skiller replica setting %s to %s", name, GaleCommon.GetStringFromKey(key)))
    else
        -- print(string.format("Icey2Skiller replica clear key %s",GaleCommon.GetStringFromKey(key)))
    end

    print("Current key settings:")
    local tab = {}
    for k, v in pairs(self.keyhandler) do
        table.insert(tab, { k, v })
        print(string.format("%s:%s", GaleCommon.GetStringFromKey(k), v))
    end
    TheSim:SetPersistentString("mod_config_data/icey2_skiller_keyhandler", json.encode(tab), true)

    -- self.inst:PushEvent("icey2_skiller_ui_update")
end

function Icey2Skiller:IsLearned(name)
    return name and self.learned_skill[name] == true
end

function Icey2Skiller:GetLearnedSkill()
    local ret = {}
    for name, v in pairs(self.learned_skill) do
        if v == true then
            table.insert(ret, name)
        end
    end

    return ret
end

function Icey2Skiller:GetDebugString()
    local s = "Learned skill:"
    for name, bool in pairs(self.learned_skill) do
        if bool then
            s = s .. name .. ","
        end
    end

    return s
end

return Icey2Skiller
