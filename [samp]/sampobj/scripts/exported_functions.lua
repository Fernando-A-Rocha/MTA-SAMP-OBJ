--[[
    Credits: gta191977649 & Fernando
    Exported functions (client and server)
--]]



-- Adding new objects for SA-MP Maps
-- You can generate a model's .col with kdff

function AddSimpleModel(baseid, newid, folderPath, fileDff, fileTxd, fileCol) -- [Exported]

    baseid = tonumber(baseid)
    assert(baseid, "baseid not number: "..tostring(baseid))

    newid = tonumber(newid)
    assert(newid, "newid not number: "..tostring(newid))

    assert(type(folderPath)=="string", "folderPath not passed, example ':myResource/models'")

    local lastchar = string.sub(folderPath, -1)
    if lastchar ~= "/" then
        folderPath = folderPath.."/"
    end

    assert(string.find(fileDff, ".dff") ~= nil, "model dff file name must end in .dff")
    assert(string.find(fileTxd, ".txd") ~= nil, "model txd file name must end in .txd")

    local dffpath = folderPath..fileDff
    assert(fileExists(dffpath), "file not found: "..dffpath)

    local txdpath = folderPath..fileTxd
    assert(fileExists(txdpath), "file not found: "..txdpath)

    local colpath = folderPath..fileCol
    assert(fileExists(colpath), "file not found: "..colpath)

    if SAMPObjects[newid] then
        local reason2 = "newid already allocated"
        outputDebugMsg(string.format("failed to add object model: %d - %s, %s, %s, reason: %s",newid, fileDff,fileTxd,fileCol,reason2), 1)
        return false
    end

    -- SAMP model as base id not supported
    if isNewObject(baseid) then
        -- outputDebugMsg(string.format("ignoring new object model with base id %d (upon adding): %d - %s, %s, %s ...",baseid, newid, fileDff,fileTxd,fileCol), 2)
        baseid = nil
    end

    local allocated_id, reason = mallocNewObject(txdpath, dffpath, colpath, newid, baseid, "-")
    if not tonumber(allocated_id) then
        outputDebugMsg(string.format("failed to add object model: %d - %s, %s, %s, reason: %s",newid, fileDff,fileTxd,fileCol,reason), 1)
        return false
    end

    return allocated_id
end




-- Spawn an object of a default SA ID or a New Added ID
-- (SAMP or custom after calling AddSimpleModel)

function CreateNewObject(model_id,x,y,z,rx,ry,rz,distance) -- [Exported]
    local obj, lod

    local samp_info = SAMPObjects[model_id]
    model_id = samp_info and samp_info.malloc_id or model_id

    if isNewObject(model_id) and not samp_info then
        if isSAMPObject(model_id) then
            -- samp obj not yet loaded, meaning no map used it and the scripter called this func separately:
            -- mapid 0 means objects not belonging to any map (spawned freely by a dev)
            if (queueSAMPID(model_id, 0) and loadSAMPObjects()) then
                return CreateNewObject(model_id,x,y,z,rx,ry,rz,distance)
            else
                outputDebugMsg("SAMP ID "..model_id.." failed to allocate", 1)
                return
            end
        else
            outputDebugMsg("model ID "..model_id.." unknown, call AddSimpleModel before creating", 2)
            return
        end
    end

    obj = createObject(model_id,x,y,z,rx,ry,rz)
    
    if not obj then
        outputDebugMsg("failed to create object of model: "..model_id, 1)
        return
    end

    if obj and tonumber(distance) and distance ~= 300 then
        lod = createObject(model_id,x,y,z,rx,ry,rz,true)
        setLowLODElement ( obj, lod )
        engineSetModelLODDistance ( model_id, distance )
    end

    return obj,lod
end



-- Changing object texture with SetObjectMaterial via material index

