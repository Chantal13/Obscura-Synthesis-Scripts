# Obscura Toolkit
## Mudlet client package for the Obscura Synthesis CoffeeMUD server

A feature-rich Mudlet package that combines XAMM's polished UI (gauges, combat display, group panel, mud time tracking) with cofudlet's robust auto-mapper (BFS/DFS pathfinding, collision avoidance, speedwalking, bookmarks).

### Features

- **Auto-mapper** powered by GMCP room events with pathfinding, bookmarks, and speedwalking
- **Stat gauges** for HP, Mana, Move, XP, Fatigue, Hunger, Thirst, Stinky, Items, Weight
- **Combat display** with enemy/tank portraits and HP gauges
- **Group panel** showing up to 5 party members with HP/MP/MV bars
- **Mud time tracking** with day/night cycle detection
- **Responsive layout** that adapts to any window size (right panel scales with window)

## Installation

To install and update Obscura Toolkit, use `mpkg`. See https://packages.mudlet.org/ for instructions.

### Prompt Setup

Set your CoffeeMUD prompt for full gauge support:

```
Change your prompt to: [XAMM] items %c %C%B[XAMM] weight %w %W%B< %z | %r | %G | Status: %I >%B%/< Fighting %E< Tanking %KE%/%B[XAMM] prompt end
```

## Usage

### Mapper

Run `map help` for all mapper commands. Key commands:

- `map go <destination>` - walk to a room, area, or bookmark
- `map run <destination>` - run (faster) to a destination
- `map path <destination>` - show the path without walking
- `map add <name>` / `map rm <name>` / `map ls` - manage bookmarks
- `map save` / `map load` - manually save/load map data
- `map find <name>` - search for rooms by name

The mapper auto-discovers rooms as you explore via GMCP room info events.

### Gauges

Gauges update automatically from GMCP data. Items and Weight bars require the XAMM prompt format above.

### Combat

Combat portraits and HP bars appear automatically when fighting. The mapper hides during combat and reappears when combat ends.

### Group

The group panel shows party members when you use the `group` command. Each member displays an avatar with HP, MP, and MV bars.

## Acknowledgments

Built on [XAMM](https://forums.mudlet.org/viewtopic.php?p=46823#p46823) (Xanthia's Advanced MUD Module) by Xanthia and the [cofudlet](http://coffeemud.net:8080/wiki/index.php?title=Cofudlet(Client_Addon)) mapper by cizra.

## Support

File issues at the project's GitHub repository.
