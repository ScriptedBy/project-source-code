--// Manages the crate system, including purchases, inventory limits, randomized rewards, game passes, item trading, and currency updates.

local Players = game:GetService("Players");
local HttpService = game:GetService("HttpService");
local RunService = game:GetService("RunService");
local MarketPlaceService = game:GetService("MarketplaceService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local CreateEvent = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]["Create"];
local UpdateLevels = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]:WaitForChild("Update Levels");
local UpdateCurrency = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]:WaitForChild("Update Currency");
local DisplayOpenEvent = ReplicatedStorage.Remotes["Remote Events"]["Display Open"];
local BuyCrate = ReplicatedStorage.Remotes["Remote Functions"]["Buy Crate"];
local HandleEvent = ReplicatedStorage:WaitForChild("Remotes")["Remote Functions"]["Handle"];
local CheckRewards = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]:WaitForChild("Check Rewards");

local ServerPets = workspace:WaitForChild("Pets"):WaitForChild("ServerPets");
local CaseFolder = workspace:WaitForChild("Cases");

local _Service = require(ReplicatedStorage.Modules.Contents.__Service);
local _Defenders = require(ReplicatedStorage.Modules.Contents.__Defenders);
local _Animations = require(ReplicatedStorage.Modules.Contents.__Animations);
local _Server = require(script.Parent.__Server);

local Crafting = { Normal = 1, Shiny = 2 };

local _Cases = {}

function HasPass(id, Player)
	if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, id) then
		return true
	end

	return false
end

function CheckPass(Player, id, which)
	if which == "Check" then
		return HasPass(id, Player);
	elseif which == "Prompt" then
		MarketPlaceService:PromptGamePassPurchase(Player, id);
	end
	return false
end


local function GetCurrentAmount(PlayerData)
	local Defenders = PlayerData.Inventory.Defenders.Contents
	local amount = 0
	for _, v in pairs(Defenders) do
		if type(v) == "table" then
			amount = amount + 1
		end
	end
	return amount
end

local function CheckInv(Player, Which, RobuxEgg)
	if RobuxEgg == true then return true end
	local AmountAdd
	
	if Which == "Buy3" then
		AmountAdd = 3
	else
		AmountAdd = 1
	end
	
	local ProfileModule = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
	local Data = ProfileModule[Player];
	local PlayerData = Data.Data.Data.Player
	local MaxStorage = PlayerData.Inventory.Defenders.MaxStorage
	local DefenderAmount = GetCurrentAmount(PlayerData)
	
	print(DefenderAmount, AmountAdd)
	if tonumber(DefenderAmount) == MaxStorage then
		return false
	elseif (tonumber(DefenderAmount) + tonumber(AmountAdd)) > MaxStorage then
		return false
	elseif (tonumber(DefenderAmount) + tonumber(AmountAdd)) == MaxStorage then
		return true
	elseif tonumber(DefenderAmount) < MaxStorage then
		return true
	end
	
	return false
end