function getTextureNameFromIndex(object,mat_index)
    local mta_id = getElementModel(object)
    local samp_info = MTAIDMapSAMPModel[mta_id]
    
    local tex_name = nil

    local model = ""

    if samp_info then -- if samp model
        model = samp_info.dff
        if SA_MATLIB[model..".dff"] ~= nil then
            for _,val in ipairs(SA_MATLIB[model..".dff"]) do
                if val.index == mat_index then --
                    tex_name = val.name
                end
            end
        else
            outputDebugMsg("(samp) "..model..".dff not in SA_MATLIB", 2)
        end
    else -- normal SA object
        model = string.lower(engineGetModelNameFromID(mta_id))
        if SA_MATLIB[model..".dff"] ~= nil then
            for _,val in ipairs(SA_MATLIB[model..".dff"]) do
                if val.index == mat_index then --
                    tex_name = val.name
                end
            end
        else
            outputDebugMsg(model..".dff not in SA_MATLIB", 2)
        end
    end

    
    -- more in depth debugging (uncomment this)

    -- if not tex_name and SA_MATLIB[model..".dff"] then
    --     outputDebugMsg((samp_info and ("(samp) "..samp_info.samp_id) or mta_id).." index "..mat_index.." not found, "..#(SA_MATLIB[model..".dff"]).." available:")
    --     for k,val in pairs(SA_MATLIB[model..".dff"]) do
    --         outputDebugMsg(val.index.." => "..val.name)
    --     end
    -- end

    return tex_name
end
function getTextureFromName(model_id,tex_name)
    if SAMPObjects[model_id] then -- if is samp model, we need to obtain the id allcated by the MTA
        model_id = SAMPObjects[model_id].malloc_id
    end

    local txds = engineGetModelTextures(model_id,tex_name)
    for name,texture in pairs(txds) do
        return texture, name
    end
end

function getColor(color)
    if color == "0" or color == 0 then
        return 1,1,1,1
    elseif #color == 8 then 
        local a = tonumber(string.sub(color,1,2), 16) /255
        local r = tonumber(string.sub(color,3,4), 16) /255
        local g = tonumber(string.sub(color,5,6), 16) /255
        local b = tonumber(string.sub(color,7,8), 16) /255
        return a,r,g,b
    else -- not hex, not number, return default material color
        return 1,1,1,1
    end 
end

function SetObjectMaterial(object,mat_index,model_id,tex_name,color)  -- [Exported]
    --MTA doesn't need lib_name (.txd file) to find texture by name
    if model_id ~= -1 then -- dealing replaced mat objects
        local target_tex_name = getTextureNameFromIndex(object,mat_index)
        if target_tex_name ~= nil then 
            -- find the txd name we want to replaced
            local matShader = dxCreateShader( "files/shader.fx" )
            local matTexture = getTextureFromName(model_id,tex_name)
            if matTexture ~= nil then
                -- apply shader attributes
                --local a,r,g,b = getColor(color)
                --a = a == 0 and 1 or a
                --alpha disabled due to bug
                dxSetShaderValue ( matShader, "gColor", 1,1,1,1);
                dxSetShaderValue ( matShader, "gTexture", matTexture);
            else
                destroyElement(matShader)
                outputDebugMsg(string.format( "Invalid texture name on model_id: %s and tex_name: %s", tostring(model_id),tostring(tex_name)), 2)
                return false
            end
            engineApplyShaderToWorldTexture (matShader,target_tex_name,object)

            local mat_info = getElementData(object, "material_info") or {}
            table.insert(mat_info, {
                mat_index = mat_index,
                target_tex_name = target_tex_name,
                tex_name = tex_name
            })
            setElementData(object, "material_info", mat_info)

            return { matShader, matTexture }
        else
            local model = getSAMPOrDefaultModel(object)
            outputDebugMsg(string.format( "Unknown material on model: %s, index: %s", tostring(model),tostring(mat_index)), 2)
            return false
        end
    end
end






-- Parse SA-MP map code (Pawn)

function string.trim(str)
    str = string.gsub(str, "%s+", "")
    return str
end
function string.contains(str,key) 
    return string.match(str, key) ~= nil
end
function isComment(line) -- lazy temp solution
    -- TODO know when a comment starts /* and then ends */
    if string.match(line,"//") ~= nil then return false end
    if string.match(line,"/*") ~= nil then return false end
    return true
end
function isCreateObject(line)
    return string.contains(line,"CreateObject") or string.contains(line,"CreateDynamicObject")
end
function isMaterialText(line) 
    return string.contains(line,"SetDynamicObjectMaterialText") or string.contains(line,"SetObjectMaterialText")
end
function isSetMaterial(line)
    if isMaterialText(line) then return false end
    return string.contains(line,"SetObjectMaterial") or string.contains(line,"SetDynamicObjectMaterial")
end
function isWorldObjectRemovel(line)
    return string.contains(line,"RemoveBuildingForPlayer")
end
function isAddSimpleModel(line)
    return string.contains(line, "AddSimpleModel")
end

function parseCreateObject(code)
    -- get rid of unused syntax
    code = string.gsub(code, "%(", "")
    code = string.gsub(code, "%)", "")
    code = string.gsub(code, ";", "")
    code = string.gsub(code, "CreateObject", "")
    code = string.gsub(code, "CreateDynamicObjectEx", "")
    code = string.gsub(code, "CreateDynamicObject", "")
    code = string.trim(code)

    -- get object code
    local b = split(code,',')
    local model = tonumber(b[1])
    local x = tonumber(b[2])
    local y = tonumber(b[3])
    local z = tonumber(b[4])
    local rx = tonumber(b[5])
    local ry = tonumber(b[6])
    local rz = tonumber(b[7])
    local streamDis = b[11] ~= nil and tonumber(b[11]) or nil
    return model,x,y,z,rx,ry,rz,streamDis
end
function parseSetObjectMaterial(code)
    --code = string.gsub(code, "%(", "")
    --code = string.gsub(code, "%)", "")
    code = string.gsub(code, ";", "")
    code = string.gsub(code, "SetObjectMaterial", "")
    code = string.gsub(code, "SetDynamicObjectMaterial", "")
    code = string.trim(code)
    -- get info
    local b = split(code,',')
    local matIndex = tonumber(b[2])
    local model = tonumber(b[3])
    local lib = string.gsub(b[4], "\"", "")
    local txd = string.gsub(b[5], "\"", "")
    if lib == "none" or txd == "none" then
        return nil -- ignore none, it's just to set color
    end

    -- local color = string.gsub(b[6], "%)", "") -- color ignored for now
    -- color = string.gsub(color, "0x", "")
    return matIndex,model,lib,txd--,color 
end
function parseRemoveBuildingForPlayer(code)
    code = string.gsub(code, "%(", "")
    code = string.gsub(code, "%)", "")
    code = string.gsub(code, ";", "")
    code = string.gsub(code, "RemoveBuildingForPlayer", "")
    code = string.trim(code)
    local b = split(code,',')

    local model = tonumber(b[2])
    local x = tonumber(b[3])
    local y = tonumber(b[4])
    local z = tonumber(b[5])
    local rad = tonumber(b[6])
    return model, x, y, z, rad
end
function parseAddSimpleModel(code)
    code = string.gsub(code, "%(", "")
    code = string.gsub(code, "%)", "")
    code = string.gsub(code, ";", "")
    code = string.gsub(code, "AddSimpleModel", "")
    code = string.trim(code)
    local b = split(code,',')

    local virtualworld = tonumber(b[1])
    local baseid = tonumber(b[2])
    local newid = tonumber(b[3])
    local dffname = string.gsub(b[4], "\"", "")
    local txdname = string.gsub(b[5], "\"", "")
    return virtualworld, baseid, newid, dffname, txdname
end

function parseTextureStudioMap(filename) -- [Exported]  type: shared
    if fileExists(filename) then 

        local result = {}
        local new_objs_used = {}

        local f = fileOpen(filename)
        local str = fileRead(f,fileGetSize(f))
        fileClose(f)

        Lines = split(str,'\n' )
        for i = 1, #Lines do
            local line = Lines[i]
            if not isComment(line) then

                if isAddSimpleModel(line) then
                    local virtualworld, baseid, newid, dffname, txdname = parseAddSimpleModel(line)
                    if virtualworld then
                        table.insert(result, {
                            f = "model",
                            line = i,
                            variables = {
                                -- virtualworld is useless
                                baseid, newid, dffname, txdname
                            }
                        })
                    end
                end
                if isCreateObject(line) then
                    local objdetails = ""
                    if string.find(line, "=") then -- has variable = createObject
                        objdetails = split(line,"=")
                        objdetails = objdetails[2] or ""
                    else
                        objdetails = line
                    end
                    local model,x,y,z,rx,ry,rz,dist = parseCreateObject(objdetails)
                    if model then
                        table.insert(result, {
                            f = "object",
                            line = i,
                            variables = {
                                model,x,y,z,rx,ry,rz,dist
                            }
                        })

                        if isNewObject(model) then
                            new_objs_used[model] = true
                        end
                    end
                end
                if isSetMaterial(line) then 
                    local index,model,lib,txd,color = parseSetObjectMaterial(line)
                    if index then
                        table.insert(result, {
                            f = "material",
                            line = i,
                            variables = {
                                --lib not needed
                                index,model,txd,color
                            }
                        })

                        if isNewObject(model) then
                            new_objs_used[model] = true
                        end
                    end
                end
                if isWorldObjectRemovel(line) then 
                    local model,x,y,z,radius = parseRemoveBuildingForPlayer(line)
                    if model then
                        table.insert(result, {
                            f = "remove",
                            line = i,
                            variables = {
                                model,x,y,z,radius
                            }
                        })
                    end
                end
            end
        end

        return result, "", new_objs_used
    else
        return false, filename.." doesn't exist"
    end
end