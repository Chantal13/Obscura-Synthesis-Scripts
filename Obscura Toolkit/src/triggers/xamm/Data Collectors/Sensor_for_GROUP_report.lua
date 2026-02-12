-- detects the start of a GROUP report

if charName ~= nil then -- ensure charName already detected
  if matches[2] == charName then -- match charName
    groupReport = true
    cecho("\n<yellow:ansi_blue>[XAMM] - Group report detected\n")
    groupNumber = 0 -- reset numbering of group members
    groupSlot = 1 -- reset slot number for group display
  else
    -- player probably used SWITCH to change char, need SCORE again
    local issue = "Different player character detected."
    local command = "score"
    local solution = "to load current character data into XAMM."
    echo("\n")
    xamm_alert(issue, command, solution)
    -- clear all data in the group windows / labels
    for i = 1,5 do
      local slotname = "groupMemberName"..i
      echo(slotname, [[<p style="font-size:10px"><b><center><font color="white">]]..""..[[</font></center></b></p>]])
      local slotname = "groupMember"..i
      echo(slotname, [[<p style="font-size:10px"><b><center><font color="white">]]..""..[[</font></center></b></p>]])
    end
  end
else
  -- inform player to load current session's char data
  local issue = "XAMM needs current session character data."
  local command = "score"
  local solution = "to load current character data into XAMM."
  echo("\n")
  xamm_alert(issue, command, solution)
end
