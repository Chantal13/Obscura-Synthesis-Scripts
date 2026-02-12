function initOnConnect()

cecho("<purple>[ XAMM ]  - <cyan>Running Initialization on MUD connection\n")

-- default window setup
disableScrollBar()

-- resize the main text console area to have space at the bottom for UI
setBorderBottom(150)

-- start/stop Mudlet features
disableTimer("mudtimer") -- do not let timer run until time can be estimated

  -- initialise global variables
  gameStarted = false
  mudHour = 0
  mudMinutes = 0
  mudTimeKnown = false -- time is unknown until trigger fires on sunrise/sunset
  charTNLKnown = false -- XP to next level not known at session start
  charLeveledUp = false -- flag when char levels up
  mudTextRedirect = "" -- no redirecting
  emptyLine = 0 -- for emptyLine detection
  xammPrompt = false -- to indicate when [XAMM] prompt is detected 
  stillFighting = false -- for combat detection
  currentGauge = "combatFighting" -- setting to avoid lua error for ""
  collectData = false -- prevent Data Collectors from grabbing data unwittingly

  -- init cofudlet mapper
  cofudlet = cofudlet or {}
  cofudlet.map = cofudlet.map or {}
  mudlet.mapper_script = true
  uninstallPackage("generic_mapper")
  local loadedok = loadMap(getMudletHomeDir().."/xamm-mapdata.dat")
  if not loadedok then
    cecho("<purple>[ XAMM ]  - <red>Couldn't load map data :(\n")
  else
    cecho("<purple>[ XAMM ]  - <green>Loaded map data!\n")
    setMapZoom(7)
  end

-- initialise global gauge values
gaugeFontSize = 12 

charHPbar = Geyser.Gauge:new({
  name="charHPbar",
  x="65%", y=660,
  width="35%", height=16,
})
charHPbar:setFontSize(gaugeFontSize)
charHPbar:setAlignment("left")
-- charHPbar:hide()

-- styling charHPbar : using https://www.w3schools.com/colors/colors_picker.asp for color reference
charHPbar.front:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #f04141, stop: 0.1 #ef2929, stop: 0.49 #cc0000, stop: 0.5 #a40000, stop: 1 #cc0000);
    border-top: 1px black solid;
    border-left: 1px black solid;
    border-bottom: 1px black solid;
    font: "courier";
    border-radius: 7;
    padding: 3px;]])
charHPbar.back:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #8d2525, stop: 0.1 #831616, stop: 0.49 #4d0000, stop: 0.5 #330000, stop: 1 #4d0000);
    border-width: 1px;
    border-color: black;
    border-style: solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])

charMPbar = Geyser.Gauge:new({
  name="charMPbar",
  x="65%", y=680,
  width="35%", height=16,
})
charMPbar:setFontSize(gaugeFontSize)
charMPbar:setAlignment("left")
-- charMPbar:hide()

-- styling charMPbar
charMPbar.front:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #3377ff, stop: 0.1 #1a66ff, stop: 0.49 #0055ff, stop: 0.5 #003cb3, stop: 1 #0055ff);
    border-top: 1px black solid;
    border-left: 1px black solid;
    border-bottom: 1px black solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;
]])
charMPbar.back:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #003cb3, stop: 0.1 #003399, stop: 0.49 #002b80, stop: 0.5 #001133, stop: 1 #002b80);
    border-width: 1px;
    border-color: black;
    border-style: solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;
]])


charMVbar = Geyser.Gauge:new({
  name="charMVbar",
  x="65%", y=700,
  width="35%", height=16,
})
charMVbar:setFontSize(gaugeFontSize)
charMVbar:setAlignment("left")
-- charMVbar:hide()

-- styling charMVbar
charMVbar.front:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #98f041, stop: 0.1 #8cf029, stop: 0.49 #66cc00, stop: 0.5 #52a300, stop: 1 #66cc00);
    border-top: 1px black solid;
    border-left: 1px black solid;
    border-bottom: 1px black solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;
]])
charMVbar.back:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #598d25, stop: 0.1 #4d8316, stop: 0.49 #264d00, stop: 0.5 #1a3300, stop: 1 #264d00);
    border-width: 1px;
    border-color: black;
    border-style: solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;
]])

charFatiguebar = Geyser.Gauge:new({
  name="charFatiguebar",
  x="65%", y=640,
  width="11.7%", height=16,
})
charFatiguebar:setFontSize(gaugeFontSize)
charFatiguebar:setAlignment("left")
-- charFatiguebar:hide()

