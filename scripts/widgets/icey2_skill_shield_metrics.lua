local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local Icey2SkillShieldMetrics = Class(Widget, function(self, owner)
    Widget._ctor(self, "Icey2SkillShieldMetrics")

    self.owner = owner

    self.bg2 = self:AddChild(UIAnim())
    self.bg2:GetAnimState():SetBank("icey2_skill_shield_metrics")
    self.bg2:GetAnimState():SetBuild("icey2_skill_shield_metrics")
    self.bg2:GetAnimState():PlayAnimation("bg2")
    self.bg2:SetScale(0.55)

    self.bar = self:AddChild(UIAnim())
    self.bar:GetAnimState():SetBank("icey2_skill_shield_metrics")
    self.bar:GetAnimState():SetBuild("icey2_skill_shield_metrics")
    self.bar:SetPosition(0, -2)
    self.bar:SetScale(0.5)

    self.charge_cover = self:AddChild(UIAnim())
    self.charge_cover:GetAnimState():SetBank("icey2_shield_charge_cover")
    self.charge_cover:GetAnimState():SetBuild("icey2_shield_charge_cover")
    self.charge_cover:GetAnimState():PlayAnimation("idle", true)
    self.charge_cover:GetAnimState():SetDeltaTimeMultiplier(4)
    self.charge_cover:GetAnimState():SetMultColour(0, 0, 0, 0)
    self.charge_cover:GetAnimState():SetAddColour(100 / 255, 100 / 255, 100 / 255, 1)
    self.charge_cover:SetScissor(-32, -50, 64, 100)
    self.charge_cover:SetClickable(false)

    self.bg = self:AddChild(UIAnim())
    self.bg:GetAnimState():SetBank("icey2_skill_shield_metrics")
    self.bg:GetAnimState():SetBuild("icey2_skill_shield_metrics")
    self.bg:GetAnimState():PlayAnimation("bg3")
    self.bg:SetScale(0.5)





    -- self.inst:ListenForEvent("isghostmodedirty", function()
    --     print("isghostmodedirty", owner.player_classified.isghostmode:value())
    --     if owner.player_classified and owner.player_classified.isghostmode:value() then
    --         self:Hide()
    --     else
    --         self:Show()
    --     end
    -- end, owner)

    -- self.inst:DoP

    self:StartUpdating()
end)

local function RGBA(r, g, b, a)
    return { r = r, g = g, b = b, a = a, }
end

function Icey2SkillShieldMetrics:PushCharge()
    -- TheFocalPoint.SoundEmitter:PlaySound("icey2_bgm/bgm/icey1_mound")
    -- local r, g, b, a = self.charge_cover:GetAnimState():GetMultColour()
    -- -- self.charge_cover:GetAnimState():SetMultColour(1, 1, 1, 1)


    -- self.charge_cover:CancelTintTo()
    -- self.charge_cover:TintTo(RGBA(r, g, b, a), RGBA(1, 1, 1, 1), 0.1, function()
    --     self.charge_cover:TintTo(RGBA(1, 1, 1, 1), RGBA(1, 1, 1, 1), 1,function ()
    --         self.charge_cover:TintTo(RGBA(r, g, b, a), RGBA(1, 1, 1, 1), 1)
    --     end)
    -- end)




    -- self.charge_cover:CancelTintTo()
    -- if self.cancel_charge_task then
    --     self.cancel_charge_task:Cancel()
    --     self.cancel_charge_task = nil
    -- end


    -- self.charge_cover:GetAnimState():SetMultColour(1, 1, 1, 1)
    -- self.cancel_charge_task = self.inst:DoTaskInTime(0.5, function()
    --     self.charge_cover:TintTo(RGBA(1, 1, 1, 1), RGBA(0, 0, 0, 0), 0.5)
    --     self.cancel_charge_task = nil
    -- end)

    TheFocalPoint.SoundEmitter:PlaySound("icey2_sfx/hud/shield_charge")
    self.charge_cover:GetAnimState():SetMultColour(1, 1, 1, 1)


    if self.charge_color_change_task then
        self.charge_color_change_task:Cancel()
        self.charge_color_change_task = nil
    end

    if self.cancel_charge_task then
        self.cancel_charge_task:Cancel()
        self.cancel_charge_task = nil
    end


    self.cancel_charge_task = self.inst:DoTaskInTime(0.7, function()
        self.cancel_charge_task = nil

        self.charge_color_change_task = self.inst:DoPeriodicTask(0, function()
            local speed = 1
            local r, _, _, _ = self.charge_cover:GetAnimState():GetMultColour()

            r = math.max(0, r - speed * FRAMES)

            self.charge_cover:GetAnimState():SetMultColour(r, r, r, r)

            if r <= 0 then
                self.charge_color_change_task:Cancel()
                self.charge_color_change_task = nil
            end
        end)
    end)

    self:EmitSparks(0.6, 0.05)
