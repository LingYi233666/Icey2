local Widget = require "widgets/widget"
local Icey2SoulAbsorbAnim = require "widgets/icey2_soul_absorb_anim"



local Icey2SoulAbsorbCircle = Class(Widget, function(self)
    Widget._ctor(self, "Icey2SoulAbsorbCircle")

    self.radius = 100

    self.radius_final = 10


    self.rotate_speed = 180
end)

function Icey2SoulAbsorbCircle:Start(duration)
    duration = duration or 3.5

    self:Stop()

    self.cur_degree = self.cur_degree or math.random() * 360
    TheFocalPoint.SoundEmitter:PlaySound("icey2_sfx/hud/absorb_souls_3s", "absorb_souls_3s")

    self.emit_task = self.inst:DoPeriodicTask(0, function()
        -- Icey2SoulAbsorbCircle
        local px = math.cos(self.cur_degree * DEGREES) * self.radius
        local py = math.sin(self.cur_degree * DEGREES) * self.radius

        local px2 = math.cos(self.cur_degree * DEGREES) * self.radius_final
        local py2 = math.sin(self.cur_degree * DEGREES) * self.radius_final

        px = px + GetRandomMinMax(-33, 33)
        py = py + GetRandomMinMax(-33, 33)


        px2 = px2 + GetRandomMinMax(-15, 15)
        py2 = py2 + GetRandomMinMax(-15, 15)


        local fx = self:AddChild(Icey2SoulAbsorbAnim())
        fx:SetPosition(px, py)
        fx:FadeInOut()

        fx:ScaleTo(1, 0.4, 0.7)
        fx:MoveTo(Vector3(px, py, 0), Vector3(px2, py2, 0), 0.7)

        self.cur_degree = self.cur_degree + FRAMES * self.rotate_speed
    end)

    self.cancel_task = self.inst:DoTaskInTime(duration, function()
        self:Stop()
    end)
end

function Icey2SoulAbsorbCircle:Stop()
    if self.emit_task then
        self.emit_task:Cancel()
        self.emit_task = nil
    end

    if self.cancel_task then
        self.cancel_task:Cancel()
        self.cancel_task = nil
    end

    TheFocalPoint.SoundEmitter:KillSound("absorb_souls_3s")
end

return Icey2SoulAbsorbCircle
