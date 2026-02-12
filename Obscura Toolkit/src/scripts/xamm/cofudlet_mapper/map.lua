cofudlet = cofudlet or {}
cofudlet.map = cofudlet.map or {}
cofudlet.ui = cofudlet.ui or {}
local map = cofudlet.map

-- Create mapper widget in XAMM's layout position (right side)
-- Wrap in a container to isolate from other Geyser widgets (matches original XAMM pattern)
cofudlet.ui.mapperContainer = cofudlet.ui.mapperContainer or Geyser.Container:new({
  x = 0, y = 0, width = "100%", height = "100%",
  name = "mapper container"
})
cofudlet.ui.mapper = cofudlet.ui.mapper or Geyser.Mapper:new({
  name = "mapper",
  x = "65%", y = 20,
  width = "35%", height = 480
}, cofudlet.ui.mapperContainer)

map.terrainColors = {
	-- Admire the colors at https://wiki.mudlet.org/w/Manual:Lua_Functions#setCustomEnvColor - they're also configurable by the end user.
	city = 263,
	woods = 258,
	rocky = 272,
	plains = 266,
	underwater = 260,
	air = 270,
	watersurface = 268,
	jungle = 262,
	swamp = 259,
	desert = 267,
	hills = 261,
	mountains = 269,
	spaceport = 271,
	seaport =271,

	-- indoors
	stone = 263,
	wooden = 259,
	cave = 272,
	magic = 269,
	in_underwater = 260,
	gap = 271,
	cavelakesurface = 268,
	metal = 272,
	innerseaport = 271,
	caveseaport = 271,
}

map.normalizedDirections = {
	N = 'north',
	E = 'east',
	S = 'south',
	W = 'west',
	U = 'up',
	D = 'down',
	n = 'north',
	e = 'east',
	s = 'south',
	w = 'west',
	u = 'up',
	d = 'down',
	north = 'north',
	east = 'east',
	south = 'south',
	west = 'west',
	up = 'up',
	down = 'down',
	nw = 'northwest',
	ne = 'northeast',
	sw = 'southwest',
	se = 'southeast',
	northwest = 'northwest',
	northeast = 'northeast',
	southwest = 'southwest',
	southeast = 'southeast',
}

map.shortDirections = {
	north = 'n',
	east = 'e',
	south = 's',
	west = 'w',
	up = 'u',
	down = 'd',
	northwest = 'nw',
	northeast = 'ne',
	southwest = 'sw',
	southeast = 'se',
}

map.currentArea = function()
	local areaName = gmcp.room.info.zone
	return getAreaTable()[areaName]
end

map.isInstanced = function()
     return string.match(gmcp.room.info.zone, " of Mystery")
end

local function currentArea() return map.currentArea() end

-- visitRoom returs nil to continue search, or a value to signal the end of search (like path to desired room).
-- visitExit returns true if we should stop BFSing after this exit.
local function search(here, visitRoom, visitExit, bypassLocks, inArea, breadthFirst)
	local area1 = getRoomArea(getPlayerRoom())
	local visited = {}
	local roomq = List.new()
	List.pushRight(roomq, here)
	while not List.isEmpty(roomq) do
		local room = breadthFirst and List.popLeft(roomq) or List.popRight(roomq)
		if visited[room] == nil then -- A given room might end up in the queue through different paths
			local ex = getRoomExits(room)
			for exDir, exTgt in pairs(ex) do
				if (bypassLocks or not hasExitLock(room, exDir)) and (not inArea or getRoomArea(exTgt) == -1 or area1 == getRoomArea(exTgt)) --[[and not isHardLocked(room, exDir) ]] then
					-- TODO: add options to path through swim-only rooms, etc
					--[[
					  if True and ex[exDir].get('data', {}).get('swim'):
							continue
					  if True and ex[exDir].get('data', {}).get('crawl'):
							continue
					  if True and ex[exDir].get('data', {}).get('climb'):
							continue
					  if True and ex[exDir].get('data', {}).get('fly'):
							continue
					]]
					if not visitExit(room, exDir, exTgt) then
						List.pushRight(roomq, exTgt)
					end
				end
			end
			local res = visitRoom(room)
			if res ~= nil then
				return res
			end
			visited[room] = true
		end
	end
end

