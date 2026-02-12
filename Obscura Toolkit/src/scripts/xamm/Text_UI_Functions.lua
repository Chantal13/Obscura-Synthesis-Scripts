-- https://unicode-table.com/en/blocks/box-drawing/
-- https://unicode-table.com/en/blocks/block-elements/
-- an alert window in the text main display
-- ╔ ═ ╗ ╚ ║ ╝ ╭ ─ ╮ ╰ ╯
function xamm_tip(issue, command, solution)
  cecho("<yellow:medium_blue>╔")
  for i = 2,75 do
    cecho("<yellow:medium_blue>═")
  end
  cecho("<yellow:medium_blue>╗\n")
  local issuelen = 64
  cecho("<yellow:medium_blue>║ <gray:medium_blue>Issue : <cyan:medium_blue>" .. string.format("%-"..issuelen.."s", string.sub(issue, 1, issuelen)) .. " <yellow:medium_blue>║\n")
  local solutionlen = 64 - 6 - string.len(command) - 1
  cecho("<yellow:medium_blue>║ <gray:medium_blue>Fix   : Enter <green:medium_blue>" .. command .. " <gray:medium_blue>" ..string.format("%-"..solutionlen.."s", string.sub(solution, 1, solutionlen)).." <yellow:medium_blue>║\n")
  cecho("<yellow:medium_blue>╚")
  for i = 2,75 do
    cecho("<yellow:medium_blue>═")
  end
  cecho("<yellow:medium_blue>╝\n\n")
end

function xamm_alert(issue, command, solution)
  cecho("<yellow:ansi_red>╔")
  for i = 2,75 do
    cecho("<yellow:ansi_red>═")
  end
  cecho("<yellow:ansi_red>╗\n")
  local issuelen = 64
  cecho("<yellow:ansi_red>║ <white:ansi_red>Issue : <cyan:ansi_red>" .. string.format("%-"..issuelen.."s", string.sub(issue, 1, issuelen)) .. " <yellow:ansi_red>║\n")
  local solutionlen = 64 - 6 - string.len(command) - 1
  cecho("<yellow:ansi_red>║ <white:ansi_red>Fix   : Enter <green:ansi_red>" .. command .. " <white:ansi_red>" ..string.format("%-"..solutionlen.."s", string.sub(solution, 1, solutionlen)).." <yellow:ansi_red>║\n")
  cecho("<yellow:ansi_red>╚")
  for i = 2,75 do
    cecho("<yellow:ansi_red>═")
  end
  cecho("<yellow:ansi_red>╝\n\n")
end