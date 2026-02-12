-- end combat, do cleanup
stillFighting = false

-- hide combat stuff
hideWindow("combatFighting")
hideWindow("combatTanking")
hideWindow("combatFightingName")
hideWindow("combatTankingName")
hideGauge("combatFighting")
hideGauge("combatTanking")

-- show mapper window
if cofudlet and cofudlet.ui and cofudlet.ui.mapper then
  cofudlet.ui.mapper:show()
end