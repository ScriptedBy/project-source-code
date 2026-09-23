--// Manages global leaderboards by storing, ranking, and displaying player statistics for cases opened and rounds completed.

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local GlobalDataStore = DataStoreService:GetOrderedDataStore("Cases_1.1");
local GlobalDataStore2 = DataStoreService:GetOrderedDataStore("Rounds_1.1");

local ProfileService = require(ReplicatedStorage.Modules["Proile Manager"]["Profile Functions"]);

local CaseLeaderboard = workspace.Lobby.Decore.Leaderboard.Display.Container.Container.Container
local RoundLeaderboard = workspace.Lobby.Decore.Leaderboard2.Display.Container.Container.Container

local _Global = {}

local GetSizes = function(Value)
	return Vector2.new(1, .2), Vector2.new(1, .2), 100

end

function _Global:SetCanvasSize(searchOn, Shrink, obj, obj2, Type)


	local PADDING, SIZE, MAX_CELLS;

	PADDING, SIZE, MAX_CELLS = GetSizes(Shrink);

	local AbsoluteSize = obj.AbsoluteSize;
	local NewPadding = PADDING * AbsoluteSize;
	NewPadding = UDim2.new(0, NewPadding.X, 0, NewPadding.Y);
	local NewSize = SIZE * AbsoluteSize;
	NewSize = UDim2.new(0, NewSize.X, 0, NewSize.Y);

	obj2.CellPadding = NewPadding;
	obj2.CellSize = NewSize;

	local Children = obj:GetChildren();
	local Items = 0;
	if searchOn == true then
		for i, v in pairs(Children) do
			if v:IsA("Frame") then
				if v.Visible == true then
					Items += 1;
				end
			end
		end
	else
		Items = (#Children) - 1;
	end
	local FrameSizeY = obj.AbsoluteSize.Y;
	local ySize = obj2.CellSize.Y.Offset;
	local yPadding = obj2.CellPadding.Y.Offset;
	obj2.FillDirectionMaxCells = MAX_CELLS;
	local rows = math.ceil(Items / obj2.FillDirectionMaxCells);
	local pixels = rows * ySize + (rows - 1) * yPadding;
	obj.CanvasSize = UDim2.new(0, 0, 0, (pixels + 5));

end


local function CreateDisplay(plr, userid, obj, cases, rank, obj2)
	if rank == 1 then
		obj.Amount.PlayerName.First.Enabled = true 
		obj.Amount.Rank.First.Enabled = true 
	elseif rank == 2 then
		obj.Amount.PlayerName.Second.Enabled = true 
		obj.Amount.Rank.Second.Enabled = true 
	elseif rank == 3 then
		obj.Amount.PlayerName.Third.Enabled = true 
		obj.Amount.Rank.Third.Enabled = true 
	end
	obj.PlayerImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..userid.."&width=420&height=420&format=png"
	obj.Amount.Text = cases
	obj.Amount.Rank.Text = "[#"..rank.."]"
	obj.Amount.PlayerName.Text = plr
	obj.LayoutOrder = rank

	obj.Parent = obj2
end


function _Global:UpdateLeaderboard(Cases)

	local Template = script.PlayerSlot:Clone()

	for i, v in pairs(CaseLeaderboard:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end

	local success, err = pcall(function()
		local Data = GlobalDataStore:GetSortedAsync(false, 100)
		local Page = Data:GetCurrentPage()

		for rank, plrData in ipairs(Page) do
			local UserId = plrData.key
			local Value = plrData.value
			local PlayerU = Players:GetNameFromUserIdAsync(UserId)
			local obj = Template:Clone()
			CreateDisplay(PlayerU, UserId, obj, Value, rank, CaseLeaderboard)
		end
	end)

end

function _Global:UpdateLeaderboard2(Rounds)

	local Template = script.PlayerSlot2:Clone()

	for i, v in pairs(RoundLeaderboard:GetChildren()) do
		if v:IsA("Frame") then
			v:Destroy()
		end
	end

	local success, err = pcall(function()
		local Data = GlobalDataStore2:GetSortedAsync(false, 100)
		local Page = Data:GetCurrentPage()

		for rank, plrData in ipairs(Page) do
			local UserId = plrData.key
			local Value = plrData.value
			local PlayerU = Players:GetNameFromUserIdAsync(UserId)
			local obj = Template:Clone()
			CreateDisplay(PlayerU, UserId, obj, Value, rank, RoundLeaderboard)
		end
	end)



end

function _Global:Int()
	spawn(function()
		
		while true do
			for i, v in pairs(game.Players:GetPlayers()) do
				local Data = ProfileService[game.Players[tostring(v)]];

				if Data ~= nil then
					local PlayerData = Data.Data.Data.Player

					if RunService:IsStudio() then

					else
						GlobalDataStore:SetAsync(v.UserId, PlayerData.Cases)
						GlobalDataStore2:SetAsync(v.UserId, PlayerData.Rounds)
					end
					
					if PlayerData ~= nil then
						_Global:UpdateLeaderboard(PlayerData.Cases)
						_Global:UpdateLeaderboard2(PlayerData.Rounds)
					end
				end
				
				
			end

			

			wait(math.random(20, 35))
		end
	end)
end

return _Global;
