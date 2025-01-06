-- The character select screen lines  --人物选人界面的描述
STRINGS.CHARACTER_TITLES.icey2 = "艾希"
STRINGS.CHARACTER_NAMES.icey2 = "艾希"
STRINGS.CHARACTER_DESCRIPTIONS.icey2 = "*依旧是作者的老婆\n*已经产生了自我意识\n*控场技能丰富\n"
STRINGS.CHARACTER_QUOTES.icey2 = "\"又有死宅在找我的本子\""

-- Custom speech strings  ----人物语言文件  可以进去自定义
STRINGS.CHARACTERS.ICEY2 = require "speech_icey2"

-- The character's name as appears in-game  --人物在游戏里面的名字
STRINGS.NAMES.ICEY2 = "艾希"
STRINGS.SKIN_NAMES.icey2_none = "艾希" -- 检查界面显示的名字

-- 生存几率
STRINGS.CHARACTER_SURVIVABILITY.icey2 = "较高"

----------------------------------------------------------------------------------------------
-- NAMES & DESCRIBE


STRINGS.NAMES.ICEY2_PACT_WEAPON_RAPIER = "能量刺剑"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ICEY2_PACT_WEAPON_RAPIER = "这是某种...武器。"

STRINGS.NAMES.ICEY2_PACT_WEAPON_SCYTHE = "能量镰刀"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ICEY2_PACT_WEAPON_SCYTHE = "这是某种...武器。"

STRINGS.NAMES.ICEY1_BLUEROSE = "高频切割刃"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ICEY1_BLUEROSE = "已经很旧了。"
STRINGS.CHARACTERS.ICEY2.DESCRIBE.ICEY1_BLUEROSE = "看起来很眼熟。"

STRINGS.NAMES.ICEY1_MOUND = "安息之地"
STRINGS.CHARACTERS.ICEY2.DESCRIBE.ICEY1_MOUND = {
    DUG = "......",
    GENERIC = "最好还是不要打扰她了。",
}


STRINGS.NAMES.ICEY2_SKILL_BUILDER_NEW_PACT_WEAPON_SCYTHE = "解锁能量武器：镰刀"
STRINGS.RECIPE_DESC.ICEY2_SKILL_BUILDER_NEW_PACT_WEAPON_SCYTHE = "使你的能量武器种类增加！"

STRINGS.NAMES.ICEY2_SKILL_BUILDER_BATTLE_FOCUS = "解锁战意聚焦"
STRINGS.RECIPE_DESC.ICEY2_SKILL_BUILDER_BATTLE_FOCUS = "不受伤的连续攻击可以恢复属性。"

STRINGS.NAMES.ICEY2_SKILL_BUILDER_PHANTOM_SWORD = "解锁幻影剑"
STRINGS.RECIPE_DESC.ICEY2_SKILL_BUILDER_PHANTOM_SWORD = "释放幻影剑自动追踪敌人。"

STRINGS.NAMES.ICEY2_SKILL_BUILDER_PARRY = "解锁聚能盾牌"
STRINGS.RECIPE_DESC.ICEY2_SKILL_BUILDER_PARRY = "制造盾牌格挡面前的攻击。"

----------------------------------------------------------------------------------------------
-- ACTIONS

STRINGS.ACTIONS.CASTAOE.ICEY2_PACT_WEAPON_RAPIER = "迭影"
STRINGS.ACTIONS.CASTAOE.ICEY2_PACT_WEAPON_SCYTHE = "掷镰"
STRINGS.ACTIONS.CASTAOE.ICEY1_BLUEROSE = "突围冲击"

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
        FORCE_SHIELD = {
            TITLE = "力场护盾",
            DESC = "你的力场护盾与任何护甲的加持一样有效。在你不装备任何护甲或盾牌时，力场护盾能帮助你吸收等量伤害。\n护盾当前值与最大值能在右上角查看。",
        },

        BATTLE_FOCUS = {
            TITLE = "战意聚焦",
            DESC =
            "在你不装备任何护甲或盾牌时，使用近战武器连续普通攻击会使你进入战斗专注状态，提高力场伤害、恐惧抵抗与移动速度。在此状态下，你可以从敌人的生命中撕扯出精华，回复护盾或者生命值。\n受到攻击会让战斗专注效果中断。",
        },

        PHANTOM_SWORD = {
            TITLE = "幻影剑",
            DESC = "消耗少许饥饿值，释放5枚电浆飞弹攻击鼠标指向的生物，每枚飞弹造成少量力场伤害。飞弹一定会命中目标。\n如果鼠标指向处没有生物。则飞弹会自动寻找附近的敌人。"
        },

        DODGE = {
            TITLE = "闪光冲刺",
            DESC = "消耗少许饥饿值，向鼠标指向方向冲刺，冲刺期间你不会受到伤害。\n冲刺开始时，自动使用残影向正在攻击你的敌人发动一次反击。\n若你装备了任何种类的护甲或盾牌，就无法使用闪光冲刺。"
        },

        SUMMON_PACT_WEAPON = {
            TITLE = "创造能量武器",
            DESC =
            "在你手中凭空创造出1把能量刺剑。\n你不能丢弃以此技能制造的武器，其他生物也不能将其打落。当你不需要它时，可以再次释放此技能将其销毁。\n能量刺剑能同时造成物理和力场伤害，武器战技如下：\n战技·迭影：\n对鼠标指向地点周围的敌人连续发动攻击。",
            DESC_TIP_MORE_WEAPON = "*某些技能可以让你召唤更多种类的能量武器。",
            DESC_CURRENT_WEAPON = "除了能量刺剑，你现在还有以下武器可选：%s。",

            WHEEL_INFO = {
                GENERAL = "创造：",
                -- REMOVE = "销毁当前能量武器",
                REMOVE = "销毁：",
                REMOVE_ALL = "销毁全部能量武器",
            },
        },

        NEW_PACT_WEAPON_SCYTHE = {
            TITLE = "能量武器：镰刀",
            DESC =
            "“创造能量武器”技能新增武器种类：能量镰刀。能量镰刀可以用于战斗，或是用来收割农作物，武器战技如下：\n战技·掷镰：\n向鼠标方向投掷镰刀，对一条直线上的敌人造成伤害，并在落地点形成一道能够增加你伤害的力幕。",
        },

        PARRY = {
            TITLE = "聚能盾牌",
            DESC =
            "将力场护盾的全部能量输出集中在你的手中，形成一面能够吸收正前方攻击的坚固盾牌。\n在你不装备任何护甲或盾牌时，如果你在举起盾牌后短时间内格挡了一次攻击，且你已经掌握“战意聚焦”技能，你会立刻进入战斗专注状态，",
        },

        UNKNOWN = {
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

STRINGS.ICEY2_UI.SHIELD_METRICS = {
    TIP = "护盾：%d/%d"
}
----------------------------------------------------------------------------------------------
