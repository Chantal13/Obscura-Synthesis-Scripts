-- ttsQueue("group text detected")

-- assign groupLine number
groupLine = groupLine + 1

-- gag line
deleteLine()

--echo("\ngrp line  = " .. groupLine .. "\n")
--echo("mob type  = " .. matches[2] .. "\n")
--echo("mob class = " .. matches[3] .. "\n")
--echo("mob level = " .. matches[4] .. "\n")
--echo("mob name  = " .. matches[5] .. "\n")
xamm.party.name[groupLine-1] = matches[5]

--echo("mob hp    = " .. matches[6] .. "\n")
--echo("mob maxhp = " .. matches[7] .. "\n")
--echo("mob mn    = " .. matches[8] .. "\n")
--echo("mob maxmn = " .. matches[9] .. "\n")
--echo("mob mv    = " .. matches[10] .. "\n")
--echo("mob maxmv = " .. matches[11] .. "\n")