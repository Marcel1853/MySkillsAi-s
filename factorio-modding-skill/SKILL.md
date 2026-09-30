---
name: factorio-modding-skill
description: >
  Create, modify and debug Factorio 2.1 mods, including Space Age. Use for prototypes (entities,
  items, recipes, planets, asteroids, quality), the data lifecycle (settings → prototype →
  runtime), events, GUIs, circuit networks, trains and schedules, rendering, and anything on the
  Factorio Lua API. Also on "factorio mod", "data.lua", "control.lua", "LuaEntity", "LuaSurface",
  "defines.events".
---

# Factorio 2.1 + Space Age Modding Skill

Comprehensive skill for creating Factorio 2.1 mods including all Space Age DLC features.
Covers the complete Factorio Lua API through organized reference files and practical examples.

> **⚠️ VERSION WARNING — Factorio 2.1 is EXPERIMENTAL and changes weekly.**
> This skill's reference files are snapshots and may be outdated. **When in doubt about any method signature, property, or define, ALWAYS verify against the official live documentation:**
> - **Runtime API:** [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/)
> - **Prototype/Data-Stage:** [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/) (prototype definitions section)
> - **Version this skill was last updated against:** Factorio 2.1.11 experimental (stable: 2.0.x); corrections, `14-testing-and-publishing.md` and `15-pitfalls.md` verified against **2.1.20** (Sept. 2026)
>
> API features marked `2.1.x experimental` may not be available in the current stable release (2.0.x). Always check which version your users target.

## ⚠️ Factorio Uses Modified Lua 5.2

Factorio does **not** use standard Lua. Key differences:

- **No `os` or `io` libraries** — Factorio sandboxes these for security
- **`__self` removed in 2.0** — Check `type(obj) == "userdata"` to identify Lua objects
- **`serpent` available** — Debug tables: `serpent.block(my_table)`
- **`table.deepcopy()` only in the prototype stage** — at runtime use `require("util")` and `util.table.deepcopy()`
- **`require` only while control.lua is being parsed** — never inside functions/events at runtime
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
│   ├── items.lua
│   ├── recipes.lua
│   ├── entities.lua
│   ├── technologies.lua
│   ├── fluids.lua
│   ├── equipment.lua
│   └── space-age/                    ← Space Age specific (if needed)
│       ├── planets.lua
│       ├── asteroids.lua
│       ├── quality.lua
│       └── space-entities.lua
│
├── locale/                           ← Recommended: translations
│   ├── en/
│   │   └── my-mod.cfg
│   └── de/
│       └── my-mod.cfg
│
├── migrations/                       ← Optional: version migration scripts
│   ├── 1.1.0.json
│   └── 1.1.0.lua
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
   - **Read `references/15-pitfalls.md` first** — verified traps that cost hours otherwise
2. **Read the relevant reference file(s)** from `references/` for detailed API documentation
3. **Use the example files** in `examples/` as starting points
4. **Follow the Data Lifecycle** — understand which file runs when (see `references/data-lifecycle.md`)
5. **⚠️ Verify against live docs** — If any API seems uncertain, check [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/) before using
6. **Test headless** and lint before handing over (`scripts/headless-test.sh`, `scripts/lint.sh`); package with `scripts/package.sh`
   - Mods or scenarios that build rails: check the signals of a save with `scripts/signal-audit.sh`
     (chain signal in, rail signal out, blocks that hold the longest train; see `10-trains.md`)
7. **Starting a new mod project?** Put a `CLAUDE.md` with the project rules into the mod folder —
   take `scripts/templates/CLAUDE.md` as the base, then go through it **with the user** and adapt
   it: their language for the locale, their performance limits, their release process. Delete what
   does not apply. `scripts/generate_mod.py` already writes this file into a fresh skeleton.
   An existing project without a `CLAUDE.md` is worth one short offer, not a surprise file.

## Navigation

