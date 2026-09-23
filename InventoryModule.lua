--// Manages the client-side inventory system, including defender stats, leveling, equipping, multi-delete functionality, currency animations, and dynamic inventory UI updates.

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local TweenService = game:GetChildren("TweenService");

repeat wait() until Players.LocalPlayer;
local Player = Players.LocalPlayer;
local PlayerUI = Player:WaitForChild("PlayerGui");
local ScreenUI = PlayerUI:WaitForChild("ScreenGui");
local UIFrame  = ScreenUI:WaitForChild("UI");
local Help  = UIFrame:WaitForChild("Help");
local InventoryFrame = UIFrame:WaitForChild("Inventory");
local MultiDeleteFrame = UIFrame:WaitForChild("MultiDeleteItems");
local DeleteButton = InventoryFrame:WaitForChild("Delete");
local MultiDeleteBool = DeleteButton:WaitForChild("MultiDeleteOn");
local Bottom = UIFrame:WaitForChild("Bottom")
local Left = UIFrame:WaitForChild("Left")

local FetchClientData = ReplicatedStorage.Remotes["Remote Functions"]["Client Data"];
local HandleEvent = ReplicatedStorage:WaitForChild("Remotes")["Remote Functions"]["Handle"];
local CreateEvent = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]["Create"];
local LoadItemsEvent = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]:WaitForChild("Load Items");
local UpdateLevels = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]:WaitForChild("Update Levels");
local UpdatePlayerData = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]:WaitForChild("Update Player Data");
local UpdateCurrency = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]:WaitForChild("Update Currency");

local CurrentSlot, CurrentSlot2, ClickDebounce, ClickDebounce2, DeleteDebounce, SendTable = nil, nil, false,false, false, {};
local Knife_Equip, Pet_Equip = nil, nil
local SendTbl2 = {}

--local Crafting = { Normal = 1, Shiny = 2 };
local XP_RARITIES = { [0] = 250, [0.5] = 250, [1] = 250, [2] = 250, [3] = 250, [4] = 300, [5] = 400, [6] = 500 };
local CRAFTING = { Normal = 1, Corrupted = 2 };

local _Defenders = require(ReplicatedStorage.Modules.Contents.__Defenders);
local _Abbreviation = require(ReplicatedStorage.Modules.Contents.__Abbreviation);
local _Ranks = require(ReplicatedStorage.Modules.Contents.__Ranks);
local _Specialties = require(ReplicatedStorage.Modules.Contents.__Specialties);
local _Interface = require(ReplicatedStorage.Modules.Contents.__Interface);
local _Delete = require(script.__Delete);

local _Inventory = {}

local GetName = function(Name, Shiny)
	if Shiny == "Corrupted" then
		return "Corrupted "..tostring(Name)
	end

	return tostring(Name), "Normal"
end

local function GetMultiplier(Status, Level, Shiny)
	--[[local ignore = {};
	if table.find(ignore, Status) then
		local CoinMul, RagdollMul, ThirdCurrency = Status.Coins, Status.Ragdolls, (status[Thrid status here])
	end]]
	
	print(Status, Level, Shiny)
	local TokenMul, ExpMul, DamageMul, ReloadMul = Status.Tokens, Status.XP, Status.Damage, Status.Reload;
	local Mul = CRAFTING[tostring(Shiny)];
	if Mul == nil then
		warn("No Craft Multiplier")
		Mul = 1;
	end

	local PetLevel=  (tonumber(Level) * 0.1) + 1;
	if tonumber(PetLevel) < 1 then PetLevel = 1 end
	
	if Level > 1 then
		print(Mul)
		TokenMul = (TokenMul * PetLevel) * Mul;
		ExpMul = (ExpMul * PetLevel) * Mul;
		DamageMul = (DamageMul * PetLevel) * Mul;
		ReloadMul = ReloadMul / (PetLevel * Mul)
	else
		TokenMul = TokenMul * Mul;
		ExpMul = ExpMul * Mul;
		DamageMul = DamageMul * Mul;
		ReloadMul = ReloadMul / Mul
	end
	
	if ReloadMul <= 1 then
		ReloadMul = 0.5
	end
	
	return _Abbreviation:RoundDecimals(TokenMul, 2), _Abbreviation:RoundDecimals(ExpMul, 2), _Abbreviation:RoundDecimals(DamageMul, 2),  _Abbreviation:RoundDecimals(ReloadMul, 2);

end

