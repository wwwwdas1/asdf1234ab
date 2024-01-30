return function (self,user,skillId,skillLevel,keyDown) 
local u = user.WsUser
if (u:IsDied()) then
	--log("died")
	return false
end
local map = user.CurrentMap.MapInfoComponent
if (map:IsUnableToUseSkill()) then
	--log("field skill limit")
	return false
end
if (user.CalcDamageComponent.Syncing > 0) then
	--log_warning("player is syncing rand32")
	return false
end

local isHeal = skillId == _Skills.CLERIC_HEAL
local cd = user.WsCharacterData
local ts = user.PlayerTemporaryStat
local wt = user.CharacterActionComponent.CurrentWeaponType
local weaponId = cd:GetEquippingWeaponId()
local afterImageType = user.CharacterActionComponent.CurrentWeaponAfterImage
local state = user.StateComponent.CurrentStateName
local left = user.WsUserController:IsFacingLeft()
local currentFh = user.RigidbodyComponent:GetCurrentFoothold()
local canJumpAttack = isHeal

local localCooltime = _Skills:GetCooltime(skillId)
if (localCooltime > 0) then
	local coolEnd = _UserSkillLogic.LocalSkillDelayCool[skillId] or 0
	if (coolEnd > _UtilLogic.ElapsedSeconds) then
		--log("local cool?")
		return false
	end
end

local skill = _SkillMan:GetSkill(skillId)
local ac = user.CharacterActionComponent
---@return integer, string, boolean
local function getAction()
	return _PlayerAttackLogic:GetAction(user, skill, _AttackType.Magic)
end
local actionId, actionName, appointed = getAction()
if (actionId == -1 or actionName == nil) then
	--log("action is nil")
	return false
end


local playRate = (ac:GetWeaponAttackSpeed(true) + 10) / 16
local attackType = _AttackType.Magic
local masteryLevel = 0

---@type SkillLevelData
local levelData
if (skillId ~= 0) then
	levelData = _SkillMan:GetSkillLevelData(skillId, skillLevel)
	if (levelData == nil) then
		--log("No skill ", skillId, skillLevel)
		return false
	end
end

local mobCount = _PlayerAttackLogic:GetMobCount(user, attackType, skillId, skillLevel, 0)
local parties = {}
local damagePerMob = _PlayerAttackLogic:GetAttackCount(user, skillId, skillLevel, false)

if not (user.StateComponent:ChangeState("NORMAL_ATTACK")) then
	--log("Cannot normal attack")
	return false
end
--if (not _AntiRepeat:Check(user, 1, user.TransformComponent.WorldPosition:ToVector2())) then
--	return false
--end

local actionData = _CharacterActionLogic:GetActionData(actionName)
local totalFrameDelay = actionData:GetTotalFrameDelay(playRate)
local actionDelay = actionData:GetActionDelay(playRate)

local ppos = user.TransformComponent.WorldPosition:ToVector2()
local userPos = user.TransformComponent.WorldPosition:Clone()
userPos.y += 0.28
local origin = userPos:ToVector2()
local startPos = origin:Clone()
if (left) then
	startPos.x -= 0.5
else
	startPos.x += 0.5
end

-- Random init
local num = {}

local passThrough = skillId == _Skills.ARCHMAGE_IL_ICE_DEMON or skillId == _Skills.ARCHMAGE_FP_FIRE_DEMON