### 🏗️ Data Lifecycle & Settings
| Reference | Description |
|-----------|-------------|
| [data-lifecycle.md](references/data-lifecycle.md) | **Wann läuft welche Datei?** Settings → Prototype → Runtime Stage, `storage`-Regeln, `on_init`/`on_load`/`on_configuration_changed`-Sequenz, Multiplayer-Join-Verhalten |
| [01-settings-stage.md](references/01-settings-stage.md) | Mod-Konfiguration: `bool`, `int`, `double`, `string` Setting-Typen, `settings.lua`/`settings-updates.lua`/`settings-final-fixes.lua`, Default-Werte und Bereichsgrenzen |

### 🔧 Prototype Stage (data.lua)
| Reference | Description |
|-----------|-------------|
| [02-prototype-stage.md](references/02-prototype-stage.md) | Entities, Items, Recipes, Technologies, Tiles, Fluids, Equipment — alle Prototype-Typen mit Pflichtfeldern, `data.lua`/`data-updates.lua`/`data-final-fixes.lua` Patterns |
| [03-space-age-prototypes.md](references/03-space-age-prototypes.md) | **Space Age DLC:** Planeten, Space Locations, Asteroiden, Quality-Tiers, Space Platforms, Cargo Pods, Thruster, Oberflächen-Eigenschaften |

### ⚙️ Runtime Stage (control.lua)
| Reference | Description |
|-----------|-------------|
| [04-runtime-api.md](references/04-runtime-api.md) | **Kern-API:** `script`, `game`, `LuaEntity`, `LuaPlayer`, `LuaSurface`, `LuaItemStack`, `LuaInventory`, `LuaForce`, Fluid-API (2.1 Overhaul), `prototypes` Read-Only-Zugriff, 2.1 Breaking Changes |
| [07-events.md](references/07-events.md) | **Alle Factorio-Events:** `defines.events.*` vollständig katalogisiert — Build/Mine/Craft/Combat/Train/Platform/GUI-Events mit Event-Filter-Patterns |
| [08-additional-runtime.md](references/08-additional-runtime.md) | Erweiterte Runtime-Klassen: `LuaForce`, `LuaTechnology`, `LuaRecipe`, `LuaTrain`, `LuaSchedule`, `LuaSpacePlatform`, `LuaLogisticNetwork`, `LuaTransportLine` |
| [09-defines.md](references/09-defines.md) | Enums & Konstanten **aus der API erzeugt** (`scripts/gen_defines_reference.py`): `defines.events`, `defines.direction`, `defines.inventory`, `defines.train_state`, `defines.wire_connector_id`, `defines.space_platform_state` … plus Liste oft erfundener defines (z. B. gibt es kein `defines.comparator`) |

### 🖥️ GUI & Circuit Network
| Reference | Description |
|-----------|-------------|
| [05-gui-api.md](references/05-gui-api.md) | Custom GUIs: `LuaGuiElement`-Typen, `player.gui.screen`/`top`/`left`/`relative`, Event-Handler, Inventar-GUI-Elemente (2.1+), Choose-Elem-Button, Kamera folgt Objekt, **Erklärfenster für Szenarien** (Vorlage) |
| [06-circuit-network.md](references/06-circuit-network.md) | Schaltungsnetz: Red/Green Wire, `LuaCircuitNetwork`, Combinator-Verhalten (Decider/Arithmetic/Constant/Selector), Signal-Typen, Entity-Steuerung via Circuit |

### 🚂 Trains & Rendering
| Reference | Description |
|-----------|-------------|
| [10-trains.md](references/10-trains.md) | **Zug-System 2.1:** `LuaSchedule`-API, Schedule-Interrupts, Train-Groups, Wait-Conditions (`full`/`empty`/`time`/`inactivity`/`circuit`), `LuaTrain`, `LuaLocomotive`, **Signale/Blöcke/Zuglängen** (Kettensignal rein, normales raus, Block ≥ längster Zug, Segment-API) |
| [rendering-api.md](references/rendering-api.md) | Visualisierung: `rendering.draw_line/circle/text/sprite/animation`, persistente Render-Objekte, `time_to_live`, Draw-on-Ground, Farben und Scale |

