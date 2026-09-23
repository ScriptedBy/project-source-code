--// Manages core server gameplay systems, including defender combat, positioning, enemy rewards, progression, playtime rewards, and respawn handling.

local TweenSevice = game:GetService("TweenService");
local RunService = game:GetService("RunService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local MarketPlaceService = game:GetService("MarketplaceService");
local PlayerService = game:GetService("Players")

local UpdateCurrency = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]:WaitForChild("Update Currency");

local ProfileService = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
local _Animations = require(ReplicatedStorage.Modules.Contents.__Animations);
local _Defenders = require(ReplicatedStorage.Modules.Contents.__Defenders);
local _Abbreviation = require(ReplicatedStorage.Modules.Contents.__Abbreviation);
local _Specialties = require(ReplicatedStorage.Modules.Contents.__Specialties);
local _Levels = require(ReplicatedStorage.Modules.Contents.__Level);
local _Monsters = require(ReplicatedStorage.Modules.Contents.__Monsters)
local _Drops = require(ReplicatedStorage.Modules.Contents.__Drops)
local _Time = require(ReplicatedStorage.Modules.Contents.__Time)
local _Rewards = require(ReplicatedStorage.Modules.Contents.__Rewards)
local _Service = require(ReplicatedStorage.Modules.Contents.__Service)

--local Crafting = { Normal = 1, Shiny = 2 };
local XP_RARITIES = { [1] = 100, [2] = 100, [3] = 200, [4] = 300, [5] = 400, [6] = 500 };
local CRAFTING = { Normal = 1, Corrupted = 2 };

local Debounce, CheckDeath = false, false

local ServerPets = workspace:WaitForChild("Pets"):WaitForChild("ServerPets");
local ClientPets = workspace:WaitForChild("Pets"):WaitForChild("ClientPets");

local _Server = {}

function _Server:CreateLeaderboard(Player, Coins, Diamonds)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player
	
	local CoinsVal = Instance.new("NumberValue");
	CoinsVal.Name = "Coins"
	CoinsVal.Value = Coins
	CoinsVal.Parent = leaderstats
	
	local DiamondsVal = Instance.new("NumberValue")
	DiamondsVal.Name = "Diamonds"
	DiamondsVal.Value = Diamonds
	DiamondsVal.Parent = leaderstats
	
	local Configurations = script["In-Game Values"]:Clone()
	Configurations.Parent = leaderstats
end

function _Server:CreateItemFolder(Player)
	local PetFolder = Instance.new("Folder"); 
	PetFolder.Name = Player.Name 
	PetFolder.Parent = ServerPets
end

function _Server:AddItemLocations(plr, numParts, angleIncrement, radius, HumanoidRootPart)
	for i = 1, numParts do
		local part = Instance.new("Part")
		part.Size = Vector3.new(2, 2, 2)
		part.BrickColor = BrickColor.new("Bright red")
		part.Anchored = false
		part.CanCollide = false
		part.Massless = true
		part.Transparency = 1
		part.Parent = plr.Character
		part.Name = "Position "..i

		local angle = math.rad(180) - (angleIncrement * (i - 1))
		local offsetX = math.cos(angle) * radius
		local offsetZ = math.sin(angle) * radius

		part.Position = HumanoidRootPart.Position + Vector3.new(offsetX, 0, offsetZ)

		-- Weld the part to the character
		local weld = Instance.new("Weld")
		weld.Part0 = HumanoidRootPart
		weld.Part1 = part
		weld.C0 = CFrame.new(offsetX, 0, offsetZ)
		weld.Parent = HumanoidRootPart
	end
end

