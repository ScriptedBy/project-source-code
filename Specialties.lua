--// Implements defender special abilities, including healing, shields, area damage, combat effects, and player damage tracking.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Shake = ReplicatedStorage.Remotes["Remote Events"]:WaitForChild("Shake")

function GetPlayersWhoAttacked(plr, obj, Damage)

	if obj.Attacked:FindFirstChild(plr) ~= nil then
		local TotalDamage = obj.Attacked:FindFirstChild(plr).Value
		TotalDamage = TotalDamage + Damage
	else
		local PlayersAttacked = Instance.new("NumberValue")
		PlayersAttacked.Name = plr.Name
		PlayersAttacked.Value = PlayersAttacked.Value + Damage
		PlayersAttacked.Parent = obj.Attacked
	end
end

local function tweenLighting(times, target)
	-- Create a tween
	local tween = game:GetService("TweenService"):Create(Lighting, TweenInfo.new(times), target)

	-- Play the tween
	tween:Play()
	tween.Completed:Wait() -- Wait for the tween to complete
end

-- Function to shake the camera
local function shakeCamera()
	local camera = workspace.CurrentCamera
	local startTime = tick() -- Get the starting time
	-- Define the parameters for the camera shake
	local duration = 5 -- Shake duration in seconds
	local magnitude = 1 -- Magnitude of the camera shake
	
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

