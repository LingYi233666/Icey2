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


    -- Init chips
    self.chips = {}
    self.num_chips = 0
    self.max_num_chips = 0

    local chip_x = -8
    local chip_y = -35
    local y_delta = 25
    for i = 1, 5 do
        local chip = self:AddChild(UIAnim())
        chip:GetAnimState():SetBank("status_wx")
        chip:GetAnimState():SetBuild("status_wx")
        chip:GetAnimState():PlayAnimation("chip_idle")
        chip:SetPosition(chip_x, chip_y)
        chip:SetScale(0.6)
        chip:MoveToBack()
        chip_y = chip_y + y_delta

        table.insert(self.chips, chip)
    end

    self.inst:DoTaskInTime(1, function()
        local cmp_dodge = self.owner.replica.icey2_skill_dodge
        self:SetMaxNumChips(cmp_dodge:GetMaxCharge())
        self:SetNumChips(cmp_dodge:GetCharge())
    end)

    self.inst:ListenForEvent("Icey2SkillDodge._dodge_charge", function()
        local cmp_dodge = self.owner.replica.icey2_skill_dodge
        self:SetNumChips(math.floor(cmp_dodge:GetCharge()))
    end, self.owner)


    self.inst:ListenForEvent("Icey2SkillDodge._max_dodge_charge", function()
        local cmp_dodge = self.owner.replica.icey2_skill_dodge
        self:SetMaxNumChips(cmp_dodge:GetMaxCharge())
    end, self.owner)



    self:StartUpdating()
end)



function Icey2SkillShieldMetrics:PushChargeShield()
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
    spark:SetClickable(false)


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
    self.bg:SetTooltip(STRINGS.ICEY2_UI.SHIELD_METRICS.TIP:format(cur_value, max_value))
end

function Icey2SkillShieldMetrics:SetNumChips(val)
    self.num_chips = val
    for i = 1, #self.chips do
        if i <= val then
            self.chips[i]:GetAnimState():Show("plug_on")
        else
            self.chips[i]:GetAnimState():Hide("plug_on")
        end

        self.chips[i]:SetTooltip(STRINGS.ICEY2_UI.SHIELD_METRICS.DODGE_CHARGE:format(self.num_chips, self.max_num_chips))
    end
end

function Icey2SkillShieldMetrics:SetMaxNumChips(val)
    local is_init = (self.max_num_chips == 0)
    local should_play_sound = false
    self.max_num_chips = val
    for i = 1, #self.chips do
        if i <= val then
            if not is_init and not self.chips[i].shown then
                self.chips[i]:GetAnimState():PlayAnimation("plug")
                self.chips[i]:GetAnimState():PushAnimation("chip_idle", false)
                should_play_sound = true
            end
            self.chips[i]:Show()
        else
            self.chips[i]:Hide()
        end

        self.chips[i]:SetTooltip(STRINGS.ICEY2_UI.SHIELD_METRICS.DODGE_CHARGE:format(self.num_chips, self.max_num_chips))
    end

    if should_play_sound then
        -- self.inst:DoTaskInTime(10 * FRAMES, function()
        TheFocalPoint.SoundEmitter:PlaySound("icey2_sfx/hud/install_dodge_charge_chip", nil, 0.8)
        -- end)
    end
end

function Icey2SkillShieldMetrics:PlayChipInstallAnim()
    local chip = self.chips[self.max_num_chips]
    chip:GetAnimState():PlayAnimation("plug")
    chip:GetAnimState():PushAnimation("chip_idle", false)

    chip.inst:DoTaskInTime(10 * FRAMES, function()
        TheFocalPoint.SoundEmitter:PlaySound("icey2_sfx/hud/install_dodge_charge_chip")
    end)
end

function Icey2SkillShieldMetrics:OnUpdate(dt)
    local cmp_shield = self.owner.replica.icey2_skill_shield

    self:SetMetrics(cmp_shield:GetCurrent(), cmp_shield:GetMax())
end

return Icey2SkillShieldMetrics
