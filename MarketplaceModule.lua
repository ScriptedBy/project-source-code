--// Processes developer product purchases and automatically grants purchased crates, equipment upgrades, coins, and diamonds.

local MarketplaceService = game:GetService("MarketplaceService");
local ServerScriptService = game:GetService("ServerScriptService");
local HttpService = game:GetService("HttpService");
local Players = game:GetService("Players");

local CaseModule = require(script.Parent["__Cases"]);

local _Marketplace = {}

local DeveloperPass = {
	
	["Exclusive Crate 1"] = {1583358771, 1,

		function(plr) 
			return CaseModule:OpenRobux(plr, "Exclusive Crate 1", "Buy1");
		end
	},
	
	["Exclusive Crate 1 (Type 3)"] = {1583358601, 1,

		function(plr) 
			return CaseModule:OpenRobux(plr, "Exclusive Crate 1", "Buy3");
		end
	},
	
	["+5 Equip"] = {1192831944, 1,

		function(plr) 
			return CaseModule:AddAmtEquip(plr, "Bought");
		end
	},
	
	-- Passes
	
	["1000 Coins"] = {1572712904, 1,

		function(plr) 
			return CaseModule:AddAmount(plr, 1000, "Coins");
		end
	},
	["10000 Coins"] = {1572712994, 1,

		function(plr) 
			return CaseModule:AddAmount(plr, 10000, "Coins");
		end
	},
	["50000 Coins"] = {1572713198, 1,

		function(plr) 
			return CaseModule:AddAmount(plr, 50000, "Coins");
		end
	},
	["100000 Coins"] = {1572713376, 1,

		function(plr) 
			return CaseModule:AddAmount(plr, 100000, "Coins");
		end
	},
	["500000 Coins"] = {1572713627, 1,

		function(plr) 
			return CaseModule:AddAmount(plr, 500000, "Coins");
		end
	},
	["200 Diamonds"] = {1572713770, 1,

		function(plr) 
			return CaseModule:AddAmount(plr, 200, "Diamonds");
		end
	},
	["1000 Diamonds"] = {1572713857, 1,

		function(plr) 
			return CaseModule:AddAmount(plr, 1000, "Diamonds");
		end
	},
	["5000 Diamonds"] = {1572713928, 1,

		function(plr) 
			return CaseModule:AddAmount(plr, 5000, "Diamonds");
		end
	},
	["10000 Diamonds"] = {1572714116, 1,

		function(plr) 
			return CaseModule:AddAmount(plr, 10000, "Diamonds");
		end
	},
	["50000 Diamonds"] = {1572714258, 1,

		function(plr) 
			return CaseModule:AddAmount(plr, 50000, "Diamonds");
		end
	}
	
	
	
}

function _Marketplace:Int()
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local plr = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if plr and receiptInfo then
			local success = false
			for i, v in pairs(DeveloperPass) do
				if type(v) == "table" then
					local ID, image, funct = v[1], v[2], v[3]
					if ID ~= nil and funct ~= nil and type(funct) == "function" then
						if receiptInfo.ProductId == ID then
							local functionFinished = funct(plr)
							if functionFinished == nil then
								warn(plr.Name, "error occurred when purchasing", i)
								--SendReciept(plr, i, image, false)
								success = false
							else
								--SendReciept(plr, i, image, true)
								success = true
							end
							break
						end
					end
				end
			end

			if success == true then
				return Enum.ProductPurchaseDecision.PurchaseGranted
			else
				return Enum.ProductPurchaseDecision.NotProcessedYet	
			end
		end

		return Enum.ProductPurchaseDecision.NotProcessedYet	
	end
end


return _Marketplace;

