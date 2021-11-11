
function CreateSAMPObject(model_id,x,y,z,rx,ry,rz)
    if SAMPObjects[model_id] and SAMPObjects[model_id].malloc_id ~= nil then 
        --local lod = createObject(SAMPObjects[model_id].malloc_id,x,y,z,rx,ry,rz,true)
        local samp_obj = createObject(SAMPObjects[model_id].malloc_id,x,y,z,rx,ry,rz)
        if samp_obj then
            setElementDoubleSided(samp_obj,true)
            return samp_obj
        else
            outputDebugString("[SAMP_OBJ] Faild to create model: "..model_id, 1)
            return false
        end
    elseif not isSampObject(model_id) then -- not SAMP Object
        return createObject(model_id,x,y,z,rx,ry,rz)
    else
        outputDebugString("samp object not allocated: "..model_id, 2)
    end
end