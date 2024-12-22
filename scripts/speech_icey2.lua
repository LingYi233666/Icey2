--[[
	--- This is Wilson's speech file for Don't Starve Together ---
	Write your character's lines here.
	If you want to use another speech file as a base, or use a more up-to-date version, get them from data\scripts\
	
	If you want to use quotation marks in a quote, put a \ before it.
	Example:
	"Like \"this\"."
]]

local MODIFIED_SPEECH = {
	-- 战吼
	BATTLECRY =
	{
		-- GENERIC = "我不怕任何敌人！",
		-- PIG = "今晚吃五花肉！",
		-- PREY = "午餐别跑！",
		-- SPIDER = "蜘蛛，尝尝我的利刃！",
		-- SPIDER_WARRIOR = "战斗吧！",
		GENERIC = "",
	},

	-- 检查
	DESCRIBE = {
		BUSHHAT = "不如纸箱实用。",

		CUTGRASS = "生草。",

		GRASS = {
			GENERIC = "草，一种植物。",
		},

		OTTER = "兄.....兄弟......",
		OTTERDEN = {
			GENERIC = "兄弟的家。",
			HAS_LOOT = "兄弟...你家好满....",
		},

		SHADOWTHRALL_MOUTH = "Snake? Snaaaaaaaaaaaaaaaake!",

		WATHGRITHR_SHIELD = "My face is my shield.",

		WORMHOLE =
		{
			GENERIC = "肉乎乎的一坨虫洞。",
			OPEN = "它想对我做什么呢？",
		},

		PLAYER = {
			GENERIC = "嗨，%s!",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},

		SHIYE = {
			GENERIC = "你好，皇家守卫%s!",
			ATTACKER = "你为这个世界带来了混乱！",
			MURDERER = "面具杀手！",
			REVIVER = "%s是个好人",
			GHOST = "我得把%s从虚空之境中拉回来！",
		},

		-- FLOWER = "朝雾，你究竟到哪里去了？",

		GELBLOB = "角色扮演游戏中的经典怪物。",
	},

	ANNOUNCE_EXIT_GELBLOB = "我不喜欢丸吞play。",

	-- 为了避免OOC，这些还是不要加了吧
	-- ANNOUNCE_TALK_TO_PLANTS =
	-- {

	-- 	"杂鱼♡~杂鱼♡~",
	-- 	"杂鱼♡再怎么对话也不会变长的~",
	-- 	"阿啦啦啦，你这杂鱼植物♡~",
	-- 	"捏捏~杂鱼被子植物君♡~",
	-- 	"只会光合成♡~遇到碘液就会变紫♡~",
	-- 	"Zaku♡~Zaku♡~",
	-- 	"还是没有变大吗？真是杂鱼呢♡~",
	-- 	"哦啦，长得快一点啊♡~",
	-- 	"踩扁你哦♡~",

	-- },

	ANNOUNCE_WORMHOLE = "还好它没对我动手动脚。",

}

return MODIFIED_SPEECH
