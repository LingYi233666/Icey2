local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local easing = require("easing")

local Icey2SoulAbsorbAnim = Class(Widget, function(self)
    Widget._ctor(self, "Icey2SoulAbsorbAnim")

    self.rgba_start = { 0, 0, 0, 0 }
    self.rgba_mid = { 1, 0, 0, 1 }
    self.rgba_end = { 0, 0, 0, 0 }


    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank("icey2_soul_absorb_fx")
    self.anim:GetAnimState():SetBuild("icey2_soul_absorb_fx")
    self.anim:GetAnimState():PlayAnimation("idle")
    self.anim:GetAnimState():SetDeltaTimeMultiplier(1 / 0.7)
    self.anim:GetAnimState():SetMultColour(unpack(self.rgba_start))
end)

function Icey2SoulAbsorbAnim:FadeInOut(in_duration, out_duration)
    in_duration = in_duration or 0.2
    out_duration = out_duration or 0.5

    self.in_duration = in_duration
    self.out_duration = out_duration
    self.start_time = GetTime()

    self:StartUpdating()
end

function Icey2SoulAbsorbAnim:OnUpdate()
    local cur_time = GetTime() - self.start_time
    local rgba_1, rgba_2, t, duration
    if cur_time < self.in_duration then
        rgba_1 = self.rgba_start
        rgba_2 = self.rgba_mid
        t = cur_time
        duration = self.in_duration
    elseif cur_time < self.out_duration then
        rgba_1 = self.rgba_mid
        rgba_2 = self.rgba_end
        t = cur_time - self.in_duration
        duration = self.out_duration - self.in_duration
    else
        self:Kill()
        return
    end

    local r = easing.linear(t, rgba_1[1], rgba_2[1] - rgba_1[1], duration)
    local g = easing.linear(t, rgba_1[2], rgba_2[2] - rgba_1[2], duration)
    local b = easing.linear(t, rgba_1[3], rgba_2[3] - rgba_1[3], duration)
    local a = easing.linear(t, rgba_1[4], rgba_2[4] - rgba_1[4], duration)

    self.anim:GetAnimState():SetMultColour(r, g, b, a)
end

return Icey2SoulAbsorbAnim
