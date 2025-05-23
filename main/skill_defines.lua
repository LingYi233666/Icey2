local function CastSkillByComponent(cmp_name, inst, x, y, z, ent)
    local cmp = inst.components[cmp_name]

    if cmp then
        local can_cast, reason = cmp:CanCast(x, y, z, ent)

        if can_cast then
            cmp:Cast(x, y, z, ent)
        else
            print(cmp_name .. " cast failed, reason: " .. tostring(reason))
        end
    end
end

local function CastSkillByComponentWrapper(cmp_name)
    local function fn(inst, x, y, z, ent)
        CastSkillByComponent(cmp_name, inst, x, y, z, ent)
    end

    return fn
end

local function PassiveSkillOnLearnedWrapper(cmp_name)
    local function fn(inst, is_onload)
        -- if is_onload then
        --     return
        -- end

        local cmp = inst.components[cmp_name]

        if cmp then
            cmp:Enable()
        end
    end

    return fn
end

local function PassiveSkillOnForgetWrapper(cmp_name)
    local function fn(inst)
        local cmp = inst.components[cmp_name]

        if cmp then
            cmp:Disable()
        end
    end

    return fn
end

local function SkillIngredient(name)
    -- if not string.starts(name, "icey2_skill_builder_") then
    --     name = "icey2_skill_builder_" .. name
    -- end

    local name2 = "icey2_skill_builder_" .. name
    return Ingredient(name2, 0, "images/inventoryimages/" .. name2 .. ".xml")
end

local function AllLinkedWeaponsCheckSkill(inst)
    for _, v in pairs(inst.components.icey2_skill_summon_pact_weapon:GetLinkedWeapons()) do
        if v.components.icey2_upgradable then
            v.components.icey2_upgradable:CheckSkill(inst)
        end
    end
end