function _Inventory:SetPetsEquipped()

	local Data = FetchClientData:InvokeServer(Player);
	local MaxStorage = Data.Data.Player.Inventory.Defenders.MaxStorage;
	local MaxPetsEquipped = Data.Data.Player.Inventory.Defenders.MaxEquipped;
	local AmountInvPets, AmountPetsEquipped = (function()
		local Amount, AmountEquipped = 0, 0
		local pets = Data.Data.Player.Inventory.Defenders.Contents;
		local Equipped = Data.Data.Player.Inventory.Defenders.Equppied;
		for _, v in pairs(pets) do
			if type(v) == "table" then
				if v[3] == true then
					AmountEquipped += 1
				end
				Amount += 1
			end
		end
		return Amount, AmountEquipped
	end)()

	local TotalTokens, TotalExp = 0, 0
	for i, v in pairs(Data) do
		if type(v) == "table" then
			local ItemName, Shiny, Level = v[2], v[6], v[4];
			if v[3] == true and ItemName ~= nil and Shiny ~= nil and Level ~= nil then
				local Status = _Inventory:GetPetStatus(ItemName);
				local TokenMul, ExpMul = GetMultiplier(Status, Level, Shiny);
				TotalTokens = TotalTokens + TokenMul;
				TotalExp = TotalExp + ExpMul;
			end
		end
	end
	
	InventoryFrame.PetAmount.Text = "("..tostring(AmountPetsEquipped) .."/".. tostring(MaxPetsEquipped)..") Equipped";
	InventoryFrame.ItemStorage.Text = "("..tostring(AmountInvPets) .."/".. tostring(MaxStorage)..")";
	--[[if MaxPetsEquipped == math.huge then
		InventoryFrame.Status.PetStorage.Storage.Text = tostring(AmountPetsEquipped) .." / ∞";
		else InventoryFrame.Status.PetStorage.Storage.Text = tostring(AmountPetsEquipped) .." / ".. tostring(MaxPetsEquipped);
	end
	if MaxPetsInventory == math.huge then
		InventoryFrame.Status.PetsEquipped.Equipped.Text = tostring(AmountInvPets) .." / ∞";
		else InventoryFrame.Status.PetsEquipped.Equipped.Text = tostring(AmountInvPets) .." / ".. tostring(MaxPetsInventory);
	end]]

	-- total pets space if needed
end

function _Inventory:GetStatus(Name)
	if _Defenders[Name] == nil then
		warn("No pet status for pet with name of" .. tostring(Name));
		return _Defenders["Security Toilet"];
	end
	return _Defenders[Name];
end

function _Inventory:GetStatusData(Data, ID, Type)
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

function _Inventory:CheckEquipped(Data, ID, Type)
	if Data ~= nil and ID ~= nil then
		local Inventory = Data.Data.Player.Inventory.Defenders.Contents;
		
		if Inventory ~= nil then
			for i, v in pairs(Inventory) do
				if type(v) == "table" then
					if v[1] ~= nil then
						--print(v[1])
						return v; -- equipped
					end
				end
			end
		end
	end
end

local DefenderXPBar = function(obj, progress)
	local OneOverProgress
	if progress == 0 then
		OneOverProgress = 0
	else
		OneOverProgress = 1/progress
	end
	obj:TweenSize(UDim2.new(progress, 0, 1, 0))
	obj.Top:TweenSize(UDim2.new(OneOverProgress, 0, 1, 0))
end

local PlayerXPBar = function(obj, progress)
	local OneOverProgress
	if progress == 0 then
		OneOverProgress = 0
	else
		OneOverProgress = 1/progress
	end
	obj:TweenSize(UDim2.new(progress, 0, 1, 0))
	obj.Top:TweenSize(UDim2.new(OneOverProgress, 0, 1, 0))
end

local GetPetXPLevel = function(PetName, Level, Shiny)
	if tonumber(Level) < 1 then Level = 1 end;
	Shiny = Shiny ~= nil and tostring(Shiny) or "Normal";

	local Status =  _Inventory:GetStatus(PetName);
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

local GetDataButton = function(button)
	if button and button:FindFirstChild("Pet") then
		local Pet = button:FindFirstChild("Pet")
		if Pet:FindFirstChild("Data") then
			local petName = button.Pet.Data.ItemName.Value
			local petID = button.Pet.Data.ID.Value
			local Shiny = button.Pet.Data.Corrupted.Value
			local Level = button.Pet.Data.Level.Value

			return petName, petID, Shiny
		end
	end
end


function Format_(number)

	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
end

