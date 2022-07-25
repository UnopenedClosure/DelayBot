--dofile ("route_starter_manip.lua")
dofile ("route_clefairy_manip.lua")
dofile ("Utils.lua")

--Ensure turbo-seek and auto-restore are on
--Ensure the branch is saved at or after the worst-case frame to search for
--Example: initalTargetFrame is 6029 and maxDelay is 40, so the branch should be saved at or after frame 6069
--TODO how well/poorly does this bot work if the delayPoints are not sorted initially?

local logInterval = 1000
local gcInterval = 1000
local branchNum = 68
local maxDelay = Route["maxDelay"]
local initialTargetFrame = Route["initialTargetFrame"]
local delayPoints = Route["delayPoints"]
local numDelayPoints = table.getn(delayPoints)
local targetState = Route["targetState"]
local candidates = {}
local passCount = 0
local resumeFlag = false
local failureStates = {}
local failureStateIndexes = {}
for x, v in pairs(delayPoints) do
	if v["delayFrames"] > 0 then
		resumeFlag = true
	end
end

for i, delayPoint in pairs(delayPoints) do
	if delayPoint["failureState"] ~= nil then
		failureStates[tonumber(i)] = delayPoint["failureState"]
	end
end
for k in pairs(failureStates) do table.insert(failureStateIndexes, k) end
table.sort(failureStateIndexes)

function checkBagStatus()
	local bagData = Utils.getBagData()
	return (targetState["bagPocket"] == bagData["bagPocket"])
end

function checkLocation()
	local locationData = Utils.getLocation()
	return (targetState["map"] == locationData["map"] and
			targetState["xCoord"] == locationData["xCoord"] and
			targetState["yCoord"] == locationData["yCoord"])
end

function checkPokemonStats()
	local pokemonData = Utils.getPokemonData(targetState["player"], targetState["slot"])
	return (targetState["pokemonID"] == pokemonData["pokemonID"] and
			targetState["iv"] == pokemonData["iv"] and
			targetState["nature"] == pokemonData["nature"])
end

-- total delay from indices 1 to endIndex
-- passing numDelayPoints gets the overall delay
function getTotalDelay(endIndex)
	local toReturn = 0
	if endIndex >= 1 then
		for x, y in pairs(delayPoints) do
			if x <= endIndex then
				toReturn = toReturn + y["delayFrames"]
			end
		end
	end
	return toReturn
end

--helper function for frame insertion and deletion
function getOffsetInitialFrameValue(x)
	return delayPoints[x]["frame"] + getTotalDelay(x - 1)
end

function incrementFrameDelay(i)
	delayPoints[i]["delayFrames"] = delayPoints[i]["delayFrames"] + 1
	tastudio.submitinsertframes(getOffsetInitialFrameValue(i), 1)
	tastudio.applyinputchanges()
end

function deepcopy(orig)
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

function runTest()
	local totalDelay = getTotalDelay(numDelayPoints)
	local targetFrame = initialTargetFrame + totalDelay
	
	local inputString = "["
	local delim = ""
	for x, v in pairs(delayPoints) do
		inputString = inputString .. delim .. v["delayFrames"]
		delim = ", "
	end
	inputString = inputString .. "]"
	
	if passCount % logInterval == 0 then
		local mess = "maxDelay = ".. maxDelay ..", delays are "
		mess = mess .. inputString .. ", advancing to frame " .. targetFrame
		console.writeline(mess)
	end
	if passCount % gcInterval == 0 then
		collectgarbage()
	end
	
	local earlyFailure = false
	for _, k in ipairs(failureStateIndexes) do
		if not earlyFailure then
			local intermediateTargetFrame = delayPoints[k]["frame"] + getTotalDelay(k)
			while emu.framecount() < intermediateTargetFrame do
				emu.frameadvance()
			end
			if failureStates[k]["map"] ~= nil then
				local locationData = Utils.getLocation()
				earlyFailure = (locationData["map"] ~= failureStates[k]["map"])
			elseif failureStates[k]["bagPocket"] ~= nil then
				local bagData = Utils.getBagData()
				earlyFailure = (bagData["bagPocket"] ~= failureStates[k]["bagPocket"])
			elseif failureStates[k]["pokemonID"] ~= nil then
				local pokemonData = Utils.getPokemonData(2, 1)--TODO enhance this to look for other slots
				earlyFailure = (pokemonData["pokemonID"] ~= failureStates[k]["pokemonID"])
			end
		end
	end
	
	if not earlyFailure then
		while emu.framecount() < targetFrame do
			emu.frameadvance()
		end
		
		--TODO combine the check functions
		if checkBagStatus() then
			if checkLocation() then
				if checkPokemonStats() then
					if totalDelay < maxDelay then
						--wipe the existing candidates
						local count = table.getn(candidates)
						for k = 0, count do candidates[k] = nil end
						maxDelay = totalDelay
					end
					
					--TODO why does this work for the version of deepcopy in the same file, but not the version in Utils?
					table.insert(candidates, deepcopy(delayPoints))
					--table.insert(candidates, Utils.deepcopy(delayPoints))
					
					console.writeline("Matched the target state for inputs " .. inputString .. ", maxDelay = " .. totalDelay .. ", found " .. table.getn(candidates) .. " candidates at this delay length")
				end
			end
		end
	end
	passCount = passCount + 1
end

--TODO document this function better? I can see it works, but I don't remember how
function searchFromInitialIndex(index)
	if index == numDelayPoints then --recursion base case
		if resumeFlag then
			resumeFlag = false
		end
		repeat
			runTest()
			incrementFrameDelay(index)
		until getTotalDelay(numDelayPoints) > maxDelay
	else
		while getTotalDelay(index) <= maxDelay do
			if resumeFlag == false then
				for j = (index + 1), numDelayPoints do
					tastudio.submitdeleteframes(getOffsetInitialFrameValue(j), delayPoints[j]["delayFrames"])
					tastudio.applyinputchanges()
					delayPoints[j]["delayFrames"] = 0
				end
			end
			searchFromInitialIndex(index + 1)
			incrementFrameDelay(index)
		end
	end
end

console.clear()
tastudio.setrecording(false)
tastudio.loadbranch(branchNum)
if resumeFlag then
	for i=1, numDelayPoints, 1 do
		local point = delayPoints[numDelayPoints + 1 - i]
		tastudio.submitinsertframes(point["frame"], point["delayFrames"])
		tastudio.applyinputchanges()
	end
end
searchFromInitialIndex(1)

--TODO print candidates