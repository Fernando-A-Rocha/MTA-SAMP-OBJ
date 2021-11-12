
function CreateNewObject(model_id,x,y,z,rx,ry,rz,distance)
    distance = distance or 300
    local obj, lod

    local samp_info = SAMPObjects[model_id]
    model_id = samp_info and samp_info.malloc_id or model_id

    if model_id < 0 then
        -- outputDebugString("model '"..model_id.."' missing custom model!", 2)
        return
    end

    obj = createObject(model_id,x,y,z,rx,ry,rz)
    
    if not obj and isSampObject(model_id) then
        -- outputDebugString("failed to create samp object, not allocated: "..model_id, 2)
        return
    end

    if obj and distance ~= 300 then
        lod = createObject(model_id,x,y,z,rx,ry,rz,true)
        setLowLODElement ( obj, lod )
        engineSetModelLODDistance ( model_id, distance )
    end

    return obj,lod
end