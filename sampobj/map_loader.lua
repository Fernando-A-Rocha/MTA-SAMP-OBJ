--[[
    Original creator: gta191977649
    Edited by: Fernando
]]

local mapList = {
    -- {id=1, name="maps/test.pwn", int=1, dim=2, pos={1395.462891,-17.192383,1000.917358}},
    {id=2, name="maps/office.pwn", int=1, dim=2, pos={1409.0078125, 39.7099609375, 39.607231140137}},
}


function listMaps(cmd)
    for k, map in pairs(mapList) do
        outputChatBox("(#"..map.id..") '"..map.name.."' int: "..map.int.." dim: "..map.dim, 255,126,0)
    end
end
addCommandHandler("listmaps", listMaps, false)

function gotoMapCommand(cmd, map_id)
    if not tonumber(map_id) then
        outputChatBox("SYNTAX: /"..cmd.." [map_id]", 255,194,14)
        return listMaps(cmd)
    end
    map_id = tonumber(map_id)

    for k, map in pairs(mapList) do
        if map.id == map_id then

            setElementPosition(getLocalPlayer(), unpack(map.pos))
            setElementDimension(getLocalPlayer(), map.dim)
            setElementInterior(getLocalPlayer(), map.int)
            
            return outputChatBox("Teleported to map #"..map_id.." named '"..map.name.."'", 0,255,0)
        end
    end
    
    outputChatBox("Map #"..map_id.." not found", 255,0,0)
    return listMaps(cmd)
end
addCommandHandler("gotomap", gotoMapCommand, false)

-- called once samp objects are loaded
function loadSAMPMaps()
    for k, map in pairs(mapList) do
        if loadTextureStudioMap(map.name, map.int, map.dim) then
            -- outputDebugString("Loaded '"..map.name.."' (ID #"..map.id..")", 0,20,255,20)
        else
            outputDebugString("Failed to load '"..map.name.."' (ID #"..map.id..")", 1)
        end
    end
end