map.bfs = function(here, visitRoom, visitExit, bypassLocks, inArea)
	return search(here, visitRoom, visitExit, bypassLocks, inArea, true)
end

map.dfs = function(here, visitRoom, visitExit, bypassLocks, inArea)
	return search(here, visitRoom, visitExit, bypassLocks, inArea, false)
end

cofudlet.map.runifyDirs = function(directions)
	count = 1
	out = ""
	first = true
	for i = 2, #directions do
		if directions[i-1] == directions[i] then
			count = count + 1
		else
			if first then
				first = false
			else
				out = out .. ' '
			end
			out = out .. (count == 1 and "" or count) .. directions[i-1]
			count = 1
		end
	end
	if not first then
		out = out .. ' '
	end
	out = out .. (count == 1 and "" or count) .. directions[#directions]
	return out
end

assert(cofudlet.map.runifyDirs({ 'e' }) == 'e')
assert(cofudlet.map.runifyDirs({ 'e', 'e' }) == '2e')
assert(cofudlet.map.runifyDirs({ 'n', 'e', 'e' }) == 'n 2e')
assert(cofudlet.map.runifyDirs({ 'e', 'e', 'n' }) == '2e n')

cofudlet.map.assemble = function(dirs, mode)
	local directions = {} -- streak of non-special exits
	local out = {}
	for _, compoundDir in ipairs(dirs) do
		for _, dir in ipairs(string.split(compoundDir, ';;')) do
			if dir == 'down' then dir = 'd'
			elseif dir == 'up' then dir = 'u' end
			if not map.normalizedDirections[dir] then
				if next(directions) then
					table.insert(out, mode .. ' ' .. cofudlet.map.runifyDirs(directions))
				end
				table.insert(out, dir)
				directions = {}
			else
				table.insert(directions, dir)
			end
		end
	end
	if next(directions) then
		table.insert(out, mode .. ' ' .. cofudlet.map.runifyDirs(directions))
	end
	return table.concat(out, ';;')
end

assert(cofudlet.map.assemble({ 'e' }, 'go') == 'go e')
assert(cofudlet.map.assemble({ 'e', 'e' }, 'go') == 'go 2e')
assert(cofudlet.map.assemble({ 'n', 'e', 'e' }, 'go') == 'go n 2e')
assert(cofudlet.map.assemble({ 'e', 'e', 'n' }, 'go') == 'go 2e n')

assert(cofudlet.map.assemble({ 'open e;;e', 'e' }, 'go') == 'open e;;go 2e')
assert(cofudlet.map.assemble({ 'open e;;e', 'e', 'e' }, 'go') == 'open e;;go 3e')
assert(cofudlet.map.assemble({ 'open e;;e', 'n', 'e', 'e' }, 'go') == 'open e;;go e n 2e')
assert(cofudlet.map.assemble({ 'open e;;e', 'e', 'e', 'n' }, 'go') == 'open e;;go 3e n')

assert(cofudlet.map.assemble({ 'e', 'open e;;e', 'n' }, 'go') == 'go e;;open e;;go e n')
assert(cofudlet.map.assemble({ 'e', 'e', 'open e;;e', 'n' }, 'go') == 'go 2e;;open e;;go e n')

-- TODO: implement swim/crawl/fly/climb locks.
-- TODO: implement level locks.
function doSpeedWalk()
	local goCmd = map.goCmd or "go"
	send(cofudlet.map.assemble(speedWalkDir, goCmd))
end

cofudlet.map.oppositeDirections = {
	north="south",
	east="west",
	south="north",
	west="east",
	up="down",
	down="up",
	northwest="southeast",
	northeast="southwest",
	southwest="northeast",
	southeast="southwest",
}

local function targetToCid(there)
	local bookmarks = yajl.to_value(getMapUserData("bookmarks") or "{}")
	if bookmarks[there] then
		there = bookmarks[there]
		log(f"Map: going to bookmark {parameter} Cid {there}")
		return there
	end

	local areaId = getAreaTable()[there]
	if areaId then
		there = getAreaUserData(areaId, "startRoomCid")
		log(f"Map: going to area {parameter}, start room {there}")
		return there
	end

	local areaId = getAreaTable()[string.gsub(there, "'", '`')]
	if areaId then
		there = getAreaUserData(areaId, "startRoomCid")
		log(f"Map: going to area {parameter}, start room {there}")
		return there
	end

	if tonumber(there) then
		local cid = getRoomIDbyHash(there)
		if cid ~= -1 then
			log(f"Map: going to {getRoomUserData(cid, 'id')} {getRoomName(cid)}")
			return cid
		end

		local num = getRoomHashByID(there)
		if num then
			log(f"Map: going to {getRoomUserData(there, 'id')} {getRoomName(there)}")
			return there
		end
	end

	if string.find(there, ".+#%d+$") then
		local areaName = string.gsub(there, "#%d+$", "")
		areaId = getAreaTable()[areaName] -- Lua has weird shadowing rules - can create a new local here, but next line, the wrong one will be read.
		for _, cid in pairs(getAreaRooms(areaId)) do
			if getRoomUserData(cid, "id") == there then
				log(f"Map: going to area {areaId}, {areaName} room {there}")
				return cid
			end
		end
		log(f"Map: couldn't find room {there} in area {areaId} {areaName}")
		return
	end

	local allRooms = getRooms()
	local exactMatches = {}
	local upperThere = there:upper()
	for cid, rname in ipairs(allRooms) do
		if string.gsub(rname:upper(), "`", "'") == string.gsub(upperThere, "`", "'")  then
			exactMatches[#exactMatches+1] = cid
		end
	end

	if #exactMatches == 1 then
		log(f"Map: going to room {there}, Cid {exactMatches[1]}")
		return exactMatches[1]
	elseif #exactMatches > 1 then
		log(f"Map: TODO implement room selection. Meanwhile, `map go` to one of these rooms:")
		display(exactMatches)
		return
	end

	local fuzzyMatches = {}
	for cid, rname in ipairs(allRooms) do
		if string.find(string.gsub(rname:upper(), "`", "'"), string.gsub(upperThere, "`", "'")) then
			fuzzyMatches[#fuzzyMatches+1] = {cid = cid, name = rname}
		end
	end
	if #fuzzyMatches == 1 then
		log(f"Map: going to room {fuzzyMatches[1].cid} {fuzzyMatches[1].name}")
		return fuzzyMatches[1].cid
	elseif #fuzzyMatches > 1 then
		log(f"Map: TODO implement room selection. Meanwhile, `map go` to one of these rooms:")
		display(fuzzyMatches)
		return
	end

	log(f"Map: Room not found: {parameter}")
end

local function goImpl(dest)
	if not dest then return end
	if getPlayerRoom() == tonumber(dest) then
		log("Map: already there!")
		return true
	else
		local ok, err = gotoRoom(dest)
		if not ok then
			log(f"Map: {err}")
			return ok
		else
			return true
		end
	end
end

-- As a weird side effect, these aliases also change what double-click on the graphical map does.
cofudlet.map.go = function(to)
	map.goCmd = "go"
	return goImpl(targetToCid(to))
end

cofudlet.map.run = function(to)
	map.goCmd = "run"
	return goImpl(targetToCid(to))
end

cofudlet.map.path = function(to)
	local toCid = targetToCid(to)
	if getPath(getPlayerRoom(), toCid) then
		log(cofudlet.map.assemble(speedWalkDir, 'go'))
		return true
	else
		log(f"No path found from {getPlayerRoom()} to {to}")
	end
end

cofudlet.map.cover = function(noSwimNoFly, excludedRooms)
	local here = getPlayerRoom()
	local area1 = getRoomArea(getPlayerRoom())
	local roomsList = {}
	local roomsSet = {}

	local function visitExit(room, exDir, tgt)
		return (excludedRooms or {})[tgt]
	end

	local function visitRoom(room)
		if not roomsSet[room] then
			local terrain = getRoomUserData(room, "terrain")
			if noSwimNoFly and (terrain == "underwater" or terrain == "watersurface" or terrain == "in_underwater" or terrain == "cavelakesurface"
				or terrain == "air" or terrain == "gap") then
				return
			end
			roomsSet[room] = true
			table.insert(roomsList, room)
		end
	end

	map.dfs(here, visitRoom, visitExit, false, true)
	return roomsList
end

cofudlet.map.getRoomId = function()
	return getRoomUserData(getPlayerRoom(), "id")
end
