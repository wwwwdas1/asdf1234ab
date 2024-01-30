return function (self,state) 

if zz_y7.people_hide then
	return false
end

if (state == "IDLE" or state == "MOVE" or state == "PRONE" or state == "FALL" or state == "JUMP" or state == "ALERT" or state == "FLY") then
	return true
end
return false
end