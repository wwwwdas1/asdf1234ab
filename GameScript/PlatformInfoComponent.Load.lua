return function (self) 
local footholdComponent = self.Entity.CurrentMap.FootholdComponent
local mapInfo = self.Entity.CurrentMap.MapInfoComponent
local platformIndex = 0
local abs = math.abs
local getFoothold = footholdComponent.GetFoothold

---@param fh Foothold
---@param dir integer
local function getWallHeight(fh, dir)
	local len = 0
	while true do
		if (dir < 0) then
			len += (fh.EndPoint.y - fh.StartPoint.y)
			if (fh.PreviousFootholdId == 0) then
				break
			end
			fh = getFoothold(footholdComponent, fh.PreviousFootholdId)
		else
			len += (fh.StartPoint.y - fh.EndPoint.y)
			if (fh.NextFootholdId == 0) then
				break
			end
			fh = getFoothold(footholdComponent, fh.NextFootholdId)
		end
		if (not fh or fh.Variance.x ~= 0) then
			break
		end
	end
	return len
end

---@param var Vector2
---@param edge table
---@param wallPoint Vector2
---@param edgePoint Vector2
---@param fh Foothold
---@param sign integer
---@return void
local function setEdgeData(var, edge, wallPoint, edgePoint, fh, sign)
	if (var.x == 0) then
		-- wall
		if (var.y < 0) then
			edge.dir = -1 * sign
		elseif (var.y > 0) then
			edge.dir = 1 * sign
		end
		edge.x = wallPoint.x
		edge.y = wallPoint.y
		edge.length = getWallHeight(fh, sign)
	else
		-- object
		edge.x = edgePoint.x
		edge.y = edgePoint.y
	end
	edge.foothold = fh
end

---@param fh Foothold
---@return table, table, integer
local function makePlatform(fh)
	local leftEdge, rightEdge = {x = 0, y = 0, dir = 0, length = 0}, {x = 0, y = 0, dir = 0, length = 0}
	local fhList = {fh.Id}
	local fhListIndex = 1
	local cur = fh
	local visited1 = {}
	while cur.PreviousFootholdId ~= 0 do
		cur = getFoothold(footholdComponent, cur.PreviousFootholdId)
		if (visited1[cur.Id]) then
			break
		end
		visited1[cur.Id] = true
		fhList[fhListIndex + 1] = cur.Id
		fhListIndex += 1
		if (cur.Variance.x == 0) then
			-- 벽 발견
			break
		end
	end
	setEdgeData(cur.Variance, leftEdge, cur.EndPoint, cur.StartPoint, cur, -1)
	cur = fh
	local visited2 = {}
	while cur.NextFootholdId ~= 0 do
		cur = getFoothold(footholdComponent, cur.NextFootholdId)
		if (visited2[cur.Id]) then
			break
		end
		visited2[cur.Id] = true
		fhList[fhListIndex + 1] = cur.Id
		fhListIndex += 1
		if (cur.Variance.x == 0) then
			-- 벽 발견
			break
		end
	end
	setEdgeData(cur.Variance, rightEdge, cur.StartPoint, cur.EndPoint, cur, 1)
	if (isvalid(mapInfo)) then
		local boundLeft = mapInfo.BoundLb.x
		local boundRight = mapInfo.BoundRt.x
		if (leftEdge.x < boundLeft) then
			leftEdge.x = boundLeft
		end
		if (rightEdge.x > boundRight) then
			rightEdge.x = boundRight
		end
	end
	return {left = leftEdge, right = rightEdge}, fhList, fhListIndex
end

---@param platform table
---@param previous table
---@return table
local function connectEachOther(platform, previous)
	if (platform.left.id == platform.right.id) then
		return previous
	elseif (previous.left.id == previous.right.id) then
		return platform
	end
	
	if (platform.right.id == previous.left.id) then
		return {id = 0, left = previous.left, right = platform.right}
	elseif (platform.left.id == previous.right.id) then
		return {id = 0, left = platform.left, right = previous.right}
	else
		--log_error("how you do this")
	end
end

local function insertPlatform(p)
	self.Platforms[platformIndex + 1] = p
	platformIndex += 1
	p.id = platformIndex
end

local zMass = _DataService:GetTable("zMass")
local row = zMass:FindRow("map", self.Entity.CurrentMapName)
local hashes = {}
if (row ~= nil) then
	hashes = _HttpService:JSONDecode(row:GetItem("data"))
