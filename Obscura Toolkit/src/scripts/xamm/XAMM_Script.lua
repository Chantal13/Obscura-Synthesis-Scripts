-- Xanthia's Advanced MUD Module
-- Aug 2019 - 2022
local version = "1.0.0"

		-- implement help and command line options
		-- test audio listing

--this will resize your main Mudlet window, required size
setMainWindowSize(1280, 750)

		
xamm = xamm or {}

xamm.group = xamm.group or {}

xamm.group.name = {}
xamm.group.name[1] = ""
xamm.group.name[2] = ""
xamm.group.name[3] = ""
xamm.group.name[4] = ""
xamm.group.name[5] = ""

xamm.group.hp = {}
xamm.group.hp[1] = 0
xamm.group.hp[2] = 0
xamm.group.hp[3] = 0
xamm.group.hp[4] = 0
xamm.group.hp[5] = 0

xamm.group.maxhp = {}
xamm.group.maxhp[1] = 1
xamm.group.maxhp[2] = 1
xamm.group.maxhp[3] = 1
xamm.group.maxhp[4] = 1
xamm.group.maxhp[5] = 1

xamm.group.mp = {}
xamm.group.mp[1] = 0
xamm.group.mp[2] = 0
xamm.group.mp[3] = 0
xamm.group.mp[4] = 0
xamm.group.mp[5] = 0

xamm.group.maxmp = {}
xamm.group.maxmp[1] = 1
xamm.group.maxmp[2] = 1
xamm.group.maxmp[3] = 1
xamm.group.maxmp[4] = 1
xamm.group.maxmp[5] = 1

xamm.group.mv = {}
xamm.group.mv[1] = 0
xamm.group.mv[2] = 0
xamm.group.mv[3] = 0
xamm.group.mv[4] = 0
xamm.group.mv[5] = 0

xamm.group.maxmv = {}
xamm.group.maxmv[1] = 1
xamm.group.maxmv[2] = 1
xamm.group.maxmv[3] = 1
xamm.group.maxmv[4] = 1
xamm.group.maxmv[5] = 1

xamm.help = {[[
    <cyan>Xanthia's Advanced MUD Module<reset>

    This script allows for easy management of audio assets for background and
    sound effects. It is based on a proposed General BGM/SFX standard, like the 
    General MIDI standard, in hopes of simplifying the process of adding an
    immersive audio dimension to typically silent text games.

    Below is an overview of the included commands and important events that this
    script uses to work. Additional information on each command or event is
    available in individual help files.

    <cyan>Common Commands:<reset>
        These are commonly used commands 

        <link: 1>xamm help <optional command name></link> - Shows either this help file or the
            help file for the command given
        <link: list>xamm <on or off></link> - Activates or deactivates the audio manager
        <link: list>xamm mixer</link> - Displays the volume levels of each sound bank
        <link: list>xamm list</link> - Displays a list of assignable audio assets

    <cyan>Playback Commands:<reset>
        These are commands used for working with installed audio assets

        <link: stop>xamm stop</link> - Stops all audio playback

    <cyan>Key Variables:<reset>
        These variables are used by the script to keep track of important
            information

        <yellow>xamm.settings<reset> - Contains a number of different options that can be set
            to modify script behavior
        <yellow>xamm.volume<reset> - Contains the volume levels for the sound banks
        <yellow>xamm.playing.bgm_number<reset> - Set to the current playing BGM number
        <yellow>xamm.playing.bgm_name<reset> - Set to the current playing BGM name 
        <yellow>xamm.playing.sfx_number<reset> - Set to the current playing SFX number 
        <yellow>xamm.playing.sfx_name<reset> - Set to the current playing SFX name
]]}

xamm.help.list = [[
    <cyan>XAMM List<reset>
        syntax: <yellow>xamm list<reset>

        This command prints a list of BGM and SFX assets on screen, along with
        a General BGM/SFX Standard (proposed) description of what that asset is
        best used for.
]]
xamm.help.stop = [[
    <cyan>XAMM Stop<reset>
        syntax: <yellow>xamm stop<reset>

        This command stops all audio playback.
]]

xamm.settings = xamm.settings or {}
-- set xamm default volumes
xamm.volume = xamm.volume or {}
xamm.volume.a = xamm.volume.a or 80
xamm.volume.b = xamm.volume.b or 40
xamm.volume.c = xamm.volume.c or 50
xamm.playing = xamm.playing or {}
xamm.playing.bgm_number = xamm.playing.bgm_number or 0
xamm.playing.bgm_name = xamm.playing.bgm_name or ""
xamm.playing.sfx_number = xamm.playing.sfx_number or 0
xamm.playing.sfx_name = xamm.playing.sfx_name or ""

local oldstring = string
local string = utf8
string.format = oldstring.format
string.trim = oldstring.trim
string.starts = oldstring.starts
string.split = oldstring.split
string.ends = oldstring.ends

local profilePath = getMudletHomeDir()
profilePath = profilePath:gsub("\\","/")

xamm.defaults = {
    debug = false,
    download_path = "https://raw.githubusercontent.com/xanthiacoder/xamm/master",
}

-- checks for default XAMM folders, if not create them
fileInfo = lfs.attributes(getMudletHomeDir().."/xamm/audio/interface")
if fileInfo then
    if fileInfo.mode == "directory" then
        -- echo("Path points to a directory.")
    elseif fileInfo.mode == "file" then
        -- echo("Path points to a file.")
    else
        -- echo("Path points to: "..fileInfo.mode)
    end
    -- display(fileInfo) -- to see the detailed information