function _Inventory:ShowCurrencyCollect(CurrencyType, Value)
	print(CurrencyType, Value)
	local CurrencyImage = {
		["Coins"] = "rbxassetid://5864197065",
		["Experience"] = "rbxassetid://7103638819",
		["PetXP"] = "rbxassetid://7103768455",
		["Diamonds"] = "rbxassetid://5874959188"
	}

	local Clone = script.Currency:Clone();
	local Clone2 = script.Currency:Clone();
	--local Clone3 = script.Currency:Clone();

	local TokenTween = UIFrame.Left.CurrencyTween
	local XPTween = UIFrame.Bottom.CurrencyTween

	Clone.Image = CurrencyImage[CurrencyType];
	Clone.Value.Text = Format_(Value)

	Clone2.Image = CurrencyImage[CurrencyType];
	Clone2.Value.Text = Format_(Value)
	
	--Clone3.Image = CurrencyImage[CurrencyType];
	--Clone3.Value.Text = Format_(Value)

	local RNG = Random.new()
	local Division = 1.5
	local Position1, Position2 = RNG:NextNumber(2, 3), RNG:NextNumber(-.1, -.5);
	local Position3, Position4 = RNG:NextNumber(2, 3), RNG:NextNumber(-.3, -1);
	Clone.Position = UDim2.new(Position1/Division, 0, Position2/Division, 0);
	Clone2.Position = UDim2.new(Position3/Division, 0, Position4/Division, 0);
	--Clone3.Position = UDim2.new(Position3/Division, 0, Position4/Division, 0);
	if CurrencyType ~= "Experience" then
		Clone.Parent = TokenTween
		wait(.7)
		Clone:TweenSizeAndPosition(UDim2.new(0.125, 0, 0.15, 0), UDim2.new(0.127, 0, 0.272, 0), "Out", "Quad", 1);

	elseif CurrencyType == "Experience" then
		Clone2.Size = UDim2.new(0.323, 0, 0.646, 0)
		Clone2.Parent = XPTween
		wait(.7)
		Clone2:TweenSizeAndPosition(UDim2.new(0.125, 0, 0.15, 0), UDim2.new(0.127, 0, .9, 0), "Out", "Quad", 1);
	end

	spawn(function()
		for i = 0, 1, 0.1 do
			wait(.04)
			Clone.ImageTransparency = i
			Clone2.ImageTransparency = i
			--Clone3.ImageTransparency = i
			if Clone:FindFirstChild("Value") ~= nil then
				Clone:WaitForChild("Value").TextTransparency = i
			end
			if Clone2:FindFirstChild("Value") ~= nil then
				Clone2:WaitForChild("Value").TextTransparency = i
			end
			--Clone2:WaitForChild("Value").TextTransparency = i
			--Clone3:WaitForChild("Value").TextTransparency = i
		end
	end)

	wait(.7)
	Clone:Destroy();
	Clone2:Destroy();
--	Clone3:Destroy();
end

local XP_REQUIRED = 2000;

function _Inventory:GetXP(Level)
	return (Level ^ 2) * (XP_REQUIRED * Level)
end
local goal = {}

function _Inventory:UpdateData(Level, Remaining, Type)
	if Level ~= nil then
		local Data = FetchClientData:InvokeServer(Player);
		local PlayerData = Data.Data.Player

		local Exp_Needed = _Inventory:GetXP(PlayerData.Level);
		local XP = math.floor(PlayerData.Experience)
		local Change = XP / Exp_Needed;
		local Percent = math.floor(Change * 100)
		
		
		
		Bottom.Level.RankName.Text = _Ranks:ReturnRank(Level)[1];
		Bottom.Level.RankName.TextColor3 = _Ranks:ReturnRank(Level)[2];
		Bottom.Level.LevelNum.TextColor3 = _Ranks:ReturnRank(Level)[2];
		Bottom.Level.LevelBar.BackgroundColor3 = _Ranks:ReturnRank(Level)[2];
		--Sidebar.Level.Prestige.Image = "rbxassetid://"..PrestigeModule:ReturnPrestige(Prestige)[1];
		
		if _Ranks:ReturnRank(Level)[3] ~= nil and _Ranks:ReturnRank(Level)[3] == "MAX" then
			Bottom.Level.LevelNum.Text = "MAX";
			PlayerXPBar(Bottom.Level.LevelBar, 1);
		else
			Bottom.Level.LevelNum.Text = Percent.."%";
			PlayerXPBar(Bottom.Level.LevelBar, Change);
		end

	end
	
	if Remaining ~= nil and Type == "Experience" then
		_Inventory:ShowCurrencyCollect(Type, Remaining);
	end
	if Type ~= nil and Remaining ~= nil then
		_Inventory:ShowCurrencyCollect(Type, Remaining);
	end
