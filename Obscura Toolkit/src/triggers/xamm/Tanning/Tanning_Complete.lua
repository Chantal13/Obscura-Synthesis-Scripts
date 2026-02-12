if tanningActive then
    cecho("\n<yellow>[Tan] <white>Tanning complete!\n")
    send("get leather")
    tanningActive = false
end