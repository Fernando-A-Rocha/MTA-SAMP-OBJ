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
            outputDebugString("(samp) "..model..".dff not in SA_MATLIB", 2)
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
            outputDebugString(model..".dff not in SA_MATLIB", 2)
        end
    end

    -- debugging
    -- if not tex_name and SA_MATLIB[model..".dff"] then
    --     outputChatBox((samp_info and ("(samp) "..samp_info.samp_id) or mta_id).." index "..mat_index.." not found, "..#(SA_MATLIB[model..".dff"]).." available:")
    --     for k,val in pairs(SA_MATLIB[model..".dff"]) do
    --         outputChatBox(val.index.." => "..val.name)
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
    return nil
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

function setObjectMaterial(object,mat_index,model_id,lib_name,tex_name,color)
    --mta doesn't need lib_name (.txd file) to find texture by name
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
                outputDebugString(string.format( "[OBJ_MAT] Invalid texture name on model_id: %d and tex_name: %s, file: %s, line: %d", model_id,tex_name, Buffer.curr_filepath, Buffer.curr_line), 1)
            end
            engineApplyShaderToWorldTexture (matShader,target_tex_name,object)

            local mat_info = getElementData(object, "material_info") or {}
            table.insert(mat_info, {
                mat_index = mat_index,
                target_tex_name = target_tex_name,
                tex_name = tex_name
            })
            setElementData(object, "material_info", mat_info)
        else
            local model = getElementModel(object)
            local samp_info = MTAIDMapSAMPModel[model]
            model = samp_info and ("(samp) "..samp_info.samp_id) or tostring(model)

            -- outputChatBox(string.format( "[OBJ_MAT] Unknown material on model: %s, index: %d, file: %s, line: %d", model,mat_index, Buffer.curr_filepath, Buffer.curr_line), 255,255,0)
            outputDebugString(string.format( "[OBJ_MAT] Unknown material on model: %s, index: %d, file: %s, line: %d", model,mat_index, Buffer.curr_filepath, Buffer.curr_line), 2)
        end
    end
end