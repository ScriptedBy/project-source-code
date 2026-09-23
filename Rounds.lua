--// Manages the complete round system, including wave progression, enemy spawning and scaling, boss encounters, timers, player states, and intermissions.

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local CollectionService = game:GetService("CollectionService");
local HttpService = game:GetService("HttpService");
local RunService = game:GetService("RunService");
local PhysicsService = game:GetService("PhysicsService");

local AFK = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]["AFK"];
local CheckLoading = ReplicatedStorage:WaitForChild("Remotes")["Remote Functions"]["Check Loading"];

local ProfileService = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);
local Waves = require(ReplicatedStorage.Modules.Contents.__Waves)
local Monsters = require(ReplicatedStorage.Modules.Contents.__Monsters)
local Drops = require(ReplicatedStorage.Modules.Contents.__Drops)
local _Animations = require(ReplicatedStorage.Modules.Contents.__Animations)
local Pathfinding = require(ReplicatedStorage.Modules.Contents.__Pathfinding)
local Index = require(ReplicatedStorage.Modules.Contents.__Index)
local Defenders = require(ReplicatedStorage.Modules.Contents.__Defenders)
local _Abbreviation = require(ReplicatedStorage.Modules.Contents.__Abbreviation);

local XP_RARITIES = { [1] = 100, [2] = 100, [3] = 200, [4] = 300, [5] = 400, [6] = 500 };
local CRAFTING = { Normal = 1, Corrupted = 2 };

local pos = 0
local numParts = 5
local radius = 6
local angleIncrement = math.rad(360) / (numParts)

local MaxWave = 10
local WaveCount, WaveSubCount, WaveSpawner = 0, 0, 1
local Intermission = 3
local Debounce = false

local _Rounds = {}
local InRoundProgress = {}
local Cooldown = {}
local Connections = {}

local function GetItem(Mobs)
	local RNG = Random.new(); -- Randomizer
	local Counter = 0; -- Weight
	for i, v in pairs(Mobs) do 
		--print(v)
		Counter += v[2] -- Here's where were going to set our counter for every item in the table, or shall we call it weight.
	end
	local Chosen = RNG:NextNumber(0, Counter); -- Randomize Counter
	for i, v in pairs(Mobs) do 
		Counter -= v[2] 
		if Chosen > Counter then
			return v[1] -- This will return the first array in the table, which is the item we would like to give chosen randomly..
		end
	end
end

local function GenerateUID()
	return HttpService:GenerateGUID(false)
end

local function AddAudio(obj)
	if obj:FindFirstChild("Sound") == nil then
		local Sound = Instance.new("Sound");
		local Clone = Sound:Clone();

		Clone.Looped = true
		Clone.SoundId = "rbxassetid://14023753513"
		Clone.MaxDistance = 55
		Clone.RollOffMode = "InverseTapered"
		Clone.Parent = obj
		
		if obj.Parent.RealName.Value == "Giant Skibi" then
			Clone.Volume = 2
		end
		
		Clone:Play()

		spawn(function()
			while true do
				wait()
				if Clone.TimePosition >= Clone.TimeLength - .02 then
					Clone.TimePosition = 0.01

				end
			end
		end)
	end

end

function _Rounds:GetPlayersAlive(plr)
	if InRoundProgress[plr] ~= nil then
		if InRoundProgress[plr].Alive == true then
			return true
		end
	end
	
	return false
end

function _Rounds:ReturnWaveSet(Wave_Count) 
	if Wave_Count <= 5 then
		
		return "Wave Set 1"
	elseif Wave_Count > 5 and Wave_Count < 10 then
		
		return "Wave Set 2"
	elseif Wave_Count % 10 == 0 then
		--WaveCount = 1
		return "Wave Set 3"
	end
end

local function SetFrames(value)
	for i, v in pairs(workspace.Pets.ServerPets:GetChildren()) do
		for a, b in pairs(v:GetChildren()) do
			for c, d in pairs(b:GetChildren()) do
				if d:IsA("Model") then
					if d:FindFirstChild("Charge") then
						d:FindFirstChild("Charge").Enabled = value
						--d:FindFirstChild("SpecialDisplay").Enabled = value
						--print("TAAAAAAAAAAAAAAA", value)
					end
				end
			end

		end
	end
