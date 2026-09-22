--// Manages player and defender progression by calculating XP requirements, processing level-ups, and synchronizing progression updates.


local ReplicatedStorage = game:GetService("ReplicatedStorage");

local UpdateLevel = ReplicatedStorage.Remotes["Remote Events"]:WaitForChild("Update Levels")
local UpdatePlayerData = ReplicatedStorage.Remotes["Remote Events"]:WaitForChild("Update Player Data");
local UpdateRank = ReplicatedStorage.Remotes["Remote Events"]:WaitForChild("Update Rank");

local _Defenders = require(ReplicatedStorage.Modules.Contents.__Defenders);
local _Service = require(ReplicatedStorage.Modules.Contents.__Service);
local _XP = require(script.__XP);

local TOP_LEVEL, MAX_LEVEL, MAX_PRESTIGE = 20, 5, 5;

local XP_RARITIES = { [0] = 250, [0.5] = 250, [1] = 250, [2] = 250, [3] = 250, [4] = 300, [5] = 400, [6] = 500 };
local CRAFTING = { Normal = 1, Corrupted = 2 };
local XP_REQUIRED = 2000;
local XP_PLAYER_REQ = 200

local _Level = {}

function _Level:GetXP(Level)
	return (Level ^ 2) * (XP_PLAYER_REQ * Level)
end

function _Level:GetOnlyLevel(XP)
	return math.floor(math.exp((math.log(XP/XP_REQUIRED))/1.5))
end

function _Level:GetStatus(Name)
	if _Defenders[Name] == nil then
		warn("No pet status for pet with name of" .. tostring(Name));
		return _Defenders["Security Toilet"];
	end
	return _Defenders[Name];
end

local GetXPLevel = function(PetName, Level, Shiny)
	if tonumber(Level) < 1 then Level = 1 end;
	Shiny = Shiny ~= nil and tostring(Shiny) or "Normal";

	local Status =  _Level:GetStatus(PetName);
	local Rarity = Status.Rarity;
	local LVL_TYPE_MUL = CRAFTING[tostring(Shiny)] or 1;
	if LVL_TYPE_MUL == nil then
		warn("No Craft Multiplier For ".. tostring(Shiny).." Shiny!")
		LVL_TYPE_MUL = 1;
	end
	if tonumber(LVL_TYPE_MUL) < 1 then LVL_TYPE_MUL = 1 end;
	if XP_RARITIES[Rarity] == nil then
		warn("No pet XP rarity amount for \"" .. tostring(Rarity) .. "!\"")
		return math.floor(100 * Level ^ 1.15) * LVL_TYPE_MUL;
	end

	local XP_MULTI = XP_RARITIES[Rarity];
	return math.floor(XP_MULTI * Level ^ 1.15) * LVL_TYPE_MUL;
end

local GetPetXPLevel = function(PetName, Level, Shiny)
	if tonumber(Level) < 1 then Level = 1 end;
	Shiny = Shiny ~= nil and tostring(Shiny) or "Normal";

	local Status =  _Level:GetStatus(PetName);
	local Rarity = Status.Rarity;
	local LVL_TYPE_MUL = CRAFTING[tostring(Shiny)] or 1;
	
	if tonumber(LVL_TYPE_MUL) < 1 then LVL_TYPE_MUL = 1 end;
	
	if XP_RARITIES[Rarity] == nil then
		warn("No pet XP rarity amount for \"" .. tostring(Rarity) .. "!\"")
		return math.floor(100 * Level ^ 1.25) * LVL_TYPE_MUL;
	end

	local XP_MULTI = XP_RARITIES[Rarity];
	return math.floor(XP_MULTI * Level ^ 1.25) * LVL_TYPE_MUL;
end

function UpdatePetLevels(Player)
	_Service:Handle(Player, "UpdateLevels", {})
end

local function Round(Number, Precision)
	local Places = (Precision) and (10^Precision) or 1
	return (((Number * Places) + 0.5 - ((Number * Places) + 0.5) % 1)/Places)
end

function GetNewXPAmount(Player, Data, Amount)
	local BASE = tonumber(Amount)
	local NewXPAmount = tonumber(BASE)
	local RoundedXP = Round(tonumber(NewXPAmount))
	if tonumber(RoundedXP) < 1 then RoundedXP = 1 end
	return tonumber(RoundedXP)
end

