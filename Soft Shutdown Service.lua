--// Handles server reboots by temporarily moving players to a reserved server and returning them to the main game afterward.

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

if (game.VIPServerId ~= "" and game.VIPServerOwnerId == 0) then
	-- this is a reserved server without a VIP server owner
	local m = Instance.new("Message")
	m.Text = "This is a temporary lobby. Teleporting back in a moment."
	m.Parent = workspace
	
	local waitTime = 5

	Players.PlayerAdded:connect(function(player)
		wait(waitTime)
		waitTime = waitTime / 2
		TeleportService:Teleport(game.PlaceId, player)
	end)
	
	for _,player in pairs(Players:GetPlayers()) do
		TeleportService:Teleport(game.PlaceId, player)
		wait(waitTime)
		waitTime = waitTime / 2
	end
else
	game:BindToClose(function()
		if (#Players:GetPlayers() == 0) then
			return
		end
		
		if (game.JobId == "") then
			-- Offline
			return
		end
		
		local m = Instance.new("Message")
		m.Text = "Rebooting servers for update. Please wait"
		m.Parent = workspace
		wait(2)
		local reservedServerCode = TeleportService:ReserveServer(game.PlaceId)
		
		for _,player in pairs(Players:GetPlayers()) do
			TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerCode, { player })
		end
		Players.PlayerAdded:connect(function(player)
			TeleportService:TeleportToPrivateServer(game.PlaceId, reservedServerCode, { player })
		end)
		while (#Players:GetPlayers() > 0) do
			wait(1)
		end	
		
		-- done
	end)
end
