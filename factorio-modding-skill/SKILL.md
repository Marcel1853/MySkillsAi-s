---
name: factorio-modding
description: >
  Create, modify, and debug Factorio 2.1 mods including Space Age DLC content.
  Use this skill whenever the user asks about Factorio modding, Lua scripting for Factorio,
  creating prototypes (entities, items, recipes, planets, space locations, asteroids, quality),
  working with the data lifecycle (settings → prototype → runtime stages), handling events,
  building GUIs, circuit network integration, train scheduling with interrupts and groups,
  Space Age features (space platforms, cargo pods, asteroid collection, planetary surfaces,
  thrusters), rendering/visualization, or anything related to the Factorio Lua API
  (https://lua-api.factorio.com/latest/). Also use when the user mentions "factorio mod",
  "data.lua", "control.lua", "prototype", "LuaEntity", "LuaPlayer", "LuaSurface", "LuaGameScript",
  "LuaBootstrap", "LuaTrain", "LuaSchedule", "defines.events", train stops, schedule interrupts,
  or Space Age modding topics like planets, space platforms, asteroid spawning, quality tiers,
  or surface properties.
---

# Factorio 2.1 + Space Age Modding Skill

Comprehensive skill for creating Factorio 2.1 mods including all Space Age DLC features.
Covers the complete Factorio Lua API through organized reference files and practical examples.

## ⚠️ Factorio Uses Modified Lua 5.2

Factorio does **not** use standard Lua. Key differences:

- **No `os` or `io` libraries** — Factorio sandboxes these for security
- **`__self` removed in 2.0** — Check `type(obj) == "userdata"` to identify Lua objects
- **`serpent` available** — Debug tables: `serpent.block(my_table)`
- **`table.deepcopy()` built-in** — Use instead of manual deep copy
- **`log()` writes to factorio-current.log** — Use for debugging, not `print()`
- **LuaObjects are userdata, not tables** — `pairs()` doesn't work on them directly
- **All globals are engine-provided** — `game`, `script`, `data`, `prototypes`, `defines`, `remote`, `commands`
- **`storage` table** — Persists mod data across saves (was `global` in 1.1)

## Mod File Structure

The **only** truly required file is `info.json`. All other files are optional lifecycle hooks — Factorio loads them automatically *if they exist*. For any non-trivial mod, you will want most of them, but a mod with just `info.json` is technically valid.

```
my-mod/
├── info.json                         ← ONLY truly required file
│
├── settings.lua                      ← Optional: runs in settings stage
├── settings-updates.lua              ← Optional: modify other mods' settings
├── settings-final-fixes.lua          ← Optional: final settings corrections
│
├── data.lua                          ← Optional: runs in prototype stage
├── data-updates.lua                  ← Optional: modify existing prototypes
├── data-final-fixes.lua              ← Optional: final prototype corrections
│
├── control.lua                       ← Optional: runtime scripting (events)
│
├── prototypes/                       ← Recommended: split prototype definitions
│   ├── items.lua                     ← All item prototypes
│   ├── recipes.lua                   ← All recipe prototypes (using categories array)
│   ├── entities.lua                  ← All entity prototypes
│   ├── technologies.lua              ← All technology prototypes
│   ├── fluids.lua                    ← All fluid prototypes
│   ├── equipment.lua                 ← All equipment prototypes
│   └── space-age/                    ← Space Age specific prototypes (if needed)
│       ├── planets.lua
│       ├── asteroids.lua
│       ├── quality.lua
│       └── space-entities.lua
│
├── locale/                           ← Recommended: translations
│   ├── en/
│   │   └── my-mod.cfg                ← English strings
│   └── de/
│       └── my-mod.cfg                ← German strings
│
├── migrations/                       ← Optional: version migration scripts
│   ├── 1.1.0.json                    ← Prototype renames/removals
│   └── 1.1.0.lua                     ← Data migration code
│
├── changelog.txt                     ← Recommended: version history for mod portal
├── thumbnail.png                     ← Recommended: 144x144 icon for mod portal
│
└── graphics/                         ← Optional: image assets
    ├── icons/
    ├── entity/
    └── technology/
```

> **When to create which files:**
> - **Nur `info.json`**: Minimaler Test-Mod, keine Funktionalität
> - **`data.lua` + `prototypes/`**: Füge Items, Entities, Recipes, Technologies hinzu
> - **`settings.lua`**: Mod-Konfiguration im Hauptmenü oder während des Spiels
> - **`control.lua`**: Event-Handling, GUI, Circuit Network, Train Schedules
> - **`locale/`**: Sobald du anzeigbare Strings hast (Items, Entities, GUI-Texte)
> - **`migrations/`**: Sobald du eine neue Version veröffentlichst, die bestehende Saves ändert

## How to Use This Skill

When the user asks about Factorio modding:

1. **Identify the API stage** they need (Settings, Prototype/Data, or Runtime/Control)
2. **Read the relevant reference file(s)** from `references/` for detailed API documentation (updated for 2.1)
3. **Use the example files** in `examples/` as starting points (updated for 2.1 categories and APIs)
4. **Follow the Data Lifecycle** — understand which file runs when (see `references/data-lifecycle.md`)

## Navigation

| Topic | Reference | Example |
|-------|-----------|---------|
| Data lifecycle: when each file runs, storage rules | `references/data-lifecycle.md` | `examples/basic-mod/` |
| Mod settings (bool, int, double, string) | `references/01-settings-stage.md` | `examples/basic-mod/settings.lua` |
| Entities, items, recipes, technologies, tiles | `references/02-prototype-stage.md` | `examples/basic-mod/prototypes/` |
| Space Age: planets, asteroids, quality, platforms | `references/03-space-age-prototypes.md` | `examples/space-age/custom-planet-example.lua` |
| Runtime: events, storage, LuaEntity, LuaPlayer | `references/04-runtime-api.md` | `examples/runtime-stage/event-tracking-mod.lua` |
| Custom GUIs & Inventories | `references/05-gui-api.md` | `examples/gui/custom-gui-example.lua` |
| Circuit networks & combinators | `references/06-circuit-network.md` | `examples/circuits/circuit-control-example.lua` |
| All Factorio events | `references/07-events.md` | — |
| Extended runtime classes (LuaForce, LuaTech, etc.) | `references/08-additional-runtime.md` | — |
| Enums and constants (defines.*) | `references/09-defines.md` | — |
| Trains: schedules, interrupts, groups, stops | `references/10-trains.md` | `examples/trains/train-dispatcher.lua` |
| Rendering & visualization | `references/rendering-api.md` | — |
| Graphics & AI Style Guide (Items, Entities, Techs) | `references/11-graphics-and-art.md` | — |
| AI Personas & Roles (Developer, Graphics, QA, etc.) | `references/12-ai-personas.md` | — |

## AI Personas & Roles

This skill defines specialized AI roles (personas) that can be activated to handle specific aspects of a Factorio modding project:

- **Factorio Core Developer** — Focuses on performant, desync-safe Lua scripting, event filtering, and strict lifecycle rules.
- **Industrial Dieselpunk Graphics Artist** — Focuses on authentic visual style, top-left lighting, sprite-sheet packing, and glow-masks.
- **QA Automation & Migration Specialist** — Focuses on error validation, edge cases, robust settings limits, and safe save migrations.
- **Sound & Atmosphere Designer** — Focuses on mechanical sounds, heavy auditory feedback, and planet-bound environmental loops.
- **Localization & Cultural Specialist** — Focuses on zero-hardcoding rules and perfect dual-language localization (EN/DE).

To activate a persona, explicitly prompt: *"Act as the [PERSONA_NAME]"*. For details, see `references/12-ai-personas.md`.

## The Three Stages

### 1. Settings Stage
- **Files:** `settings.lua` → `settings-updates.lua` → `settings-final-fixes.lua`
- **When:** Game startup, before any game exists
- **Available:** `data`, `mods`
- **Purpose:** Define mod configuration options

### 2. Prototype Stage
- **Files:** `data.lua` → `data-updates.lua` → `data-final-fixes.lua`
- **When:** After settings stage, still no game
- **Available:** `data`, `data.raw`, `mods`, `settings` (startup settings resolved)
- **Purpose:** Define all game objects
- **Best practice:** Use `require()` in `data.lua` to load from `prototypes/`

### 3. Runtime Stage
- **File:** `control.lua`
- **When:** During active gameplay
- **Available:** `script`, `game`, `storage`, `commands`, `remote`, `prototypes`
- **Purpose:** Handle events, GUI, circuit networks, train schedules

## Data Lifecycle — Save Startup Sequence

When a save is loaded, Factorio runs these 5 steps in order:

1. **`control.lua`** — Load mod's Lua state, register events. No `game` access yet.
2. **`on_init()`** — Only if mod is new to this save. Full `game` + `storage` access. Initialize `storage` here.
3. **Migrations** — Run `migrations/*.json` and `migrations/*.lua` files that haven't been applied.
4. **`on_load()`** — Only if mod already existed in save. **NO `game` access. `storage` is READ-ONLY.** Only for: re-setup metatables, conditional event handlers, local references.
5. **`on_configuration_changed()`** — If game/mod version changed, settings changed, prototypes changed, or migration applied. Full `game` + `storage` access.

**Critical `storage` rules:**
- `storage` replaces the old `global` table (renamed in 2.0)
- Only store serializable data — no Lua objects, no functions
- Use `entity.unit_number` for entity references, not the entity itself
- `on_load()` can READ `storage` but MUST NOT WRITE to it (causes error)
- `on_init()` is the correct place to INITIALIZE `storage`
- `storage` is NOT available during `control.lua` top-level execution

**Multiplayer joining:** Only steps 1 (`control.lua`) and 4 (`on_load()`) run.

Full details: `references/data-lifecycle.md`

## info.json Template (Factorio 2.1)

```json
{
  "name": "my-mod",
  "version": "1.1.0",
  "title": "My Mod Title",
  "author": "Your Name",
  "factorio_version": "2.1",
  "dependencies": [
    "base >= 2.1",
    "+ space-age"
  ],
  "description": "What this mod does."
}
```

> `+` prefix = optional recommended dependency (new in 2.1). Auto-enabled by default but can be disabled.
> `?` prefix = optional dependency. Without prefix = required.

## Locale Files — Recommended EN + DE

Factorio hat eine große deutschsprachige Spielerbasis. Stelle immer beide Sprachen bereit.

### locale/en/my-mod.cfg
```cfg
[item-name]
my-item=My Item

[item-description]
my-item=A useful item created by this mod.

[entity-name]
my-machine=My Machine

[recipe-name]
my-recipe=My Recipe

[technology-name]
my-tech=My Technology

[mod-name]
my-mod=My Mod Title

[mod-description]
my-mod=Description shown in mod portal.
```

### locale/de/my-mod.cfg
```cfg
[item-name]
my-item=Mein Item

[item-description]
my-item=Ein nützliches Item, das von diesem Mod erstellt wurde.

[entity-name]
my-machine=Meine Maschine

[recipe-name]
my-recipe=Mein Rezept

[technology-name]
my-tech=Meine Technologie

[mod-name]
my-mod=Mein Mod Titel

[mod-description]
my-mod=Beschreibung, die im Mod-Portal angezeigt wird.
```

## 2.1 Key Changes & Deprecations (Moving from 2.0)

| Change | Factorio 2.1 (Old) | Factorio 2.1 (New) |
|--------|---------------------|---------------------|
| Mod Dependency | `"dependencies": ["? space-age"]` | `"dependencies": ["+ space-age"]` (`+` is optional recommended, auto-enabled!) |
| Recipe Category | `RecipePrototype::category = "crafting"` | `RecipePrototype::categories = {"crafting"}` (`category` and `additional_categories` are removed) |
| Fluid Interaction | `entity.fluidbox[1] = ...` (LuaFluidBox) | Direct entity methods: `entity.add_fluid()`, `entity.get_fluid_filter()`, etc. (`fluidbox` read removed!) |
| Fluids Removal | `entity.remove_fluid()` | `entity.extract_fluid()` (old behavior renamed, new `remove_fluid` added with different parameters) |
| Entity Active State | `entity.active = false` (writable) | `entity.disabled_by_script = true` (`active` write removed) |
| Entity Minable State | `entity.minable = false` (writable) | `entity.minable_flag = false` (`minable` write removed) |
| Entity Neighbours | `entity.neighbors` (read property) | Specific properties: `fluidbox_neighbours`, `underground_belt_neighbour`, etc. |
| Crafter Inventories | `defines.inventory.crafter_input`, etc. | `defines.inventory.crafter_input`, `crafter_output`, `crafter_modules`, `crafter_trash` (unified) |
| Control Behavior | `defines.control_behavior.type.single_fluid_box` | `defines.control_behavior.type.single_fluid_box` (renamed) |
| Container GUI defines | `defines.relative_gui_type.boiler_gui` | Removed. Added `.boiler_gui`, `.radar_gui`, etc. |
| Display Panel | `get_message`/`set_message`/`messages` | Record-based: `add_record()`, `remove_record()`, `set_record()`, `records` |
| Logistic Container | `circuit_exclusive_mode_of_operation` | Removed. Use `set_requests` and `read_contents` together directly. |
| Molten metal recipes | `"molten-iron"`, `"molten-copper"` | Renamed to `"iron-ore-melting"`, `"copper-ore-melting"` |
| Inventory GUI element | None | Added `LuaGuiElement` type `"inventory"` and `on_gui_inventory_action` event |

## Quality System (Space Age)

Quality tier system applies to a limited, fixed set of properties on specific prototype types:

### Items
Quality affects: `stack_size` (lower quality = fewer per stack), `weight`, and the item's visual appearance. Items created through crafting can roll for quality based on the recipe's `allow_quality` flag and any quality modules used.

### Entities
Quality affects: `max_health` (higher quality = more health), `mining_time` (for mining drills), `crafting_speed` (for assemblers/furnaces), `pollution` values, and module slot count on some entities. Storage tank capacity also increases with quality (new in 2.1!).

### Equipment
Quality affects: `max_shield_value` (energy shields), `movement_bonus` (exoskeletons), `energy_production` (solar panels), and `power` (batteries).

### Built-in Quality Tiers

| Quality | Level | Order |
|---------|-------|-------|
| Normal | 0 | "a" |
| Uncommon | 1 | "b" |
| Rare | 2 | "c" |
| Epic | 3 | "d" |
| Legendary | 4 | "e" |

## Best Practices (Updated for 2.1)

1. **Use `categories` array on recipes** — `category` and `additional_categories` will crash on load.
2. **Use direct entity fluid methods** — never try to read or write to `entity.fluidbox`, as it has been completely removed.
3. **Use the `+` dependency modifier** for optional recommended mods like `+ space-age`.
4. **Use unified `crafter` inventories** — `defines.inventory.crafter_input` is gone, use `defines.inventory.crafter_input`.
5. **Use `entity.disabled_by_script`** to disable/enable entities instead of writing to `entity.active`.
6. **Use `entity.minable_flag`** to make entities indestructible/unminable by script instead of writing to `entity.minable`.
7. **Provide both `en/` and `de/` locale files** — Factorio has a large German playerbase.
8. **Check `mods` table** before accessing other mods: `if mods["space-age"] then ...`
9. **Use `data.raw[type][name]`** to modify existing prototypes.
10. **Use `storage` not `global`** — `global` was removed in Factorio 2.1.
11. **Never modify `storage` in `on_load()`** — it's read-only; only re-setup metatables/conditional handlers.
12. **Use `script.on_configuration_changed()`** for mod updates on existing saves.

## Key API Objects (Updated for 2.1)

| Object | Access | Description |
|--------|--------|-------------|
| `LuaEntity` | `surface.find_entity()` | Game entities (machines, belts, trains, direct fluid APIs) |
| `LuaPlayer` | `game.get_player(index)` | Connected players |
| `LuaSurface` | `game.surfaces[name]` | Worlds/planets/platforms |
| `LuaGameScript` | `game` | Global game state |
| `LuaBootstrap` | `script` | Events, storage, metatables |
| `LuaGuiElement` | `player.gui.*` | GUI components (including new `"inventory"` type) |
| `LuaInventory` | `entity.get_inventory()` | Item containers |
| `LuaItemStack` | `inventory[slot]` | Individual item stacks |
| `LuaTrain` | `locomotive.train` | Connected rolling stock |
| `LuaSchedule` | `train.get_schedule()` | Train/space platform schedules |
| `LuaSpacePlatform` | `game.get_space_platforms()` | Space platform management |
| `LuaForce` | `game.forces[name]` | Factions/teams |
| `LuaCircuitNetwork` | `entity.get_circuit_network()` | Circuit wire connections |

## Train System (2.1 — Schedule & Quality multipliers)

### Getting a Train's Schedule
```lua
local train = locomotive.train
local schedule = train.get_schedule()  -- Returns LuaSchedule object
```

### Setting a Schedule
```lua
local schedule = train.get_schedule()
schedule.set_records({
  {
    station = "Iron Mine",
    temporary = false,
    allows_unloading = false,
    wait_conditions = {
      { type = "full", compare_type = "and" },
    },
  },
  {
    station = "Smelter",
    temporary = false,
    allows_unloading = true,
    wait_conditions = {
      { type = "empty", compare_type = "and" },
    },
  },
})
```

### Quality Effects on Trains (2.1 additions)
- Locomotive power and max speed increase with quality.
- Cargo wagon inventory size increases with quality.
- Automatic trains waiting at a stop cannot depart if a robot is on the way to upgrade them.
- Spidertrons now support automatic patrol path loops!

## External Resources

- [Factorio Lua API Docs](https://lua-api.factorio.com/latest/) — Official reference
- [Factorio Modding Tutorial](https://wiki.factorio.com/Tutorial:Modding_tutorial/Gangsir) — Step-by-step guide
- [Scripting Tutorial](https://wiki.factorio.com/Tutorial:Scripting) — Runtime scripting
- [Localisation Guide](https://wiki.factorio.com/Tutorial:Localisation) — Translation system
- [Railway](https://wiki.factorio.com/Railway) — Train scheduling & signals
- [Mod Portal](https://mods.factorio.com/) — Share and browse mods
- [Factorio Forums](https://forums.factorio.com/viewforum.php?f=233) — Community help
