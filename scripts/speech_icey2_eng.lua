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
            SKILL_ALREADY_LEARNED = "I've already learned this skill before.",
            PRE_SKILL_REQUIRED = "I need to unlock the previous upgrade first.",
            MAX_DODGE_CHARGE = "Dodge charge is already at max.",
            DODGE_CHARGE_CHIP_ONLY_ONCE = "I can only use each chip once!",
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
        BACKPACK = "You're right, but Don't Starve is a grid-based inventory management game.",
        BEARDHAIR = "I can't grow such a magnificent beard!",
        BEARGER = "It's looking for honey.",
        BISHOP = "Have you seen 'The Mechanic'?",
        BUSHHAT = "Not as practical as a cardboard box.",

        -- CATCOON = "小猫，你可以吃素食堡。",
        CATCOON = "Where catcoons dance with wolves.",
        CHARLIE_STAGE_POST = "Do you want me to recite the lines from Icey's true ending?",
        CUTGRASS = "Lol.",

        DEERCLOPS = "My deer friend.",
        DRAGONFLY = "Dragonfly!",

        -- FIREPIT = {
        -- 	EMBERS = "I should put something on the fire before it goes out.",
        -- 	GENERIC = "Sure beats darkness.",
        -- 	HIGH = "Good thing it's contained!",
        -- 	LOW = "The fire's getting a bit low.",
        -- 	NORMAL = "Nice and comfy.",
        -- 	OUT = "At least I can start it up again.",
        -- },
        FLOWER = "Kindergarten flower.",
        -- FLOWER = "朝雾，你究竟到哪里去了？",
        FROG =
        {
            GENERIC = "It can control time.",
        },

        GELBLOB = "Slime, a classic monster in RPGs.",
        GOLDENPITCHFORK = "I heard a witcher say it's 'very dangerous in melee combat'.",
        GRASS =
        {
            GENERIC = "Grass, a plant.",
        },

        KNIGHT = "Mechanical Mark Shaw.",
        KNIGHT_NIGHTMARE = "A very old mechanical Mark Shaw, or just Old Mark Shaw.",
        KOALEFANT_SUMMER = "Sad Elephant Smash.",                       -- "Sad Elephant Smash" is a phrase from a Bilibili Don't Starve streamer.
        KOALEFANT_WINTER = "Old grandpa! I'm here to stomp your back!", -- From "Peas Funny Story: Stepping on Backs".
        KOALEFANT_CARCASS = "Elephant! Elephant!!!",                    -- From the quotes of Changshu Arno.

        LEAFYMEATBURGER = "Tastes better than the leftover burgers in Mi City's cafeteria.",
        LIGHTNING_ROD =
        {
            GENERIC = "One for each, Ganbareito!",
            CHARGED = "Azure Lightning!",
        },
        LUNARFROG = "Are you crazy!",

        MOOSE = "A big silly duck.",
        MOOSE_NESTING_GROUND = "This nest looks like a silly duck.",
        MOOSEEGG = "Baby silly ducks are born here.",
        MOSSLING = "A little silly duck.",
        MULTIPLAYER_PORTAL = "Teleportation successful!",
        MULTIPLAYER_PORTAL_MOONROCK = "Are you going to replace me?",

        OTTER = "Bro... brother...",
        OTTERDEN =
        {
            GENERIC = "Brother's home.",
            HAS_LOOT = "Brother... your house is so full....",
        },

        PETALS = "Holding the kindergarten flower in my hand.",
        PETALS_EVIL = "Evil petals!",
        PIGMAN =
        {
            DEAD = "Dead pig.",
            FOLLOWER = "He's my good buddy.",
            GENERIC = "Pig! You have two nostrils!",
            GUARD = "He looks tough.",
            WEREPIG = "Right in the werepig!",
        },
        PITCHFORK = "Can be used to dig a 3x3 grid.",
        PLAYER_HOSTED =
        {
            GENERIC = "Corpse, fire.",
            ME = "Corpse, fi...",
        },
        PONDFISH = "BiliBili fish man.",

        RABBIT =
        {
            GENERIC = "Gallop's distant relative.",
            HELD = "Should I give it to Gallop?",
        },
        RABBITHOLE =
        {
            GENERIC = "Rabbit hole.",
            SPRING = "The rabbit hole is broken.",
        },
        ROBIN_WINTER =
        {
            GENERIC = "Bird of the bell rose.",
            HELD = "Let me see that bird.",
        },
        ROOK = "Rook, aren't you a spy anymore?",

        -- SHADOWTHRALL_HANDS = "Hands off!",
        -- SHADOWTHRALL_HORNS = "It looks hungry for a fight.",
        -- SHADOWTHRALL_WINGS = "The wings seem to be just for show.",
        SHADOWTHRALL_MOUTH = "Snake? Snaaaaaaaaaaaaaaaake!",
        SPIDER =
        {
            DEAD = "Dead!",
            GENERIC = "Spiders everywhere! Open fire!",
            SLEEPING = "Looks kinda cute when it's sleeping.",
        },
        STALKER_ATRIUM = "Ancient fuel weaving.", -- From an early awkward machine translation of "Ancient Fuelweaver" in Don't Starve Together.

        TOADSTOOL =
        {
            GENERIC = "It can drain energy from mortals.",
        },
        TORCH = "Wilson's lifelong research achievement.",

        WATHGRITHR_SHIELD = "My face is my shield.",
        WORMHOLE =
        {
            GENERIC = "A fleshy blob of wormhole.",
            OPEN = "What does it want to do to me?",
        },
        WORM_BOSS = "Can be turned off in settings.",

        WILSON =
        {
            GENERIC = "%s looks ordinary, but I believe he can conquer the world with his brains.",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WOLFGANG =
        {
            GENERIC = "You are too OP!",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WAXWELL =
        {
            GENERIC = "Legend says the black magician has a disciple...",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WX78 =
        {
            GENERIC = "I don't think he's a malfunctioning robot.",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WILLOW =
        {
            GENERIC = "Dragon King, spit fire!",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WENDY =
        {
            GENERIC = "A poor girl who lost her loved ones.",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WOODIE =
        {
            GENERIC = "%s is a bit too invincible.",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
            GOOSE = "A monk can jump onto the roof, and so can you!",
        },
        WICKERBOTTOM =
        {
            GENERIC = "%s is a knowledgeable lady.",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WES =
        {
            GENERIC = "%s is not good with words, but has a kind heart.",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WEBBER =
        {
            GENERIC = "%s is furry, furries should like him.",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WATHGRITHR =
        {
            GENERIC = "Have you played God of War?",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WINONA =
        {
            GENERIC = "I expect %s to be able to make redstone someday.",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WORTOX =
        {
            GENERIC = "A man who bears the name of a traitor and abandoned everything to fight ♫~~~~",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WORMWOOD =
        {
            GENERIC = "Plant humanities teacher Wang!",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WARLY =
        {
            GENERIC = "Warly! He is just a...",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WURT =
        {
            GENERIC = "This is your soldier? A merm!",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WALTER =
        {
            GENERIC = "Good day, %s!",
            -- GENERIC = "我不能呼吸了！",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        WANDA =
        {
            GENERIC = "Gentle Wanda.",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
        },
        -- WONKEY =
        -- {
        -- 	GENERIC = "It's a monkey.",
        -- },

        PLAYER =
        {
            GENERIC = "Hi, %s!",
            ATTACKER = "%s, you're a bad guy!",
            MURDERER = "Murderer!",
            REVIVER = "%s is a good friend to ghosts",
            GHOST = "I need to give %s a heart!",
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

    ANNOUNCE_DEERCLOPS = "My sensors are vibrating, there must be a big guy nearby!",

    ANNOUNCE_EAT =
    {
        GENERIC = "Mmm~",
        PAINFUL = "I feel unwell...",
        SPOILED = "This is awful...",
        STALE = "Feels like it's going bad.",
        INVALID = "I won't eat that.",
        YUCKY = "I want to eat batteries!",
    },

    ANNOUNCE_EXIT_GELBLOB = "I don't like being swallowed whole.",

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

    ANNOUNCE_HOT = "I'm overheating!",
    ANNOUNCE_HUNGRY = "I'm running out of power.",

    ANNOUNCE_DAMP = "Seems a little damp...",
    ANNOUNCE_WET = "Looks like my clothes aren't waterproof...",
    ANNOUNCE_WETTER = "I'm going to short circuit if this keeps up!",
    ANNOUNCE_SOAKED = "Ah! Pantyshot! Narrator, where are you looking?!!",

    -- ANNOUNCE_SHADOWTHRALL_STEALTH = "aieeee，忍者，为啥这里会有忍者？！",
    ANNOUNCE_SHADOWTHRALL_STEALTH = "Aieeeeeeeeee! Ninja, ninja why?!",


    ANNOUNCE_WORMHOLE = "Ugh, I'm all slimy!",
    ANNOUNCE_WORMS = "Seismic activity detected. Cave worms are entering the area.",
    ANNOUNCE_WORMS_BOSS = "Something's breaking through the surface!",
}

return MODIFIED_SPEECH