function _Server:AddCollectLocation(plr, HumanoidRootPart)
	for i = 1, 1 do
		local part = Instance.new("Part")
		part.Size = Vector3.new(1,1,1)
		part.BrickColor = BrickColor.new("Bright red")
		part.Anchored = false
		part.CanCollide = false
		part.Massless = true
		part.Transparency = 1
		part.Parent = plr.Character
		part.Name = "Collect"

		part.Position = HumanoidRootPart.Position

		-- Weld the part to the character
		local weld = Instance.new("Weld")
		weld.Part0 = HumanoidRootPart
		weld.Part1 = part
		weld.C0 = CFrame.new(0,0,0)
		weld.Parent = HumanoidRootPart
	end
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
	
	
	local Data = ProfileService[game.Players[plr]];
	local PlayerData = Data.Data.Data.Player
	local GetHighestToken, GetHighestXP = GetTotalData(PlayerData);
	local GetHighestDamage = GetDamageData(PlayerData)


	local PetLevel=  (tonumber(Level) * 0.1) + 1;
	if tonumber(PetLevel) < 1 then PetLevel = 1 end

	if Rarity == 6 then
		TokenMul = GetHighestToken * _Defenders[ItemName].Tokens 
		ExpMul = GetHighestXP * _Defenders[ItemName].XP 
		DamageMul = GetHighestDamage * _Defenders[ItemName].Damage 
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


local function TotalMultiplier(plr)
	
	local Data = ProfileService[game.Players[plr]];
	local PlayerData = Data.Data.Data.Player.Inventory.Defenders.Contents
	
	
	local TotalTokens, TotalExp = 0, 0
	for i, v in pairs(PlayerData) do
		if type(v) == "table" then
			local ID, ItemName, Shiny, Level = v[1], v[2], v[6], v[4];
			if v[3] == true  then
				
				local Status = GetStatus(ItemName);
				local TokenMul, ExpMul = GetMultiplier(Status, Level, Shiny, plr);
				
				TotalTokens = TotalTokens + TokenMul
				TotalExp = TotalExp + ExpMul
				
				
				
			end
		end
	end

	return TotalTokens, TotalExp
end

local function AddCurrency(plr, obj, EnemyName, TotalCoins, TotalExperience)
	if plr ~= nil then
		local TokensValue = math.random(_Monsters[EnemyName].Drops.Tokens.Min, _Monsters[EnemyName].Drops.Tokens.Max) or nil;
		local DiamondsValue = math.random(_Monsters[EnemyName].Drops.Diamonds.Min, _Monsters[EnemyName].Drops.Diamonds.Max) or nil;
		local ExperienceValue = math.random(_Monsters[EnemyName].Drops.Experience.Min, _Monsters[EnemyName].Drops.Experience.Max) or nil;
		local DefenderXP = math.random(_Monsters[EnemyName].Drops.DefenderXP.Min, _Monsters[EnemyName].Drops.DefenderXP.Max) or nil;
		local TokensCount = math.random(5,8)
		local DiamondsCount = math.random(2,5)
		local ExperienceCount = math.random(3,6)
		local DefenderXPBoost, TokenBoost, EXPBoost = 1, 1, 1
		
		print(plr)
		--print(TotalCoins, TotalExperience)
		if CheckPass(game.Players[plr], 199495369, "Check") == true then
			DefenderXPBoost = DefenderXPBoost * 2
		end

		if CheckPass(game.Players[plr], 199492932, "Check") == true then
			TokenBoost = TokenBoost * 2
		end
		if CheckPass(game.Players[plr], 199501207, "Check") == true then
			EXPBoost = EXPBoost * 1.5
		end
	

		spawn(function()
			if TokensCount ~= nil then
				_Drops:DropCurrency(plr, obj.HumanoidRootPart.CFrame, (((TokensValue/TokensCount) * (obj.Attacked:FindFirstChild(plr).Value / obj.Humanoid.MaxHealth.Value))*TotalCoins)*TokenBoost, TokensCount, "Coins")
			end
			if DiamondsCount ~= nil then
				_Drops:DropCurrency(plr, obj.HumanoidRootPart.CFrame, ((DiamondsValue/DiamondsCount) * (obj.Attacked:FindFirstChild(plr).Value / obj.Humanoid.MaxHealth.Value)), DiamondsCount, "Diamonds")
			end
			if ExperienceCount ~= nil then
				_Drops:DropCurrency(plr, obj.HumanoidRootPart.CFrame, (((DiamondsValue/DiamondsCount) * (obj.Attacked:FindFirstChild(plr).Value / obj.Humanoid.MaxHealth.Value))*TotalExperience)*EXPBoost, ExperienceCount, "Experience")
			end
			if DefenderXP ~= nil then
				_Levels:AddXP(game.Players[plr], DefenderXP * DefenderXPBoost)
			end
		end)
	end
	
