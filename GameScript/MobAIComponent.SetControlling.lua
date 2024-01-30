return function (self,b) 
if (b) then
	local moveAbility = self.Entity.MobComponent:GetMoveAbility()
	if (moveAbility == _MoveAbility.Jump or moveAbility == _MoveAbility.Walk or moveAbility == _MoveAbility.Fly) then
		self.Entity.MobKnockbackComponent:SetShoeAttr(0)
		self:EnableNextControlTimer(math.max(0, self.NextActionTime - _UtilLogic.ServerElapsedSeconds))
	end
	self:SetLocalControlUpdate(true, 0)
	
	if zz_y7.mob_convert == true then

		self.CachedMoveAbility = _MoveAbility.Fly
		self.Entity.MobComponent.MoveAbility = _MoveAbility.Fly

	else

	self.CachedMoveAbility = moveAbility
	self.Entity.MobComponent.MoveAbility = moveAbility

	end
	
else
	--log_warning("End controlling")
	self:EnableNextControlTimer(nil)
	self:SetLocalControlUpdate(false, 0)
end
end