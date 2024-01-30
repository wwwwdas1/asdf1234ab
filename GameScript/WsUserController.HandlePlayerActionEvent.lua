return function (self,event) 
--------------- Native Event Sender Info ----------------
-- Sender: PlayerControllerComponent
-- Space: Server, Client
---------------------------------------------------------

-- Parameters
local ActionName = event.ActionName
local PlayerEntity = event.PlayerEntity
---------------------------------------------------------

--log("Received action!! " .. ActionName)
------------------------------ zz_y7 ------------------------------
--_ChatMessageLogic:Add(_ChatMessageType.System, "[PlayerController] " .. ActionName)
--_UserRaiseLogic:OnStatChangeRequest(_UserService.LocalPlayer.WsUser.Entity, 9999, 9999, 0) mp not work
------------------------------ zz_y7 ------------------------------
end