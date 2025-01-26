local Icey2VersatileWeapon = Class(function(self, inst)
    self.inst = inst

    self._cur_form = net_tinybyte(inst.GUID, "Icey2VersatileWeapon._cur_form")
end)

function Icey2VersatileWeapon:SetCurForm(val)
    self._cur_form:set(val)
end

function Icey2VersatileWeapon:GetCurForm()
    return self._cur_form:value()
end

return Icey2VersatileWeapon
