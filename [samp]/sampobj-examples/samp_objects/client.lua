--[[
	Author: Fernando
	Script: samp_objects/client.lua
	
	Description:

		Creates some SA-MP objects without using the built-in SA-MP map loading feature provided by 'sampobj'
		Useful for coding your own implementations
		
		TL;DR - All you need to do is CreateNewObject and destroy obj when no longer needed

	Commands (clientside):
		- /spawnobject: creates a an object by ID where you're standing
		- /dobjs: (destroy objects) destroys SA-MP objects spawned with the samp_objects example
]]


--
-- 	Table containing model ID, spawn coords and settings for each object
-- 	To see them go to Blueberry next to 0,0,0
--
local objs = {
	--model, 			x,y,z, 									rx,ry,rz, 	int,dim,  scale, distance
	{19833, 	35.4443359375, 26, 5, 							0,0,90, 	0,0, 		10},
	{19833, 	51.6201171875, 11.4931640625, 5, 				0,0,120, 	0,0, 		5},
	{18801, 	6.576171875, -62.5546875, 24.6, 				0,0,90, 	0,0, 		1, 500},
	{18859, 	80.3837890625, -76.3359375, 11, 				0,0,-90, 	0,0, 		1, 500},
	{18850, 	19.701171875, -3.705078125, 13.5, 				0,0,0, 		0,0, 		1, 500},
	{19338, 	79.9638671875, -15.5849609375, 19.061399, 		0,0,0, 		0,0, 		1, 500},
	{19335, 	43.5693359375, -125.1123046875, 31.1265449, 	0,0,0, 		0,0, 		1, 500},
	{19076, 	37.6865234375, -37.0576171875, 0.5, 			0,0,0, 		0,0, 		1, 300, true},
	{18880, 	7.861328125, -24.2509765625, 2, 				0,0,0, 		0,0, 		1, 400, true},
	{19967, 	-13.4482421875, 20.7470703125, 1.5, 			0,0,90,		0,0, 		1, 300, true},
}

--
-- 	Table which will store the spawned object elements
--
local spawned = {}

--
-- 	Destroys all objects stored in 'spawned' and returns the count
--
local function destroyAllSpawnedSAMP()
	
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
-- 	Command to destroy objects and output count
--
local function destroyObjs(cmd)
	local a,b = destroyAllSpawnedSAMP()
	outputChatBox("Destroyed "..a.." SA-MP objects, "..b.." of which had LOD", 0,255,0)
end
addCommandHandler("dobjs", destroyObjs, false)

--
-- 	Command to create a SA-MP object at localPlayer's position
--
local cTimer
local function spawnObject(cmd, model)
	if not tonumber(model) then
		outputChatBox("SYNTAX: /"..cmd.." [Object ID]", 255,194,14)
		outputChatBox("See: https://dev.prineside.com/en/gtasa_samp_model_id/", 255,126,14)
		return
	end
	model = tonumber(model)
	local x,y,z = getElementPosition(localPlayer)
	local rx,ry,rz = getElementRotation(localPlayer)
	local i,d = getElementInterior(localPlayer), getElementDimension(localPlayer)

	local obj,lod = lib:CreateNewObject(model,x,y,z,0,0,rz)
	if obj then
		if isTimer(cTimer) then killTimer(cTimer) end
		setElementCollidableWith(localPlayer, obj, false)
		cTimer = setTimer(setElementCollidableWith, 2000, 1, localPlayer, obj, true)

		spawned[obj] = { blip = createBlip(x,y,z, 0, 1, 255,126,0,200) }

		setElementInterior(obj, i)
		setElementDimension(obj, d)
		if lod then
			spawned[obj].lod = lod
		end
		
		outputChatBox("Spawn a SA-MP Object ID "..model.." at "..x..", "..y..", "..z.." (int: "..i.." & dim: "..d..")", 25,255,0)
	else
		outputChatBox("Failed to spawn SA-MP Object ID "..model..". Check for debug error messages.", 255,0,0)
	end
end
addCommandHandler("spawnobject", spawnObject, false)

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


--
-- 	Spawn the objects on startup and store them in the 'spawned' table so they can destroyed later
--
addEventHandler( "onClientResourceStart", resourceRoot, 
function (startedResource)

	local count = 0
	local count_lod = 0

	for k,v in pairs(objs) do

		local model,x,y,z,rx,ry,rz,int,dim,scale,distance,doublesided = unpack(v)
		local obj,lod = lib:CreateNewObject(model,x,y,z,rx,ry,rz,distance)
		if obj then
			spawned[obj] = { blip = createBlip(x,y,z, 0, 1, 255,126,0,200) }

			setElementInterior(obj, int)
			setElementDimension(obj, dim)
			setObjectScale(obj, scale or 1)
			if doublesided then
				setElementDoubleSided(obj, true)
			end

			if lod then
				spawned[obj].lod = lod
				count_lod = count_lod + 1
			end

			count = count+1
		end
	end

	print("Spawned "..count.." SA-MP objects, "..count_lod.." of which have LOD")
end)

--
-- 	Destroy the objects on resource stop (aka when player disconnects)
-- 	It's important to note that objects spawned won't be automatically destroyed
-- 	because they were created in another resource 'sampobj'
--
addEventHandler( "onClientResourceStop", resourceRoot, 
function (stoppedResource)
	destroyAllSpawnedSAMP()
end)