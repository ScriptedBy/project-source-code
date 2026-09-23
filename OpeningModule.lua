--// Manages crate-opening animations and UI, including item probabilities, rarity displays, collection tracking, visual effects, and single or multi-item reveals.

local Players = game:GetService("Players");
local HttpService = game:GetService("HttpService");
local RunService = game:GetService("RunService");
local TweenService = game:GetService("TweenService");
local StarterGui = game:GetService("StarterGui");
local InsertService = game:GetService("InsertService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

repeat wait() until Players.LocalPlayer;
local Player = Players.LocalPlayer;
local PlayerUI = Player:WaitForChild("PlayerGui");
local ScreenUI = PlayerUI:WaitForChild("ScreenGui");
local UIFrame  = ScreenUI:WaitForChild("UI");
local CaseUI = UIFrame:WaitForChild("CaseUI");

local UIClones = script.Parent:WaitForChild("Assets").CrateDisplay;
--local LegendaryEffects = script.Parent:WaitForChild("Assets").LegendaryEffects;

local Remotes = ReplicatedStorage.Remotes;
local FetchClientData = Remotes["Remote Functions"]:WaitForChild("Client Data");

local Camera = game.Workspace.CurrentCamera;
local cameraOffset = CFrame.new(0, 0, -4) * CFrame.Angles(0, math.rad(180), 0)

local _Defenders = require(ReplicatedStorage.Modules.Contents.__Defenders);
local _Crates = require(ReplicatedStorage.Modules.Contents.__Crates);
local _Service = require(ReplicatedStorage.Modules.Contents.__Service);
local _Chat = require(script.Parent.Parent.__Chat);

--crateHandlerModule

local _Opening = {}

local GetName = function(Name, Shiny)
	if Shiny == true then
		return "Corrupted "..tostring(Name)
	end

	return tostring(Name)
end

function GetStatus(Name)
	if _Defenders[tostring(Name)] == nil then
		warn("No pet stats found in..", tostring(Name))
		return _Defenders.Name
	end
	return _Defenders[tostring(Name)];
end

local GetRarity = function(rName)
	local Status = GetStatus(rName)
	return Status.Rarity
end

local GetStringValue = function(Num)
	if Num ~= math.floor(Num) then
		if string.len(tostring(Num)) == 3 then
			return string.format("%.1f", tonumber(Num))
		else	
			return string.format("%.2f", tonumber(Num))
		end
	else
		return tostring(Num)
	end
end

local gameInterfaceUI = function(val)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, val)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, val)
end

