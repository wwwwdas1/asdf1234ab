return function (self,user,type,pos) 

	if zz_y7.use_infi then
		return true
	end
	
local u = user.WsUser
local last = u.AntiRepeat[type]
if (not last) then
	last = {pos, 0}
	u.AntiRepeat[type] = last
	return true
end
---@type Vector2
local lastPos = last[1]
local abs = math.abs
if (abs(lastPos.x - pos.x) >= 0.06 or abs(lastPos.y - pos.y) >= 1.5) then
	u.AntiRepeat[type] = {pos, 0}
	return true
end
last[2] += 1
if (type == 0) then -- b
	if (last[2] >= 20) then
		return false
	end
else
	if (last[2] >= 100) then
		return false
	end
end
return true
end