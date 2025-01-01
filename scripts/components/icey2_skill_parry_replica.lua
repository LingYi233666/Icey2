local Icey2SkillParry = Class(function(self, inst)
    self.inst = inst

    self._is_parrying = net_bool(inst.GUID, "Icey2SkillParry._is_parrying", "Icey2SkillParry._is_parrying")

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("Icey2SkillParry._is_parrying", function()
            if self:IsParrying() and not self.task then
                self.task = inst:DoPeriodicTask(0, function()
                    inst:ForceFacePoint(TheInput:GetWorldPosition())
                end)
            elseif not self:IsParrying() and self.task then
                self.task:Cancel()
                self.task = nil
            end
        end)
    end
end)

function Icey2SkillParry:SetIsParrying(val)
    self._is_parrying:set(val)
end

function Icey2SkillParry:IsParrying()
    return self._is_parrying:value()
end

return Icey2SkillParry