function _Cases:OpenRobux(Player, CaseName, Which)
	print(Player, CaseName, Which)
	local ProfileModule = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
	local Data = ProfileModule[Player];
	local PlayerData = Data.Data.Data.Player
	
	if Player and CaseName ~= nil and Which ~= nil then
		if CheckInv(Player, Which, true) == true then
			if Which == "Buy1" then
				local Item = _Service:OpenCrate(Player, tostring(CaseName), "Buy1");
				if Item ~= nil then
					PlayerData.Cases = PlayerData.Cases + 1

					--LegendaryPetChatModule:SendMessage(plr, "Pet", tostring(pet), tostring(eggName))

					local Table = {};
					local New = _Service:AddIndex(Player, tostring(Item));
					local Shiny = _Service:GetShinyChance(Player, tostring(CaseName));
					--PetWebhook:SendWebhook(Player, tostring(Item), Shiny)
					if Shiny == true then
						_Service:AddItem(Player, {ItemName = tostring(Item), Shiny = "Corrupted"});
						Table =  {Item, New, true, false};
					else
						_Service:AddItem(Player, {ItemName = tostring(Item)});
						Table =  {Item, New, false, false};
					end

					spawn(function()
						DisplayOpenEvent:FireClient(Player, CaseName, "Open1", Table)
					end)
					print("Returned true")
					return true
				end
			else
				local Item, Item2, Item3 = _Service:OpenCrate(Player, CaseName, "Buy3");
				if Item ~= nil and Item2 ~= nil and Item3 ~= nil then
					--UpdateLeaderboard:FireAllClients(FormatLeaderboard());
					local Item, Item2, Item3 = _Service:OpenCrate(Player, CaseName, "Buy3");
					if Item ~= nil and Item2 ~= nil and Item3 ~= nil then
						PlayerData.Cases = PlayerData.Cases + 3
						local Tbl, Tbl2, Tbl3 = {}, {}, {}

						if Item ~= nil then
							print(Item)
							local New = _Service:AddIndex(Player, tostring(Item));
							local Shiny = _Service:GetShinyChance(Player, tostring(CaseName));
							--PetWebhook:SendWebhook(Player, tostring(Item), Shiny, Type)
							if Shiny == true then
								_Service:AddItem(Player, {ItemName = tostring(Item), Shiny = "Corrupted"});
								Tbl = {tostring(Item), New, true, false};
							else
								_Service:AddItem(Player, {ItemName = tostring(Item)});
								Tbl = {tostring(Item), New, false, false};
							end
						end

						if Item2 ~= nil then
							print(Item2)
							local New = _Service:AddIndex(Player, tostring(Item2));
							local Shiny = _Service:GetShinyChance(Player, tostring(CaseName));
							--PetWebhook:SendWebhook(Player, tostring(Item2), Shiny, Type)
							if Shiny == true  then
								_Service:AddItem(Player, {ItemName = tostring(Item2), Shiny = "Corrupted"});
								Tbl2 = {tostring(Item2), New, true, false};
							else
								_Service:AddItem(Player, {ItemName = tostring(Item2)});
								Tbl2 = {tostring(Item2), New, false, false};
							end
						end

						if Item3 ~= nil then
							print(Item3)
							local New = _Service:AddIndex(Player, tostring(Item3));
							local Shiny = _Service:GetShinyChance(Player, tostring(CaseName));
							--PetWebhook:SendWebhook(Player, tostring(Item3), Shiny, Type)
							if Shiny == true then
								_Service:AddItem(Player, {ItemName = tostring(Item3), Shiny = "Corrupted"});
								Tbl3 = {tostring(Item3), New, true, false};
							else
								_Service:AddItem(Player, {ItemName = tostring(Item3)});
								Tbl3 = {tostring(Item3), New, false, false};
							end
						end
						--UpdateLeaderboard:FireAllClients(FormatLeaderboard());
						--LoadItemsEvent:FireClient(Player, Data.Data, Type)
						local Table = {Tbl, Tbl2, Tbl3};
						spawn(function()
							DisplayOpenEvent:FireClient(Player, CaseName, "Open3", Table)
						end)
						print("Returned true")
						return true
					end
				end
			end
		end
	end

end

function _Cases:RemoveCurrency(Player, Currency, Amount)
	local ProfileModule = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
	local Data = ProfileModule[Player];
	if Data ~= nil then
		if Amount ~= nil then
			Data.Data.Data.Player[Currency] -= Amount;
		end
		return Data;
	end
end