end

local function abbreviateNumber(number)
	local suffixes = {
		{ 1e12, "T" }, -- Trillion
		{ 1e9, "B" },  -- Billion
		{ 1e6, "M" },  -- Million
		{ 1e3, "K" }   -- Thousand
	}

	for _, suffix in ipairs(suffixes) do
		if number >= suffix[1] then
			local abbreviatedNumber = number / suffix[1]
			return string.format("%.1f%s", abbreviatedNumber, suffix[2])
		end
	end

	return tostring(number)
end


function _Inventory:SetStats(Name, ID)

	if Name == nil and ID == nil then
		CurrentSlot = nil
		DefenderXPBar(InventoryFrame.Display.LevelCon.LevelBar, 0);
	else
		local MultiplierStatus = _Inventory:GetStatus(Name);
		local Data = FetchClientData:InvokeServer(Player);
		local PetData = Data.Data.Player.Inventory.Defenders.Contents
		local PetDataStatus = _Inventory:GetStatusData(Data, ID);
		if PetDataStatus == nil then
			warn("No Pet Stats for pet with ID:", tostring(ID))
			return
		end

		for i, v in pairs(InventoryFrame.Buffs.Container:GetChildren()) do
			if v:IsA("ImageLabel") then
				v.Visible = false
			end
		end
		
		for a, b in pairs(_Defenders[Name]) do
			if InventoryFrame.Buffs.Container:FindFirstChild(tostring(a)) then
				InventoryFrame.Buffs.Container:FindFirstChild(tostring(a)).Visible = true
			end
		end

		--InventoryFrame.KnifeDisplay.Details[_Defenders[tostring(Name)].Rarity].Visible = true

		local Shiny = PetDataStatus[6]
		local Level = PetDataStatus[4];
		if tonumber(Level) < 1 then Level = 1 end;
		

		local TokenMul, ExpMul, DamageMul, ReloadMul = GetMultiplier(MultiplierStatus, Level, Shiny);
		if TokenMul == nil then
			InventoryFrame.Buffs.Container.Tokens.Multiplier.Text = "nil";
		else
			
			InventoryFrame.Buffs.Container.Tokens.Multiplier.Text = "x".. tostring(TokenMul);
		end
		if ExpMul == nil then
			InventoryFrame.Buffs.Container.XP.Multiplier.Text = "nil";
		else
			InventoryFrame.Buffs.Container.XP.Multiplier.Text = "x".. tostring(ExpMul);
		end
		
		if DamageMul == nil then
			InventoryFrame.Buffs.Container.Damage.Multiplier.Text = "nil";
		else
			InventoryFrame.Buffs.Container.Damage.Multiplier.Text = "+".. tostring(DamageMul);
		end
		
		if ReloadMul == nil then
			InventoryFrame.Buffs.Container.Reload.Multiplier.Text = "nil";
		else
			InventoryFrame.Buffs.Container.Reload.Multiplier.Text = "+".. tostring(ReloadMul);
		end
		
		if _Defenders[Name] ~= nil then
			if _Defenders[Name].Rarity == 6 then
				for i, v in pairs(InventoryFrame.Buffs.Container:GetChildren()) do
					if v.Name ~= "Reload" and v:IsA("ImageLabel") then
						v.Multiplier.Text = "???"
					end

				end
			end
			
		end
		
		if _Defenders[Name].Specialties ~= nil then
			for i, v in pairs(_Defenders[Name].Specialties) do
				if i == 1 then
					InventoryFrame.Buffs.SPECIAL.USE.Text = _Specialties[_Defenders[Name].Specialties[1]]("Table") .."!"
				elseif i == 2 then
					InventoryFrame.Buffs.SPECIAL.USE.Text = _Specialties[_Defenders[Name].Specialties[1]]("Table") ..", ".._Specialties[_Defenders[Name].Specialties[2]]("Table") .."!"
				end
			end
			
			InventoryFrame.Buffs.SPECIAL.Visible = true
		else
			InventoryFrame.Buffs.SPECIAL.Visible = false
		end
		
		
		
		
		local Exp_Needed = GetPetXPLevel(tostring(Name), Level, tostring(Shiny));
		local xp = math.floor(PetDataStatus[5]);
		local change = xp / Exp_Needed;
		print(xp)
		InventoryFrame.Display.LevelCon.Level.Text = "Level ".. tostring(Level).. " ("..abbreviateNumber(xp).." / "..abbreviateNumber(Exp_Needed)..")"
		--InventoryFrame.LevelCon.Level.Text = ""
		DefenderXPBar(InventoryFrame.Display.LevelCon.LevelBar, change);
		
			--[[if PetDataStatus[3] == false then
				InventoryFrame.Display.Equip.Visible, InventoryFrame.Display.Unequip.Visible = true, false
			else
				InventoryFrame.Display.Equip.Visible, InventoryFrame.Display.Unequip.Visible = false, true
			end]]
	end
	--end

