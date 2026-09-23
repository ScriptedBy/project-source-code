--// Rewards players with in-game currency when invited friends join, while tracking previously rewarded invitations to prevent duplicates.

local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ProfileService = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
local UpdateCurrency = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]:WaitForChild("Update Currency")
local Invite = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]["Invite"];

local _Invites = {}

function GiveReward(Player, PlayerData)
	if PlayerData ~= nil then
		if PlayerData.Coins ~= nil and PlayerData.Diamonds ~= nil then
			local CoinAmount = math.random(100000, 200000)
			local DiamondAmount =  math.random(10000, 20000)
			PlayerData.Coins = PlayerData.Coins + CoinAmount
			PlayerData.Diamonds = PlayerData.Diamonds + DiamondAmount
			UpdateCurrency:FireClient(Player, "Coins", CoinAmount)
			UpdateCurrency:FireClient(Player, "Diamonds", DiamondAmount)
			Invite:FireClient(Player,"Coins", "Diamonds", CoinAmount, DiamondAmount)
		end
		
	end
end


function _Invites:Int(newPlayer)
	--Players.PlayerAdded:Connect(function(newPlayer) 
		for i, v in pairs(game.Players:GetPlayers()) do
			local Data = ProfileService[game.Players[tostring(v)]];
			local PlayerData = Data.Data.Data.Player

			if not v:IsFriendsWith(newPlayer.UserId) then
				continue -- skips the current play from GetPlayers and moves on
			end 

			if not table.find(PlayerData.Invites, newPlayer.UserId) and v:IsFriendsWith(newPlayer.UserId) then
				GiveReward(v, PlayerData)
				table.insert(PlayerData.Invites, newPlayer.UserId)
			end
		end
	--end)

end



return _Invites;
