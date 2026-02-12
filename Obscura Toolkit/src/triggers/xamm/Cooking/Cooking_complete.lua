local item = cookingItem or "something"
cecho("\n<yellow>[Cook] <white>" .. item .. " is done!\n")
cookingItem = nil
if cookingActive then
    send("get all pot")
    local ingredient = cookIngredient
    tempTimer(1, function()
        send("put " .. ingredient .. " pot")
    end)
end