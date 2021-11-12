
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

local img,cols,ide

-- checking the variables (test print x)
addCommandHandler("tp1", function() iprint(SAMPObjects) end, false)
addCommandHandler("tp2", function() iprint(MTAIDMapSAMPModel) end, false)
addCommandHandler("tp3", function() iprint(objects_load_list) end, false)
addCommandHandler("tp4", function() iprint(loaded_maps) end, false)
addCommandHandler("tp5", function() iprint(img) end, false)
addCommandHandler("tp6", function() iprint(cols) end, false)
addCommandHandler("tp7", function() iprint(ide) end, false)

function loadSAMPObjects()

    Lines = split(ide,'\n' )
    Async:iterate(1, #Lines, function(i)
    -- for i=1, #Lines in pairs(parsed) do
        local s = split(Lines[i],",")
        if #s == 5 and not string.find(s[1], "#") then -- read ide lines
            local samp_modelid = tonumber(s[1])
            if not samp_modelid then
                return outputDebugString("ide read fail: '"..s[1].."'", 1)
            end

            local found
            for mapid,v in pairs(objects_load_list) do
                for id,_ in pairs(v) do
                    if id == samp_modelid then
                        found = true
                        break
                    end
                end
            end

            if found then
                if SAMPObjects[samp_modelid] then
                    outputDebugString("SAMP Obj "..samp_modelid.." already loaded", 2)
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
                            outputDebugString(string.format("id failed to allocate for samp model %d, reason: %s", samp_modelid,reason), 1)
                        end
                    else
                        outputDebugString(string.format("dff %s failed to load",string.lower(dff)), 1)
                    end
                end
            end
        end
    -- end
    end)
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
        dff=string.lower(dffName),txd=string.lower(txdName),
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

    if not engineFreeModel(allocated_id) then
        return false, "failed to free model id '"..allocated_id.."'"
    end

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
        materials = {},
        removals = {},
    }

    int = int or 0
    dim = dim or 0

    local filename = ""
    local mapname = ""
    for k,map in pairs(mapList) do
        if map.id == mapid then
            filename = map.path
            mapname = map.name
            break
        end
    end
    Buffer.curr_filepath = filename

    Async:foreach(parsed, function(v)
    -- for _, v in pairs(parsed) do
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
                local elements = SetObjectMaterial(Buffer.last_object, mat_index,model_id,lib_name,tex_name,color)
                if type(elements) == "table" then
                    table.insert(loaded_maps[mapid].materials, {
                        model = model_id,
                        elements = elements,
                    })
                end
            end
        elseif v.f == "remove" then
            local model,radius,x,y,z = unpack(v.variables)
            if removeWorldModel(model,radius,x,y,z,int) then
                table.insert(loaded_maps[mapid].removals, {
                    model,radius,x,y,z,int
                })
            end
        end
    -- end
    end)

    Buffer.total = 0
    Buffer.last_object = nil
    Buffer.curr_filepath = ""
    Buffer.curr_line = 0

    outputDebugString("Map '"..mapname.."' (ID "..mapid..") loaded")
    return true
end

