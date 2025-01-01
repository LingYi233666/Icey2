--[[
	--- This is Wilson's speech file for Don't Starve Together ---
	Write your character's lines here.
	If you want to use another speech file as a base, or use a more up-to-date version, get them from data\scripts\
	
	If you want to use quotation marks in a quote, put a \ before it.
	Example:
	"Like \"this\"."
]]

local MODIFIED_SPEECH = {
	ACTIONFAIL = {
		BUILD =
		{
			SKILL_ALREADY_LEARNED = "我之前就已经学会这个技能了。"
		},
	},

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
		BACKPACK = "你说得对，但是饥荒是一款格子管理游戏。",
		BEARDHAIR = "我长不出这么宏伟的胡须！",
		BUSHHAT = "不如纸箱实用。",

		CUTGRASS = "生草。",

		-- FIREPIT = {
		-- 	EMBERS = "I should put something on the fire before it goes out.",
		-- 	GENERIC = "Sure beats darkness.",
		-- 	HIGH = "Good thing it's contained!",
		-- 	LOW = "The fire's getting a bit low.",
		-- 	NORMAL = "Nice and comfy.",
		-- 	OUT = "At least I can start it up again.",
		-- },
		FLOWER = "幼儿园小班花。",
		-- FLOWER = "朝雾，你究竟到哪里去了？",

		GELBLOB = "史莱姆，角色扮演游戏中的经典怪物。",
		GRASS = {
			GENERIC = "草，一种植物。",
		},

		LEAFYMEATBURGER = "小猫，你可以吃素食堡。",

		OTTER = "兄.....兄弟......",
		OTTERDEN = {
			GENERIC = "兄弟的家。",
			HAS_LOOT = "兄弟...你家好满....",
		},

		PETALS = "把小班花捧在手心。",
		-- PETALS_EVIL = "I'm not sure I want to hold those.",
		PONDFISH = "比利比利鱼腩。",

		RABBIT =
		{
			GENERIC = "加洛普的远亲。",
			HELD = "我应该把它交给加洛普吗？",
		},
		RABBITHOLE =
		{
			GENERIC = "兔子洞。",
			SPRING = "兔子洞已经坏掉了。",
		},

		SHADOWTHRALL_MOUTH = "Snake? Snaaaaaaaaaaaaaaaake!",

		TORCH = "威尔逊毕生科研成果的结晶。",

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


	},

	ANNOUNCE_EAT =
	{
		GENERIC = "唔~",
		PAINFUL = "我感觉不舒服···",
		SPOILED = "好难吃啊····",
		STALE = "感觉要烂掉了",
		INVALID = "我才不吃呢",
		YUCKY = "我要吃电池!",
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

	ANNOUNCE_HUNGRY = "我快没电了。",

	ANNOUNCE_DAMP = "湿了···",
	ANNOUNCE_WET = "看来我的衣服并不防水···",
	ANNOUNCE_WETTER = "再这样下去要短路了！",
	ANNOUNCE_SOAKED = "啊！走光了！旁白你在看哪里？！！",

	ANNOUNCE_WORMHOLE = "还好它没对我动手动脚。",

}

return MODIFIED_SPEECH
