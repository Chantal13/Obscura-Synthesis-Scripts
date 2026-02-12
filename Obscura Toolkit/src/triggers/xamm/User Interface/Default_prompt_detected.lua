
-- inform user how to set up for full integration with XAMM
local issue = "Default CoffeeMud prompt detected."
local command = "xamm set prompt"
local solution = "to enable full XAMM integration."
xamm_alert(issue, command, solution)

-- inform user how to start TimeBar manually
if mudTimeKnown == false then
  local issue = "Time Bar has not started tracking time."
  local command = "time"
  local solution = "to start tracking mud time with the Time Bar."
  xamm_tip(issue, command, solution)
end