end

local function AddSpecial(plr)

	local Amount = math.floor((math.random(20, 40) /  #workspace.Pets.ServerPets[tostring(plr)]:GetChildren())+0.5)

	for i, v in pairs(workspace.Pets.ServerPets[tostring(plr)]:GetChildren()) do
		local specialValue = v:FindFirstChild("Special")

		if specialValue then
			local newValue = specialValue.Value + Amount
			specialValue.Value = newValue
		end
	end
end

local angle

function _Server:UpdatePosition(plr, v, hrp)
	local numObjects = #workspace.Pets.ServerPets[plr.Name]:GetChildren()
	local hrpx, pety, hrpz
	local EnemyFolder = #workspace.Enemies:GetChildren()
	
	if v:IsA("Folder") then
		if v.Selected.Value == "None"  then
			
			if plr.Character:FindFirstChild("Position 3") ~= nil and plr.Character:FindFirstChild("Position 2") ~= nil and plr.Character:FindFirstChild("Position 4") ~= nil and plr.Character:FindFirstChild("Position 1") ~= nil and plr.Character:FindFirstChild("Position 5") ~= nil then
				
				if numObjects == 1 and v.IndexPos.Value == 1 then
					hrpx, pety, hrpz = plr.Character["Position 3"].Position.X, plr.Character["Position 3"].Position.Y, plr.Character["Position 3"].Position.Z
					
				elseif numObjects == 2 and v.IndexPos.Value == 1 then
					hrpx, pety, hrpz = plr.Character["Position 3"].Position.X, plr.Character["Position 3"].Position.Y, plr.Character["Position 3"].Position.Z
				elseif numObjects == 2 and v.IndexPos.Value == 2 then
					hrpx, pety, hrpz = plr.Character["Position 4"].Position.X, plr.Character["Position 4"].Position.Y, plr.Character["Position 4"].Position.Z

				elseif numObjects == 3 and v.IndexPos.Value == 1 then
					hrpx, pety, hrpz = plr.Character["Position 3"].Position.X, plr.Character["Position 3"].Position.Y, plr.Character["Position 3"].Position.Z
				elseif numObjects == 3 and v.IndexPos.Value == 2 then
					hrpx, pety, hrpz = plr.Character["Position 4"].Position.X, plr.Character["Position 4"].Position.Y, plr.Character["Position 4"].Position.Z
				elseif numObjects == 3 and v.IndexPos.Value == 3 then
					hrpx, pety, hrpz = plr.Character["Position 2"].Position.X, plr.Character["Position 2"].Position.Y, plr.Character["Position 2"].Position.Z

				elseif numObjects == 4 and v.IndexPos.Value == 1 then
					hrpx, pety, hrpz = plr.Character["Position 3"].Position.X, plr.Character["Position 3"].Position.Y, plr.Character["Position 3"].Position.Z
				elseif numObjects == 4 and v.IndexPos.Value == 2 then
					hrpx, pety, hrpz = plr.Character["Position 4"].Position.X, plr.Character["Position 4"].Position.Y, plr.Character["Position 4"].Position.Z
				elseif numObjects == 4 and v.IndexPos.Value == 3 then
					hrpx, pety, hrpz = plr.Character["Position 2"].Position.X, plr.Character["Position 2"].Position.Y, plr.Character["Position 2"].Position.Z
				elseif numObjects == 4 and v.IndexPos.Value == 4 then
					hrpx, pety, hrpz = plr.Character["Position 1"].Position.X, plr.Character["Position 1"].Position.Y, plr.Character["Position 1"].Position.Z

				elseif numObjects == 5 and v.IndexPos.Value == 1 then
					hrpx, pety, hrpz = plr.Character["Position 3"].Position.X, plr.Character["Position 3"].Position.Y, plr.Character["Position 3"].Position.Z
				elseif numObjects == 5 and v.IndexPos.Value == 2 then
					hrpx, pety, hrpz = plr.Character["Position 4"].Position.X, plr.Character["Position 4"].Position.Y, plr.Character["Position 4"].Position.Z
				elseif numObjects == 5 and v.IndexPos.Value == 3 then
					hrpx, pety, hrpz = plr.Character["Position 2"].Position.X, plr.Character["Position 2"].Position.Y, plr.Character["Position 2"].Position.Z
				elseif numObjects == 5 and v.IndexPos.Value == 4 then
					hrpx, pety, hrpz = plr.Character["Position 1"].Position.X, plr.Character["Position 1"].Position.Y, plr.Character["Position 1"].Position.Z
				elseif numObjects == 5 and v.IndexPos.Value == 5 then
					hrpx, pety, hrpz = plr.Character["Position 5"].Position.X, plr.Character["Position 5"].Position.Y, plr.Character["Position 5"].Position.Z

				end
				
				


				if hrpx ~= nil and pety ~= nil and hrpz ~= nil then
					for a, b in pairs(v:GetChildren()) do
						if b:IsA("Model") then
							local hrplv = hrp.CFrame.LookVector
							local base = Vector3.new(hrpx, pety + _Defenders[tostring(b.Name)].HipHeight, hrpz)
							local goalcf = CFrame.new(base - 1 * hrplv, base)
							local humanoidRootPart = b.PrimaryPart
							local distance = (humanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
							
							--if CheckDeath == false then
								if distance > 30 then
									humanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
								end
								if b ~= nil then
									TweenSevice:Create(b.PrimaryPart, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = goalcf}):Play()
								end	
							--end
										
							
						end
					end
					
				end
			end

		else
			local EnemyPositions = workspace.Enemies:FindFirstChild(tostring(v.Selected.Value));
			
			-- Get the necessary references
			if v.IndexPos.Value == 1 then
				angle = math.rad(360) / v.IndexPos.Value
			elseif v.IndexPos.Value == 2 then
				angle = math.rad(360) / v.IndexPos.Value
			elseif v.IndexPos.Value == 3 then
				angle = math.rad(360) / v.IndexPos.Value
			elseif v.IndexPos.Value == 4 then
				angle = math.rad(360) / v.IndexPos.Value
			elseif v.IndexPos.Value == 5 then
				angle = math.rad(360) / v.IndexPos.Value
			end
			
			if EnemyPositions ~= nil then
				if EnemyPositions:FindFirstChild("Humanoid").CurrentHealth.Value > 0 then
					local hrp2 = EnemyPositions.HumanoidRootPart
					
					for a, b in pairs(v:GetChildren()) do
						if b:IsA("Model") then

							local radius = 6

							local offsetX = math.sin(angle) * radius
							local offsetZ = math.cos(angle) * radius
							local goalcf = CFrame.new(hrp2.Position + Vector3.new(offsetX, 0, offsetZ)) -- Adjust the radius as desired


							if b~= nil then

								b.HumanoidRootPart.CFrame = CFrame.new(b.HumanoidRootPart.Position) * CFrame.Angles(0,Vector3.new(CFrame.new(b.HumanoidRootPart.Position, EnemyPositions.HumanoidRootPart.Position):ToOrientation()).Y,0)
								TweenSevice:Create(b.PrimaryPart, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = goalcf}):Play()
							end

						end
					end

		
						

				end
			else
				v.Selected.Value = "None"
			end
			
		end
	end
	
	
	
	for a, b in pairs(workspace.Enemies:GetChildren()) do
		
		spawn(function()
			if b.Humanoid.CurrentHealth.Value <= 2 then
				if Debounce == false then
					Debounce = true

					for c, d in pairs(b.Attacked:GetChildren()) do
						local TotalCoins, TotalExpeience = TotalMultiplier(d.Name)
						AddCurrency(d.Name, b, b.RealName.Value, TotalCoins, TotalExpeience)
						AddSpecial(d.Name)
					end



					wait(1)
					b:Destroy()
					Debounce = false
				end
			end
		end)
		
	end
end

--[[
function UpdatePosition(plr, v, hrp)
	
		
		local TokensValue = math.random(Monsters[EnemyPositions.RealName.Value].Drops.Tokens.Min, Monsters[EnemyPositions.RealName.Value].Drops.Tokens.Max) or nil;
		local DiamondsValue = math.random(Monsters[EnemyPositions.RealName.Value].Drops.Diamonds.Min, Monsters[EnemyPositions.RealName.Value].Drops.Diamonds.Max) or nil;
		local ExperienceValue = math.random(Monsters[EnemyPositions.RealName.Value].Drops.Experience.Min, Monsters[EnemyPositions.RealName.Value].Drops.Experience.Max) or nil;
		local TokensCount = math.random(5,8)
		local DiamondsCount = math.random(2,5)
		local ExperienceCount = math.random(3,6)


		spawn(function()

			if EnemyPositions:FindFirstChild("Humanoid") then
				EnemyPositions.Humanoid.Died:Connect(function()
					local debounce = false
					local Tab = {}

					if debounce == false and v.Selected.Value == EnemyPositions.Name then
						debouce = true

						v.Selected.Value = "None"
						EnemyPositions:FindFirstChild("Enemy").Enabled = false
						--print(TokensCount, DiamondsCount, ExperienceCount)
						if TokensCount ~= nil then
							Drops:DropCurrency(plr, EnemyPositions.HumanoidRootPart.CFrame, TokensValue/TokensCount, TokensCount, "Tokens")
						end
						if DiamondsCount ~= nil then
							Drops:DropCurrency(plr, EnemyPositions.HumanoidRootPart.CFrame, DiamondsValue/DiamondsCount, DiamondsCount, "Diamonds")
						end

						if ExperienceCount ~= nil then
							Drops:DropCurrency(plr, EnemyPositions.HumanoidRootPart.CFrame, ExperienceValue/ExperienceCount, ExperienceCount, "Experience")
						end

						debounce = false
						wait(1)
						EnemyPositions:Destroy()
					end

				end)
			end

			--v.PrimaryPart.Health.Level.Health.Text = "[ "..tostring(CurrentHealth).." / "..tostring(MaxHealth).." ]"

		end)
	end

end]]


--[[
if _Defenders[Name].Specialties ~= nil then
			for i, v in pairs(_Defenders[Name].Specialties) do
				if i == 1 then
					InventoryFrame.Buffs.SPECIAL.USE.Text =  .."!"
elseif i == 2 then
	InventoryFrame.Buffs.SPECIAL.USE.Text = _Specialties[_Defenders[Name].Specialties[1]("Table") ..", ".._Specialties[_Defenders[Name].Specialties[2]("Table") .."!"
end
end

InventoryFrame.Buffs.SPECIAL.Visible = true
else
	InventoryFrame.Buffs.SPECIAL.Visible = false
end

]]


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

function _Server:UpdateResetTimer(plr)

	local Data = ProfileService[game.Players[plr.Name]];
	local PlayerData = Data.Data.Data.Player
	local LastJoinedData
	
	local FoundData, NoData = pcall(function()
		LastJoinedData =  Data.Data.Data.Player.DailyReward.LastLogin2
	end)
	
	pcall(function()
		if Data ~= nil and LastJoinedData ~= nil then
			local TimeNow = os.time();
			local TimeSinceLastClaim =  (TimeNow - LastJoinedData);

			spawn(function()
				print(TimeSinceLastClaim);
				PlayerData.DailyReward.Playtime.TimeReset = PlayerData.DailyReward.Playtime.TimeReset - TimeSinceLastClaim
			end)
		else
			warn("New Player joined for playtime rewards")
			
		end
	
	end)
	
	spawn(function()
		while wait(1) do
			-- take one point away from thing
			if PlayerData.DailyReward.Playtime.TimeReset <= 0 then
				PlayerData.DailyReward.Playtime.TimeReset = _Time.Day
				PlayerData.DailyReward.Playtime.Claim = 7200
				
				for i, v in pairs(PlayerData.DailyReward.Playtime.Rewards) do
					v = false
				end
			else
				PlayerData.DailyReward.Playtime.TimeReset = PlayerData.DailyReward.Playtime.TimeReset - 1;
			end
			
			if PlayerData.DailyReward.Playtime.Claim > 0 then
				PlayerData.DailyReward.Playtime.Claim = PlayerData.DailyReward.Playtime.Claim - 1
			end

		end
	end)
	
end

local function CheckRewards(Player,Type)
	local Data = ProfileService[Player];
	local PlayerData = Data.Data.Data.Player
	

	if Type ~= nil then
		print(Player, Type)
		if (PlayerData.DailyReward.Playtime.Claim - (7200 - _Rewards[Type].Time)) <= 0 and PlayerData.DailyReward.Playtime.Rewards[Type] == false then
			-- Claim Reward
			local CoinAmt = math.random(_Rewards[Type].Rewards.Coins.Min, _Rewards[Type].Rewards.Coins.Max)
			local DiamondAmt = math.random(_Rewards[Type].Rewards.Diamonds.Min, _Rewards[Type].Rewards.Diamonds.Max)
			PlayerData.DailyReward.Playtime.Rewards[Type] = true
			PlayerData.Coins = PlayerData.Coins + CoinAmt
			PlayerData.Diamonds = PlayerData.Diamonds + DiamondAmt


			if Type == "Reward7" then
				local chance = math.random(1, 100)
				local shinychance = math.random(1, 50)
				local shiny

				if chance == 1 then
					if shinychance == 1 then
						shiny = "Corrupted"
					else 
						shiny = "Normal"
					end

					_Service:AddItem(Player, {ItemName = "Titan Speakerman", Shiny = shiny, Level = 1})
				end
			end
			
			UpdateCurrency:FireClient(Player, "Coins", CoinAmt)
			UpdateCurrency:FireClient(Player, "Diamonds", CoinAmt)

		end
	end
	
end

function _Server:GetPlaytimeRewards(plr, name)
	
	
	CheckRewards(plr, name)

end

function _Server:GetGroupReward(plr)
	local Debounce2 = false
	local GroupID = 15225156;
	local Reward = game.Workspace.Lobby.Decore.ChestReward.Reward

	local Data = ProfileService[game.Players[plr.Name]];
	local PlayerData = Data.Data.Data.Player
	local LastJoinedData

	if plr:IsInGroup(GroupID) then

		local FoundData, NoData = pcall(function()
			LastJoinedData = Data.Data.Data.Player.DailyReward.LastLogin2
		end)

		pcall(function()
			if Data ~= nil and LastJoinedData ~= nil then
				local TimeNow = os.time();
				local TimeSinceLastClaim =  (TimeNow - LastJoinedData);

				spawn(function()
					print(TimeSinceLastClaim);
					PlayerData.DailyReward.Group.LastCollectedChest = PlayerData.DailyReward.Group.LastCollectedChest - TimeSinceLastClaim
				end)
			else
				warn("New Player joined for group rewards")
			end
		end)

		--
		spawn(function()
			while wait(1) do
				-- take one point away from thing
				if PlayerData.DailyReward.Group.LastCollectedChest <= 0 then
				else
					PlayerData.DailyReward.Group.LastCollectedChest = PlayerData.DailyReward.Group.LastCollectedChest - 1;
				end

			end
		end)
		--
		Reward.Touched:Connect(function(part)
			if Debounce2 == false and PlayerData.DailyReward.Group.LastCollectedChest <= 0 then
				Debounce2 = true
				print("ran")
				if part.Parent:FindFirstChild("HumanoidRootPart") then
					
					if PlayerData.DailyReward.Group.LastCollectedChest <= 0 then
						PlayerData.DailyReward.Group.LastCollectedChest = 86400;
						local RandDiamonds = math.random(100, 200)
						local RandTokens = math.random(1000, 2000)
						
						PlayerData.Diamonds = PlayerData.Diamonds + RandDiamonds
						PlayerData.Coins = PlayerData.Coins + RandTokens
						
						UpdateCurrency:FireClient(plr, "Coins", RandTokens)
						UpdateCurrency:FireClient(plr, "Diamonds", RandDiamonds)
					end

					Debounce2 = false
				end
			end

		end)

	end

end

local SendTbl = {}

function _Server:UnequipDeath(Player, char)
	
	--local Humanoid = char:WaitForChild("Humanoid")

	--Humanoid.Died:Connect(function()
		SendTbl[Player] = {}
		for i, v in pairs(ServerPets[Player.Name]:GetChildren()) do
			table.insert(SendTbl[Player], {ItemName = tostring(v.ItemName.Value); ID = v.ID.Value; Shiny = v.Shiny.Value, Level = v.Level.Value})
			print(SendTbl[Player])
			wait(.1)
			for i, v in pairs(SendTbl[Player]) do
				print(i)
				_Service:Handle(Player, "Unequip", v, "Server")
			end
			
		end
	--end)
	
end

function _Server:EquipRespawn(Player)
	for i, v in pairs(SendTbl[Player]) do
		print(v)
		_Service:Handle(Player, "Equip", v, "Server")
	end
end

function _Server:PlayerRemoving()
	game.Players.PlayerAdded:Connect(function(plr)
		table.remove(SendTbl, SendTbl[plr])
	end)
end


function _Server:Int(plr)
	_Server:GetGroupReward(plr)
	_Server:GetPlaytimeRewards(plr)
	_Server:UpdateResetTimer(plr)
--
	
	spawn(function()
		plr.CharacterRemoving:Connect(function(char)
			_Server:UnequipDeath(plr, char)
		end)
		
		plr.CharacterAdded:Connect(function(char)
			wait(2)
			_Server:EquipRespawn(plr)
		end)

	end)
	
	spawn(function()
		RunService.Heartbeat:Connect(function()
			if plr ~= nil and plr.Character ~= nil then
				local plrServerPets = workspace.Pets.ServerPets:WaitForChild(plr.Name)
				
				for a,b in pairs(workspace.Enemies:GetChildren()) do
					if b:IsA("Model") then
						local MaxHealth = b.Humanoid.MaxHealth.Value
						local CurrentHealth = b.Humanoid.CurrentHealth.Value

						if b:FindFirstChild("Humanoid") ~= nil then
							local Level = b.PrimaryPart.Health.Level
							local Change = CurrentHealth / MaxHealth;

							PlayerXPBar(Level.LevelBar, Change);
							b.PrimaryPart.Health.Level.Health.Text = "[ "..tostring(b.Humanoid.CurrentHealth.Value).." / "..tostring(b.Humanoid.MaxHealth.Value).." ]"
						end
						
					end
				end
			
				for i, v in pairs(plrServerPets:GetChildren()) do
					task.defer(function()
						_Server:UpdatePosition(plr, v, plr.Character.PrimaryPart)
					end)
					
				end
				
				
				--CheckSpecial(plr)
				
			end
		end)
	end)
end


return _Server;
