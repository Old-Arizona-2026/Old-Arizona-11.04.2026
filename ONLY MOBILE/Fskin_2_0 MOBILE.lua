script_name('Fskin 2.0')
script_author('Ranty')
script_description('https://www.youtube.com/@rantyck')


local favskin = 0;

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

	sampRegisterChatCommand("fskin", nsc_cmd)
	sampAddChatMessage("{00ff00}[Fskin {ff0000}2.0{00ff00}]: {00ffff}SkinChanger 2.0 loaded.", -1)
	sampAddChatMessage("{00ff00}[Fskin {ff0000}2.0{00ff00}]: {00ffff}Use - {ff0000}/fskin ID", -1)

	while true do
		wait(100)
		if favskin ~= 0 then
			local nowskinid = getCharModel(PLAYER_PED)
			if nowskinid ~= favskin then
				local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
				set_player_skin(id, favskin)
				sampAddChatMessage("{00ff00}[Fskin {ff0000}2.0{00ff00}]: {00ffff}Successfully!", -1)
			end
		end

	end

end

function nsc_cmd( arg )

	if #arg == 0 then
		sampAddChatMessage("/fskin ID",-1)
	else
		local skinid = tonumber(arg)
		if skinid == 0 then
			favskin = 0
		else
			favskin = skinid
			local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			set_player_skin(id, favskin)
			sampAddChatMessage("{00ff00}[Fskin {ff0000}2.0{00ff00}]: {00ffff}Successfully!", -1)
		end
	end
end

function set_player_skin(id, skin)
	local BS = raknetNewBitStream()
	raknetBitStreamWriteInt32(BS, id)
	raknetBitStreamWriteInt32(BS, skin)
	raknetEmulRpcReceiveBitStream(153, BS)
	raknetDeleteBitStream(BS)
end