-- styling charFatiguebar
charFatiguebar.front:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #cc6699, stop: 0.1 #c6538c, stop: 0.49 #bf4080, stop: 0.5 #862d59, stop: 1 #bf4080);
    border-top: 1px black solid;
    border-left: 1px black solid;
    border-bottom: 1px black solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])
charFatiguebar.back:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #862d59, stop: 0.1 #73264d, stop: 0.49 #602040, stop: 0.5 #260d1a, stop: 1 #602040);
    border-width: 1px;
    border-color: black;
    border-style: solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])

charStinkybar = Geyser.Gauge:new({
  name="charStinkybar",
  x="65%", y=620,
  width="11.7%", height=16,
})
charStinkybar:setFontSize(gaugeFontSize)
charStinkybar:setAlignment("left")
-- charStinkybar:hide()

-- styling charStinkybar
charStinkybar.front:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #ff9933, stop: 0.1 #ff8c1a, stop: 0.49 #ff8000, stop: 0.5 #cc6600, stop: 1 #ff8000);
    border-top: 1px black solid;
    border-left: 1px black solid;
    border-bottom: 1px black solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])
charStinkybar.back:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #b35900, stop: 0.1 #994d00, stop: 0.49 #804000, stop: 0.5 #331a00, stop: 1 #804000);
    border-width: 1px;
    border-color: black;
    border-style: solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])

charHungerbar = Geyser.Gauge:new({
  name="charHungerbar",
  x="76.7%", y=620,
  width="11.7%", height=16,
})
charHungerbar:setFontSize(gaugeFontSize)
charHungerbar:setAlignment("left")
-- charHungerbar:hide()

-- styling charHungerbar
charHungerbar.front:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #cc6699, stop: 0.1 #c6538c, stop: 0.49 #bf4080, stop: 0.5 #862d59, stop: 1 #bf4080);
    border-top: 1px black solid;
    border-left: 1px black solid;
    border-bottom: 1px black solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])
charHungerbar.back:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #862d59, stop: 0.1 #73264d, stop: 0.49 #602040, stop: 0.5 #260d1a, stop: 1 #602040);
    border-width: 1px;
    border-color: black;
    border-style: solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])

charThirstbar = Geyser.Gauge:new({
  name="charThirstbar",
  x="76.7%", y=640,
  width="11.7%", height=16,
})
charThirstbar:setFontSize(gaugeFontSize)
charThirstbar:setAlignment("left")
-- charThirstbar:hide()

-- styling charThirstbar
charThirstbar.front:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #cc6699, stop: 0.1 #c6538c, stop: 0.49 #bf4080, stop: 0.5 #862d59, stop: 1 #bf4080);
    border-top: 1px black solid;
    border-left: 1px black solid;
    border-bottom: 1px black solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])
charThirstbar.back:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #862d59, stop: 0.1 #73264d, stop: 0.49 #602040, stop: 0.5 #260d1a, stop: 1 #602040);
    border-width: 1px;
    border-color: black;
    border-style: solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])

charItemsbar = Geyser.Gauge:new({
  name="charItemsbar",
  x="88.3%", y=620,
  width="11.7%", height=16,
})
charItemsbar:setFontSize(gaugeFontSize)
charItemsbar:setAlignment("left")
-- charItemsbar:hide()

-- styling charItemsbar
charItemsbar.front:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #b3b3b3, stop: 0.1 #a6a6a6, stop: 0.49 #999999, stop: 0.5 #737373, stop: 1 #999999);
    border-top: 1px black solid;
    border-left: 1px black solid;
    border-bottom: 1px black solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])
charItemsbar.back:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #737373, stop: 0.1 #666666, stop: 0.49 #595959, stop: 0.5 #333333, stop: 1 #595959);
    border-width: 1px;
    border-color: black;
    border-style: solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])

charWeightbar = Geyser.Gauge:new({
  name="charWeightbar",
  x="88.3%", y=640,
  width="11.7%", height=16,
})
charWeightbar:setFontSize(gaugeFontSize)
charWeightbar:setAlignment("left")
-- charWeightbar:hide()

-- styling charWeightbar
charWeightbar.front:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #b3b3b3, stop: 0.1 #a6a6a6, stop: 0.49 #999999, stop: 0.5 #737373, stop: 1 #999999);
    border-top: 1px black solid;
    border-left: 1px black solid;
    border-bottom: 1px black solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])
charWeightbar.back:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #737373, stop: 0.1 #666666, stop: 0.49 #595959, stop: 0.5 #333333, stop: 1 #595959);
    border-width: 1px;
    border-color: black;
    border-style: solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])



