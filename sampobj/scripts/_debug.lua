--[[
	In this script you can enable debug messages for client or server side scripts.
	Very useful when trying to find why your map didn't load the way you expected it.


	This resource comes with the following default configuration:
	
	Clientside debug messages -> chatbox
	Serverside debug messages -> debugbox

	^ Allows you to distinguish both easily.
]]

DEBUG = {
	-- CLIENTSIDE
	client_dbox = false, 	-- [true/false] print to client's debug box
	client_chat = true, 	-- [true/false] print to chat
	
	-- SERVERSIDE
	server_dbox = true, 	-- [true/false] print to server's debug box
	server_chat = false, 	-- [true/false] print to every player's chat
}


-- Optional: enable /tdo automatically on startup
TDO_AUTO = false

-- Optional: enable async debug mode
ASYNC_DEBUG = false










---------------------------------------------------------------------------------------------------------
-- 	outputDebugString was rewritten to output to debug and/or chatbox at the same time, if you enabled it
_outputDebugString = outputDebugString

if isElement(localPlayer) then
	function outputDebugString( text, level, r, g, b )
		
		level = tonumber(level) or 3
		r = tonumber(r) or 255
		g = tonumber(g) or 255
		b = tonumber(b) or 255
		
		if DEBUG.client_dbox then
			_outputDebugString( text, level, r, g, b )
		end
		if DEBUG.client_chat then
			local leveltext = ""
			if level == 1 then
				leveltext = "[ERROR] "
				r,g,b = 255,50,50
			elseif level == 2 then
				leveltext = "[WARNING] "
				r,g,b = 255, 210, 77
			elseif level == 3 then
				leveltext = "[INFO] "
				r,g,b = 50,255,50
			end
			text = leveltext.."#ffffff"..text
			outputChatBox( text, r, g, b, true )
		end
	end
else
	function outputDebugString( text, level, r, g, b )

		level = tonumber(level) or 3
		r = tonumber(r) or 255
		g = tonumber(g) or 255
		b = tonumber(b) or 255
		
		if DEBUG.server_dbox then
			_outputDebugString( text, level, r, g, b )
		end
		if DEBUG.server_chat then
			local leveltext = ""
			if level == 1 then
				leveltext = "[ERROR] "
				r,g,b = 255,50,50
			elseif level == 2 then
				leveltext = "[WARNING] "
				r,g,b = 255, 210, 77
			elseif level == 3 then
				leveltext = "[INFO] "
				r,g,b = 50,255,50
			end
			text = leveltext.."#ffffff"..text
			outputChatBox( text, root, r, g, b, true )
		end
	end
end

function outputFatalError(text)
	local r,g,b = 255,0,0
	_outputDebugString( text, 1, r, g, b )
	if isElement(localPlayer) then
		outputChatBox( text, r, g, b, true )
	else
		outputChatBox( text, root, r, g, b, true )
	end
end