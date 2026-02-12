if cookingActive then
    cecho("\n<yellow>[Cook] <red>Fire went out! Build a new fire and type cc " .. (cookIngredient or "ingredient") .. " again.\n")
    cookingActive = false
    cookingItem = nil
end
if tanningActive then
    cecho("\n<yellow>[Tan] <red>Fire went out! Build a new fire and type tt again.\n")
    tanningActive = false
end