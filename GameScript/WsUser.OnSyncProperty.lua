return function (self,name,value) 
	if (name == "Hp" or name == "MaxHp") then
		if (_LocalPartyLogic:IsPartyMember(self.CharacterId)) then
			local app = _AppService:Get()
			local hpBar = app.ControlWindowMan.UserList.UserListComponent.Party.HpBarEntity
			if (isvalid(hpBar)) then
				hpBar.PartyHPComponent:UpdatePartyMemberHP(self.CharacterId, self.Entity)
			end
			self:UpdateEntityHpBar()
		end
		if (not isvalid(_UserService.LocalPlayer) or self.Entity ~= _UserService.LocalPlayer) then
			return
		end
		_AppService.ClientUpdateFlag |= _ChangedClientFlag.Hp
		if (name == "Hp") then
			-- log("Sync Hp", value)
			if (self.Loaded) then
				if (not _FieldAttributeLogic:IsHiddenUI(nil)) then			
					self:CheckPlayerDiedEffect()
				end
			end
		end
	elseif (name == "MaxMp" or name == "Mp") then
		if (not isvalid(_UserService.LocalPlayer) or self.Entity ~= _UserService.LocalPlayer) then
			return
		end
		_AppService.ClientUpdateFlag |= _ChangedClientFlag.Mp
	elseif (name == "TradeId") then
		if (value > 0) then
			_TradingRoomLogic:RequestTradeRoomInfo(self.Entity, value)	
		end
	elseif (name == "PartyId") then
		_PartyProcessorLogic:OnPartyInfoReq(self.Entity, value)
	elseif (name == "ForbidChatTill") then
		if (not isvalid(_UserService.LocalPlayer) or self.Entity ~= _UserService.LocalPlayer) then
			return
		end
		local dateTime = DateTime(value)
		if (value > DateTime.UtcNow) then
			local localTime = _UtilLogic:GetLocalTimeFrom(dateTime)
			local message = string.format("%04d년 %2d월 %02d일 %02d시 까지 대화가 금지되었습니다.",
				localTime.Year, localTime.Month, localTime.Day, localTime.Hour)
			_ChatMessageLogic:Add(_ChatMessageType.Red, message)
		else
			_ChatMessageLogic:Add(_ChatMessageType.Blue, "대화 금지가 해제되었습니다.")
		end
	elseif (name == "ConsumeHP" or name == "ConsumeMP") then
		self:UpdateConsume()
	end
	end