local assets =
{
    Asset("ANIM", "anim/cave_exit_lightsource.zip"),
}

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("grotto/common/chandelier_LP", "loop")
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local light_params =
{
    day =
    {
        radius = 5,
        intensity = .85,
        falloff = .3,
        colour = { 180 / 255, 195 / 255, 150 / 255 },
        time = 2,
    },

    dusk =
    {
        radius = 5,
        intensity = .6,
        falloff = .6,
        colour = { 91 / 255, 164 / 255, 255 / 255 },
        time = 4,
    },

    night =
    {
        radius = 0,
        intensity = 0,
        falloff = 1,
        colour = { 0, 0, 0 },
        time = 6,
    },

    fullmoon =
    {
        radius = 5,
        intensity = .6,
        falloff = .6,
        colour = { 131 / 255, 194 / 255, 255 / 255 },
        time = 4,
    },
}


local function common_fn(widthscale)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("cavelight")
    inst.AnimState:SetBuild("cave_exit_lightsource")
    inst.AnimState:PlayAnimation("idle_loop", false) -- the looping is annoying
    inst.AnimState:SetLightOverride(1)

    inst.Transform:SetScale(2 * widthscale, 2, 2 * widthscale) -- Art is made small coz of flash weirdness, the giant stage was exporting strangely

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst:AddTag("daylight")

    local params = light_params.day
    inst.Light:SetRadius(params.radius * widthscale)
    inst.Light:SetIntensity(params.intensity)
    inst.Light:SetFalloff(params.falloff)
    inst.Light:SetColour(unpack(params.colour))
    inst.Light:Enable(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    return inst
end

local function normalfn()
    return common_fn(1)
end

local function smallfn()
    return common_fn(.5)
end

local function tinyfn()
    return common_fn(.2)
end


return Prefab("icey1_graveyard_light", normalfn, assets),
    Prefab("icey1_graveyard_light_small", smallfn, assets),
    Prefab("icey1_graveyard_light_tiny", tinyfn, assets)
