# Definitive Guide: Factorio Mod File Lifecycle

> **⚠️ Version-Hinweis:** Stand Factorio 2.1.11 experimental. Bei Unsicherheit über verfügbare Globals/Methoden IMMER gegen die offizielle Doku verifizieren: [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/). Factorio 2.1 (experimental) ändert sich wöchentlich. Der Lifecycle selbst (settings → prototype → runtime) ist stabil seit 2.0.

## Table of Contents

- [The Three Stages](#the-three-stages)
  - [Stage 1: Settings Stage](#stage-1:-settings-stage)
  - [Stage 2: Prototype Data Stage](#stage-2:-prototype-data-stage)
  - [Stage 3: Control Runtime Stage](#stage-3:-control-runtime-stage)
- [The storage Object](#the-storage-object)
- [The on_load Handler](#the-on_load-handler)
- [The on_configuration_changed Handler](#the-on_configuration_changed-handler)
- [Migrations](#migrations)
  - [JSON Migration prototype changes](#json-migration-prototype-changes)
  - [Lua Migration data fixes](#lua-migration-data-fixes)
- [Splitting Code with require](#splitting-code-with-require)
  - [Data stage require](#data-stage-require)
  - [Runtime stage require](#runtime-stage-require)
- [Quick Reference: What's Available When?](#quick-reference:-what's-available-when?)
- [Common Pitfalls](#common-pitfalls)


- [The Three Stages](#)
- [The `storage` Object](#)
- [The `on_load()` Handler](#)
- [The `on_configuration_changed()` Handler](#)
- [Migrations](#)
- [Splitting Code with `require()`](#)
- [Quick Reference: What's Available When?](#)
- [Common Pitfalls](#)



This document explains exactly when each file runs, what's available, and how data flows through a Factorio 2.1 mod.

---

## The Three Stages

Factorio loads mods in three distinct stages, each with different rules:

### Stage 1: Settings Stage

**Timing:** Game startup, before any game or surface exists.

**Files run (in order across ALL mods):**
```
settings.lua         →  settings-updates.lua         →  settings-final-fixes.lua
  (all mods)               (all mods)                     (all mods)
```

**What's available:**
- `data` — registry for setting prototypes
- `data:extend{}` — function to register settings
- `mods` — table of all active mods with versions

**What you define:**
- `double-setting`, `int-setting`, `string-setting`, `bool-setting`
- Settings with `setting_type`: `"startup"`, `"runtime"`, or `"runtime-per-user"`

**Key point:** Startup settings are frozen after this stage. Runtime settings can change during gameplay.

---

### Stage 2: Prototype (Data) Stage

**Timing:** Game startup, after settings stage, still before any game exists.

**Files run (in order across ALL mods):**
```
data.lua             →  data-updates.lua             →  data-final-fixes.lua
  (all mods)               (all mods)                     (all mods)
```

**What's available:**
- `data` — registry for game prototypes
- `data.raw` — table of ALL prototypes loaded so far, indexed by `[type][name]`
- `data:extend{}` — function to register prototypes
- `data:is_dirty()` — check if `data:extend()` was called
- `mods` — table of all active mods
- `settings.startup[...]` — resolved startup settings

**What you define:**
- All game objects: entities, items, recipes, technologies, fluids, equipment, planets, etc.
- Each prototype must have `type` and `name` fields

**Key patterns:**

```lua
-- Creating a new prototype
data:extend({
  {
    type = "item",
    name = "my-item",
    icon = "__my-mod__/graphics/icons/my-item.png",
    icon_size = 64,
    stack_size = 100,
  }
})

-- Modifying an existing prototype
if data.raw["assembling-machine"]["assembling-machine-3"] then
  data.raw["assembling-machine"]["assembling-machine-3"].crafting_speed = 2.0
end

-- Checking for optional dependencies
if mods["space-age"] then
  -- Add space-age specific content
end

-- Reading startup settings in data stage
if settings.startup["my-mod-enable-feature"].value then
  -- Add conditional content
end
```

**Load order rules:**
1. Mods sorted by dependency depth (shallowest first)
2. Ties broken alphabetically by mod name
3. Within each mod, `data.lua` → `data-updates.lua` → `data-final-fixes.lua`

This means:
- In `data.lua`: Define your own prototypes
- In `data-updates.lua`: Modify prototypes from other mods that loaded before you
- In `data-final-fixes.lua`: Make final corrections after everyone has had their say

---

### Stage 3: Control (Runtime) Stage

**Timing:** When a save is loaded or a new game is created. This is when `game` actually exists.

**The control stage has its own internal sequence:**

```
1. control.lua runs (top-level code)
   ↓
2. Is mod new to this save?
   ├─ YES → on_init() runs, then migrations
   └─ NO  → on_load() runs, then migrations
   ↓
3. on_configuration_changed() runs (if mod or settings changed)
   ↓
4. Game is fully running → Events fire normally
```

**What's available (after initialization):**
- `script` — event registration, storage, metatables
- `game` — full access to game world (players, surfaces, forces, entities)
- `commands` — custom console commands
- `remote` — cross-mod communication
- `storage` — persistent data table (serialized with saves)
- `settings` — all resolved settings (startup, runtime-global, runtime-per-user)
- `prototypes` — read-only access to all prototypes

**What you do:**
- Register event handlers with `script.on_event()`
- Read/modify `storage` (basic data, tables, LuaObject references — no functions)
- Interact with the game via `game` methods
- Define custom console commands

---

## The `storage` Object

`storage` is a special table that persists across save/load cycles. It's serialized into the save file.

**Rules** ([official](https://lua-api.factorio.com/latest/auxiliary/storage.html), verified 2.1.19):
1. Allowed: nil, strings, numbers, booleans, tables and **references to LuaObjects** (LuaEntity, LuaPlayer, LuaSurface …)
2. **Not allowed:** functions (error when saving). Metatables are only kept if registered with `script.register_metatable`
3. Stored LuaObjects can become invalid (entity removed) → always check `.valid`; `unit_number` is a good table key
4. Initialize in `on_init()`, read in `on_load()`, modify in event handlers

```lua
-- ✅ CORRECT: storing serializable data
script.on_init(function()
  storage.entities = {}
  storage.counters = {builds = 0, deaths = 0}
  storage.config = {enabled = true, mode = "normal"}
end)

-- ✅ CORRECT: storing entity reference by unit_number
script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.entity
  if entity.type == "assembling-machine" then
    storage.entities[entity.unit_number] = {
      name = entity.name,
      position = entity.position,
      surface = entity.surface.name,
    }
  end
end)

-- ✅ ALSO CORRECT: storing the LuaObject reference itself (check .valid before use)
script.on_init(function()
  storage.my_entity = game.surfaces["nauvis"].find_entity("assembling-machine-3", {0, 0})
end)

-- ❌ WRONG: storing a function
script.on_init(function()
  storage.callback = function() end -- error when the game is saved
end)
```

**Retrieving stored entities:**
```lua
local unit_number = storage.entities[some_key]
if unit_number then
  local entity = game.surfaces["nauvis"].get_entity(unit_number)
  if entity and entity.valid then
    -- Safe to use the entity
  end
end
```

---

## The `on_load()` Handler

`on_load()` runs when a save is loaded, **before** the game is fully available.

**Rules:**
1. **DO NOT** access `game` in `on_load()`
2. **DO NOT** modify `storage` in `on_load()`
3. Only use it to re-register handlers that use closures
4. Most handlers registered with `script.on_event()` persist automatically

```lua
-- Typical on_load: re-register handlers that captured local variables
script.on_load(function()
  -- If your handler was defined as a closure with captured state,
  -- re-register it here. Otherwise, handlers persist automatically.
  
  -- Example with closure:
  -- local counter = 0
  -- script.on_event(defines.events.on_tick, function()
  --   counter = counter + 1  -- This closure needs re-registration
  -- end)
end)
```

---

## The `on_configuration_changed()` Handler

Runs when:
- A new game is started with the mod enabled (after `on_init`)
- The mod version changes on an existing save
- Mod settings change

```lua
script.on_configuration_changed(function(event)
  local changes = event.mod_changes
  if changes["my-mod"] then
    local old_ver = changes["my-mod"].old_version
    if old_ver == nil then
      -- Mod was just added to an existing save
      game.print("My Mod added! Initializing...")
    elseif old_ver == "1.0.0" then
      -- Migrating from 1.0.0 to current
      migrate_from_1_0()
    end
  end
  
  -- Check if space-age was added
  if changes["space-age"] and changes["space-age"].old_version == nil then
    -- Space Age was added to an existing save
    unlock_space_content()
  end
end)
```

---

## Migrations

Migrations handle version-specific changes to save data. Place files in `migrations/`:

```
my-mod/
└── migrations/
    ├── 1.1.0.json   ← Prototype migrations (renames, removals)
    └── 1.2.0.lua    ← Script migrations (data fixes)
```

### JSON Migration (prototype changes)
```json
{
  "entity": [
    ["old-entity-name", "new-entity-name"]
  ],
  "item": [
    ["old-item-name", "new-item-name"]
  ],
  "recipe": [
    ["old-recipe-name", "new-recipe-name"]
  ]
}
```

### Lua Migration (data fixes)
```lua
-- migrations/1.2.0.lua
-- Runs once when upgrading from a version < 1.2.0
for _, player in pairs(game.players) do
  -- Unlock new techs
  player.force.technologies["my-new-tech"].researched = true
end

-- Fix storage data
if storage.old_format then
  storage.new_format = convert(storage.old_format)
  storage.old_format = nil
end
```

---

## Splitting Code with `require()`

Factorio mods can (and should) split code across multiple files.

### Data stage `require()`
```lua
-- data.lua
require("prototypes.items")
require("prototypes.recipes")
require("prototypes.entities")
require("prototypes.technologies")

if mods["space-age"] then
  require("prototypes.space-entities")
end
```

Each file must call `data:extend{}` with its prototypes. They're all executed in the same Lua state.

### Runtime stage `require()`
```lua
-- control.lua
require("lib.event-handlers")
require("lib.gui")
require("lib.circuit-logic")
require("lib.migration")
```

Use `__mod-name__/` prefix to reference files from other mods:
```lua
local asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")
local effects = require("__core__.lualib.surface-render-parameter-effects")
```

---

## Quick Reference: What's Available When?

| Context | `data` | `data.raw` | `game` | `script` | `storage` | `settings` | `mods` | `prototypes` |
|---------|--------|-----------|--------|----------|-----------|------------|--------|-------------|
| `settings.lua` | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ |
| `data.lua` | ✅ | ✅ | ❌ | ❌ | ❌ | ✅(startup) | ✅ | ❌ |
| `data-updates.lua` | ✅ | ✅ | ❌ | ❌ | ❌ | ✅(startup) | ✅ | ❌ |
| `data-final-fixes.lua` | ✅ | ✅ | ❌ | ❌ | ❌ | ✅(startup) | ✅ | ❌ |
| `control.lua` top-level | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ |
| `on_init()` | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| `on_load()` | ❌ | ❌ | ❌ | ✅ | ✅(read-only) | ✅ | ✅ | ❌ |
| `on_configuration_changed()` | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Event handlers | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## Common Pitfalls

1. **Modifying `storage` in `on_load()`** — This causes corruption. Only modify in event handlers or `on_init()`.
2. **Accessing `game` at the top level of `control.lua`** — `game` doesn't exist until after initialization.
3. **Not checking `entity.valid`** — Stored entities can be destroyed. Always check before use.
4. **Forgetting to add `?` to optional dependencies** — Use `"? space-age"` for optional, `"space-age"` for required.
5. **Not handling `on_configuration_changed()`** — Mod updates on existing saves will break without migration code.
6. **Storing functions in `storage`** — not allowed (error on save). LuaObject references are fine; check `.valid`.
