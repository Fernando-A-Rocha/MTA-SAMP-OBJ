
SAMPObjects = {}
MTAIDMapSAMPModel = {}
local objects_load_list = {} -- samp objects to load (instructed by the server)

loaded_maps = {}
Buffer = {
    last_object = nil,
    total = 0,
    curr_filepath = "",
    curr_line = 0,
}

local img, cols, ide

function loadSAMPObjects()
    if not img then
        img = engineLoadIMGContainer("files/samp.img") -- returns object
    end
    if not cols then
        cols = engineGetCOLsFromLibrary("samp/samp.col") -- returns array
    end
    if not ide then
        local f = fileOpen("files/samp.ide")
        ide = fileRead(f,fileGetSize(f))
        fileClose(f)
    end

    Lines = split(ide,'\n' )
    for i = 1, #Lines do
        local s = split(Lines[i],",")
        if #s == 5 and not string.find(s[1], "#") then -- read ide lines
            local samp_modelid = tonumber(s[1])
            if not samp_modelid then
                return outputDebugString("ide read fail: '"..s[1].."'", 1)
            end

            local found
            for k,id in pairs(objects_load_list) do
                if id == samp_modelid then
                    found = true
                    break
                end
            end

            if not found then
                -- outputChatBox("Skipping "..samp_modelid)
            else

                if SAMPObjects[samp_modelid] then
                    -- print("SAMP Obj "..samp_modelid.." already loaded")
                else

                    local dff = string.gsub(s[2], '%s+', '')
                    local txd = string.gsub(s[3], '%s+', '')

                    --load files
                    local loadCol = cols[string.lower(dff)]
                    local loadDff = img:getFile(string.lower(dff..".dff"))
                    local loadTxd = img:getFile(string.lower(txd..".txd"))

                    -- replace
                    if loadCol and loadDff and loadTxd then

                        local newid,reason = mallocNewObject(loadTxd, loadDff, loadCol, samp_modelid, nil, dff,txd)
                        if not tonumber(newid) then
                            outputDebugString(string.format("[SAMP_OBJ] id failed to allocate for samp model %d, reason: %s", samp_modelid,reason), 1)
                        end
                    else
                        outputDebugString(string.format("[SAMP_OBJ] dff %s failed to load",string.lower(dff)), 1)
                    end
                end
            end
        end
    end
    return true
end


function mallocNewObject(loadTxd, loadDff, loadCol, samp_modelid, baseid, dffName, txdName)
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

    if not engineFreeModel(allocated_id) then
        return false, "failed to free model id '"..allocated_id.."'"
    end

    for k,v in pairs(SAMPObjects) do
        if v.malloc_id == allocated_id then
            SAMPObjects[k] = nil
            break
        end
    end

    MTAIDMapSAMPModel[allocated_id] = nil

    return true
end

function countAllocatedModels()
    local c = 0
    for id,_ in pairs(MTAIDMapSAMPModel) do
        c = c + 1
    end
    return c
end

function loadTextureStudioMap(mapid,parsed,int,dim)

    if loaded_maps[mapid] then
        return false, "Already loaded"
    end

    loaded_maps[mapid] = { -- store elements so the map can be unloaded
        models = {},
        objects = {},
        removals = {},
    }

    int = int or 0
    dim = dim or 0

    Buffer.curr_filepath = filename
    for _, v in pairs(parsed) do
        Buffer.curr_line = v.line

        if v.f == "model" then
            local allocated_id = AddSimpleModel(unpack(v.variables))
            if allocated_id then
                table.insert(loaded_maps[mapid].models, allocated_id)
            end
        elseif v.f == "object" then
            local obj,lod = CreateNewObject(unpack(v.variables))
            Buffer.last_object = obj

            if isElement(obj) then

                Buffer.total = Buffer.total + 1

                setElementInterior(obj,int)
                setElementDimension(obj,dim)

                if isElement(lod) then
                    setElementInterior(lod,int)
                    setElementDimension(lod,dim)
                    
                    table.insert(loaded_maps[mapid].objects, {Buffer.last_object, lod})
                else
                    table.insert(loaded_maps[mapid].objects, {Buffer.last_object})
                end


            end
        elseif v.f == "material" then
            if isElement(Buffer.last_object) then
                local mat_index,model_id,lib_name,tex_name,color = unpack(v.variables)
                SetObjectMaterial(Buffer.last_object, mat_index,model_id,lib_name,tex_name,color)
            end
        elseif v.f == "remove" then
            local model,radius,x,y,z = unpack(v.variables)
            if removeWorldModel(model,radius,x,y,z,int) then
                table.insert(loaded_maps[mapid].removals, {
                    model,radius,x,y,z,int
                })
            end
        end
    end

    Buffer.total = 0
    Buffer.last_object = nil
    Buffer.curr_filepath = ""
    Buffer.curr_line = 0

    print("Map "..mapid.." loaded")
    return true
