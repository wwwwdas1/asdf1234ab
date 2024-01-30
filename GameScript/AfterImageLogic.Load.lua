return function (self,name) 
if (not _DebugConstants.LoadAfterImage) then
	--log ("Skip loading afterimage")
	return
end
local time = _UtilLogic.ElapsedSeconds
local wz = _ResourceMan:ParseGenericWzCollection("Afterimage", name)
--_Log:Info(string.format("[AFTERIMAGE] Parsed [%s.img] (%.2f secs)", name, _UtilLogic.ElapsedSeconds - time))

local data = {}
for i,level in _WzUtils:GetLabeled(wz) do
	data[i] = level
end
if (wz["charge"] ~= nil) then
	data["charge"] = wz["charge"]
end
_AfterImageLogic.Afterimages[name] = data
end