--[[


local MarketplaceModule = {}

local MarketplaceService = game:GetService("MarketplaceService");
local ServerScriptService = game:GetService("ServerScriptService");
local HttpService = game:GetService("HttpService");
local Players = game:GetService("Players");

local Library = require(game.ReplicatedStorage.Modules["Game Contents"]["Library Module"]);
local Webhook = require(script.Parent:WaitForChild("Webhook Module"));
local CaseModule = require(script.Parent["Case Module"]);
local BoostModule = Library("Boost Module");
local WEBHOOK_URL = Webhook["Developer Reciepts"]

local DeveloperPass = {
	["Octogo Egg (One Pet)"] = {1192831865, 7162713445,

		function(plr) 
			return CaseModule:OpenRobux(plr, "Octogo Egg", "Buy1", "Pet");
		end

	};
	["Octogo Egg (Three Pets)"] = {1192831944, 7162713445,

		function(plr) 
			return CaseModule:OpenRobux(plr, "Octogo Egg", "Buy3", "Pet"); 
		end

	};
	
	-- PRODUCT PASSES
	
	["Triple Open (+1 Hour)"] = {1193552221, 7100679557,

		function(plr) 
			return CaseModule:AddBoosts(plr, "Triple Open", "+1 Hour"); 
		end

	};
	
	["Faster Open (+1 Hour)"] = {1189971051, 7100680692,

		function(plr) 
			return CaseModule:AddBoosts(plr, "Faster Open", "+1 Hour"); 
		end

	};
	
	
	["x2 Luck (+1 Hour)"] = {1193665567, 7101267499,

		function(plr) 
			return CaseModule:AddBoosts(plr, "x2 Luck", "+1 Hour"); 
		end

	};
	
	["x2 Luck (+5 Hours)"] = {1193665839, 7101267499,

		function(plr) 
			return CaseModule:AddBoosts(plr, "x2 Luck", "+5 Hours"); 
		end

	};
	
	["x2 Shiny (+1 Hour)"] = {1189970837, 7100686712,

		function(plr) 
			return CaseModule:AddBoosts(plr, "x2 Shiny", "+1 Hour"); 
		end

	};

	["x2 Shiny (+5 Hours)"] = {1189970947, 7100686712,

		function(plr) 
			return CaseModule:AddBoosts(plr, "x2 Shiny", "+5 Hours"); 
		end

	};
	
	["x2 Coins (+1 Hour)"] = {1189971051, 7100705831,

		function(plr) 
			return CaseModule:AddBoosts(plr, "x2 Coins", "+1 Hour"); 
		end

	};

	["x2 Coins (+5 Hours)"] = {1189971097, 7100705831,

		function(plr) 
			return CaseModule:AddBoosts(plr, "x2 Coins", "+5 Hours"); 
		end

	};
	
	
}

local function SendReciept(plr, devproduct, image, success)
	local Message, Color

	if success == true then
		Message, Color = "successfully purchased this product.", 5504843
	else
		Message, Color = "had an error occur while trying to purchase this product.", 16734296 
	end

	local Data = HttpService:JSONEncode({
		["embeds"] = {{
			["title"] = devproduct.. "[ "..plr.Name..", "..plr.UserId.." ]",
			["description"] = Message,
			["color"] = tonumber(Color),
			["image"] = {
				["url"] = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=50&height=50&assetId="..image
			}

		}}
	})
	if Data ~= nil then
		HttpService:PostAsync(WEBHOOK_URL, Data);
	end
end



function MarketplaceModule:Int()
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local plr = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if plr and receiptInfo then
			local success = false
			for i, v in pairs(DeveloperPass) do
				if type(v) == "table" then
					local ID, image, funct = v[1], v[2], v[3]
					if ID ~= nil and funct ~= nil and type(funct) == "function" then
						if receiptInfo.ProductId == ID then
							local functionFinished = funct(plr)
							if functionFinished == nil then
								warn(plr.Name, "error occurred when purchasing", i)
								SendReciept(plr, i, image, false)
								success = false
							else
								-SendReciept(plr, i, image, true)
								success = true
							end
							break
						end
					end
				end
			end

			if success == true then
				return Enum.ProductPurchaseDecision.PurchaseGranted
			else
				return Enum.ProductPurchaseDecision.NotProcessedYet	
			end
		end

		return Enum.ProductPurchaseDecision.NotProcessedYet	
	end
end

return MarketplaceModule;



]]