ICEY2_SKILL_DEFINES = {
    {
        Name = "hunger_is_electricity",
        Root = true,
    },

    {
        Name = "force_shield",
        OnLearned = PassiveSkillOnLearnedWrapper("icey2_skill_shield"),

        OnForget = PassiveSkillOnForgetWrapper("icey2_skill_shield"),

        Root = true,
    },

    {
        Name = "dodge",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        OnPressed = CastSkillByComponentWrapper("icey2_skill_dodge"),

        Root = true,
    },

    {
        Name = "phantom_sword",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        OnPressed = CastSkillByComponentWrapper("icey2_skill_phantom_sword"),

        Ingredients = { Ingredient("flint", 5), },
    },

    {
        Name = "battle_focus",
        OnLearned = PassiveSkillOnLearnedWrapper("icey2_skill_battle_focus"),

        OnForget = PassiveSkillOnForgetWrapper("icey2_skill_battle_focus"),


        Ingredients = { Ingredient("bluegem", 1), },
        Tech = TECH.SCIENCE_TWO,
    },


    {
        Name = "parry",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        OnPressed = function(inst, x, y, z, ent)
            local can_cast, reason = inst.components.icey2_skill_parry:CanStartParry(x, y, z, ent)

            if can_cast then
                inst.components.icey2_skill_parry:StartParry()
            else
                -- print("icey2_skill_parry start parry failed, reason: " .. tostring(reason))
            end
        end,

        OnReleased = function(inst, x, y, z, ent)
            local can_cast, reason = inst.components.icey2_skill_parry:CanStopParry(x, y, z, ent)

            if can_cast then
                inst.components.icey2_skill_parry:StopParry()
            else
                -- print("icey2_skill_parry stop parry failed, reason: " .. tostring(reason))
            end
        end,

        Ingredients = {
            Ingredient("boards", 2), Ingredient("rope", 1), Ingredient(CHARACTER_INGREDIENT.SANITY, 50)
        },
        Tech = TECH.SCIENCE_ONE,

    },

    {
        Name = "summon_pact_weapon",
        OnLearned = function(inst, is_onload) end,

        OnForget = function(inst) end,

        OnPressed_Client = function(inst)
            if inst.replica.icey2_skill_summon_pact_weapon.call_cd == nil
                or GetTime() - inst.replica.icey2_skill_summon_pact_weapon.call_cd > 0.1 then
                inst.replica.icey2_skill_summon_pact_weapon:ShowPactWeaponsWheel()
                inst.replica.icey2_skill_summon_pact_weapon.call_cd = GetTime()
            end
        end,

        -- DescFn = function(inst)
        --     return STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC.SUMMON_PACT_WEAPON.DESC ..
        --         "\n\n" .. STRINGS.ICEY2_UI.SKILL_TAB.SKILL_DESC.SUMMON_PACT_WEAPON.DESC_TIP_MORE_WEAPON
        -- end,

        Root = true,
    },

    {
        Name = "upgrade_pact_weapon_rapier_1",
        OnLearned = function(inst, is_onload)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        OnForget = function(inst)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        Ingredients = {
            SkillIngredient("summon_pact_weapon"),
            Ingredient("icey2_blood_metal", 3, "images/inventoryimages/icey2_blood_metal.xml"),
        },
    },

    {
        Name = "upgrade_pact_weapon_rapier_2",
        OnLearned = function(inst, is_onload)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        OnForget = function(inst)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        Ingredients = {
            SkillIngredient("upgrade_pact_weapon_rapier_1"),
            Ingredient("icey2_blood_metal", 5, "images/inventoryimages/icey2_blood_metal.xml"),
        },
    },

    {
        Name = "upgrade_pact_weapon_rapier_3",
        OnLearned = function(inst, is_onload)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        OnForget = function(inst)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        Ingredients = {
            SkillIngredient("upgrade_pact_weapon_rapier_2"),
            Ingredient("icey2_blood_metal", 7, "images/inventoryimages/icey2_blood_metal.xml"),
        },
    },

    {
        Name = "new_pact_weapon_scythe",
        OnLearned = function(inst, is_onload)
            inst.components.icey2_skill_summon_pact_weapon:AddWeaponPrefab("icey2_pact_weapon_scythe")
        end,

        OnForget = function(inst)
            inst.components.icey2_skill_summon_pact_weapon:RemoveWeaponPrefab("icey2_pact_weapon_scythe")
        end,

        Ingredients = {
            Ingredient("flint", 6),
            Ingredient("twigs", 3),
            Ingredient(CHARACTER_INGREDIENT.SANITY, 50)
        },
        Tech = TECH.SCIENCE_TWO,
    },

    {
        Name = "upgrade_pact_weapon_scythe_1",
        OnLearned = function(inst, is_onload)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        OnForget = function(inst)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        Ingredients = {
            SkillIngredient("new_pact_weapon_scythe"),
            Ingredient("icey2_blood_metal", 3, "images/inventoryimages/icey2_blood_metal.xml"),
        },
        Tech = TECH.SCIENCE_TWO,
    },

    {
        Name = "upgrade_pact_weapon_scythe_2",
        OnLearned = function(inst, is_onload)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        OnForget = function(inst)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        Ingredients = {
            SkillIngredient("upgrade_pact_weapon_scythe_1"),
            Ingredient("icey2_blood_metal", 5, "images/inventoryimages/icey2_blood_metal.xml"),
        },
        Tech = TECH.SCIENCE_TWO,
    },

    {
        Name = "upgrade_pact_weapon_scythe_3",
        OnLearned = function(inst, is_onload)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        OnForget = function(inst)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        Ingredients = {
            SkillIngredient("upgrade_pact_weapon_scythe_2"),
            Ingredient("icey2_blood_metal", 7, "images/inventoryimages/icey2_blood_metal.xml"),
        },
        Tech = TECH.SCIENCE_TWO,
    },


    {
        Name = "new_pact_weapon_gunlance",
        OnLearned = function(inst, is_onload)
            inst.components.icey2_skill_summon_pact_weapon:AddWeaponPrefab("icey2_pact_weapon_gunlance")
        end,

        OnForget = function(inst)
            inst.components.icey2_skill_summon_pact_weapon:RemoveWeaponPrefab("icey2_pact_weapon_gunlance")
        end,

        Ingredients = {
            Ingredient("blowdart_pipe", 6),
            Ingredient("transistor", 2),
            Ingredient(CHARACTER_INGREDIENT.SANITY, 50)
        },
        Tech = TECH.MAGIC_TWO,
    },

    {
        Name = "upgrade_pact_weapon_gunlance_1",
        OnLearned = function(inst, is_onload)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        OnForget = function(inst)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        Ingredients = {
            SkillIngredient("new_pact_weapon_gunlance"),
            Ingredient("icey2_blood_metal", 3, "images/inventoryimages/icey2_blood_metal.xml"),
        },
        Tech = TECH.MAGIC_TWO,
    },

    {
        Name = "upgrade_pact_weapon_gunlance_2",
        OnLearned = function(inst, is_onload)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        OnForget = function(inst)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        Ingredients = {
            SkillIngredient("upgrade_pact_weapon_gunlance_1"),
            Ingredient("icey2_blood_metal", 5, "images/inventoryimages/icey2_blood_metal.xml"),
        },
        Tech = TECH.MAGIC_TWO,
    },

    {
        Name = "upgrade_pact_weapon_gunlance_3",
        OnLearned = function(inst, is_onload)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        OnForget = function(inst)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        Ingredients = {
            SkillIngredient("upgrade_pact_weapon_gunlance_2"),
            Ingredient("icey2_blood_metal", 7, "images/inventoryimages/icey2_blood_metal.xml"),
        },
        Tech = TECH.MAGIC_TWO,
    },

    {
        Name = "new_pact_weapon_chainsaw",
        OnLearned = function(inst, is_onload)
            inst.components.icey2_skill_summon_pact_weapon:AddWeaponPrefab("icey2_pact_weapon_chainsaw")
        end,

        OnForget = function(inst)
            inst.components.icey2_skill_summon_pact_weapon:RemoveWeaponPrefab("icey2_pact_weapon_chainsaw")
        end,

        Ingredients = {
            Ingredient("wagpunk_bits", 4),
            Ingredient("flint", 4),
            Ingredient(CHARACTER_INGREDIENT.SANITY, 50)
        },
        Tech = TECH.MAGIC_THREE,
    },

    {
        Name = "upgrade_pact_weapon_chainsaw_1",
        OnLearned = function(inst, is_onload)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        OnForget = function(inst)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        Ingredients = {
            SkillIngredient("new_pact_weapon_chainsaw"),
            Ingredient("icey2_blood_metal", 3, "images/inventoryimages/icey2_blood_metal.xml"),
        },
        Tech = TECH.MAGIC_THREE,
    },

    {
        Name = "upgrade_pact_weapon_chainsaw_2",
        OnLearned = function(inst, is_onload)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        OnForget = function(inst)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        Ingredients = {
            SkillIngredient("upgrade_pact_weapon_chainsaw_1"),
            Ingredient("icey2_blood_metal", 5, "images/inventoryimages/icey2_blood_metal.xml"),
        },
        Tech = TECH.MAGIC_THREE,
    },

    {
        Name = "upgrade_pact_weapon_chainsaw_3",
        OnLearned = function(inst, is_onload)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        OnForget = function(inst)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        Ingredients = {
            SkillIngredient("upgrade_pact_weapon_chainsaw_2"),
            Ingredient("icey2_blood_metal", 7, "images/inventoryimages/icey2_blood_metal.xml"),
        },
        Tech = TECH.MAGIC_THREE,
    },

    {
        Name = "new_pact_weapon_hammer",
        OnLearned = function(inst, is_onload)
            inst.components.icey2_skill_summon_pact_weapon:AddWeaponPrefab("icey2_pact_weapon_hammer")
        end,

        OnForget = function(inst)
            inst.components.icey2_skill_summon_pact_weapon:RemoveWeaponPrefab("icey2_pact_weapon_hammer")
        end,

        Ingredients = {
            Ingredient("wagpunk_bits", 4),
            Ingredient("hammer", 1),
            Ingredient(CHARACTER_INGREDIENT.SANITY, 50)
        },
        Tech = TECH.MAGIC_THREE,
    },

    {
        Name = "upgrade_pact_weapon_hammer_1",
        OnLearned = function(inst, is_onload)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        OnForget = function(inst)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        Ingredients = {
            SkillIngredient("new_pact_weapon_hammer"),
            Ingredient("icey2_blood_metal", 3, "images/inventoryimages/icey2_blood_metal.xml"),
        },
        Tech = TECH.MAGIC_THREE,
    },

    {
        Name = "upgrade_pact_weapon_hammer_2",
        OnLearned = function(inst, is_onload)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        OnForget = function(inst)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        Ingredients = {
            SkillIngredient("upgrade_pact_weapon_hammer_1"),
            Ingredient("icey2_blood_metal", 5, "images/inventoryimages/icey2_blood_metal.xml"),
        },
        Tech = TECH.MAGIC_THREE,
    },

    {
        Name = "upgrade_pact_weapon_hammer_3",
        OnLearned = function(inst, is_onload)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        OnForget = function(inst)
            AllLinkedWeaponsCheckSkill(inst)
        end,

        Ingredients = {
            SkillIngredient("upgrade_pact_weapon_hammer_2"),
            Ingredient("icey2_blood_metal", 7, "images/inventoryimages/icey2_blood_metal.xml"),
        },
        Tech = TECH.MAGIC_THREE,
    },
}

-- Check if has duplicate skill names
local exists_skill_names = {}
for _, data in pairs(ICEY2_SKILL_DEFINES) do
    assert(exists_skill_names[data.Name] ~= true)

    exists_skill_names[data.Name] = true
end

GLOBAL.ICEY2_SKILL_DEFINES = ICEY2_SKILL_DEFINES
