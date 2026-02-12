tanningActive = true
cecho("\n<yellow>[Tan] <white>Starting tanning loop...\n")
send("drop bundle")
tempTimer(1, function()
    if tanningActive then
        send("tan bundle")
    end
end)