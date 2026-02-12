-- [XAMM] prompt detected
xammPrompt = true

-- gag line
-- deleteLine()

-- stop all redirects
mudTextRedirect = ""


-- checks if it's the first combat round
if stillFighting == false then
  -- this is the first combat round, do stuff
  -- hide mapper window
  if cofudlet and cofudlet.ui and cofudlet.ui.mapper then
    cofudlet.ui.mapper:hide()
  end
  -- show combat stuff
  showWindow("combatFighting")
  showWindow("combatTanking")
  showWindow("combatFightingName")
  showWindow("combatTankingName")
  showGauge("combatFighting")
  showGauge("combatTanking")
  stillFighting = true  
end


-- for debugging
-- echo("setting combatFighting gauge\n")

-- set the currentGauge
currentGauge = "combatFighting"