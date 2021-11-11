
SAMPObjects = {}
MTAIDMapSAMPModel = {}
local total = 0

function loadSAMPObjects()
    local img = engineLoadIMGContainer("files/samp.img") -- returns object
    local cols = engineGetCOLsFromLibrary("samp/samp.col") -- returns array


    if fileExists("files/samp.ide") then 
        local f = fileOpen("files/samp.ide")
        local str = fileRead(f,fileGetSize(f))
        fileClose(f)
        Lines = split(str,'\n' )
        for i = 1, #Lines do
            local s = split(Lines[i],",")
            if #s == 5 and not string.find(s[1], "#") then -- read ide lines
                local samp_modelid = tonumber(s[1])
                if not samp_modelid then
                    return outputDebugString("fail: '"..s[1].."'", 1)
                end
                local dff = string.gsub(s[2], '%s+', '')
                local txd = string.gsub(s[3], '%s+', '')

                --load files
                local loadCol = cols[string.lower(dff)]
                local loadDff = img:getFile(string.lower(dff..".dff"))
                local loadTxd = img:getFile(string.lower(txd..".txd"))

                -- replace
                if loadCol and loadDff and loadTxd then

                    local newid,reason = mallocSAMPObject(loadTxd, loadDff, loadCol, samp_modelid, nil, dff,txd)
                    if not tonumber(newid) then
                        outputDebugString(string.format("[SAMP_OBJ] id failed to allocate for samp model %d, reason: %s", samp_modelid,reason), 1)
                    end
                else
                    outputDebugString(string.format("[SAMP_OBJ] dff %s failed to load",string.lower(dff)), 1)
                end
            end
        end
    end
    
    -- print("[SAMP_OBJ] Total loaded: ",total)
    return true
end


function mallocSAMPObject(loadTxd, loadDff, loadCol, samp_modelid, baseid, dffName, txdName)
    -- malloc & replace object

    baseid = tonumber(baseid)
    local id

    if baseid then
        id = engineRequestModel("object", baseid)
    else
        id = engineRequestModel("object")
    end
    if not tonumber(id) then
        return false, "Fail: engineRequestModel"..(baseid and ("("..baseid..")") or ("()"))
    end

    -- load file
    local file_txd = engineLoadTXD(loadTxd)
    if not file_txd then
        return false, "Fail: engineLoadTXD("..tostring(loadTxd)..")"
    end

    local file_dff = engineLoadDFF(loadDff)
    if not file_dff then
        return false, "Fail: engineLoadDFF("..tostring(loadDff)..")"
    end

    local file_col = engineLoadCOL(loadCol)
    if not file_col then
        return false, "Fail: engineLoadCOL("..tostring(loadCol)..")"
    end

    
    if not engineImportTXD(file_txd, id) then
        return false, "Fail: engineImportTXD("..tostring(file_txd)..", "..id..")"
    end

    if not engineReplaceModel(file_dff, id) then
        return false, "Fail: engineReplaceModel("..tostring(file_dff)..", "..id..")"
    end
    
    if not engineReplaceCOL(file_col,id) then
        return false, "Fail: engineReplaceCOL("..tostring(file_col)..", "..id..")"
    end
    
    SAMPObjects[samp_modelid] = {
        malloc_id=id, samp_id=samp_modelid,
        dff=string.lower(dffName),txd=string.lower(txdName)
    }

    -- to save speed finding ids
    MTAIDMapSAMPModel[id] = SAMPObjects[samp_modelid]

    total = total + 1
    return id
end


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
        if loadTextureStudioMap(map.path, map.int, map.dim) then
            -- outputDebugString("Loaded '"..map.name.."' (ID #"..map.id..")", 0,20,255,20)
        else
            outputDebugString("Failed to load '"..map.name.."' ('"..map.path.."') (ID #"..map.id..")", 1)
        end
    end
    return true
end


addEventHandler( "onClientResourceStart", resourceRoot, 
function (startedResource)

    if loadSAMPObjects() then
        if loadSAMPMaps() then
            collectgarbage("collect")
        end

        -- togDrawObjects()--testing
    end
end)

addEventHandler( "onClientResourceStop", resourceRoot, 
function (stoppedResource)
    for id,_ in pairs(MTAIDMapSAMPModel) do
        if not engineFreeModel(id) then
            outputDebugString("Failed to free allocated ID "..id, 1)
        end
    end
    collectgarbage("collect")
end)