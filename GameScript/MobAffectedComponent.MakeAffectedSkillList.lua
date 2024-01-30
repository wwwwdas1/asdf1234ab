return function (self) 
local ret = {}
local insert = table.insert
---@type function(table:table,pos:number,value:any)
local insert3 = table.insert
local registeredReason = {}

---@param entry MobAffectedSkillEntry
local function addToList(entry)
	entry.MobEffectPos = _WzUtils:GetInt32(entry.MobEffect["pos"], 0)
	entry.MobEffectIsIcon = _WzUtils:GetBool(entry.MobEffect["icon"], false)
	entry.MobEffectIsRepeat = _WzUtils:GetBool(entry.MobEffect["repeat"], false)
	if (entry.MobEffectIsRepeat or entry.MobEffectIsIcon) then
		insert(ret, entry)
	else
		insert3(ret, 1, entry)
	end
end

---@return MobAffectedSkillEntry
local function addEntry(reason)
	if (registeredReason[reason]) then
		return
	end
	
	---@type MobAffectedSkillEntry
	local entry = {}
	entry.SkillId = reason
	local playerSkill = _SkillMan:GetSkill(reason)
	if (playerSkill ~= nil) then
		entry.MobEffect = playerSkill:GetMobEffect(nil)
		if (not entry.MobEffect) then
			if (not _MobSkill.AffectedSkillEffect[reason]) then
				--log_error(string.format("PlayerSkill %d MobEffect is nil", reason))			
			end
			entry.MobEffect = {}
		end
		entry.MobEffectClip = _EffectLogic.AnimationAssets[string.format("Skill/%03d.img/skill/%07d/mob", reason // 10000, reason)]
		addToList(entry)
	else
		local mobSkillId = (reason >> 16) & 0xffff
		local mobSkillLevel = reason & 0xffff
		local mobSkill = _SkillMan:GetMobSkillLevelData(mobSkillId, mobSkillLevel)
		if (mobSkill ~= nil) then
			entry.MobEffect = mobSkill.MobEffect
			if (not entry.MobEffect) then
				--log_error(string.format("MobSkill %d/%d MobEffect is nil", mobSkillId, mobSkillLevel))
				entry.MobEffect = {}
			end
			entry.MobEffectClip = _EffectLogic.AnimationAssets[string.format("Skill/MobSkill.img/%d/level/%d/mob", mobSkillId, mobSkillLevel)]
			addToList(entry)
		end
	end
	
	registeredReason[reason] = true
end

local mts = self.Entity.MobTemporaryStat
if (mts:GetValue(_MTS.Pad) ~= 0) then
	-- log(string.format("Pad: %s", tostring(mts:GetValue(_MTS.Pad))))
	addEntry(mts:GetReason(_MTS.Pad))
end
if (mts:GetValue(_MTS.Pdr) ~= 0) then
	-- log(string.format("Pdr: %s", tostring(mts:GetValue(_MTS.Pdr))))
	addEntry(mts:GetReason(_MTS.Pdr))
end
if (mts:GetValue(_MTS.Mad) ~= 0) then
	-- log(string.format("Mad: %s", tostring(mts:GetValue(_MTS.Mad))))
	addEntry(mts:GetReason(_MTS.Mad))
end
if (mts:GetValue(_MTS.Mdr) ~= 0) then
	-- log(string.format("Mdr: %s", tostring(mts:GetValue(_MTS.Mdr))))
	addEntry(mts:GetReason(_MTS.Mdr))
end
if (mts:GetValue(_MTS.Acc) ~= 0) then
	-- log(string.format("Acc: %s", tostring(mts:GetValue(_MTS.Acc))))
	addEntry(mts:GetReason(_MTS.Acc))
end
if (mts:GetValue(_MTS.Eva) ~= 0) then
	-- log(string.format("Eva: %s", tostring(mts:GetValue(_MTS.Eva))))
	addEntry(mts:GetReason(_MTS.Eva))
end
if (mts:GetValue(_MTS.Speed) ~= 0) then
	-- log(string.format("Speed: %s", tostring(mts:GetValue(_MTS.Speed))))
	addEntry(mts:GetReason(_MTS.Speed))
end
if (mts:GetValue(_MTS.Poison) ~= 0) then
	-- log(string.format("Poison: %s", tostring(mts:GetValue(_MTS.Poison))))
	addEntry(mts:GetReason(_MTS.Poison))
end
if (mts:GetValue(_MTS.Stun) ~= 0) then
	-- log(string.format("Stun: %s", tostring(mts:GetValue(_MTS.Stun))))
	addEntry(mts:GetReason(_MTS.Stun))
end
if (mts:GetValue(_MTS.Freeze) ~= 0) then
	-- log(string.format("Freeze: %s", tostring(mts:GetValue(_MTS.Freeze))))
	addEntry(mts:GetReason(_MTS.Freeze))
end
if (mts:GetValue(_MTS.Seal) ~= 0) then
	-- log(string.format("Seal: %s", tostring(mts:GetValue(_MTS.Seal))))
	addEntry(mts:GetReason(_MTS.Seal))
end
if (mts:GetValue(_MTS.PGuardUp) ~= 0) then
	-- log(string.format("PGuardUp: %s", tostring(mts:GetValue(_MTS.PGuardUp))))
	addEntry(mts:GetReason(_MTS.PGuardUp))
end
if (mts:GetValue(_MTS.MGuardUp) ~= 0) then
	-- log(string.format("MGuardUp: %s", tostring(mts:GetValue(_MTS.MGuardUp))))
	addEntry(mts:GetReason(_MTS.MGuardUp))
end
if (mts:GetValue(_MTS.PowerUp) ~= 0) then
	-- log(string.format("PowerUp: %s", tostring(mts:GetValue(_MTS.PowerUp))))
	addEntry(mts:GetReason(_MTS.PowerUp))
end
if (mts:GetValue(_MTS.MagicUp) ~= 0) then
	-- log(string.format("MagicUp: %s", tostring(mts:GetValue(_MTS.MagicUp))))
	addEntry(mts:GetReason(_MTS.MagicUp))
end
if (mts:GetValue(_MTS.Web) ~= 0) then
	-- log(string.format("Web: %s", tostring(mts:GetValue(_MTS.Web))))
	addEntry(mts:GetReason(_MTS.Web))
end
if (mts:GetValue(_MTS.PImmune) ~= 0) then
	-- log(string.format("PImmune: %s", tostring(mts:GetValue(_MTS.PImmune))))
	addEntry(mts:GetReason(_MTS.PImmune))
end
if (mts:GetValue(_MTS.MImmune) ~= 0) then
	-- log(string.format("MImmune: %s", tostring(mts:GetValue(_MTS.MImmune))))
	addEntry(mts:GetReason(_MTS.MImmune))
end
-- HardSkin
-- Ambush
-- Venom
-- Blind
if (mts:GetValue(_MTS.Seal) ~= 0) then
	-- log(string.format("Seal: %s", tostring(mts:GetValue(_MTS.Seal))))
	addEntry(mts:GetReason(_MTS.Seal))
end
-- Dazzle
if (mts:GetValue(_MTS.Doom) ~= 0) then
	-- log(string.format("Doom: %s", tostring(mts:GetValue(_MTS.Doom))))
	addEntry(mts:GetReason(_MTS.Doom))
end
-- PCounter
-- MCounter
-- BodyPressure
-- Weakness
-- TimeBomb
-- Showdown
-- MagicCrash
-- BurnedInfo
-- HealByDamage

return ret
end