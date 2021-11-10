-- Credits: Fernando

local mpath = "models/"
function AddSimpleModel(virtualworld, baseid, newid, dffname, txdname) -- virtualworld ignored
	baseid = tonumber(baseid)
	newid = tonumber(newid)
	assert(newid and baseid, "baseid or newid not numbers")

	local dffpath = mpath..dffname
	assert(fileExists(dffpath), "file not found: "..dffpath)

	local txdpath = mpath..txdname
	assert(fileExists(txdpath), "file not found: "..txdpath)

	local colname = (dffname:gsub(".dff", ""))..".col" -- 	generated with kdff
	local colpath = mpath..colname
	assert(fileExists(colpath), "file not found: "..colpath)

	local allocated_id = mallocSAMPObject(txdpath, dffpath, colpath, newid, baseid, dffname, txdname)
	if not allocated_id then
		outputDebugString(string.format("[SAMP_OBJ] failed to add object: %d - %s, %s, %s",newid, dffname,txdname,colname), 1)
		return false
	-- else
		-- outputDebugString(string.format("[SAMP_OBJ] allocated to: %d - %s, %s, %s",newid, dffname,txdname,colname), 0,25,255,25)
	end

	return true
end