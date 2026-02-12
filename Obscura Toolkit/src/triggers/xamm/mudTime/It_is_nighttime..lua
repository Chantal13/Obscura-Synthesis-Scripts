ttsQueue("Nighttime.")

-- set the flag to inform timer to start
mudTimeKnown = true

-- recalibrate timer for nighttime
disableTimer("mudtimer")
mudHour = 5
resetmudtime = true
enableTimer("mudtimer")
-- echo("\nmudMinutes = " .. mudMinutes .. "/10\n")
-- echo("mudHour = " .. mudHour .. "/5\n")

-- forcerun timer script at 00:00:00
if mudTimeKnown == true then

  if resetmudtime == true then
    mudMinutes = 0
    resetmudtime = false
  else
    mudMinutes = mudMinutes + 1
  end

  if mudMinutes > 9 then
    mudMinutes = 0
    mudHour = mudHour + 1
    if mudHour == 6 then
      mudHour = 0
    end
  end
--  send("time")
--  cecho("<white>-=## XAMM Timer ##=-\n")
--  cecho(" mudMinutes = <yellow>" .. mudMinutes .. "/10\n")
--  cecho(" mudHour    = <yellow>" .. mudHour .. "/5\n\n")
end