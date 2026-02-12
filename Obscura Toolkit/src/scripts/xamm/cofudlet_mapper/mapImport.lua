function import()
	local fjson = io.open("map.json", "rb")
	local json = fjson:read("*all")
	pymap = yajl.to_value(json)

	for k, _ in pairs(pymap) do
		log(f"pymap has a key {k}")
	end

	deleteMap()

	-- create areas
	-- set area start rooms (needs 2 passes)
	-- create rooms
	-- assign areas
	-- set exits

	for name, startNum in pairs(pymap.areas) do
		local areaId = addAreaName(name)
		setAreaUserData(areaId, "startRoomCid", startNum)
	end

	local areaToId = getAreaTable()


	local ok = 0
	local err = 0
	for num, room in pairs(pymap.rooms) do
		if room.data ~= nil and type(room.data) ~= "userdata" and room.name ~= nil and type(room.name) ~= "userdata" then
			-- room might be created as a target for an exit
			local id = getRoomIDbyHash(num)
			if not id or id == -1 then
				id = createRoomID(ok + 1)
				addRoom(id)
				setRoomIDbyHash(id, num)
			end

			-- log(f"Adding num={num} mapid={id} mudid={room.data.id} name={room.name}")
			setRoomName(id, room.name)
			if room.data.id then setRoomUserData(id, "id", room.data.id) end
			if room.data.terrain then
				setRoomUserData(id, "terrain", room.data.terrain)

				local color = cofudlet.map.terrainColors[room.data.terrain]
				if color ~= nil then -- Might want to consider adding new ones dynamically
					setRoomEnv(id, color)
				else
					log(f"Previously unseen terrain, need to add color: {gmcp.room.info.terrain}")
				end
			end
			if room.coords then setRoomCoordinates(id, room.coords.x, -room.coords.y, room.coords.z) end

			for dir, exit in pairs(room.exits or {}) do
				local exId = getRoomIDbyHash(exit.tgt)
				if not exId or exId == -1 then
					exId = createRoomID(id)
					addRoom(exId)
					setRoomIDbyHash(exId, exit.tgt)
				end

				if dir:len() == 1 and dir ~= "v" then
					setExit(id, exId, dir)
				else
					addSpecialExit(id, exId, dir)
				end

				local function setExitFlag(id, flag)
					local uds = getRoomUserData(id, "exits")
					if uds == "" then uds = "{}" end
					local ud = yajl.to_value(uds)
					ud[dir] = ud[dir] or {}
					ud[dir][flag] = true
					setRoomUserData(id, "exits", yajl.to_string(ud))
				end

				if exit.data and exit.data.swim then
					setExitFlag(id, 'swim')
				end
				if exit.data and exit.data.fly then
					setExitFlag(id, 'fly')
				end

				if exit.data and exit.data.lock then
					if dir:len() == 1 then
						lockExit(id, dir, true)
					end
				end

				if exit.data and exit.data.hardLock then
					if dir:len() == 1 then
						lockExit(id, dir, true)
					end
				end
			end

			if room["data"].zone ~= nil then -- unmapped in Py
				local area = areaToId[room["data"].zone]
				if area == nil then
					log(f"Error: Area not found: {area}")
				else
					setRoomArea(id, area)
				end
			end
			ok = ok + 1
		else
			-- log(f"Error while importing {num}")
			-- display(room)
			err = err + 1
		end
	end

	for name, startNum in pairs(pymap.areas) do
		local areaId = getRoomAreaName(name)
		local startRoom = getRoomIDbyHash(startNum)
		if startRoom == -1 then
			log(f"Couldn't find area to map start room for {name}")
		end

		setAreaUserData(areaId, "startRoomCid", startRoom)
	end

	log(f"Map import done with ok={ok} err={err}")
end
