local Icey2SkillBase_Passive = Class(function(self, inst)
    self.inst = inst
    self.enable = false
end)

function Icey2SkillBase_Passive:Enable() self.enable = true end

function Icey2SkillBase_Passive:Disable() self.enable = false end

function Icey2SkillBase_Passive:IsEnabled() return self.enable end

-- function Icey2SkillBase_Passive:OnSave()
--     local data = {}
--     data.enable = self.enable

--     return data
-- end

-- function Icey2SkillBase_Passive:OnLoad(data)
--     if data ~= nil then
--         if data.enable ~= nil then
--             if data.enable then
--                 self:Enable()
--             else
--                 self:Disable()
--             end
--         end
--     end
-- end

return Icey2SkillBase_Passive
