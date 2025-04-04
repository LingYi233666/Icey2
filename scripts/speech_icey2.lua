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
			SKILL_ALREADY_LEARNED = "我之前就已经学会这个技能了。",
			PRE_SKILL_REQUIRED = "我必须解锁前一项升级。",
			MAX_DODGE_CHARGE = "闪避充能已经到达上限了。",
			DODGE_CHARGE_CHIP_ONLY_ONCE = "每种芯片我最多只能使用一次！",
		},
	},

	-- 战吼
	-- 老马克肖：艾希在战斗时不会说话
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
		BEARGER = "它在找蜂蜜吃。",
		BISHOP = "你看过《肖申克的救赎》吗？",
		BUSHHAT = "不如纸箱实用。",

		-- CATCOON = "小猫，你可以吃素食堡。",
		CATCOON = "彼处浣猫与狼共舞。",
		CHARLIE_STAGE_POST = "要我把《艾希》真结局的台词复述一遍吗？",
		CUTGRASS = "生草。",

		DEERCLOPS = "My deer friend.",
		DRAGONFLY = "龙飞！",

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
		FROG =
		{
			GENERIC = "它能掌控时间。",
		},

		GELBLOB = "史莱姆，角色扮演游戏中的经典怪物。",
		GOLDENPITCHFORK = "我听一位猎魔人说它“在近身战中十分危险”。",
		GRASS =
		{
			GENERIC = "草，一种植物。",
		},

		KNIGHT = "机械马克肖。",
		KNIGHT_NIGHTMARE = "很老旧的机械马克肖，简称老马克肖。",

		LEAFYMEATBURGER = "比弥城食堂里那些吃剩的汉堡更美味。",
		LIGHTNING_ROD =
		{
			GENERIC = "一人一台，刚巴雷特！",
			CHARGED = "苍蓝雷霆！",
		},
		LUNARFROG = "不要命啦！",

		MOOSE = "一只大憨憨鸭。",
		MOOSE_NESTING_GROUND = "这个巢看起来好憨憨鸭。",
		MOOSEEGG = "小憨憨鸭从这里诞生。",
		MOSSLING = "一只小憨憨鸭。",
		MULTIPLAYER_PORTAL = "传送成功！",
		MULTIPLAYER_PORTAL_MOONROCK = "要把我换掉吗？",

		OTTER = "兄.....兄弟......",
		OTTERDEN =
		{
			GENERIC = "兄弟的家。",
			HAS_LOOT = "兄弟...你家好满....",
		},

		PETALS = "把小班花捧在手心。",
		PETALS_EVIL = "邪恶的花瓣！",
		PIGMAN =
		{
			DEAD = "死猪。",
			FOLLOWER = "他是我的好伙伴。",
			GENERIC = "猪！你的鼻子有两个孔！",
			GUARD = "他看上去很不好惹。",
			WEREPIG = "正中大疯猪！",
		},
		PITCHFORK = "可以用来挖九宫格。",
		PLAYER_HOSTED =
		{
			GENERIC = "尸体，发火。",
			ME = "尸体，发...",
		},
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
		ROBIN_WINTER =
		{
			GENERIC = "铃铛蔷薇的鸟。",
			HELD = "让我看看这个鸟。",
		},
		ROOK = "鲁克，你不做间谍了吗？",

		-- SHADOWTHRALL_HANDS = "Hands off!",
		-- SHADOWTHRALL_HORNS = "It looks hungry for a fight.",
		-- SHADOWTHRALL_WINGS = "The wings seem to be just for show.",
		SHADOWTHRALL_MOUTH = "Snake? Snaaaaaaaaaaaaaaaake!",
		SPIDER =
		{
			DEAD = "死了！",
			GENERIC = "蜘蛛到处都是！那就到处开火！",
			SLEEPING = "睡着了还蛮可爱的。",
		},

		TOADSTOOL =
		{
			GENERIC = "它能从凡人身上汲取能量。",
		},
		TORCH = "威尔逊毕生科研成果的结晶。",

		WATHGRITHR_SHIELD = "My face is my shield.",
		WORMHOLE =
		{
			GENERIC = "肉乎乎的一坨虫洞。",
			OPEN = "它想对我做什么呢？",
		},
		WORM_BOSS = "可以在设置里关掉。",

		WILSON =
		{
			GENERIC = "%s看起来平平无奇，但我相信他能用头脑征服这个世界。",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WOLFGANG =
		{
			GENERIC = "你  太  超  模  了  ！",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WAXWELL =
		{
			GENERIC = "传说黑魔术师有一位弟子...",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WX78 =
		{
			GENERIC = "我认为他不是故障机器人。",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WILLOW =
		{
			GENERIC = "龙王喷个火！",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WENDY =
		{
			GENERIC = "失去至亲的可怜女孩。",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WOODIE =
		{
			GENERIC = "%s有些过于无敌了。",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
			GOOSE = "武僧能一跃跳上房顶，你也能！",
		},
		WICKERBOTTOM =
		{
			GENERIC = "%s是一位博学的女士。",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WES =
		{
			GENERIC = "%s不善言辞，但心地善良。",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WEBBER =
		{
			GENERIC = "%s毛茸茸的，福瑞控应该会很喜欢他。",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WATHGRITHR =
		{
			GENERIC = "你玩过《战神》吗？",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WINONA =
		{
			GENERIC = "我期待%s有朝一日能搓出红石。",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WORTOX =
		{
			GENERIC = "背负着叛徒之名，抛弃了全部来战斗的男人♫~~~~",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WORMWOOD =
		{
			GENERIC = "植物人文汪老师！",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WARLY =
		{
			GENERIC = "沃利！就是一......",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WURT =
		{
			GENERIC = "这就是你的士兵？一只鱼人！",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WALTER =
		{
			GENERIC = "日安, %s！",
			-- GENERIC = "我不能呼吸了！",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		WANDA =
		{
			GENERIC = "温柔的旺达。",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},
		-- WONKEY =
		-- {
		-- 	GENERIC = "It's a monkey.",
		-- },

		PLAYER =
		{
			GENERIC = "嗨，%s!",
			ATTACKER = "%s，你是个坏人！",
			MURDERER = "杀人犯！",
			REVIVER = "%s是鬼魂的好朋友",
			GHOST = "我得给%s一颗心！",
		},

		-- SHIYE =
		-- {
		-- 	GENERIC = "你好，皇家守卫%s!",
		-- 	ATTACKER = "你为这个世界带来了混乱！",
		-- 	MURDERER = "面具杀手！",
		-- 	REVIVER = "%s是个好人",
		-- 	GHOST = "我得把%s从虚空之境中拉回来！",
		-- },
	},

	ANNOUNCE_DEERCLOPS = "我的传感器在震动，这附近一定有大家伙！",

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

	ANNOUNCE_HOT = "我要热宕机了！",
	ANNOUNCE_HUNGRY = "我快没电了。",

	ANNOUNCE_DAMP = "好像有些湿了···",
	ANNOUNCE_WET = "看来我的衣服并不防水···",
	ANNOUNCE_WETTER = "再这样下去要短路了！",
	ANNOUNCE_SOAKED = "啊！走光了！旁白君你在看哪里？！！",

	-- ANNOUNCE_SHADOWTHRALL_STEALTH = "aieeee，忍者，为啥这里会有忍者？！",
	ANNOUNCE_SHADOWTHRALL_STEALTH = "Aieeeeeeeeee！忍者，忍者为何？！",


	ANNOUNCE_WORMHOLE = "啊，我身上黏糊糊的！",
	ANNOUNCE_WORMS = "侦测到地震运动，洞穴蠕虫正在进入。",
	ANNOUNCE_WORMS_BOSS = "有什么东西要破土而出了！",

}

return MODIFIED_SPEECH
