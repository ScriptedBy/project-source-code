--// Updates and manages XP, levels, prestige, and progression values for players and their defenders.


local _XP = {}

function _XP:AddXP(Player, PlayerData, PetID, XPData)
	
	for i, v in pairs(PlayerData) do 
		if type(PlayerData[i]) == "table" then
			for a, b in pairs(PlayerData[i]) do
				if a == "Defenders" then
					for c, d in pairs(PlayerData[i][a]) do
						if c == "Contents" then
							for e, f in pairs(PlayerData[i][a][c]) do
								local ID, XP, Level = f[1], f[5], f[4];
								if ID ~= nil and XP ~= nil and Level ~= nil then
									if ID == PetID then
										if XPData ~= nil and type(XPData) == "table" then
											local Type, XPAmount = XPData[1], XPData[2];
											print(XPData[2])
											if Type == "Add" and type(tonumber(XPAmount)) then
												PlayerData[i][a][c][e][5] = PlayerData[i][a][c][e][5] + tonumber(XPAmount);
											elseif Type == "Set" and type(tonumber(XPAmount)) then
												PlayerData[i][a][c][e][5] = tonumber(XPAmount)
											elseif Type == "Level" and type(tonumber(XPAmount)) then
												local Type2, LevelAmount = XPAmount[1], XPAmount[2];
												if Type2 == "Add" and type(tonumber(LevelAmount)) then
													PlayerData[i][a][c][e][4] = PlayerData[i][a][c][e][4] + tonumber(LevelAmount)
												elseif Type2 == "Set" and type(tonumber(LevelAmount)) then
													PlayerData[i][a][c][e][4] = tonumber(LevelAmount)
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end


function _XP:AddPlayerXP(Player, PlayerData, XPData)

	local ProfileService = require(game.ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);

	local PlayerXP = ProfileService[Player].Data.Data.Player.Experience;
	local Tokens = ProfileService[Player].Data.Data.Player.Coins;
	local Diamonds = ProfileService[Player].Data.Data.Player.Diamonds;

	if PlayerXP ~= nil and Tokens ~= nil and Diamonds ~= nil then
		local Type, XPAmount = XPData[1], XPData[2];

		if Type == "Add" and type(tonumber(XPAmount)) then
			ProfileService[Player].Data.Data.Player.Experience = ProfileService[Player].Data.Data.Player.Experience + tonumber(XPAmount);
		elseif Type == "Set" and type(tonumber(XPAmount)) then
			ProfileService[Player].Data.Data.Player.Experience = tonumber(XPAmount);
		elseif Type == "Subtract" and type(tonumber(XPAmount)) then
			ProfileService[Player].Data.Data.Player[Type] = ProfileService[Player].Data.Data.Player.Experience - tonumber(XPAmount);
		elseif Type == "Level" and type(tonumber(XPAmount)) then
			local Type2, LevelAmount = XPAmount[1], XPAmount[2];
			if Type2 == "Add" and type(tonumber(LevelAmount)) then
				ProfileService[Player].Data.Data.Player.Level = ProfileService[Player].Data.Data.Player.Level + tonumber(LevelAmount)
			elseif Type2 == "Set" and type(tonumber(LevelAmount)) then
				ProfileService[Player].Data.Data.Player.Level = tonumber(LevelAmount)
			end
		elseif Type == "Prestige" then
			local Type2, PrestigeAmount = XPAmount[1], XPAmount[2];
			if Type2 == "Add" and type(tonumber(PrestigeAmount)) then
				ProfileService[Player].Data.Data.Player.Prestige = ProfileService[Player].Data.Data.Player.Prestige + tonumber(PrestigeAmount)
			elseif Type2 == "Set" and type(tonumber(PrestigeAmount)) then
				ProfileService[Player].Data.Data.Player.Prestige = tonumber(PrestigeAmount)
			end
		else
			local Type2, Amount = XPAmount[1], XPAmount[2];
			if Type2 == "Add" and type(tonumber(Amount)) then
				ProfileService[Player].Data.Data.Player[Type] = ProfileService[Player].Data.Data.Player[Type] + tonumber(Amount)
			elseif Type2 == "Set" and type(tonumber(Amount)) then
				ProfileService[Player].Data.Data.Player[Type] = tonumber(Amount)
			end

		end
	end

end

return _XP;
