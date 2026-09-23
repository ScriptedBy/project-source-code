--// Manages the game’s custom loading screen by preloading assets, displaying loading progress, supporting skip functionality, and initializing the game interface and audio.

local Players = game:GetService("Players");
local ReplicatedFirst = game:GetService("ReplicatedFirst");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContentProvider = game:GetService("ContentProvider");
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")

repeat wait() until Players.LocalPlayer;
local Player = Players.LocalPlayer;
local PlayerUI = Player:WaitForChild("PlayerGui");
local ScreenUI = PlayerUI:WaitForChild("ScreenGui");
local UIFrame  = ScreenUI:WaitForChild("UI");
local LoadingScreen = UIFrame:WaitForChild("Loading");
local SkipButton = LoadingScreen:WaitForChild("Skip");
local LoadingBar = LoadingScreen:WaitForChild("LoadingBar");

local CheckLoading = ReplicatedStorage.Remotes["Remote Functions"]["Check Loading"];

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
ReplicatedFirst:RemoveDefaultLoadingScreen()

local Assets = script.Objects:GetDescendants();
local Skip = false

local _Loading = {}

local LoadingDisplay = function(obj, progress)
	local OneOverProgress
	if progress == 0 then
		OneOverProgress = 0
	else
		OneOverProgress = 1/progress
	end
	obj:TweenSize(UDim2.new(progress, 0, 1, 0))
	obj.Top:TweenSize(UDim2.new(OneOverProgress, 0, 1, 0))
end


function _Loading:GetAssets()
	
	
	for i = 1, #Assets do
		if Skip == true then break end
	
		local Asset = Assets[i]
		local percentage = math.round(i / #Assets * 100)
		local change = (percentage / 100)
		
		ContentProvider:PreloadAsync({Asset})
		
		LoadingBar.Percentage.Text = percentage.."%"
		LoadingBar.Assets.Text = "loading assets ("..i.." / "..#Assets..") "
		-- loading assets ( 1 / 2000)
		LoadingDisplay(LoadingBar.LoadCont, change)
		
		
		
		
		
		if percentage >= 10 then
			SkipButton.Visible = true
		end
	end
	
	SoundService.Chill:Play()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
	LoadingScreen.Visible = false
end


function _Loading:Int()
	LoadingScreen.Visible = true
	
	local Success, Err = pcall(function()
		CheckLoading.OnClientInvoke = function()
			return LoadingScreen.Visible
		end
	end)

	if Err then warn(Err) end -- If there is an Error then tell us what the error is
	
	SkipButton.MouseButton1Click:Connect(function()
		Skip = true
	end)
	
	_Loading:GetAssets()
	
end

return _Loading;
