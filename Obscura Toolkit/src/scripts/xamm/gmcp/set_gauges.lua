function set_gauges()

-- echo("incoming GMCP\n")
-- uncomment to see the data that is sent with the event handler
-- display(gmcp)

-- new session init char's TNL max
if charTNLKnown == false and gmcp.char.status.tnl ~= nil then -- XP to next level not known at session start
  sessionTNL = gmcp.char.status.tnl
  charTNLKnown = true
  cecho("<green>Setting this session's XP to Level...\n")
  
  -- lazy tagging along this condition to assume just connected to game
  -- using this for any recurring tips and alerts
  -- inform user how to start TimeBar manually
  if mudTimeKnown == false then
    local issue = "Time Bar has not started tracking time."
    local command = "time"
    local solution = "to start tracking mud time with the Time Bar."
    xamm_tip(issue, command, solution)
  end

end

if charLeveledUp == true and (sessionTNL < gmcp.char.status.tnl) then
  sessionTNL = gmcp.char.status.tnl
  charLeveledUp = false
  cecho("<green>Setting new XP to level requirement...\n")
end

  if gmcp.char.maxstats and gmcp.char.maxstats.maxhp ~= nil then
    -- HP / MP / MV bars
    charHPbar:setValue(gmcp.char.vitals.hp, gmcp.char.maxstats.maxhp, "&nbsp;&nbsp;&nbsp;Health&nbsp;&nbsp;:&nbsp;".. gmcp.char.vitals.hp .."/" .. gmcp.char.maxstats.maxhp)
    charMPbar:setValue(gmcp.char.vitals.mana, gmcp.char.maxstats.maxmana, "&nbsp;&nbsp;&nbsp;Mana&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;".. gmcp.char.vitals.mana .. "/" .. gmcp.char.maxstats.maxmana)
    charMVbar:setValue(gmcp.char.vitals.moves, gmcp.char.maxstats.maxmoves, "&nbsp;&nbsp;&nbsp;Move&nbsp;&nbsp;&nbsp;&nbsp;:&nbsp;".. gmcp.char.vitals.moves .. "/" .. gmcp.char.maxstats.maxmoves)
    -- Stinky Bar
    charMaxStinky = 100
    charStinkybar:setValue(gmcp.char.status.stink_pct, charMaxStinky, "&nbsp;&nbsp;&nbsp;Stinky&nbsp;&nbsp;&nbsp;:&nbsp;" .. math.floor((gmcp.char.status.stink_pct / charMaxStinky) * 100) .. "%")
    -- Fatigue Bar
    charMaxFatigue = 12120000
    charFatiguebar:setValue(gmcp.char.status.fatigue, charMaxFatigue, "&nbsp;&nbsp;&nbsp;Fatigue :&nbsp;" .. math.floor((gmcp.char.status.fatigue / charMaxFatigue) * 100) .. "%")
    -- Hunger Bar
    charHungerbar:setValue((500-gmcp.char.status.hunger), 500, "&nbsp;&nbsp;&nbsp;Hunger :&nbsp;" .. math.floor((1-(gmcp.char.status.hunger / 500)) * 100) .. "%")
    -- Thirst Bar
    charThirstbar:setValue((1000-gmcp.char.status.thirst), 1000, "&nbsp;&nbsp;&nbsp;Thirst :&nbsp;" .. math.floor((1-(gmcp.char.status.thirst / 1000)) * 100) .. "%")

    -- Day Time Bar
    if mudTimeKnown == true then
      gameTimebar:setValue((mudHour*10)+mudMinutes, 60, "&nbsp;&nbsp;&nbsp;Day Time Used : " .. math.floor(((((mudHour*10)+mudMinutes)/60) * 100)) .. "%")
    end

    -- XP Bar
    -- echo("tnl = " .. gmcp.char.status.tnl .."\nsessionTNL = " ..  sessionTNL .. "\n")
    charXPbar:setValue(((sessionTNL+1)-gmcp.char.status.tnl),sessionTNL, "&nbsp;&nbsp;&nbsp;XP to next level (this session) :&nbsp;"..math.floor(((sessionTNL-gmcp.char.status.tnl) / sessionTNL) * 100) .. "%")


    -- The following Bars need the [XAMM] Prompt in not it will cause errors

    -- Items Bar
    if charMaxCarry ~= nil then
      charItemsbar:setValue(charCarry, charMaxCarry, "&nbsp;&nbsp;&nbsp;Items&nbsp;&nbsp;:&nbsp;".. charCarry .. "/" .. charMaxCarry)
    end
    -- Weight Bar
    if charMaxWeight ~= nil then
      charWeightbar:setValue(charWeight, charMaxWeight, "&nbsp;&nbsp;&nbsp;Weight&nbsp;:&nbsp;".. charWeight .. "/" .. charMaxWeight)
    end
  end

end