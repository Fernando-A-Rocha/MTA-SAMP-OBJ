
function string.trim(str)
    str = string.gsub(str, "%s+", "")
    return str
end
function string.contains(str,key) 
    return string.match(str, key) ~= nil
end
function isComment(line)
    return string.match(line,"//") ~= nil
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

-- Do the parsing here
function getTextureStudioMap(filename)
    if fileExists(filename) then 

        local result = {}
        local samp_objs_used = {}

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
                                virtualworld, baseid, newid, dffname, txdname
                            }
                        })
                    end
                end
                if isCreateObject(line) then
                    local b = split(line,"=")
                    local model,x,y,z,rx,ry,rz,dist = parseCreateObject(b[2])
                    if model then
                        table.insert(result, {
                            f = "object",
                            line = i,
                            variables = {
                                model,x,y,z,rx,ry,rz,dist
                            }
                        })

                        if isSampObject(model) then
                            samp_objs_used[model] = true
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
                                index,model,lib,txd,color
                            }
                        })

                        if isSampObject(model) then
                            samp_objs_used[model] = true
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

        return result, "", samp_objs_used
    else
        return false, filename.." doesn't exist"
    end
end