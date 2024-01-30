return function (self) 
	local user = self.Entity
	if (user.WsUser.ExclusiveAction) then
		return
	end
	if (not user.WsUser:IsAvailableInventoryOperation()) then
		return
	end
	if (user.PlayerTemporaryStat:GetValue(_CTS.DarkSight) ~= 0) then
		return
	end
	local simulator = _CollisionService:GetSimulator(user)
	--------------- zz_y7 ---------------
	local size
	if zz_y7.use_pickup then
		size = Vector2(500.0, 500.0)
	else
		size  = Vector2(0.22, 0.35)
	end
	local shape = BoxShape(user.TransformComponent.WorldPosition:ToVector2(), size, 0)
	local tb = {}
	--------------- zz_y7 ---------------
	local count = simulator:OverlapAllFast(CollisionGroups.MapleDrop, shape, tb)
	if (count == 0) then
		return
	end
	local minimumDrop = nil
	local minimumDropId = 0
for _,drop in pairs(tb) do
	---@type DropComponent
	local d = drop.Entity.DropComponent
	if (not isvalid(d)) then
		continue
	end
	local r = d.ReservedDestroy
	if (r == 0) then
		local dropId = d.DropId
		if (minimumDrop == nil or dropId < minimumDropId) then
			minimumDrop = d
			minimumDropId = dropId
		end
	end
end
if (minimumDrop ~= nil) then
	self:TryPick(minimumDrop)
end
end
	--[[_TableUtils:Shuffle(tb)
	for _,drop in pairs(tb) do
		self:TryPick(drop)
	end
	end]]