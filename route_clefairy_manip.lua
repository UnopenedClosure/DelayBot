Route = {
	initialTargetFrame = 67064,
	maxDelay = 18,
	targetState = {
		map = 0x082FC778,-- Mt. Moon B2F
		xCoord = 18,
		yCoord = 28,
		registeredItem = 0x016C,-- TM Case
		bagPocket = 2,-- Balls Pocket
		tsType = {"check pokemon stats", "location", "bag status"},--TODO actually use this for something?
		player = 2,
		slot = 1,
		pokemonID = 35,-- Clefairy
		iv = 0x29FFA7E8,-- 8HP/31ATK/9DEF/31SPA/20SPD/31SPE
		--     SPD   SPA   SPE   DEF   ATK    HP  
		-- --______-------______------______------
		-- 0010 1001 1111 1111 1010 0111 1110 1000
		
		nature = 4-- Naughty
	},


	delayPoints = {-- the names are optional, but helpful for clarity
		{
			name = "end of Spearow",
			frame = 61757,
			delayFrames = 0
		},
		{
			name = "start moving after Spearow",
			frame = 61931,
			delayFrames = 0
		},
		{
			name = "last input before entering Center",
			frame = 62132,
			delayFrames = 0
		},
		{--TODO add failure state for the NPC not moving/PC activity failure?
			name = "last input before leaving Center",
			frame = 63914,
			delayFrames = 0
		},
		{
			name = "start moving after Center",
			frame = 64085,
			delayFrames = 0
		},
		{
			name = "start moving in Mt Moon",
			frame = 64321,
			delayFrames = 1
		},
		{
			name = "exit bag",
			frame = 64610,
			delayFrames = 1,
			failureState = {
				name = "early encounter",
				operator = "not equals",
				pokemonID = 21
			}
		},
		{
			name = "start moving after first Repel",
			frame = 64675,
			delayFrames = 0,
			failureState = {
				name = "failed to register TM Case",
				operator = "not equals",
				registeredItem = 0x016C
			}
		},
		{
			name = "start moving after Moon Stone",
			frame = 65538,
			delayFrames = 3
		},
		{
			name = "start moving after first ladder",
			frame = 65641,
			delayFrames = 3
		},
		{
			name = "start moving after first Repel wears off",
			frame = 65720,
			delayFrames = 1
		},
		{
			name = "start moving after second Repel",
			frame = 66104,
			delayFrames = 0,
			failureState = {
				name = "early encounter",
				operator = "not equals",
				pokemonID = 21
			}
		},
		{
			name = "start moving after second ladder",
			frame = 66245,
			delayFrames = 0,
			failureState = {
				name = "cursor not in Balls Pocket",
				operator = "not equals",
				bagPocket = 2
			}
		},
		{
			name = "start moving after second Repel wears off",
			frame = 67035,
			delayFrames = 3,
			failureState = {
				name = "wrong map",
				operation = "not equals",
				map = 0x082FC778
			}
		},
		{
			name = "last input before encounter",
			frame = 67053,
			delayFrames = 1
		},
	}
}