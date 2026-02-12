if #matches < 2 then
	log(f"Map: usage: `map subcommand`. Run `map help` for a list.")
	return
end

local args = matches[3] ~= nil and string.split(matches[3], ' ') or {}
local arg1 = args[1]
local parameter = nil
if string.find(matches[3], "^[^ ]+ +") then
	parameter = string.gsub(matches[3], "^[^ ]+ +", "")
end

cofudlet = cofudlet or {}
cofudlet.map = cofudlet.map or {}
local map = cofudlet.map

-- Stuff we could implement with reasonably small effort:
-- finding multiple some unmapped rooms and displaying a selectable list
-- Exposing existing APIs - potentially useful if a person is scared of calling Lua APIs directly, like:
-- getAreaTable()
-- swim/fly/crawl/climb-only exits. This one would be a bit tricky to implement.
	-- Perhaps the player could set a config flag "noswim", at which moment,
	-- we'd iterate over all rooms, locking the exits. Downside: when undoing the
	-- change, we'd nuke all regular exit locks, so we need to duplicate this.
	-- Alternative: just implement our own pathfinding. Here's how to teach
	-- Mudlet to use it on double-click:
	-- https://wiki.mudlet.org/w/Manual:Mapper#Custom_speedwalking_and_pathfinding

local function unmapped(unvisited, inArea, one, bypassLocks)
	if unvisited and map.visited == nil then
		map.visited = {}
	end
	local here = getPlayerRoom()
	local unmappedRoom = nil
	local paths = {[here] = {}}

	local function visitExit(room, exDir, tgt)
		local path = paths[room]
		paths[tgt] = table.deepcopy(path)
		table.insert(paths[tgt], exDir)

		if getRoomUserData(tgt, "id") == "" then -- unmapped?
			unmappedRoom = tgt
			return true
		elseif unvisited and map.visited[tgt] == nil then
			unmappedRoom = tgt
			return true
		else
			return unmappedRoom
		end
	end

	local function visitRoom(room)
		return unmappedRoom -- Hack: stop search if we found any unmapped room
	end

	map.bfs(here, visitRoom, visitExit, bypassLocks, inArea)
	return unmappedRoom, paths[unmappedRoom]
end

local function coordsToString(hash)
	local x, y, z = getRoomCoordinates(hash)
	return (f"({x}, {y}, {z})")
end

cofudlet.map.findAndGoUnmapped = function(inArea)
	local room, path = unmapped(false, inArea, true, false)
	if room then
		log(f"Found unmapped room {room}: {table.concat(path, ' ')}")
		-- gotoRoom(room)
		local goCmd = map.goCmd or "go"
		send(f"{goCmd} {table.concat(path, ' ')}")
	else
		log(f"No unmapped rooms found.")
	end
end

local function doorImpl(locked)
	dir = parameter
	if not (dir and string.match("^(n|e|s|w|u|d)$", dir)) then
		log("Usage: map door (n|e|s|w|u|d)")
		return
	end

	local direction = string.lower(dir or "")
	local eCid = getRoomExits(getPlayerRoom())[map.normalizedDirections[direction]]
	if not eCid then
		log(f"There is no exit {direction}wards from here.")
		return
	end

	local openCmd = "open " .. direction .. ";;" .. direction
	if locked then
		openCmd = "unlock " .. direction .. ";;" .. openCmd
	end

	addSpecialExit(getPlayerRoom(), eCid, openCmd)
	setExitWeight(getPlayerRoom(), dir, 2)
	log("Done!")
end

local function door()
	doorImpl(false)
end

local function ldoor()
	doorImpl(true)
end

local function attach()
	if not parameter then
		for dir, eCid in pairs(getRoomExits(getPlayerRoom())) do
			if eCid ~= getPlayerRoom() then
				local direction = map.normalizedDirections[dir]
				map.setCoords(getPlayerRoom(), eCid, direction)
			end
		end
		centerview(getPlayerRoom())
		return
	else
		local direction = string.lower(parameter or "")
		local eCid = getRoomExits(getPlayerRoom())[map.normalizedDirections[direction]]
		if not eCid then
			log(f"There is no exit {direction}wards from here.")
			return
		end

		map.setCoords(getPlayerRoom(), eCid, direction)
	end
	centerview(getPlayerRoom())
end