end

local function SetSpecials(value)
	for i, v in pairs(workspace.Pets.ServerPets:GetChildren()) do
		for a, b in pairs(v:GetChildren()) do
			if b:FindFirstChild("Special") then
				b:FindFirstChild("Special").Value = 0

			end
		end
	end
end

local function HealAllPlayers(v)
	game.Workspace[v]:WaitForChild("Humanoid").Health = game.Workspace[v]:WaitForChild("Humanoid").Health + 1000
end

local InRound = {}
local PlayerAFK = {}
function _Rounds:StartRound(status, timer, playerdata)
	local MapSpawns = workspace.Map.Spawns.Players
	local randomMapSpawns = MapSpawns[math.random(1, #MapSpawns:GetChildren())]
	
	local LobbySpawns = workspace.Lobby.Spawns
	local randomLobbySpawns = LobbySpawns[math.random(1, #LobbySpawns:GetChildren())]
	
	
	
	
	
	for i = 1, MaxWave do
		status.Value = "Round "..i.." starting..."
		

		local PlayersAlive = {}

		for i, v in pairs(Players:GetPlayers()) do
			print(v.PlayerGui.ScreenGui.UI.Loading.Visible)
			if (PlayerAFK[v] == false or PlayerAFK[v] == nil) and CheckLoading:InvokeClient(v) == false then
				-- if player not afk
				table.insert(PlayersAlive, v);
				v.Character:WaitForChild("HumanoidRootPart").CFrame = randomMapSpawns.CFrame + Vector3.new(0, 1, 0)
				InRound[v] = true

				Players.PlayerRemoving:Connect(function()
					table.remove(PlayersAlive, PlayersAlive[v])
				end)

				v.Character.Humanoid.Died:Connect(function()
					table.remove(PlayersAlive, PlayersAlive[v])
					v.Character:WaitForChild("HumanoidRootPart").CFrame = randomLobbySpawns.CFrame + Vector3.new(0, 1, 0)
					InRound[v] = false
				end)

				spawn(function()
					repeat wait() SetFrames(true) until InRound[v] == false
				end)
			end
		end
		
		if i > 1 then
			for i, v in pairs(PlayersAlive) do
				local Data = ProfileService[game.Players[tostring(v)]];
				local PlayerData = Data.Data.Data.Player
				PlayerData.Rounds = PlayerData.Rounds + 1
				HealAllPlayers(tostring(v))
				game.Workspace[tostring(v)]:WaitForChild("HumanoidRootPart").CFrame = randomMapSpawns.CFrame + Vector3.new(0, 1, 0)
			end
		end
		
		
		
		local SetTimer
		
		
		if i == 10 then
			SetTimer = 181
		else
			SetTimer= 120
		end
		wait(5)
		
		print(#PlayersAlive)
		if i >= 1 and i <= 5  and #PlayersAlive > 0 then
			_Rounds:SpawnEnemies(i, i, playerdata)
		elseif i > 5 and #PlayersAlive > 0 then
			_Rounds:SpawnEnemies(i, (i-5), playerdata)
		end
		
		
		local StartTime = tick() 
		print(SetTimer - (tick() - StartTime))
		status.Value = "Round "..i 
		
			
		wait(1)
		repeat wait() timer.Value = SetTimer - (tick() - StartTime) until #workspace:WaitForChild("Enemies"):GetChildren() < 1 or #PlayersAlive < 1 or tick() - StartTime >= SetTimer
		
		if #PlayersAlive < 1 then
			for i, v in pairs(Players:GetPlayers()) do
				InRound[v] = false
			end
			
			for i, v in pairs(PlayersAlive) do
				game.Workspace:WaitForChild(tostring(v)):WaitForChild("HumanoidRootPart").CFrame = randomLobbySpawns.CFrame + Vector3.new(0, 1, 0)
				HealAllPlayers(tostring(v))
			end
			
			SetSpecials()
			status.Value = "Round Over! You lost."
			break
		elseif timer.Value <= 0 and #workspace:WaitForChild("Enemies"):GetChildren() > 0 then
			for i, v in pairs(Players:GetPlayers()) do
				InRound[v] = false
			end
			for i, v in pairs(PlayersAlive) do
				game.Workspace:WaitForChild(tostring(v)):WaitForChild("HumanoidRootPart").CFrame = randomLobbySpawns.CFrame + Vector3.new(0, 1, 0)
				HealAllPlayers(tostring(v))
			end
			SetSpecials()
			
			status.Value = "Round Over! You lost."
			break
		end
		
		if i == 10 then
			status.Value = "Round 10 completed! "
			for i, v in pairs(PlayersAlive) do
				game.Workspace:WaitForChild(tostring(v)):WaitForChild("HumanoidRootPart").CFrame = randomLobbySpawns.CFrame + Vector3.new(0, 1, 0)
			end
			
			for i, v in pairs(Players:GetPlayers()) do
				table.remove(PlayersAlive, PlayersAlive[v])
				InRound[v] = false
				HealAllPlayers(tostring(v))
			end
			SetSpecials()
			wait(5)
			status.Value = "Teleporting back to lobby.."
		end 
	end
	-- 
end


local function AddToGroup(character)
	wait(.2)

	for i, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") then
			
			PhysicsService:SetPartCollisionGroup(v, "Players")
		end
	end
end

function _Rounds:SpawnEnemies(Wave_Count, Wave_Spawner)
	spawn(function()
		for i, v in pairs(Waves[_Rounds:ReturnWaveSet(Wave_Count)]) do
			--if WaveCount 
			
			if v.Boss ~= nil then
				for i = 1, 1 do

					local GetRadItem = v.Boss[1][1]
					local Enemy = ReplicatedStorage.Assets.Enemies[GetRadItem]:Clone();
					local EnemyScript = script.Enemy:Clone();
					local EnemyHealth = Monsters[v.Boss[1][1]].Health.Max;
					local EnemyWalkspeed = Monsters[GetRadItem].Walkspeed
					local Animation = Enemy.Animations
					local BodyGyro = Instance.new("BodyGyro")
					local BodyPosition = Instance.new("BodyPosition")

					for i, v in pairs(_Animations[GetRadItem]) do
						local Animations = Instance.new("Animation");
						Animations.Name = i
						Animations.AnimationId = v
						Animations.Parent = Animation
					end
					
					Enemy.Name = GenerateUID()
					
					Enemy.Humanoid.MaxHealth.Value = EnemyHealth
					Enemy.Humanoid.CurrentHealth.Value = EnemyHealth
					Enemy.Humanoid.Walkspeed.Value = EnemyWalkspeed
					EnemyScript.Parent = Enemy
					
					AddAudio(Enemy.HumanoidRootPart)
					--AddToGroup(Enemy)
					Enemy.HumanoidRootPart.Sound.MaxDistance = 100
					Enemy.HumanoidRootPart.Sound.PlaybackSpeed = 0.7
					Enemy.Parent = workspace:WaitForChild("Enemies");
					Enemy.PrimaryPart.CFrame = workspace.Map.Spawns.Enemy.Boss.CFrame + Vector3.new(0, 3, 0)
					Enemy.HumanoidRootPart:SetNetworkOwner(nil)
					--BodyGyro.Parent = Enemy.HumanoidRootPart
					--BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
					--BodyPosition.Parent = Enemy.HumanoidRootPart
					--BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					--[[Enemy:PivotTo(
						Enemy.PrimaryPart.CFrame * CFrame.new(math.random(0, 50), 0, math.random(-30, 30))
					)]]

					EnemyScript.Enabled = true

				end
				
				spawn(function()
					for i = 1, v.Spawns do

						local GetRadItem = GetItem(v.Mobs);
						local Enemy = ReplicatedStorage.Assets.Enemies[GetRadItem]:Clone();
						local EnemyScript = script.Enemy:Clone();
						local EnemyHealth = math.random(Monsters[GetRadItem].Health.Min, Monsters[GetRadItem].Health.Max);
						local EnemyWalkspeed = Monsters[GetRadItem].Walkspeed
						local EnemySpawns = workspace.Map.Spawns.Enemy
						local randomPart = EnemySpawns[math.random(1, 8)]
						local Animation = Enemy.Animations
						local BodyGyro = Instance.new("BodyGyro")
						local BodyPosition = Instance.new("BodyPosition")

						for i, v in pairs(_Animations[GetRadItem]) do
							local Animations = Instance.new("Animation");
							Animations.Name = i
							Animations.AnimationId = v
							Animations.Parent = Animation

						end
						local NewHealth = math.floor(EnemyHealth * ((Wave_Count or 1)  ^ 1.25))
						Enemy.Humanoid.MaxHealth.Value = NewHealth
						Enemy.Humanoid.CurrentHealth.Value = NewHealth
						Enemy.Humanoid.Walkspeed.Value = EnemyWalkspeed
						Enemy.Name = GenerateUID()
						EnemyScript.Parent = Enemy
						AddAudio(Enemy.HumanoidRootPart)
						
						--AddToGroup(Enemy)
						Enemy.Parent = workspace:WaitForChild("Enemies");
						Enemy.PrimaryPart.CFrame = randomPart.CFrame + Vector3.new(0, 3, 0)
						--BodyGyro.Parent = Enemy.HumanoidRootPart
						---BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
						--BodyPosition.Parent = Enemy.HumanoidRootPart
						--BodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
						Enemy.HumanoidRootPart:SetNetworkOwner(nil)
						EnemyScript.Enabled = true

					end
				end)
			else
				for i = 1, v.Spawns[Wave_Spawner] do
					spawn(function()
						local GetRadItem = GetItem(v.Mobs);
						local Enemy = ReplicatedStorage.Assets.Enemies[GetRadItem]:Clone();
						local EnemyScript = script.Enemy:Clone();
						local Rand = Vector3.new(math.random(-100, 100), 0, 0)
						local EnemyHealth = math.random(Monsters[GetRadItem].Health.Min, Monsters[GetRadItem].Health.Max);
						local EnemyWalkspeed = Monsters[GetRadItem].Walkspeed
						local EnemySpawns = workspace.Map.Spawns.Enemy
						local randomPart = EnemySpawns[math.random(1, 8)]
						local Animation = Enemy.Animations
						-- Create BodyGyro and BodyAngularVelocity objects
						local BodyGyro = Instance.new("BodyGyro")
						local BodyPosition = Instance.new("BodyPosition")



						for i, v in pairs(_Animations[GetRadItem]) do
							local Animations = Instance.new("Animation");
							Animations.Name = i
							Animations.AnimationId = v
							Animations.Parent = Animation

						end
						
						local NewHealth = math.floor(EnemyHealth + ((Wave_Count or 1) ^ 1.25))
						Enemy.Humanoid.MaxHealth.Value = NewHealth
						Enemy.Humanoid.CurrentHealth.Value = NewHealth
						Enemy.Humanoid.Walkspeed.Value = EnemyWalkspeed
						Enemy.Name = GenerateUID()       
						EnemyScript.Parent = Enemy
						AddAudio(Enemy.HumanoidRootPart)
						
						Enemy.Parent = workspace:WaitForChild("Enemies");
						Enemy.PrimaryPart.CFrame = randomPart.CFrame + Vector3.new(0, 3, 0)
						Enemy.HumanoidRootPart:SetNetworkOwner(nil)

						EnemyScript.Enabled = true
					end)
					

				end
			end 
			
		end

	end)
	
end


local IntermissionTime = 25

function _Rounds:Int()
	
	AFK.OnServerEvent:Connect(function(plr, Value)
		PlayerAFK[plr] = Value
		print(PlayerAFK)
	end)
	
	
	for i, v in pairs(Players:GetPlayers()) do
		Players.PlayerRemoving:Connect(function(plr)
			print("Removed")
			table.remove(PlayerAFK, PlayerAFK[v])
		end)
	end
	
	coroutine.wrap(function()
		local Status = workspace.Map.Status
		local Timer = workspace.Map.Timer
		
		while wait() do
			
			
			
			local PlayerCount = #Players:GetChildren()

			if PlayerCount > 0 then
				for i, v in pairs(workspace.Enemies:GetChildren()) do
					if v ~= nil then
						v:Destroy()
					end

				end

				Status.Value = "Intermission..."
				Timer.Value = IntermissionTime

				local StartTime = tick() 
				
				

				repeat wait() Timer.Value = IntermissionTime - (tick() - StartTime) until tick() - StartTime >= IntermissionTime
				_Rounds:StartRound(Status, Timer)


			end

		end
	end)()
	
	
	
end


return _Rounds
