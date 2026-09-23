--// Manages the client-side crate system, including proximity detection, single/multi openings, auto-opening, game pass checks, purchases, and crate UI interactions.

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local MarketPlaceService = game:GetService("MarketplaceService");
local UserInputService = game:GetService("UserInputService");
local RunService = game:GetService("RunService");

repeat wait() until Players.LocalPlayer;
local Player = Players.LocalPlayer;
local PlayerUI = Player:WaitForChild("PlayerGui");
local ScreenUI = PlayerUI:WaitForChild("ScreenGui");
local UIFrame  = ScreenUI:WaitForChild("UI");
local CaseUI = UIFrame:WaitForChild("CaseUI");
local Shop = UIFrame:WaitForChild("Shop");
local UIClones = script:WaitForChild("Assets").CrateDisplay;

local BuyCrate = ReplicatedStorage.Remotes["Remote Functions"]["Buy Crate"];
local DisplayOpenEvent = ReplicatedStorage.Remotes["Remote Events"]["Display Open"];

local Case, LastCrate, Debounce = {}, nil, false
local AutoOn, CurrentAuto, WaitDebounce = false, nil, false
local Debounce2 = false

local _Opening = require(script["__Opening"]);
local _Index = require(script["__Index"])
local _Defenders = require(ReplicatedStorage.Modules.Contents.__Defenders);
local _Crates = require(ReplicatedStorage.Modules.Contents.__Crates);

local _Cases = {};

local CaseFolder = game.Workspace.Cases:GetChildren();
for i, v in pairs(CaseFolder) do
	if v:IsA("Model") then
		Case[v.Name] = v
		Case[v.Name].MoneyTitle:WaitForChild("Amount").SurfaceGui.Amount.Text = _Crates[v.Name].Cost[2]
	end
end

function _Cases:GetClosest(distance)
	local RequiredDistance = 12;
	local Distance = distance ~= nil and distance or RequiredDistance;
	local Closest = nil

	for i, v in pairs(Case) do
		local CameraPart = v:FindFirstChild("View");
		if CameraPart ~= nil then
			local partPOS = CameraPart.Position
			local newDistance = Player:DistanceFromCharacter(partPOS)
			if newDistance <= Distance then
				Closest = v
				Distance = newDistance
			end
		end
	end
	return Closest;
end

function _Cases:GetCaseStatus(ItemName)
	if _Crates[ItemName] == nil then
		warn("No Egg Data found in " .. tostring(ItemName) .. "");
		return
	end
	
	return _Crates[ItemName];
	
end

function _Cases:GetCaseCost(ItemName)
	local Status = _Cases:GetCaseStatus(ItemName);
	local Cost = Status.Cost;
	if Cost ~= nil and Cost[1] ~= nil and Cost[2] ~= nil then
		return tonumber(Cost[2]), tostring(Cost[1])
	end
	
	return 0, "nil"
end

-- Check Gamepass
function HasPass(id)
	if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, id) then
		return true
	end
	
	return false
end

function CheckPass(id, which)
	if which == "Check" then
		return HasPass(id);
	elseif which == "Prompt" then
		MarketPlaceService:PromptGamePassPurchase(Player, id);
			
	end
	return false
end

function _Cases:OpenCrate(Case, Auto)
	if UIFrame:FindFirstChild("Open") == nil and UIFrame:FindFirstChild("MultiOpen") == nil then
		if Debounce == false then
			Debounce = true
			local CaseName = Case.Name;
			local Status = _Cases:GetCaseStatus(CaseName);
			local Cost, Currency = _Cases:GetCaseCost(CaseName);

			if Currency == "Robux" and Status.ProductID ~= nil and Status.TripleProductID ~= nil then
				local productID = Status.ProductID
				MarketPlaceService:PromptProductPurchase(Player, productID)
			else
				local Item = BuyCrate:InvokeServer(CaseName, "Buy1");
				if Item == "Max" then
					Debounce = false
					print("Max Pets")
					return true
				elseif Item == "Distance Nil" then
					Debounce = false
					print("Not Close to purchase Egg")
					return true
				elseif Item then

					if Item[1] == "Need Currency" then
						local CurrencyName, AmountNeeded = Item[2], Item[3]
						local msg = "You do not have enough " .. CurrencyName .. " to purchase this egg!"
						print("Not Enough ".. CurrencyName);
					else
						print(Item, Item[1], Item[2], Item[3])
						local ItemName, newItem, shiny, autoDeleted = Item[1], Item[2], Item[3], Item[4];
						_Opening:ChangePercentage(Player, CaseName);
						_Index:UpdateIndex(CaseName)
						_Opening:OpenCrate(CaseName, ItemName, newItem, nil, nil, shiny, autoDeleted, Auto, nil);
					end
				end
				
			end
			wait() Debounce = false
		end 
	end
