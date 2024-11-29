local Icey2Scythe = Class(function(self, inst)
    self.inst = inst
    self.do_scythe_fn = nil
end)

function Icey2Scythe:SetDoScytheFn(fn)
    self.do_scythe_fn = fn
end

function Icey2Scythe:DoScythe(doer, target)
    if self.do_scythe_fn then
        return self.do_scythe_fn(self.inst, doer, target)
    end
end

return Icey2Scythe
