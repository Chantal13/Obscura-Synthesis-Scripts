local amount = matches[2]
cecho("\n<yellow>[Tax] <white>Paying " .. amount .. " gold coins to the tax collector...\n")
send("give " .. amount .. " gold coin to collector")