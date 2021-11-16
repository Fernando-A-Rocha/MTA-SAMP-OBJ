--[[
	Author: Fernando
	Script: new_objects/client.lua
	
	Description:

		Adds a few new objects to the game then creates them somewhere using the 'sampobj' library
		Useful for coding your own implementations

		TL;DR - All you need to do is first AddSimpleModel then CreateNewObject and destroy obj when no longer needed

	Commands (clientside):
		- /newmodels: lists all models defined in the samp_models example inside modelList
		- /dobjs: (destroy new objects) destroys new objects spawned with the samp_objects example
]]

-- 	
-- 	Models folder path relative to this resource
-- 	
local modelsFolder = "new_objects/models"

-- 	
-- 	Table containing new object models to add
-- 	
local modelList = {
	--model   	base model  		 dff   					txd   					col
	{50001, 	  1337,		  "engine_hoist.dff",  	 "engine_hoist.txd",  	"engine_hoist.col"},
}


--
-- 	Table containing model ID, spawn coords and settings for each object
-- 	To see them go to Blueberry next to 0,0,0
--
local objs = {
	--model, 			x,y,z, 									rx,ry,rz, 	int,dim,  scale, distance
	{50001, 	-8.412109375, 6.44921875, 2.15, 			0,0,0, 		0,0},
}

--
-- 	Table which will store the spawned object elements
--
local spawned = {}

-- 	
-- 	Array containing allocated IDs for new objects IDs
-- 	
local allocated = {}

--
-- 	Command to list all loaded new objects
--
function myNewObjects(cmd)
	for newid,allocated_id in pairs(allocated) do
		outputChatBox(newid.." - Allocated ID: "..allocated_id)
	end
end
addCommandHandler("newmodels", myNewObjects, false)

--
-- 	Destroys all objects stored in 'spawned' and returns the count
--
local function destroyAllSpawnedNew()
	
	local count = 0
	local count_lod = 0

	for obj,v in pairs(spawned) do
		if isElement(obj) then
			if destroyElement(obj) then
				count = count + 1
			end
		end
		if isElement(v.blip) then
			destroyElement(v.blip)
		end
		if isElement(v.lod) then
			if destroyElement(v.lod) then
				count_lod = count_lod + 1
			end
		end
	end
	return count, count_lod
end

--
-- 	Command to destroy the new objects and output count
--
local function destroyNewObjs(cmd)
	local a,b = destroyAllSpawnedNew()
	outputChatBox("Destroyed "..a.." new objects, "..b.." of which had LOD", 0,255,0)
end
addCommandHandler("dnewobjs", destroyNewObjs, false)

--
-- 	If you decide to destroy an object element that was spawned on startup,
-- 	it will automatically be removed from the 'spawned' array
--
addEventHandler( "onClientElementDestroy", resourceRoot, 
function ()
	-- Free memory when object is destroyed automatically

	local et = getElementType(source)
	if et == "object" or et == "blip" then
	
		for obj,v in pairs(spawned) do

			if v.lod == source then
				spawned[obj].lod = nil
			elseif v.blip == source then
				spawned[obj].blip = nil

			elseif obj == source then
				
				if isElement(v.lod) then
					destroyElement(v.lod)
				end
				if isElement(v.blip) then
					destroyElement(v.blip)
				end

				spawned[obj] = nil
			end
		end
	end
end)



addEventHandler( "onClientResourceStart", resourceRoot, 
function (startedResource)
	
	local count = 0

	for k,v in pairs(modelList) do
		local model,base,dff,txd,col = unpack(v)
		local path = ":"..resName.."/"..modelsFolder
		local allocated_id = lib:AddSimpleModel(base or 1337, model, path, dff, txd, col)
		if allocated_id then
			allocated[allocated_id] = model
			count = count + 1
		end
	end

	print("Loaded "..count.." new objects")

	local count2 = 0
	local count2_lod = 0

	for k,v in pairs(objs) do
		local model,x,y,z,rx,ry,rz,int,dim,scale,distance,doublesided = unpack(v)
		local obj,lod = lib:CreateNewObject(model,x,y,z,rx,ry,rz,distance)
		if obj then
			spawned[obj] = { blip = createBlip(x,y,z, 0, 1, 255,194,14,255) }

			setElementInterior(obj, int)
			setElementDimension(obj, dim)
			setObjectScale(obj, scale or 1)
			if doublesided then
				setElementDoubleSided(obj, true)
			end

			if lod then
				spawned[obj].lod = lod
				count2_lod = count2_lod + 1
			end

			count2 = count2+1
		end
	end

	print("Spawned "..count.." new objects, "..count2_lod.." of which have LOD")
end)


--
-- 	Destroy the objects on resource stop (aka when player disconnects)
-- 	It's important to note that objects spawned won't be automatically destroyed
-- 	because they were created in another resource 'sampobj'
--
addEventHandler( "onClientResourceStop", resourceRoot, 
function (stoppedResource)
	destroyAllSpawnedNew()
end)