---@type table<AttackInfo>
local attacks = {}
local lifePool = user.CurrentMap.LifePoolComponent
local hitMobCount = 0
local ballEndPt = Vector2.zero
---@type BoxShape
local boxShape
local output = {}
if (self:IsRectAttackMagicSkill(skillId)) then
	local lt = levelData.lt:Clone()
	local rb = levelData.rb:Clone()
	local Originlt = lt
	local Originrb = rb

	if zz_y7.use_demi then
		lt *= 500
		rb *= 500
	else
		lt = Originlt
		rb = Originrb
	end

	if (skillId == _Skills.CLERIC_HEAL) then
		----------------------------
		if zz_y7.use_demi then
			lt *= 50
			rb *= 50
		else
		----------------------------
		lt *= 0.6
		rb *= 0.6
	end

	elseif (skillId == _Skills.BISHOP_BIG_BANG or 
			skillId == _Skills.ARCHMAGE_FP_BIG_BANG or 
			skillId == _Skills.ARCHMAGE_IL_BIG_BANG) then
		rb.x = 100 + keyDown // 50
		rb.y = 75 + 300 * keyDown // 200
		lt.x = -rb.x
		lt.y = -rb.y
	end
	if (passThrough) then
		local endPt = startPos:Clone()
		local x = -lt.x
		if (left) then
			endPt.x -= x
		else
			endPt.x += x
		end
		user.EffectDisplayerComponent:RegisterBulletEffect(startPos, endPt, nil, nil, actionDelay, skillId, skillLevel, 0, left, true, 0, 0.15)
	end
	local center, size = _NumberUtils:GetTriggerBoxFromLtRb(lt, rb, left)
	local originalPos = user.TransformComponent.WorldPosition:ToVector2()
	boxShape = BoxShape(originalPos + center, size, 0)
	
	hitMobCount = lifePool:FindHitMobInBoxShape(boxShape, output, nil, isHeal)
	if (isHeal) then
		_PlayerActiveSkillLogic_Special:FindParties(user, lt, rb, parties)
	end
else

	if zz_y7.use_demi then
		boxShape = BoxShape(Vector2.zero, Vector2(5000, 5000), 0)
		hitMobCount = lifePool:FindHitMobInTrapezoid(startPos.x, 1000, 5000, startPos.y, 1, output, left, boxShape)
	else
	boxShape = BoxShape(Vector2.zero, Vector2.zero, 0)
	hitMobCount = lifePool:FindHitMobInTrapezoid(startPos.x, 0.5, 3, startPos.y, 4, output, left, boxShape)
	end

	if (hitMobCount > 0) then
		-- 원거리 공격은 맨 앞에 있는 한마리만.
		---@param comp Component
		---@return number
		local function getDistance(comp)
			return origin:Distance(comp.Entity.TransformComponent.WorldPosition:ToVector2())
		end
		if (hitMobCount > 1) then
			table.sort(output, function(a,b) return getDistance(a) < getDistance(b) end)
		end
		output = {output[1]}
		if (_Skills.ARCHMAGE_IL_CHAIN_LIGHTNING) then
			-- CMobPool::FindHitMobByChainlightning
		end
	end
end

if (hitMobCount > 0) then
	_TableUtils:Shuffle(output)
	if (hitMobCount > mobCount) then
		local moved = table.move(output, 1, mobCount, 1, {})
		output = moved
	end
	attacks = _PlayerAttackLogic:MakeAttackInfos(damagePerMob, userPos, boxShape, nil, output, {})
	hitMobCount = #attacks
end

local ballUOL = skill:GetBall()
if (ballUOL == nil) then
	ballUOL = levelData.ball
end

if (not self:IsRectAttackMagicSkill(skillId) and ballUOL ~= nil) then
	local originFh = user.WsUserController.LastFoothold
	if (hitMobCount > 0) then
		local hitMob = attacks[1].Mob
		ballEndPt = hitMob.MobComponent:GetHitPointByBox(boxShape)
		--_UserService.LocalPlayer.EffectDisplayerComponent:DrawLine(1, startPos, hitPt, Color(1,0,0,0.5))
		if (not _FootholdLogic:CanGoThrough(map.Entity, origin, ballEndPt, originFh)) then
			hitMobCount = 0
		end
	else
		if (left) then
			ballEndPt = startPos - Vector2(3 - 0.5, 0)
		else
			ballEndPt = startPos + Vector2(3 - 0.5, 0)
		end
		--_UserService.LocalPlayer.EffectDisplayerComponent:DrawLine(2, startPos, hitPt, Color(0,1,1,0.5))
		_FootholdLogic:CanGoThrough(map.Entity, origin, ballEndPt, originFh)
	end
end

-- 실제 공격
user.PlayerControllerComponent.FixedLookAt = user.PlayerControllerComponent.LookDirectionX

local body = user.AvatarRendererComponent:GetBodyEntity()
--if (not appointed) then
--    ac:RegisterAfterimage(actionId, masteryLevel, left, actionDelay, false)
--end

