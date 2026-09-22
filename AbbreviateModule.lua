--// This is my abbreviate module, used to abbreviate high values.

local AbbreviateNumber = {}

local Abbrevations = {
	K = 4,
	M = 7,
	B = 10,
	T = 13,
	Qa = 16
}

function AbbreviateNumber:Abbreviate(number)
	local Text = tostring(math.floor(number));
	
	local ChosenAbbrevation
	for i, v in pairs(Abbrevations) do
		if #Text >= v and #Text < (v + 3) then
			ChosenAbbrevation = i
			break
		end
	end
	
	if ChosenAbbrevation then
		local Digits = Abbrevations[ChosenAbbrevation];
		local Rounded = math.floor(number / 10 ^ (Digits - 2) * 10 ^ (Digits - 2));
		Text = string.format("%.1f", Rounded / 10 ^ (Digits - 1)) .. ChosenAbbrevation
	else
		Text = number
	end
	
	return Text
end

function AbbreviateNumber:RoundDecimals(number, Places)
	Places = math.pow(10, Places or 0)
	number = number * Places

	if number >= 0 then 
		number = math.floor(number + 0.5) 
	else 
		number = math.ceil(number - 0.5) 
	end

	return number / Places
end

return AbbreviateNumber;
