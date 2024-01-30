return function (self) 
local user = _UserService.LocalPlayer
if (not user.WsUser:IsAvailableInventoryOperation()) then
	return
end

_UtilDlgLogic:Input("얼마를 버리시겠습니까? (타유저 획득시 금액의 일부를 잃어버릴 수 있습니다.)", true, "50000", function(val)
	self:DropInputDropMesoNumber(val)
end, nil)
end