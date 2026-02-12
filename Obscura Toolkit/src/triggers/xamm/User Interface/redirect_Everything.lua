-- for debugging purposes
-- echo("consoleExplore","Detected line = "..matches[2].."\n")

-- reset emptyLine since it's not an empty line
emptyLine = 0


if mudTextRedirect ~= "" and (xammPrompt==false) then
  -- do the redirection to other consoles
    selectCurrentLine()
    copy()
    appendBuffer(mudTextRedirect)
    deleteLine()
end

if xammPrompt==true then
  mudTextRedirect = "" -- stop redirecting since reached prompt
end
