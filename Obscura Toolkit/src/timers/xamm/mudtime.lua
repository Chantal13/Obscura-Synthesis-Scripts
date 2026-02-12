-- do only after Sunrise/Sunset broadcasts

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
--  ttsQueue("Time check.")
--  send("time")
--  cecho("<white>-=## XAMM Timer ##=-\n")
--  cecho(" mudMinutes = <yellow>" .. mudMinutes .. "/10\n")
--  cecho(" mudHour    = <yellow>" .. mudHour .. "/5\n\n")
end