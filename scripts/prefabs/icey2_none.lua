local assets =
{
	Asset("ANIM", "anim/icey2.zip"),
	Asset("ANIM", "anim/ghost_icey2_build.zip"),
}

local skins =
{
	normal_skin = "icey2",
	ghost_skin = "ghost_icey2_build",
}

local base_prefab = "icey2"

local tags = { "BASE", "ICEY2", "CHARACTER" }

return CreatePrefabSkin("icey2_none",
						{
							base_prefab = base_prefab,
							skins = skins,
							assets = assets,
							skin_tags = tags,

							build_name_override = "icey2",
							rarity = "Character",
						})