end

function _Inventory:UpdateLevelStatus(SetPetEquipped)
	if CurrentSlot ~= nil and InventoryFrame.Visible == true then
		local Name, ID, Shiny, Level = GetDataButton(CurrentSlot);
		if Name ~= nil and ID ~= nil and Shiny ~= nil and Level ~= nil then
			_Inventory:SetStats(Name, ID);
			if SetPetEquipped == true then
				_Inventory:SetPetsEquipped()
			end
		end
	end
end

function _Inventory:CheckDuplicate(ID, Equip)
	if ID ~= nil  then
		if Equip == true then
			return true
		end
	else
		for i, v in pairs(InventoryFrame.Container:GetChildren()) do
			if v:IsA("ScrollingFrame") and v.Name ~= "Container" then
				if v:IsA("ScrollingFrame") then
					local ItemID = v.Data.ID.Value
					if ItemID == ID then
						return false
					end
				end
			end
		end
		return true
	end
end

function _Inventory:SetShiny(Object)

	game:GetService("RunService").Heartbeat:Connect(function()
		local Offset = math.abs(math.sin((tick()) * 2)) / 3.5
		local Light = 0.9 + Offset
		local Dark = 0.9 
		Object.BackgroundColor3 = Color3.fromHSV(0.12549019607843137, 0.8352941176470589, Dark)
		if math.random(200) == 1 then
			coroutine.wrap(function()
				local Speed = 2
				local Shine = script.Shine:Clone()
				Shine.Parent = Object
				Shine.Position = UDim2.new()
				Shine.ZIndex = Object.ZIndex + 10
				pcall(function()
					Shine:TweenPosition(UDim2.new(3, 0, 3, 0), "Out", "Linear", Speed, true)
				end)
				wait(Speed)
				if Shine.Parent then
					Shine:Destroy()
				end
			end)()
		end
	end)
end

function isEmpty(t)
	return next(t) ~= nil
end

local RaritytoSort = {[0] = 0, [0.5] = 0.5, [1] = 6, [2] = 5, [3] = 4, [4] = 3, [5] = 2, [6] = 1}

