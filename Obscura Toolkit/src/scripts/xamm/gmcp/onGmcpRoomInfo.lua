cofudlet = cofudlet or {}
cofudlet.map = cofudlet.map or {}
local map = cofudlet.map

local function updateCoords(coords, direction)
	-- log(f"Updating coords: {coords.x} {coords.y} {coords.z} towards {direction}")
	if direction == "north" then coords.y = coords.y + 1
	elseif direction == "east" then coords.x = coords.x + 1
	elseif direction == "south" then coords.y = coords.y - 1
	elseif direction == "west" then coords.x = coords.x - 1
	elseif direction == "up" then coords.z = coords.z + 1
	elseif direction == "down" then coords.z = coords.z - 1
	elseif direction == "northeast" then coords.y = coords.y + 1 ; coords.x = coords.x + 1
	elseif direction == "northwest" then coords.y = coords.y + 1 ; coords.x = coords.x - 1
	elseif direction == "southeast" then coords.y = coords.y - 1 ; coords.x = coords.x + 1
	elseif direction == "southwest" then coords.y = coords.y - 1 ; coords.x = coords.x - 1
	else return nil
	end
	return coords
end

local function getDirectionBetweenRooms(from, to)
	for dir, tgt in pairs(getRoomExits(from)) do
		if tgt == to then
			return dir
		end
	end
end

map.setCoords = function(from, to, dir)
	local prevCoords = {x=0, y=0, z=0}
	prevCoords.x, prevCoords.y, prevCoords.z = getRoomCoordinates(from)
	-- log(f"Room prevCoords: {prevCoords.x} {prevCoords.y} {prevCoords.z}")
	local nDir = map.normalizedDirections[string.lower(dir)]
	local coords = updateCoords(prevCoords, nDir)
	-- log(f"Map debug: checking for collisions at area {getRoomArea(from)}, room {to}: {coords.x} {coords.y} {coords.z}")
	local collisions = getRoomsByPosition(getRoomArea(from), coords.x, coords.y, coords.z)

	-- idempotency
	for _, rid in pairs(collisions) do
		if rid == to then
			return
		end
	end

	if next(collisions) then
		local direction = getDirectionBetweenRooms(from, to)
		log(f"Map: Collision detected. Shifting rooms to fit this one. Direction: {direction}")
		for _, cid in pairs(getAreaRooms(getRoomArea(from))) do
			if cid ~= from then
				local shiftX, shiftY, shiftZ = getRoomCoordinates(cid)
				if direction == 'down' and shiftZ <= coords.z then setRoomCoordinates(cid, shiftX, shiftY, shiftZ - 1)
				elseif direction == 'up' and shiftX >= coords.z then setRoomCoordinates(cid, shiftX, shiftY, shiftZ + 1)
				elseif shiftZ == coords.z then
					if direction == 'north' and shiftY >= coords.y then setRoomCoordinates(cid, shiftX, shiftY + 1, shiftZ)
					elseif direction == 'south' and shiftY <= coords.y then setRoomCoordinates(cid, shiftX, shiftY - 1, shiftZ)
					elseif direction == 'west' and shiftX <= coords.x then setRoomCoordinates(cid, shiftX - 1, shiftY, shiftZ)
					elseif direction == 'east' and shiftX >= coords.x then setRoomCoordinates(cid, shiftX + 1, shiftY, shiftZ)
					end
				end
			end
		end
	end
	-- log(f"Room {to} coords: {coords.x} {coords.y} {coords.z}")
	setRoomCoordinates(to, coords.x, coords.y, coords.z)
end

local function abortMapping()
	map.mapping = false
end

local function maybeAddArea(startRoom)
	local areaName = gmcp.room.info.zone
	local area = getAreaTable()[areaName]
	if area == nil then
		area = addAreaName(areaName)
		if startRoom ~= -1 then
			setAreaUserData(area, "startRoomCid", startRoom)
		end
		log(f"Map: New area {area}: {areaName}, startRoom={startRoom}")
		return area, true
	end
	return area, false
end

