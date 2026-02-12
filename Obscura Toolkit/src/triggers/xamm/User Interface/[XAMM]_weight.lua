-- [XAMM] prompt detected
xammPrompt = true

-- gag line
deleteLine()

-- stop all redirects
mudTextRedirect = ""

-- get data for weight
-- ttsQueue("weight detected")
charWeight = tonumber(matches[2])
-- echo("carrying = "..charWeight.."\n")
charMaxWeight = tonumber(matches[3])
-- echo("maxcarry = "..charMaxWeight.."\n")