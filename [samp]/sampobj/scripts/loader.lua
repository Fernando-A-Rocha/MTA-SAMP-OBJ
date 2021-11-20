
SAMPObjects = {}
MTAIDMapSAMPModel = {}
req_object_ids = {} -- new object ids requested to load

local img,cols,ide

-- checking the variables (test print x)
addCommandHandler("tp1", function() iprint(SAMPObjects) end, false)
addCommandHandler("tp2", function() iprint(MTAIDMapSAMPModel) end, false)
addCommandHandler("tp3", function() iprint(req_object_ids) end, false)

function isSAMPIDQueued(model) -- [Exported]
    model = tonumber(model)
    for mapid,v in pairs(req_object_ids) do
        if v[model] then return true end
    end
    return false
end

function queueSAMPID(model, mapid) -- [Exported]
    if not req_object_ids[mapid] then req_object_ids[mapid] = {} end
    req_object_ids[mapid][model] = true
    return true
end

function queueSAMPIDs(ids, mapid) -- [Exported]
    req_object_ids[mapid] = ids
    return true
end

function loadSAMPObjects()

    Lines = split(ide,'\n' )
    Async:iterate(1, #Lines, function(i)
    -- for i=1, #Lines do
        local s = split(Lines[i],",")
        if #s == 5 and not string.find(s[1], "#") then -- read ide line
            local samp_modelid = tonumber(s[1])
            if not samp_modelid then
                return outputDebugMsg("ide read fail: '"..s[1].."'", 1)
            end

            if isSAMPIDQueued(samp_modelid) and not SAMPObjects[samp_modelid] then-- if not already allocated, then allocate:
                
                local dff = string.gsub(s[2], '%s+', '')
                local txd = string.gsub(s[3], '%s+', '')
                
                local loadCol = cols[string.lower(dff)]
                local loadDff = img:getFile(string.lower(dff..".dff"))
                local loadTxd = img:getFile(string.lower(txd..".txd"))

                -- replace
                if loadCol and loadDff and loadTxd then

                    local newid,reason = mallocNewObject(loadTxd, loadDff, loadCol, samp_modelid, nil, dff)
                    if not tonumber(newid) then
                        outputDebugMsg(string.format("id failed to allocate for samp model %d, reason: %s", samp_modelid,reason), 1)
                    end
                else
                    outputDebugMsg(string.format("dff %s failed to load",string.lower(dff)), 1)
                end
            end
        end
    -- end
    end)
    return true
end


function mallocNewObject(loadTxd, loadDff, loadCol, samp_modelid, baseid, dffName) --txdName
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

        -- used for looking up in SA_MATLIB
        dff=string.lower(tostring(dffName)), --txd=string.lower(txdName),
        elements = {
            file_txd, file_dff, file_col -- destroy to free memory
        }
    }

    -- to save speed finding ids
    MTAIDMapSAMPModel[id] = SAMPObjects[samp_modelid]

    return id
end

function freeNewObject(allocated_id)
    allocated_id = tonumber(allocated_id)
    if not allocated_id then
        return false, "id passed not number"
    end

    if not MTAIDMapSAMPModel[allocated_id] then
        return false, "id '"..allocated_id.."' not allocated"
    end

    engineRestoreModel(allocated_id)
    engineFreeModel(allocated_id)

    for k,v in pairs(SAMPObjects) do
        if v.malloc_id == allocated_id then

            for j,w in pairs(v.elements) do
                if isElement(w) then
                    destroyElement(w)
                end
            end

            SAMPObjects[k] = nil
            break
        end
    end

    MTAIDMapSAMPModel[allocated_id] = nil
    return true
end


-- Automatic memory freeing
addEventHandler( "onClientElementDestroy", root, 
function ()
    if getElementType(source)~="object" then return end
    local model = getElementModel(source)
    local samp_info = MTAIDMapSAMPModel[model]
    if samp_info then
        local sampid = samp_info.samp_id

        -- check if there are other objects using the same new object model
        for k, obj in ipairs(getElementsByType("object")) do
            local model2 = getElementModel(obj)
            if obj ~= source and model2 == model then
                local x,y,z = getElementPosition(obj)
                -- another exists so not freeing
                return
            end
        end
        
        freeNewObject(model) -- free memory
        -- outputDebugMsg(string.format("freed allocated model: %d (new model %d)",model,sampid), 3)
    end
end)

addEventHandler( "onClientResourceStart", resourceRoot, 
function (startedResource)


    img = getSAMPIMG("files/samp.img") -- returns object
    if not img then
        return outputFatalError("FATAL ERROR: Failed to load samp.img", 1)
    end

    cols = getSAMPCOL("files/samp.col") -- returns array
    if not cols then
        return outputFatalError("FATAL ERROR: Failed to load samp.col", 1)
    end

    ide = getSAMPIDE("files/samp.ide") -- returns file content string
    if not ide then
        return outputFatalError("FATAL ERROR: Failed to load samp.ide", 1)
    end

    -- Async loading
    if ASYNC_DEBUG then
        Async:setDebug(true);
    end

    -- Async:setPriority("low");    -- better fps
    -- Async:setPriority("normal"); -- medium
    Async:setPriority("high");   -- better perfomance

    -- or, more advanced
    -- Async:setPriority(500, 100);
    -- 500ms is "sleeping" time, 
    -- 100ms is "working" time, for every current async thread


    if TDO_AUTO then
        togDrawObjects() -- enable on startup for testing
    end
end)



addEventHandler( "onClientResourceStop", resourceRoot, 
function (stoppedResource)
    for id,_ in pairs(MTAIDMapSAMPModel) do
        if not engineFreeModel(id) then
            outputDebugMsg("Failed to free allocated ID "..id, 1)
        end
    end
    collectgarbage("collect")
end)


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