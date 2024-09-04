-- The character select screen lines  --人物选人界面的描述
STRINGS.CHARACTER_TITLES.icey2 = "艾希"
STRINGS.CHARACTER_NAMES.icey2 = "艾希"
STRINGS.CHARACTER_DESCRIPTIONS.icey2 = "*Perk 1\n*Perk 2\n*Perk 3"
STRINGS.CHARACTER_QUOTES.icey2 = "\"Quote\""

-- Custom speech strings  ----人物语言文件  可以进去自定义
STRINGS.CHARACTERS.ICEY2 = require "speech_icey2"

-- The character's name as appears in-game  --人物在游戏里面的名字
STRINGS.NAMES.ICEY2 = "艾希"
STRINGS.SKIN_NAMES.icey2_none = "艾希" -- 检查界面显示的名字

-- 生存几率
STRINGS.CHARACTER_SURVIVABILITY.icey2 = "生存"

STRINGS.ICEY2_UI = {}

STRINGS.ICEY2_UI.MAIN_MENU = {}
STRINGS.ICEY2_UI.MAIN_MENU.CALLER_TEXT = "菜单"
STRINGS.ICEY2_UI.MAIN_MENU.SUB_TITLES = {
    SKILL_TAB = "技能组",
    KEY_CONFIG = "键位一览"
}

STRINGS.ICEY2_UI.SKILL_TAB = {
    SKILL_DESC = {
        PHANTOM_SWORD = {
            TITLE = "幻影剑",
            DESC = "释放5枚电浆飞弹攻击鼠标指向的生物，每枚飞弹造成5~14力场伤害。飞弹一定会命中目标。\n如果鼠标指向处没有生物。则飞弹会自动寻找附近的敌人。"
        },

        DODGE = {
            TITLE = "闪光冲刺",
            DESC = "向鼠标指向方向瞬间移动。\n如果你没有装备护甲或盾牌，则冲刺期间你处于无敌状态，并且可以向正在攻击你的敌人发动一次反击。"
        },

        UNKNWON = {
            TITLE = "未知技能",
            DESC = "有些东西需要靠你自己去发现。"
        }
    },

    KEY_CONFIG = "设置键位"
}

STRINGS.ICEY2_UI.KEY_CONFIG_DIALOG = {
    TITLE = "设置键位",
    -- TEXT_BEFORE = "请按下对应的键位后再按确定来完成键位设置。",
    TEXT_BEFORE = "请按下对应的键位后再按确定来完成键位设置。\n不仅仅是键盘按键，鼠标中键或者侧键也可以进行设置哦！",
    TEXT_AFTER = "当前选的按键是：%s。您可以点击确定键完成键位设置，或者重新选择按键。",

    DO_SET_SKILL_KEY = "确定",
    CLEAR_SKILL_KEY = "清除按键",
    SET_KEY_CANCEL = "取消"
}
