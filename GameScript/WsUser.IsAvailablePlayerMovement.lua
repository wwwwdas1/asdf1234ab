return function (self) 
if (self.Migrating) then
	return true
end
if (_UtilDlgLogic:IsActiveModal()) then
	return true
end
if (_UtilDlgLogic:IsActiveBlockingMovementWindow()) then
	return true
end
if (self.CurrentNpcShop ~= 0) then
	return true
end
if (self.TradeId > 0) then
	return true
end
return true
end