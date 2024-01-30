return function (self,user,skillId,skillLevel,output,lastFinalAttack,keyDown) 
	local state = user.StateComponent.CurrentStateName
	
	local finalAttack = false
	if (_Skills.FinalAttack[skillId] and user.WsUserController.FinalAttack ~= nil) then
		finalAttack = true
	end
	--if (not user.MovementComponent.Enable) then
	--    return -1
	--end
	if (user.CalcDamageComponent.Syncing > 0) then
		log_warning("player is syncing rand32")
		return -1
	end
	
	if (skillId == 0) then
		if not (_CharacterActionLogic:CanAttack(state)) then
			return -1
		end
	else
		if (not finalAttack and not _CharacterActionLogic:CanMeleeShootAttack(state)) then
			log("cannot attack state", state, " / ", skillId, " / ", _Skills.FinalAttack[skillId], user.WsUserController.FinalAttack)
			return -1
		end
	end
	
	local ac = user.CharacterActionComponent
	
	if (skillId == 1311006 or skillId == 4221001 or skillId == 1121006 or skillId == 1221007 or skillId == 1321003 
		or skillId == 5121004 or skillId == 5111006 or skillId == 5101002 or skillId == 5221003 or skillId == 5121001
		or skillId == 5121005 or skillId == 5121007 or skillId == 1009 or skillId == 1020) then
		if (not user.RigidbodyComponent:IsOnGround()) then
			log("not on ground")
			return -1
		end
	end
	if (user.CurrentMap.MapInfoComponent:IsUnableToUseSkill()) then
		if (skillId == 4211002 or skillId == 4221001 or skillId == 1121006 or skillId == 1221007
			or skillId == 1321003 or skillId == 4321001 or skillId == 4121008 or skillId == 5101002
			or skillId == 5101004 or skillId == 5121005) then
			log("field skill limit")
			return -1
		end
	end
	
	local body = user.AvatarRendererComponent:GetBodyEntity()
	local left = user.WsUserController:IsFacingLeft()
	
	local skill = _SkillMan:GetSkill(skillId)
	
	---@return integer, string
	local function getAction()
		return _PlayerAttackLogic:GetAction(user, skill, _AttackType.Melee)
	end
	local actionId, actionName = getAction()
	if (actionId == -1 or actionName == nil) then
		return -1
	end
	
	local relativeSpeed = (ac:GetWeaponAttackSpeed(false) + 10) / 16
	local attackType = _AttackType.Melee
	local mobCount = _PlayerAttackLogic:GetMobCount(user, attackType, skillId, skillLevel, lastFinalAttack)
	local damagePerMob = _PlayerAttackLogic:GetAttackCount(user, skillId, skillLevel, false)
	local actionData = _CharacterActionLogic:GetActionData(actionName)
	local totalFrameDelay = actionData:GetTotalFrameDelay(relativeSpeed)
	local actionDelay = actionData:GetActionDelay(relativeSpeed)
	
	local wt = ac.CurrentWeaponType
	local afterImageOrigin = ac.AfterImage.TransformComponent.WorldPosition
	local afterImageTrigger = ac.AfterImage.TriggerComponent
	local _, masteryLevel = _MasteryLogic:GetWeaponMastery(user, wt, attackType, skillId, nil)
	
	---@type table<AttackInfo>
	local attacks = {}
	local levelData = _SkillMan:GetSkillLevelData(skillId, skillLevel)
	
	local ppos = user.TransformComponent.WorldPosition:ToVector2()
	local userPos = user.TransformComponent.WorldPosition:ToVector2()
	local lifePool = user.CurrentMap.LifePoolComponent
	local hitMobs = {}
	local ranged = skillId == _Skills.SWORDMAN_SLASH_BLAST or
					skillId == _Skills.CRUSADER_COMA_AXE or
					skillId == _Skills.CRUSADER_COMA_SWORD or
					skillId == _Skills.KNIGHT_CHARGE_BLOW or
					lastFinalAttack == _Skills.SWORDMAN_SLASH_BLAST
	
	---@type BoxShape
	local boxShape = self:GetBoxShape(user, actionId, nil, masteryLevel, output ~= nil, wt, skillId, userPos, left, levelData)
	local realHitMobCount = lifePool:FindHitMobInBoxShape(boxShape, hitMobs, nil, false)
	
	if (ranged) then
		local range
		if (lastFinalAttack == _Skills.SWORDMAN_SLASH_BLAST) then
			local sbLevel = user.WsCharacterData:GetSkillLevel(_Skills.SWORDMAN_SLASH_BLAST)
			local sbLevelData = _SkillMan:GetSkillLevelData(_Skills.SWORDMAN_SLASH_BLAST, sbLevel)
			if (sbLevelData ~= nil) then
				range = levelData.range
			else
				range = 120
			end
		else
			range = levelData.range
		end
		
		if (realHitMobCount > 0 and range ~= 0) then
			local afterImageData = ac:MakeAfterimageData(actionId, masteryLevel)
			boxShape = _CharacterActionLogic:MakeAfterimageBox(user, left, ppos, wt, actionId, false, afterImageData, range)
			hitMobs = {}
			realHitMobCount = lifePool:FindHitMobInBoxShape(boxShape, hitMobs, nil, false)
		end
	end
	
	---@return number
	local function getDistanceFromHit(comp)
		return boxShape.Position:Distance(comp.Entity.TransformComponent.WorldPosition:ToVector2())
	end
	table.sort(hitMobs, function(a,b) return getDistanceFromHit(a) < getDistanceFromHit(b) end)
	
	local resultMobs = {}
	-- mobCount수에 맞게 결과 조정
	if (mobCount < realHitMobCount) then
		table.move(hitMobs, 1, mobCount, 1, resultMobs)
	else
		resultMobs = hitMobs
	end
	
	if (output ~= nil) then
		local meleeAttackRange = afterImageTrigger.BoxSize
		output.ShootRange = math.max(0.65, meleeAttackRange.x / 2)
		if (realHitMobCount == 0) then
			return 0
		end
	end
	
	if (not finalAttack and not user.StateComponent:ChangeState("NORMAL_ATTACK")) then
		--log("Cannot normal attack")
		return -1
	end
	--if (not _AntiRepeat:Check(user, 1, user.TransformComponent.WorldPosition:ToVector2())) then
	--	return -1
	--end
	
	attacks = _PlayerAttackLogic:MakeAttackInfos(damagePerMob, user.TransformComponent.WorldPosition, boxShape, nil, resultMobs, {})
	local hitMobCounts = #attacks
	local parties = {}
	
	--log("ActionR:", actionR, "actionId:", actionId, "ActionName:", actionName)
	ac:RegisterAfterimage(actionId, masteryLevel, left, actionDelay, true)
	
	user.PlayerControllerComponent.FixedLookAt = user.PlayerControllerComponent.LookDirectionX
	
	-- Random init
	
	local num = {}
	local rndChar = user.CalcDamageComponent:GetRndGenForCharacter()
	
	for i=1,#attacks do
		for p=1,7 do
			num[p] = rndChar:Random()
		end
		local a = attacks[i]
		a.DamagePerMob = damagePerMob
		---@type CalcDamageParam
		local param = {
			MobCount = hitMobCounts,
			DamagePerMob = damagePerMob,
			WeaponType = ac.CurrentWeaponType,
			BulletItemId = 0,
			AttackType = attackType,
			Action = actionId,
			KeyDown = 0,
			ShadowPartner = false,
			PartyCount = #parties
		}
		local mob = a.Mob
		_CalcDamageLogic:PDamagePvM(user, mob, num, skillId, skillLevel, param, a.DamageCli, a.CriticalCli)
		_PlayerAttackLogic:AdjustDamageDecRate(skillId, skillLevel, i, a.DamageCli, lastFinalAttack == _Skills.SWORDMAN_SLASH_BLAST)
		a.DelayBase = actionDelay + math.min(0.07 * (i - 1), 0.28)
	end
	local damageInfos = _PlayerAttackLogic:MakeDamageInfos(user, attacks, hitMobCounts, skillId, skillLevel, left, true)
	local hitEffects = _PlayerAttackLogic:MakeHitEffects(user, attackType, attacks, hitMobCounts, skillId, skillLevel, actionId)
	
	--log("damageInfos:", #damageInfos)
	_PlayerAttackLogic:ProcessHitDamageInfo(skillId, hitMobCounts, damagePerMob, attacks, damageInfos, hitEffects, true)
	
	if (skillId > 0) then
		_PlayerAttackLogic_FinalAttack:TryRegisterFinalAttack(user, skill.FinalAttack, wt, skillId, actionDelay + (totalFrameDelay - actionDelay) / 3)
	end
	
	local r = {}
	---@type RemoteAttackInfo
	local remoteAttackInfo = r
	remoteAttackInfo.BulletItem = 0
	remoteAttackInfo.HitPt = Vector2.zero
	remoteAttackInfo.ShadowPartner = false
	remoteAttackInfo.ShootRange = 0
	remoteAttackInfo.SoulArrow = 0
	remoteAttackInfo.FinalAttackLast = lastFinalAttack
	
	local prone = ac.Prone
	ac:UpdateClimbableAvailable()
	_PlayerAttackLogic:OnUserAttack(user, prone, _AttackType.Melee, actionId, actionDelay, skillId, skillLevel, masteryLevel, 0, attacks, hitMobCounts, parties, damagePerMob, left, r, output ~= nil, ppos, {}, keyDown)
	_PlayerAttackLogic:PlayAction(user, body, nil, actionName, ac:GetWeaponAttackSpeed(false))
	ac:EnableAlertMode(totalFrameDelay)
	return hitMobCounts
	end