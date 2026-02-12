-- [XAMM] prompt detected
xammPrompt = true

-- detection for when the game has started
if gameStarted == false then
  gameStarted = true
end


-- gag line
deleteLine()

-- (this is only for the first line of [XAMM] prompt
-- echo("\n\n")

-- stop all redirects
mudTextRedirect = ""

-- get data for items
-- ttsQueue("items detected")
charCarry = tonumber(matches[2])
-- echo("carrying = "..charCarry.."\n")
charMaxCarry = tonumber(matches[3])
-- echo("maxcarry = "..charMaxCarry.."\n")