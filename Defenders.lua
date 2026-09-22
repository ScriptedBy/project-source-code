-- // Defines defender units and their gameplay attributes, including rarity, damage, rewards, cooldowns, trading, and special abilities.


local _Defenders = {
	
	--// Starters
	["Security Helper"] = {
		Name = "Security Helper",
		Image = 13803386036,
		HipHeight = -.5,
		Rarity = 0,
		Damage = 20,
		Tokens = 10,
		XP = 6,
		Reload = 5,
		Tradeable = true,
		Specialties = nil

	},
	
	--// VIP
	["VIP Security"] = {
		Name = "VIP Security",
		Image = 13954872469,
		HipHeight = 0,
		Rarity = 0.5,
		Damage = 75,
		Tokens = 40,
		XP = 25,
		Reload = 4,
		Special = 10,
		Tradeable = false,
		Specialties = {"Shield"}

	},
	
	--// Rarity 1
	["Security Toilet"] = {
		Name = "Security Toilet",
		Image = 13803386036,
		HipHeight = -.5,
		Rarity = 1,
		Damage = 25,
		Tokens = 15,
		XP = 10,
		Reload = 5,
		Tradeable = true,
		Specialties = nil

	},

	--// Rarity 2
	["Security Medic"] = {
		Name = "Security Medic",
		Image = 13804942170,
		HipHeight = 0,
		Rarity = 2,
		Damage = 50,
		Tokens = 20,
		XP = 15,
		Reload = 5,
		Heal = 25,
		Special = 10,
		Tradeable = true,
		Specialties = {"Heal Medic"}
	},
	
	["Handsaw Security"] = {
		Name = "Handsaw Security",
		Image = 13830119510,
		HipHeight = 0,
		Rarity = 3,
		Damage = 200,
		Tokens = 170,
		XP = 75,
		Reload = 4,
		Special = 10,
		Tradeable = true,
		Specialties = nil
	},
	
	["Cameraman"] = {
		Name = "Cameraman",
		Image = 13822572418,
		HipHeight = 0,
		Rarity = 3,
		Damage = 210,
		Tokens = 180,
		XP = 100,
		Reload = 4,
		Special = 10,
		Tradeable = true,
		Specialties = nil
	},
	
	--// Rarity 3
	["Speakerman"] = {
		Name = "Speakerman",
		Image = 13832023357,
		HipHeight = 0,
		Rarity = 3,
		Damage = 150,
		Tokens = 120,
		XP = 100,
		Reload = 4,
		Special = 10,
		Tradeable = true,
		Specialties = nil
	},
	
	--// Rarity 4
	["OG Speakerman"] = {
		Name = "OG Speakerman",
		Image = 13822654474,
		HipHeight = 0,
		Rarity = 4,
		Damage = 300,
		Tokens = 240,
		XP = 150,
		Reload = 4,
		Special = 10,
		Tradeable = true,
		Specialties = {"Shield"}
	},
	
	["TV Man"] = {
		Name = "TV Man",
		Image = 14092470684,
		HipHeight = 0,
		Rarity = 4,
		Damage = 450,
		Tokens = 400,
		XP = 250,
		Reload = 4,
		Special = 10,
		Tradeable = true,
		Specialties = {"Shield"}
	},
	--// Rarity 5
	["Upgraded Cameraman"] = {
		Name = "Upgraded Cameraman",
		Image = 13822626033,
		HipHeight = 0,
		Rarity = 5,
		Damage = 550,
		Tokens = 340,
		XP = 300,
		Reload = 4,
		Special = 10,
		Tradeable = true,
		Specialties = {"Camera Boom"}
	},
	
	["Upgraded Radioman"] = {
		Name = "Upgraded Radioman",
		Image = 14092477295,
		HipHeight = 0,
		Rarity = 5,
		Damage = 1050,
		Tokens = 640,
		XP = 300,
		Reload = 4,
		Special = 10,
		Tradeable = true,
		Specialties = {"Camera Boom"}
	},
	
	--// Rarity 6
	["Titan Speakerman"] = {
		Name = "Titan Speakerman",
		Image = 13803603391,
		HipHeight = 0,
		Rarity = 6,
		Damage = 2,
		Tokens = 2,
		XP = 2,
		Reload = 1,
		Special = 50,
		Tradeable = true,
		Specialties = {"Competitor", "Barrage"}
	},
	
	["Titan Cameraman"] = {
		Name = "Titan Cameraman",
		Image = 14092475032,
		HipHeight = 0,
		Rarity = 6,
		Damage = 2,
		Tokens = 2,
		XP = 2,
		Reload = 1,
		Special = 50,
		Tradeable = true,
		Specialties = {"Competitor", "Barrage 2"}
	},
}


return _Defenders; 

