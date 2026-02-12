-- use with KILLSCAN to set the targetmob.name safely
-- with CONSIDER/LL and GCONSIDER

send("ll " .. matches[2])
send("gconsider " .. matches[2])

-- reset for KILLSCAN
targetmob.name = matches[2]
targetmob.health = 0

ttsQueue("Checking " .. matches[2])

cecho("The current targetted mob is : <white:blue>" .. targetmob.name .. "\n")
cecho("The estimated health reset to : <green>" .. targetmob.health .. "\n")
