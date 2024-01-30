---------- zz_y7 -------------
local zz_y7_const = {
	TEST			= "테스트";
	HELP			= "?";

	PEOPLE			= "감지";

	INFI_ATTACK 	= "무공";
	ATTACK_COUNT	= "타수";
	ATTACK_SPEED	= "공속";
	IMMORTAL		= "무적";
	NO_COOL			= "노쿨";
	PICKUP			= "획득";
	SPEED			= "이속";
	DEMI            = "데미";
	FILTER          = "필터";
	DUPE            = "듀프";
	CONVERT         = "변환";

	AUTO_NORMAL     = "자동";
	AUTO_SLASH		= "슬래시";
	AUTO_CLAW       = "클로";
	AUTO_THUNDER    = "썬볼";
	AUTO_FIRE       = "파이어";
	AUTO_MOVE       = "무브";
	AUTO_HEAL       = "힐";

	INVEN			= "인벤";
	HIDE_NAME		= "닉가리기";
	MOUSE_TP		= "마박";
	ONE_CLICK       = "원클릭";

	UNRAN           = "카톡";
	GHOST           = "투명";
	PET             = "펫";
}

local print_toggle_message = function(feature_name, if_toggle_on)
	_ChatMessageLogic:Add(_ChatMessageType.System, 
		("%s: %s"):format(
			feature_name,
			if_toggle_on and "활성화됨" or "비활성화됨"
		)
	)
end

---------- zz_y7 -------------

return function (self) 

