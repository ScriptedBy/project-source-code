--// Generates unique collectible currency drops with randomized physics, player ownership, and automatic cleanup.

local HttpService = game:GetService("HttpService");
local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local CollectionService = game:GetService("CollectionService");

local _Level = require(ReplicatedStorage.Modules.Contents.__Level);
local Debounce = false

local _Drops = {}
local Connections = {}

function _Drops:GenerateUID()
	return HttpService:GenerateGUID(false)
end

local function AddToGroup(character)
	wait(.2)

	for i, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		--	PhysicsService:SetPartCollisionGroup(v, "Players")
		end
	end
end


function _Drops:DropCurrency(plr, origin, amount, total, Type)
	
	spawn(function()
		for i = 1, total do
			local Clone = script[Type]:Clone();
			local ScriptClone = script.Follow:Clone();

			Clone.Name = _Drops:GenerateUID()
			Clone.CFrame = origin
			Clone.Value.Value = amount
			Clone.Player.Value = plr
			Clone.Type.Value = Type
			Clone.Parent = workspace.Drops

			ScriptClone.Parent = Clone
			ScriptClone.Enabled = true
			Clone.CanCollide = false


			local RandomX = {math.random(-5,-2), math.random(2,5)}
			local RandomZ = {math.random(-5,-2), math.random(2,5)}

			local velocity = Vector3.new(RandomX[math.random(1,2)], math.random(50, 100), RandomZ[math.random(1,2)])
			Clone.AssemblyLinearVelocity = velocity
			Clone.CanCollide = true
			
			spawn(function()
				wait(30)
				Clone:Destroy()
			end)

		end
		
	end)
	
end

return _Drops;
