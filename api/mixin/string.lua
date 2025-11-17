

function string.startsWith(str, startWithStr)
	return str:sub(1, #startWithStr) == startWithStr;
end

function string.endsWith(str, endsWithStr)
	return str:sub(#str-#endsWithStr+1, #str) == endsWithStr;
end

function string.contains(str, charSeq)
	local startIndex, _ = str:find(charSeq);
	if startIndex == nil then return false
	else return true end
end
