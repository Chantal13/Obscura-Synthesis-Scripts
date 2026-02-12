mendQueue = {}
mendIndex = 0
mendActive = true
cecho("\n<yellow>[Mend] <white>Removing all leather equipment...\n")
send("rem all.leather")
tempTimer(2, function()
    if mendActive and #mendQueue > 0 then
        mendIndex = 1
        local item = mendQueue[mendIndex]
        cecho("\n<yellow>[Mend] <white>Mending " .. item .. " (1/" .. #mendQueue .. ")...\n")
        send("leather mend " .. item)
    elseif mendActive then
        cecho("\n<yellow>[Mend] <white>No leather items to mend.\n")
        mendActive = false
    end
end)