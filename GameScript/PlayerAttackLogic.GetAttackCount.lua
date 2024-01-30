return function (self,user,skillId,skillLevel,shadowPartner) 
	--------------- zz_y7 ---------------
	if zz_y7.use_attack_count then
		return 15
	end
	--------------- zz_y7 ---------------

local levelData = _SkillMan:GetSkillLevelData(skillId, skillLevel)
if (levelData ~= nil) then
	local svrAttackCount = levelData.attackCount
	local svrBulletCount = levelData.bulletCount
	if (svrAttackCount <= 1) then
		svrAttackCount = 1
	end
	if (shadowPartner and user.PlayerTemporaryStat:GetValue(_CTS.ShadowPartner) ~= 0) then
		svrAttackCount *= 2
	end
	if (svrBulletCount <= 1) then
		svrBulletCount = 1
	end
	local final = svrAttackCount * svrBulletCount
	if (final > 15) then
		final = 15
	end
	return final
end
return 1
end