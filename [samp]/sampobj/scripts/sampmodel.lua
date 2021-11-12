-- Credits: Fernando

local mpath = "models/"

function AddSimpleModel(virtualworld, baseid, newid, dffname, txdname) -- virtualworld ignored
	baseid = tonumber(baseid)
	assert(baseid, "baseid not number: "..tostring(baseid))

	newid = tonumber(newid)
	assert(newid, "newid not number: "..tostring(newid))

	local dffpath = mpath..dffname
	assert(fileExists(dffpath), "file not found: "..dffpath)

	local txdpath = mpath..txdname
	assert(fileExists(txdpath), "file not found: "..txdpath)

	local colname = (dffname:gsub(".dff", ""))..".col" -- 	generated with kdff
	local colpath = mpath..colname
	assert(fileExists(colpath), "file not found: "..colpath)

	if SAMPObjects[newid] then
		local reason2 = "newid already allocated"
		outputDebugString(string.format("failed to add object: %d - %s, %s, %s, reason: %s",newid, dffname,txdname,colname,reason2), 1)
		return false
	end

	-- SAMP model as base id not supported
	if isSampObject(baseid) then
		outputDebugString(string.format("ignoring SAMP base id %d upon adding: %d - %s, %s, %s ...",baseid, newid, dffname,txdname,colname), 2)
		baseid = nil
	end

	local allocated_id, reason = mallocNewObject(txdpath, dffpath, colpath, newid, baseid, dffname, txdname)
	if not tonumber(allocated_id) then
		outputDebugString(string.format("failed to add object: %d - %s, %s, %s, reason: %s",newid, dffname,txdname,colname,reason), 1)
		return false
	end

	return allocated_id
end