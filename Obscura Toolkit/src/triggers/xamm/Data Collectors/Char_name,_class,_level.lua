-- need to tighten this capture because it will trigger on any sentence
-- starting with YOU ARE including room descriptions
-- use SCORE command override to set collectData flag to read in data

if collectData then
  charName = matches[2]
  charClass = matches[3]
  charLevel = matches[4]

  cecho("\n<purple>[XAMM] - captured charName  : <white:ansi_blue>".. charName .."\n")
  cecho("<purple>[XAMM] - captured charClass : <yellow:ansi_blue>".. charClass .."\n")
  cecho("<purple>[XAMM] - captured charLevel : <yellow:ansi_blue>".. charLevel .."\n")
  
  -- turn off collectData so that this trigger will not load data unwittingly
  collectData = false
  echo("data collected - turning collectData off\n")
end