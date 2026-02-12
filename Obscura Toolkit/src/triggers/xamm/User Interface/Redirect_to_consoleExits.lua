-- debugging
xammPrompt = false -- set the start signal to do redirects

-- using system display of exits to frequently trigger for GROUP update
-- send("group")


-- reset empty line counter
emptyLine = 0

-- gag line
deleteLine()
-- moveCursor(0,getLineNumber()-1)         -- move the cursor back one line

-- clear consoleExits
clearWindow("consoleExits")
mudTextRedirect = "consoleExits" -- set the signal for the redirect everything trigger