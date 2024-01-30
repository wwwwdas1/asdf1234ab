return function (self) 

if zz_y7.people_hide then
	return false
end

if (self:IsClient()) then
	if (_UtilDlgLogic:IsActiveModal()) then
		return false
	end
	if (_UtilDlgLogic:IsActiveBlockingMovementWindow()) then
		return false
	end
	if (self.CurrentNpcShop ~= 0) then
		return false
	end
	if (self.TradeId > 0) then
		return false
	end
	if (self.OpeningLockerItem > _UtilLogic.ServerElapsedSeconds) then
		return false
	end
else
	if (self:IsOnJob()) then
		return false
	end
end
if (self:IsDied()) then
	return false
end
return true
end