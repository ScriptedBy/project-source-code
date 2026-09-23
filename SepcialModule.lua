--// Manages defender special abilities by calculating damage scaling, validating charge requirements, and activating combat effects.

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ProfileService = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
local _Animations = require(ReplicatedStorage.Modules.Contents.__Animations);
local _Defenders = require(ReplicatedStorage.Modules.Contents.__Defenders);
local _Abbreviation = require(ReplicatedStorage.Modules.Contents.__Abbreviation);
local _Specialties = require(ReplicatedStorage.Modules.Contents.__Specialties);

local CheckSpecial = ReplicatedStorage.Remotes["Remote Events"]["Check Special"]

local CRAFTING = { Normal = 1, Shiny = 2 };

local _Special = {}

function GetDamageData(Data)
	local TableToSort = {}

	if Data ~= nil then
		local Inventory = Data.Inventory.Defenders.Contents;
		if Inventory ~= nil then
			for i, v in pairs(Inventory) do
				if type(v) == "table" then
					if v[1] ~= nil then
						table.insert(TableToSort, _Defenders[v[2]].Damage)

					end
				end
			end
		end
	end
	return math.max(unpack(TableToSort))
end

local function GetStatus(Name)
	if _Defenders[Name] == nil then
		warn("No pet status for pet with name of" .. tostring(Name));
		return _Defenders["Security Toilet"];
	end
	return _Defenders[Name];
end

local function GetMultiplier(Status, Level, Shiny, plr)
	--[[local ignore = {};
	if table.find(ignore, Status) then
		local CoinMul, RagdollMul, ThirdCurrency = Status.Coins, Status.Ragdolls, (status[Thrid status here])
	end]]

	print(Status, Level, Shiny)
	local TokenMul, ExpMul, DamageMul, ReloadMul, Rarity, ItemName = Status.Tokens, Status.XP, Status.Damage, Status.Reload, Status.Rarity, Status.Name;
	local Mul = CRAFTING[tostring(Shiny)];
	if Mul == nil then
		warn("No Craft Multiplier")
		Mul = 1;
	end

	local Data = ProfileService[game.Players[plr.Name]];
	local PlayerData = Data.Data.Data.Player
	local GetHighestDamage = GetDamageData(PlayerData)


	local PetLevel=  (tonumber(Level) * 0.1) + 1;
	if tonumber(PetLevel) < 1 then PetLevel = 1 end

	if Rarity == 6 then
		DamageMul = GetHighestDamage * _Defenders[ItemName].Damage 
	end

	if Level > 1 then
		TokenMul = TokenMul * PetLevel * Mul;
		ExpMul = ExpMul * PetLevel * Mul;
		DamageMul = DamageMul * PetLevel * Mul;
		ReloadMul = ReloadMul / (PetLevel * Mul)
	end

	print(ExpMul)
	return  _Abbreviation:RoundDecimals(DamageMul, 2);

end


local function UseSpecial(plr, v)
	local MultiplierStatus = GetStatus(v.ItemName.Value);
	local Damage = GetMultiplier(MultiplierStatus, v.Level.Value, v.Shiny.Value, plr);

	if _Defenders[v.ItemName.Value].Rarity == 6 then
		_Specialties[_Defenders[v.ItemName.Value].Specialties[2]]("Battle", plr, Damage)
	elseif _Defenders[v.ItemName.Value].Rarity == 5 then
		_Specialties[_Defenders[v.ItemName.Value].Specialties[1]]("Battle", plr, Damage)
	else
		_Specialties[_Defenders[v.ItemName.Value].Specialties[1]]("Battle", plr)
	end
	
	
end

local Debounce = false


function _Special:Int()
	
	CheckSpecial.OnServerEvent:Connect(function(plr, obj)
		print(plr, obj)
		for i, v in pairs(workspace.Pets.ServerPets[plr.Name]:GetChildren()) do
			if v.Name == obj then
				print(plr, obj)
				if v:FindFirstChild("Special").Value >= _Defenders[v.ItemName.Value].Special then
					if Debounce == false then
						Debounce = true
						print(plr, obj)
						v:FindFirstChild("Special").Value = 0
						UseSpecial(plr, v)
						Debounce = false
					end
				end
			end
		end
	end)
end

return _Special