function _Cases:OpenCrate(Player, CaseName, Which)
	print(Player, CaseName, Which)

	local ProfileModule = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
	local Data = ProfileModule[Player];
	local PlayerData = Data.Data.Data.Player
	
	if Player and CaseName ~= nil and Which ~= nil then
		if CheckInv(Player, Which, false) == true then
			
			
			local CanOpen = _Service:GetCanOpen(Player, CaseName);
			if CanOpen == true then
				if _Service:GetClosest(Player, tostring(CaseName)) == true then
					print("true")
					if Which == "Buy1" then
						local Cost, Currency = _Service:GetCost(tostring(CaseName));
						local Status = _Service:GetPlayerCurrency(Player, Currency);
						print(Status, Cost, Currency)
						if tonumber(Status) >= tonumber(Cost) then
							print(Currency)
							_Cases:RemoveCurrency(Player, Currency, Cost);
							local Item = _Service:OpenCrate(Player, tostring(CaseName), "Buy1");
							if Item ~= nil then
								PlayerData.Cases = PlayerData.Cases + 1
								-- Auto delete
								local Table = {};
								local New = _Service:AddIndex(Player, tostring(Item));
								local Shiny = _Service:GetShinyChance(Player, tostring(CaseName));
								--PetWebhook:SendWebhook(Player, tostring(Item), Shiny, Type)
								--UpdateLeaderboard:FireAllClients(FormatLeaderboard());
								if Shiny == true then
									_Service:AddItem(Player, {ItemName = tostring(Item), Shiny = "Corrupted"});
									return {Item, New, true, false};
								else
									_Service:AddItem(Player, {ItemName = tostring(Item)});
									return {Item, New, false, false};
								end

								--LoadItemsEvent:FireClient(Player, Data.Data, Type)

								--[[spawn(function()
									DisplayHatchEvent:FireClient(Player, EggName, "Open1", PetTable)
								end)
								return true]]
							end

						else
							local AmountNeeded = tonumber(Cost) - tonumber(Status);
							return {"Need Currency", tostring(Currency), AmountNeeded};
						end
					elseif Which == "Buy3" then
						if CheckPass(Player, 199493120, "Check") == true then
							-- Check if own gamepass
							local Cost, Currency = _Service:GetCost(tostring(CaseName));
							local Status = _Service:GetPlayerCurrency(Player, Currency);
							local NewCost = tonumber(Cost) * 3
							if tonumber(Status) >= tonumber(NewCost) then
								print("passes`")
								_Cases:RemoveCurrency(Player, Currency, NewCost);
								--UpdateLeaderboard:FireAllClients(FormatLeaderboard());
								local Item, Item2, Item3 = _Service:OpenCrate(Player, tostring(CaseName), "Buy3");
								if Item ~= nil and Item2 ~= nil and Item3 ~= nil then
									
									PlayerData.Cases = PlayerData.Cases + 3
									local Tbl, Tbl2, Tbl3 = {}, {}, {}

									if Item ~= nil then
										print(Item)
										local New = _Service:AddIndex(Player, tostring(Item));
										local Shiny = _Service:GetShinyChance(Player, tostring(CaseName));
										--PetWebhook:SendWebhook(Player, tostring(Item), Shiny)
										if Shiny == true  then
											_Service:AddItem(Player, {ItemName = tostring(Item), Shiny = "Corrupted"});
											Tbl = {tostring(Item), New, true, false};
										else
											_Service:AddItem(Player, {ItemName = tostring(Item)});
											Tbl = {tostring(Item), New, false, false};
										end
									end
									print(Tbl, Tbl2, Tbl3)
									if Item2 ~= nil then
										print(Item2)
										local New = _Service:AddIndex(Player, tostring(Item2));
										local Shiny = _Service:GetShinyChance(Player, tostring(CaseName));
										if Shiny == true then
											--PetWebhook:SendWebhook(Player, tostring(Item2), Shiny, Type)
											_Service:AddItem(Player, {ItemName = tostring(Item2), Shiny = "Corrupted"});
											Tbl2 = {tostring(Item2), New, true, false};
										else
											_Service:AddItem(Player, {ItemName = tostring(Item2)});
											Tbl2 = {tostring(Item2), New, false, false};
										end
									end

									if Item3 ~= nil then
										print(Item3)
										local New = _Service:AddIndex(Player, tostring(Item3));
										local Shiny = _Service:GetShinyChance(Player, tostring(CaseName));
										--PetWebhook:SendWebhook(Player, tostring(Item3), Shiny, Type)
										if Shiny == true then
											_Service:AddItem(Player, {ItemName = tostring(Item3), Shiny = "Corrupted"});
											Tbl3 = {tostring(Item3), New, true, false};
										else
											_Service:AddItem(Player, {ItemName = tostring(Item3)});
											Tbl3 = {tostring(Item3), New, false, false};
										end
									end
									--UpdateLeaderboard:FireAllClients(FormatLeaderboard());
									--LoadItemsEvent:FireClient(Player, Data.Data, Type)
									return Tbl, Tbl2, Tbl3
								end
							else
								local AmountNeeded = tonumber(Cost) - tonumber(Status);
								return {"Need Currency", tostring(Currency), AmountNeeded};
							end
						else
							print("gamepass neeeded")
							return "Need Pass"
						end
					end
				else
					return "Distance Nil"
				end
			end
		else 
			return "Max"
		end
	end
