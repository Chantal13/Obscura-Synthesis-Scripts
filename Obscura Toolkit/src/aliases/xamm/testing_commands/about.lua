-- displays the coffeemud image in tabbed window

local imagepath = "[["..getMudletHomeDir().."/xamm/images/interface/placeholder-640x480.png]]"

echo("displaying " .. imagepath .. "\n")

xammmenu.Tab4center:setBackgroundImage(imagepath) -- update location to actual image location on your computer