-- for debugging purposes
-- echo("consoleExplore", "Empty line detected\n")

-- stop redirects when there is an empty line
mudTextRedirect = ""

-- do the detection and removal of extra empty lines
emptyLine = emptyLine + 1
if emptyLine == 2 then
  deleteLine()
  emptyLine = 1
end