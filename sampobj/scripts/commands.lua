--[[
    List of commands (clientside):

    - /tdo (test draw objects): displays object IDs and replaced textures with material indexes
    - /listmaps: lists all maps defined in maps/_maplist.lua
    - /gotomap: teleports you to a certain map's defined TP position

]]


local drawing = false
function togDrawObjects(cmd)
    drawing = not drawing
    outputChatBox("Displaying object IDs: "..(drawing and "Yes" or "No"), 50,255,50)

    if drawing then
        addEventHandler( "onClientRender", root, drawObjects)
    else
        removeEventHandler( "onClientRender", root, drawObjects)
    end
end
addCommandHandler("tdo", togDrawObjects, false)

function listMaps(cmd)
    outputChatBox("Total new objects loaded: "..countAllocatedModels(), 255,194,0)
    for k, map in pairs(mapList) do
        local status = loaded_maps[map.id] and "[LOADED]" or "[NOT LOADED]"
        outputChatBox(status.." (#"..map.id..") '"..map.name.."' int: "..map.int.." dim: "..map.dim, 255,126,0)
    end
end
addCommandHandler("listmaps", listMaps, false)

function gotoMapCommand(cmd, map_id)
    if not tonumber(map_id) then
        outputChatBox("SYNTAX: /"..cmd.." [Map ID from mapList]", 255,194,14)
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



function drawObjects()

    local px,py,pz = getElementPosition(localPlayer)
    local int,dim = getElementInterior(localPlayer), getElementDimension(localPlayer)
    local lx, ly, lz = getCameraMatrix()

    for k, obj in ipairs(getElementsWithinRange(px,py,pz, 35, "object")) do

        local i,d = getElementInterior(obj), getElementDimension(obj)
        if d == dim and i == int then
            local x,y,z = getElementPosition(obj)

            local collision, cx, cy, cz, element = processLineOfSight(lx, ly, lz, x,y,z,
            false, false, false, false, false, false, false, true, obj)

            if not collision then

                local dx, dy, distance = getScreenFromWorldPosition(x,y,z)
                if dx and dy then


                    local model = getElementModel(obj)

                    local fsize = 1
                    local fcolor = "0xffffffff"

                    local samp_info = MTAIDMapSAMPModel[model]
                    if samp_info then
                        model = samp_info.samp_id.." ("..samp_info.dff..")"
                        fcolor = "0xff00ff00"
                    else
                        model = model.." ("..string.lower(engineGetModelNameFromID(model))..")"
                    end

                    local text2
                    local mat_info = getElementData(obj, "material_info") or false
                    if mat_info then
                        local temp = ""
                        for k, mat in pairs(mat_info) do
                            temp=temp.."["..mat.mat_index.."] "..mat.target_tex_name.." => "..mat.tex_name.."\n"
                        end
                        text2 = temp
                    end

                    local text = tostring(model)
                    if text2 then
                        text = text.."\n"..text2
                    end

                    dxDrawText(text, dx, dy, dx, dy, fcolor, fsize, "default", "center")
                end
            end
        end
    end
end

