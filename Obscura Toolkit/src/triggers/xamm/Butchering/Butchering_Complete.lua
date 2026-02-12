butcherCount = butcherCount + 1
if butcherCount < butcherMax then
    cecho("\n<yellow>[Butcher] <white>Finished #" .. butcherCount .. ", butchering next body...\n")
    send("butcher body")
else
    cecho("\n<yellow>[Butcher] <white>Done! Butchered " .. butcherCount .. " bodies.\n")
    butcherCount = 0
end