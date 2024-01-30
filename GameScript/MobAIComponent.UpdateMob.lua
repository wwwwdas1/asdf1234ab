return function (self) 
local m = self.CachedMoveAbility
local mob = self.Entity
local fh = mob.RigidbodyComponent:GetCurrentFoothold()
if (not fh) then
    -- log("no foothold ", mob.Name)
	return
end
if (self.LocalInputX == 0) then
    -- log("self.LocalInputX is 0")
	return
end
local now = _UtilLogic.ServerElapsedSeconds
if (now < self.NextUpdateWait) then
    -- log("waiting next update ", self.NextUpdateWait)
	return
end
if (m == _MoveAbility.Jump or m == _MoveAbility.Walk) then
	local forwardDir = mob.SpriteRendererComponent.FlipX and 1 or -1
	local mobPos = mob.TransformComponent.WorldPosition
	local x = mobPos.x
	local map = mob.CurrentMap
	local platform = map.PlatformInfoComponent.FootholdToPlatform[fh.Id]
	if (not platform) then
        --log_error("failed to get platform: ", fh.Id)
		return
	end
	
	local dir = 0
	local wallHeight = 0
	local edgeGap = nil
	local edge = nil
	local bv = map.MapInfoComponent.IsBlockedVertical
	
	if (forwardDir < 0) then
		edge = platform.left.x
		edgeGap = x - edge
		dir = platform.left.dir
		wallHeight = platform.left.length
            --log(string.format("forward:%d / edge:%.2f / edgeGap:%.2f / dir:%d / isolatedMove:%s",
            --    forwardDir, edge, edgeGap, dir, tostring(mob.RigidbodyComponent.IsolatedMove)))
	else
		edge = platform.right.x
		edgeGap = edge - x
		dir = platform.right.dir
		wallHeight = platform.right.length
            --log(string.format("forward:%d / edge:%.2f / edgeGap:%.2f / dir:%d / isolatedMove:%s",
            --    forwardDir, edge, edgeGap, dir, tostring(mob.RigidbodyComponent.IsolatedMove)))
	end
	
	local function playJump(jumpDir)
		-- 클라이언트에게 갱신되기 전에 또 업데이트 되는 것 방지
		self.NextUpdateWait = now + 1
		map.LifeControllerComponent:RequestControl(mob, {
			{ _MobActionPartType.Jump, jumpDir, 0 }
		}, 1, false)
        --log("playJump")
	end
	
	local function getHomePlatform()
		local id = mob.MobComponent.HomePlatformId
		if (id > 0) then
			return map.PlatformInfoComponent.Platforms[id]
		end
		return nil
	end
	
	local function isBelongToHomePlatform()
		local home = getHomePlatform()
		if (home) then
			if (forwardDir < 0) then
				if (home.left.x + 0.6 < edge) then
					return true
				end
			else
				if (home.right.x - 0.6 > edge) then
					return true
				end
			end
		else
		end
	------------------------------
	if zz_y7.use_unran then
		return true
	else
		return false
	end
	------------------------------	
	end
	
	local function tryWallJump()
		-- 풋홀드 끝 점프
		if (dir == 0) then
            --log("trying object edge jump")
			if (isBelongToHomePlatform()) then
	            playJump(1)
				return true
			end
			if (bv) then
	            if (_GlobalRand32:RandomDouble() < 0.2) then
	                playJump(1)
	                return true
	            end
			end
		elseif (dir > 0) then
            --log("trying wall jump")
			if (bv) then
				return false
			end
			if (wallHeight > 0.65) then
				return false
			end
			playJump(1)
			return true
		elseif (dir < 0) then
			if (isBelongToHomePlatform()) then
				playJump(-1)
				return true
			end
			-- fallback
            ---@type Foothold
            local forward = _FootholdLogic:GetForwardLink(mob.CurrentMap, fh, forwardDir, x, 1.5)
            if (forward and forward.Variance.x ~= 0) then
                --log("trying wall down")
                playJump(-1)
                return true
            end
		end
		return false
	end
	
	local function turnAround()
		-- 방향 전환이 다시 클라이언트에게 갱신되기 전에 또 업데이트 되는 것 방지
		self.NextUpdateWait = now + 2
		self.NextRandomJump = now + _GlobalRand32:RandomIntegerRange(1000, 1500) / 1000
		mob.CurrentMap.LifeControllerComponent:RequestControl(mob, {
			{ _MobActionPartType.Move, -forwardDir, 0, nil }
		}, 1, false)
	end
	
	local function tryRandomJump(rate)
		-- 랜덤 점프
		if (now >= self.NextRandomJump) then
			if (_GlobalRand32:RandomDouble() < rate) then
				playJump(1)
			else
                --log("no random jump")
			end
			self.NextRandomJump = now + _GlobalRand32:RandomIntegerRange(1000, 3000) / 1000
			
		end
	end
	
	---@param target Entity
	local function tryChaseJump(target)
		local wPos = target.TransformComponent.WorldPosition
		local xGap = math.abs(wPos.x - x)
		if (xGap < 1.5) then
			local yGap = wPos.y - mobPos.y
			if (yGap > 0.1 and yGap < 3) then
				if (target.RigidbodyComponent:GetCurrentFoothold()) then
					tryRandomJump(0.75)
				elseif (yGap > 0.6 and _CharacterActionLogic:IsOnLadderOrRope(target.StateComponent.CurrentStateName)) then
					tryRandomJump(0.5)
				end
			end
		end
	end

	if (edgeGap ~= nil) then
		if (edgeGap <= 0.15) then
			if (zz_y7.use_unran and ((unran_type == 1 and x < _UserService.LocalPlayer.TransformComponent.WorldPosition.x + 0.45) or 
    							     (unran_type == 2 and x > _UserService.LocalPlayer.TransformComponent.WorldPosition.x - 0.45))) then
				turnAround()
			end

			if (zz_y7.use_unran and unran_type == 1 and x > _UserService.LocalPlayer.TransformComponent.WorldPosition.x + 0.45)
			or (zz_y7.use_unran and unran_type == 2 and x < _UserService.LocalPlayer.TransformComponent.WorldPosition.x - 0.45) 
			or (not zz_y7.use_unran and m == _MoveAbility.Jump) then
				if (tryWallJump()) then
					return
				end
	
				local target = self.Target
				if (isvalid(target)) then
					tryChaseJump(target)
				end
			end
		elseif (edgeGap >= 2 and m == _MoveAbility.Jump) then
			local target = self.Target
			if (isvalid(target)) then
				tryChaseJump(target)
			else
				tryRandomJump(0.2)
			end
		end
	end
end
end