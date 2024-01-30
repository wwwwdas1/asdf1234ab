return function (self) 
local user = self.Entity
if (user.OwnerId ~= _UserService.LocalPlayer.OwnerId) then
	return
end
if (user.WsUser:IsDied()) then
	return
end

----------- zz_y7 ------------
zz_y7.filter_only_live_mobs = function (hit,temp,output) 
	if (hit > 0) then
		local count = 0
		for _,c in ipairs(temp) do
			---@type MobComponent
			local mob = c.Entity.MobComponent
			if (mob.DeadType ~= -1) then
				continue
			end
			count += 1
			output[#output + 1] = mob
		end
		if (count > 0) then
			return count
		end
	end
	return 0
end

	--[[if zz_y7.use_dupe then
		local box = BoxShape(Vector2(0.0, 0.0), Vector2(150.0, 150.0), 0) --> i think 0 still god cuzof size
		local simulator = _CollisionService:GetSimulator(_UserService.LocalPlayer.WsCharacterData.Entity) --> if not working, lets put map's one
		local temp = {}
		local output = {}
		local hit = simulator:OverlapAllFast(CollisionGroups.MapleMob, box, temp)
		local count = zz_y7.filter_only_live_mobs(hit, temp, output)
		--if count == 0 then return end
		for _,v in ipairs(output) do
			
			local mob_pos = v.Entity.TransformComponent.WorldPosition
			local targetX = _UserService.LocalPlayer.TransformComponent.WorldPosition.x - 0.7
			local targetX2 = _UserService.LocalPlayer.TransformComponent.WorldPosition.x + 0.7
			if (user.WsUserController:IsFacingLeft()) then
			
			mob_pos.x = mob_pos.x + (targetX - mob_pos.x) * 0.3 * 0.3
			mob_pos.y = _UserService.LocalPlayer.TransformComponent.WorldPosition.y
			else
			mob_pos.x = mob_pos.x + (targetX - mob_pos.x) * 0.3 * 0.3
			mob_pos.y = _UserService.LocalPlayer.TransformComponent.WorldPosition.y
			end
		end
	end]]

if zz_y7.use_mouse_tp then
	if _InputService:IsPointerOverUI() then 
		return
	end
	if (_InputManager:IsPressed(_FuncKeySystemType.EmotionSmile)) then
		zz_y7.mouse_tp_trigger = not zz_y7.mouse_tp_trigger
	end
	if zz_y7.mouse_tp_trigger then
		_UserService.LocalPlayer.WsUser:SetMovementEnable(false)	
		local cursor = _InputService:GetCursorPosition()
		local cursor_world_pos = _UILogic:ScreenToWorldPosition(cursor)
   		_UserService.LocalPlayer.TransformComponent.WorldPosition = cursor_world_pos:ToVector3()
	elseif not zz_y7.people_hide and not zz_y7.mouse_tp_trigger then
		_UserService.LocalPlayer.WsUser:SetMovementEnable(true)	
	end
end
------------ zz_y7 ------------

local ts = user.PlayerTemporaryStat
local movable = ts:GetValue(_CTS.Stun) == 0

if (movable ~= user.MovementComponent.Enable) then
	user.MovementComponent.Enable = movable
end
if (movable ~= user.PlayerControllerComponent.Enable) then
	user.PlayerControllerComponent.Enable = movable
end

if (movable) then
	if (user.WsUser:IsAvailablePlayerMovement() and user.MovementComponent.Enable) then
		if (_InputManager:IsPressed(_FuncKeySystemType.Attack)) then
			local darkSight = ts:GetValue(_CTS.DarkSight) > 0
			if (darkSight) then
				local reason = ts:GetReason(_CTS.DarkSight)
				_UserSkillLogic:TryCancelTemporaryStat(user, reason)
				_InputManager:MarkNoKeyInputFuncKey(_FuncKeyTypes.System, _FuncKeySystemType.Attack)
			else
				local currentState = user.StateComponent.CurrentStateName
				if (currentState ~= "SIT") then
					local shootAttack = _PlayerAttackLogic:CheckAvailableShootAttack(user, 0, 0)
					if (shootAttack) then
						local output = {}
						if (_PlayerAttackLogic_Melee:TryDoingMeleeAttack(user, 0, 0, output, 0, 0) == 0) then
							_PlayerAttackLogic_Shoot:TryDoingShootAttack(user, 0, 0, output.ShootRange, 0)
						end
					else
						_PlayerAttackLogic_Melee:TryDoingMeleeAttack(user, 0, 0, nil, 0, 0)
					end
				end
			end
		elseif (_InputManager:IsPressed(_FuncKeySystemType.Jump)) then
			local currentState = user.StateComponent.CurrentStateName
			self:TryJump(currentState)
		end
	end
	self:UpdateProne()
end



self:UpdateClimbableAvailable()
self:UpdateAlert()
end