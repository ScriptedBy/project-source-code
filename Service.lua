--// Manages the defender system, including crate probabilities, inventory, equipping, upgrades, animations, stats, and item management.

local Players = game:GetService("Players");
local HttpService = game:GetService("HttpService");
local RunService = game:GetService("RunService");
local MarketPlaceService = game:GetService("MarketplaceService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local FetchClientData = ReplicatedStorage.Remotes["Remote Functions"]["Client Data"];
local ItemTable = ReplicatedStorage:WaitForChild("Remotes")["Remote Functions"]:WaitForChild("Item Table");
local CreateEvent = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]["Create"];
local LoadItemsEvent = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]:WaitForChild("Load Items");
local UpdateLevels = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]:WaitForChild("Update Levels");
local DisplayOpenEvent = ReplicatedStorage.Remotes["Remote Events"]["Display Open"];
local HandleEvent = ReplicatedStorage:WaitForChild("Remotes")["Remote Functions"]["Handle"];

local ServerPets = workspace:WaitForChild("Pets"):WaitForChild("ServerPets");
local CaseFolder = workspace:WaitForChild("Cases");

local _Crates = require(script.Parent.__Crates);
local _Defenders = require(script.Parent.__Defenders);
local _Animations = require(script.Parent.__Animations);
local _Abbreviation = require(script.Parent.__Abbreviation);
local BACKUP_ITEM = "Security Toilet";

local _Service = {}

local GetCopy = function(tab)
	local newTab = {};
	for i = 1, #tab do
		newTab[i] = { unpack(tab[i]) }
	end
	return newTab
end

local GetRarity = function(Name)
	if _Defenders[tostring(Name)] ~= nil then
		return _Defenders[tostring(Name)].Rarity
	end

	warn(tostring(Name).. " does not have a pet rarity!")
	return 1
end

local GetRandom = function(Rarities)
	local RNG = Random.new();
	local Counter = 0;
	for i, v in pairs(Rarities) do
		Counter += Rarities[i][2]
	end
	local Chosen = RNG:NextNumber(0, Counter);
	for i, v in pairs(Rarities) do
		Counter -= Rarities[i][2]
		if Chosen > Counter then
			return Rarities[i][1]
		end
	end
end

local GetIndex = function(Data, Name)
	local Index = Data.Data.Player.Inventory.Index or {};
	for i, v in pairs(Index) do
		if tostring(v) == tostring(Name) then
			return true;
		end
	end
	return false;
end

local id = function()
	return HttpService:GenerateGUID(false);
end


function HasPass(Player, id)
	if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, id) then
		return true
	end

	return false
end

function CheckPass(Player, id, which)
	if which == "Check" then
		return HasPass(Player, id);
	elseif which == "Prompt" then
		MarketPlaceService:PromptGamePassPurchase(Player, id);
	end
	return false
end

local function GetLuckPass(Player)
	return false
end

local function GetLuckBoost(Player)
	return false
end

local function GetLuckEvent()
	return {false, 2}
end

local function GetRarityIncrease(Player)
	local RarityIncrease = 1
	local luckPass = GetLuckPass(Player)
	local luckBoost = GetLuckBoost(Player)
	local luckEvent = GetLuckEvent()

	if CheckPass(Player, 199492272, "Check") == true then
		RarityIncrease = RarityIncrease * 2
	end
	--[[if luckBoost == true then
		RarityIncrease = RarityIncrease * 2
	end]]
	if luckEvent[1] == true then
		RarityIncrease = RarityIncrease * (luckEvent[2] or 1)
	end

	return RarityIncrease
end

local function GetNewChances(Player, Rarities)
	local RarityIncrease = GetRarityIncrease(Player);
	local New = GetCopy(Rarities);
	local Remove, Amount = 0, 0;

	for i = 1, #New do
		local Item = New[i];
		local Name = Item[1];
		local Rarity = GetRarity(Name)
		
		if Rarity >= 4 then
			Remove += Item[2] * (RarityIncrease - 1)
			Item[2] *= RarityIncrease
		else
			Amount += 1
		end
	end
	
	for i = 1, #New do
		local Item = New[i]
		local Name = Item[1]
		local Rarity = GetRarity(Name)
		
		if Rarity <= 3 then
			New[i][2] = New[i][2] - Remove / Amount;
		end
		
	end

	return New;
end