local function getHighestCoord(areaId)
	local rooms = getAreaRooms(areaId)
	if not rooms then return 0 end
	local maxZ = 0
	local first = true
	for _, cid in pairs(rooms) do
		local x, y, z = getRoomCoordinates(cid)
		if first then
			maxZ = z
			first = false
		elseif z > maxZ then
			maxZ = z
		end
	end
	return maxZ
end

-- Mazes
-- ~~~~~
--
-- There are at least 4 kinds of mazes:
-- 1. fully connected blocks of rooms (every room, except edges, has 4 doors leading to all adjacent rooms): Goblin Mountains#24#(x, y)
-- 2. sparsely connected rooms (rooms are connected to adjacent rooms, but it's more difficult to find a way through corridors): Orthindar#214#(x, y), Medley Orchard's storyquest mazes
-- For all cases, track exits - if exits have changed at all (which will never trigger for case 1), then remove & rediscover all exits in the maze.
local mazePattern = "^[^#]+#(%d+)#%((%d+),(%d+)%)$"
local function isMaze(roomID)
	return string.match(roomID, mazePattern)
end

-- lua for _, cid in pairs(getAreaRooms(getRoomArea(getPlayerRoom()))) do local id = getRoomUserData(cid, "id"); log(f"{cid} {id}") end
local function tryCalculateMazeCoordinates(roomID, exitID)
	-- CoffeeMUD mazes are described with just one room ID + coords: Sewers#7019#(9,5)
	_, _, thisX, thisY = string.find(roomID, "^[^#]+#%d+#%((%d+),(%d+)%)$")
	-- log("TODO calculate mazy coordinates")
	return string.find(roomID, "^[^#]+#%d+#%(%d+,%d+%)$")
end

-- Incomplete. It might happen that we walk through half the maze, which randomly happens to have the same
-- layout like last time, until finally hitting a room which we retain, but delete the rest. Instead,
-- we should also retain the path traversed so far - yet that's too much of a hassle.
local function deleteAllExitsFromThisMazeExcept(cid, niceId)
	local mazeId, x, y = isMaze(niceId)
	if not mazeId or not x or not y then return end
	for _, rid in pairs(getAreaRooms(getRoomArea(cid))) do
		local niceId2 = getRoomUserData(rid, "id")
		local mazeId2, x2, y2 = isMaze(niceId2)
		if mazeId2 == mazeId and rid ~= cid then
			log(f"Removing exits from maze: {niceId2}")
			for dir, _ in pairs(getRoomExits(rid)) do
				setExit(rid, -1, dir)
			end
		end
	end
end

-- TODO: split and clean up
function onGmcpRoomInfo()
	local num = tostring(gmcp.room.info.num)
	local roomID = getRoomIDbyHash(num)

	local niceId = gmcp.room.info.id

	local areaId, newArea = maybeAddArea(roomID)
	if roomID == -1 and not newArea then
		log(f"Map: teleported. Resetting coordinates to highest+100. If this place is also reachable via walking, you'll need to manually attach coordinates from the walkable side, with `map attach`.")
		z = getHighestCoord(areaId)
		roomID = createRoomID()
		addRoom(roomID)
		setRoomIDbyHash(roomID, num)
		setRoomCoordinates(roomID, 0, 0, z + 100)
	elseif roomID == -1 and newArea then
		roomID = createRoomID()
		addRoom(roomID)
		setRoomIDbyHash(roomID, num)
		setAreaUserData(areaId, "startRoomCid", roomID)
		log(f"Map: backfilled missing area {areaId} {gmcp.room.info.zone} start room to {roomID}")
	end

	if newArea then
		setRoomCoordinates(roomID, 0, 0, 0)
	end

	-- Normally this would go into the "Things that never change" section, but my imported maps lack IDs :(
	-- TODO: map all the IDs, then move this line there.
	setRoomUserData(roomID, "id", niceId)

	-- TODO: estimate move cost by moves lost (what about flight, mounts, etc?)

	-- Things that might change: when you visit a previously hinted-at room,
	-- its exits get populated
	for exitDir, rawTargetNum in pairs(gmcp.room.info.exits) do
		local targetNum = tostring(rawTargetNum)
		local exitID = getRoomIDbyHash(targetNum)
		-- log(f"Map: exit stub towards {exitDir}")

		if exitID == -1 then
			exitID = createRoomID()
			addRoom(exitID)
			tempTimer(0, function() raiseEvent('cofudlet.onNewRoom', exitID) end)
			setRoomIDbyHash(exitID, targetNum)
			if exitDir == "V" then
				addSpecialExit(roomID, exitID, "enter there")
			else
				setExit(roomID, exitID, exitDir)
			end

			map.setCoords(roomID, exitID, exitDir)
			setRoomArea(exitID, areaId)
		else
			-- log(f"Not populating already seen exit from {roomID} towards {exitDir} to {exitID}, coords from {coords(roomID)} to {coords(exitID)}")
			-- tryCalculateMazeCoordinates(roomID, exitID)
			-- Partially connected mazes lose some exits every now and then. If exits disappear for this room, remove them for the whole maze - it's probably better to rediscover the whole maze rather than speedwalk through missing exits.
			-- CoffeeMUD's exits don't normally disappear, not even secret exits.
			-- This means we can just prune any missing exits regardless of whether they're mazy.
			local found = false
			local normalizedDir = map.normalizedDirections[exitDir]
			for mapDir, mapTgt in pairs(getRoomExits(roomID)) do
				if mapDir == normalizedDir then
					found = true
					if mapTgt ~= exitID then
						log(f"Exit from {roomID} {mapDir}ward to {mapTgt} reconnected to {exitID}")
						setExit(roomID, exitID, mapDir)
					end
					break
				end
			end
			if not found then
				if getRoomUserData(roomID, "terrain") ~= "" then
					log(f"Existing room got a new exit from {roomID} {exitDir}ward to {exitID}")
				end
				setExit(roomID, exitID, exitDir)
			end
		end
	end

	-- Prune disappeared exits
	-- Best not do this, because darkness / dirt-kicking would disappearify exits.
	if false then
		for mapDir, mapTgt in pairs(getRoomExits(roomID)) do
			local found = false
			for exitDir, targetNum in pairs(gmcp.room.info.exits) do
				local normalizedExDir = map.normalizedDirections[exitDir]
				if normalizedExDir == mapDir then
					found = true
				end
			end
			if not found then
				log("no match")
				log(f"Exit from {roomID} {mapDir}wards to {mapTgt} disappeared, removing")
				setExit(roomID, -1, mapDir)

				deleteAllExitsFromThisMazeExcept(roomID, niceId)
			end
		end
	end

	-- Things that never change
	if getRoomUserData(roomID, "terrain") == "" then -- 1st visit to the room populates this
		local roomName = stripColors(gmcp.room.info.name)
		log(f"Map: new room {niceId}: {roomName}")
		setRoomName(roomID, roomName)
		setRoomArea(roomID, areaId)
		local terrain = gmcp.room.info.terrain
		setRoomUserData(roomID, "terrain", terrain)
		if terrain == "underwater" or terrain == "watersurface" or terrain == "in_underwater" or terrain == "cavelakesurface" then
			setRoomWeight(roomID, 10)
		elseif terrain == "air" or terrain == "gap" then
			setRoomWeight(roomID, 20)
		end

		local color = cofudlet.map.terrainColors[gmcp.room.info.terrain]
		if color ~= nil then -- Might want to consider adding new ones dynamically
			setRoomEnv(roomID, color)
		else
			log(f"Previously unseen terrain, need to add color: {gmcp.room.info.terrain}")
		end

		-- Rooms in randomly connected mazes don't get placed correctly in the
		-- 1st try - walk S of (0,0) and we expect to end up at (0,1), but
		-- could really go anywhere.
		-- Upon entering a new maze room for the 1st time, readjust its coordinates
	end

	map.lastRoom = map.thisRoom
	map.thisRoom = roomID
	centerview(roomID)
end

local function isLocked(room, direction)
	local rdSerialized = getRoomUserData(room, "exitLocks")
	if not rdSerialized then
		return false
	end
	local rd = yajl.to_value(rd)
	-- TODO: check for my level
	return rd[direction] ~= nil
end

