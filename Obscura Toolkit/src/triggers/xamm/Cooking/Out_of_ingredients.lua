if cookingActive then
    cecho("\n<yellow>[Cook] <white>Out of " .. (cookIngredient or "ingredients") .. ". Cooking done!\n")
    cookingActive = false
end