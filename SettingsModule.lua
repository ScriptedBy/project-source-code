--// Manages player settings by handling AFK mode toggles, animated UI controls, and in-game code redemption.

local _Settings = {}

local TweenService = game:GetService("TweenService");
local Players = game:GetService("Players");

repeat wait() until Players.LocalPlayer;
local Player = Players.LocalPlayer;
local ClickDebounce = false

local PlayerUI = Player:WaitForChild("PlayerGui");
local ScreenUI = PlayerUI:WaitForChild("ScreenGui");
local UIFrame  = ScreenUI:WaitForChild("UI");
local SettingsFrame = UIFrame:WaitForChild("Settings");

local ReplicatedStorage = game.ReplicatedStorage;
local Remotes = ReplicatedStorage.Remotes;
local AFKEvent = Remotes["Remote Events"]:WaitForChild("AFK");
local CheckCodes = Remotes["Remote Functions"]["Check Codes"];

local Disabled, dColor, dbgColor = UDim2.new(0.05, 0, 0.4, 0), Color3.fromRGB(255, 75, 75), Color3.fromRGB(120, 35, 35);
local Enabled, eColor, ebgColor = UDim2.new(0.55, 0, 0.4, 0), Color3.fromRGB(93, 255, 75), Color3.fromRGB(37, 120, 31);

local Toggle = function(UI, Which)
	if Which == true then
		UI.BG.ImageColor3, UI.BG.BG.ImageColor3 = dbgColor, dColor;
		UI:WaitForChild("Circle"):TweenPosition(Disabled, "In", "Quint", .3, true);
		
		
	else
		UI:WaitForChild("Circle"):TweenPosition(Enabled, "Out", "Quint", .3, true);
		UI.BG.ImageColor3, UI.BG.BG.ImageColor3 = ebgColor, eColor;
	end
end

local SETTINGS_FUNCS = {
	
	AFK = function(Button)
		local WhichValue = Button.Which
		if WhichValue.Value == false then
			WhichValue.Value = true
			Toggle(Button.Button, false)
			AFKEvent:FireServer(WhichValue.Value)
		elseif WhichValue.Value == true then
			WhichValue.Value = false
			Toggle(Button.Button, true)
			AFKEvent:FireServer(WhichValue.Value)
		end
	end;
	
	
}


local function redeemCode(code)
	print(code)
	local CheckCode = CheckCodes:InvokeServer(code)
	local successMessage = string.format("You have redeemed code '%s' and received item(s)!", code)
	local errorMessage = string.format("The code '%s' is invalid or has already been redeemed.", code)
	
	print(CheckCode)
	if CheckCode == true then
		SettingsFrame.Codes.Enter.Text = successMessage

	else
		SettingsFrame.Codes.Enter.Text = errorMessage
	end
	
	
end
--[[ReturnMute.OnInvoke = function(...)
	if Mute == nil then
		return true;
	else
		return Mute
	end
end

ReturnTrade.OnClientInvoke = function(...)
	if TradeRequest == nil then
		return true;
	else
		return TradeRequest
	end
end

ReturnTrade.= function(...)
	print(TradeRequest)
	if TradeRequest == nil then
		return false;
	else
		return TradeRequest
	end
end]]

function _Settings:Int()
	for i, v in pairs(SettingsFrame.Container:GetChildren()) do
		if v:IsA("Frame") and v:FindFirstChild("Button") then
			v.Button.Click.MouseButton1Click:Connect(function()
				if ClickDebounce == false then
					if SETTINGS_FUNCS[v.Name] ~= nil then
						ClickDebounce = true
						SETTINGS_FUNCS[v.Name](v)
						wait(0.25) ClickDebounce = false
					end
				end
			end)
		end
	end
	
	SettingsFrame.Codes.Enter.FocusLost:Connect(function()
		redeemCode(SettingsFrame.Codes.Enter.Text)
		wait(3)
		SettingsFrame.Codes.Enter.Text = ""
	end)
end

return _Settings;
