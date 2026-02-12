if lastChant then
    local chant = lastChant
    lastChant = nil
    tempTimer(30, function()
        send('CHANT "' .. chant .. '"')
    end)
end