--// Validates redeemable codes, awards in-game currency, and prevents players from claiming the same reward multiple times.

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local CheckCodes = ReplicatedStorage.Remotes["Remote Functions"]["Check Codes"];
local UpdateCurrency = ReplicatedStorage.Remotes["Remote Events"]["Update Currency"];

local ProfileService = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);

local _Codes = {}

local List = {
	["FinishedTutorial!"] = {
		ItemType = "Currency",
		Amount = { Coins = 1500, Diamonds = 50 }
	}
}

function _Codes:CheckCode(Player, Text)
	local Data = ProfileService[Player];
	local PlayerData = Data.Data.Data.Player
	
	for a,b  in pairs(List) do
		if Text == a and not table.find(PlayerData.Inventory.Codes, Text) then
			if b.ItemType == "Currency" then
				print(Player, Text)
				if b.Amount.Coins ~= nil then
					PlayerData.Coins = PlayerData.Coins + b.Amount.Coins
					UpdateCurrency:FireClient(Player, "Coins", b.Amount.Coins)

				end
				if b.Amount.Diamonds ~= nil then
					PlayerData.Diamonds = PlayerData.Diamonds + b.Amount.Diamonds
					UpdateCurrency:FireClient(Player, "Diamonds", b.Amount.Diamonds)
				end
			end

			table.insert(PlayerData.Inventory.Codes, Text)
			return true
		end
	end

	return false
end

function _Codes:Int()
	CheckCodes.OnServerInvoke = (function(...)
		return _Codes:CheckCode(...)
	end)
end

return _Codes; 

