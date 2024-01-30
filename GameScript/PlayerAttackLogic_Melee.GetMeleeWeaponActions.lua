return function (self,prone,skill,weaponType,finalAttack) 
if (prone and skill == nil) then
	return {_CharacterAction.PRONESTAB}
else
	if (weaponType == _WeaponType.OneHandedSword or weaponType == _WeaponType.OneHandedAxe or weaponType == _WeaponType.OneHandedMace or weaponType == _WeaponType.Dagger) then
		if (finalAttack) then
			return {_CharacterAction.SWINGOF, _CharacterAction.STABOF}
		else
	    	return {_CharacterAction.SWINGO1, _CharacterAction.SWINGO2, _CharacterAction.SWINGO3, _CharacterAction.STABO1, _CharacterAction.STABO2}
		end
	elseif (weaponType == _WeaponType.TwoHandedSword or weaponType == _WeaponType.TwoHandedAxe or weaponType == _WeaponType.TwoHandedMace) then
		if (finalAttack) then
			return {_CharacterAction.SWINGTF, _CharacterAction.STABOF}
		else
		    return {_CharacterAction.SWINGT1, _CharacterAction.SWINGT2, _CharacterAction.SWINGT3, _CharacterAction.STABO1, _CharacterAction.STABO2}
		end
	elseif (weaponType == _WeaponType.Wand or weaponType == _WeaponType.Staff) then
		if (finalAttack) then
			return {}
		else
		    return {_CharacterAction.SWINGO2}
		end
	elseif (weaponType == _WeaponType.Spear or weaponType == _WeaponType.PoleArm) then
		if (finalAttack) then
			return {_CharacterAction.STABTF, _CharacterAction.SWINGPF}
		else
		    --return {_CharacterAction.SWINGT2, _CharacterAction.SWINGP1, _CharacterAction.SWINGP2, _CharacterAction.STABT1, _CharacterAction.STABT2}
			return {_CharacterAction.STABT1, _CharacterAction.STABT2}
		end
	elseif (weaponType == _WeaponType.Bow) then
		if (finalAttack) then
	    	return {}
		else
	    	return {_CharacterAction.SWINGT1, _CharacterAction.SWINGT3}
		end
	elseif (weaponType == _WeaponType.Crossbow) then
		if (finalAttack) then
	    	return {}
		else
	    	return {_CharacterAction.SWINGT1, _CharacterAction.STABT1}
		end
	elseif (weaponType == _WeaponType.ThrowingGlove) then
		if (finalAttack) then
		    return {}
		else
		    return {_CharacterAction.STABO1, _CharacterAction.STABO2}
		end
	end
end
end