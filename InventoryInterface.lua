--// Dynamically adjusts UI grid sizing, spacing, and scrolling based on visible inventory items and screen dimensions.

local _Interface = {}

local Players = game:GetService("Players");

repeat wait() until Players.LocalPlayer;
local Player = Players.LocalPlayer;
local PlayerUI = Player:WaitForChild("PlayerGui");
local ScreenUI = PlayerUI:WaitForChild("ScreenGui");
local UIFrame  = ScreenUI:WaitForChild("UI");
local InventoryFrame = UIFrame:WaitForChild("Inventory");
--local ScrollingFrame = InventoryFrame.Container.ScrollingFrame;
--local UIGridLayout = ScrollingFrame.UIGridLayout

local GetSizes = function(Value)
	return Vector2.new(0.002*1.2, 0.001*1.2), Vector2.new(0.16*1.2, 0.34*1.2), 5

end

local GetSongSizes = function(Value)
	return Vector2.new(0, 0.01), Vector2.new(0.97, 0.17), 1
end

function _Interface:SetCanvasSize(searchOn, Shrink, obj, obj2, Type)
	
	
	local PADDING, SIZE, MAX_CELLS;
	if Type ~= nil then
		PADDING, SIZE, MAX_CELLS = GetSongSizes(Shrink);
	else
		PADDING, SIZE, MAX_CELLS = GetSizes(Shrink);
	end
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

return _Interface;