gameTimebar = Geyser.Gauge:new({
  name="gameTimebar",
  x="65%", y=2,
  width="35%", height=16,
})
gameTimebar:setFontSize(gaugeFontSize)
gameTimebar:setAlignment("left")
-- gameTimebar:hide()

-- styling gameTimebar
gameTimebar.front:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #ff9933, stop: 0.1 #ff8c1a, stop: 0.49 #ff8000, stop: 0.5 #cc6600, stop: 1 #ff8000);
    border-top: 1px black solid;
    border-left: 1px black solid;
    border-bottom: 1px black solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])
gameTimebar.back:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #b35900, stop: 0.1 #994d00, stop: 0.49 #804000, stop: 0.5 #331a00, stop: 1 #804000);
    border-width: 1px;
    border-color: black;
    border-style: solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])

charXPbar = Geyser.Gauge:new({
  name="charXPbar",
  x="65%", y=600,
  width="35%", height=16,
})
charXPbar:setFontSize(gaugeFontSize)
charXPbar:setAlignment("left")
-- charXPbar:hide()

-- styling charXPbar
charXPbar.front:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #999999, stop: 0.1 #8c8c8c, stop: 0.49 #808080, stop: 0.5 #595959, stop: 1 #808080);
    border-top: 1px black solid;
    border-left: 1px black solid;
    border-bottom: 1px black solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])
charXPbar.back:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #595959, stop: 0.1 #4d4d4d, stop: 0.49 #404040, stop: 0.5 #1a1a1a, stop: 1 #404040);
    border-width: 1px;
    border-color: black;
    border-style: solid;
    border-radius: 7;
    font: "courier";
    padding: 3px;]])


-- compute initial layout dimensions
local w, h = getMainWindowSize()
local rx = math.floor(w * 0.65)
local rw = w - rx
local combatW = math.floor(rw / 2) - 15
local memberSpacing = math.floor(rw / 5)

-- create consoles / labels [left side]  x, y, width, height
createMiniConsole("consoleExits", 0, 575, rx, 150)
setFontSize("consoleExits", 14)

-- create consoles / labels [right side]
createMiniConsole("consoleBattle", rx, 20, rw, 480)
setFontSize("consoleBattle", 14)
setBackgroundImage("consoleBattle", getMudletHomeDir().."/xamm/images/interface/zone_emerald_forest.jpg", "center")
createMiniConsole("consoleExplore", rx, 20, rw, 480)
setFontSize("consoleExplore", 14)
setBackgroundImage("consoleExplore", getMudletHomeDir().."/xamm/images/cache/zone_emerald_forest.jpg", "center")


-- create Labels for Combat [right side]
createGauge("combatFighting", combatW, 40, rx + 10, 25, "", "red", "horizontal") -- no text
hideGauge("combatFighting")
createLabel("combatFighting", rx + 10, 70, combatW, 420, 1)
hideWindow("combatFighting")
setBackgroundColor("combatFighting", 255, 204, 0, 255)
setBackgroundImage("combatFighting", getMudletHomeDir().."/xamm/images/cache/mob_a_nymph.jpg", "center")
createLabel("combatFightingName", rx + 15, 455, combatW - 10, 30, 1)
hideWindow("combatFightingName")
setBackgroundColor("combatFightingName", 0, 0, 0, 128) -- transparency 128
echo("combatFightingName", [[<p style="font-size:20px"><b><center><font color="white">a nymph</font></center></b></p>]])

createGauge("combatTanking", combatW, 40, rx + combatW + 20, 25, "", "red", "goofy") -- no text
hideGauge("combatTanking")
createLabel("combatTanking", rx + combatW + 20, 70, combatW, 420, 1)
hideWindow("combatTanking")
setBackgroundColor("combatTanking", 255, 204, 0, 255)
setBackgroundImage("combatTanking", getMudletHomeDir().."/xamm/images/cache/player_xanthia.jpg", "center")
createLabel("combatTankingName", rx + combatW + 25, 455, combatW - 10, 30, 1)
hideWindow("combatTankingName")
setBackgroundColor("combatTankingName", 0, 0, 0, 128) -- transparency 128
echo("combatTankingName", [[<p style="font-size:20px"><b><center><font color="white">Xanthia</font></center></b></p>]])


-- create Group consoles / labels [right side]
-- create main block, background first
createLabel("groupBackground", rx, 500, rw, 100, 1)
setBackgroundColor("groupBackground", 255, 204, 0, 255)
local pathtoimage = getMudletHomeDir().."/xamm/images/interface/xamm-partyBackground.jpg"
setBackgroundImage("groupBackground", pathtoimage)

