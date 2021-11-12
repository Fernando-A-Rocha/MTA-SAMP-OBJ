--[[
	List of maps to load on startup in scripts/loader.lua

	Required settings for each map:
	
	 - autoload: load map on startup or not
	 - id: arbitrary ID
	 - name: arbitrary custom name
	 - path: map file path
	 - int: interior world of the objects
	 - dim: dimensiom world of the objects
	 - pos: x,y,z teleport position
]]



mapList = {
    {
    	autoload = false,
    	id = 1,
    	name = "Office",
    	path = "maps/test2.pwn",
    	int = 1,
    	dim = 2,
    	pos = { 1928.7041015625, -343.6083984375, 50.75 },
	},
    {
    	autoload = false,
    	id = 2,
    	name = "Mansion",
    	path = "maps/test.pwn",
    	int = 1,
    	dim = 3,
    	pos = { 1395.462891,-17.192383,1001 },
	},
    {
    	autoload = true,
    	id = 3,
    	name = "VICTIM",
    	path = "maps/VICTIM.pwn",
    	int = 1,
    	dim = 4,
    	pos = { 1556.423828125, 1803.9453125, 1012.0983886719 },
	},
}