-- total 8 matches including matches[1]

groupData = groupData or {}
groupData[groupNumber] = {
  race = string.trim(matches[2]);
  class = string.trim(matches[3]);
  level = string.trim(matches[4]);
  name = string.trim(matches[5]);
  hp = tonumber(matches[6]);
  mana = tonumber(matches[7]);
  moves = tonumber(matches[8])
}

--cecho("\nGroup Member "..groupNumber.." : ")
--cecho("<white:ansi_blue>"..groupData[groupNumber].race.." ")
--cecho("<black:white>"..groupData[groupNumber].class.." ")
--cecho("<white:ansi_blue>"..groupData[groupNumber].level.." ")
--cecho("<black:white>"..groupData[groupNumber].name.." ")
--cecho("<white:ansi_blue>"..groupData[groupNumber].hp.." ")
--cecho("<black:white>"..groupData[groupNumber].mana.." ")
--cecho("<white:ansi_blue>"..groupData[groupNumber].moves.."\n")

-- if capture is not player char, then fill in groupSlot
if groupData[groupNumber].name ~= charName then
  -- fill in the group slot and increment for next slot
  local slotname = "groupMemberName"..groupSlot -- should change 'party' to 'group' for consistency
  echo(slotname, [[<p style="font-size:10px"><b><center><font color="white">]]..groupData[groupNumber].name..[[</font></center></b></p>]])
  local slotname = "groupMember"..groupSlot -- should change 'party' to 'group' for consistency
  echo(slotname, [[<p style="font-size:10px"><b><center><font color="white">]]..groupData[groupNumber].class..[[</font></center></b></p>]])
  groupSlot = groupSlot + 1
end


-- increment groupNumber to capture the next one in the group
groupNumber = groupNumber + 1