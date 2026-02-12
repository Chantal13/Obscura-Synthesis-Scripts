if fireFailed then
    fireFailed = false
    tempTimer(1, function()
        send("light fire")
    end)
else
    -- Success! Stop practicing
    fireFailed = false
end