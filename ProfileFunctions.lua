
-- ProfileTemplate table is what empty profiles will default to.
-- Updating the template will not include missing template values
--   in existing player profiles!

local Profiles = {}; -- [player] = profile

----- Loaded Services -----
local Players = game:GetService("Players");
local HttpService = game:GetService("HttpService");

----- Loaded Modules -----
local ProfileService = require(game.ReplicatedStorage.Modules["Proile Manager"]["Profile Service"]);

----- Private Variables -----
local ProfileTemplate = {
	
	Data = {
		Player = {
			
			Coins = 0,
			Diamonds = 0,
			Experience = 0,
			Level = 1,
			Prestige = 0,
			Cases = 0,
			Rounds = 0,
			
			Invites = {},
			
			DailyReward = { 
				LastLogin = os.time(), 
				LastLogin2 = os.time(),
				
				Group = { LastCollectedChest = 0 }, 
				Playtime = { 
					TimeReset = 0, 
					Claim = 7200, 
					Rewards = {
						Reward1 = false, 
						Reward2 = false, 
						Reward3 = false, 
						Reward4 = false, 
						Reward5 = false, 
						Reward6 = false, 
						Reward7 = false
					}
				} 
			},
			
			Inventory = { 
				Index = {}, 
				Codes = {},
				Defenders = { 
					Contents = { {"Starter", "Security Helper", false, 1, 0, "Normal", false, false} }, 
					MaxEquipped = 3,
					MaxStorage = 350
				}; --{"B048C671-423D-4F21-865A-BB64CD353FC0","Kitty",1,0,false,false},{"95C1C242-3939-4B96-8429-FE7DFEB7E3F1","Doggy",1,0,false,false},{"3BA6CD96-53A5-4D13-BCF6-2F3EC5530DD8","Bunny",1,0,false,false},{"1514DAD9-059B-4820-93EA-0F0C8E7C9B58","Doggy",1,0,false,false},{"16C479A8-1C95-4659-97A0-57FB373235D1","Kitty",1,0,false,false}
				--Radios = { Contents = {}, Equipped = "Default", Songs = {152745539} },
			},
			
		},
	},
}

--[[
	Boosts = { ["Triple Open"] = 0, ["Faster Open"] = 0, ["x2 Luck"] = 0, ["x2 Shiny"] = 0, ["x2 Coins"] = 0 },
	
	[1] = id(); 
	[2] = ItemName;
	[3] = Equip or false;
	[4] = (tonumber(Level) or 1); 
	[5] = 0;
	[6] = Shiny or false;
	[7] = false;
	[8] = Tradeable;
]]

local GameProfileStore = ProfileService.GetProfileStore("PlayerData", ProfileTemplate)

----- Local functions -----

local function DeepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = DeepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

local function MergeDataWithTemplate(data, template)
	for k, v in pairs(template) do
		if type(k) == "string" then -- Only string keys will be merged
			if data[k] == nil then
				if type(v) == "table" then
					data[k] = DeepCopy(v)
				else
					data[k] = v
				end
			elseif type(data[k]) == "table" and type(v) == "table" then
				MergeDataWithTemplate(data[k], v)
			end
		end
	end
end

----- Private Functions -----
Profiles.PlayerAdded = function(Player)
	
	local Profile = GameProfileStore:LoadProfileAsync(
		"Player____" .. Player.UserId,
		"ForceLoad"
	)
	
	MergeDataWithTemplate(Profile.Data, ProfileTemplate)
	if Profile ~= nil then
		
		Profile:ListenToRelease(function()
			Profiles[Player] = nil
			-- The profile could've been loaded on another Roblox server:
			Player:Kick("Kicked [1]; Please rejoin.")
			-- A profile has been successfully loaded:
			
		end)
		if Player:IsDescendantOf(Players) then
			Profiles[Player] = Profile
			spawn(function()
				while true do
					wait(10)
					print(HttpService:JSONEncode(Profile.Data))
				end
			end)
			print(HttpService:JSONEncode(Profile.Data))
		else
			-- Player left before the profile loaded:
			Profile:Release()
		end 
	else
		-- The profile couldn't be loaded possibly due to other
		--   Roblox servers trying to load this profile at the same time:
		Player:Kick("Kicked [2]; Please rejoin.")
	end
	
end

Profiles.PlayerRemoved = function(Player)
	
	local Profile = Profiles[Player];
	
	if Profile ~= nil then
		Profile:Release()
	end
	
end

return Profiles;
