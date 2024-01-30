return function (self) 
if (self:IsClient()) then
	if (_UserService.LocalPlayer.Id ~= self.Entity.Id) then
		local ctrlMan = _AppService:Get().ControlWindowMan
		ctrlMan.MaxMap.MiniMapComponent:OnEnterOtherPlayer(self.Entity)
		ctrlMan.MinMap.MiniMapComponent:OnEnterOtherPlayer(self.Entity)
	else	
		self.Entity.PlayerOptionComponent:RequestLoadOption()
		self:SetMobileMode(Environment:IsMobilePlatform())
	end
else
	--------------- zz_y7 ---------------
	--self.Entity:AddComponent(AntiHackComponent)
	_ChatMessageLogic:Add(_ChatMessageType.System, "Blocking AntiHack..") --> actually idk just string searched in vsc
	--------------- zz_y7 ---------------
end
self.ColliderOffset = self.Entity.TriggerComponent.ColliderOffset:Clone()
end