
SAMPObjects = {}
MTAIDMapSAMPModel = {}
local total = 0

function loadSAMPObjects()
    local img = engineLoadIMGContainer("samp/samp.img") -- returns object
    local cols = engineGetCOLsFromLibrary("samp/samp.col") -- returns array


    if fileExists("samp/samp.ide") then 
        local f = fileOpen("samp/samp.ide")
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

                    local newid = mallocSAMPObject(loadTxd, loadDff, loadCol, samp_modelid, nil, dff,txd)
                    if not tonumber(newid) then
                        outputDebugString(string.format("[SAMP_OBJ] id failed to allocate for samp model %d", samp_modelid), 1)
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

    local id
    if tonumber(baseid) then
        id = engineRequestModel("object", tonumber(baseid))
    else
        id = engineRequestModel("object")
    end
    if not id then
        return false
    end

    -- load file
    local file_txd = engineLoadTXD(loadTxd)
    local file_dff = engineLoadDFF(loadDff)
    local file_col = engineLoadCOL(loadCol)

    engineImportTXD(file_txd, id)
    engineReplaceModel(file_dff, id)
    engineReplaceCOL(file_col,id)
    
    SAMPObjects[samp_modelid] = {
        malloc_id=id, samp_id=samp_modelid,
        dff=string.lower(dffName),txd=string.lower(txdName)
    }

    -- for the sake of saving speed of finding the id
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

addEventHandler( "onClientResourceStart", resourceRoot, 
function (startedResource)

    if loadSAMPObjects() then
        loadSAMPMaps()
        -- togDrawObjects()--testing
    end
end)