end

function _Cases:GetStatusData(Data, ID)
	if Data ~= nil and ID ~= nil then
		local Inventory = Data.Data.Player.Inventory.Defenders.Contents;
		if Inventory ~= nil then
			for i, v in pairs(Inventory) do
				if type(v) == "table" then
					if v[1] ~= nil then
						local ItemID = v[1];
						if ItemID == ID then
							--print(v[1])
							return v;
						end
					end
				end
			end
		end
	end
end

function _Cases:CheckEquip(Data)
	local MaxEquipped = Data.Data.Data.Player.Inventory.Defenders.MaxEquipped;
	local AmountEquipped = (function()
		local Defenders = Data.Data.Data.Player.Inventory.Defenders.Contents;
		local Amount = 0;
		for i, v in pairs(Defenders) do
			if type(v) == "table" then
				if v[3] == true then
					Amount = Amount + 1;
				end
			end
		end
		return Amount;
	end)()
	if (tonumber(AmountEquipped) + 1) > tonumber(MaxEquipped) then
		return false
	end
	return true
end



local function GetMultiplier(Status, Level, Shiny)
	--[[local ignore = {};
	if table.find(ignore, Status) then
		local CoinMul, RagdollMul, ThirdCurrency = Status.Coins, Status.Ragdolls, (status[Thrid status here])
	end]]
	print(Status, Level, Shiny)
	local TokenMul, ExpMul = Status.Buffs.Tokens, Status.Buffs.Experience;
	local Mul = Crafting[tostring(Shiny)];
	if Mul == nil then
		warn("No Craft Multiplier")
		Mul = 1;
	end

	local LevelMul =  (tonumber(Level) * 0.1) + 1;
	if tonumber(LevelMul) < 1 then LevelMul = 1 end

	TokenMul = TokenMul * tonumber(LevelMul) * tonumber(Mul);
	ExpMul = ExpMul * tonumber(LevelMul) * tonumber(Mul);

	return TokenMul, ExpMul;

end

local GetName = function(Name)
	if string.sub(tostring(Name), 1, 5) == "Corrupted" then
		return string.sub(tostring(Name), 7), "Corrupted"
	end
	return tostring(Name), "Normal"
end


function _Cases:GetStatus(Name)
	local rName, Type = GetName(Name);
	if _Defenders[rName] == nil then
		warn("No pet status for pet with name of" .. tostring(Name));
		return _Defenders["Security Toilet"];
	end
	return _Defenders[rName];
end

