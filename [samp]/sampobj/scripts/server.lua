-- Fernando
local SERVER_READY = false

local used_SAMP_objects = {}
local parsed_maps = {}

function mapCheckError(text)
	outputDebugString("mapList incorrect: "..text, 0, 255,120,0)
end

function mapChecks() -- check if the dev configured all variables correctly
	
	local used_ids = {}
	for _, map in pairs(mapList) do

		-- 1.  verify IDs
		if not tonumber(map.id) then
			return false, mapCheckError("Invalid map ID '"..tostring(map.id).."'")
		else
			for k,id in pairs(used_ids) do
				if id == map.id then
					return false, mapCheckError("Duplicated map ID '"..id.."'")
				end
			end

			table.insert(used_ids, map.id)
		end

		-- 2.  verify name
		if not map.name or type(map.name)~="string" then

			return false, mapCheckError("Missing/Invalid map name '"..tostring(map.name).."' for map ID "..map.id)
		end

		-- 3.  verify path
		if not map.path or type(map.path)~="string" then

			return false, mapCheckError("Missing/Invalid map path '"..tostring(map.path).."' for map ID "..map.id)
		end

		-- 4.  verify file exists
		if not fileExists(map.path) then

			return false, mapCheckError("File does not exist: '"..tostring(map.path).."' for map ID "..map.id)
		end

		-- 5.  verify interior
		if not tonumber(map.int) then

			return false, mapCheckError("Missing/Invalid interior world (int): '"..tostring(map.int).."' for map ID "..map.id)
		end

		-- 6.  verify dimension
		if not tonumber(map.dim) then

			return false, mapCheckError("Missing/Invalid dimension world (dim): '"..tostring(map.dim).."' for map ID "..map.id)
		end

		-- 7.  verify teleport pos
		if not map.pos or type(map.pos)~="table" or not (map.pos[1] and map.pos[2] and map.pos[3]) then

			return false, mapCheckError("Missing/Invalid teleport position X,Y,Z (pos): '"..tostring(map.pos).."' for map ID "..map.id)
		end

		-- 8.  verify autoload
		if (map.autoload)==nil or type(map.autoload)~="boolean" then
			
			return false, mapCheckError("Missing/Invalid autoload value (must be true or false) for map ID "..map.id)
		end

	end

	return true
end

function parseTextureStudioMaps()

	for _, map in pairs(mapList) do

		local parsed, reason, objects_used = getTextureStudioMap(map.path)
		if not (type(parsed)=="table") then
			outputDebugString("Failed to parse map ID "..map.id.." ('"..map.path.."'), reason: "..reason, 1)
		else

			-- objects IDs used by this map
			used_SAMP_objects[map.id] = objects_used

			-- parsed map content
			parsed_maps[map.id] = parsed
		end
	end
	
	return true
end


addEventHandler( "onResourceStart", resourceRoot, 
function (startedResource)

	if not mapChecks() then return end

	if parseTextureStudioMaps() then
		SERVER_READY = true
	end
end)

function unloadMapForPlayers(map_id)
    for k, player in ipairs(getElementsByType("player")) do
		triggerClientEvent(player, "sampobj:unloadMap", resourceRoot, map_id)
	end
end

function loadMapForPlayers(map_id)
	for _, map in pairs(mapList) do
		if map.id == map_id then
			for k, player in ipairs(getElementsByType("player")) do
				triggerClientEvent(player, "sampobj:loadMap", resourceRoot, used_SAMP_objects[map_id], map_id, parsed_maps[map_id], map.int,map.dim)
			end
			return
		end
	end
end

function sendResultWhenReady(player)
	if SERVER_READY then

		-- only send maps which are auto-load on startup request

		local autoload_maps = {}
		local objects = {}

		for mapid,content in pairs(parsed_maps) do
			local autoload
            for k, map in pairs(mapList) do
                if map.id == mapid then
                    autoload = map.autoload
                    break
                end
            end

            if autoload == true then
            	objects[mapid] = used_SAMP_objects[mapid]
            	autoload_maps[mapid] = content
            end
		end

		triggerLatentClientEvent(player, "sampobj:load", resourceRoot, objects, autoload_maps)
	else
		setTimer(sendResultWhenReady, 1000, 1, player)
	end
end

addEvent("sampobj:request", true)
function clientStartupRequest()

	if (table.size(parsed_maps)) == 0 then
		outputDebugString(getPlayerName(client).." requested maps but none were loaded", 2)
		return
	end

	sendResultWhenReady(client)	
end
addEventHandler("sampobj:request", resourceRoot, clientStartupRequest)
