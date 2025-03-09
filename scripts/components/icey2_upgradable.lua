local Icey2Upgradable = Class(function(self, inst)
    self.inst = inst

    self.level = 0
    self.applyfn = nil
    self.skill_tab = nil
    self.owner = nil

    self._listen_owner = function()
        self:CheckSkill()
    end

    inst:ListenForEvent("onputininventory", function(_, owner)
        self:ListenForOwner(owner)
        self:CheckSkill()
    end)

    inst:ListenForEvent("ondropped", function(_)
        self:UnListenForOwner()
    end)
end)

function Icey2Upgradable:ListenForOwner(owner)
    self:UnListenForOwner()

    self.owner = owner
    self.inst:ListenForEvent("icey2_skill_learned", self._listen_owner, owner)
    self.inst:ListenForEvent("icey2_skill_forgot", self._listen_owner, owner)
end

function Icey2Upgradable:UnListenForOwner()
    if not self.owner then
        return
    end

    self.inst:RemoveEventCallback("icey2_skill_learned", self._listen_owner, self.owner)
    self.inst:RemoveEventCallback("icey2_skill_forgot", self._listen_owner, self.owner)
    self.owner = nil
end

function Icey2Upgradable:SetApplyFn(fn)
    self.applyfn = fn
end

-- function Icey2Upgradable:SetCheckSkillFn(fn)
--     self.checkskillfn = fn
-- end

function Icey2Upgradable:SetSkillTab(tab)
    self.skill_tab = tab
end

function Icey2Upgradable:GetLevel()
    return self.level
end

function Icey2Upgradable:SetLevel(lvl)
    local old_lvl = self.level
    self.level = lvl

    self:ApplyLevel(old_lvl)
end

function Icey2Upgradable:ApplyLevel(old_lvl)
    if self.applyfn then
        self.applyfn(self.inst, self.level, old_lvl)
    end
end

function Icey2Upgradable:CheckSkill(owner_override)
    owner_override = owner_override or self.owner
    if not self.skill_tab or not owner_override then
        return
    end

    local skiller = owner_override.components.icey2_skiller

    local level = 0
    if skiller then
        for name, lvl in pairs(self.skill_tab) do
            if skiller:IsLearned(name) then
                level = math.max(level, lvl)
            end
        end
    end

    -- print("check level", level)

    self:SetLevel(level)
end

return Icey2Upgradable
