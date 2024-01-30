return function (self,type,sender,message,channel) 
--[[local colorTable = self.ColorTable[type]
if (not colorTable) then
	return
end
self.ChatLog:AddChatLog(colorTable[1], colorTable[2], sender, channel, message)]]
end