else
    -- echo("The path is invalid (file/directory doesn't exist) ... creating...\n")
    lfs.mkdir (getMudletHomeDir().."/xamm")
    lfs.mkdir (getMudletHomeDir().."/xamm/audio")
    -- MSP is storing sounds in the "/media" directory
    lfs.mkdir (getMudletHomeDir().."/xamm/audio/interface") -- for XAMM UI sounds
    lfs.mkdir (getMudletHomeDir().."/xamm/audio/custom") -- for user's custom sounds
    lfs.mkdir (getMudletHomeDir().."/xamm/audio/cache") -- for XAMM sounds cache
end
fileInfo = lfs.attributes(getMudletHomeDir().."/xamm/images/mxp")
if fileInfo then
    if fileInfo.mode == "directory" then
        -- echo("Path points to a directory.")
    elseif fileInfo.mode == "file" then
        -- echo("Path points to a file.")
    else
        -- echo("Path points to: "..fileInfo.mode)
    end
    -- display(fileInfo) -- to see the detailed information
else
    -- echo("The path is invalid (file/directory doesn't exist) ... creating...\n")
    lfs.mkdir (getMudletHomeDir().."/xamm/images")
    lfs.mkdir (getMudletHomeDir().."/xamm/images/mxp") -- coffeemud's MXP images
    lfs.mkdir (getMudletHomeDir().."/xamm/images/interface") -- for XAMM UI images
    lfs.mkdir (getMudletHomeDir().."/xamm/images/custom") -- for user's custom images
    lfs.mkdir (getMudletHomeDir().."/xamm/images/cache") -- for XAMM's images cache
end


function xamm.show_help(cmd)
    if cmd and cmd ~= "" then
        if cmd:starts("xamm ") then cmd = cmd:sub(6) end
        cmd = cmd:lower():gsub(" ","_")
        if not xamm.help[cmd] then
            cecho("No help file on that command.\n")
        end
    else
        cmd = 1
    end

    for w in xamm.help[cmd]:gmatch("[^\n]*\n") do
        local target = w:match("<link: ([^>]+)>")
        if target then
            local before, link, after = w:match("(.*)<link: [^>]+>(.*)</link>(.*)")
            cecho(before)
            link = "<yellow>"..link.."<reset>"
            if target ~= "1" then
                cechoLink(link,[[xamm.show_help("]]..target..[[")]],"View: xamm help " .. target,true)
            else
                cechoLink(link,[[xamm.show_help()]],"View: xamm help",true)
            end
            cecho(after)
        else
            cecho(w)
        end
    end
    echo("\n")
end

function xamm.eventHandler(event,...)
    if event == "sysDownloadDone" then
        local file = arg[1]
        if string.ends(file,"/xamm_logosound.mp3") then
            playSoundFile(file, 100)
						cecho("\n")
						-- https://unicode-table.com/en/blocks/box-drawing/
						-- https://unicode-table.com/en/blocks/block-elements/
						cecho("<red>  ▓     ▓     ▓       ▓▓ ▓▓     ▓▓ ▓▓    \n")
						cecho("<orange>    ▓ ▓      ▓ ▓      ▓ ▓ ▓     ▓ ▓ ▓    \n")
						cecho("<yellow>     ▓      ▓   ▓    ▓  ▓  ▓   ▓  ▓  ▓   \n")
						cecho("<green>    ▓ ▓    ▓  ▓  ▓   ▓     ▓   ▓     ▓   \n")
						cecho("<blue>  ▓     ▓ ▓       ▓ ▓       ▓ ▓       ▓  \n")
						cecho("\n")
            cecho("  Xanthia's Advanced MUD Module loaded\n")
						cecho("\n")
        elseif string.ends(file,"/someotherfiledownloaded.txt") then
            cecho("Some other file downloaded.\n")
        end
    elseif event == "sysConnectionEvent" or event == "sysInstall" then
        cecho("Doing some other stuff.\n")
    end
end

registerAnonymousEventHandler("sysDownloadDone","xamm.eventHandler")

-- Play XAMM logo sound on launch
fileInfo = lfs.attributes(getMudletHomeDir().."/xamm/audio/interface/xamm_logosound.mp3")
if fileInfo then
	playSoundFile(getMudletHomeDir().."/xamm/audio/interface/xamm_logosound.mp3", 100)
	cecho("\n")
	-- https://unicode-table.com/en/blocks/box-drawing/
	-- https://unicode-table.com/en/blocks/block-elements/
	cecho("<red>  ▓     ▓     ▓       ▓▓ ▓▓     ▓▓ ▓▓    \n")
	cecho("<orange>    ▓ ▓      ▓ ▓      ▓ ▓ ▓     ▓ ▓ ▓    \n")
	cecho("<yellow>     ▓      ▓   ▓    ▓  ▓  ▓   ▓  ▓  ▓   \n")
	cecho("<green>    ▓ ▓    ▓  ▓  ▓   ▓     ▓   ▓     ▓   \n")
	cecho("<blue>  ▓     ▓ ▓       ▓ ▓       ▓ ▓       ▓  \n")
	cecho("\n")
  cecho("  Xanthia's Advanced MUD Module loaded\n")
	cecho("\n")
else
	downloadFile(getMudletHomeDir().."/xamm/audio/interface/xamm_logosound.mp3","https://github.com/xanthiacoder/xamm/raw/master/audio/xamm_logosound.mp3")
end


-- use this function to check if asset exists locally, if not download it
function xamm_preload_asset(localdir, filename, url)
  fileInfo = lfs.attributes(getMudletHomeDir()..localdir..filename)
  if fileInfo then
    -- file exists, continue with using asset
  else
  	downloadFile(getMudletHomeDir()..localdir..filename,url)
  end
end
