PrefabFiles = {
    "icey2",      --人物代码文件
    "icey2_none", --人物皮肤

    "icey2_phantom_sword",
    "icey2_phantom_sword_hitfx",
}
---对比老版本 主要是增加了names图片 人物检查图标 还有人物的手臂修复（增加了上臂）
--人物动画里面有个SWAP_ICON 里面的图片是在检查时候人物头像那里显示用的


----2019.05.08 修复了 人物大图显示错误和检查图标显示错误
--2020.05.31  新加人物选人界面的属性显示信息
Assets = {
    Asset("IMAGE", "images/saveslot_portraits/icey2.tex"), --存档图片
    Asset("ATLAS", "images/saveslot_portraits/icey2.xml"),

    Asset("IMAGE", "images/selectscreen_portraits/icey2.tex"), --单机选人界面
    Asset("ATLAS", "images/selectscreen_portraits/icey2.xml"),

    Asset("IMAGE", "images/selectscreen_portraits/icey2_silho.tex"), --单机未解锁界面
    Asset("ATLAS", "images/selectscreen_portraits/icey2_silho.xml"),

    Asset("IMAGE", "bigportraits/icey2.tex"), --人物大图（方形的那个）
    Asset("ATLAS", "bigportraits/icey2.xml"),

    Asset("IMAGE", "images/map_icons/icey2.tex"), --小地图
    Asset("ATLAS", "images/map_icons/icey2.xml"),

    Asset("IMAGE", "images/avatars/avatar_icey2.tex"), --tab键人物列表显示的头像
    Asset("ATLAS", "images/avatars/avatar_icey2.xml"),

    Asset("IMAGE", "images/avatars/avatar_ghost_icey2.tex"), --tab键人物列表显示的头像（死亡）
    Asset("ATLAS", "images/avatars/avatar_ghost_icey2.xml"),

    Asset("IMAGE", "images/avatars/self_inspect_icey2.tex"), --人物检查按钮的图片
    Asset("ATLAS", "images/avatars/self_inspect_icey2.xml"),

    Asset("IMAGE", "images/names_icey2.tex"), --人物名字
    Asset("ATLAS", "images/names_icey2.xml"),

    Asset("IMAGE", "bigportraits/icey2_none.tex"), --人物大图（椭圆的那个）
    Asset("ATLAS", "bigportraits/icey2_none.xml"),

    Asset("IMAGE", "images/ui/skill_slot/sample.tex"),
    Asset("ATLAS", "images/ui/skill_slot/sample.xml"),

    Asset("SOUNDPACKAGE", "sound/icey2_sfx.fev"),
    Asset("SOUND", "sound/icey2_sfx.fsb"),

    Asset("ANIM", "anim/icey2_new_skill_circle.zip"),


    -- Asset("SOUNDPACKAGE", "sound/gale_bgm.fev"),
    -- Asset("SOUND", "sound/gale_bgm.fsb"),

    --[[---注意事项
1、目前官方自从熔炉之后人物的界面显示用的都是那个椭圆的图
2、官方人物目前的图片跟名字是分开的
3、names_icey2 和 icey2_none 这两个文件需要特别注意！！！
这两文件每一次重新转换之后！需要到对应的xml里面改对应的名字 否则游戏里面无法显示
具体为：
降names_esctemplatxml 里面的 Element name="icey2.tex" （也就是去掉names——）
将icey2_none.xml 里面的 Element name="icey2_none_oval" 也就是后面要加  _oval
（注意看修改的名字！不是两个都需要修改）
	]]
}

GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })

PREFAB_SKINS["icey2"] = { --修复人物大图显示
    "icey2_none",
}


local modimport_filenames = {
    "language_chs",
    "rpc_defines",
    "skill_defines",
    "icey2_skiller_cmp",
    "input",
    "stategraphs",
    "hud",
}

for _, filename in pairs(modimport_filenames) do
    modimport("main/" .. filename)
end

AddMinimapAtlas("images/map_icons/icey2.xml") --增加小地图图标

--增加人物到mod人物列表的里面 性别为女性（MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL）
AddModCharacter("icey2", "FEMALE")



--选人界面人物三维显示
TUNING.ICEY2_HEALTH = 150
TUNING.ICEY2_HUNGER = 150
TUNING.ICEY2_SANITY = 150



--选人界面初始物品显示
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.ICEY2 = { "spear" }

--[[如果你的初始物品是mod物品需要定义mod物品的图片路径 比如物品是 abc

TUNING.STARTING_ITEM_IMAGE_OVERRIDE["abc"] = {
	atlas = "images/inventoryimages/abc.xml",
	image = "abc.tex",
}

]]