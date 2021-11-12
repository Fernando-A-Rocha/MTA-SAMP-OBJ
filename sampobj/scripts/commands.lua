--[[
    List of commands (clientside):

    - /tdo (test draw objects): displays object IDs and replaced textures with material indexes
    - /listmaps: lists all maps defined in maps/_maplist.lua

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
        local status = loaded_maps[map.id] and ("#89ff6b[LOADED] #d1d1d1("..(#(loaded_maps[map.id].objects).." objects)")) or "#ff9c9c[NOT LOADED]"
        outputChatBox(status.." #ffc67a(ID "..map.id..") #ffa126'"..map.name.."' #ffffffint: "..map.int.." dim: "..map.dim, 255,126,0, true)
    end
end
addCommandHandler("listmaps", listMaps, false)



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

