-- Credits: Fernando
-- Adding new objects for SA-MP Maps
-- Generate the .col with kdff

function AddSimpleModel(baseid, newid, folderPath, fileDff, fileTxd, fileCol)
	--[[
		OPTIONAL: fileCol
		when not passed it will assume dff name .col
	]]

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


	if not (fileCol and type(fileCol)=="string") then
		fileCol = (fileDff:gsub(".dff", ""))..".col"
	end

	local colpath = folderPath..fileCol
	assert(fileExists(colpath), "file not found: "..colpath)


	if SAMPObjects[newid] then
		local reason2 = "newid already allocated"
		outputDebugString(string.format("failed to add object: %d - %s, %s, %s, reason: %s",newid, fileDff,fileTxd,fileCol,reason2), 1)
		return false
	end

	-- SAMP model as base id not supported
	if isSampObject(baseid) then
		outputDebugString(string.format("ignoring SAMP base id %d upon adding: %d - %s, %s, %s ...",baseid, newid, fileDff,fileTxd,fileCol), 2)
		baseid = nil
	end

	local allocated_id, reason = mallocNewObject(txdpath, dffpath, colpath, newid, baseid, "-")
	if not tonumber(allocated_id) then
		outputDebugString(string.format("failed to add object: %d - %s, %s, %s, reason: %s",newid, fileDff,fileTxd,fileCol,reason), 1)
		return false
	end

	return allocated_id
end