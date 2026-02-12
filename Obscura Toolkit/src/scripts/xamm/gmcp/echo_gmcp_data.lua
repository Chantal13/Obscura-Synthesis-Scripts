function echo_gmcp_data()

echo("incoming GMCP\n")
-- uncomment to see the data that is sent with the event handler
-- display(gmcp)

echo("HP = " .. gmcp.char.vitals.hp .. " ")
echo("maxHP = " .. gmcp.char.maxstats.maxhp .. "\n")
echo("MN = " .. gmcp.char.vitals.mana .. " ")
echo("maxMN = " .. gmcp.char.maxstats.maxmana .. "\n")
echo("MV = " .. gmcp.char.vitals.moves .. " ")
echo("maxMV = " .. gmcp.char.maxstats.maxmoves .. "\n")

-- charHPbar:setValue(gmcp.char.vitals.hp, gmcp.char.maxstats.maxhp, math.floor((gmcp.char.vitals.hp / gmcp.char.maxhp) * 100) .. "%")
-- charHPbar:setValue(gmcp.char.vitals.mana, gmcp.char.maxstats.maxmana, math.floor((gmcp.char.vitals.mana / gmcp.char.maxmana) * 100) .. "%")
-- charHPbar:setValue(gmcp.char.vitals.moves, gmcp.char.maxstats.maxmoves, math.floor((gmcp.char.vitals.moves / gmcp.char.maxmoves) * 100) .. "%")

end