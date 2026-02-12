if chantRetrying then
    cecho("\n<yellow>[Chant] <white>Can't cast " .. chantRetrying .. " indoors, stopping.\n")
    chantRetrying = nil
    chantRetries = 0
end
deleteLine()