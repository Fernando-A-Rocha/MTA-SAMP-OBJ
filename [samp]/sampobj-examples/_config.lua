--[[
	Configuration file for the entire sampobj-examples resource
]]

-- In case you want to change the main library resource name:
local libName = "sampobj"

local res = getThisResource()
-- Global resource name variable
resName = getResourceName(res)

if isElement(localPlayer) then
	addEventHandler( "onClientResourceStart", resourceRoot, function() lib = exports[libName] end)
else
	addEventHandler( "onResourceStart", resourceRoot, function() lib = exports[libName] end)
end