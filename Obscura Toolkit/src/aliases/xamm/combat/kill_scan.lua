-- this is to kill and gauge mob's overall health
-- based on NOBATTLESPAM condensed reporting with
-- HP loss of the targetted mob

-- targetmob.name should be set by kc (kill consider)
-- targetmob.name = matches[2]

ttsQueue("Engaging " .. targetmob.name)

send("kill " .. targetmob.name)