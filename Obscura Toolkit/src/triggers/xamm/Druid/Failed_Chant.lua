if lastChant then
    local chant = lastChant
    chantRetries = (chantRetries or 0) + 1
    chantRetrying = chant
    if chantRetries <= 3 then
        tempTimer(30, function()
            send('CHANT "' .. chant .. '"')
        end)
    else
        chantRetries = 0
        chantRetrying = nil
    end
end