return function (self,magic) 
	------------- zz_y7 --------------
	if zz_y7.use_attack_speed then
		return 3.5
	end
	------------- zz_y7 --------------
local speed
if (magic) then
	speed = 6
else
	speed = self.CurrentWeaponAttackSpeed
end
speed += self.Entity.PlayerTemporaryStat:GetValue(_CTS.Booster)
if (speed < 2) then
	return 2
end
if (speed > 10) then
	return 10
end
return speed
end