self.ClientCommands = {
	["도움말"] = self.Help,
	["교환"] = self.Trade,
	["게임교환"] = self.Trade,
	["모두"] = self.ToAll,
	["파티"] = self.ToParty,
	["채널"] = self.ToChannel,
	["귓말"] = self.ToWhisper,
	["귓"] = self.ToWhisper,
	["찾기"] = self.Find,
	["파티만들기"] = self.CreateParty,
	["파티탈퇴"] = self.LeaveParty,
	["파티초대"] = self.InviteParty,
	["파티강퇴"] = self.KickParty,
	
	["귓숨김"] = self.__TEMP__BlockWhisperON, -- FIXME
	["귓보임"] = self.__TEMP__BlockWhisperOFF, -- FIXME


	------------------------------------------------- zz_y7 -------------------------------------------------
	[zz_y7_const.HELP] = function(self)
		--> add yourself : ) ;;
		local message = [[
			----------------- 명령어 -----------------
			[사냥]
			/노쿨 /공속 /카톡(언랜) /변환

			[유틸]
			/마박 /필터 /감지 /투명

			[자동]
			/자동 /슬래시 /클로 /썬볼 /파이어 /무브 /펫
			------------------------------------------
		]]
		_ChatMessageLogic:Add(_ChatMessageType.System, message)
	end,
	------------------- Toggle Cheats -------------------

	[zz_y7_const.UNRAN] = function(self, user, argc, args)
		local mapId = tonumber(_UserService.LocalPlayer.CurrentMapName:sub(2))
		_ChatMessageLogic:Add(_ChatMessageType.System, string.format("%s", mapId))
		unran_type = tonumber(args[2])
		if unran_used == nil then
			unran_used = false
		end
		if mapId <= 1020001 then
			_UtilDlgLogic:Show("사용할 수 없는 맵 입니다.")
			return
		end
		if not zz_y7.use_hide then
			_UtilDlgLogic:Show("감지 기능이 선행되어야 합니다.")
		elseif unran_used == false and unran_type ~= 1 and unran_type ~= 2 then
			_UtilDlgLogic:Show("입력할 수 없는 값 입니다. 1 또는 2만 입력할 수 있습니다.")
			return
		elseif unran_type == 1 then
			unran_used = true
			zz_y7.use_unran = true
			zz_y7.unran_trigger = true
			print_toggle_message(zz_y7_const.UNRAN, zz_y7.use_unran)
		elseif unran_type == 2 then
			unran_used = true
			zz_y7.use_unran = true
			zz_y7.unran_trigger = true
			print_toggle_message(zz_y7_const.UNRAN, zz_y7.use_unran)
		elseif unran_used == true and unran_type == nil then
			unran_used = false
			zz_y7.unran_trigger = false
			zz_y7.use_unran = not zz_y7.use_unran
			print_toggle_message(zz_y7_const.UNRAN, zz_y7.use_unran)
		end
	end,
	[zz_y7_const.PEOPLE] = function(self, user, argc, args)
		testcount = tonumber(args[2])

		if testcount == nil then
			zz_y7.use_hide = not zz_y7.use_hide
		elseif testcount <= 0 then
			_UtilDlgLogic:Show("입력할 수 없는 값 입니다.")
			return
		elseif testcount ~= nil then
			_ChatMessageLogic:Add(_ChatMessageType.System, string.format("맵 최대 허용 인원은 %s명 입니다.", testcount))
			zz_y7.use_hide = not zz_y7.use_hide
		end
		if zz_y7.use_hide then
			hasPositionBeenSaved = false
			_UserService.LocalPlayer.NameTagComponent.FontColor = Color(0, 1, 1, 1)
			zz_y7.auto_play_timer = _TimerService:SetTimerRepeat(zz_y7.hide_timer_func, 0.4)
		else
			_TimerService:ClearTimer(zz_y7.auto_play_timer)
			zz_y7.people_hide = false;
			zz_y7.use_unran = false;
			_UserService.LocalPlayer.NameTagComponent.FontColor = Color(1, 1, 1, 1)
			if PreX ~= nil and PreY ~= nil then
				_UserService.LocalPlayer.TransformComponent.WorldPosition.x = PreX
				_UserService.LocalPlayer.TransformComponent.WorldPosition.y = PreY
				_UserService.LocalPlayer.WsUser:SetMovementEnable(true)
			end
			if zz_y7.claw_trigger then
				zz_y7.claw_trigger = false
			elseif zz_y7.thunder_trigger then
				zz_y7.thunder_trigger = false
			elseif zz_y7.unran_trigger then
				zz_y7.unran_trigger = false
			elseif zz_y7.move_trigger then
				zz_y7.move_trigger = false
				zz_y7.is_move = false
			end
		end
		print_toggle_message(zz_y7_const.PEOPLE, zz_y7.use_hide)
		print_toggle_message(zz_y7_const.UNRAN, zz_y7.use_unran)
		print_toggle_message(zz_y7_const.AUTO_MOVE, zz_y7.is_move)
	end,
	[zz_y7_const.AUTO_NORMAL] = function(self)
		zz_y7.is_auto = not zz_y7.is_auto
		zz_y7.auto_trigger = not zz_y7.auto_trigger
		if zz_y7.is_auto then
			zz_y7.auto_hit_timer = _TimerService:SetTimerRepeat(zz_y7.hit_timer_func, 0.2)
			zz_y7.auto_pot_timer = _TimerService:SetTimerRepeat(zz_y7.potion_timer_func, 0.7)
		else
			_TimerService:ClearTimer(zz_y7.auto_hit_timer)
			_TimerService:ClearTimer(zz_y7.auto_pot_timer)
		end
		print_toggle_message(zz_y7_const.AUTO_NORMAL, zz_y7.is_auto)
	end,
	[zz_y7_const.AUTO_SLASH] = function(self)
		zz_y7.is_slash = not zz_y7.is_slash
		zz_y7.slash_trigger = not zz_y7.slash_trigger
		if zz_y7.is_slash then
			zz_y7.auto_hit_timer = _TimerService:SetTimerRepeat(zz_y7.hit_timer_func, 0.2)
			zz_y7.auto_pot_timer = _TimerService:SetTimerRepeat(zz_y7.potion_timer_func, 0.7)
		else
			_TimerService:ClearTimer(zz_y7.auto_hit_timer)
			_TimerService:ClearTimer(zz_y7.auto_pot_timer)
		end
		print_toggle_message(zz_y7_const.AUTO_SLASH, zz_y7.is_slash)
	end,
	[zz_y7_const.AUTO_CLAW] = function(self)
		zz_y7.is_claw = not zz_y7.is_claw
		zz_y7.claw_trigger = not zz_y7.claw_trigger
		if zz_y7.is_claw then
			zz_y7.auto_hit_timer = _TimerService:SetTimerRepeat(zz_y7.hit_timer_func, 0.2)
			zz_y7.auto_pot_timer = _TimerService:SetTimerRepeat(zz_y7.potion_timer_func, 0.7)
		else
			_TimerService:ClearTimer(zz_y7.auto_hit_timer)
			_TimerService:ClearTimer(zz_y7.auto_pot_timer)
		end
		print_toggle_message(zz_y7_const.AUTO_CLAW, zz_y7.is_claw)
	end,
	[zz_y7_const.AUTO_THUNDER] = function(self)
		zz_y7.is_thunder = not zz_y7.is_thunder
		zz_y7.thunder_trigger = not zz_y7.thunder_trigger
		if zz_y7.is_thunder then
			zz_y7.auto_hit_timer = _TimerService:SetTimerRepeat(zz_y7.hit_timer_func, 0.2)
			zz_y7.auto_pot_timer = _TimerService:SetTimerRepeat(zz_y7.potion_timer_func, 0.7)
		else
			_TimerService:ClearTimer(zz_y7.auto_hit_timer)
			_TimerService:ClearTimer(zz_y7.auto_pot_timer)
		end
		print_toggle_message(zz_y7_const.AUTO_THUNDER, zz_y7.is_thunder)
	end,
	[zz_y7_const.AUTO_HEAL] = function(self)
		zz_y7.is_heal = not zz_y7.is_heal
		zz_y7.heal_trigger = not zz_y7.heal_trigger
		if zz_y7.is_heal then
			zz_y7.auto_hit_timer = _TimerService:SetTimerRepeat(zz_y7.hit_timer_func, 0.2)
			zz_y7.auto_pot_timer = _TimerService:SetTimerRepeat(zz_y7.potion_timer_func, 0.7)
		else
			_TimerService:ClearTimer(zz_y7.auto_hit_timer)
			_TimerService:ClearTimer(zz_y7.auto_pot_timer)
		end
		print_toggle_message(zz_y7_const.AUTO_HEAL, zz_y7.is_heal)
	end,
	[zz_y7_const.AUTO_FIRE] = function(self)
		zz_y7.is_fire = not zz_y7.is_fire
		zz_y7.fire_trigger = not zz_y7.fire_trigger
		if zz_y7.is_fire then
			zz_y7.auto_hit_timer = _TimerService:SetTimerRepeat(zz_y7.hit_timer_func, 0.2)
			zz_y7.auto_pot_timer = _TimerService:SetTimerRepeat(zz_y7.potion_timer_func, 0.7)
		else
			_TimerService:ClearTimer(zz_y7.auto_hit_timer)
			_TimerService:ClearTimer(zz_y7.auto_pot_timer)
		end
		print_toggle_message(zz_y7_const.AUTO_FIRE, zz_y7.is_fire)
	end,
	[zz_y7_const.ONE_CLICK] = function(self)
		zz_y7.use_filter = not zz_y7.use_filter
		zz_y7.use_infi = not zz_y7.use_infi
		zz_y7.use_attack_speed = not zz_y7.use_attack_speed
		zz_y7.use_immortal = not zz_y7.use_immortal
		zz_y7.use_no_cool = not zz_y7.use_no_cool
		zz_y7.use_pickup = not zz_y7.use_pickup
		zz_y7.use_hide_name = not zz_y7.use_hide_name
		if zz_y7.use_hide_name then
			_UserService.LocalPlayer.NameTagComponent.Name = "MapleLand"
		else
			_UserService.LocalPlayer.NameTagComponent.Name = zz_y7.local_player.name
		end
		print_toggle_message(zz_y7_const.FILTER, zz_y7.use_filter)
		print_toggle_message(zz_y7_const.INFI_ATTACK, zz_y7.use_infi)
		print_toggle_message(zz_y7_const.ATTACK_SPEED, zz_y7.use_attack_speed)
		print_toggle_message(zz_y7_const.IMMORTAL, zz_y7.use_immortal)
		print_toggle_message(zz_y7_const.NO_COOL, zz_y7.use_no_cool)
		print_toggle_message(zz_y7_const.PICKUP, zz_y7.use_pickup)
		print_toggle_message(zz_y7_const.HIDE_NAME, zz_y7.use_hide_name)
	end,
	[zz_y7_const.DUPE] = function(self)
		zz_y7.use_dupe = not zz_y7.use_dupe
		print_toggle_message(zz_y7_const.DUPE, zz_y7.use_dupe)
	end,
	[zz_y7_const.CONVERT] = function(self)
		zz_y7.mob_convert = not zz_y7.mob_convert
		zz_y7.convert_trigger = not zz_y7.convert_trigger
		print_toggle_message(zz_y7_const.CONVERT, zz_y7.mob_convert)
	end,
	[zz_y7_const.AUTO_MOVE] = function(self)
		zz_y7.is_move = not zz_y7.is_move
		zz_y7.move_trigger = not zz_y7.move_trigger
		if zz_y7.is_move then
			zz_y7.auto_move_timer = _TimerService:SetTimerRepeat(zz_y7.move_timer_func, 3)
		else
			_TimerService:ClearTimer(zz_y7.auto_move_timer)
			previousPosition = nil
		end
		print_toggle_message(zz_y7_const.AUTO_MOVE, zz_y7.is_move)
		print_toggle_message(zz_y7_const.AUTO_MOVE, zz_y7.move_trigger)
	end,
	[zz_y7_const.PET] = function(self)
		zz_y7.is_pet = not zz_y7.is_pet
		if zz_y7.is_pet then
			zz_y7.auto_pet_timer = _TimerService:SetTimerRepeat(zz_y7.pet_timer_func, 600.0)
		else
			_TimerService:ClearTimer(zz_y7.auto_pet_timer)
		end
		print_toggle_message(zz_y7_const.PET, zz_y7.is_pet)
	end,
	[zz_y7_const.GHOST] = function(self)
		zz_y7.is_ghost = not zz_y7.is_ghost
		if zz_y7.is_ghost then
			_UserService.LocalPlayer.Visible = false
			print_toggle_message(zz_y7_const.GHOST, zz_y7.is_ghost)
		else 
			_UserService.LocalPlayer.Visible = true
			print_toggle_message(zz_y7_const.GHOST, zz_y7.is_ghost)
		end
	end,
	[zz_y7_const.DEMI] = function(self)
		zz_y7.use_demi = not zz_y7.use_demi
		print_toggle_message(zz_y7_const.DEMI, zz_y7.use_demi)
	end,
	[zz_y7_const.FILTER] = function(self)
		zz_y7.use_filter = not zz_y7.use_filter
		print_toggle_message(zz_y7_const.FILTER, zz_y7.use_filter)
	end,
	[zz_y7_const.INFI_ATTACK] = function(self)
		zz_y7.use_infi = not zz_y7.use_infi
		print_toggle_message(zz_y7_const.INFI_ATTACK, zz_y7.use_infi)
	end,
	[zz_y7_const.ATTACK_COUNT] = function(self)
		zz_y7.use_attack_count = not zz_y7.use_attack_count
		print_toggle_message(zz_y7_const.ATTACK_COUNT, zz_y7.use_attack_count)
	end,
	[zz_y7_const.ATTACK_SPEED] = function(self)
		zz_y7.use_attack_speed = not zz_y7.use_attack_speed
		print_toggle_message(zz_y7_const.ATTACK_SPEED, zz_y7.use_attack_speed)
	end,
	[zz_y7_const.IMMORTAL] = function(self)
		zz_y7.use_immortal = not zz_y7.use_immortal
		print_toggle_message(zz_y7_const.IMMORTAL, zz_y7.use_immortal)
	end,
	[zz_y7_const.NO_COOL] = function(self)
		zz_y7.use_no_cool = not zz_y7.use_no_cool
		print_toggle_message(zz_y7_const.NO_COOL, zz_y7.use_no_cool)
	end,
	[zz_y7_const.PICKUP] = function(self)
		zz_y7.use_pickup = not zz_y7.use_pickup
		print_toggle_message(zz_y7_const.PICKUP, zz_y7.use_pickup)
	end,
	[zz_y7_const.SPEED] = function(self)
		zz_y7.use_speed = not zz_y7.use_speed
		if zz_y7.use_speed then
			_UserService.LocalPlayer.InputSpeed = 5
			_UserService.LocalPlayer.JumpForce  = 3
		else
			_UserService.LocalPlayer.InputSpeed = zz_y7.local_player.speed
			_UserService.LocalPlayer.JumpForce  = zz_y7.local_player.jump_force
		end
		print_toggle_message(zz_y7_const.SPEED, zz_y7.use_speed)
	end,

	[zz_y7_const.HIDE_NAME] = function(self)
		zz_y7.use_hide_name = not zz_y7.use_hide_name
		if zz_y7.use_hide_name then
			_UserService.LocalPlayer.NameTagComponent.Name = "MapleLand"
		else
			_UserService.LocalPlayer.NameTagComponent.Name = zz_y7.local_player.name
		end
		print_toggle_message(zz_y7_const.HIDE_NAME, zz_y7.use_hide_name)
	end,

	[zz_y7_const.MOUSE_TP] = function(self)
		zz_y7.use_mouse_tp = not zz_y7.use_mouse_tp
		print_toggle_message(zz_y7_const.MOUSE_TP, zz_y7.use_mouse_tp)
	end,
	------------------- Instant Cheats -------------------
	[zz_y7_const.INVEN] = function(self, user, argc, args)
		local cd = user.WsCharacterData
		-- no check argc but idc cuz its trash for rn
		local empty_slot_count = _InventoryLogic:GetFreeSlots(cd, tonumber(args[2]))
		local full_slot_count  = _InventoryLogic:GetHoldCount(cd, tonumber(args[2]))
		_ChatMessageLogic:Add(_ChatMessageType.System, "[Command/Inven] slot: " .. full_slot_count .. " / " .. empty_slot_count)
	end,
	--[zz_y7_const.SET_SKILL] = function(self, args)
	--	local setid = string.match(args, "%d+")
	--	_ChatMessageLogic:Add(_ChatMessageType.System, string.format("(%s)", setid))
	--end,

	------------------- Test here -------------------
	[zz_y7_const.TEST] = function(self, user, argc, args)
		local cd = user.WsCharacterData
		local local_player = _UserService.LocalPlayer
		local current_map = local_player.CurrentMap
		zz_y7.test_toggle = not zz_y7.test_toggle
		_ChatMessageLogic:Add(_ChatMessageType.System, "test function start")
		--[[
		local s = ""
		for i,v in pairs(current_map) do
			s = s .. ("[%s] - %s (type: %s)\n"):format(i, tostring(v), type(v))
		end
		]]
		--local portal = _EntityService:GetEntityByPath("script/5f9c23c8-3f96-41ee-9b94-c00c2d6807e9:MaplePortalComponent")
		--local portal = local_player.WsUserController.worldEntity.MaplePortalComponent
		--local portals = local_player.WsUser:GetPortals(local_player.CurrentMapName, "east00")
		--local portals2 = local_player.WsUser:GetPortals(local_player.CurrentMapName, "")
		--if (_PlayerActiveSkillLogic_Teleport:TryRegisterTeleport(local_player.WsUserController.Entity, 0, 0, portals2[1], portals[1], false)) then
		--	_SoundService:PlaySound(_EffectLogic.SoundGame["Portal"], 1)
		--end
		--local_player.WsUserController:TryEnterNormalPortal(portals[1])
		_ChatMessageLogic:Add(_ChatMessageType.System, "test function end")
	end,
	------------------------------------------------- zz_y7 -------------------------------------------------





}
if (Environment:IsMakerPlay()) then
	self.DebugCommands = {
		["impact"] = _CommandLogic_Client_Debug.Impact
	}
end
end