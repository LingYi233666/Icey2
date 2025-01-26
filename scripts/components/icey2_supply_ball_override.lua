local Icey2SupplyBallOverride = Class(function(self, inst)
    self.inst = inst

    self.getdatafn = nil
end)

function Icey2SupplyBallOverride:GetData(player, target, addition)
    return self.getdatafn and self.getdatafn(self.inst, player, target, addition) or {}
end

return Icey2SupplyBallOverride
