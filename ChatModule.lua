--// Manages the in-game chat system, including developer/moderator/VIP tags, automated server messages, and rare-item announcements.

local TextChatService = game:GetService("TextChatService");
local MarketPlaceService = game:GetService("MarketplaceService");

local _Chat  = {}

local Developer = {
	["B_rnz"] = {
		"<font color='#0063ef'>[Developer ⚒️] </font>", 
		"<font color='#0063ef'>[Developer ⚒️]</font>"
	}
}
local Mods = {
	["Trendybxlla"] = {
		"<font color='#00ffee'>[Moderator 🔨] </font>",
		"<font color='#00ffee'>[Moderator 🔨]</font>"
	},
	["ejim434157"] = {
		"<font color='#C3B1E1'>[Moderator 🔨] </font>",
		"<font color='#C3B1E1'>[Moderator 🔨]</font>",
	},
	["blazenma"] = {
		"<font color='#C48189'>[Moderator 🔨] </font>",
		"<font color='#C48189'>[Moderator 🔨]</font>",
	},
}

function HasPass(Player, id)
	if MarketPlaceService:UserOwnsGamePassAsync(Player.UserId, id) then
		return true
	end

	return false
end

function CheckPass(Player, id, which)
	if which == "Check" then
		return HasPass(Player, id);
	elseif which == "Prompt" then
		MarketPlaceService:PromptGamePassPurchase(Player, id);

	end
	return false
end

function _Chat:RareOpening(Player, ItemName)
	
	local message = "[Server]: "..Player.Name.." opened a rare "..tostring(ItemName).."!"
	game.TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(message)
	
end

function _Chat:ServerMessages()
	game.TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage("Welcome to Skibi Toilet Defense!")
	spawn(function()
		while true do
			local WaitTime = math.random(200, 300)
			game.TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage("Need help? Please click on the question mark to learn how to play")
			wait(WaitTime)
			game.TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage("⭐ Want a TON of rewards? Invite your friends! One time per NEW FRIEND only!")
			wait(WaitTime)
			game.TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage("If you enjoy the game, please give us a (⭐) or a (👍), and join the group for rewards!")
			wait(WaitTime)
		end
		
		
		
	end)
	
end

function _Chat:AddTags()
	
	TextChatService.OnIncomingMessage = function(message: TextChatMessage)
		local properties = Instance.new("TextChatMessageProperties")

		if message.TextSource then
			local Player = game:GetService("Players"):GetPlayerByUserId(message.TextSource.UserId)

			for i, v in pairs(Developer) do
				if Player.Name == i and CheckPass(Player, 199501207, "Check") == false then
					properties.PrefixText = v[1] .. message.PrefixText
				elseif Player.Name == i and CheckPass(Player, 199501207, "Check") == true then
					properties.PrefixText = v[2] .."<font color='#FFD700'>[VIP]: </font>".. message.PrefixText
				elseif Player.Name ~= i then
					for a, b in pairs(Mods) do
						if Player.Name == a and CheckPass(Player, 199501207, "Check") == false then
							properties.PrefixText = b[1] .. message.PrefixText
						elseif Player.Name == a and CheckPass(Player, 199501207, "Check") == true then
							properties.PrefixText = b[2] .."<font color='#FFD700'>[VIP]: </font>".. message.PrefixText
						end
					end
				elseif Player.Name ~= i and CheckPass(Player, 199501207, "Check") == true then
					properties.PrefixText = "<font color='#FFD700'>[VIP]: </font>".. message.PrefixText
				end
			end
		end

		return properties;
	end
end

function _Chat:Int()
	_Chat:ServerMessages()
	_Chat:AddTags()
	
end

return _Chat;