end

local ceil = math.ceil
local floor = math.floor
local format = string.format
local function truncate(n)
	if (n < 0) then
		return ceil(n-0.5)
	else
		return floor(n+0.5)
	end
end

---@param fh Foothold
---@return string
local function makeHash1(fh)
	return format("%0.2f|%0.2f|%0.2f|%0.2f",
		fh.StartPoint.x, fh.StartPoint.y, fh.EndPoint.x, fh.EndPoint.y)
    --local x1 = floor(fh.StartPoint.x * 100)
    --local y1 = floor(fh.StartPoint.y * 100)
    --local x2 = floor(fh.EndPoint.x * 100)
    --local y2 = floor(fh.EndPoint.x * 100)
    --return x1 * 1337 + y1 * 24437 + x2 * 86437 + y2 * 131078
    --local state = _XXHash64:CreateState(0)	
    --state:update(string.pack("<i8", truncate(fh.StartPoint.x * 100)))
    --state:update(string.pack("<i8", truncate(fh.StartPoint.y * 100)))
    --state:update(string.pack("<i8", truncate(fh.EndPoint.x * 100)))
    --state:update(string.pack("<i8", truncate(fh.EndPoint.y * 100)))
    --return state:digest()
end
---@param fh Foothold
---@return string
local function makeHash2(fh)
	return format("%0.2f|%0.2f|%0.2f|%0.2f",
		fh.EndPoint.x, fh.EndPoint.y, fh.StartPoint.x, fh.StartPoint.y)
end

local footholds = footholdComponent:GetFootholdAll()
local zMassTable = self.ZMass
local footholdToPlatform = self.FootholdToPlatform
for i=1,#footholds do
	local fh = footholds[i]
	local hash1 = makeHash1(fh)
	local hash2 = makeHash2(fh)
	
	-- zMass
	local zMassID1 = hashes[tostring(hash1)] or -2
    --log(string.format("[FH:%d] x1: %d  y1: %d  x2: %d  y2: %d  -->>  Hash: %d (zMass:%d)",
    --        fh.Id,
    --        floor(fh.StartPoint.x * 100),
    --        floor(fh.StartPoint.y * 100),
    --        floor(fh.EndPoint.x * 100),
    --        floor(fh.EndPoint.y * 100),
    --        hash,
    --        zMassID))
	if (zMassID1 == -2) then
		local zMassID2 = hashes[tostring(hash2)] or -2
        --log(string.format("[FH:%d/ZM2] x1: %0.2f  y1: %0.2f  x2: %0.2f  y2: %0.2f  -->>  Hash: %s (zMass:%d)",
        --        fh.Id,
        --        fh.EndPoint.x,
        --        fh.EndPoint.y,
        --        fh.StartPoint.x,
        --        fh.StartPoint.y,
        --        hash2,
        --        zMassID2))
		zMassTable[fh.Id] = zMassID2
	else
    --log(string.format("[FH:%d/ZM1] x1: %0.2f  y1: %0.2f  x2: %0.2f  y2: %0.2f  -->>  Hash: %s (zMass:%d)",
    --        fh.Id,
    --        fh.StartPoint.x,
    --        fh.StartPoint.y,
    --        fh.EndPoint.x,
    --        fh.EndPoint.y,
    --        hash1,
    --        zMassID1))
		zMassTable[fh.Id] = zMassID1
	end
	
	if (footholdToPlatform[fh.Id]) then
		-- 이미 등록된 Foothold -> Platform
		continue
	end
	
	local platform, fhList, fhListNum = makePlatform(fh)
	
	-- 새 플랫폼 삽입
	insertPlatform(platform)
	
	for j=1,fhListNum do
		footholdToPlatform[fhList[j]] = platform
	end
end

--local function getType(dir)
--    if (dir < 0) then
--        return "wall(down)"
--    elseif (dir > 0) then
--        return "wall(up)"
--    else
--        return "edge"
--    end
--end
--
--for key,platform in pairs(self.Platforms) do
--    log(string.format("id: %d [Left:(%.2f, %.2f) dir=%s] [Right:(%.2f, %.2f) type=%s]",
--            key, 
--            platform.left.x, platform.left.y, getType(platform.left.dir),
--            platform.right.x, platform.right.y, getType(platform.right.dir)))
--end
--for fhid,platform in pairs(self.FootholdToPlatform) do
--    log(string.format("fh: %d -> platform %d", fhid, platform.id))
--end
end