local _Specialties = {
	
	["Heal Medic"] = function(Type, plr)
		if Type == "Table" then
			-- return values
			return "Heals you by 5% for 5 seconds"
		elseif Type == "Battle" then
			if plr ~= nil then
				
				local Effect = script.Assets.Effects.Healing:Clone()
				Effect.Parent = workspace[plr.Name]:WaitForChild("HumanoidRootPart")
				
				for i=1, 5 do
					wait(5)
					workspace[plr.Name].Humanoid.Health = workspace[plr.Name].Humanoid.Health + (workspace[plr.Name].Humanoid.MaxHealth / 5)
				end
				wait(1)
				Effect:Destroy()
			end
			
			
			-- in battle
		end
	end,
	
	["Competitor"] = function(Type)

		if Type == "Table" then
			-- return values
			return "Significantly stronger than your best defender"
		end
	end,
	
	["Camera Boom"] = function(Type, plr, Damage)

		if Type == "Table" then
			-- return values
			return "Creates an earthquake and within a certain range"
		elseif Type == "Battle" then
			local Enemies = game.Workspace.Enemies
			local playerRange = 30 -- Maximum range to consider humanoid parts

		
			local humanoid = plr.Character:WaitForChild("Humanoid")
			local character = plr.Character

			-- Create the red circular platform
			local platform = Instance.new("Part")
			platform.Name = "PlayerRangeIndicator"
			platform.Size = Vector3.new(playerRange * 2, 0.2, playerRange * 2)
			platform.BrickColor = BrickColor.new("Bright red")
			platform.Material = Enum.Material.SmoothPlastic
			platform.Transparency = 0.8
			platform.Anchored = false
			platform.CanCollide = false
			platform.Massless = true
			platform.Parent = workspace

			
			-- Create a Weld constraint to attach the platform to the player's feet
			local weld = Instance.new("Weld")
			weld.Name = "PlayerRangeWeld"
			weld.Part0 = character.HumanoidRootPart
			weld.Part1 = platform
			weld.C1 = CFrame.new(0, -character.HumanoidRootPart.Size.Y / 2, 0) -- Offset to attach at the bottom of the player's feet
			weld.Parent = character.HumanoidRootPart
			platform.Parent = workspace
			Shake:FireClient(plr)
			
			wait(4)
			
			-- Apply damage to humanoids within range
			for _, humanoidPart in pairs(Enemies:GetChildren()) do
				local distance = (humanoidPart.HumanoidRootPart.Position - humanoid.Parent.HumanoidRootPart.Position).Magnitude
				if distance <= playerRange then
					if Damage > humanoidPart.Humanoid.CurrentHealth.Value  then
						GetPlayersWhoAttacked(plr, humanoidPart, humanoidPart.Humanoid.CurrentHealth.Value)
					else
						GetPlayersWhoAttacked(plr, humanoidPart, Damage)
					end
					humanoidPart:FindFirstChildOfClass("Humanoid").CurrentHealth.Value  = humanoidPart:FindFirstChildOfClass("Humanoid").CurrentHealth.Value - Damage
				end
			end
	
			platform:Destroy()
			
		end
	end,	
	["Shield"] = function(Type, plr)

		if Type == "Table" then
			-- return values
			return "Shields you for 10 seconds!"
		elseif Type == "Battle" then
			
			if plr ~= nil then
				
				local Effect = script.Assets.Effects.Shield:Clone()
				Effect.Parent = workspace[plr.Name]:WaitForChild("HumanoidRootPart")
				local Humanoid = workspace[plr.Name].Humanoid
				
				local Time = false
				local lastHealth = Humanoid.Health
				
				spawn(function()
					for i=1, 10 do
						wait(1)
						if i == 10 then
							Time = true
							wait(1)
							Effect:Destroy()
						end
					end	
				end)
			
				Humanoid.HealthChanged:Connect(function()
					if Time == false then
						Humanoid.Health = lastHealth
					end
					
				end)
			end
		end
	end,
	["Barrage"] = function(Type, plr, Damage)

		if Type == "Table" then
			-- return values
			return "1 time use for dealing damage to every mob per wave"
		elseif Type == "Battle" then
			-- in battle
			local Enemies = game.Workspace.Enemies
			local Titan = ReplicatedStorage.Assets.Defenders.Special_Titan:Clone()
			local AnimationID = Titan.Cutscene:WaitForChild("Animation")

			if #Enemies:GetChildren() > 0 then
				Titan.Parent = workspace

				wait()
				local Anim = Titan:WaitForChild("Humanoid"):LoadAnimation(AnimationID)
				Anim:Play()

				Anim.Stopped:Wait()

				for i, v in pairs(Titan.Tween:GetChildren()) do
					v.Transparency = 0.85
					--v.Position = Vector3.new(-6.837, 0.382, 82.907) + Vector3.new(0, 2, 0)

				end

				local scaleTween = game:GetService("TweenService"):Create(Titan.Tween.Shockwave, TweenInfo.new(2, Enum.EasingStyle.Linear), {Position = Vector3.new(405.23, 44.414, -171.305), Size = Vector3.new(201.555, 42.764, 211.926)})
				local scaleTween2 = game:GetService("TweenService"):Create(Titan.Tween.Shockwave2, TweenInfo.new(2, Enum.EasingStyle.Linear), {Position = Vector3.new(405.23, 63.355, -171.306), Size = Vector3.new(380.101, 80.646, 399.659)})
				local scaleTween3 = game:GetService("TweenService"):Create(Titan.Tween.Shockwave3, TweenInfo.new(2, Enum.EasingStyle.Linear), {Position = Vector3.new(405.23, 85.839, -171.306), Size = Vector3.new(523.241, 164.372, 550.152)})
				scaleTween:Play()
				scaleTween2:Play()
				scaleTween3:Play()		

				for i, v in pairs(Enemies:GetChildren()) do
					if v~= nil then
						if Damage*2 > v.Humanoid.CurrentHealth.Value  then
							GetPlayersWhoAttacked(plr, v, v.Humanoid.CurrentHealth.Value )

						else
							GetPlayersWhoAttacked(plr, v, Damage*2)
						end
						v:FindFirstChild("Humanoid").CurrentHealth.Value = v:FindFirstChild("Humanoid").CurrentHealth.Value   - (Damage*2)
					end
				end

				scaleTween3.Completed:Wait()
				Titan:Destroy() 
			end
		end
	end,
	
	["Barrage 2"] = function(Type, plr, Damage)

		if Type == "Table" then
			-- return values
			return "1 time use for dealing damage to every mob per wave"
		elseif Type == "Battle" then
			-- in battle
			local Enemies = game.Workspace.Enemies
			local Titan = ReplicatedStorage.Assets.Defenders.Special_Titan_Camera:Clone()
			local AnimationID = Titan.Cutscene:WaitForChild("Animation")

			if #Enemies:GetChildren() > 0 then
				Titan.Parent = workspace

				wait()
				local Anim = Titan:WaitForChild("Humanoid"):LoadAnimation(AnimationID)
				Anim:Play()
				-- Tween the lighting from morning to night
				
				Lighting.TimeOfDay = 14*60
				--Lighting:SetMinutesAfterMidnight(8 * 60)
				Anim.Stopped:Wait()
				
				for i, v in pairs(Enemies:GetChildren()) do
					if v:FindFirstChild("HumanoidRootPart") then
						local CloneEffect = script.Assets.Effects.Shock:Clone()
						CloneEffect.Parent = v:FindFirstChild("HumanoidRootPart")



					end

				end
				
				
				wait(3)
				for i, v in pairs(Enemies:GetChildren()) do
					if v~= nil then
						if Damage*2 > v.Humanoid.CurrentHealth.Value  then
							GetPlayersWhoAttacked(plr, v, v.Humanoid.CurrentHealth.Value )

						else
							GetPlayersWhoAttacked(plr, v, Damage*2)
						end
						if v:FindFirstChild("Humanoid") then
							v:FindFirstChild("Humanoid").CurrentHealth.Value = v:FindFirstChild("Humanoid").CurrentHealth.Value   - (Damage*2)
						end
						
					end
				end
				
				print("Destrpy)_")
				Lighting.TimeOfDay = 21*60
				Titan:Destroy() 
			end
		end
	end,
	
}
return _Specialties; 

--functiontable["name of function"]("Hello", "World!")