end

function _Cases:OpenRobux(CaseName, Which, Item)
	if CaseName ~= nil and Which ~= nil and Item ~= nil then
		delay(1, function()
			if Which == "Open3" then
				local Item1, Item2, Item3 = Item[1], Item[2], Item[3]
				if Item1 == "Max" then
					print("Max Pets!")
					return true
				elseif Item and Item2 and Item3 then
					print("LEL")
					_Opening:MultiOpenCrate(CaseName, {Item1, Item2, Item3})
				end
			elseif Which == "Open1" then
				if Item == "Max" then
					print("Max Pets!")
					return true
				elseif Item then

					print("LEL")
					local ItemName, newItem, shiny, autoDeleted = Item[1], Item[2], Item[3], Item[4];
					_Opening:OpenCrate(CaseName, ItemName, newItem, nil, nil, shiny, autoDeleted, nil, nil);
				end	
			end
		end)
	end
end


function _Cases:MultiOpen(Case)
	if UIFrame:FindFirstChild("Open") == nil and UIFrame:FindFirstChild("MultiOpen") == nil then
		if Debounce == false then
			Debounce = true
			local CaseName = Case.Name;
			local Status = _Cases:GetCaseStatus(CaseName);
			local Cost, Currency = _Cases:GetCaseCost(CaseName);
			
			if Currency == "Robux" and Status.ProductID ~= nil and Status.TripleProductID ~= nil then
				local productID = Status.TripleProductID
				MarketPlaceService:PromptProductPurchase(Player, productID)
			else
				if CheckPass(199493120, "Check") == true then
					local Item, Item2, Item3 = BuyCrate:InvokeServer(CaseName, "Buy3");

					if Item == "Max" then
						Debounce = false
						print("Max Pets")
						return true
					elseif Item == "Distance Nil" then
						Debounce = false
						print("Not Close to purchase Egg")
						return true
					elseif Item == "Need Pass" then
						print("NEED PASS")
						CheckPass(199493120, "Prompt");
						Debounce = false
						return true 
					elseif Item then

						if Item[1] == "Need Currency" then
							local CurrencyName, AmountNeeded = Item[2], Item[3]
							local msg = "You do not have enough " .. CurrencyName .. " to purchase this egg!"
							print("Not Enough ".. CurrencyName);
						elseif Item ~= nil and Item2 ~= nil and Item3 ~= nil then
							local petName, newPet, shiny, autoDeleted = Item[1], Item[2], Item[3], Item[4];
							_Opening:ChangePercentage(Player, CaseName);
							_Index:UpdateIndex(CaseName)
							_Opening:MultiOpenCrate(CaseName, {Item, Item2, Item3});
						end
					end

				else
					CheckPass(199493120, "Prompt");
				end

			end
			wait() Debounce = false
		end
	end
end



function _Cases:AutoOpen()
	local function LoopCancel()
		AutoOn = false;
		CurrentAuto = nil;
	end
	local function AutoOpenOne()
		AutoOn = true
		spawn(function()
			while true do
				if AutoOn == false then
					LoopCancel() break
				end
				local Closest = _Cases:GetClosest(10);
				if Closest ~= nil then
					if CurrentAuto == nil then 
						CurrentAuto = Closest.Name
					end
					if CurrentAuto == Closest.Name then
						CurrentAuto = Closest.Name
						local MaxPets = _Cases:OpenCrate(Closest, true);
						if MaxPets == true then
							LoopCancel()
							break
						end
						repeat wait()
						until UIFrame:FindFirstChild("MultiOpen") == nil and UIFrame:FindFirstChild("Open") == nil
						wait(1)
					else
						LoopCancel() break
					end
				else
					LoopCancel() break
				end
			end
		end)
	end
	local function AutoOpenThree()
		if CheckPass(199493120, "Check") == true then
			AutoOn = true;
			spawn(function()
				while true do
					if AutoOn == false then
						LoopCancel() break
					end
					local Closest = _Cases:GetClosest();
					if Closest ~= nil then
						if CurrentAuto == nil then 
							CurrentAuto = Closest.Name
						end
						if CurrentAuto == Closest.Name then
							CurrentAuto = Closest.Name
							local Check = _Cases:MultiOpen(Closest, true);
							if Check == true then
								
								LoopCancel()
								break
							end
							--repeat wait()
							--until UIFrame:FindFirstChild("MultiPetHatch") == nil
							wait(1)
						else
							LoopCancel() break
						end
					else
						LoopCancel() break
					end
				end
			end)
		else
			LoopCancel()
		end
	end
	if AutoOn == true then return end
	if CheckPass(199493120, "Check") == true then
		AutoOpenThree();
	else
		AutoOpenOne();
	end
