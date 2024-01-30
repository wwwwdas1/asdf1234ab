return function (self,map) 
local realZoomLevel = self.MiniMapZoomLevel
local player = _UserService.LocalPlayer
if (map == nil) then
	if (isvalid(player) and isvalid(player.CurrentMap)) then
		map = player.CurrentMap
	else
		--log_error("??")
	end
end
local mi = map.MapInfoComponent
if (isvalid(mi) and mi.HideMinimap) then
	realZoomLevel = 0
end
local mm = map.MinimapInfoComponent
if (isvalid(mm) and _UtilLogic:IsNilorEmptyString(mm.Canvas)) then
	realZoomLevel = 0
end
if not (isvalid(mm)) then
	realZoomLevel = 0
end

self.Min.MiniMapComponent:SetVisible(realZoomLevel == 0, false)
self.MinMap.MiniMapComponent:SetVisible(realZoomLevel == 1, false)
self.MaxMap.MiniMapComponent:SetVisible(realZoomLevel == 2, false)
end