_Service.GetChances = function(Player, Name, Extra)
	print(Player, Name)
	if not Player then
		warn("Player Is Nil When Trying To Get Random Object!", tostring(Player));
		return {};
	elseif Name == nil or type(Name) ~= "string" then
		warn("Name Sent Is Nil When Trying To Get Random Object!", tostring(Name));
		return {};
	elseif _Crates[Name].Contents == nil then
		warn(tostring(Name).. " does not have a pet!");
		return {};
	end

	local Table = _Crates[Name].Contents;
	return GetNewChances(Player, Table);
end

_Service.Get_One_Pet = function(Extra, Player, CrateName)
	print(Player, CrateName, " Line 145")
	local Chances = _Service.GetChances(Player, tostring(CrateName));
	if Chances ~= nil then
		local Pet = GetRandom(Chances);
		if Pet ~= nil then
			return Pet;
		end
	end

	if _Crates[CrateName] ~= nil then
		return _Crates[CrateName];
	end

	warn("No Backup pet for", tostring(CrateName), "Egg!")
	return BACKUP_ITEM;
end

_Service.Get_Three_Pets = function(Extra, Player, Name)
	print(Player, Name)
	local Chances = _Service.GetChances(Player, tostring(Name));
	if Chances ~= nil then
		local Pet = GetRandom(Chances);
		local Pet2 = GetRandom(Chances);
		local Pet3 = GetRandom(Chances);

		if Pet ~= nil and Pet2 ~= nil and Pet3 ~= nil then
			print(Pet, Pet2, Pet3)
			return Pet, Pet2, Pet3;
		end
	end

	if _Crates[Name] ~= nil then
		return _Crates[Name];
	end

	warn("No Backup pet for", tostring(Name), "Egg!")
	return BACKUP_ITEM, BACKUP_ITEM, BACKUP_ITEM;
end                                            



function _Service:GetShinyChance(Player, EggName)

	local ShinyRNG = Random.new();
	local Shiny_Max = 10; -- 1/100 Chance
	local ShinyBoost = false -- Shiny Boost (5x)
	if CheckPass(Player, 199492731, "Check") == true then
		Shiny_Max = 5;
	end

	return ShinyRNG:NextInteger(1, Shiny_Max) == 1;

end

function _Service:GetAmount(Data)
	local Pets = Data.Data.Data.Player.Inventory.Defenders.Equipped;
	local Amount, AmountEquipped = 0, 0;
	for i, v in pairs(Pets) do
		if type(v) == "table" then
			AmountEquipped += 1;
		end
		Amount = Amount + 1
	end
	return Amount, AmountEquipped;
end



function _Service:GetClosest(Player, CrateName, Distance)
	local EggModel = CaseFolder:FindFirstChild(CrateName);
	local RequiredDistance = 12;

	if EggModel ~= nil then
		local CameraPart = EggModel:FindFirstChild("View");
		if CameraPart ~= nil then
			local partPOS = CameraPart.Position;
			local newDistance = Player:DistanceFromCharacter(partPOS);
			local Distance = Distance ~= nil and Distance or RequiredDistance;
			if newDistance <= Distance then
				return true;
			end
		end
	end
	return false;
end

function _Service:GetCanOpen(Player, Name)
	if Player and Name ~= nil then
		-- add a security to the egg, like check if the player has a world/land/area
		return true
	end 
	return false
end

function _Service:GetCost(CrateName)
	local Status = _Crates[CrateName];
	local Cost = Status.Cost;

	if Status ~= nil then
		return tonumber(Cost[2]), tostring(Cost[1])
	end

	return 0, "nil"
end

function _Service:GetPlayerCurrency(Player, Currency)
	local ProfileModule = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
	local Data = ProfileModule[Player];
	local Amount = Data.Data.Data.Player[Currency];
	return tonumber(Amount);
end

function _Service:AddIndex(Player, ItemName)
	local ProfileModule = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
	local Data = ProfileModule[Player];
	local PetIndex = Data.Data.Data.Player.Inventory.Index;
	if PetIndex == nil then
		Data.Data.Data.Player.Inventory.Index = {};
		PetIndex = Data.Data.Data.Player.Inventory.Index;
	end
	if GetIndex(Data.Data, tostring(ItemName)) == false then
		table.insert(PetIndex, tostring(ItemName));
		return true;
	end
	return false;
end

