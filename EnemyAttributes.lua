--// Defines enemy attributes, including damage, health, movement speed, and randomized reward drops.

local _Monsters = {
	
	["Skibi"] = {
		Damage = { Min = 5, Max = 10 },
		Health = { Min = 350, Max = 500 },
		Walkspeed = 10,

		Drops = { 
			Tokens = { Min = 50, Max = 100 }, 
			Diamonds = { Min = 1, Max = 10 }, 
			Experience = { Min = 20, Max = 80 },
			DefenderXP = { Min = 10, Max = 100 }, 
		}
	},
	
	["Girl Skibi"] = {
		Damage = { Min = 10, Max = 15 },
		Health = { Min = 500, Max = 750 },
		Walkspeed = 12,
		
		Drops = { 
			Tokens = { Min = 100, Max = 150 }, 
			Diamonds = { Min = 3, Max = 15 }, 
			Experience = { Min = 50, Max = 120 },
			DefenderXP = { Min = 30, Max = 130 }, 
		}
	},
	
	["Giant Skibi"] = {
		Damage = { Min = 0, Max = 0 },
		Health = { Max = 10000 },
		Walkspeed = 2,
		
		Drops = { 
			Tokens = { Min = 5000, Max = 10000 }, 
			Diamonds = { Min = 100, Max = 1000 }, 
			Experience = { Min = 2000, Max = 8000 },
			DefenderXP = { Min = 1000, Max = 10000 }, 
		}
	}

}


return _Monsters; 

