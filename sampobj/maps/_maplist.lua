--[[
	List of maps to load on startup in scripts/loader.lua
]]

mapList = {
    {
    	id = 1, -- arbitrary ID
    	name = "Test Office", -- arbitrary custom name
    	path = "maps/office5.pwn", -- map file path
    	int = 1, -- interior world of the objects
    	dim = 2, -- dimension world of the objects
    	pos = {
	    	1928.7041015625, -343.6083984375, 50.75 -- x,y,z teleport location
	    }
	},
    {
    	id = 2, -- arbitrary ID
    	name = "Test 1", -- arbitrary custom name
    	path = "maps/test.pwn", -- map file path
    	int = 1,
    	dim = 2, -- dimension world of the objects
    	pos = {
	    	1395.462891,-17.192383,1001 -- x,y,z teleport location
	    }
	},
}