--// Manages the player’s item collection index by tracking discovered defenders and visually updating locked or unlocked items in the crate UI.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage");

repeat wait() until Players.LocalPlayer;
local Player = Players.LocalPlayer;
local PlayerUI = Player:WaitForChild("PlayerGui");
local ScreenUI = PlayerUI:WaitForChild("ScreenGui");
local UIFrame  = ScreenUI:WaitForChild("UI");
local CaseUI = UIFrame:WaitForChild("CaseUI");
local Remotes = ReplicatedStorage.Remotes;
local FetchClientData = ReplicatedStorage.Remotes["Remote Functions"]:WaitForChild("Client Data");


local _Index = {}

local GetIndex = function(Data, ItemName)
	local Index = Data.Data.Player.Inventory.Index or {};
	for i, v in pairs(Index) do
		if tostring(v) == tostring(ItemName) then
			return true;
		end
	end
	return false;
end


function _Index:UpdateIndex(CrateName)
	spawn(function()
		local Data = FetchClientData:InvokeServer(Player);
		local CaseFrame = CaseUI:FindFirstChild(CrateName);
		for i, v in pairs(CaseFrame:GetChildren()) do
			if v:IsA("Frame") then
				local Items = v.Data
				print(Items)
				for a, b in pairs(Items.Container:GetChildren()) do
					if b:IsA("Frame") then
						local ItemName = b.Name
						local obj = CaseFrame.Hotkey.Data.Container:WaitForChild(ItemName).Container;
						local Holder = obj
						local Index = GetIndex(Data, tostring(ItemName));

						if Index == true then
							Holder.ImageColor3 = Color3.fromRGB(255, 255, 255)
						else Holder.ImageColor3 = Color3.fromRGB(1, 1, 1)
						end

					end
				end
			end
		end
	end)
end

return _Index;
