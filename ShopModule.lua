--// Manages the in-game shop, including game passes, developer products, premium crates, active boosts, and daily group rewards.

local Debounce3 = false

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
local Boosts = UIFrame.Bottom:WaitForChild("Boosts")

local FetchClientData = ReplicatedStorage.Remotes["Remote Functions"]:WaitForChild("Client Data");


local _Cases = require(script.Parent.__Cases)
local _Gamepasses = require(ReplicatedStorage.Modules.Contents.__Gamepasses);

local _Shop = {}

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

function _Shop:Gamepasses()
	local Passes = Shop.Container.ScrollingFrame.Gamepasses

	for i, v in pairs(Passes:GetChildren()) do
		if v:IsA("Frame") then
			v.Purchase.MouseButton1Click:Connect(function()

				if CheckPass(_Gamepasses.Passes[v.Name], "Check") == false then
					print(_Gamepasses.Passes[v.Name])
					CheckPass(_Gamepasses.Passes[v.Name], "Prompt")
				end

			end)
		end
	end
end

local function promptPurchase(id)
	MarketPlaceService:PromptProductPurchase(Player, id)
end

function _Shop:Devproducts()
	local TokensShop = Shop.Container.ScrollingFrame.Coins
	local DiamondsShop = Shop.Container.ScrollingFrame.Diamonds
	for i, v in pairs(TokensShop:GetChildren()) do
		if v:IsA("Frame") then
			v.Purchase.MouseButton1Click:Connect(function()

				promptPurchase(_Gamepasses.Products[v.Name])

			end)
		end
	end
	for i, v in pairs(DiamondsShop:GetChildren()) do
		if v:IsA("Frame") then
			v.Purchase.MouseButton1Click:Connect(function()

				promptPurchase(_Gamepasses.Products[v.Name])

			end)
		end
	end
end

function _Shop:CheckPasses()
	spawn(function()
		while wait(1) do
			for i, v in pairs(_Gamepasses.Passes) do
				if CheckPass(v, "Check") == true then
					Boosts[i].Visible = true
				else
					Boosts[i].Visible = false
				end
			end

		end
	end)
end

function _Shop:GiveSpeed()
	spawn(function()
		while wait(1) do
			if CheckPass(199501207, "Check") == true then
				Player.Character.Humanoid.WalkSpeed = 20
			else
				Player.Character.Humanoid.WalkSpeed = 20
			end

		end
	end)
end


local function toHMS(s)
	return string.format("%02i:%02i:%02i", s/60^2, s/60%60, s%60)
end

function _Shop:UpdateChestReward()
	local Reward = game.Workspace.Lobby.Decore.ChestReward.Reward
	local GroupID = 15225156
	spawn(function()
		while wait(1) do
			local Data = FetchClientData:InvokeServer(Player);
			
			if Player:IsInGroup(GroupID) then
				Reward.BillboardGui.Title.Text = "Daily Group Rewards!"
				if Data.Data.Player.DailyReward.Group.LastCollectedChest <= 0 then
					Reward.BillboardGui.Timer.Text = "REDEEM!"
				else
					print(Data.Data.Player.DailyReward.Group.LastCollectedChest)
					Reward.BillboardGui.Timer.Text = toHMS(Data.Data.Player.DailyReward.Group.LastCollectedChest);
				end
				
			else
				Reward.BillboardGui.Title.Text = "Join the group for rewards!"
			end
			


		end
	end)
end

function _Shop:Int()
	local ExclusiveCont = Shop.Container.ScrollingFrame.ExclusiveCont.Exclusive.Container
	local CrateTab = {Name = "Exclusive Crate 1"}

	ExclusiveCont.Purchase.Buy1.Purchase.MouseButton1Click:Connect(function()
		if Debounce3 == false then
			Debounce3 = true
			print("HELLO")
			_Cases:OpenCrate(CrateTab) 
			wait() Debounce3 = false
		end

	end)
	ExclusiveCont.Purchase.Buy3.Purchase.MouseButton1Click:Connect(function()
		if Debounce3 == false then
			Debounce3 = true
			print("HELLO")
			_Cases:MultiOpen(CrateTab) 
			wait() Debounce3 = false
		end

	end)
	
	_Shop:Gamepasses()
	_Shop:CheckPasses()
	_Shop:GiveSpeed()
	_Shop:Devproducts()
	_Shop:UpdateChestReward()
end

return _Shop
