--// Manages client-side round updates, including timers, camera shake effects, currency drop cleanup, and visibility of other players’ defender interfaces.

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

repeat wait() until Players.LocalPlayer;
local Player = Players.LocalPlayer;
local PlayerUI = Player:WaitForChild("PlayerGui");
local ScreenUI = PlayerUI:WaitForChild("ScreenGui");
local UIFrame  = ScreenUI:WaitForChild("UI");
local Round = UIFrame:WaitForChild("Round")

local FetchClientData = ReplicatedStorage.Remotes["Remote Functions"]["Client Data"];
local _Defenders = require(ReplicatedStorage.Modules.Contents.__Defenders);
local Shake = ReplicatedStorage.Remotes["Remote Events"]:WaitForChild("Shake")

local _Rounds = {}

local function formatTime(duration)
	local minutes = math.floor(duration / 60)
	local seconds = math.floor(duration % 60)

	-- Format the time as "mm:ss"
	local formattedTime = string.format("%02d:%02d", minutes, seconds)

	return formattedTime
end

function _Rounds:DestroyCurrency()
	local Drops = workspace.Drops

	if #Drops:GetChildren() > 0  then
		for i, v in pairs(Drops:GetChildren()) do
			if v.Player.Value == Player.Name then
				
			else
				v:Destroy()
			end 
		end
	end

end

function _Rounds:DestroyFrames()
	local plrPets = workspace.Pets.ServerPets
	
	for i, v in pairs(plrPets:GetChildren()) do
		if v.Name ~= Player.Name then
			if #v:GetChildren() > 0 then
				for a, b in pairs(v:GetChildren()) do
					if b:IsA("Model") then
						if b:FindFirstChild("Charge") ~= nil and b:FindFirstChild("SpecialDisplay") ~= nil then
							b:FindFirstChild("Charge").Enabled = false
							b:FindFirstChild("SpecialDisplay").Enabled = false
						end
					end
				end
			end
		end
		
	end

end

function _Rounds:CreateShake()
	
		local camera = workspace.CurrentCamera

		local duration = 5 -- Shake duration in seconds
		local magnitude = 0.05 -- Magnitude of the camera shake
	local startTime = tick() -- Get the starting time
	spawn(function()
		-- Update the camera position continuously for the specified duration
		while tick() - startTime < duration do
			local shakeOffset = Vector3.new(
				math.random(-magnitude, magnitude),
				math.random(-magnitude, magnitude),
				math.random(-magnitude, magnitude)
			)
			camera.CFrame = camera.CFrame + shakeOffset

			wait(0.05) -- Wait for a short time before updating the camera position again
		end
	end)
		
	

	
end

function _Rounds:Int()
	
	local Status = game.Workspace.Map.Status
	local Timer = game.Workspace.Map.Timer
	
	-- Listen for the shake camera event
	Shake.OnClientEvent:Connect(function()
		_Rounds:CreateShake()
	end)
	
	while wait() do
		_Rounds:DestroyFrames()
		_Rounds:DestroyCurrency()
		
		Round.Rounds.Text = Status.Value
		if Timer.Value >= 0  then
			Round.Counter.Timer.Text = formatTime(Timer.Value)
		end
	end
end

return _Rounds;
