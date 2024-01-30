return function (self) 
	if (self:IsInAlert()) then
		-- 숨 무시
		--_UtilDlgLogic:Show("지금은 할 수 없습니다.\n숨을 돌리고 다시 시도하세요.")
		--return true
		return false
	end
	return false
	end