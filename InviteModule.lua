--// Manages the player invite system by prompting friend invitations and displaying reward notifications when invited players join.

local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Invite = ReplicatedStorage:WaitForChild("Remotes")["Remote Events"]["Invite"];

repeat wait() until Players.LocalPlayer;
local Player = Players.LocalPlayer
local Obj = game.Workspace.Lobby.Decore.Obj
local Reward = Obj.Reward

local _Invite = {}

-- Function to check whether the player can send an invite
local function canSendGameInvite(sendingPlayer)
	local success, canSend = pcall(function()
		return SocialService:CanSendGameInviteAsync(sendingPlayer)
	end)
	return success and canSend
end


function _Invite:ShowInviteMessage(Currency1, Currency2, Value1, Value2)
	local message = "You have invited or had a new friend join you! You have recieved ⭐"..Value1.." "..Currency1.. " and 💎"..Value2.." "..Currency2.."!"
	game.TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(message)
end


function _Invite:Int()
	Invite.OnClientEvent:Connect(function(...)
		_Invite:ShowInviteMessage(...)
	end)
	
	Reward.Touched:Connect(function(hit)
		if hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
			if hit.Parent.Name ~= "Obj" then
				local canInvite = canSendGameInvite(Player)
				if canInvite then
					local success, errorMessage = pcall(function()
						SocialService:PromptGameInvite(Player)
					end)
				end
			end
		end
	end)
end

return _Invite