function _Level:AddXP(Player, Amount)
	spawn(function()
		local ProfileService = require(game.ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
		local Data = ProfileService[Player].Data.Data.Player;

		local AmountEquipped = (function()
			local Pets = Data.Inventory.Defenders.Contents;
			local Amount = 0;
			for i, v in pairs(Pets) do
				if type(v) == "table" then
					if v[3] == true then
						Amount = Amount + 1;
					end
				end
			end
			return Amount;
		end)()
		if tonumber(AmountEquipped) < 1 then
			AmountEquipped = 1
		end
		
		spawn(function()
			local NewAmount = GetNewXPAmount(Player, Data, Amount);
			local FinalAmount = math.ceil(tonumber(NewAmount) / tonumber(AmountEquipped));

			local Pets = Data.Inventory.Defenders.Contents;
			for i, v in pairs(Pets) do
				if type(v) == "table" then
					if v[3] == true then
						local Remaining = tonumber(FinalAmount);
						local PetName, PetLevel, PetID, Shiny = v[2], v[4], v[1], v[6];
						spawn(function()
							while true do
								--print("Added XP .. "..Remaining)
								if tonumber(PetLevel) >= TOP_LEVEL then
									_XP:AddXP(Player, Data, PetID, {"Level", {"Set", TOP_LEVEL}});
									_XP:AddXP(Player, Data, PetID, {"Set", 0});
									break
								end
								local XPNeeded = GetPetXPLevel(PetName, PetLevel, Shiny);
								local Difference = XPNeeded - v[5];

								if Remaining < Difference then 
									_XP:AddXP(Player, Data, PetID, {"Add", tonumber(Remaining)});
									break
								end
								Remaining = Remaining - Difference;
								_XP:AddXP(Player, Data, PetID, {"Level", {"Add", 1}});
								_XP:AddXP(Player, Data, PetID, {"Set", 0});
							end
						end)
					end
				end
			end

			spawn(function()
				UpdatePetLevels(Player);
			end)

			UpdateLevel:FireClient(Player);
		end)
		
	end)
end

function _Level:AddPlayerXP(Player, Amount, Type)
	--spawn(function()

		local ProfileService = require(game.ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
		local Data = ProfileService[Player].Data.Data.Player;

		local NewAmount = GetNewXPAmount(Player, Data, Amount);
		local FinalAmount = NewAmount
		local Remaining = tonumber(FinalAmount);
		
		--spawn(function()
			while true do
				--[[if tonumber(Data.Prestige) >= MAX_PRESTIGE then
					XPModule:AddPlayerXP(Player, ProfileService[Player].Data.Data.Player, {"Level", {"Set", 0}});
					XPModule:AddPlayerXP(Player, ProfileService[Player].Data.Data.Player, {"Prestige", {"Set", 10}});
					XPModule:AddPlayerXP(Player, ProfileService[Player].Data.Data.Player, {"Set", 0});
					break
				end]]
				if Type == "Experience" then
					if tonumber(Data.Level) >= MAX_LEVEL then
						_XP:AddPlayerXP(Player, ProfileService[Player].Data.Data.Player, {"Level", {"Set", MAX_LEVEL}});
						--XPModule:AddPlayerXP(Player, ProfileService[Player].Data.Data.Player, {"Prestige", {"Add", 1}});
						_XP:AddPlayerXP(Player, ProfileService[Player].Data.Data.Player, {"Set", 0});
						UpdateRank:FireClient(Player, ProfileService[Player].Data.Data.Player.Prestige);
						break
					end

					local XPNeeded = _Level:GetXP(Data.Level)
					local Difference = XPNeeded - ProfileService[Player].Data.Data.Player.Experience;
					if Remaining < Difference then
						_XP:AddPlayerXP(Player, ProfileService[Player].Data.Data.Player, {"Add", tonumber(Remaining)});
						break
					end
					Remaining = Remaining - Difference;
					_XP:AddPlayerXP(Player, ProfileService[Player].Data.Data.Player, {"Level", {"Add", 1}});
					_XP:AddPlayerXP(Player, ProfileService[Player].Data.Data.Player, {"Set", 0});
				else 
					_XP:AddPlayerXP(Player, ProfileService[Player].Data.Data.Player, {Type, {"Add", Amount}});
					break
				end

			end
		--end)

		UpdatePlayerData:FireClient(Player, ProfileService[Player].Data.Data.Player.Level, Remaining, Type);
	--end)
	
end

return _Level