function _Cases:GetTotalStatus(Data)
	local TotalTokenMul, TotalExpMul = 0,0
	local Defenders = Data.Inventory.Defenders.Contents;
	for _, v in pairs(Defenders) do
		if type(v) == "table" then
			local Name, Shiny, Level = v[2], v[6], v[4]
			if v[3] == true and Name ~= nil and Shiny ~= nil and Level ~= nil then
				local Status = _Cases:GetStatus(Name)
				local TokenMul, ExpMul = GetMultiplier(Status, Level, Shiny)
				TotalTokenMul = TotalTokenMul + TokenMul
				TotalExpMul = TotalExpMul + ExpMul
			end
		end
	end
	if TotalTokenMul >= 1 and TotalExpMul >= 1 then
		return TotalTokenMul, TotalExpMul;
	else
		return nil
	end
end

function _Cases:Trade(PlayerWhoHadName, PlayerWhoGetsName, ItemName, ItemID)
	if ItemName ~= nil and ItemID ~= nil then
		local plr1 = Players:FindFirstChild(tostring(PlayerWhoHadName))
		local plr2 = Players:FindFirstChild(tostring(PlayerWhoGetsName))
		if plr1 ~= nil and plr2 ~= nil then
			local ProfileModule = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
			local Data = ProfileModule[plr1];
			if _Defenders[ItemName] ~= nil then
				local ItemData = _Cases:GetStatusData(Data.Data, ItemID);
				if ItemData == nil then
					warn("No Pet data for pet with ID:", tostring(ItemID))
					return
				end
				local Shiny, Level = ItemData[6], ItemData[4]
				local deleted = _Service:DeleteItem(plr1, Data.Data, ItemID, ItemName, false, false)
				if deleted == true then
					if plr2 ~= nil then
						local added = _Service:AddItem(plr2, {
							ItemName = tostring(ItemName), 
							Shiny = (tostring(Shiny) or "Normal"), 
							Level = (tonumber(Level) or 1),
						})
						if added == true then
							return true
						end

					end
				end
			end
		end
	end
end

function _Cases:CheckItem(Data, Item)

	local Defenders = Data.Inventory.Defenders.Contents;
	for i, v in pairs(Defenders) do
		if type(v) == "table" then
			if v[2] == tostring(Item) then
				return true
			end
		end
	end
	
	return false
end

function _Cases:AddItem(Player, Data, Item, Shiny, Type)
	if Type == "Gamepass" then
		if _Defenders[tostring(Item)] ~= nil then
			if CheckPass(Player, 199501207, "Check") == true then
				if _Cases:CheckItem(Data, Item) == false then
					_Service:AddItem(Player, {ItemName = tostring(Item), Shiny = Shiny});
				end
			end
		end
		
	else
		if _Defenders[tostring(Item)] ~= nil then
			if _Cases:CheckItem(Data, Item) == false then
				_Service:AddItem(Player, {ItemName = tostring(Item), Shiny = Shiny});
			end
		end
		
	end

end

function _Cases:AddAmtEquip(plr, Which)
	local ProfileModule = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
	local Data = ProfileModule[plr];
	
	if Which == "Bought" then
		Data.Data.Data.Player.Inventory.Defenders.MaxEquipped = 5
	elseif Which == "Check" then
		if CheckPass(plr, 200777907, "Check") == true then
			Data.Data.Data.Player.Inventory.Defenders.MaxEquipped = 5
		end
	end
	
end

function _Cases:AddAmount(plr, Amount, Type)
	local ProfileModule = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
	local Data = ProfileModule[plr];
	local PlayerData = Data.Data.Data.Player;
	
	if PlayerData[Type] ~= nil then
		PlayerData[Type] = PlayerData[Type] + Amount
		UpdateCurrency:FireClient(plr, Type, Amount)
		return true
	end
	
	return nil
end

function _Cases:Int()
	BuyCrate.OnServerInvoke = function(...)
		return _Cases:OpenCrate(...)
	end
	HandleEvent.OnServerInvoke = function(...)
		return _Service:Handle(...)
	end
	CheckRewards.OnServerEvent:Connect(function(...)
		_Server:GetPlaytimeRewards(...)
	end)
	
end

return _Cases;
