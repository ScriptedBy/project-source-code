--// Manages multi-item deletion by tracking selected inventory items, updating selection counts, and handling item removal or reset operations.

local Players = game:GetService("Players");

repeat wait() until Players.LocalPlayer
local Player = Players.LocalPlayer
local PlayerUI = Player:WaitForChild("PlayerGui");
local ScreenUI = PlayerUI:WaitForChild("ScreenGui");
local UIFrame  = ScreenUI:WaitForChild("UI");
local InventoryFrame = UIFrame:WaitForChild("Inventory")

local MultiDeleteModule = {}
local ItemsInDelete = {}

function UpdateDelete(num)
	local Amount = #ItemsInDelete
	if type(tonumber(Amount)) == "number" then
		InventoryFrame.DeleteDisplay.Selected.Text = tostring(Amount).." Item(s) Selected"
	end
end

function MultiDeleteModule:AddItemToMultiDelete(Item)
	if Item ~= nil then
		if not table.find(ItemsInDelete, Item) then
			table.insert(ItemsInDelete, Item)
			UpdateDelete()
		end
	end
end

function MultiDeleteModule:DeleteItemInMultiDelete(Item)
	if Item ~= nil then
		local place = table.find(ItemsInDelete, Item)
		if place then
			table.remove(ItemsInDelete, tonumber(place))
			UpdateDelete()
		end
	end
end

function MultiDeleteModule:ResetMultiDeleteTable()
	ItemsInDelete = {}
end

function MultiDeleteModule:GetMutliDeletePets()
	return ItemsInDelete
end

return MultiDeleteModule;
