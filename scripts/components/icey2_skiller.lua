require "json"

local function onjson_data(self, data)
	self.inst.replica.icey2_skiller:SetJsonData(data)
end

local Icey2Skiller = Class(function(self, inst)
							   self.inst = inst

							   self.learned_skill = {}

							   -- self.json_data = "{}"


							   self:UpdateJsonData()
						   end, nil, {
							   json_data = onjson_data,
						   })


-- ThePlayer.components.icey2_skiller:Learn("PHANTOM_SWORD")
function Icey2Skiller:Learn(name, is_onload)
	if self:IsLearned(name) then
		print("Try to learn a skill you already learned:", name)
		return
	end

	local data = ICEY2_SKILL_DEFINES[name]
	if data then
		self.learned_skill[name] = true
		if data.OnLearned then
			data.OnLearned(self.inst, is_onload)
		end

		self.inst:PushEvent("icey2_skill_learned", {
			name = name,
			is_onload = is_onload
		})
	else
		print("Error:Unable to learn", name)
	end

	self:UpdateJsonData()
end

function Icey2Skiller:Forget(name)
	if not self:IsLearned(name) then
		return
	end

	self.learned_skill[name] = nil
	local data = ICEY2_SKILL_DEFINES[name]
	if data then
		if data.OnForget then
			data.OnForget(self.inst)
		end
		self.inst:PushEvent("icey2_skill_forgot", {
			name = name,
		})
	else
		print("Error:Data not found:", name)
	end

	self:UpdateJsonData()
end

function Icey2Skiller:UpdateJsonData()
	local data = {
		learned_skill = self.learned_skill,
		unlocked_tree = self.unlocked_tree
	}

	self.json_data = json.encode(data)
end

function Icey2Skiller:IsLearned(name)
	return self.learned_skill[name] == true
end

function Icey2Skiller:GetLearnedSkill()
	local ret = {}
	for name, v in pairs(self.learned_skill) do
		if v == true then
			table.insert(ret, name)
		end
	end

	return ret
end

function Icey2Skiller:OnSave()
	local ret = {
		learned_skill = self:GetLearnedSkill()
	}

	return ret
end

function Icey2Skiller:OnLoad(data)
	if data then
		if data.learned_skill then
			print(":OnLoad() data.learned_skill:")
			dumptable(data.learned_skill)
			for k, name in pairs(data.learned_skill) do
				self:Learn(name, true)
			end
		end
	end
end

function Icey2Skiller:GetDebugString()
	local s = "Learned skill:"
	for name, bool in pairs(self.learned_skill) do
		if bool then
			s = s .. name .. ","
		end
	end

	return s
end

return Icey2Skiller