local function find(parameter)
	local roomsInArea = getAreaRooms(getRoomArea(getPlayerRoom()))
	if not parameter or #parameter == 0 then
		-- List rooms in area
		table.sort(roomsInArea,
			function(a, b) return getRoomName(a) < getRoomName(b) end
		)
		log("Listing all rooms in area:")
		for _, cid in pairs(roomsInArea) do
			log(f"{cid} {getRoomName(cid)}")
		end
	else
		-- Filter rooms in area
		local found = false
		for _, cid in pairs(roomsInArea) do
			local rn = getRoomName(cid)
			if string.find(string.upper(rn), string.upper(parameter)) then
				if not found then
					log("Filtered rooms in area:")
				end
				log(f"{cid} {rn}")
				found = true
			end
		end

		-- Filter rooms globally
		if not found then
			for cid, rn in pairs(getRooms()) do
				if string.find(string.upper(rn), string.upper(parameter)) then
					if not found then
						log("Filtered rooms globally:")
					end
					log(f"{cid} {rn}")
					found = true
				end
			end
		end

		if not found then
			log(f'Room "{parameter}" not found anywhere in the map')
		end
	end
end

local commands = {
	["add"] = function()
		local bookmarks = yajl.to_value(getMapUserData("bookmarks") or "{}")
		bookmarks[parameter] = getPlayerRoom()
		setMapUserData("bookmarks", yajl.to_string(bookmarks))
		log(f"Map: added bookmark {parameter} to Cid={getPlayerRoom()}")
	end,
	["rm"] = function()
		local bookmarks = yajl.to_value(getMapUserData("bookmarks") or "{}")
		if bookmarks[parameter] then
			log(f"Map: removing bookmark {parameter} to {bookmarks[parameter]}")
			bookmarks[parameter] = nil
			setMapUserData("bookmarks", yajl.to_string(bookmarks))
		else
			log(f"Map: bookmark {parameter} not found")
		end
	end,
	["ls"] = function()
		local bookmarks = yajl.to_value(getMapUserData("bookmarks") or "{}")
		if parameter then
			log(f"Map: bookmarks filtered by {parameter}:")
			local filtered = {}
			for name, dest in pairs(bookmarks) do
				if string.find(name:upper(), parameter:upper()) then
					filtered[name] = dest
				end
			end
			display(filtered)
		else
			log(f"Map: all bookmarks:")
			display(bookmarks)
		end
	end,
	["here"] = function()
		local id = getPlayerRoom()
		log(f[[Room info:
		Mudlet Id: {id}
		Mudside Id: {gmcp.room.info.id}
		Mudside Num: {gmcp.room.info.num}
		Name: {getRoomName(id)}
		Coords: {coordsToString(id)}
		Exits (mudside numbers): {yajl.to_string(gmcp.room.info.exits)}
		Exits (Mudlet room IDs): {yajl.to_string(getRoomExits(id))}
		Special exits: {yajl.to_string(getSpecialExitsSwap(id))}
		Area name: {getRoomArea(id)} {getRoomAreaName(getRoomArea(id))}
		Room data: {yajl.to_string(getAllRoomUserData(id))}
		]])
	end,
	["start"] = function()
		if map.mapping then
			log("Map: already mapping.")
		else
			map.mapping = true
			log("Map: started mapping. Move slowly - it's easier to fix manually any misaligned rooms if there's not a lot of them.")
		end
	end,
	["stop"] = function()
		if not map.mapping then
			log("Map: not mapping.")
		else
			map.mapping = nil
			log("Map: stopped mapping.")
		end
	end,
	["save"] = function()
		local fn = getMudletHomeDir() .. '/xamm-mapdata.dat'
		log(f"Map: saving map to {fn}: {saveMap(fn)}")
	end,
	["load"] = function()
		local fn = getMudletHomeDir() .. '/xamm-mapdata.dat'
		log(f"Map: loading map from {fn}: {loadMap(fn)}")
	end,
	["unmapped"] = function() cofudlet.map.findAndGoUnmapped(true) end,
	["unmapped!"] = function() cofudlet.map.findAndGoUnmapped(false) end,
	["attach"] = attach,
	["path"] = function() cofudlet.map.path(parameter) end,
	["go"] = function() cofudlet.map.go(parameter) end,
	["run"] = function() cofudlet.map.run(parameter) end,
	["find"] = function() find(parameter) end,
	["cover"] = function() display(cofudlet.map.cover()) end,
	["deleteinstances"] = function() log("Deleting all instanced areas, this might take time..."); for name, id in pairs(getAreaTable()) do if string.match(name, "of Mystery") then deleteArea(id) end end; log("Done!") end,
	["door"] = door,
	["ldoor"] = ldoor,
}

local function printHelp()
	log("Map: Try one of these commands:")
	for k, _ in pairs(commands) do
		log("map " .. k)
	end
	log(
		[[`map go` and `map run` accept the following arguments:
			- a bookmark
			- area name (case sensitive)
			- CoffeeMUD server-side room nums (the `Mudside num` you see with `map here`)
			- Mudlet client-side room IDs (the `Mudlet Id` you see with `map here`)
			- Friendly room ID like Midgaard#3001
			- Exact match on room name
			- Substring match on room name
		]])
end

if commands[arg1] ~= nil then
	commands[arg1](args)
else
	printHelp()
end