### 🎨 Graphics & Locale
| Reference | Description |
|-----------|-------------|
| [11-graphics-and-art.md](references/11-graphics-and-art.md) | Grafik-Styleguide (nur Referenz, keine API): Sprite-Formate, Icon-Größen, Entity-Animationen, Technology-Icons, Factorio-Art-Style-Konventionen |
| [13-locale-reference.md](references/13-locale-reference.md) | Lokalisierung: `.cfg`-Format, EN + DE Templates, `LocalisedString`-Patterns, GUI-Texte, Item/Entity/Technology-Beschreibungen, Pluralformen |

### 🧪 Testing, Publishing & Pitfalls (from a real project, 2.1.19)
| Reference | Description |
|-----------|-------------|
| [14-testing-and-publishing.md](references/14-testing-and-publishing.md) | Headless-Tests mit eigenem Datenordner, UPS messen (`--benchmark-verbose all`), Lint wie VS Code (FMTK), Packen, Name/Changelog/Thumbnail-Regeln, Mod-Portal (Kategorie, Tags, API, Upload), GitHub-Workflow + Release, Screenshots mit Grafik (sicher!), Tipps & Tricks mit Szenen, Headless-Szenarien (server-settings, stdin), Fehlersuche im Log, Abhängigkeits-Präfixe, Portal-API (Beschreibung, Versionsliste hinkt), **Testläufe zählen und bündeln** (parallel, `test-all.sh`), Szenario ohne Spieler prüfen, fremde Schnittstelle nachbilden |
| [15-pitfalls.md](references/15-pitfalls.md) | **Geprüfte Stolperfallen:** storage/LuaObjects, `require`, Szenario-Reihenfolge, `-0`, GUI-Abstände, Schaltungs-Panel, Züge (temporäre Halte, Wegpunkte, Wartebedingungen), Greifarm-Richtung, Kabelreichweite, Pumpen/Tanks an Flüssigkeitswagen, Gleisgeometrie, `fuel_categories` statt `fuel_category`, `game.train_manager.get_trains`, **Gleise per `get_rail_extensions` anbauen**, Weg zwischen zwei Haltestellen (`starts`), `train_state` in 2.1 (kein `path_lost`), Abfahrt vs. `no_path`, Strommasten ohne Kupferkabel, **Space Exploration** (Aufzug, Schnittstelle, Headless-Grenzen) |

### 🤖 AI Personas
| Reference | Description |
|-----------|-------------|
| [⭐ 12-ai-personas.md](references/12-ai-personas.md) | **Core Developer Role:** API-Regeln, Prototype-Validierung, Data-Lifecycle-Constraints, häufige Fehlerquellen, Best Practices für KI-gestütztes Factorio-Modding — **Pflichtlektüre für AI-gestützte Mod-Entwicklung** |

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
- Allowed: nil, strings, numbers, booleans, tables and **references to LuaObjects** (check `.valid` before use)
- Not allowed: functions (error on save); unregistered metatables are dropped (use `script.register_metatable`)
- `on_load()` can READ `storage` but MUST NOT WRITE to it (causes error)
- `on_init()` is the correct place to INITIALIZE `storage`
- `storage` IS available during `control.lua` top-level execution (since 2.0), but `game` is NOT

**Multiplayer joining:** Only steps 1 (`control.lua`) and 4 (`on_load()`) run.

