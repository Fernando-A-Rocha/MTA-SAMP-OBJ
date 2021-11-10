function isSampObject(model)
    model = tonumber(model)
    return model >= 18631 and model <= 19999 or model >= 11682 and model <= 12799
end

function genFileStream() -- credit by thisdp
	return {
		--Variable
		file = false;
		cacheSize = 512*512;	--1MB
		cachedString = ""; 
		cachedIndex	= false;
		--Function
		loadFile = function(self,fname)
			if fileExists(fname) then
				self.file = fname
			end
		end;
		cache = function(self,offset)
			local filePath = self.file
			if filePath then
				local f = fileOpen(self.file)
				fileSetPos(f,offset)
				self.cachedString = fileRead(f,self.cacheSize)
				self.cachedIndex = offset
				fileClose(f)
				return str
			end
			return false
		end;
		get = function(self,offset,bytes,direct)
			local filePath = self.file
			if filePath then
				if direct then
					local f = fileOpen(filePath)
					fileSetPos(f,offset)
					local str = fileRead(f,bytes)
					fileClose(f)
					return str
				else
					if not self.cachedIndex then self:cache(offset) end
					local cacheStart,cacheEnd = self.cachedIndex,self.cachedIndex+self.cacheSize
					local readStart,readEnd = offset,offset+bytes
					local str = ""
					if readStart >= cacheStart then
						if readStart >= cacheEnd then
							self:cache(readStart)
							return self:get(offset,bytes)
						end
						if readEnd <= cacheEnd then
							return self.cachedString:sub(readStart-cacheStart+1,readEnd-cacheStart)
						else
							str = self.cachedString:sub(readStart-cacheStart+1)
							while true do
								self:cache(self.cachedIndex+self.cacheSize)
								local _cacheEnd = self.cachedIndex+self.cacheSize
								if self.cachedIndex+self.cacheSize >= readEnd then
									str = str..self.cachedString:sub(1,readEnd-self.cachedIndex)
									break
								else
									str = str..self.cachedString
								end
							end
							return str
						end
					else
						self:cache(readStart)
						return self:get(offset,bytes)
					end
				end
			end
		end;
		readChar = function(self,offset,bytes)
			local str = self:get(offset,bytes)
			local zero = str:find("%z")
			if zero then
				return str:sub(1,zero-1)
			end
			return str
		end;
		readNumber = function(self,offset,bytes)
			local str = self:get(offset,bytes)
			local num = 0
			for i=1,bytes do
				num = num+str:sub(i,i):byte()*0x100^(i-1)
			end
			return num
		end;
	}
end

function engineLoadIMGContainer(file)
	assert(type(file) == "string","Bad argument @'engineLoadIMGContainer' at argument 1, expected a string got "..type(file))
	assert(fileExists(file),"Bad argument @'engineLoadIMGContainer' at argument 1, file "..file.." doesn't exist")
	local fs = genFileStream()
	fs:loadFile(file)
	local imgFile = {
		files = {},
		directory = {},
		directoryNameToIndex = {},
	}
	--Read Head
	local readIndex = 0
	local IMGVer = fs:readChar(readIndex,4)
	readIndex = readIndex+4
	imgFile.version = IMGVer
	local entriesCount = fs:readNumber(readIndex,4)
	readIndex = readIndex+4
	imgFile.entriesCount = entriesCount
	--Read Directory
	for index=1,entriesCount do
		local i = index-1
		local offset,streamingSize,sizeInArchive,name
		offset = fs:readNumber(readIndex,4)
		readIndex = readIndex+4
		streamingSize = fs:readNumber(readIndex,2)
		readIndex = readIndex+2
		sizeInArchive = fs:readNumber(readIndex,2)
		readIndex = readIndex+2
		name = string.lower(fs:readChar(readIndex,24))
		readIndex = readIndex+24
		imgFile.directory[index] = {name=name,streamingSize=streamingSize*2048,sizeInArchive=sizeInArchive*2048,offset=offset*2048}
		imgFile.files[index] = name
		imgFile.directoryNameToIndex[name] = index
	end
	imgFile.getFile = function(self,name)
		if self then
			local index = imgFile.directoryNameToIndex[name]
			if index then
				local dirData = imgFile.directory[index]
				return fs:get(dirData.offset,dirData.streamingSize)
			end
			return false
		end
	end
	imgFile.fileExists = function(self,name)
		return imgFile.directoryNameToIndex[name] or false
	end
	imgFile.listFiles = function(self)
		return imgFile.files
	end
	return imgFile
end


local matchedCOLVer = {
	COLL = "COLL",
	COL2 = "COL2",
	COL3 = "COL3",
}
function engineGetCOLsFromLibrary(file)
	assert(type(file) == "string","Bad argument @'engineGetCOLsFromLibrary' expected a string at argument 1, got "..type(file))
	if fileExists(file) then	--COL Library
		local f = fileOpen(file)
		local str = fileRead(f,fileGetSize(f))
		fileClose(f)
		return engineGetCOLsFromLibrary(str)
	else
		local cols = {}
		while true do
			local colVer = file:sub(1,4)
			if matchedCOLVer[colVer] then
				local a,b,c,d = file:byte(5,8)
				local colSize = a+b*0x100+c*0x10000+d*0x1000000
				local col = file:sub(1,colSize+8)
				local colName = col:sub(9,29)
				local zeroPoint = colName:find("\0")
				cols[string.lower(colName:sub(1,zeroPoint-1))] = col
				file = file:sub(colSize+9)
			else
				break
			end
		end
		return cols
	end
end