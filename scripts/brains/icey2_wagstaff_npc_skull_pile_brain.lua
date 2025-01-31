require "behaviours/standstill"
require "behaviours/wander"
require "behaviours/follow"
require "behaviours/faceentity"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/chattynode"
require "behaviours/leash"

local BrainCommon = require "brains/braincommon"



local Wagstaff_NPCBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)


local function ShouldGoToSkullPile(inst)
    local pos = inst.components.knownlocations:GetLocation("skull_pile")

    if pos ~= nil then
        inst:DoTaskInTime(4, function()
            inst.components.talker:Chatter("WAGSTAFF_GO_TO_SKULL_PILE", math.random(#STRINGS.WAGSTAFF_GO_TO_SKULL_PILE),
                nil, nil, CHATPRIORITIES.HIGH)
        end)
        return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, pos, nil, .2)
    end
end

function Wagstaff_NPCBrain:OnStart()
    local go_to_skull_pile = WhileNode(
        function() return self.inst.components.knownlocations:GetLocation("skull_pile") end,
        "GoingToSkullPile",
        PriorityNode {
            IfNode(function() return self.inst.components.knownlocations:GetLocation("skull_pile") end, "Go to skull pile",
                DoAction(self.inst, ShouldGoToSkullPile, "Go to skull pile", true)),
            StandStill(self.inst),
        }, .5)



    local root =
        PriorityNode(
            {
                go_to_skull_pile,
                StandStill(self.inst),
            }, .5)

    self.bt = BT(self.inst, root)
end

return Wagstaff_NPCBrain
