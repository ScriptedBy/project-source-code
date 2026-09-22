--// Defines timed reward milestones with randomized currency payouts and special item rewards.

local _Rewards = {

	["Reward1"] = {
		Time = 60*5,
		Rewards = {
			Coins = {Min = 100, Max = 300},
			Diamonds = {Min = 50, Max =  100}
		}
	},
	["Reward2"] = {
		Time = 60*10,
		Rewards = {
			Coins = {Min = 500, Max = 1000},
			Diamonds = {Min = 200, Max = 300}
		}
	},
	["Reward3"] = {
		Time = 60*15,
		Rewards = {
			Coins = {Min = 1100, Max = 1400},
			Diamonds = {Min = 400, Max = 500}
		}
	},
	["Reward4"] = {
		Time = 60*30,
		Rewards = {
			Coins = {Min = 1700, Max = 3000},
			Diamonds = {Min = 600, Max = 700}
		}
	},
	["Reward5"] = {
		Time = 60*60,
		Rewards = {
			Coins = {Min = 4000, Max = 8000},
			Diamonds = {Min = 800, Max = 900}
		}
	},
	["Reward6"] = {
		Time = 60*90,
		Rewards = {
			Coins = {Min = 10000, Max = 15000},
			Diamonds = {Min = 1100, Max = 1200}
		}
	},
	["Reward7"] = {
		Time = 60*120,
		Item = "Titan Speakerman",
		Rewards = {
			Coins = {Min = 30000, Max = 45000},
			Diamonds = {Min = 1300, Max = 1500}
		}
	}

}


return _Rewards; 



return _Rewards; 

