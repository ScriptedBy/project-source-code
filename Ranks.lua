--// Maps player levels to progression ranks and assigns unique display colors for each rank.

local _Rank = {}

function _Rank:ReturnRank(Level)
	if Level == 1 then
		return {"VISITOR", Color3.fromRGB(255, 255, 255)} -- White, Return rewards later
	elseif Level == 2 then
		return {"STARTER", Color3.fromRGB(255, 221, 197)} -- Light orange
	elseif Level == 3 then
		return {"NOOB", Color3.fromRGB(255, 249, 174)} -- Light Yellow
	elseif Level == 4 then
		return {"BASIC", Color3.fromRGB(221, 255, 193)} -- Light Green
	elseif Level == 5 then
		return {"AVERAGE", Color3.fromRGB(217, 254, 255), "MAX"} -- Light Blue
	elseif Level == 6 then
		return {"PRO", Color3.fromRGB(117, 177, 255)} -- Light Cyan, Stops here for now
	elseif Level == 7 then
		return {"ELITE", Color3.fromRGB(116, 125, 255)} -- Light Purple
	elseif Level == 8 then
		return {"MASTER", Color3.fromRGB(196, 124, 255)} -- Purple/Pink, light
	elseif Level == 9 then
		return {"KING", Color3.fromRGB(255, 121, 123)} -- Light Red
	elseif Level == 10 then
		return {"LEGEND", Color3.fromRGB(255, 240, 67)} -- Yellow
	elseif Level == 11 then
		return {"HACKER", Color3.fromRGB(255, 139, 56)} -- Orange
	elseif Level == 12 then
		return {"MANIPULATOR", Color3.fromRGB(86, 86, 86)}
	elseif Level == 13 then
		return {"ANGELIC", Color3.fromRGB(255, 255, 255)}
	elseif Level == 14 then
		return {"GOD", Color3.fromRGB(255, 255, 255)}
	elseif Level == 15 then
		return {"IMPOSSIBLE", Color3.fromRGB(255, 255, 255)}
	end
end

return _Rank;
