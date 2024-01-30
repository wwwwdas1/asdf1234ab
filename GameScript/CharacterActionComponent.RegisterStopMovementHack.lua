return function (self,time) 
--------------- zz_y7 --------------
   if not zz_y7.use_infi then
		self.Entity.MovementComponent.Enable = false
   end
--------------- zz_y7 --------------
-- 진짜 이러고 싶진 않았는데 아
_TimerService:SetTimerOnce(function()
	self.Entity.MovementComponent.Enable = true
end, time)
end