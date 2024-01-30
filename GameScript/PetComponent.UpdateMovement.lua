return function (self) 
	local owner = self.Owner
	if (not isvalid(owner)) then
		return
	end
	local now = _UtilLogic.ServerElapsedSeconds
	if (self.WaitingForServer > now) then
		return
	end
	local pet = self.Entity
	local userState = owner.StateComponent.CurrentStateName
	local userIsOnRope = userState == "LADDER" or userState == "CLIMB"
	local petState = pet.StateComponent.CurrentStateName
	
	local function clearSweepTarget()
		self.SweepTemporaryExceptions[self.SweepTargetId] = nil
		self.SweepTarget = nil
		self.SweepTargetId = 0
		self.SweepOrigin = Vector3.zero
	end
	
	local function setWaitingServer()
		self.WaitingForServer = now + 5
	end
	
	-- 사다리 체크
	--[[if (userIsOnRope) then
		if (petState ~= "HANG") then
			setWaitingServer()
			self:RequestPetAction("ATTACH", 0)
			clearSweepTarget()
		end
		return
	end]]
	
	-- 사다리에서 나오면 어태치 해제
	--[[if (petState == "HANG") then
		local dir = 0
		if (userState == "FALL" or userState == "JUMP") then
			dir = owner.PlayerControllerComponent.LookDirectionX
		end
		setWaitingServer()
		self:RequestPetAction("DETACH", dir)
		return
	end]]
	
	local userPos = owner.TransformComponent.WorldPosition
	local petPos = pet.TransformComponent.WorldPosition
	local xDiff = userPos.x - petPos.x
	local yDiff = userPos.y - petPos.y
	local abs = math.abs
	local absXDiff = abs(xDiff)
	
	
	-- 유저 위치로 순간이동
	if (absXDiff> 3 or abs(yDiff) > 2) then
		setWaitingServer()
		self:RequestPetAction("TELEPORT", 0)
		clearSweepTarget()
		return
	end
	
	-- 유저에게 따라가기
	if (_PetLogic.PetMovableState[petState]) then
		if (self.InputX == 0) then
			if (petState == "ACTION") then
				if (self.MoveAvailable > _UtilLogic.ServerElapsedSeconds) then
					return
				end
			end
		end
		
		local isLongRange = false
		local petMoveRange = isLo4ngRange and 1.5 or 0.6
		local maxMoveRange = petMoveRange + 0.2
		
		---@return table<Entity>
		local function getSweepableDrops()
			local box = BoxShape(petPos:ToVector2(), Vector2(100.0, 100.0), 0)
			local simulator = _CollisionService:GetSimulator(pet.CurrentMap)
			local result = {}
			local cnt = simulator:OverlapAllFast(CollisionGroups.MapleDrop, box, result)
			local user = _UserService.LocalPlayer
			local final = {}
			for i=1,cnt do
				---@type DropComponent
				local d = result[i].Entity.DropComponent
				if (d.ReservedDestroy == 0) then
					if (_ItemDropLogic:CheckDropOwner(d.OwnType, d.OwnId, d.CreateTime, user, true)) then
						if (d.CreateTime + 1 <= now) then
							final[#final + 1] = d.Entity
						end
					end
				end
			end
			return final
		end
		local stop = petState == "IDLE" or petState == "ACTION"
		if (isvalid(self.SweepTarget)) then
			-- 플레이어 이동 -> clear
			if (abs(userPos.x - self.SweepOrigin.x) >= 0.05) then
				clearSweepTarget()
				return
			end
			
			local drop = self.SweepTarget.DropComponent
			if (isvalid(drop) and drop.DropId == self.SweepTargetId and drop.ReservedDestroy == 0) then
				local lastInputX = self.InputX
				local dropPos = drop.Position
				if (dropPos.x > petPos.x) then
					if (lastInputX ~= 1) then
						setWaitingServer()
						self:RequestPetAction("MOVE", 1)
					end
				elseif (dropPos.x < petPos.x) then
					if (lastInputX ~= -1) then
						setWaitingServer()
						self:RequestPetAction("MOVE", -1)
					end
				end
			else
				clearSweepTarget()
			end
		elseif ((stop and absXDiff > 0.8) or (absXDiff > maxMoveRange)) then
			setWaitingServer()
			self:RequestPetAction("MOVE", xDiff / absXDiff)
			clearSweepTarget()
		elseif (_Items:HasPetSkillAttr2(self, _PetSkillAttribute.DropSweep)) then
			local sdrops = getSweepableDrops()
			if (#sdrops > 0) then
				for i=1,#sdrops do
					local first = sdrops[i]
					local dropId = first.DropComponent.DropId
					local timeout = self.SweepTemporaryExceptions[dropId] or 0
					if (timeout > now) then
						continue
					end
					self.SweepTarget = first
					self.SweepTargetId = dropId
					self.SweepTemporaryExceptions[dropId] = now + 10
					self.SweepOrigin = userPos:Clone()
					return
				end
			end
		end
		
		if (not isvalid(self.SweepTarget)) then
			-- 가까워지면 멈추기
			if (self.InputX ~= 0) then
				if (absXDiff <= 0.8) then
					setWaitingServer()
					self:RequestPetAction("STOP", 0)
					return
				end
			end
		end
		
		-- 아이템 주울때
		--[[if (isvalid(self.SweepTarget)) then
			local dropPos = self.SweepTarget.TransformComponent.WorldPosition
			if (dropPos.y - petPos.y > 100.0) then
				if (self.InputX ~= 0) then
					if (abs(dropPos.x - petPos.x) <= 100.0) then
						setWaitingServer()
						self:RequestPetAction("TELEPORT", 0)
					end
				else
					setWaitingServer()
					self:RequestPetAction("JUMP", 0)
				end
				return
			end
		end]]
		--[[if (isvalid(self.SweepTarget)) then
			local dropPos = self.SweepTarget.TransformComponent.WorldPosition
			if (dropPos.y - petPos.y > 30.0) then
				if (self.InputX ~= 0) then
					if (abs(dropPos.x - petPos.x) <= 30.0) then
						-- 펫이 아이템과 가까이 있을 때 아이템의 위치로 이동
						pet.TransformComponent.WorldPosition = dropPos
						setWaitingServer()
						self:RequestPetAction("STOP", 0)
					end
				else
					setWaitingServer()
					self:RequestPetAction("JUMP", 0)
				end
				return
			end
		end]]
	
		-- 플랫폼 체크
		if (self.InputX ~= 0) then
			local petFh = pet.RigidbodyComponent:GetCurrentFoothold()
			if (petFh) then
				local petDir = pet.SpriteRendererComponent.FlipX and 1 or -1
				local x = petPos.x
				---@type Foothold
				local forward = _FootholdLogic:GetForwardLink(pet.CurrentMap, petFh, petDir, x, 0.65)
				if (forward == nil or (forward.Variance.x == 0 and forward.Variance.y * petDir > 0)) then
					setWaitingServer()
					self:RequestPetAction("JUMP", petDir)
				end
			end
		end

	end
	end