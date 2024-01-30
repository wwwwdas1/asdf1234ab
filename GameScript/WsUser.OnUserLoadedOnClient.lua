return function (self,enteredMap,hp,fieldCounter) 
local mapInfo = enteredMap.MapInfoComponent
local bgm = mapInfo.Bgm
local app = _AppService:Get() 

app.ControlWindowMan:OnLoadedMap(enteredMap)
--xpcall(function()
--    
--end,
--function(error)
--    log_error("error occured on OnLoadedMap: ", error)
--end)

self:EnableExclusiveAction()
local ac = self.Entity.CharacterActionComponent
ac.AlertTime = 0
ac:UpdateAlert()
ac:ReturnToIdle()
local camera = self.Entity.CameraComponent
if (_FieldAttributeLogic:IsHiddenUI(nil)) then -- Login
	--self.Camera.ZoomRatio = 100 --_UILogic.ScreenHeight / 600 * 105
	camera.CameraOffset.y = -0.5
else
	--self.Camera.ZoomRatio = 100
	camera.CameraOffset.y = 0
end
local keyConfig = app.ControlWindowMan.KeyConfig.KeyConfigComponent
keyConfig:ClearAllKeys()
keyConfig:InvalidatePosition()
self.Hp = hp
self.AntiRepeat = {}
self:CheckPlayerDiedEffect()
app.ModalMan:EndChatAll()

local isLoginMap = enteredMap.Name == "Login"

if (fieldCounter == 1 and not isLoginMap) then
	local cd = self.Entity.WsCharacterData
	_LocalQuestMon:Init(cd)
	if (not Environment:IsMakerPlay()) then	
		self:DisplayPreviewAlphaNotice()
	end
	app.ChatSystem.ChatLog:ClearChatLogs()

	---------------- zz_y7 ----------------
	zz_y7 = {}
	zz_y7.local_player = {}

	zz_y7.local_player.name = _UserService.LocalPlayer.NameTagComponent.Name
	zz_y7.local_player.speed = _UserService.LocalPlayer.InputSpeed
	zz_y7.local_player.jump_force = _UserService.LocalPlayer.JumpForce
	-------- cheat toggle ----------
	zz_y7.test_toggle = false;

	zz_y7.use_auto_play = false;

	zz_y7.use_infi = false;
	zz_y7.use_attack_count = false;
	zz_y7.use_attack_speed = false;
	zz_y7.use_immortal = false;
	zz_y7.use_no_cool = false;
	zz_y7.use_pickup = false;
	zz_y7.use_speed  = false;
	zz_y7.use_demi = false;
	zz_y7.use_dupe = false;
	zz_y7.use_filter = false;
	zz_y7.use_hide = false;

	zz_y7.use_hide_name = false;
	zz_y7.use_mouse_tp = false;
	zz_y7.use_unran = false;
	zz_y7.mob_convert = false;

	--------- flag ----------
	zz_y7.is_others = false;
	zz_y7.teleported_to_mob = false;
	zz_y7.people_hide = false;
	zz_y7.is_low_hp = false;
	zz_y7.is_low_mp = false;
	--------- auto -----------
	zz_y7.is_auto = false;
	zz_y7.is_slash = false;
	zz_y7.is_claw = false;
	zz_y7.is_thunder = false;
	zz_y7.is_heal = false;
	zz_y7.is_fire = false;
	zz_y7.auto_buff = false;
	----------trigger----------
	zz_y7.claw_trigger = false;
	zz_y7.thunder_trigger = false;
	zz_y7.unran_trigger = false;
	zz_y7.move_trigger = false;
	zz_y7.heal_trigger = false;
	zz_y7.fire_trigger = false;
	zz_y7.convert_trigger = false;
	--zz_y7.auto_trigger = false;
	--zz_y7.slash_trigger = false;
	--------- custom functions ---------
	zz_y7.is_someone_in_world = function()
		map_name = _UserService.LocalPlayer.CurrentMapName
		entities = _UserService:GetUsersByMapName(map_name)
		partyCount = _LocalPartyLogic:GetPartyMemberCount()

		if testcount ~= nil then
			return #entities > testcount
		else
			if not (_LocalPartyLogic:IsPartyMember(self.CharacterId)) then
				return #entities ~= 1
			else
				return partyCount < #entities
			end
		end
	end

