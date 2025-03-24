name = "艾希：地狱归来" ---mod名字
description = "一个有趣的人物模组。" --mod描述
author = "灵衣女王的鬼铠" --作者
version = "1.0.0" -- mod版本 上传mod需要两次的版本不一样

forumthread = ""

api_version = 10                   --api版本

dst_compatible = true              --兼容联机

dont_starve_compatible = false     --不兼容原版
reign_of_giants_compatible = false --不兼容巨人DLC

all_clients_require_mod = true     --所有人mod

icon_atlas = "modicon.xml"         --mod图标
icon = "modicon.tex"

server_filter_tags = { --服务器标签
    "character",
}

configuration_options = {
    {
        name = "play_skill_learned_anim",
        label = "技能学习动画",
        options =
        {
            { description = "播放", data = true },
            { description = "不播放", data = false },
        },
        default = true,
    },
} --mod设置


if locale == "zh" or locale == "zhr" or locale == "zht" then
    -- Do nothing
else
    name = "Icey: Back from Hell"
    description = "An interesting character mod."
    configuration_options[1].label = "Skill learning animation"
    configuration_options[1].options[1].description = "Play"
    configuration_options[1].options[2].description = "Don't play"
end
