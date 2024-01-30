return function (self,event) 
local Function = event.Function
local Entity = event.Entity
if (Function == "Channel") then
	_AppService:Get():CloseMenus()
	local player = _UserService.LocalPlayer
	if (player.CurrentMap.MapInfoComponent:HasMigrateLimit()) then
		_UtilDlgLogic:Show("채널을 변경할 수 없는 장소입니다.")
		return
	end
	if (player.CharacterActionComponent:CheckAlert()) then
		return
	end
	
	--_UtilDlgLogic:Show("채널 변경 기능은 서버 성능 저하 문제로 임시 비활성화되었습니다.")
	
	self.ChannelChange.ChannelChangeComponent:LoadChannel()
	self.ChannelChange.Enable = true
	
elseif (Function == "GameOpt") then
	self.GameOpt.Enable = true
	_AppService:Get():CloseMenus()
elseif (Function == "SysOpt") then
	self.SysOpt.Enable = true
	_AppService:Get():CloseMenus()
end
end