function log(...)
	fg("green")
	print(...)
end

function stripColors(str)
	str = str:gsub("%^[MRGYBPCWkrgybpcw?]", "")
	return str:gsub("%^#%d%d%d", "")
end