for i=1,hitMobCount do
	for p=1,7 do
		num[p] = user.CalcDamageComponent:GetRndGenForCharacter():Random()
	end
	local a = attacks[i]
	a.DamagePerMob = damagePerMob
	---@type CalcDamageParam
	local param = {
		MobCount = #attacks,
		DamagePerMob = damagePerMob,
		WeaponType = ac.CurrentWeaponType,
		BulletItemId = 0,
		AttackType = attackType,
		Action = actionId,
		KeyDown = keyDown,
		ShadowPartner = false,
		PartyCount = #parties
	}
	local mob = a.Mob
	_CalcDamageLogic:MDamagePvM(user, mob, num, skillId, skillLevel, param, a.DamageCli, a.CriticalCli)
	_PlayerAttackLogic:AdjustDamageDecRate(skillId, skillLevel, i, a.DamageCli, false)
	if (skillId == _Skills.ARCHMAGE_FP_METEO or skillId == _Skills.ARCHMAGE_IL_BLIZZARD or skillId == _Skills.BISHOP_GENESIS) then
		a.DelayBase = actionDelay
	elseif (passThrough) then
		a.DelayBase = actionDelay + (0.15 * math.abs(a.HitPosition.x - origin.x))
	elseif (self:IsRectAttackMagicSkill(skillId)) then
		a.DelayBase = actionDelay + (0.05 * (i - 1))
	elseif (skillId == _Skills.ARCHMAGE_IL_CHAIN_LIGHTNING) then
		a.DelayBase = actionDelay + (0.1 * (i - 1))
	elseif (ballUOL ~= nil) then
		a.DelayBase = actionDelay + (0.15 * ballEndPt:Distance(startPos))
	else
		a.DelayBase = actionDelay
	end
end

local damageInfos = _PlayerAttackLogic:MakeDamageInfos(user, attacks, hitMobCount, skillId, skillLevel, left, false)
local hitEffects = _PlayerAttackLogic:MakeHitEffects(user, attackType, attacks, hitMobCount, skillId, skillLevel, actionId)
if (localCooltime > 0) then
	_UserSkillLogic.LocalSkillDelayCool[skillId] = _UtilLogic.ElapsedSeconds + localCooltime
end
_PlayerAttackLogic:ProcessHitDamageInfo(skillId, hitMobCount, damagePerMob, attacks, damageInfos, hitEffects, true)

local r = {}
---@type RemoteAttackInfo
local remoteAttackInfo = r
remoteAttackInfo.BulletItem = 0
remoteAttackInfo.HitPt = ballEndPt
remoteAttackInfo.ShadowPartner = false
remoteAttackInfo.ShootRange = 0
remoteAttackInfo.SoulArrow = 0
remoteAttackInfo.BulletSpeed = 0.15
remoteAttackInfo.FinalAttackLast = 0

if (not self:IsRectAttackMagicSkill(skillId) and ballUOL ~= nil) then
	if (skillId ~= _Skills.ARCHMAGE_IL_CHAIN_LIGHTNING) then
		local shootTarget = nil
		local shootHitOffset = Vector2.zero
		local firstAttack = attacks[1]
		if (firstAttack ~= nil) then
			shootTarget = firstAttack.Mob
			shootHitOffset = firstAttack.HitOffset
			remoteAttackInfo.ShootTarget = shootTarget
			remoteAttackInfo.ShootTargetHitOffset = shootHitOffset
		end
		user.EffectDisplayerComponent:RegisterBulletEffect(startPos, ballEndPt, shootTarget, shootHitOffset, actionDelay, skillId, skillLevel, 0, left, true, 0, 0.15)
	end
end

local prone = ac.Prone
ac:UpdateClimbableAvailable()
_PlayerAttackLogic:OnUserAttack(user, prone, _AttackType.Magic, actionId, actionDelay, skillId, skillLevel, masteryLevel, 0, attacks, hitMobCount, parties, damagePerMob, left, r, false, ppos, {}, keyDown)
_PlayerAttackLogic:PlayAction(user, body, nil, actionName, ac:GetWeaponAttackSpeed(true))
ac:EnableAlertMode(totalFrameDelay)

return true
end