function _Service:OpenCrate(Player, CrateName, Which)
	if Player and CrateName ~= nil and Which ~= nil then
		if Which == "Buy1" then

			local Pet = _Service:Get_One_Pet(Player, CrateName);
			return Pet;
		elseif Which == "Buy3" then
			local Pet, Pet2, Pet3 = _Service:Get_Three_Pets(Player, CrateName);
			return Pet, Pet2, Pet3;
		end
	end
end


function _Service:ReturnPetData(ItemName, Equip, Shiny, Level, Tradeable)
	return {
		[1] = id(); 
		[2] = ItemName;
		[3] = Equip or false;
		[4] = (tonumber(Level) or 1); 
		[5] = 0;
		[6] = Shiny;
		--[7] = Tradeable;
	}	
	
end

local XP_RARITIES = { [1] = 100, [2] = 100, [3] = 200, [4] = 300, [5] = 400, [6] = 500 };
local CRAFTING = { Normal = 1, Shiny = 2 };


function GetTotalData(Data)
	local TokenTable, XPtable = {}, {}
	if Data ~= nil then
		local Inventory = Data.Inventory.Defenders.Contents;
		if Inventory ~= nil then
			for i, v in pairs(Inventory) do
				if type(v) == "table" then
					if v[1] ~= nil then
						table.insert(TokenTable, _Defenders[v[2]].Tokens)
						table.insert(XPtable, _Defenders[v[2]].XP)

					end
				end
			end
		end
	end
	return math.max(unpack(TokenTable)), math.max(unpack(XPtable))
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

	local ProfileService = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);

	local Data = ProfileService[game.Players[plr.Name]];
	local PlayerData = Data.Data.Data.Player
	local GetHighestToken, GetHighestXP = GetTotalData(PlayerData);


	local PetLevel=  (tonumber(Level) * 0.1) + 1;
	if tonumber(PetLevel) < 1 then PetLevel = 1 end

	if Rarity == 6 then
		TokenMul = GetHighestToken * _Defenders[ItemName].Tokens 
		ExpMul = GetHighestXP * _Defenders[ItemName].XP 
	end

	if Level > 1 then
		TokenMul = TokenMul * PetLevel * Mul;
		ExpMul = ExpMul * PetLevel * Mul;
		DamageMul = DamageMul * PetLevel * Mul;
		ReloadMul = ReloadMul / (PetLevel * Mul)
	else
		TokenMul = TokenMul * Mul;
		ExpMul = ExpMul * Mul;
		DamageMul = DamageMul * Mul;
		ReloadMul = ReloadMul / Mul
	end
	print(ExpMul)
	return _Abbreviation:RoundDecimals(TokenMul, 2), _Abbreviation:RoundDecimals(ExpMul, 2), _Abbreviation:RoundDecimals(DamageMul, 2),  _Abbreviation:RoundDecimals(ReloadMul, 2);

end

local function GetStatus(Name)
	if _Defenders[Name] == nil then
		warn("No pet status for pet with name of" .. tostring(Name));
		return _Defenders["Security Toilet"];
	end
	return _Defenders[Name];
end


