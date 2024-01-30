return function (self,newController) 
if (isvalid(newController) and newController.Id == _UserService.LocalPlayer.Id) then
	self:SetControlling(true)
end
end