function _Inventory:CreatePetButton(ItemName, ID, Type, ItemEquip)
	if _Inventory:CheckDuplicate(ID, ItemEquip) == false then
		return
	end

	local Data = FetchClientData:InvokeServer(Player);
	local PetData = Data.Data.Player.Inventory.Defenders.Contents

	if isEmpty(PetData) then
		local Clone = script.PetItem:Clone();
		local MultiplierStatus = _Inventory:GetStatus(ItemName);
		local PetDataStatus = _Inventory:GetStatusData(Data, ID);
		
		print(PetDataStatus)
		local Shiny = PetDataStatus[6];
		local Level = PetDataStatus[4];
		local Equipped = PetDataStatus[3]
		
		local rName, Type = GetName(tostring(ItemName), PetDataStatus[6]);
		local TokenMul, ExpMul, DamageMul, ReloadMul = GetMultiplier(MultiplierStatus, Level, Shiny);
		local GetRarityColor = script.Rarities[tostring(_Defenders[ItemName].Rarity)]:Clone();

		Clone.Name = RaritytoSort[_Defenders[ItemName].Rarity];
		Clone.Visible = true
		Clone.Pet.ItemImage.Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=420&height=420&assetId=".._Defenders[ItemName].Image
		--Clone.ItemLevel.Text = "["..tostring(Level).."]"
		if PetDataStatus[3] == true then
			Clone.Pet:WaitForChild("Equipped").Visible = true
		end
		if Shiny == "Corrupted" then
			Clone.Pet.Corrupted.LocalScript.Enabled = true
			--	InventoryModule:SetShiny(Clone)
		end
		
		Clone.Pet.Average.Text = DamageMul
		if _Defenders[ItemName].Rarity == 6 then
			Clone.Pet.Average.Text = "??"
		end
		GetRarityColor.Parent = Clone.Pet.RareItem
		Clone.Parent = InventoryFrame.Container.ScrollingFrame

		Clone.Pet.Data.ID.Value = ID;
		Clone.Pet.Data.ItemName.Value = ItemName;
		Clone.Pet.Data.Corrupted.Value = Shiny;
		Clone.Pet.Data.Level.Value = Level;
		print(Equipped)
		
		_Inventory:SetPetsEquipped()

		--for i, v in pairs(InventoryFrame.Container.PetScrollingFrame:GetChildren()) do
		--if v:IsA("Frame") and v.Name == Clone.Name then
		
		Clone.Pet.MouseButton1Click:Connect(function()
			if MultiDeleteBool.Value == true then
				print(ItemName)
				if ItemName == "Security Helper" or ItemName == "VIP Security" then
					return
				else
					if Clone.Pet.DeleteOverlay.Visible == false then
						Clone.Pet.DeleteOverlay.Visible = true
						
						_Delete:AddItemToMultiDelete(Clone)
					else
						Clone.Pet.DeleteOverlay.Visible = false
						_Delete:DeleteItemInMultiDelete(Clone)
					end
				end
			end
		end)
		
		Clone.Pet.MouseEnter:Connect(function()
			if MultiDeleteBool.Value == false then
				
				InventoryFrame.Display.Item.ItemIcon.Size = UDim2.new(1.196, 0, 1.18, 0)
				InventoryFrame.Display.Item.ItemIcon.Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=420&height=420&assetId=".._Defenders[ItemName].Image;
				InventoryFrame.Display.Item.ItemName.Text = rName;
				--InventoryFrame.Display.Item.ItemName.ItemRarity.Text = _Inventory[ItemName].Rarity;

				CurrentSlot = Clone;
				_Inventory:SetStats(tostring(ItemName), ID);
			end
			

		end)
		
		Clone.Pet.MouseButton1Click:Connect(function()
			CurrentSlot2 = Clone;
			if Clone.Pet.Equipped.Visible ==  false then
				
				_Inventory:EquipPet()
			else
				_Inventory:UnequipPet()
			end
			
		end)
	end
end

function _Inventory:LoadInventory(Data, Data2, Type)
		
	if Data ~= nil and Data2 ~= nil and type(Data) == "table" then
		--[[table.insert(SortedTable, Data)
		for i, v in pairs(Data) do
			table.insert(SortedTable, v)
		end]]
		local ItemName = Data[2];
		local ItemID = Data[1];
		
		--local PetDataStatus = InventoryModule:GetPetStatusData(Data.Data, ItemID);
		if ItemName and ItemID ~= nil then
			_Inventory:CreatePetButton(ItemName, ItemID)
			
		end
	end
	
	for i, v in pairs(InventoryFrame.Container:GetChildren()) do
		if v:IsA("ScrollingFrame") and v.Name ~= "Container" then
			v.UIGridLayout:ApplyLayout()
			_Interface:SetCanvasSize("", "", v, v.UIGridLayout)
		end
	end
end

function _Inventory:LoadInventory2(Data, Type)
	if Data ~= nil and type(Data) == "table" then
		for i, v in pairs(Data) do
			spawn(function()
				local ItemName = v[2];
				local ItemID = v[1];
				--local ItemEquip = v[6];
				--local PetDataStatus = InventoryModule:GetPetStatusData(Data.Data, ItemID);
				if ItemName and ItemID ~= nil then
					_Inventory:CreatePetButton(ItemName, ItemID)
				end
			end)
			
		end
	end
end

function _Inventory:LoadItems(PlayerData, Option)
	spawn(function()
		_Inventory:SetStats(nil, nil, "Pet");
		_Inventory:LoadInventory2(PlayerData.Data.Player.Inventory.Defenders.Contents, Option);
	
		wait(.1)
		_Inventory:SetPetsEquipped()
		for i, v in pairs(InventoryFrame.Container:GetChildren()) do
			if v:IsA("ScrollingFrame") and v.Name ~= "Container" then
				v.UIGridLayout:ApplyLayout()
				_Interface:SetCanvasSize("", "", v, v.UIGridLayout)
			end
		end
	end)
end
local DeleteD = false