end

function Icey2SkillShieldMetrics:EmitSpark()
    local x = GetRandomMinMax(-20, 20)
    local y = GetRandomMinMax(-80, 80)

    local spark = self:AddChild(UIAnim())
    spark:GetAnimState():SetBank("icey2_skill_shield_metrics")
    spark:GetAnimState():SetBuild("icey2_skill_shield_metrics")
    -- spark:GetAnimState():PlayAnimation("spark_small")
    spark:GetAnimState():PlayAnimation("spark")
    spark:GetAnimState():SetMultColour(150 / 255, 250 / 255, 250 / 255, 1)
    spark:SetPosition(x, y)

    local live_time = 0.67
    local start_fadeout_time = 0.33

    local start_deg = math.random() * 360
    local end_deg = start_deg + 40 * (math.random() > 0.5 and 1 or -1)
    spark:RotateTo(start_deg, end_deg, live_time)

    local start_scale = 0.01
    local end_scale = 0.4
    -- local start_scale = 0.01
    -- local end_scale = 1
    spark:SetScale(start_scale)
    spark:ScaleTo(start_scale, end_scale, live_time)

    spark.inst:DoTaskInTime(start_fadeout_time, function()
        local time_for_fadeout = live_time - start_fadeout_time
        spark.inst:DoPeriodicTask(0, function()
            local speed = 1 / time_for_fadeout
            local r, g, b, a = spark:GetAnimState():GetMultColour()

            a = math.max(0, a - speed * FRAMES)

            spark:GetAnimState():SetMultColour(r, g, b, a)
        end)
    end)



    spark.inst:DoTaskInTime(live_time, function()
        spark:Kill()
    end)
end

function Icey2SkillShieldMetrics:EmitSparks(duration, period)
    if self.emit_spark_task then
        self.emit_spark_task:Cancel()
    end
    if self.cancel_emit_spark_task then
        self.cancel_emit_spark_task:Cancel()
    end

    self:EmitSpark()
    self.emit_spark_task = self.inst:DoPeriodicTask(period, function()
        self:EmitSpark()
    end)

    self.cancel_emit_spark_task = self.inst:DoTaskInTime(duration, function()
        if self.emit_spark_task then
            self.emit_spark_task:Cancel()
            self.emit_spark_task = nil
        end
        self.cancel_emit_spark_task = nil
    end)
end

function Icey2SkillShieldMetrics:SetMetrics(cur_value, max_value)
    self.bar:GetAnimState():SetPercent("bar", cur_value / max_value)

    self.bar:SetTooltip(STRINGS.ICEY2_UI.SHIELD_METRICS.TIP:format(cur_value, max_value))
end

function Icey2SkillShieldMetrics:OnUpdate(dt)
    local cmp = self.owner.replica.icey2_skill_shield
    self:SetMetrics(cmp:GetCurrent(), cmp:GetMax())


    -- Tint speed

    -- if self.target_charge_cover_rgba ~= nil then
    --     local speed = 1

    --     local r, g, b, a = self.charge_cover:GetAnimState():GetMultColour()
    --     local target_r, target_g, target_b, target_a = unpack(self.target_charge_cover_rgba)

    --     local delta_r = (target_r - r) * dt * speed
    --     local delta_g = (target_g - g) * dt * speed
    --     local delta_b = (target_b - b) * dt * speed
    --     local delta_a = (target_a - a) * dt * speed

    --     self.charge_cover:GetAnimState():SetMultColour(r + delta_r, g + delta_g, b + delta_b, a + delta_a)

    --     if math.abs(delta_r) < 1e-6
    --         and math.abs(delta_g) < 1e-6
    --         and math.abs(delta_b) < 1e-6
    --         and math.abs(delta_a) < 1e-6 then
    --         self.charge_cover:GetAnimState():SetMultColour(delta_r, delta_g, delta_b, delta_a)

    --         self.target_charge_cover_rgba = nil
    --     end
    -- end
end

return Icey2SkillShieldMetrics
