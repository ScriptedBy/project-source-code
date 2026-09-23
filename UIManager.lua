--// Manages the game’s main user interface by handling menu navigation, panel visibility, exit controls, and animated UI transitions.

wait(.5);

local UserInputService = game:GetService("UserInputService");
local TweenService = game:GetService("TweenService");
local Players = game:GetService("Players");

repeat wait() until Players.LocalPlayer;
local Player = Players.LocalPlayer;
local Character = Player.Character
local PlayerUI = Player:WaitForChild("PlayerGui");
local ScreenUI = PlayerUI:WaitForChild("ScreenGui");
local UIFrame  = ScreenUI:WaitForChild("UI");
local InventoryFrame = UIFrame:WaitForChild("Inventory");
local Bottom = UIFrame:WaitForChild("Bottom")
--local TypeWriter = require(game.ReplicatedStorage.Modules:WaitForChild("Typewriter"));


Bottom.Slider.MouseButton1Click:Connect(function()
	if Bottom.Slider.Text == ">" then
		Bottom.Slider.Text = "<" 
		Bottom:TweenPosition(UDim2.new(-0.25, 0, 1, 0))
	else
		Bottom.Slider.Text = ">" 
		Bottom:TweenPosition(UDim2.new(0, 0, 1, 0))
	end
	
end)


for i, v in pairs(script.Parent:GetChildren()) do
	for a, b in pairs(v:GetChildren()) do
		if b.Name == "Exit" then
			b.Container.Exit.MouseButton1Click:Connect(function()
				if b.Parent.Name == "Spectate" then
					script.Parent.Sidebar.Visible = true
					b.Parent.Visible = false
				else
					b.Parent.Visible = false
				end
			end)
		end
	end
end

--- Handling UI from screen ---
for i, v in pairs(script.Parent.Left:GetChildren()) do
	if v:IsA("ImageLabel") then
		for a, b in pairs(v:GetChildren()) do
			if b:IsA("ImageButton") then
				b.MouseButton1Click:Connect(function()
					if b.Name == "Inventory" then
						if script.Parent:FindFirstChild(b.Name).Visible == false then
							script.Parent:FindFirstChild(b.Name).Visible = true
							script.Parent.Settings.Visible = false
							script.Parent.Radio.Visible = false
							script.Parent.Trade.Visible = false
							script.Parent.Boosts.Visible = false
							script.Parent.Shop.Visible = false
							script.Parent.Rewards.Visible = false
							script.Parent.Help.Visible = false
						else
							script.Parent:FindFirstChild(b.Name).Visible = false
						end
					end
					if b.Name == "Settings" then
						if script.Parent:FindFirstChild(b.Name).Visible == false then
							script.Parent:FindFirstChild(b.Name).Visible = true
							script.Parent.Inventory.Visible = false
							script.Parent.Radio.Visible = false
							script.Parent.Trade.Visible = false
							script.Parent.Boosts.Visible = false
							script.Parent.Shop.Visible = false
							script.Parent.Rewards.Visible = false
							script.Parent.Help.Visible = false
						else
							script.Parent:FindFirstChild(b.Name).Visible = false
						end
					end
					if b.Name == "Rewards" then
						if script.Parent:FindFirstChild(b.Name).Visible == false then
							script.Parent:FindFirstChild(b.Name).Visible = true
							script.Parent.Inventory.Visible = false
							script.Parent.Radio.Visible = false
							script.Parent.Trade.Visible = false
							script.Parent.Boosts.Visible = false
							script.Parent.Shop.Visible = false
							script.Parent.Help.Visible = false
						else
							script.Parent:FindFirstChild(b.Name).Visible = false
						end
					end
					if b.Name == "Shop" then
						if script.Parent:FindFirstChild(b.Name).Visible == false then
							script.Parent:FindFirstChild(b.Name).Visible = true
							script.Parent.Settings.Visible = false
							script.Parent.Radio.Visible = false
							script.Parent.Trade.Visible = false
							script.Parent.Inventory.Visible = false
							script.Parent.Rewards.Visible = false
							script.Parent.Help.Visible = false
						else
							script.Parent:FindFirstChild(b.Name).Visible = false
						end
					end
					if b.Name == "Spectate" then
						if script.Parent:FindFirstChild(b.Name).Visible == false then
							script.Parent:FindFirstChild(b.Name).Visible = true
							script.Parent.Inventory.Visible = false
							script.Parent.Sidebar.Visible = false
							script.Parent.Settings.Visible = false
							script.Parent.Radio.Visible = false
							script.Parent.Trade.Visible = false
							script.Parent.Boosts.Visible = false
							script.Parent.Shop.Visible = false
							script.Parent.Rewards.Visible = false
							script.Parent.Help.Visible = false
						end
					end
					if b.Name == "Radio" then
						if script.Parent:FindFirstChild(b.Name).Visible == false then
							script.Parent:FindFirstChild(b.Name).Visible = true
							script.Parent.Inventory.Visible = false
							script.Parent.Settings.Visible = false
							script.Parent.Trade.Visible = false
							script.Parent.Boosts.Visible = false
							script.Parent.Rewards.Visible = false
							script.Parent.Help.Visible = false
						else
							script.Parent:FindFirstChild(b.Name).Visible = false
						end
					end
					if b.Name == "Trade" then
						if script.Parent:FindFirstChild(b.Name).Visible == false then
							script.Parent:FindFirstChild(b.Name).Visible = true
							script.Parent.Inventory.Visible = false
							script.Parent.Settings.Visible = false
							script.Parent.Radio.Visible = false
							script.Parent.Boosts.Visible = false
							script.Parent.Shop.Visible = false
							script.Parent.Rewards.Visible = false
							script.Parent.Help.Visible = false
						else
							script.Parent:FindFirstChild(b.Name).Visible = false
						end
					end
					if b.Name == "Boosts" then
						if script.Parent:FindFirstChild(b.Name).Visible == false then
							script.Parent:FindFirstChild(b.Name).Visible = true
							script.Parent.Settings.Visible = false
							script.Parent.Radio.Visible = false
							script.Parent.Trade.Visible = false
							script.Parent.Inventory.Visible = false
							script.Parent.Shop.Visible = false
							script.Parent.Rewards.Visible = false
							script.Parent.Help.Visible = false
						else
							script.Parent:FindFirstChild(b.Name).Visible = false
						end
					end
					if b.Name == "Help" then
						if script.Parent:FindFirstChild(b.Name).Visible == false then
							script.Parent:FindFirstChild(b.Name).Visible = true
							script.Parent.Settings.Visible = false
							script.Parent.Radio.Visible = false
							script.Parent.Trade.Visible = false
							script.Parent.Inventory.Visible = false
							script.Parent.Shop.Visible = false
							script.Parent.Rewards.Visible = false
							script.Parent.Boosts.Visible = false
						else
							script.Parent:FindFirstChild(b.Name).Visible = false
						end
					end
				end)
			end
		end
	end
end


-- add leaderboard values to sidebar