function _Inventory:ConfirmMultiDeletePets()
	local ItemsInMultiDelete = _Delete:GetMutliDeletePets()
	if (#ItemsInMultiDelete) >= 1 then
		if MultiDeleteBool.Value == true then
			if DeleteD == false then
				DeleteD = true

				SendTbl2 = {}
				for _, v in pairs(ItemsInMultiDelete) do
					local Name, ItemID = GetDataButton(v)
					table.insert(SendTbl2, {ItemName = tostring(Name), ID = ItemID})
				end

				local deleteAllMsg 
				if #SendTbl2 <= 1 then
					deleteAllMsg = "Are you sure you want to delete 1 item?"
				else
					deleteAllMsg = "Are you sure you want to delete "..tostring(#SendTbl2).." items?"
				end

				MultiDeleteFrame.ItemSelected.Text = tostring(deleteAllMsg)
				MultiDeleteFrame.Visible = true

				wait() DeleteD = false
			end
		end
	end
end


function _Inventory:CancelMultiDelete()
	if MultiDeleteBool.Value == true then
		MultiDeleteBool.Value = false
		InventoryFrame.Delete.ImageColor3 = Color3.fromRGB(255, 255, 255)
		InventoryFrame.DeleteDisplay.Visible, InventoryFrame.Display.Visible, InventoryFrame.Buffs.Visible = false, true, true
		
		for i, v in pairs(InventoryFrame.Container.ScrollingFrame:GetChildren()) do
			if v:IsA("Frame") and v.Pet:FindFirstChild("Data") then
				if v.Pet.DeleteOverlay.Visible == true then
					v.Pet.DeleteOverlay.Visible = false
				end
			end
		end

		CurrentSlot, CurrentSlot2, SendTbl2 = nil, nil, {}
		_Delete:ResetMultiDeleteTable()
		InventoryFrame.DeleteDisplay.Selected.Text = "0 Item(s) Selected"
		_Inventory:SetStats(nil, nil)
		MultiDeleteFrame.Visible = false
	end
end

function _Inventory:MultiDeletePets()
	local deletedItems = HandleEvent:InvokeServer("MultiDelete", SendTbl2) wait(.1)
	if deletedItems ~= nil and type(deletedItems) == "table" then
		for i, v in pairs(deletedItems) do
			if v and v.ID then
				--local button = (function()
					for a, b in pairs(InventoryFrame.Container.ScrollingFrame:GetChildren()) do
					if b:IsA("Frame") and b.Pet:FindFirstChild("Data") then
							spawn(function()
								local Name, ID = GetDataButton(b)
								if ID == v.ID then
									b:Destroy()
								end
							end)
							
						end
					end
				--end
				--if button ~= nil then
					
					--if i % 4 == 0 then  wait() end
				--end
			end
		end
		_Delete:ResetMultiDeleteTable()
		_Inventory:SetPetsEquipped()
		_Inventory:CancelMultiDelete()
		
		InventoryFrame.Visible = true
	end
end

function _Inventory:SwitchMultiDelete()
	
	if MultiDeleteBool.Value == false then
		CurrentSlot, CurrentSlot2, SendTbl2 = nil, nil, {}
		InventoryFrame.DeleteDisplay.Visible, InventoryFrame.Display.Visible, InventoryFrame.Buffs.Visible = true, false, false
		InventoryFrame.DeleteDisplay.Selected.Text = "0 Item(s) Selected"
		MultiDeleteBool.Value = true
		InventoryFrame.Delete.ImageColor3 = Color3.fromRGB(255, 0, 0)
		_Inventory:SetStats(nil, nil, true)
	else 
		_Inventory:CancelMultiDelete()
	end
end

function _Inventory:EquipNew()
	local DefenderName = "Security Helper"
	local DefenderID = "Starter"
	local DefenderShiny = "Normal"
	local DefenderLevel = 1
	
	if DefenderName ~= nil and DefenderID ~= nil then
		local SendTbl3 = {ItemName = tostring(DefenderName); ID = DefenderID; Shiny = DefenderShiny, Level = DefenderLevel};
		local Task = HandleEvent:InvokeServer("Equip", SendTbl3) wait(.1);
		if Task == true then
			for i, v in pairs(InventoryFrame.Container.ScrollingFrame:GetChildren()) do
				if v:FindFirstChild("Pet") then
					for a, b in pairs(v.Pet.Data:GetChildren()) do
						if b.ItemName == "Security Helper" then
							b.Pet:FindFirstChild("Equipped").Visible = true
						end
					end
				end
			end
		end
	end
	
end

function _Inventory:EquipPet()
	if CurrentSlot ~= nil and MultiDeleteBool.Value == false then
		if ClickDebounce == false then
			ClickDebounce = true
			local ItemName, ID, Shiny, Level = GetDataButton(CurrentSlot2);
			if ItemName ~= nil and ID ~= nil then
				local SendTbl = {ItemName = tostring(ItemName); ID = ID; Shiny = Shiny, Level = Level};
				local Task = HandleEvent:InvokeServer("Equip", SendTbl) wait(.1);
				if Task == true then
					_Inventory:SetStats(ItemName, ID);
					CurrentSlot2.Pet:WaitForChild("Equipped").Visible = true
					_Inventory:SetPetsEquipped();
					CurrentSlot2.Name = -1
					InventoryFrame.Container.ScrollingFrame.UIGridLayout:ApplyLayout();
				end
				wait() ClickDebounce = false
			end
		end
	end
end

function _Inventory:UnequipPet()
	if CurrentSlot ~= nil and MultiDeleteBool.Value == false then
		if ClickDebounce == false then
			ClickDebounce = true
			local ItemName, ID, Shiny, Level = GetDataButton(CurrentSlot2);
			if ItemName ~= nil and ID ~= nil then
				local SendTbl = {ItemName = tostring(ItemName); ID = ID; Shiny = Shiny, Level = Level};
				
				local Task = HandleEvent:InvokeServer("Unequip", SendTbl) wait(.1);
				if Task == true then
					_Inventory:SetStats(ItemName, ID);
					CurrentSlot2.Pet:WaitForChild("Equipped").Visible = false
					CurrentSlot2.Name = RaritytoSort[_Defenders[ItemName].Rarity];
					_Inventory:SetPetsEquipped();
					InventoryFrame.Container.ScrollingFrame.UIGridLayout:ApplyLayout();
				end
				wait() ClickDebounce = false				
			end
		end
	end
end

function _Inventory:CheckNewPlayer()
	local Data = FetchClientData:InvokeServer(Player);
	local LastJoinedData
	
	local FoundData, NoData = pcall(function()
		LastJoinedData = Data.Data.Player.DailyReward.Group.LastJoined
	end)
	
	pcall(function()
		if Data ~= nil and LastJoinedData ~= nil then
			
		else
			warn("New Player")
			Help.Visible = true
			_Inventory:EquipNew()
			
		end

	end)
	
end

function _Inventory:Int()
	
	
	delay(.2, function() 
		for i, v in pairs(InventoryFrame.Container:GetChildren()) do
			if v:IsA("ScrollingFrame") and v.Name ~= "Container" then
				_Interface:SetCanvasSize(false, 1, v, v.UIGridLayout)
			end
		end
	end)
	
	LoadItemsEvent.OnClientEvent:Connect(function(...)
		_Inventory:LoadItems(...)
	end)
	CreateEvent.OnClientEvent:Connect(function(...)
		_Inventory:LoadInventory(...)
	end)
	UpdatePlayerData.OnClientEvent:Connect(function(...)
		_Inventory:UpdateData(...)
	end)
	UpdateCurrency.OnClientEvent:Connect(function(...)
		_Inventory:ShowCurrencyCollect(...)
	end)
	UpdateLevels.OnClientEvent:Connect(function()
		_Inventory:UpdateLevelStatus(true)
	end)
	
	DeleteButton.MouseButton1Click:Connect(function()
		_Inventory:SwitchMultiDelete()
	end)
	InventoryFrame.DeleteDisplay.Cancel.Click.MouseButton1Click:Connect(function()
		_Inventory:CancelMultiDelete()
	end)
	InventoryFrame.DeleteDisplay.Delete.Click.MouseButton1Click:Connect(function()
		_Inventory:ConfirmMultiDeletePets()
	end)
	MultiDeleteFrame.Yes.Click.MouseButton1Click:Connect(function()
		_Inventory:MultiDeletePets()
	end)
	MultiDeleteFrame.No.Click.MouseButton1Click:Connect(function()
		MultiDeleteFrame.Visible = false
	end)
	--SearchBar:GetPropertyChangedSignal("Text"):Connect(function()

	--end)
	_Inventory:CheckNewPlayer()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		delay(.2, function() 
			for i, v in pairs(InventoryFrame.Container:GetChildren()) do
				if v:IsA("ScrollingFrame") and v.Name ~= "Container" then
					_Interface:SetCanvasSize(false, 1, v, v.UIGridLayout)
				end
			end
		end)
	end)
	
end

return _Inventory;