function unloadTextureStudioMap(mapid)
    if not loaded_maps[mapid] then
        outputDebugString("Can't unload: map "..mapid.." not loaded", 2)
        return
    end

    local icounts = {
        materials = #(loaded_maps[mapid].materials),
        models = #(loaded_maps[mapid].models),
        objects = #(loaded_maps[mapid].objects),
        removals = #(loaded_maps[mapid].removals),
    }

    local counts = {
        materials = 0,
        models = 0,
        objects = 0,
        removals = 0,
    }
    

    local destroyed_obj_ids = {} -- free SAMP objects that are allocated and not used for any other map
    local remaining_ids = {}
    
    
    -- for k,v in pairs(loaded_maps[mapid].materials) do -- important cleanup
    Async:foreach(loaded_maps[mapid].materials, function(v)

        local model = v.model
        if isSampObject(model) then
            destroyed_obj_ids[model] = true
        end

        local elements = v.elements
        for j,w in pairs(elements) do
            if isElement(w) then
                destroyElement(w)
            end
        end

        counts.materials = counts.materials + 1
    -- end
    end)

    -- for k,v in pairs(loaded_maps[mapid].models) do
    Async:foreach(loaded_maps[mapid].models, function(v)
        freeNewObject(v)
        counts.models = counts.models + 1
    -- end
    end)

    -- for k,v in pairs(loaded_maps[mapid].objects) do
    Async:foreach(loaded_maps[mapid].objects, function(v)
        for j,w in pairs(v) do
            if isElement(w) then
                local model = getSAMPOrDefaultModel(w)
                if isSampObject(model) then
                    local allocated_id = getElementModel(w)
                    destroyed_obj_ids[allocated_id] = true
                end
                destroyElement(w)
                counts.objects = counts.objects + 1
            end
        end
    -- end
    end)

    -- for k,v in pairs(loaded_maps[mapid].removals) do
    Async:foreach(loaded_maps[mapid].removals, function(v)
        local model,radius,x,y,z,int = unpack(v)
        restoreWorldModel(model,radius,x,y,z,int)
        counts.removals = counts.removals + 1
    -- end
    end)


    -- for id2,v in pairs(loaded_maps) do
    Async:foreach(loaded_maps, function(v, id2)
        if id2 ~= mapid then
            if v == "objects" then
                local model = getSAMPOrDefaultModel(v[1])
                if isSampObject(model) then
                    local allocated_id = getElementModel(v[1])
                    remaining_ids[allocated_id] = true
                end
            end
        end
    -- end
    end)

    -- for id,_ in pairs(destroyed_obj_ids) do
    Async:foreach(destroyed_obj_ids, function(v, id)
        if not remaining_ids[id] then
            freeNewObject(id)
        end
    -- end
    end)

    outputDebugString("  Unloaded map "..mapid.." stats:")
    outputDebugString(counts.materials.."/"..icounts.materials.." materials cleaned", 0,255,255,255)
    outputDebugString(counts.models.."/"..icounts.models.." models cleaned", 0,255,255,255)
    outputDebugString(counts.objects.."/"..icounts.objects.." objects cleaned", 0,255,255,255)
    outputDebugString(counts.removals.."/"..icounts.removals.." removals cleaned", 0,255,255,255)

    loaded_maps[mapid] = nil
    objects_load_list[mapid] = nil


    local mapname = ""
    for k,map in pairs(mapList) do
        if map.id == mapid then
            mapname = map.name
            break
        end
    end

    outputDebugString("Map '"..mapname.."' (ID "..mapid..") unloaded")
end
addEvent("sampobj:unloadMap", true)
addEventHandler("sampobj:unloadMap", resourceRoot, unloadTextureStudioMap)

function doLoadSAMPObjects(objs, mapid)
    objects_load_list[mapid] = objs

    if loadSAMPObjects() then
        return true
    end
end

function doLoadTextureStudioMap(thismap_objs,mapid,parsed,int,dim)

    if doLoadSAMPObjects(thismap_objs, mapid) then

        local loaded, reason = loadTextureStudioMap(mapid, parsed, int, dim)
        if not loaded then
            outputDebugString("Failed to load map ID "..mapid..", reason: "..reason)
        end
    end
end
addEvent("sampobj:loadMap", true)
addEventHandler("sampobj:loadMap", resourceRoot, doLoadTextureStudioMap)

function clientStartupLoad(objs, maps)

    for id, parsed in pairs(maps) do
        if doLoadSAMPObjects(objs[id], id) then

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


    triggerLatentServerEvent("sampobj:request", resourceRoot)

    if TDO_AUTO then
        togDrawObjects() -- enable on startup for testing
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