-- [XAMM] prompt detected
xammPrompt = true

-- gag line
deleteLine()

-- stop all redirects
mudTextRedirect = ""

-- commands to perform when end of prompt is detected
  -- echo("\n\n")
  -- inform user how to start TimeBar manually
  if mudTimeKnown == false then
    local issue = "Time Bar has not started tracking time."
    local command = "time"
    local solution = "to start tracking mud time with the Time Bar."
    xamm_tip(issue, command, solution)
  end
  
  -- check if current session's char data is loaded
  if charName == nil then
    local issue = "XAMM needs current session character data."
    local command = "score"
    local solution = "to load current character data into XAMM."
    xamm_alert(issue, command, solution)
  end
