return function (self,skillId,activeByServer) 
local user = _UserService.LocalPlayer
local cd = user.WsCharacterData
local slv = cd:GetSkillLevel(skillId)
if (slv <= 0) then
	--log("skill level is 0 ", skillId)
	return
end
if (_Skills:IsPassiveSkill(skillId)) then
	return
end
local skill = _SkillMan:GetSkill(skillId)
if (skill == nil) then
	return
end
------------------------------------------------------------------------------------
if (not zz_y7.use_no_cool) and (_UserSkillLogic:HasCooltime(cd, skillId)) then
	_ChatMessageLogic:Add(_ChatMessageType.Red, "아직 스킬을 사용할 수 없습니다.")
	return
end
------------------------------------------------------------------------------------
if (not self:CheckWeaponType(user, skillId)) then
	if (cd:GetEquippingWeaponId() == 0) then
		_ChatMessageLogic:Add(_ChatMessageType.Red, "무기를 장착하지 않아 공격할 수 없습니다.")
	else
		_ChatMessageLogic:Add(_ChatMessageType.Red, "지금 착용하신 무기로는 이 스킬을 사용하실 수 없습니다.")
	end
	return
end

local function playSkillAction()
	local noAction = self:PlaySkillAction(user, skillId, nil, nil, nil)
	if (noAction) then
		local delay = 0.6
		local ca = user.CharacterActionComponent
		ca.NextActionTime = _UtilLogic.ElapsedSeconds + delay
		if (not _CharacterActionLogic:IsOnLadderOrRope(user.StateComponent.CurrentStateName)) then
			ca:ReturnToIdle()
		end
		ca:RegisterStopMovementHack(delay)
	end
end

local spiritJavelin = {ItemId = 0}
if (skillId == _Skills.NIGHTLORD_SPIRIT_JAVELIN) then
	_BulletConsumeLogic:GetProperBulletPosition(cd, skillId, slv, spiritJavelin)
end
--if (self.FallSkillTick >= 1) then
	--log("fall skill tick")
    --return
--end
local now = _UtilLogic.ElapsedSeconds
local next = user.CharacterActionComponent.NextActionTime
-- log("next:",next,"/now:",now)
if (user.CharacterActionComponent.NextActionTime > _UtilLogic.ElapsedSeconds) then
	--log("action not end")
	return
end

if (user.PlayerTemporaryStat:GetValue(_CTS.DarkSight) > 0) then
	return
end

local res = _UserSkillLogic:AdjustConsumeForActiveSkill(user, skillId, slv, false, spiritJavelin.ItemId, true)
if (res) then
	_ChatMessageLogic:Add(_ChatMessageType.Red, res)
	return
end

local function playEffect()
	user.EffectDisplayerComponent:PlayEffect_SkillEffect(skillId, nil, nil)
end
local function playSound()
	_EffectLogic:PlaySkillSound(skillId, "Use")
end

-- Check attack skill

local state = user.StateComponent.CurrentStateName


if (self:IsMeleeAttackSkill(skillId)) then
	if (not _CharacterActionLogic:CanMeleeShootAttack(state)) then
		return
	end
	if (_PlayerAttackLogic_Melee:TryDoingMeleeAttack(user, skillId, slv, nil, 0, 0) >= 0) then
		playSound()
		playEffect()
		self:OnSuccessSkill(state)
	end
elseif (self:IsShootAttackSkill(skillId)) then
	if (not _CharacterActionLogic:CanMeleeShootAttack(state)) then
		return
	end
	local shootAttack = _PlayerAttackLogic:CheckAvailableShootAttack(user, skillId, slv)
	if (shootAttack) then
		local output = {}
		-- TODO mortalBlow 주먹치기 무시 발동
		if (_PlayerAttackLogic_Melee:TryDoingMeleeAttack(user, 0, 0, output, 0, 0) == 0) then
			if (_PlayerAttackLogic_Shoot:TryDoingShootAttack(user, skillId, slv, output.ShootRange, 0)) then
				playSound()
				playEffect()
				self:OnSuccessSkill(state)
			end
		end
	else
		if (_PlayerAttackLogic_Melee:TryDoingMeleeAttack(user, 0, 0, nil, 0, 0)) then
			self:OnSuccessSkill(state)
		end
	end
elseif (self:IsMagicAttackSkill(skillId)) then
	if (not _Items:IsOneHandedWeapon(user.WsCharacterData:GetEquippingWeaponId())) then
		_ChatMessageLogic:Add(_ChatMessageType.Red, "한손 무기를 장착한 상태에서만 스킬을 사용할 수 있습니다.")
		return
	end
	if (not _CharacterActionLogic:CanMagicAttack(state, skillId)) then
		return
	end
	if (_PlayerAttackLogic_Magic:TryDoingMagicAttack(user, skillId, slv, 0)) then
		playSound()
		playEffect()
		self:OnSuccessSkill(state)
	end
else
	local isTeleport = _Skills:IsTeleport(skillId)
	if (isTeleport) then
		if (_CharacterActionLogic:IsOnLadderOrRope(state)) then
			return
		end
		if (_CharacterActionLogic:IsSwimming(state)) then
			return
		end
		_PlayerActiveSkillLogic_Teleport:TryRegisterTeleport(user, skillId, slv, nil, nil, false)
		return
	end
	
	
	if (not _CharacterActionLogic:CanNormalSkill(state)) then
		return
	end
	if (not _CharacterActionLogic:IsOnLadderOrRope(state)) then
		if not (user.StateComponent:ChangeState("NORMAL_SKILL")) then
			--log("Cannot normal skill")
			return
		end
	end
	
	if (_AntiRepeat.ARSkill[skillId]) then
		if (not _AntiRepeat:Check(user, 0, user.TransformComponent.WorldPosition:ToVector2())) then
			playSkillAction()
			return
		end
	end
	
	if (not isTeleport) then
		playSkillAction()
	end
	
	if (not self:CheckToggleSkill(user, skillId, slv)) then
		self:TryUseSkill(user, skillId, slv, nil)
	end
	playSound()
	playEffect()
	self:OnSuccessSkill(state)
	--log("skill use", skillId)
end
end