end

function unloadTextureStudioMap(mapid)
    if not loaded_maps[mapid] then
        outputDebugString("Can't unload: map "..mapid.." not loaded", 2)
        return
    end

    local destroyed_obj_ids = {}
    for k,v in pairs(loaded_maps[mapid].models) do
        local worked, reason = freeNewObject(v)
        if not worked then
            print(reason)
        end
    end
    for k,v in pairs(loaded_maps[mapid].objects) do
        for j,w in pairs(v) do
            if isElement(w) then
                local model = getSAMPOrDefaultModel(w)
                if isSampObject(model) then
                    local allocated_id = getElementModel(w)
                    destroyed_obj_ids[allocated_id] = true
                end
                destroyElement(w)
            end
        end
    end
    for k,v in pairs(loaded_maps[mapid].removals) do
        local model,radius,x,y,z,int = unpack(v)
        restoreWorldModel(model,radius,x,y,z,int)
    end


    -- free SAMP objects that are allocated and not used for any other map

    local remaining_ids = {}
    for k,v in pairs(loaded_maps) do
        if v == "objects" then
            local model = getSAMPOrDefaultModel(v[1])
            if isSampObject(model) then
                local allocated_id = getElementModel(v[1])
                remaining_ids[allocated_id] = true
            end
        end
    end

    for id,_ in pairs(destroyed_obj_ids) do
        if not remaining_ids[id] then
            local worked, reason = freeNewObject(id)
            if not worked then
                print(reason)
            end
        end
    end


    loaded_maps[mapid] = nil
    print("Map "..mapid.." unloaded")
end
addEvent("sampobj:unloadMap", true)
addEventHandler("sampobj:unloadMap", resourceRoot, unloadTextureStudioMap)

function doLoadSAMPObjects(objs)
    objects_load_list = objs
    if loadSAMPObjects() then
        return true
    end
end

function doLoadTextureStudioMap(objs,mapid,parsed,int,dim)

    if doLoadSAMPObjects(objs) then

        local loaded, reason = loadTextureStudioMap(mapid, parsed, int, dim)
        if not loaded then
            outputDebugString("Failed to load map ID "..mapid..", reason: "..reason)
        end
    end
end
addEvent("sampobj:loadMap", true)
addEventHandler("sampobj:loadMap", resourceRoot, doLoadTextureStudioMap)

function clientStartupLoad(objs, maps)

    if doLoadSAMPObjects(objs) then

        -- only load parsed maps
        for id, parsed in pairs(maps) do
            
            local int,dim
            for k, map in pairs(mapList) do
                if map.id == id then
                    int = map.int
                    dim = map.dim
                    break
                end
            end

            local loaded, reason = loadTextureStudioMap(id, parsed, int, dim)
            if not loaded then
                outputDebugString("(startup) Failed to load map ID "..id..", reason: "..reason)
            end
        end
    end
end
addEvent("sampobj:load", true)
addEventHandler("sampobj:load", resourceRoot, clientStartupLoad)


addEventHandler( "onClientResourceStart", resourceRoot, 
function (startedResource)

    triggerLatentServerEvent("sampobj:request", resourceRoot)
    -- togDrawObjects() -- enable on startup for testing
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