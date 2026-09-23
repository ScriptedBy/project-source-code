--// Manages playtime rewards by tracking countdown timers, updating reward status, and allowing players to redeem earned rewards.

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

repeat wait() until Players.LocalPlayer;
local Player = Players.LocalPlayer;
local PlayerUI = Player:WaitForChild("PlayerGui");
local ScreenUI = PlayerUI:WaitForChild("ScreenGui");
local UIFrame  = ScreenUI:WaitForChild("UI");
local Rewards = UIFrame:WaitForChild("Rewards")

local FetchClientData = ReplicatedStorage.Remotes["Remote Functions"]["Client Data"];
local CheckRewards = ReplicatedStorage.Remotes["Remote Events"]["Check Rewards"];

local _Defenders = require(ReplicatedStorage.Modules.Contents.__Defenders);
local _Rewards = require(ReplicatedStorage.Modules.Contents.__Rewards);

local _Reward = {}

local function formatTime(duration)
	local hours = math.floor(duration / 3600)
	local minutes = math.floor((duration % 3600) / 60)
	local seconds = math.floor(duration % 60)

	-- Format the time as "hh:mm:ss" or "mm:ss" if duration is less than an hour
	local formattedTime
	if hours > 0 then
		formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)
	else
		formattedTime = string.format("%02d:%02d", minutes, seconds)
	end

	return formattedTime
end

function _Reward:UpdateRewards()
	spawn(function()
		while wait() do
			for i, v in pairs(Rewards.Container:GetChildren()) do
				if v:IsA("ImageButton") then
					local Data = FetchClientData:InvokeServer(Player);
					local PlayerData = Data.Data.Player
					-- 1000 - 1000 -200 
					if (PlayerData.DailyReward.Playtime.Claim - (7200 - _Rewards[v.Name].Time)) >= 0 then
						v.Time.Text = formatTime(PlayerData.DailyReward.Playtime.Claim - (7200 - _Rewards[v.Name].Time))
					else
						if PlayerData.DailyReward.Playtime.Rewards[v.Name] == false then
							v.Time.Text = "Redeem"
						else
							v.Time.Text = "Redeemed"
						end
						
					end
				end
			end
		end
	end)
	
	for i, v in pairs(Rewards.Container:GetChildren()) do
		if v:IsA("ImageButton") then
			local Data = FetchClientData:InvokeServer(Player);
			local PlayerData = Data.Data.Player
			
			v.MouseButton1Click:Connect(function()
				CheckRewards:FireServer(v.Name)
				
			end)
		end
	end
	
	local Data = FetchClientData:InvokeServer(Player);
	local PlayerData = Data.Data.Player
end


function _Reward:Int()
	
	_Reward:UpdateRewards()
end

return _Reward;
