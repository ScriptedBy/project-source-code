--// Controls enemy AI by finding nearby players, calculating movement paths, and pursuing targets using pathfinding and movement logic.

local Pathfinding = game:GetService("PathfindingService");
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");


local _Animations = require(script.Parent.__Animations);

local waypoints
local nextWaypointIndex
local ReachaedConnection
local BlockedConnection

local WalkSpeed
local SprintSpeed
local Damage = 1
local MaxDistance

local _Pathfinding = {}

function _Pathfinding:GetPath(Enemy, target)
	local pathparams = {
		AgentHeight = 5,
		AgentRadius = 4,
		AgentCanJump = true,
		AgentCanClimb = true
	}

	local path = Pathfinding:CreatePath(pathparams)
	if target ~= nil then
		Enemy.HumanoidRootPart.CFrame = CFrame.new(Enemy.HumanoidRootPart.Position) * CFrame.Angles(0,Vector3.new(CFrame.new(Enemy.HumanoidRootPart.Position, target.HumanoidRootPart.Position):ToOrientation()).Y,0)
		path:ComputeAsync(Enemy.HumanoidRootPart.Position, target.PrimaryPart.Position);
	end
	

	return path
end

function _Pathfinding:FindTarget(Enemy)
	local nearestTarget
	local MaxDistance  = math.huge

	for i, v in pairs(Players:GetPlayers()) do
		if v.Character then
			local target = v.Character
			if target:FindFirstChild("HumanoidRootPart")  and Enemy:FindFirstChild("HumanoidRootPart") then
				local dist = (Enemy.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
				local LookVector = (target.PrimaryPart.Position - Enemy.PrimaryPart.Position).Unit

				if dist < MaxDistance then
					nearestTarget = target
					MaxDistance = dist
				end
			end
			
		end
	end

	return nearestTarget;
end

function _Pathfinding:GetDefender(Enemy, Defender)

	for i, v in pairs(Players:GetPlayers()) do
		if v.Character then
			local target = Defender
			if Enemy:FindFirstChild("HumanoidRootPart") then
				local dist = (Enemy.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
				if dist < 10 then
					return true
				end
			end
			
			
		end
	end

	return false;
end

function _Pathfinding:Capture(Enemy, target, Cooldown)
	if Enemy:FindFirstChild("HumanoidRootPart") then
		local dist = (Enemy.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
		local speed = Enemy.Humanoid.Walkspeed.Value
		local timeToReach = dist / speed
		local tweenInfo = TweenInfo.new(timeToReach, Enum.EasingStyle.Linear)

		if Enemy.Humanoid.CurrentHealth.Value > 2 then
			timeToReach = 0
		end
		
		if Cooldown[Enemy] == false then
			--if dist > 5  then
			local tween = game:GetService("TweenService"):Create(Enemy.PrimaryPart, tweenInfo, {Position = target.HumanoidRootPart.Position})
			tween:Play()
		end
	end
	
end

function _Pathfinding:WalkTo(Enemy, Cooldown)
	local Target = _Pathfinding:FindTarget(Enemy);
	local path = _Pathfinding:GetPath(Enemy, Target);
	
	if path.Status == Enum.PathStatus.Success then
		for a, b in pairs(path:GetWaypoints()) do
			if _Pathfinding:FindTarget(Enemy) then
				_Pathfinding:Capture(Enemy, Target, Cooldown)
			end
			
		end
	end
	
end

return _Pathfinding; 