end


local function GetCaseTypes(CrateName, v, Display, Type)
	local Cost, Currency = _Cases:GetCaseCost(CrateName, Type);

	if tonumber(Cost) > 0 then
		Display.Hotkey.Data.Cost.Container.Image.Amount.Text = tostring(Cost)
	end

	if Currency == "Robux" then
		Display.Hotkey.Click.MouseButton1Click:Connect(function()
			_Cases:OpenCrate(v, Type)
		end)

		Display.Hotkey.Click2.MouseButton1Click:Connect(function()
			_Cases:MultiOpen(v, Type)
		end)

		Display.Hotkey.Click3.Visible = false
	else
		Display.Hotkey.Click.MouseButton1Click:Connect(function()
			_Cases:OpenCrate(v, Type)
		end)

		Display.Hotkey.Click2.MouseButton1Click:Connect(function()
			_Cases:MultiOpen(v, Type)
		end)

		Display.Hotkey.Click3.MouseButton1Click:Connect(function()
			_Cases:AutoOpen(Type)
		end)
	end

end


function _Cases:Int()
	
	
	for i, v in pairs(Case) do
		local CrateName = v.Name;

		if CaseUI:FindFirstChild(CrateName) == nil then
			local Display = script:WaitForChild("Assets").CrateDisplay:Clone()
			Display.Name = CrateName

			GetCaseTypes(CrateName, v, Display);
			_Opening:LoadItems(Player, CrateName);
			
			local cameraPart = v:FindFirstChild("View")
			Display.Adornee = cameraPart

			Display.Enabled = false
			Display.Parent = CaseUI
		end
	end
	
	
	
	DisplayOpenEvent.OnClientEvent:Connect(function(...)
		_Cases:OpenRobux(...)
	end)


	UserInputService.InputBegan:Connect(function(Input, GP)
		if GP then return end;
		if Input.UserInputType == Enum.UserInputType.Keyboard then
			if Debounce2 == false then
				if Input.KeyCode == Enum.KeyCode.E then
					Debounce2 = true;
					local ClosestCrate = _Cases:GetClosest()
					if ClosestCrate then
						_Cases:OpenCrate(ClosestCrate)
					
					end
					wait() Debounce2 = false
				elseif Input.KeyCode == Enum.KeyCode.T then
					Debounce2 = true;
					local ClosestCrate = _Cases:GetClosest()
					if ClosestCrate  then
						_Cases:MultiOpen(ClosestCrate, "Pet")
						
					end
					wait() Debounce2 = false
				elseif Input.KeyCode == Enum.KeyCode.R then
					Debounce2 = true;
					local ClosestCrate = _Cases:GetClosest()

					if ClosestCrate ~= nil then
						local Cost, Currency = _Cases:GetCaseCost(tostring(ClosestCrate));
						if Currency == "Robux" then

						else
							_Cases:AutoOpen();
						end
						
					end
				end
				wait() Debounce2 = false
			end
		end
	end)
	
	spawn(function()
		RunService.RenderStepped:Connect(function()
			local ClosestCrate = _Cases:GetClosest()
			if ClosestCrate then
				if ClosestCrate ~= LastCrate then
					LastCrate = ClosestCrate
					for _, frame in pairs(CaseUI:GetChildren()) do
						if frame.Name == tostring(ClosestCrate) then
							frame.Enabled = true
						else
							frame.Enabled = false
						end
					end
				end
			else
				if Debounce2 == false then
					Debounce2 = true
					LastCrate = nil
					for _, frame in pairs(CaseUI:GetChildren()) do
						frame.Enabled = false
					end
					delay(1, function() Debounce2 = false end)
				end
			end
		end)
	end)
end

return _Cases;
