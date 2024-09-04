require "json"

local Icey2Skiller = Class(function(self, inst)
    self.inst = inst

    self.learned_skill = {}

    self.input_handler = {
        -- [KEY_Z] = nil,
        -- [KEY_X] = nil,
        -- [KEY_C] = nil,
        -- [KEY_V] = nil,
    }

    self.json_data = net_string(inst.GUID, "Icey2Skiller.json_data", "icey2_skiller_json_data_dirty")

    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(1, function()
            if self.inst == ThePlayer then
                self:LoadFromFile()
                self:PrintInputHandler()
            end
        end)

        inst:ListenForEvent("icey2_skiller_json_data_dirty", function()
            if self.inst == ThePlayer then
                self:UpdateByServer()
            end
        end)
    end
end)

function Icey2Skiller:SetJsonData(val)
    self.json_data:set(val)
end

function Icey2Skiller:LoadFromFile()
    TheSim:GetPersistentString("mod_config_data/icey2_skiller_input_handler", function(success, encoded_data)
        if success then
            local save_data = json.decode(encoded_data)
            for k, v in pairs(save_data) do
                self:SetInputHandler(v[1], v[2])
            end

            self.inst:PushEvent("icey2_skiller_ui_update")

            print("Replica icey2_skiller load key config success !")
        else
            print("Replica icey2_skiller input_handler load failed !!!")
        end
    end)
end

function Icey2Skiller:SaveToFile()
    -- print("Current key settings:")
    local tab = {}
    for k, v in pairs(self.input_handler) do
        table.insert(tab, { k, v })
        -- print(string.format("%s:%s", STRINGS.UI.CONTROLSSCREEN.INPUTS[1][k], v))
    end
    TheSim:SetPersistentString("mod_config_data/icey2_skiller_input_handler", json.encode(tab), true)
end

function Icey2Skiller:UpdateByServer()
    local tab = json.decode(self.json_data:value())
    self.learned_skill = tab.learned_skill or {}

    -- update galke skill ui (in menu screen) here
    self.inst:PushEvent("icey2_skiller_ui_update")
end

function Icey2Skiller:PrintInputHandler()
    print("Icey2Skiller Current input_handler is:")
    for k, v in pairs(self.input_handler) do
        print(string.format("%s:%s", STRINGS.UI.CONTROLSSCREEN.INPUTS[1][k], v))
    end
end

function Icey2Skiller:SetInputHandler(key, name, save_to_file)
    if name ~= nil and not self:IsLearned(name) then
        return
    end

    self:RemoveInputHandler(name)

    self.input_handler[key] = name

    if name ~= nil then
        print(string.format("Icey2Skiller replica setting %s to %s", name, STRINGS.UI.CONTROLSSCREEN.INPUTS[1][key]))
    else
        -- print(string.format("Icey2Skiller replica clear key %s",STRINGS.UI.CONTROLSSCREEN.INPUTS[1][key]))
    end

    -- self.inst:PushEvent("icey2_skiller_ui_update")

    if save_to_file then
        self:SaveToFile()
    end
end

function Icey2Skiller:RemoveInputHandler(name, save_to_file)
    for k, v in pairs(self.input_handler) do
        if v == name then
            self.input_handler[k] = nil
            print(string.format("Icey2Skiller replica clean old setting:%s,%s", name,
                STRINGS.UI.CONTROLSSCREEN.INPUTS[1][k]))
            break
        end
    end

    if save_to_file then
        self:SaveToFile()
    end
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
