--// Defines the game’s crate system, including costs, purchasable currencies, rewards, rarity chances, and premium product IDs.

local _Crates = {
	
	-- Eggs
	["Security Crate #1"] = {
		Index = 1,
		Type = "Pet",
		Cost = {"Coins", 1500}, -- 500
		Contents = {
			-- Pet, Rarity
			{"Security Toilet", 45, 1}, 
			{"Security Medic", 45, 2}, 
			{"Cameraman", 35, 2}, 

			{"Speakerman", 30, 3}, 
			{"Handsaw Security", 15, 1}, 
			{"Upgraded Cameraman", 0.1, 3}, 

		}
	},
	
	-- Eggs
	["Security Crate #2"] = {
		Index = 3,
		Type = "Pet",
		Cost = {"Coins", 15000}, -- 500
		Contents = {
		
			{"Speakerman", 45, 3},  
			{"TV Man", 15, 3},
			{"Upgraded Cameraman", 35, 3}, 
			{"Upgraded Radioman", 50, 3},
			{"Titan Speakerman", 10, 3}, --0.01
			{"Titan Cameraman", 1, 3}, -- 0.0001
		}
	},
	
	["Exclusive Crate 1"] = {
		Index = 2,
		Type = "Pet",
		Cost = {"Robux", 250}, -- 500
		
		ProductID = 1583358771, 
		TripleProductID = 1583358601,
		
		Contents = {
			{"TV Man", 50, 3},
			{"Upgraded Radioman", 50, 3}, 
			{"Titan Speakerman", 70, 3}, 
			{"Titan Cameraman", 75, 3}, 
			
		}
	},

	--[[Robux Crates  Eggs
	["Octogo Egg"] = {
		Index = 2,
		Type = "Pet",
		Ignore = {"Legendary"},
		Cost = {"Robux", 1},
		ProductID = 1192831865, 
		TripleProductID = 1192831944,
		Contents = {
			-- Pet, Rarity
			{"Octadecimal", 100, 1}, --45

		}
	},]]
	
}


return _Crates;
