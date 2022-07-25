Route = {
	initialTargetFrame = 6029,
	maxDelay = 32,
	targetState = {
		tsType = "check pokemon stats",--TODO more types of targetState?
		player = 1,
		slot = 1,
		pokemonID = 7,-- Squirtle
		iv = 0x35FF94A5,-- 5HP/5ATK/5DEF/31SPA/26SPD/31SPE
		nature = 16-- Mild
	},
	delayPoints = {-- the names are optional, but helpful for clarity
		{
			name = "leave the house",
			frame = 3691,
			delayFrames = 2
		},
		{
			name = "start moving in Pallet",
			frame = 3808,
			delayFrames = 0
		},
		{
			name = "last input before triggering Oak cutscene",
			frame = 4008,
			delayFrames = 0
		},
		{
			name = "last input before going to the lab",
			frame = 4505,
			delayFrames = 0
			--delayFrames = 9
		},
		{
			name = "close Oak's last textbox",
			frame = 5762,
			delayFrames = 0
			--delayFrames = 5
		},
		{
			name = "talk to Poke Ball",
			frame = 5830,
			delayFrames = 0
			--delayFrames = 15
		},
		{
			name = "before final A press",
			frame = 6025,
			delayFrames = 0
			--delayFrames = 4
		},
	}
}