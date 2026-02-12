mendQueue = {}
mendIndex = 0
mendActive = false

function mendAdvance(message)
    if not mendActive then return end
    local item = mendQueue[mendIndex]
    cecho("\n<yellow>[Mend] <white>" .. item .. " " .. message .. "\n")
    send("wear " .. item)
    mendIndex = mendIndex + 1
    if mendIndex <= #mendQueue then
        local nextItem = mendQueue[mendIndex]
        cecho("\n<yellow>[Mend] <white>Mending " .. nextItem .. " (" .. mendIndex .. "/" .. #mendQueue .. ")...\n")
        tempTimer(1, function()
            send("leather mend " .. nextItem)
        end)
    else
        cecho("\n<yellow>[Mend] <white>All items mended!\n")
        mendActive = false
    end
end