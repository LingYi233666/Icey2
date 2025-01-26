local function oncur_form(self, val)
    self.inst.replica.icey2_versatile_weapon:SetCurForm(val)
end

local Icey2VersatileWeapon = Class(function(self, inst)
    self.inst = inst

    self.num_forms = 2
    self.cur_form = 1

    self.onformchange = nil
end, nil, {
    cur_form = oncur_form,
})

function Icey2VersatileWeapon:GetCurForm()
    return self.cur_form
end

function Icey2VersatileWeapon:SetNumForms(num)
    self.num_forms = num
end

function Icey2VersatileWeapon:SwitchForm(new_form, on_load)
    if new_form == nil then
        new_form = self.cur_form + 1
        if new_form > self.num_forms then
            new_form = 1
        end
    end

    new_form = math.clamp(new_form, 1, self.num_forms)
    local old_form = self.cur_form


    self.cur_form = new_form

    if self.onformchange then
        self.onformchange(self.inst, old_form, new_form, on_load)
    end
end

function Icey2VersatileWeapon:OnSave()
    return {
        cur_form = self.cur_form
    }
end

function Icey2VersatileWeapon:OnLoad(data)
    if data ~= nil then
        if data.cur_form ~= nil then
            self:SwitchForm(data.cur_form, true)
        end
    end
end

return Icey2VersatileWeapon