**Scenarios:** a scenario's `on_init` runs **before** the mods' `on_init` (and a mod's `storage` is set up in its own `on_init`) → set mods up from a scenario in the **first tick**, not in `on_init`. Details: `references/15-pitfalls.md`.

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

## Mod Name, Changelog & Portal (verified)

- Portal name: **more than 3 and fewer than 50 characters**, only alphanumerics, `-` and `_`. The internal name **cannot be changed after the first upload**.
- `changelog.txt`: strict format; use only the recognised categories (Major Features, Features, Minor Features, Graphics, Sounds, Optimizations, Balancing, Combat Balancing, Circuit Network, Changes, Bugfixes, Modding, Scripting, Gui, Control, Translation, Debug, Ease of use, Info, Locale, Compatibility).
- `thumbnail.png`: ideally 144 × 144 px.
- First release must be uploaded by hand; later versions can use the API (`init_upload`). See `references/14-testing-and-publishing.md` and `scripts/release.yml`.

## Locale Files — Recommended EN + DE

Factorio hat eine große deutschsprachige Spielerbasis. Stelle immer beide Sprachen bereit. Verwende niemals hartcodierte Strings im Code — immer Locale-Keys.

Full locale examples and LocalisedString patterns: `references/13-locale-reference.md`

## 2.1 Key Changes & Deprecations (Moving from 2.0 → 2.1)

> **Stand: Factorio 2.1.11 experimental** — Verify against [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/) before relying on any entry. Factorio 2.1 is experimental and changes weekly.

| Change | Factorio 2.0 (Old) | Factorio 2.1 (New) | Since Version |
|--------|---------------------|---------------------|---------------|
| Mod Dependency | `"dependencies": ["? space-age"]` | `"dependencies": ["+ space-age"]` (`+` is optional recommended, auto-enabled!) | 2.0 |
| Recipe Category | `RecipePrototype::category = "crafting"` | `RecipePrototype::categories = {"crafting"}` (`category` and `additional_categories` removed) | 2.0 |
| Fluid Interaction | `entity.fluidbox[1] = ...` (LuaFluidBox) | Direct entity methods: `entity.add_fluid()`, `entity.get_fluid()`, `entity.get_fluid_contents()`, `entity.get_fluid_filter()`; pipe connections via `entity.get_fluid_box_pipe_connections(index)` and `entity.get_fluid_box_neighbours(index)` (`fluidbox` removed entirely — even `fluidbox.get_pipe_connections()`) | 2.0 |
| Fluids Removal | `entity.remove_fluid()` | `entity.extract_fluid()` (old behavior renamed, new `remove_fluid` added with different parameters) | 2.0 |
| Entity Active State | `entity.active = false` (writable) | `entity.disabled_by_script = true` (`active` write removed) | 2.0 |
| Entity Minable State | `entity.minable = false` (writable) | `entity.minable_flag = false` (`minable` write removed) | 2.0 |
| Entity Neighbours | `entity.neighbors` (read property) | Specific properties: `fluidbox_neighbours`, `underground_belt_neighbour`, etc. | 2.0 |
| Crafter Inventories | Various `defines.inventory` values | `defines.inventory.crafter_input`, `crafter_output`, `crafter_modules`, `crafter_trash` (unified) | 2.0 |
| Display Panel | `get_message`/`set_message`/`messages` | Record-based: `add_record()`, `remove_record()`, `set_record()`, `records` | 2.0 |
| Logistic Container | `circuit_exclusive_mode_of_operation` | Removed. Use `set_requests` and `read_contents` together directly. | 2.0 |
| Molten metal recipes | `"molten-iron"`, `"molten-copper"` | Renamed to `"iron-ore-melting"`, `"copper-ore-melting"` | 2.0 |
| Inventory GUI element | None | Added `LuaGuiElement` type `"inventory"` and `on_gui_inventory_action` event | 2.1.0 |
| Programmable Speaker | — | Runtime `playback_mode` values are `"local"`, `"surface"`, `"global"` (checked 2.1.19; an older note claimed a rename to `Universe` – not in the API) | – |
| LuaPlayer Pins | `add_pin()` only | `add_pin()` now returns `LuaPin`; added `get_pins()`, `clear_pins()` | 2.1.10 |
| LuaPlayer Remote View | N/A | Added `toggle_menu_leaves_remote_view` (read-only in API 2.1.19 – player setting) | 2.1.9 |
| Entity Flip | N/A | Added `LuaEntity::flip` read | 2.1.0 |
| Entity Protection | N/A | Added `LuaEntity::protected` read/write | 2.1.0 |
| Entity Upgrades | Must mark for upgrade first | `apply_upgrade()` can now directly upgrade without marking | 2.1.10 |
| Entity Materials | N/A | Added `request_missing_construction_materials` read/write | 2.1.10 |
| Entity Platforms | N/A | Added `providing_to_other_platforms` read/write | 2.1.10 |
| Spidertron Patrol | N/A | Added `autopilot_patrol_size` read/write; patrol path support | 2.1.7 |
| Lab Circuit | N/A | Labs can be circuit-connected, read contents, read research cost, set research | 2.1.7 |
| Pipes Circuit | N/A | Pipes, storage tanks, boilers, heat exchangers can be circuit-connected | 2.1.7 |
| Selector Combinator | N/A | Added "Time" mode (game tick, time of day, day duration) | 2.1.7 |
| Storage Tank Quality | Fixed capacity | Fluid volume increases with quality | 2.1.7 |
| Cargo Wagon Quality | Fixed size | Inventory size increases with quality | 2.1.7 |
| Locomotive Quality | Fixed power | Power and max speed increase with quality | 2.1.7 |
| Choose-Elem Button | Limited types | Added `airborne-pollutant`, `ammo-category`, `quality`, `shortcut`, `space-connection`, `surface`, `virtual-signal` | 2.1.0 |
| Notification Queue | N/A | Added `LuaNotificationQueue`, `LuaBootstrap::new_notification_queue()` | 2.1.0 |
| Control Behavior | Single network view | `input_networks` and `output_networks` read/write on `LuaControlBehavior` | 2.1.0 |
| Force Visibility | N/A | `is_visible()`, `set_script_visible()`, `get_script_visible()` | 2.1.0 |
| Force Alerts | Limited | `add_alert()`, `add_custom_alert()`, `remove_alert()` | 2.1.0 |
| Force Space Travel | N/A | `unlock_logistic_network`, `unlock_travel_to_space_platforms` read/write | 2.1.0 |
| Entity Durability | N/A | `clear_stored_durability()`, `get_stored_durability()`, `set_stored_durability()` | 2.1.0 |
| Entity Tooltip Fields | N/A | `clear_tooltip_fields()`, `get_tooltip_fields()`, `set_tooltip_field()`, etc. | 2.1.0 |
| Fluid Segments | N/A | `has_fluid_segment()`, `get_fluid_segment_fluid()`, `set_fluid_segment_fluid()`, etc. | 2.1.0 |
| Player Factoriopedia | N/A | `hide_locked_prototypes_in_factoriopedia` read/write | 2.1.9 |
| Display Panel Text | `display_panel_text` accepts LocalisedString | `display_panel_text` now accepts **string only** (LocalisedString breaks); use `add_record()`/`set_record()` | 2.1 |
| Entity Mine | N/A | `entity.mine()` — script mine entity as if player mined it | 2.0 |
| Cargo Pod Creation | No entity spec | `entity.create_cargo_pod({...})` supports optional entity specification | 2.1 |
| Blueprint Library | N/A | `game.delete_blueprint_library()` | 2.1 |
| Flow Statistics | Basic counts | `get_current_input_sample()`, `set_current_input_sample()`, quality_counts, etc. | 2.1 |
| Prototype Removed | `fluid_usage_per_tick`, `max_power_output`, `pumping_speed`, `build_base_evolution_requirement` | Use `get_fluid_usage_per_tick()`, `get_max_power_output()`, `get_pumping_speed()` methods instead | 2.1 |

> **⚠️ IMPORTANT:** This table is a SNAPSHOT. Factorio 2.1 is experimental and receives weekly updates. Always verify the current API at [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/) before using any method or property listed here.

## Quality System (Space Age)

Quality tier system applies to a limited, fixed set of properties on specific prototype types:

### Items
Quality affects: `stack_size` (lower quality = fewer per stack), `weight`, and the item's visual appearance. Items created through crafting can roll for quality based on the recipe's `allow_quality` flag and any quality modules used.

### Entities
Quality affects: `max_health` (higher quality = more health), `mining_time` (for mining drills), `crafting_speed` (for assemblers/furnaces), `pollution` values, and module slot count on some entities. **Storage tank capacity increases with quality (2.1.7+).**

### Equipment
Quality affects: `max_shield_value` (energy shields), `movement_bonus` (exoskeletons), `energy_production` (solar panels), and `power` (batteries).

### Trains (2.1.7+)
- Locomotive power and max speed increase with quality.
- Cargo wagon inventory size increases with quality.

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
4. **Use unified `crafter` inventories** — `defines.inventory.crafter_input`, `crafter_output`, `crafter_modules`.
5. **Use `entity.disabled_by_script`** to disable/enable entities instead of writing to `entity.active`.
6. **Use `entity.minable_flag`** to make entities indestructible/unminable by script instead of writing to `entity.minable`.
7. **Provide both `en/` and `de/` locale files** — Factorio has a large German playerbase.
8. **Check `mods` table** before accessing other mods: `if mods["space-age"] then ...`
9. **Use `data.raw[type][name]`** to modify existing prototypes.
10. **Use `storage` not `global`** — `global` was removed in Factorio 2.0.
11. **Never modify `storage` in `on_load()`** — it's read-only; only re-setup metatables/conditional handlers.
12. **Use `script.on_configuration_changed()`** for mod updates on existing saves.
13. **Verify API against live docs** — When unsure about a method or signature, check [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/) rather than guessing from this skill's snapshot.
14. **Programmable Speaker `playback_mode`** is `"local"`, `"surface"` or `"global"` (API 2.1.19) – verify before relying on any rename.
15. **Use `LuaSchedule` API** — Don't assign `train.schedule = {}` directly; it overwrites interrupts.

## Key API Objects (Updated for 2.1.11)

> **Stand: Factorio 2.1.11 experimental.** Verify at [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/).

| Object | Access | Description | Version |
|--------|--------|-------------|---------|
| `LuaEntity` | `surface.find_entity()` | Game entities (machines, belts, trains, direct fluid APIs) | 2.0+ |
| `LuaPlayer` | `game.get_player(index)` | Connected players; pins, remote view toggle (2.1.9+) | 2.0+ |
| `LuaSurface` | `game.surfaces[name]` | Worlds/planets/platforms | 2.0+ |
| `LuaGameScript` | `game` | Global game state | 2.0+ |
| `LuaBootstrap` | `script` | Events, storage, metatables, notification queues (2.1+) | 2.0+ |
| `LuaGuiElement` | `player.gui.*` | GUI components (including `"inventory"` type since 2.1) | 2.0+ |
| `LuaInventory` | `entity.get_inventory()` | Item containers | 2.0+ |
| `LuaItemStack` | `inventory[slot]` | Individual item stacks | 2.0+ |
| `LuaTrain` | `locomotive.train` | Connected rolling stock | 2.0+ |
| `LuaSchedule` | `train.get_schedule()` | Train/space platform schedules | 2.0+ |
| `LuaSpacePlatform` | `game.get_space_platforms()` | Space platform management | 2.0+ |
| `LuaForce` | `game.forces[name]` | Factions/teams; visibility, alerts (2.1+) | 2.0+ |
| `LuaCircuitNetwork` | `entity.get_circuit_network()` | Circuit wire connections | 2.0+ |
| `LuaPin` | `player.add_pin()` return | Map pin object (2.1.10+) | 2.1.10+ |
| `LuaNotificationQueue` | `script.new_notification_queue()` | Custom notification system (2.1+) | 2.1+ |

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

### Quality Effects on Trains (2.1.7+)
- Locomotive power and max speed increase with quality.
- Cargo wagon inventory size increases with quality.
- Automatic trains waiting at a stop cannot depart if a robot is on the way to upgrade them.
- Spidertrons now support automatic patrol path loops! (`autopilot_patrol_size`)

## External Resources

- **[Factorio Lua API Docs](https://lua-api.factorio.com/latest/)** — ⚠️ ALWAYS verify against this when unsure. Authoritative reference.
- [Factorio Modding Tutorial](https://wiki.factorio.com/Tutorial:Modding_tutorial/Gangsir) — Step-by-step guide
- [Scripting Tutorial](https://wiki.factorio.com/Tutorial:Scripting) — Runtime scripting
- [Localisation Guide](https://wiki.factorio.com/Tutorial:Localisation) — Translation system
- [Railway](https://wiki.factorio.com/Railway) — Train scheduling & signals
- [Mod Portal](https://mods.factorio.com/) — Share and browse mods
- [Factorio Forums](https://forums.factorio.com/viewforum.php?f=233) — Community help
- [Version History 2.1.0](https://wiki.factorio.com/Version_history/2.1.0) — All 2.1.x changes including scripting
