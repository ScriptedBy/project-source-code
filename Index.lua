--// Tracks, sorts, and retrieves available indexed items based on their selection status and position.


local _Index = {}

local minTab, maxTab = {}, {}
function _Index:ClearTables()
	if minTab ~= nil then
		minTab = {}
	end

	if maxTab ~= nil then
		maxTab = {}
	end
end

function _Index:AddToTables(plr, v)
	if v.Selected.Value == "None" then
		table.insert(minTab, {v.Name, v.IndexPos.Value})
		table.insert(maxTab, {v.Name, v.IndexPos.Value})
	end
end

function _Index:SortTables()
	table.sort(minTab, function(a,b) 
		return a[2] < b[2] 
	end)

	table.sort(maxTab, function(a,b) 
		return a[2] > b[2]
	end)

	if #minTab == 0 then
		print("Empty")
	end
end

function _Index:ReturnData(plr, v)
	if minTab ~= nil and maxTab ~= nil then
		if #minTab > 0 then
			return #minTab, minTab[1][2], maxTab[1][2], minTab[1]
		else 
			return 0, 0, 0 
		end
		
	end
	
end

return _Index; 
