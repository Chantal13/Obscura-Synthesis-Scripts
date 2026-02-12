cookIngredient = matches[2]
if not cookIngredient or cookIngredient == "" then
    cecho("\n<yellow>[Cook] <red>Usage: cc <ingredient>  (e.g. cc meat)\n")
else
    cookingActive = true
    cecho("\n<yellow>[Cook] <white>Starting to cook with " .. cookIngredient .. "...\n")
    send("put " .. cookIngredient .. " pot")
end