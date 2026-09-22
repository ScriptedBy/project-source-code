--// This project will be filtered between Server scripts, Client Scripts, and Module Scripts and will have brief explainations to what the code does.
--// Manages core server-side player systems, including profile loading, character setup, collision groups, inventory, leaderboards, badges, and player data synchronization.

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local PhysicsService = game:GetService("PhysicsService");
local RunService = game:GetService("RunService")
local Players = game:GetService("Players");
local BadgeService = game:GetService("BadgeService")

Players.CharacterAutoLoads = false

local ProfileService = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
local _Service = require(ReplicatedStorage.Modules.Contents.__Service);
local _Level = require(ReplicatedStorage.Modules.Contents.__Level);
local _Codes = require(ReplicatedStorage.Modules.Contents.__Codes);
local _Cases = require(script.Parent["Server Modules"].__Cases);
local _Server = require(script.Parent["Server Modules"].__Server);
local _Rounds = require(script.Parent["Server Modules"].__Rounds);
local _Special = require(script.Parent["Server Modules"].__Special);
local _Marketplace = require(script.Parent["Server Modules"].__Marketplace);
local _Global = require(script.Parent["Server Modules"].__Global);
local _Invites = require(script.Parent["Server Modules"].__Invites);

local Remotes = ReplicatedStorage:WaitForChild("Remotes");
local FetchClientData = Remotes["Remote Functions"]:WaitForChild("Client Data");
local UpdatePlayerData = Remotes["Remote Events"]:WaitForChild("Update Player Data");


local ServerPets = workspace:WaitForChild("Pets"):WaitForChild("ServerPets");
local ClientPets = workspace:WaitForChild("Pets"):WaitForChild("ClientPets");

local numParts, radius = 5,8
local angleIncrement = math.rad(180) / (numParts - 1)

PhysicsService:RegisterCollisionGroup("Players")
PhysicsService:RegisterCollisionGroup("Defenders")
PhysicsService:RegisterCollisionGroup("Enemies")
PhysicsService:CollisionGroupSetCollidable("Players", "Defenders", false)
PhysicsService:CollisionGroupSetCollidable("Enemies", "Defenders", false)

local function AddToGroup(character)
	wait(.2)

	for i, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
			PhysicsService:SetPartCollisionGroup(v, "Players")
			
		end
	end
	
	for i, v in pairs(ReplicatedStorage.Assets.Defenders:GetChildren()) do
		for a, b in pairs(v:GetChildren()) do
			if b:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(b, "Defenders")
			end
		end

	end
	
	for i, v in pairs(ReplicatedStorage.Assets.Enemies:GetChildren()) do
		for a, b in pairs(v:GetChildren()) do
			if b:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(b, "Enemies")
			end
		end
		
	end
end

local function AwardBadge(plr, id)
	BadgeService:AwardBadge(plr.UserId, id)
end

local function CharacterAdded(Player, Character)
	repeat wait() until Character:WaitForChild("Humanoid");
	local Data = ProfileService[Player];
	local Humanoid = Character:WaitForChild("Humanoid");
	local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart");
	
	_Server:AddItemLocations(Player, numParts, angleIncrement, radius, HumanoidRootPart);
	_Server:AddCollectLocation(Player, HumanoidRootPart)
	--GameFunctions:EquipRadio(Player, Data.Data.Data.Player.Inventory.Radios.Equipped)
	
	AddToGroup(Player.Character)
	
	if Humanoid then
		Humanoid.Died:Connect(function()
			--[[if GetIndex(CurrentPlayers, Player) ~= -1 then
				table.remove(CurrentPlayers, GetIndex(CurrentPlayers, Player))
			end]]
			wait(1)
			if Player then
				Player:LoadCharacter()
				--Remotes.RemoteEvents["Update Leaderboard"]:FireAllClients(FormatLeaderboard());
			end
		end)
	end
end

_Cases:Int()
_Service:Int()
_Special:Int()
_Marketplace:Int()
_Codes:Int()
_Global:Int()

game.Players.PlayerAdded:Connect(function(Player)
	
	wait(1)
	ProfileService.PlayerAdded(Player)
	_Server:CreateItemFolder(Player)
	
	local Data = ProfileService[Player];
	local PlayerData = Data.Data.Data.Player
	_Server:CreateLeaderboard(Player, PlayerData.Coins, PlayerData.Diamonds)
	
	Player.CharacterAdded:Connect(function(Character)
		CharacterAdded(Player, Character)
	end)
	
	Player:LoadCharacter()
	
	_Service:LoadItemsEquipped(Player);
	_Invites:Int(Player)
	_Cases:AddItem(Player, PlayerData, "VIP Security", "Normal", "Gamepass")
	_Cases:AddAmtEquip(Player, "Check")
	AwardBadge(Player, 2148528199)
	
	UpdatePlayerData:FireClient(Player, PlayerData.Level, PlayerData.Prestige);
	_Server:Int(Player);
	spawn(function()
		wait(2)
		while true do
			wait()

			Player.leaderstats:WaitForChild("Coins").Value = PlayerData.Coins
			Player.leaderstats:WaitForChild("Diamonds").Value = PlayerData.Diamonds
			--end
		end
	end)
	
	
end)

FetchClientData.OnServerInvoke = function(Player)
	local PlayerProfile = ProfileService[Player];
	if PlayerProfile ~= nil then
		return PlayerProfile.Data;
	end
	return nil;
end

game.Players.PlayerRemoving:Connect(function(Player)
	local Data = ProfileService[Player];
	local PlayerData = Data.Data.Data.Player
	PlayerData.DailyReward.LastLogin2 = os.time()
	_Service:RemoveFolder(Player)
	ProfileService.PlayerRemoved(Player)
end)

_Server:PlayerRemoving()
_Rounds:Int()
