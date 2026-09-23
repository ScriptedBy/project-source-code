--// Manages the in-game help tutorial by handling page navigation and dynamically updating the displayed help content.

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
local Help = UIFrame:WaitForChild("Help");
local Forward = Help:WaitForChild("Forward");
local Back = Help:WaitForChild("Back");
local Current = 1

local _Help = {}

function _Help:Next()
	if Current < 7 then
		Current = Current + 1
	end
end

function _Help:Previous()
	if Current > 1 then
		Current = Current - 1
	end
end

function _Help:UpdateFrame()
	for i, v in pairs(Help.Container:GetChildren()) do
		if v.Name == tostring(Current) then
			v.Visible = true
		else
			v.Visible = false
		end
	end
	Help.Page.Text = "("..Current.."/7)"
end

function _Help:Int()
	Forward.MouseButton1Click:Connect(function()
		_Help:Next()
		_Help:UpdateFrame()
	end)
	
	Back.MouseButton1Click:Connect(function()
		_Help:Previous()
		_Help:UpdateFrame()
	end)
end

return _Help;