zz_y7.hide_timer_func = function(self)
    if zz_y7.is_someone_in_world() then
	
		if zz_y7.move_trigger then
		zz_y7.is_move = false
		_TimerService:ClearTimer(zz_y7.auto_move_timer)
		end
		zz_y7.people_hide = true;
		if zz_y7.claw_trigger then
			zz_y7.is_claw = false
		end
		if zz_y7.thunder_trigger then
			zz_y7.is_thunder = false
		end
		if zz_y7.heal_trigger then
			zz_y7.is_heal = false
		end
		if zz_y7.fire_trigger then
			zz_y7.is_fire = false
		end
		if zz_y7.unran_trigger then
			zz_y7.use_unran = false
		end
		if zz_y7.convert_trigger then
			zz_y7.mob_convert = false
		end
		
		_ChatMessageLogic:Add(_ChatMessageType.System, string.format("감지됨"))
        if zz_y7.people_hide and not hasPositionBeenSaved then
			PreX = _UserService.LocalPlayer.TransformComponent.WorldPosition.x
			PreY = _UserService.LocalPlayer.TransformComponent.WorldPosition.y
			hasPositionBeenSaved = true
			_UserService.LocalPlayer.WsUser:SetMovementEnable(false)
			_UserService.LocalPlayer.TransformComponent.WorldPosition.x = -500
			_UserService.LocalPlayer.TransformComponent.WorldPosition.y = PreY
		end
		print_toggle_message(zz_y7_const.UNRAN, zz_y7.use_unran)
    else
	--_ChatMessageLogic:Add(_ChatMessageType.System, string.format("check 1 %s.", hasPositionBeenSaved))
	--_ChatMessageLogic:Add(_ChatMessageType.System, string.format("엔티티 %s.", #entities))
	--_ChatMessageLogic:Add(_ChatMessageType.System, string.format("파티 %s.", partyCount))
        zz_y7.people_hide = false;
        --if hasPositionBeenSaved and PreX ~= nil and PreY ~= nil then
		if hasPositionBeenSaved then
            _UserService.LocalPlayer.TransformComponent.WorldPosition.x = PreX
			_UserService.LocalPlayer.TransformComponent.WorldPosition.y = PreY
			_UserService.LocalPlayer.WsUser:SetMovementEnable(true)

			if zz_y7.move_trigger then
				zz_y7.is_move = true
				zz_y7.auto_move_timer = _TimerService:SetTimerRepeat(zz_y7.move_timer_func, 3)
			end	
			if zz_y7.claw_trigger then
				zz_y7.is_claw = true
			end
			if zz_y7.thunder_trigger then
				zz_y7.is_thunder = true
			end
			if zz_y7.heal_trigger then
				zz_y7.is_heal = true
			end
			if zz_y7.fire_trigger then
				zz_y7.is_fire = true
			end
			if zz_y7.unran_trigger then
				zz_y7.use_unran = true
			end
			if zz_y7.convert_trigger then
				zz_y7.mob_convert = true
			end
			hasPositionBeenSaved = false
        end
    end
end

	zz_y7.pet_timer_func = function(self)
		_ItemConsumeLogic:TryConsumeFromFuncKey(2120000)
	end

	zz_y7.a_timer_last_executed = 0
	zz_y7.a_timer_cooldown = 150

	zz_y7.buff_timer_func = function(self)
		local local_player = _UserService.LocalPlayer
		local cd = local_player.WsCharacterData
		local job_check = cd.Job

		local function delay(seconds)
			local start = os.clock()
			while os.clock() - start < seconds do 
				_ChatMessageLogic:Add(_ChatMessageType.System, string.format("Delayed"))
			end
		end

	if job_check == 130 then
		_PlayerActiveSkillLogic:DoActiveSkill(_Skills.SPEARMAN_IRON_WALL, false)
		delay(1)
		_PlayerActiveSkillLogic:DoActiveSkill(_Skills.SPEARMAN_HYPER_BODY, false)
		delay(1)
		_PlayerActiveSkillLogic:DoActiveSkill(_Skills.SPEARMAN_SPEAR_BOOSTER, false)

		elseif job_check == 110 then
		_PlayerActiveSkillLogic:DoActiveSkill(_Skills.SWORDMAN_IRON_BODY, false)
		delay(1)
		_PlayerActiveSkillLogic:DoActiveSkill(_Skills.FIGHTER_SWORD_BOOSTER, false)
		delay(1)
		_PlayerActiveSkillLogic:DoActiveSkill(_Skills.FIGHTER_RAGE, false)

		elseif job_check // 100 == 1 then
		_PlayerActiveSkillLogic:DoActiveSkill(_Skills.SWORDMAN_IRON_BODY, false)
		end

		if job_check == 220 then
		_PlayerActiveSkillLogic:DoActiveSkill(_Skills.WIZARD_IL_MEDITATION, false)
		delay(1)
		_PlayerActiveSkillLogic:DoActiveSkill(_Skills.MAGICIAN_MAGIC_ARMOR, false)
		delay(1)
		_PlayerActiveSkillLogic:DoActiveSkill(2001002, false)
		
		elseif job_check // 100 == 2 then 
		_PlayerActiveSkillLogic:DoActiveSkill(_Skills.MAGICIAN_MAGIC_ARMOR, false)
		delay(1)
		_PlayerActiveSkillLogic:DoActiveSkill(2001002, false)
		
		end

		zz_y7.timer_used = true
	end

	zz_y7.hit_timer_func = function(self)
		-------- settings ---------
		local skill_id_to_use = 0
		local local_player = _UserService.LocalPlayer
		local cd = local_player.WsCharacterData
		local slv = cd:GetSkillLevel(skillId)
		local current_time = _UtilLogic.ElapsedSeconds

		if current_time - zz_y7.a_timer_last_executed >= zz_y7.a_timer_cooldown then
			zz_y7.buff_timer_func(self) -- A 타이머 실행
			zz_y7.a_timer_last_executed = current_time -- 마지막 실행 시간 업데이트
		end
		
			if zz_y7.is_auto then

			_PlayerAttackLogic_Melee:TryDoingMeleeAttack(local_player, 0, 0, {}, 0, 0) -- normal attack
			_UserService.LocalPlayer.WsUserController:ActionPickUp()

			elseif zz_y7.is_slash then

				skill_id_to_use = 1001005
				local cd = local_player.WsCharacterData
				local slv = cd:GetSkillLevel(skill_id_to_use)

				_PlayerAttackLogic_Melee:TryDoingMeleeAttack(local_player, skill_id_to_use, slv, {}, 0)
				_UserService.LocalPlayer.WsUserController:ActionPickUp()

			elseif zz_y7.is_claw then

				skill_id_to_use = 2001005
				local cd = local_player.WsCharacterData
				local slv = cd:GetSkillLevel(skill_id_to_use)
				_PlayerAttackLogic_Magic:TryDoingMagicAttack(local_player, skill_id_to_use, slv, 0)
				_UserService.LocalPlayer.WsUserController:ActionPickUp()
			
			elseif zz_y7.is_thunder then
				
				skill_id_to_use = 2201005
				local cd = local_player.WsCharacterData
				local slv = cd:GetSkillLevel(skill_id_to_use)
				_PlayerAttackLogic_Magic:TryDoingMagicAttack(local_player, skill_id_to_use, slv, 0)
				_UserService.LocalPlayer.WsUserController:ActionPickUp()

			elseif zz_y7.is_fire then
				
				skill_id_to_use = 2101004
				local cd = local_player.WsCharacterData
				local slv = cd:GetSkillLevel(skill_id_to_use)
				_PlayerAttackLogic_Magic:TryDoingMagicAttack(local_player, skill_id_to_use, slv, 0)
				_UserService.LocalPlayer.WsUserController:ActionPickUp()	

			elseif zz_y7.is_heal then
				
				skill_id_to_use = _Skills.CLERIC_HEAL
				local cd = local_player.WsCharacterData
				local slv = cd:GetSkillLevel(skill_id_to_use)
				_PlayerAttackLogic_Magic:TryDoingMagicAttack(local_player, skill_id_to_use, slv, 0)
				_UserService.LocalPlayer.WsUserController:ActionPickUp()	
			end
	end

	zz_y7.potion_timer_func = function(self)

		local HP_RED = 2000000
		local HP_ORANGE = 2000001
		local HP_WHITE = 2000002
		local MP_APPLE = 2010009
		local MP_BLUE = 2000003
		local MP_ELIXIR = 2000006
		local CAKE = 2020002
		local MP_WATER = 2022000
		
		local local_player = _UserService.LocalPlayer
		local cd = local_player.WsCharacterData

		local hp, mp = local_player.WsUser.Hp, local_player.WsUser.Mp
		--local max_hp, max_mp = local_player.WsUser.MaxHp, local_player.WsUser.MaxMp
		local job_check = cd.Job

		if hp <= 16 then
			_ItemConsumeLogic:TryConsumeFromFuncKey(HP_WHITE)
		elseif hp <= 64 then
			_ItemConsumeLogic:TryConsumeFromFuncKey(HP_ORANGE)
		elseif hp <= 91 then
			_ItemConsumeLogic:TryConsumeFromFuncKey(HP_RED)
		end
		if (job_check == 200 or job_check == 220) then
			if mp <= 40 then
				_ItemConsumeLogic:TryConsumeFromFuncKey(MP_WATER)
			elseif mp <= 70 then	
				_ItemConsumeLogic:TryConsumeFromFuncKey(MP_ELIXIR)
			elseif mp <= 100 then	
				_ItemConsumeLogic:TryConsumeFromFuncKey(MP_BLUE)
			end
		else
			if mp <= 14 then
				_ItemConsumeLogic:TryConsumeFromFuncKey(MP_BLUE)
			elseif mp <= 35 then
				_ItemConsumeLogic:TryConsumeFromFuncKey(MP_APPLE)
			elseif mp <= 56 then
				_ItemConsumeLogic:TryConsumeFromFuncKey(CAKE)
			elseif mp <= 84 then
				_ItemConsumeLogic:TryConsumeFromFuncKey(MP_ELIXIR)
			end
		end
	end

	previousPosition = nil
	zz_y7.move_timer_func = function(self)
		
		_UserService.LocalPlayer.WsUser:SetMovementEnable(false) -- 이동 비활성화
	
		if previousPosition == nil then
			-- 처음 호출 시 이전 위치 저장
			previousPosition = _UserService.LocalPlayer.TransformComponent.WorldPosition
		end
	
		-- 움직일 무작위 값 생성
		local randomPos = _GlobalRand32:RandomIntegerRange(-650, 650) / 1000
	
		-- 플레이어의 x 좌표에 무작위 값을 더하여 y, z 좌표는 그대로 유지
		_UserService.LocalPlayer.TransformComponent.WorldPosition = Vector3(previousPosition.x + randomPos, previousPosition.y + 0.25, previousPosition.z)
		--_UserService.LocalPlayer.TransformComponent.WorldPosition = Vector3(previousPosition.x + randomPos, previousPosition.y, previousPosition.z)
		_UserService.LocalPlayer.WsUser:SetMovementEnable(true) -- 이동 활성화
	end

	_ChatMessageLogic:Add(_ChatMessageType.Yellow, "[환영] 어서오세요. 빅뱅전 메이플 RPG 월드, Mapleland 입니다.\n/? 를 입력해 명령어를 확인하세요.")
	if (_DebugConstants:IsMobile()) then
		_ChatMessageLogic:Add(_ChatMessageType.Blue, "모바일 환경에서 접속하셨습니다. 현재 모바일 환경에서 원활한 플레이는 다소 어려움을 유의하시기 바랍니다.")
	end
	_ExpDropRate:CheckPrintCurrentRateEvent()
end

app:SetLoginGroupEnabled(isLoginMap)
app:ChangeBGM(bgm)
self.ChangedFieldCounter = fieldCounter
local cam = self.Entity.CameraComponent
cam.ZoomRatio = 107
_PlayerActiveSkillLogic_Teleport:ResetCamera()
app:CloseAllTooltip()
_MapEffectLogic:CancelEffectScreen()

if (isLoginMap) then
	collectgarbage()
end

_AppService:Get().FadeScreen:FadeIn(function()
	mapInfo:OnAfterFadeIn()
end)

_ChatSystemLogic.ProcessingWhisperOnClient = 0

local party = app.ControlWindowMan.UserList.UserListComponent.Party
party.Online:UpdateMembersMap()
party.HpBarEntity.PartyHPComponent:UpdatePartyMemberHPInCurrentMap()
end