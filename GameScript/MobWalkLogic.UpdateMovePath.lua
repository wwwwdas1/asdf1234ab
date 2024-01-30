return function (self,mob) 
local ai = mob.MobAIComponent
local kb = mob.MobKnockbackComponent
local rb = mob.MobRigidbodyComponent
if (not isvalid(rb)) then
	if (isvalid(ai)) then
		ai:EnableNextControlTimer(0.1)
	end
	return
end
if (not mob.Visible) then
	ai:EnableNextControlTimer(0.1)
	return
end
local fh = rb.LastFoothold
if (fh == 0) then
	--log("last foothold is 0")
	ai:EnableNextControlTimer(0.1)
	return
end

local now = _UtilLogic.ServerElapsedSeconds
if (now < ai.NextActionTime) then
	ai:EnableNextControlTimer(math.max(ai.NextActionTime - now, 0) + 0.1)
	return
end

local target = ai.Target
local nextAction = 0
local newInputX = nil
local mobX = mob.TransformComponent.WorldPosition.x

if zz_y7.use_unran and unran_type == 1 then
	if (isvalid(target) and ai.LocalUnchaseTick < 30) then
		nextAction = _GlobalRand32:RandomIntegerRange(1000, 1600) / 1000
		local targetX = target.TransformComponent.WorldPosition.x
		newInputX = -1
	else
		nextAction = _GlobalRand32:RandomIntegerRange(1000, 3000) / 1000
		newInputX = -2
	end
elseif zz_y7.use_unran and unran_type == 2 then
	if (isvalid(target) and ai.LocalUnchaseTick < 30) then
		nextAction = _GlobalRand32:RandomIntegerRange(1000, 1600) / 1000
		local targetX = target.TransformComponent.WorldPosition.x
		newInputX = 1
	else
		nextAction = _GlobalRand32:RandomIntegerRange(1000, 3000) / 1000
		newInputX = 2
	end
else
	if (isvalid(target) and ai.LocalUnchaseTick < 30) then
		nextAction = _GlobalRand32:RandomIntegerRange(1000, 1600) / 1000
		local targetX = target.TransformComponent.WorldPosition.x
		newInputX = targetX > mobX and 1 or -1
	else
		nextAction = (_GlobalRand32:RandomIntegerRange(1000, 3000) / 1000)
		newInputX = _GlobalRand32:RandomIntegerRange(-1, 1)
	end
end		

local platforms = mob.CurrentMap.PlatformInfoComponent
local timelines = {}
local timelineIndex = 0
--log("platform left x (fh=%d)", platform.left.x, platform.left.foothold.Id)
--log("platform right x (fh=%d)", platform.right.x, platform.right.foothold.Id)
local lastTimeline = 0
local playerFh = _UserService.LocalPlayer.WsUserController.LastFoothold
if (playerFh == 0 or platforms.ZMass[playerFh] ~= ai.LocalStartChaseZMass) then
	ai.LocalUnchaseTick += 1
end

local function makeCommand(cmd, value, timeline, nextActionTime)
	timelines[timelineIndex + 1] = {cmd, value, timeline - lastTimeline, nextActionTime}
	timelineIndex += 1
	lastTimeline = timeline
end

makeCommand(_MobActionPartType.Move, newInputX, 0, nextAction)
ai.NextRandomJump = math.max(ai.NextRandomJump, now + 1)

if (timelineIndex > 0) then
	mob.CurrentMap.LifeControllerComponent:RequestControl(mob, timelines, timelineIndex, false)
end
ai:EnableNextControlTimer(nextAction)
end