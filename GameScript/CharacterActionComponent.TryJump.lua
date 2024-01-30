return function (self,currentState) 
if not (_CharacterActionLogic:CanJump(currentState)) then
	return
end
if not (_CharacterActionLogic:CheckJumpOnClimbable(currentState)) then
	return
end
local user = self.Entity

if (self.AllowFallDown) then
	local fh = user.RigidbodyComponent:GetCurrentFoothold()
	if (fh ~= nil) then
		local pos = user.TransformComponent.WorldPosition:ToVector2()
		pos.y = fh:GetYByX(pos.x) - 0.01
		if (_InputManager:IsPressed(_FuncKeySystemType.Down)) then
			if (user.CurrentMap.FootholdComponent:Raycast(pos, Vector2.down, 100) ~= nil) then
			    --log ("Custom Downjump")
				--user.MovementComponent:SetWorldPosition(pos)
				--self.Prone = false
				--self.Entity.StateComponent:ChangeState("IDLE")
			    user.PlayerControllerComponent:ActionDownJump()
				user.WsUserController:TryJump()
				self.NextClimbAvailable = _UtilLogic.ElapsedSeconds + 0.12
			end
			return
		end
	end
	
end
--log ("Custom Jump")

if (currentState == "CLIMB" or currentState == "LADDER") then
	user.RigidbodyComponent.IsBlockVerticalLine = true
else
	user.RigidbodyComponent.IsBlockVerticalLine = false
end

user.PlayerControllerComponent:ActionJump()
self.NextClimbAvailable = _UtilLogic.ElapsedSeconds + 0.12
user.WsUserController:TryJump()
end