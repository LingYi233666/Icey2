local AOEWeapon_Base = require("components/aoeweapon_base")

local Icey2AOEWeapon_ThrowScythe = Class(AOEWeapon_Base, function(self, inst)
    AOEWeapon_Base._ctor(self, inst)

    self:SetTags("_combat")
    self:SetWorkActions()

    inst:AddTag("icey2_aoeweapon")
end)

-- function Icey2AOEWeapon_ThrowScythe:HarvestPickable(ent)
--     if ent.components.pickable.picksound ~= nil then
--         self.inst.SoundEmitter:PlaySound(ent.components.pickable.picksound)
--     end

--     local success, loot = ent.components.pickable:Pick(TheWorld)

--     if loot ~= nil then
--         for i, item in ipairs(loot) do
--             Launch(item, self.inst, 1.5)
--         end
--     end
-- end

function Icey2AOEWeapon_ThrowScythe:Launch(attacker, target_pos)

end

return Icey2AOEWeapon_ThrowScythe
