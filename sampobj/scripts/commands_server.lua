--[[
    List of commands (clientside):

    - /gotomap: teleports you to a certain map's defined TP position
    - /unloadmap: unloads a map by ID for every online player
    - /loadmap: loads a map by ID for every online player

]]

function gotoMapCommand(thePlayer, cmd, map_id)
    if not tonumber(map_id) then
        outputChatBox("SYNTAX: /"..cmd.." [Map ID from /listmaps]", thePlayer,255,194,14)
    end
    map_id = tonumber(map_id)

    for k, map in pairs(mapList) do
        if map.id == map_id then

            setElementPosition(thePlayer, unpack(map.pos))
            setElementDimension(thePlayer, map.dim)
            setElementInterior(thePlayer, map.int)
            
            return outputChatBox("Teleported to map ID "..map_id.." named '"..map.name.."'", thePlayer,0,255,0)
        end
    end
    
    outputChatBox("Map ID "..map_id.." not found, check /listmaps", 255,0,0)
end
addCommandHandler("gotomap", gotoMapCommand, false)


function unloadMapCmd(thePlayer, cmd, map_id)
	if not tonumber(map_id) then
		return outputChatBox("SYNTAX: /"..cmd.." [Map ID from /listmaps]", thePlayer, 255,194,14)
	end
	map_id = tonumber(map_id)

    for k, map in pairs(mapList) do
        if map.id == map_id then

			unloadMapForPlayers(map_id)
            return
        end
    end

    outputChatBox("Map ID "..map_id.." not found, check /listmaps", thePlayer, 255,0,0)
end
addCommandHandler("unloadmap", unloadMapCmd, false, false)

function loadMapCmd(thePlayer, cmd, map_id)
	if not tonumber(map_id) then
		return outputChatBox("SYNTAX: /"..cmd.." [Map ID from /listmaps]", thePlayer, 255,194,14)
	end
	map_id = tonumber(map_id)

    for k, map in pairs(mapList) do
        if map.id == map_id then

            loadMapForPlayers(map_id)
            return
        end
    end

    outputChatBox("Map ID "..map_id.." not found, check /listmaps", thePlayer, 255,0,0)
end
addCommandHandler("loadmap", loadMapCmd, false, false)