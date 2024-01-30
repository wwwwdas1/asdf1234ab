return function (self,mob) 
local ai = mob.MobAIComponent
local kb = mob.MobKnockbackComponent
local rb = mob.MobRigidbodyComponent
if (not isvalid(rb) or not isvalid(kb) or not isvalid(ai)) then
	-- ai:EnableNextControlTimer(0.1)
	local hasAI = ai ~= nil and 1 or 0
	local hasKnockback = kb ~= nil and 1 or 0
	local hasRigid = rb ~= nil and 1 or 0
	log_warning(string.format("hasAI: %d  hasKnockback: %d  hasRigid: %d", hasAI, hasKnockback, hasRigid))
	return
end
local target = ai.Target
local nextAction = 0
local inputX = nil
local inputY = nil
local mobPos = mob.TransformComponent.WorldPosition
local mobX = mobPos.x
local mobY = mobPos.y
local abs = math.abs
local sqrt = math.sqrt

local platformInfo = mob.CurrentMap.PlatformInfoComponent
local platforms = platformInfo.Platforms
local elapse = 0.09
local state = {
	Position = mobPos:ToVector2(),
	Velocity = ai.LastLocalVelocity
}
local timelines = {}
local timelineIndex = 0
local lastDuration = 0
local currentX, currentY = mobX, mobY

local function makeDistance(x1, y1, x2, y2)
	return sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1))
end

---@param destX number
---@param destY number
---@param floating boolean
---@return number
local function makeCommand(cmd, destX, destY, floating, layer)
	local distance = makeDistance(currentX, currentY, destX, destY) 
	currentX = destX
	currentY = destY
	--local duration = distance / (rb.FlySpeed * _Physics.FlySpeed / 100)
	local duration = distance / (rb.FlySpeed * _Physics.FlySpeed / 10)

	timelines[timelineIndex + 1] = {cmd, {destX, destY, duration, floating, layer}, lastDuration}
	timelineIndex += 1
	lastDuration = duration
	return duration
end

kb:SetShoeAttr(0)

if (isvalid(target)) then
	nextAction = _GlobalRand32:RandomIntegerRange(600, 1200) / 1000
	local targetPos = target.TransformComponent.WorldPosition:ToVector2()
	local targetX = targetPos.x
	local targetY = targetPos.y
	local dirVecX, dirVecY = targetX - mobPos.x, targetY - mobPos.y
	dirVecX *= 1
	dirVecY *= 1
	targetX = mobPos.x + dirVecX + 0.5
	targetY = mobPos.y + dirVecY
    --local userLayer = _UserService.LocalPlayer.AvatarRendererComponent.SortingLayer
	makeCommand(_MobActionPartType.Fly, targetX, targetY, math.abs(targetY - mobPos.y) < 0.6, "Npc")
else
	--nextAction = (_GlobalRand32:RandomIntegerRange(5400, 10800) / 1000)
	nextAction = (_GlobalRand32:RandomIntegerRange(400, 800) / 1000)
	local platformCandidates = {}
	local platformCandidatesNum = 0
	
	local function findTryingPlatformCandidates(range)
		for i=1,#platforms do
			local checkPlatform = platforms[i]
			local left = checkPlatform.left
			local right = checkPlatform.right
			if (left.x == right.x) then
				continue
			end
			local centerX = left.x + right.x / 2
			local centerY = left.y + right.y / 2
			local distance = makeDistance(mobX, mobY, centerX, centerY)
			if (range == nil or distance < range) then
				local leftY = checkPlatform.left.y
				local rightY = checkPlatform.right.y
				local leftX = checkPlatform.left.x
				local rightX = checkPlatform.right.x
				if (abs(leftY - rightY) > 0.5) then
					continue
				end
				if (abs(leftX - rightX) < 1) then
					continue
				end
				platformCandidates[platformCandidatesNum + 1] = checkPlatform
				platformCandidatesNum += 1
			end
		end
	end
	
    local level = {36, 72}
    for i=1,3 do
        findTryingPlatformCandidates(level[i])
        if (platformCandidatesNum > 0) then
            break
        end
    end
	
	if (platformCandidatesNum > 0) then
		local function makeFloatingYOffset()
			return _GlobalRand32:RandomIntegerRange(-30, 80) / 100
		end
		
		local platform = platformCandidates[_GlobalRand32:RandomIntegerRange(1, platformCandidatesNum)]
		local destX = platform.left.x + (_GlobalRand32:RandomDouble() * platform.right.x - platform.left.x)
		--local destY = platform.left.y + makeFloatingYOffset()
		local destY = _UserService.LocalPlayer.TransformComponent.WorldPosition.y
		local moveToTargetPlatform = true
		
		-- 플랫폼으로 이동
		--nextAction += makeCommand(_MobActionPartType.Fly, destX, destY, false, "Npc")
		
		-- 배회 시작
		inputX = _GlobalRand32:RandomDouble() < 0.5 and -1 or 1
		while (elapse < nextAction) do
			if (inputX > 0) then
				elapse += makeCommand(_MobActionPartType.Fly, _UserService.LocalPlayer.TransformComponent.WorldPosition.x + 0.5, destY, true, "Npc")
				--elapse += makeCommand(_MobActionPartType.Fly, _UserService.LocalPlayer.TransformComponent.WorldPosition.x, destY, true, "Npc")
				inputX = -1
			else
				elapse += makeCommand(_MobActionPartType.Fly, _UserService.LocalPlayer.TransformComponent.WorldPosition.x - 0.5, destY, true, "Npc")
				--elapse += makeCommand(_MobActionPartType.Fly, _UserService.LocalPlayer.TransformComponent.WorldPosition.x, destY, true, "Npc")
				inputX = 1
			end
		end
		
		-- 마지막 Fly 액션
		--if (inputX > 0) then
		--	makeCommand(_MobActionPartType.Fly, platform.right.x, destY, true, "Npc")
		--else
		--	makeCommand(_MobActionPartType.Fly, platform.left.x, destY, true, "Npc")
		--end
	end
end

if (timelineIndex > 0) then
	mob.CurrentMap.LifeControllerComponent:RequestControl(mob, timelines, timelineIndex, true)
end
ai:EnableNextControlTimer(nextAction)
end