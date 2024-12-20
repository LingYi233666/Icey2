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

----------------------------------------------------------------------------------------------
-- NAMES & DESCRIBE


STRINGS.NAMES.ICEY2_PACT_WEAPON_RAPIER = "能量刺剑"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ICEY2_PACT_WEAPON_RAPIER = "这是某种...武器。"

STRINGS.NAMES.ICEY2_PACT_WEAPON_SCYTHE = "能量镰刀"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ICEY2_PACT_WEAPON_SCYTHE = "这是某种...武器。"

----------------------------------------------------------------------------------------------
-- ACTIONS

STRINGS.ACTIONS.CASTAOE.ICEY2_PACT_WEAPON_RAPIER = "迭影"
STRINGS.ACTIONS.ICEY2_SCYTHE = "收割"

----------------------------------------------------------------------------------------------
-- HUD

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
            DESC = "消耗1点饥饿值，向鼠标指向方向冲刺，冲刺期间你不会受到伤害。\n冲刺开始时，若你没有装备护甲或盾牌，则自动使用残影向正在攻击你的敌人发动一次反击。"
        },

        SUMMON_PACT_WEAPON = {
            TITLE = "创造能量武器",
            DESC =
            "消耗1点精神值，在你手中凭空创造出1把能量刺剑。\n你不能丢弃以此技能制造的武器，其他生物也不能将其打落。当你不需要它时，可以再次释放此技能将其销毁。\n能量刺剑拥有17物理伤害和17力场伤害，武器战技如下：\n战技·迭影：\n对鼠标指向地点周围的敌人连续发动攻击。",
            DESC_TIP_MORE_WEAPON = "*某些技能可以让你召唤更多种类的能量武器。",
            DESC_CURRENT_WEAPON = "除了能量刺剑，你现在还有以下武器可选：%s。\n但是，你同一时间只能拥有一把能量武器，当你召唤新的能量武器时，旧武器会被销毁。",

            WHEEL_INFO = {
                GENERAL = "创造：",
                REMOVE = "销毁当前能量武器",
            },
        },

        UNKNWON = {
            TITLE = "未知技能",
            DESC = "有些东西需要靠你自己去发现。"
        }
    },

    KEY_CONFIG = "设置键位",
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

----------------------------------------------------------------------------------------------