function MakeFolder(plr, ItemName, ID, Shiny, Level, Defender)
	print(ItemName, ID, Shiny, Level)

	local ServerFolder = ServerPets:WaitForChild(plr.Name)

	local Fol = Instance.new("Folder") 
	Fol.Name = ID
	Fol.Parent = ServerFolder
	Defender.Parent = Fol

	local IndexVal = Instance.new("NumberValue")
	IndexVal.Name = "IndexPos"
	IndexVal.Parent = Fol

	local SelectedVal = Instance.new("StringValue")
	SelectedVal.Name = "Selected"
	SelectedVal.Value = "None"
	SelectedVal.Parent = Fol

	local NameVal = Instance.new("StringValue")
	NameVal.Name = "ItemName" 
	NameVal.Value = tostring(ItemName)
	NameVal.Parent = Fol

	local Handler = script.Handler:Clone()
	local SpecialDisplay = script.SpecialDisplay:Clone()

	SpecialDisplay.Name = ID
	SpecialDisplay.Adornee = Defender
	SpecialDisplay.Parent = game.Players[plr.Name].PlayerGui.ScreenGui.UI.SpecialUI

	if _Defenders[ItemName].Specialties ~= nil then
		local Special = Instance.new("NumberValue")
		Special.Name = "Special" 
		Special.Value = ID
		Special.Parent = Fol

		Handler.Parent = Defender
		Handler.Enabled = true
	end

	if Shiny == "Corrupted" then
		for i, v in pairs(Defender:WaitForChild("HumanoidRootPart").Corrupted:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			end
		end

	end

	local IDVal = Instance.new("StringValue")
	IDVal.Name = "ID" 
	IDVal.Value = ID
	IDVal.Parent = Fol

	Shiny = Shiny ~= nil and tostring(Shiny) or "Normal"
	local ShinyFol = Instance.new("StringValue")
	ShinyFol.Name = "Shiny" 
	ShinyFol.Value = tostring(Shiny)
	ShinyFol.Parent = Fol

	Level = Level ~= nil and tonumber(Level) or 1
	local levelFol = Instance.new("NumberValue")
	levelFol.Name = "Level" 
	levelFol.Value = tonumber(Level)
	levelFol.Parent = Fol

	
	spawn(function()
		while wait() do
			for i, v in pairs(ServerFolder:GetChildren()) do
				v.IndexPos.Value = i
			end
		end
	end)
	--[[
	for i, v in pairs(ServerFolder:GetChildren()) do
		for a, b in pairs(v:GetChildren()) do
			print(b)
		end
		Total_Tokens.Value = Total_Tokens.Value + v.Coins.Value
		TotalExp.Value = TotalExp.Value + v.Experience.Value
	end]]

	return Fol
end
--[[
function MakeFolder(plr, ItemName, ID, Shiny, Level)
	print(ItemName, ID, Shiny, Level)
	
	local ServerFolder = ServerPets:FindFirstChild(plr.Name)
	
	local Fol = Instance.new("Folder") 
	Fol.Name = ID
	
	local Animations = Instance.new("Folder")
	Animations.Name = "Animations"
	Animations.Parent = Fol
	
	for i, v in pairs(_Animations[ItemName]) do
		local Animation = Instance.new("Animation");
		Animation.Name = i
		Animation.AnimationId = v
		Animation.Parent = Animations
	end
	
	local Defender = ReplicatedStorage.Assets.Defenders[tostring(ItemName)]:Clone();
	Defender.Parent = Fol
	
	if Shiny == "Corrupted" then
		for i, v in pairs(Defender:WaitForChild("HumanoidRootPart").Corrupted:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			end
		end
		
	end
	
	--_Service:LoadAnims(plr, Defender)
	
	local IndexVal = Instance.new("NumberValue")
	IndexVal.Name = "IndexPos"
	for i, v in pairs(ServerFolder:GetChildren()) do
		IndexVal.Value = i
	end
	IndexVal.Parent = Fol
	
	local SelectedVal = Instance.new("StringValue")
	SelectedVal.Name = "Selected"
	SelectedVal.Value = "None"
	SelectedVal.Parent = Fol
	
	local NameVal = Instance.new("StringValue")
	NameVal.Name = "ItemName" 
	NameVal.Value = tostring(ItemName)
	NameVal.Parent = Fol

	local IDVal = Instance.new("StringValue")
	IDVal.Name = "ID" 
	IDVal.Value = ID
	IDVal.Parent = Fol

	Shiny = Shiny ~= nil and tostring(Shiny) or "Normal"
	local ShinyFol = Instance.new("StringValue")
	ShinyFol.Name = "Shiny" 
	ShinyFol.Value = tostring(Shiny)
	ShinyFol.Parent = Fol

	Level = Level ~= nil and tonumber(Level) or 1
	local levelFol = Instance.new("NumberValue")
	levelFol.Name = "Level" 
	levelFol.Value = tonumber(Level)
	levelFol.Parent = Fol

	
	Fol.Parent = ServerFolder
	return Fol
end]]

function _Service:LoadItemsEquipped(Player)
	local ProfileModule = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
	local Data = ProfileModule[Player];
	local Inventory = Data.Data.Data.Player.Inventory;

	local Pets = Inventory.Defenders.Contents;
	for _, v in pairs(Pets) do
		if type(v) == "table" then
			if v[3] == true then
				local Name, ID = v[2], v[1]
				local Evolution = v[6] or "Normal"
				local level = v[4] or 1
				
				local Defender = ReplicatedStorage.Assets:WaitForChild("Defenders"):WaitForChild(tostring(Name)):Clone();
				Defender.PrimaryPart.CFrame = workspace:WaitForChild(Player.Name).HumanoidRootPart.CFrame + Vector3.new(0, 0, 3)
				MakeFolder(Player, Name, ID, Evolution, level, Defender)

				_Service:LoadAnims(Player, Defender)
				
			end
		end
	end

	LoadItemsEvent:FireClient(Player, Data.Data)
end

function _Service:LoadAnims(plr, Defender)


	for i, v in pairs(_Animations) do
		if i == Defender.Name then
			local AnimationInt = Instance.new("Animation")

			if Defender.Animations:FindFirstChild(i) then

			else
				local CloneAnim = AnimationInt:Clone();
				CloneAnim.Name = i
				CloneAnim.Parent = Defender.Animations
				CloneAnim.AnimationId = v.Idle


				local Humanoid = Defender:WaitForChild("Humanoid");

				RunService.Stepped:Wait()
				local Anim = Humanoid:LoadAnimation(CloneAnim)
				Anim:Play()
			end
		end
	end

end

function _Service:GetStatusData(Data, ID)
	print(ID)
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

function _Service:CheckEquip(Data)
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


function _Service:Handle(Player, Which, data, server)
	if Player and Which ~= nil and data ~= nil then

		local ProfileModule = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);

		local Data = ProfileModule[Player];
		

		if Which == "Equip" then
			local ItemData = _Service:GetStatusData(Data.Data, data.ID);
			if ItemData == nil then
				warn("No Pet data for pet with ID:", tostring(Data[1]))
				return
			end
			local PetFolder = ServerPets:FindFirstChild(Player.Name);
			if _Service:CheckEquip(Data) == true then
				
				if ItemData[3] == false and ServerPets[Player.Name]:FindFirstChild(data.ID) == nil then
					ItemData[3] = true

					local Name, ID = data.ItemName, data.ID
					local Shiny = data.Shiny
					local Level = data.Level
					local Defender = ReplicatedStorage.Assets:WaitForChild("Defenders"):WaitForChild(tostring(Name)):Clone();
					Defender.PrimaryPart.CFrame = workspace:WaitForChild(Player.Name).HumanoidRootPart.CFrame + Vector3.new(0, 0, 3)
					MakeFolder(Player, Name, ID, Shiny, Level, Defender);
					
					_Service:LoadAnims(Player, Defender)
					print(Name, ID, Shiny, Level)
					return true
				else
					print(ItemData[3])
					if ItemData[3] == true and PetFolder:FindFirstChild(data.ID) ~= nil and server == nil then
						local DestroyModel = PetFolder:FindFirstChild(data.ID);
						DestroyModel:Destroy();


						ItemData[3] = false
						return false
					end
				end
			end
		elseif Which == "Unequip" then
			local PetFolder = ServerPets:FindFirstChild(Player.Name);
			local ItemData = _Service:GetStatusData(Data.Data, data.ID);
			if ItemData == nil then
				warn("No Pet data for pet with ID:", tostring(Data[1]))
				return
			end
			if PetFolder ~= nil then
				print(ItemData[3])
				if ItemData[3] == true and PetFolder:FindFirstChild(data.ID) ~= nil then
					local DestroyModel = PetFolder:FindFirstChild(data.ID);
					DestroyModel:Destroy();
					
				
					ItemData[3] = false
					return true
				else

					if _Service:CheckEquip(Data) == true  and server == nil then
						if ItemData[3] == false and ServerPets[Player.Name]:FindFirstChild(data.ID) == nil then
							ItemData[3] = true

							local Name, ID = data.ItemName, data.ID
							local Shiny = data.Shiny
							local Level = data.Level
							local Defender = ReplicatedStorage.Assets.Defenders[tostring(Name)]:Clone();
							Defender.PrimaryPart.CFrame = workspace:WaitForChild(Player.Name).HumanoidRootPart.CFrame + Vector3.new(0, 0, 3)
							MakeFolder(Player, Name, ID, Shiny, Level, Defender);

							_Service:LoadAnims(Player, Defender)
							print(Name, ID, Shiny, Level)
							return false
						end
					end
				end
			end
		elseif Which == "UpdateLevels" then
			local PetFolder = ServerPets:FindFirstChild(Player.Name);
		
			if PetFolder ~= nil then
				for i, v in pairs(PetFolder:GetChildren()) do
					if v:IsA("Folder") and v:FindFirstChild("ID") and v:FindFirstChild("Level") then
						local ID = v.ID.Value
						local Shiny = v.Shiny.Value
						
						local ItemData = _Service:GetStatusData(Data.Data, ID, "Pet");
						if ItemData ~= nil then
							local Level = ItemData[4]
							if Level == nil then
								warn("No Pet Level For pet with ID:", tostring(ID));
								Level = 1
							end
							
							v.Level.Value = (tonumber(Level) or 1);
							
						else
							warn("No Pet data for pet with ID:", tostring(ID))
						end
					end
				end
				UpdateLevels:FireClient(Player)
			end
		elseif Which == "MultiDelete" then
			if #data < 1 then else
				local returnDeleted = {}
				for _, v in pairs(data) do
					local ItemName, ItemID = v.ItemName, v.ID
					local ItemData = _Service:GetStatusData(Data.Data, ItemID)
					if ItemName == "Security Helper" or ItemName == "VIP Security" then
						return
					else
						
						if ItemData ~= nil then
							--local petLocked = petData.Locked or false
							local deleted = _Service:DeleteItem(Player, Data, ItemID, ItemName, false, true)
							table.insert(returnDeleted, {ID = ItemID})
						else
							warn("No Pet data for pet with ID:", tostring(ItemID))
						end
					end
				end
				
				return returnDeleted
			end
		end
		
		
			
	end
end

function _Service:AddItem(Player, Data)
	if Player and Data ~= nil then
		local ItemName = Data.ItemName;
		local Shiny = Data.Shiny or "Normal";
		--local Shiny = Data.Rainbow;
		local Level = Data.Level;
		local ItemData;
		local Tradable; 

		local ProfileModule = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
		local Data = ProfileModule[Player];

		ItemData = Data.Data.Data.Player.Inventory.Defenders.Contents;
		
		local PetData;

		--if EggService:CheckEquip(Data) == true then
		--PetData = EggService:ReturnPetData(ItemName, true, Shiny, Level, Type, Tradable, {});

		PetData = _Service:ReturnPetData(
			ItemName, 
			false, 
			Shiny, 
			Level 
		--	{math.random(LowestDamage, HighestDamage), math.random(LowestPetXP, HighestPetXP)},
			--{math.random(LowestTokens, HighestTokens), math.random(LowestExperience, HighestExperience)}
		)--, {math.random(), math.random()});
		--end
		--MakePetFolder(Player, ItemName, PetData[1], Shiny, Level);

		table.insert(ItemData, PetData);
		CreateEvent:FireClient(Player, PetData, Data.Data)

		return true;
	end
