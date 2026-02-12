# Obscura Synthesis Scripts

Mudlet client scripts for **Obscura Synthesis**, a CoffeeMUD-based MUD at http://www.synthaetica.com:8080.

- **Client**: [Mudlet](https://www.mudlet.org/) (Lua-based MUD client)
- **Server**: [CoffeeMUD](https://www.coffeemud.org/) (Java-based MUD engine)
- **Build tool**: [Muddler](https://github.com/demonnic/muddler) (Mudlet package builder)
- **Package name**: `Obscura Toolkit`

## Features

### UI and Display

- **Stat gauges** for HP, Mana, Move, XP, Fatigue, Hunger, Thirst, Stinky, Items, Weight
- **Combat display** with enemy/tank portraits and HP gauges
- **Group panel** showing up to 5 party members with HP/MP/MV bars
- **Mud time tracking** with day/night cycle detection
- **Responsive layout** that adapts to any window size

### Auto-Mapper

GMCP-powered mapper with pathfinding, bookmarks, and speedwalking. Run `map help` for all commands.

- `map go <destination>` — walk to a room, area, or bookmark
- `map run <destination>` — run (faster) to a destination
- `map path <destination>` — show the path without walking
- `map add <name>` / `map rm <name>` / `map ls` — manage bookmarks
- `map save` / `map load` — manually save/load map data
- `map find <name>` — search for rooms by name

The mapper auto-discovers rooms as you explore. It hides during combat and reappears when combat ends.

### Combat

- **Auto-butchering** (`bb`) — batch butcher up to 3 bodies in sequence, stops when all are processed or none remain

### Crafting

- **Cooking** (`cc <ingredient>`) — puts ingredient in pot, cooks, retrieves food, repeats until out of ingredients or fire goes out
- **Mending** (`mend`) — removes all leather equipment, mends each piece via leatherwork, re-equips; skips non-leather items
- **Tanning** (`tt`) — drops bundle, tans hide, picks up leather, repeats until bundle is empty; requires a fire

### Druid

- **Chant Tracker** (`CHANT "<chant name>"`) — tracks the last chant cast for smart re-casting
- **Auto-recast** — recasts Harden Skin and Moonbeam when they wear off
- **Failure retry** — retries failed chants after 30 seconds, up to 3 attempts
- **Mana retry** — retries after 30 seconds if out of mana
- **Outdoors check** — suppresses repeated "must be outdoors" messages

### Quality of Life

- **Auto Pay Tax** — matches the tax collector's demand via regex, captures the amount, and automatically pays

## Installation

### From Mudlet Package Manager

Install and update via `mpkg`. See https://packages.mudlet.org/ for instructions.

### Building from Source

1. Install [Muddler](https://github.com/demonnic/muddler)
2. Run `muddle` from the `Obscura Toolkit/` directory
3. Import the generated `.mpackage` from `Obscura Toolkit/build/`

### Prompt Setup

Set your CoffeeMUD prompt for full gauge support:

```
[XAMM] items %c %C%B[XAMM] weight %w %W%B< %z | %r | %G | Status: %I >%B%/< Fighting %E< Tanking %KE%/%B[XAMM] prompt end
```

## How It Works

### State Machine Pattern

Each automation system follows a consistent cycle:

1. **Scripts** (`src/scripts/`) initialize global state variables on package load
2. **Aliases** (`src/aliases/`) parse user input, set state, and send the first command to the MUD
3. **Triggers** (`src/triggers/`) react to MUD output, update state, and send follow-up commands
4. The cycle continues until a termination condition is met

### Global State Variables

All state is stored in global Lua variables. Current globals:

| Variable | Type | Purpose |
|---|---|---|
| `lastChant` | string/nil | Most recent chant for re-casting |
| `chantRetries` | number | Consecutive failed chant attempts |
| `chantRetrying` | string/nil | Which chant is being retried |
| `butcherCount` | number | Current butcher count in a batch |
| `butcherMax` | number | Max bodies per batch (default 3) |
| `cookIngredient` | string/nil | Current ingredient being cooked |
| `cookingActive` | boolean | Whether the cooking loop is running |
| `cookingItem` | string/nil | Name of item currently being cooked |
| `fireFailed` | boolean | Whether the last fire-building attempt failed |
| `mendActive` | boolean | Whether the mend loop is running |
| `mendQueue` | table | List of items to mend |
| `mendIndex` | number | Current position in the mend queue |
| `tanningActive` | boolean | Whether the tanning loop is running |

### Timer Delays

When an action fails, `tempTimer()` schedules a retry:

- **Failed chant**: 30 seconds, up to 3 attempts
- **Out of mana**: 30 seconds (single attempt, clears `lastChant`)
- **Cooking next step**: 1-second delay between cycles
- **Mending next item**: 1-second delay between cycles

### User Feedback

All status messages use `cecho()` with colored tags:

```lua
cecho("\n<yellow>[System] <white>Message text\n")
cecho("\n<yellow>[System] <red>Error text\n")
```

Tags: `[Cook]`, `[Butcher]`, `[Chant]`, `[Mend]`, `[Tan]`, `[Tax]`

## Folder Structure

```
Obscura Synthesis Scripts/
├── README.md
├── LICENSE
└── Obscura Toolkit/           # Muddler project (canonical source)
    ├── mfile                  # Package metadata
    ├── README.md              # Toolkit-specific docs (mapper, UI)
    └── src/
        ├── aliases/
        │   └── xamm/
        │       ├── combat/    # bb (butcher)
        │       ├── crafting/  # cc (cooking), mend, tt (tanning)
        │       ├── druid/     # CHANT tracker
        │       └── cofudlet_mapper/
        ├── triggers/
        │   └── xamm/
        │       ├── Butchering/
        │       ├── Cooking/
        │       ├── Combat/
        │       ├── Data Collectors/
        │       ├── Group Party Detection/
        │       ├── mudTime/
        │       ├── Triggers for status flags/
        │       └── User Interface/
        ├── scripts/
        │   └── xamm/
        │       ├── cofudlet_mapper/
        │       ├── coffeemud/
        │       └── gmcp/
        ├── timers/
        └── resources/
```

## Common Pitfalls

- **Trigger name mismatch**: the `name` in `triggers.json` must exactly match the `.lua` filename. A mismatch silently fails.
- **Regex escaping**: in `triggers.json`, backslashes must be double-escaped (`\\s`, `\\.`) since it's JSON.
- **Global variable collisions**: all state is global. Use descriptive prefixes per system (`cook*`, `butcher*`, `chant*`, `mend*`, `tan*`).
- **Timer stacking**: if a player triggers the same action rapidly, `tempTimer` callbacks can stack. Guard with a boolean flag.
- **`matches` indexing**: `matches[1]` is the full match; captures start at `matches[2]`.
- **Fire dependency**: cooking and tanning both require an active fire. The fire-went-out trigger pauses both systems.

## Acknowledgments

Built on [XAMM](https://forums.mudlet.org/viewtopic.php?p=46823#p46823) (Xanthia's Advanced MUD Module) by Xanthia and the [cofudlet](http://coffeemud.net:8080/wiki/index.php?title=Cofudlet(Client_Addon)) mapper by cizra.