local TweenFunc = function(Position, Info1, Info2, Info3, Speed, Value, Value2, Cframe1, Cframe2, CFrame3)
	-- Example: TweenFunc(Position, TweenInfo.new(1/1.7, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out, 0, false, 0, CFrame.new(0,.5,0));
	TweenService:Create(Position, TweenInfo.new(Info1, Enum.EasingStyle[Info2], Enum.EasingDirection[Info3], Speed, Value, Value2), {
		Value = CFrame.new(Cframe1, Cframe2, CFrame3);
	}):Play()
end

local GetIndex = function(Data, Name)
	local Index = Data.Data.Player.Inventory.Index;
	for i, v in pairs(Index) do
		if tostring(v) == tostring(Name) then
			return true
		end
	end
	return false
end

local function FindTypeForPercentage(CrateName, CrateFrame)
	local Pets = _Service.GetChances(Player, CrateName);
	local tbl = Pets 
	table.sort(tbl, function(a, b) 
		return a[3] < b[3] 
	end)
	local Data = FetchClientData:InvokeServer(Player)
	if Data ~= nil then
		for a, b in pairs(tbl) do
			local Name, Percentage = b[1], b[2];
			local Status = GetStatus(tostring(Name)); 
			if Name ~= nil then
				local obj = CrateFrame:FindFirstChild(Name);
				if obj ~= nil then
					local percent = GetStringValue(Percentage);
					obj.Container.Percentage.Text = tostring(percent).."%"

					local Holder = obj.Container
					if Holder then
						local Get_Index = GetStatus(tostring(Name));
						if Get_Index == true then
							Holder.ImageColor3 = Color3.fromRGB(255, 255, 255);
						else
							Holder.ImageColor3 = Color3.fromRGB(1, 1, 1);
						end
					end
				end
			else
				warn("Didnt find item")
			end
		end
	end
end

function _Opening:ChangePercentage(Player, CrateName)
	spawn(function()
		for i, v in pairs(_Crates[CrateName]) do
			local CaseFrame = CaseUI:FindFirstChild(CrateName);
			if _Crates[CrateName] and CaseFrame ~= nil then
				FindTypeForPercentage(CrateName, CaseFrame)
			end
		end
	end)
end

local function LoadTypeForPercentage(CrateName, CaseFrame)
	local Pets = _Service.GetChances(Player, CrateName);
	local tbl = Pets table.sort(tbl, function(a, b) 
		return a[3] < b[3] 
	end)
	local Data = FetchClientData:InvokeServer(Player)
	local Frame = CaseFrame.Hotkey.Data.Container
	if Data ~= nil then
		for a, b in pairs(tbl) do
			local Name, Percentage, Index = b[1], b[2], b[3];
			local Status = GetStatus(tostring(Name));
			if Name ~= nil then
				local Clone = script.ItemFrame:Clone();
			
				local Rarity = GetRarity(tostring(Name));

				local Percent = GetStringValue(Percentage);
				Clone.Container.Percentage.Text = Percent .."%";
				-- Text color
				
				Clone.Name = tostring(Name)
				Clone.Container.Rarity.Text = tostring(Rarity);

				-- Rarity Color
				Clone.Container.Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=420&height=420&assetId=".._Defenders[tostring(Name)].Image;


				local Holder = Clone
				if Holder:FindFirstChild("Container") then
					local Get_Index = GetIndex(Data, tostring(Name));
					if Get_Index == true then
						Holder.Container.ImageColor3 = Color3.fromRGB(255, 255, 255);
					else
						Holder.Container.ImageColor3 = Color3.fromRGB(1, 1, 1);
					end
				end;
				
				local obj = Frame:FindFirstChild(Name)
				
				if obj == nil then
					Clone.Parent = Frame
				end
				
				
			else
				warn("Didnt find pet")
			end
		end
	end
end

function _Opening:LoadItems(Player, CrateName)
	spawn(function()
		for i, v in pairs(_Crates[CrateName]) do
			local CaseFrame = CaseUI:FindFirstChild(CrateName);
			if _Crates[CrateName] and CaseFrame ~= nil then
				LoadTypeForPercentage(CrateName, CaseFrame)
			end
		end
	end)
end

function _Opening:SetOtherFramesFalse(Type)
	if Type == false then
		for i, v in pairs(CaseUI:GetChildren()) do
			v.Enabled = false
		end
		for i, v in pairs(UIFrame:GetChildren()) do
			if v:IsA("Frame") and v.Name ~= "Trading" then
				v.Visible = false
			end
		end
	elseif Type == true then
		for i, v in pairs(CaseUI:GetChildren()) do
			v.Enabled = true
		end
		for i, v in pairs(UIFrame:GetChildren()) do
			if v:IsA("Frame") then --and v.Name == "Leaderboard" and v.Name == "Sidebar" then
				if v.Name == "Left" or v.Name == "Bottom" or v.Name == "Leaderboard" or v.Name == "TradeRequest"  or v.Name == "Round" then
					v.Visible = true
				end
				--v.Visible = true
			end
		end
	end

end

local RARITIES = {
	[1] = "COMMON",
	[2] = "COMMON",
	[3] = "COMMON",
	[4] = "LEGENDARY",
	[5] = "MYTHIC",
	[6] = "TITANIC"
	
}
function _Opening:OpenCrate(ItemName, DefenderName, New, Offset, Index, Shiny, AutoDelete, Auto, Increment)

	print(DefenderName)
	Offset = Offset or cameraOffset;
	Increment = Increment or Vector3.new(0, 0, 0)
	gameInterfaceUI(false);
	_Opening:SetOtherFramesFalse(false);
	
	
	local SpeedDiv = 1;
	local Gui = ScreenUI;
	local HatchFrame;
	local Case;
	local Item;
	local Debounce = true
	local Audio = script.Parent.Assets["Crate Open"]:Clone()
	

	local function SetHatchFrames()
		HatchFrame = Index and (Gui:FindFirstChild("MultiOpen") or script.MultiOpen:Clone()) or script.Open:Clone()

		if Index == nil then
			local rName, Typ = GetName(DefenderName, Shiny);
			local Rarity = GetRarity(DefenderName);
			local Assets = script.Parent.Assets
			local CloneRar = Assets.Rarities[tostring(Rarity)]:Clone()
			
			
			HatchFrame.Container.Rarity.Text = RARITIES[Rarity];
			CloneRar.Enabled = true
			CloneRar.Parent = HatchFrame.Container.Rarity
			HatchFrame.Container.ItemName.Text = rName;

			-- Rarity[Colors] later
			HatchFrame.Visible = false;
			HatchFrame.Parent = Gui;
		else
			if not HatchFrame.Parent then
				--HatchFrame.Visible = true;
				HatchFrame.Parent = Gui
			end

			if Index ~= nil then
				if type(Index) ~= "boolean" then
					local Strength 
					
					if Index == 1 then
						Strength = "Container" .. tostring(3);
					end
					if Index == 2 then
						Strength = "Container" .. tostring(2);
					end
					if Index == 3 then
						Strength = "Container" .. tostring(1);
					end
						
					if HatchFrame:FindFirstChild(Strength) ~= nil and Strength ~= nil then
						local Frame = HatchFrame[Strength]
						local rName, Typ = GetName(DefenderName, Shiny);
						
						local Rarity = GetRarity(DefenderName);
						local Assets = script.Parent.Assets
						local CloneRar = Assets.Rarities[tostring(Rarity)]:Clone()

						Frame.Rarity.Text = RARITIES[Rarity];
						CloneRar.Enabled = true
						CloneRar.Parent = Frame.Rarity
						Frame.ItemName.Text = rName;

					else
						warn("Did not find pet frame")
					end
				else
					warn("Pet Index is boolean")
				end
			end
		end
	end
	
	SetHatchFrames();
	local function CreateCrate()
		Case = ReplicatedStorage.Assets.Crates:FindFirstChild(ItemName):Clone();
		Case.Name = "Crate"
		

		for i, v in pairs(Case:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
		
		if workspace.Items:FindFirstChild("Crate Open") then
			
		else
			Audio.Parent = workspace.Items
			Audio:Play()
		end
		
		
		Case.Parent = workspace;
	end
	CreateCrate();


	local Glow = script.Parent.Assets:WaitForChild("Glow"):Clone()
	local Position = Instance.new("CFrameValue")
	local con = RunService.RenderStepped:Connect(function()
		local viewport_size = Camera.ViewportSize
		local camera_ray = Camera:ViewportPointToRay(viewport_size.X / 2, viewport_size.Y / 2)
		local targetPosition = Camera.CFrame * Offset
		-- = CFrame.lookAt(Case.PrimaryPart.Position, camera_ray.Origin + camera_ray.Direction )

		Case:SetPrimaryPartCFrame(targetPosition * Position.Value)
		local goal = CFrame.lookAt(Case.PrimaryPart.Position, camera_ray.Origin ) -- Update goal using the adjusted camera_ray.Origin
		Case:SetPrimaryPartCFrame(goal)
	end)
	

	--        Position, Info1,  Info2,   Info3, Speed, Value, Value2
	TweenFunc(Position, 1/(1.7 * SpeedDiv), "Bounce", "Out", 0, false, 0,0, 0, 1);
	wait(.75 / SpeedDiv)
	TweenFunc(Position, 1/(1.5 * SpeedDiv), "Bounce", "Out", 0, false, 0, 0, 0, 0);
	wait(.75 / SpeedDiv)
	

	local function CreateItem()
		local rName, Typ = GetName(DefenderName);
		Item = ReplicatedStorage.Assets.Defenders[DefenderName]:Clone();
		
		for i, v in pairs(Item:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("MeshPart") then
				v.Anchored = true
				v.CanCollide = false
			end
		end

		for i, v in pairs(Item:FindFirstChild("HumanoidRootPart").Effect:GetChildren()) do
			if v:IsA("ParticleEmitter") then
				v.Enabled = true
			end
		end
		
		if Shiny == true then
			for i, v in pairs(Item:FindFirstChild("HumanoidRootPart").Corrupted:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v.Enabled = true
				end
			end
		end
		
		Item.Parent = workspace.Items
	end
	CreateItem();

	for i, v in pairs(Item:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
	
	--TweenFunc()
	TweenFunc(Position, 0.01, "Sine", "Out", 0, false, 0, 0, .15, 0);

	con:Disconnect()
	Case:Destroy()
	
	local Confirm = false
	local StartingPos,EndingPos = -16, -7
	local Offset2
	local Render = RunService.RenderStepped:Connect(function()
		local viewport_size = Camera.ViewportSize
		local camera_ray = Camera:ViewportPointToRay(viewport_size.X / 2, viewport_size.Y / 2)
		if StartingPos ~= EndingPos then
			StartingPos = StartingPos + math.floor(1 * SpeedDiv)
			Offset2 = (CFrame.new(0, 0, StartingPos) * CFrame.Angles(0, math.rad(180), 0)) + Increment;
		end
		
		local targetPosition = Camera.CFrame * Offset2

		Item:SetPrimaryPartCFrame(targetPosition * Position.Value)
		local goal = CFrame.lookAt(Item.PrimaryPart.Position, camera_ray.Origin )
		Item:SetPrimaryPartCFrame(goal)
		
		repeat wait() until StartingPos == EndingPos
	end)
	
	
	if _Defenders[DefenderName].Rarity >= 5 then
		_Chat:RareOpening(Player, DefenderName)
	end
	

	delay(0.15 / SpeedDiv, function()
		--HatchFrame = Gui:FindFirstChild("MultiPetHatch") or Gui:FindFirstChild("PetHatch");
		if HatchFrame then
			HatchFrame.Visible = true;
		end
	end)

	local function ending()
		--HatchFrame = Gui:FindFirstChild("MultiPetHatch") or Gui:FindFirstChild("PetHatch");

		--[[layer.Character.Humanoid.WalkSpeed = 16;
		Player.Character.Humanoid.JumpPower = 50;
		Camera.CameraSubject = Player.Character;
		Camera.CameraType = Enum.CameraType.Custom;
		Player.CameraMinZoomDistance = 0.5;]]

		pcall(function()
			TweenFunc(Position, 1.5/SpeedDiv, "Linear", "Out", 0, false, 0, 0, -10, 0);
		end)

		gameInterfaceUI(true);

		wait(1 / SpeedDiv);
		
		Audio:Destroy()
		Position:Destroy();
		HatchFrame:Destroy()
		Item:Destroy();
		Render:Disconnect();

	end
	delay(.5 / SpeedDiv, function()
		if Auto == true then
			ending()
			_Opening:SetOtherFramesFalse(true);
		end
	end)


	delay(2.5 / SpeedDiv, function()
		ending()
		_Opening:SetOtherFramesFalse(true);
		Debounce = false
	end)

	repeat wait() until Debounce == false

end

function _Opening:MultiOpenCrate(CrateName, Data)
	local Offset = CFrame.new(0, 0, -4) * CFrame.Angles(0, math.rad(180), 0);

	local Debounce = true
	for i = 1, 3 do
		do
			local num = i -2
			
			spawn(function()
				if Debounce == true then
					local Name, New, Shiny, AutoDeleted = Data[i][1], Data[i][2], Data[i][3], Data[i][4]
					--print(CrateName, Name, New, Offset + Vector3.new(2.5 * num, 0, 0), tonumber(i), Shiny, (AutoDeleted or false), false, Vector3.new(-5 * num, 0, 0))
					_Opening:OpenCrate(CrateName, Name, New, Offset + Vector3.new(2.5 * num, 0, 0), tonumber(i), Shiny, (AutoDeleted or false), false, Vector3.new(-5 * num, 0, 0));
				
					Debounce = false
				end

			end)
		end
	end
	repeat wait() until Debounce == false
end


return _Opening