end

function _Service:DeleteItem(plr, Data, ID, ItemName, ItemLocked, multiDelete, Type)
	if ItemLocked == true then
		return "NoDelete" 
	end
	
	local Pets = Data.Data.Data.Player.Inventory.Defenders.Contents;
	local TableI = (function()
		if Data ~= nil and ID ~= nil then
			for i, v in pairs(Pets) do
				if type(v) == "table" then
					if v[1] ~= nil then
						local ItemID = v[1];
						if ItemID == ID then
							return i;
						end
					end
				end
			end
		end
	end)()
	
	if TableI ~= nil then
		table.remove(Pets, TableI)
		--[[if multiDelete == true then else
			DataController:SavePlayerData(plr)
		end]]

		local Folder = ServerPets:FindFirstChild(plr.Name)
		if Folder ~= nil then
			if Folder:FindFirstChild(ID) ~= nil then
				local modelToDestroy = Folder:FindFirstChild(ID)
				modelToDestroy:Destroy()
			end
		end

		return true
	end
end

function _Service:GetPlayerItems(Player, PlayerName)
	if PlayerName ~= nil then
		local Player = Players:FindFirstChild(tostring(PlayerName))
		if Player ~= nil then
			local ProfileModule = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
			local Data = ProfileModule[Player];
			local Pets = Data.Data.Data.Player.Inventory.Defenders.Contents
			--print(Pets, Knives)
			return Pets
		end
	end
end

function _Service:RemoveFolder(plr)
	workspace.Pets.ServerPets[plr.Name]:Destroy()
end


function _Service:Int()
	ItemTable.OnServerInvoke = function(...)
		return _Service:GetPlayerItems(...)
	end
end



return _Service;
