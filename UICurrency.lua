--// Manages real-time currency displays by animating coin and diamond value changes with formatted numbers and sound effects.

local Players = game:GetService("Players");
local TweenService = game:GetService("TweenService");
local SoundService = game:GetService("SoundService");

repeat wait() until Players.LocalPlayer
local Player = Players.LocalPlayer
local tweenInfo = TweenInfo.new(.3)
local Left = script.Parent.Left
local CurrencySound = SoundService.Currency

local function RoundsNumber(Number)
	return(math.floor(Number+.5))
end
local goal = {}
function Format_(number)

	local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
	int = int:reverse():gsub("(%d%d%d)", "%1,")
	return minus .. int:reverse():gsub("^,", "") .. fraction
end


Left.Tokens.Tokens.Text = Format_(math.floor(Player:WaitForChild("leaderstats").Coins.Value+0.5))
Left.Diamonds.Diamonds.Text = Format_(math.floor(Player:WaitForChild("leaderstats").Diamonds.Value+0.5))

Player.leaderstats.Coins.Changed:Connect(function(val)
	goal.Coins = val

	local Tween = TweenService:Create(Left.Tokens.TweenNumber, tweenInfo, {Value = goal.Coins})
	
	Tween:Play()
	CurrencySound:Play()
	spawn(function()
		Tween.Completed:Wait()
		CurrencySound:Stop()
	end)
	
	Left.Tokens.TweenNumber.Changed:Connect(function(TweenValue)
		local newTweenValue = RoundsNumber(TweenValue)
		Left.Tokens.Tokens.Text = Format_(newTweenValue)
	end)
end)

Player.leaderstats.Diamonds.Changed:Connect(function(val)
	goal.Diamonds = val
	
	local Tween = TweenService:Create(Left.Diamonds.TweenNumber, tweenInfo, {Value = goal.Diamonds})
	Tween:Play()
	CurrencySound:Play()
	spawn(function()
		Tween.Completed:Wait()
		CurrencySound:Stop()
	end)
	
	Left.Diamonds.TweenNumber.Changed:Connect(function(TweenValue)
		local newTweenValue = RoundsNumber(TweenValue)
		Left.Diamonds.Diamonds.Text = Format_(newTweenValue)
	end)
end)

