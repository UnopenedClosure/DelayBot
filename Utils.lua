dofile ("Data.lua")
dofile ("Memory.lua")

Utils={}

function Utils.getbits(a, b, d)
	return bit.rshift(a, b) % bit.lshift(1 ,d)
end

function Utils.addhalves(a)
	local b = Utils.getbits(a,0,16)
	local c = Utils.getbits(a,16,16)
	return b + c
end

function Utils.getPokemonData(player, slot)
	local start
	if player == 1 then
		start = 0x2024284
	else
		start = 0x202402C
	end
	start = start + 100 * (slot - 1)
	
	local personality = Memory.readdword(start)
	local otid = Memory.readdword(start + 4)
	local magicword = bit.bxor(personality, otid)
	
	local aux = personality % 24
	local growthoffset = (TableData.growth[aux+1] - 1) * 12
	local attackoffset = (TableData.attack[aux+1] - 1) * 12
	local effortoffset = (TableData.effort[aux+1] - 1) * 12
	local miscoffset   = (TableData.misc[aux+1]   - 1) * 12
	
	local growth1 = bit.bxor(Memory.readdword(start+32+growthoffset),   magicword)
	local growth2 = bit.bxor(Memory.readdword(start+32+growthoffset+4), magicword)
	local growth3 = bit.bxor(Memory.readdword(start+32+growthoffset+8), magicword)
	local attack1 = bit.bxor(Memory.readdword(start+32+attackoffset),   magicword)
	local attack2 = bit.bxor(Memory.readdword(start+32+attackoffset+4), magicword)
	local attack3 = bit.bxor(Memory.readdword(start+32+attackoffset+8), magicword)
	local effort1 = bit.bxor(Memory.readdword(start+32+effortoffset),   magicword)
	local effort2 = bit.bxor(Memory.readdword(start+32+effortoffset+4), magicword)
	local effort3 = bit.bxor(Memory.readdword(start+32+effortoffset+8), magicword)
	local misc1   = bit.bxor(Memory.readdword(start+32+miscoffset),     magicword)
	local misc2   = bit.bxor(Memory.readdword(start+32+miscoffset+4),   magicword)
	local misc3   = bit.bxor(Memory.readdword(start+32+miscoffset+8),   magicword)
	
	local cs = Utils.addhalves(growth1) + Utils.addhalves(growth2) + Utils.addhalves(growth3)
	         + Utils.addhalves(attack1) + Utils.addhalves(attack2) + Utils.addhalves(attack3)
			 + Utils.addhalves(effort1) + Utils.addhalves(effort2) + Utils.addhalves(effort3)
			 + Utils.addhalves(misc1)   + Utils.addhalves(misc2)   + Utils.addhalves(misc3)
	cs = cs % 65536
	
	local status_aux = Memory.readdword(start+80)
	local sleep_turns_result = 0
	local status_result = 0
	if status_aux == 0 then
		status_result = 0
	elseif status_aux < 8 then
		sleep_turns_result = status_aux
		status_result = 1
	elseif status_aux == 8 then
		status_result = 2	
	elseif status_aux == 16 then
		status_result = 3	
	elseif status_aux == 32 then
		status_result = 4	
	elseif status_aux == 64 then
		status_result = 5	
	elseif status_aux == 128 then
		status_result = 6	
	end

	
	return {
		pokemonID = Utils.getbits(growth1, 0, 16),
		heldItem = Utils.getbits(growth1, 16, 16),
		pokerus = Utils.getbits(misc1, 0, 8),
		tid = Utils.getbits(otid, 0, 16),
		sid = Utils.getbits(otid, 16, 16),
		iv = misc2,
		ev1 = effort1,
		ev2 = effort2,
		level = Memory.readbyte(start + 84),
		nature = personality % 25,
		pp = attack3,
		move1 = Utils.getbits(attack1, 0, 16),
		move2 = Utils.getbits(attack1, 16, 16),
		move3 = Utils.getbits(attack2, 0, 16),
		move4 = Utils.getbits(attack2, 16, 16),
		curHP = Memory.readword(start + 86),
		maxHP = Memory.readword(start + 88),
		atk = Memory.readword(start + 90),
		def = Memory.readword(start + 92),  
		spe = Memory.readword(start + 94),
		spa = Memory.readword(start + 96),
		spd = Memory.readword(start + 98),
		status = status_result,
		sleep_turns = sleep_turns_result
	}
end

function Utils.getLocation()
	return {
		map = Memory.readdword(0x02036DFC),
		xCoord = Memory.readword(0x02036E48),
		yCoord = Memory.readword(0x02036E4A)
	}
end

function Utils.getBagData()
	return {
		bagPocket = Memory.readbyte(0x0203AD02)
	}
end

function Utils.deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
        copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end