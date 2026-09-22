--// Defines enemy wave configurations, including mob types, spawn chances, quantities, and boss encounters.

local _Waves = {
	
	["Wave Set 1"] = {
		-- Mob, SpawnChance, Amount
		{
			Mobs = {{"Skibi", 100}}, 
			Spawns = {1, 3, 3, 3, 4}
		}
	},

	["Wave Set 2"] = {
		{ -- {}
			Mobs = {{"Skibi", 70}, {"Girl Skibi", 30}}, 
			Spawns = {4, 5, 5, 6}
		}
	},

	["Wave Set 3"] = {
		{
			Boss = {{"Giant Skibi", 100, 50}}, 
			Mobs = {{"Skibi", 100}, {"Girl Skibi", 60}}, 
			Spawns = 7
		},
		
	},

	--[[["Inf"] = {
		-- Spawnboss Round
		{"Skibi", 70},
		{"Girl Skibi", 100},
		Spawns = 15,
		
		BossRound = {
			Time = 120,
			{"Giant Skibi", 100, 50},
			Spawns = 25
		}
		
		
		
	}]]
}

return _Waves;