for i = 0, 4 do
  local mx = rx + 8 + memberSpacing * i
  createLabel("groupMember" .. (i+1), mx, 528, 64, 64, 1)
  createLabel("groupMemberName" .. (i+1), mx, 508, 112, 16, 1)
  setBackgroundColor("groupMemberName" .. (i+1), 0, 0, 0, 200)
  createGauge("groupMember" .. (i+1) .. "HP", 14, 64, mx + 65, 528, "", "red", "vertical")
  createGauge("groupMember" .. (i+1) .. "MP", 14, 64, mx + 81, 528, "", "blue", "vertical")
  createGauge("groupMember" .. (i+1) .. "MV", 14, 64, mx + 97, 528, "", "DarkGreen", "vertical")
end


-- register resize handler and apply initial layout
if xammResizeHandler then killAnonymousEventHandler(xammResizeHandler) end
xammResizeHandler = registerAnonymousEventHandler("sysWindowResizeEvent", "xammLayout")
xammLayout()

cecho("<purple>[ XAMM ]  - <cyan>Ending Initialization on MUD connection\n")

end

-- Layout function for repositioning all widgets on window resize.
-- Bottom section (group + gauges) anchored to bottom, mapper fills remaining space.
function xammLayout()
  local w, h = getMainWindowSize()
  local rx = math.floor(w * 0.65)
  local rw = w - rx

  -- Bottom section layout (216px total, anchored to bottom of window):
  --   by+0:   group background (100px)
  --   by+100: XP bar (16px)
  --   by+120: stinky/hunger/items row (16px)
  --   by+140: fatigue/thirst/weight row (16px)
  --   by+160: HP bar (16px)
  --   by+180: MP bar (16px)
  --   by+200: MV bar (16px)
  --   by+216: bottom of window
  local bottomH = 216
  local by = h - bottomH
  local mapH = math.max(200, by - 24) -- mapper from y=20 to by-4

  -- Reposition Geyser gauges (vertical)
  gameTimebar:move("65%", 2)
  charXPbar:move("65%", by + 100)
  charStinkybar:move("65%", by + 120)
  charHungerbar:move("76.7%", by + 120)
  charItemsbar:move("88.3%", by + 120)
  charFatiguebar:move("65%", by + 140)
  charThirstbar:move("76.7%", by + 140)
  charWeightbar:move("88.3%", by + 140)
  charHPbar:move("65%", by + 160)
  charMPbar:move("65%", by + 180)
  charMVbar:move("65%", by + 200)

  -- Resize mapper to fill available space
  if cofudlet and cofudlet.ui and cofudlet.ui.mapper then
    cofudlet.ui.mapper:resize("35%", mapH)
  end

  -- Left panel: consoleExits anchored to bottom
  moveWindow("consoleExits", 0, h - 150)
  resizeWindow("consoleExits", rx, 150)

  -- Right panel consoles (same size as mapper)
  moveWindow("consoleBattle", rx, 20)
  resizeWindow("consoleBattle", rw, mapH)
  moveWindow("consoleExplore", rx, 20)
  resizeWindow("consoleExplore", rw, mapH)

  -- Combat panels (split right panel in half, same height as mapper area)
  local combatW = math.floor(rw / 2) - 15
  local combatH = mapH - 50
  moveGauge("combatFighting", rx + 10, 25)
  resizeGauge("combatFighting", combatW, 40)
  moveWindow("combatFighting", rx + 10, 70)
  resizeWindow("combatFighting", combatW, combatH)
  moveWindow("combatFightingName", rx + 15, 70 + combatH - 35)
  resizeWindow("combatFightingName", combatW - 10, 30)

  moveGauge("combatTanking", rx + combatW + 20, 25)
  resizeGauge("combatTanking", combatW, 40)
  moveWindow("combatTanking", rx + combatW + 20, 70)
  resizeWindow("combatTanking", combatW, combatH)
  moveWindow("combatTankingName", rx + combatW + 25, 70 + combatH - 35)
  resizeWindow("combatTankingName", combatW - 10, 30)

  -- Group section (anchored to bottom)
  moveWindow("groupBackground", rx, by)
  resizeWindow("groupBackground", rw, 100)
  local memberSpacing = math.floor(rw / 5)
  for i = 0, 4 do
    local mx = rx + 8 + memberSpacing * i
    moveWindow("groupMember" .. (i+1), mx, by + 28)
    moveWindow("groupMemberName" .. (i+1), mx, by + 8)
    moveGauge("groupMember" .. (i+1) .. "HP", mx + 65, by + 28)
    moveGauge("groupMember" .. (i+1) .. "MP", mx + 81, by + 28)
    moveGauge("groupMember" .. (i+1) .. "MV", mx + 97, by + 28)
  end

  raiseWindow("mapper")
end