return function (self,mob,hitByLeft,knockbackType) 
local kb = mob.MobKnockbackComponent
local ai = mob.MobAIComponent
local rb = mob.MobRigidbodyComponent
local fh = rb.LastFoothold

local map = mob.CurrentMap
local minX = map.MapComponent.LeftBottom.x + 0.1
local maxX = map.MapComponent.RightTop.x - 0.1
local mobPos = mob.TransformComponent.WorldPosition:ToVector2()

local knockbackMoveEnd = 0.35
if (knockbackType == 2) then
	knockbackMoveEnd = 0.5
end
local interruptedEnd = knockbackMoveEnd + 0.2

local state = {}

if (fh == 0) then
	--log_error("foothold is 0")
	ai:EnableNextControlTimer(interruptedEnd)
	ai:SetLocalControlUpdate(true, interruptedEnd)
	return
end
local platforms = map.PlatformInfoComponent
local platform = platforms.FootholdToPlatform[fh]
minX = platform.left.x + 0.1
maxX = platform.right.x - 0.1
if (mobPos.x < minX) then
	mobPos.x = minX
elseif (mobPos.x > maxX) then
	mobPos.x = maxX
end
state = {
	Position = mobPos.x,
	Velocity = rb.RealMoveVelocity.x
}

local elapse = 0

local timelines = {}
local timelineIndex = 0
local lastTimeline = 0

local function makeCommand(cmd, value, timeline, val2)
	timelines[timelineIndex + 1] = {cmd, value, timeline - lastTimeline, val2}
	timelineIndex += 1
	lastTimeline = timeline
end
local function resetCommands()
	timelines = {}
	timelineIndex = 0
	lastTimeline = 0
end

local inputX = 1
if (hitByLeft) then
	inputX = -1
end

kb:SetShoeAttr(knockbackType)

makeCommand(_MobActionPartType.HitMotion, 1, 0, nil)
makeCommand(_MobActionPartType.KnockbackPos, nil, 0, nil)
makeCommand(_MobActionPartType.Knockback, inputX, 0, knockbackType)
makeCommand(_MobActionPartType.Knockback, 0, knockbackMoveEnd, knockbackType)
makeCommand(_MobActionPartType.HitMotion, 0, interruptedEnd, nil)

if (timelineIndex > 0) then
	map.LifeControllerComponent:RequestControl(mob, timelines, timelineIndex, false)
end
ai:EnableNextControlTimer(interruptedEnd)
ai:SetLocalControlUpdate(true, interruptedEnd)
end