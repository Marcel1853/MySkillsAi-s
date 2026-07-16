# Runtime API Reference (control.lua)

> **⚠️ Version-Hinweis:** Stand Factorio 2.1.11 experimental. Bei Unsicherheit über aktuelle Methoden/Signaturen IMMER gegen die offizielle Doku verifizieren: [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/). Factorio 2.1 ist experimental und ändert sich wöchentlich. Eigenschaften ohne expliziten Versionshinweis gelten seit 2.0+.

## Table of Contents

- [Available Globals](#available-globals)
- [The script Object LuaBootstrap](#the-script-object-luabootstrap)
  - [Lifecycle Handlers](#lifecycle-handlers)
  - [Event Registration](#event-registration)
  - [Event Filters Performance Optimization](#event-filters-performance-optimization)
  - [Storage](#storage)
  - [Metatables Persistent Lua Objects](#metatables-persistent-lua-objects)
  - [Notification Queues 2.1+](#notification-queues-21)
- [The game Object LuaGameScript](#the-game-object-luagamescript)
  - [Players](#players)
  - [Surfaces](#surfaces)
  - [Forces](#forces)
  - [Entities](#entities)
  - [Ticks & Timing](#ticks-&-timing)
- [The commands Object LuaCommandProcessor](#the-commands-object-luacommandprocessor)
- [The remote Object LuaRemote](#the-remote-object-luaremote)
- [LuaSurface — Surface Operations](#luasurface-—-surface-operations)
- [LuaEntity — Entity Operations](#luaentity-—-entity-operations)
- [LuaPlayer — Player Operations 2.1 Additions](#luaplayer-—-player-operations-21-additions)
- [LuaItemStack — Item Operations](#luaitemstack-—-item-operations)
- [LuaInventory — Inventory Operations](#luainventory-—-inventory-operations)
- [LuaTechnology — Research](#luatechnology-—-research)
- [LuaRecipe — Recipes](#luarecipe-—-recipes)
- [LuaForce — Faction/Team](#luaforce-—-faction/team)
- [LuaTile — Tile Operations](#luatile-—-tile-operations)
- [LuaChunkIterator — Iterate Chunks](#luachunkiterator-—-iterate-chunks)
- [LuaRendering — Draw Things](#luarendering-—-draw-things)

The runtime stage runs during active gameplay. This is where you handle events, interact with the game world, build GUIs, and manage mod state.

## Available Globals

| Global | Type | Description |
|--------|------|-------------|
| `script` | LuaBootstrap | Event registration, storage, metatables, notification queues (2.1+) |
| `game` | LuaGameScript | Top-level game access (players, surfaces, forces) |
| `commands` | LuaCommandProcessor | Custom console commands |
| `settings` | table | Runtime settings (global and per-player) |
| `remote` | LuaRemote | Cross-mod communication interface |
| `helpers` | LuaHelpers | Utility functions; `is_valid_ambient_sound()`, `is_valid_animation_path()`, `stage` read (2.1+) |
| `prototypes` | table | Read-only access to all prototypes at runtime: `prototypes.item["iron-plate"]`, `prototypes.entity["assembling-machine-3"]`, etc. (2.0+) |

## The `script` Object (LuaBootstrap)

### Lifecycle Handlers

```lua
-- Runs once when the mod is first added to a save or a new game starts
script.on_init(function()
  storage.players = storage.players or {}
  storage.config = storage.config or {enabled = true}
end)

-- Runs every time a save is loaded (before on_init/on_configuration_changed)
-- DO NOT access game data here. Only re-register event handlers.
script.on_load(function()
  -- Re-bind handlers if needed (they persist across saves automatically)
end)

-- Runs when the mod version changes or mod settings change on an existing save
script.on_configuration_changed(function(event)
  -- event.mod_changes contains old_version, new_version for each changed mod
  if event.mod_changes["my-mod"] then
    local old_version = event.mod_changes["my-mod"].old_version
    if old_version and tonumber(old_version:match("%d+")) < 2 then
      -- Migrate data from version 1.x
      for _, player in pairs(game.players) do
        player.print("Welcome to the new version!")
      end
    end
  end
end)
```

### Event Registration

```lua
-- Built-in event (using string name — preferred in 2.0+)
script.on_event("on_built_entity", function(event)
  local entity = event.entity
  game.print(entity.name .. " was built!")
end)

-- Built-in event (using numeric ID — still works)
script.on_event(defines.events.on_player_mined_entity, function(event)
  local entity = event.entity
  local player = game.get_player(event.player_index)
  if player then
    player.print("You mined " .. entity.name)
  end
end)

-- Custom event
local my_event = script.generate_event_name()
script.on_event(my_event, function(event)
  game.print("Custom event fired!")
end)

-- Raise custom event
script.raise_event(my_event, {my_data = "hello"})

-- Multiple events with one handler
script.on_event({
  defines.events.on_player_joined_game,
  defines.events.on_player_left_game,
}, function(event)
  game.print("Player count changed")
end)

-- Nth tick handler
script.on_nth_tick(60, function(event)
  -- Runs every 60 ticks (1 second at 60 UPS)
  game.print("Tick: " .. event.tick)
end)
```

### Event Filters (Performance Optimization)

```lua
-- Only trigger on specific entity names
script.on_event(defines.events.on_built_entity, function(event)
  -- handle build
end, {{filter = "name", name = "assembling-machine-2"}})

-- Only trigger on specific items
script.on_event(defines.events.on_player_crafted_item, function(event)
  -- handle craft
end, {{filter = "item", name = "my-item"}})

-- Dynamic filter
script.set_event_filter(defines.events.on_built_entity, {
  {filter = "name", name = "assembling-machine-3"},
})
```

### Storage

```lua
-- `storage` is a special table that persists across saves
-- Anything stored must be serializable (no Lua objects!)

script.on_init(function()
  storage.data = {
    counters = {},
    player_prefs = {},
    tracked_entities = {},  -- store entity.unit_number, not the entity object!
  }
end)

-- Access anywhere in control.lua
storage.data.counters["my-counter"] = (storage.data.counters["my-counter"] or 0) + 1
```

### Metatables (Persistent Lua Objects)

```lua
-- Register a metatable so Lua objects are tracked across saves
script.register_metatable("my_entity_tracker", {
  __index = {
    get_health = function(self)
      local entity = self.entity
      if entity and entity.valid then
        return entity.health
      end
      return 0
    end,
  }
})

-- Usage
local tracker = {entity = some_lua_entity}
setmetatable(tracker, script.get_metatable("my_entity_tracker"))
```

### Notification Queues (2.1+)

```lua
-- Create a notification queue for custom player notifications
local queue = script.new_notification_queue()  -- Returns LuaNotificationQueue

-- Use to send custom notifications to players
-- See LuaNotificationQueue in official docs for full API
```

---

## The `game` Object (LuaGameScript)

### Players

```lua
-- Access players
for _, player in pairs(game.players) do
  player.print("Hello, " .. player.name .. "!")
end

-- Get specific player
local player = game.get_player(1)  -- by index
local player = game.get_player("MyName")  -- by name

-- Online players only
for _, player in pairs(game.connected_players) do
  player.print("You are online!")
end

-- Player properties
player.name            -- string
player.index           -- number
player.online          -- boolean
player.force           -- LuaForce
player.surface         -- LuaSurface (where their character is)
player.position        -- {x, y}
player.character       -- LuaEntity (their character, or nil)
player.get_main_inventory()  -- LuaInventory
player.cursor_stack    -- LuaItemStack (item in hand)

-- 2.1 additions (see LuaPlayer section below for details)
player.toggle_menu_leaves_remote_view  -- read/write (2.1.9+)
player.get_pins()      -- returns array of LuaPin (2.1.10+)
player.clear_pins()    -- clears all pins (2.1.10+)
player.add_pin({...})  -- now returns LuaPin (2.1.10+)
player.hide_locked_prototypes_in_factoriopedia  -- read/write (2.1.9+)
player.physical_surface          -- read (2.0+)
player.physical_surface_index    -- read (2.0+)
player.physical_vehicle          -- read (2.0+)
player.physical_position         -- read (2.0+)
```

### Surfaces

```lua
-- Iterate all surfaces
for index, surface in pairs(game.surfaces) do
  game.print("Surface: " .. surface.name .. " (index: " .. surface.index .. ")")
end

-- Get specific surface
local nauvis = game.surfaces["nauvis"]
local my_surface = game.surfaces["my-planet-surface"]

-- Create a new surface (Space Age)
local new_surface = game.create_surface("my-custom-surface", {
  width = 2000,
  height = 2000,
  terrain_segmentation = 2,
  water = 0.3,
  starting_area = 1.5,
})

-- Delete a surface
game.delete_surface("my-custom-surface")

-- Clone a surface area
game.clone_area({
  source = {surface = "nauvis", left_top = {x = 0, y = 0}, right_bottom = {x = 100, y = 100}},
  destination = {surface = "my-surface", left_top = {x = 0, y = 0}},
  options = {
    clone_tiles = true,
    clone_entities = true,
    clone_decoratives = true,
  },
})
```

### Forces

```lua
-- Iterate all forces
for _, force in pairs(game.forces) do
  game.print("Force: " .. force.name)
end

-- Get specific force
local player_force = game.forces["player"]
local enemy_force = game.forces["enemy"]

-- Force properties
force.technologies         -- dictionary of technology name → LuaTechnology
force.recipes              -- dictionary of recipe name → LuaRecipe
force.character_logistic_requests  -- boolean
force.friendly_fire        -- boolean

-- Research
force.research_progress = 0.5  -- Set progress (0-1)
force.research_queue_enabled = true

-- Relations
force.set_friend("enemy", false)
force.set_friend("player", true)

-- 2.1 additions
force.is_visible()                -- check if force is visible (2.1+)
force.set_script_visible(true)    -- set script visibility (2.1+)
force.add_alert(...)              -- add alert (2.1+)
force.add_custom_alert(...)       -- add custom alert (2.1+)
force.remove_alert(...)           -- remove alert (2.1+)
force.unlock_logistic_network     -- read/write (2.1+)
force.unlock_travel_to_space_platforms  -- read/write (2.1+)
force.cargo_landing_pad_limit     -- read/write (2.1+)
force.max_cargo_bay_unloading_distance  -- read/write (2.1+)
```

### Entities

```lua
-- Create an entity
local entity = game.surfaces["nauvis"].create_entity({
  name = "assembling-machine-3",
  position = {x = 10, y = 10},
  direction = defines.direction.north,
  force = "player",
  quality = "rare",  -- Space Age
})

-- Find entities
local entities = game.surfaces["nauvis"].find_entities({{0, 0}, {100, 100}})
local entities_filtered = game.surfaces["nauvis"].find_entities_filtered({
  area = {{0, 0}, {100, 100}},
  name = "assembling-machine-*",  -- glob pattern
  type = "assembling-machine",
  force = "player",
  limit = 100,
})

-- Find entities nearby
local nearby = entity.surface.find_entities_filtered({
  position = entity.position,
  radius = 10,
})
```

### Ticks & Timing

```lua
game.tick              -- Current game tick (60 ticks = 1 second at normal speed)
game.speed             -- Current game speed multiplier
game.ticks_per_second  -- Usually 60
game.paused            -- Is the game paused?
```

### Game Utility Methods (2.1+)

```lua
-- Delete blueprint library (2.1+)
game.delete_blueprint_library()

-- Auto-save with replay parameter (2.1+)
game.auto_save("mysave", {allow_in_replay = false})

-- Take technology screenshot (2.1+)
game.take_technology_screenshot({...}, {allow_in_replay = false})
```

---

## The `commands` Object (LuaCommandProcessor)

```lua
-- Register a custom console command
commands.add_command("my-command", "My command description", function(event)
  local player = game.get_player(event.player_index)
  if player then
    player.print("You ran /my-command with parameters: " .. (event.parameter or "none"))
  end
end)

-- With help text
commands.add_command("my-helpful-cmd", {
  "command-description.my-cmd",  -- localised string
}, function(event)
  -- handler
end)
```

---

## The `remote` Object (LuaRemote)

```lua
-- Define a remote interface (in control.lua)
remote.add_interface("my-mod", {
  get_version = function()
    return "1.0.0"
  end,
  do_something = function(data)
    -- called by other mods
    return {success = true}
  end,
  get_entities = function(surface_name)
    local surface = game.surfaces[surface_name]
    if not surface then return nil end
    return surface.count_entities_filtered({name = "assembling-machine-3"})
  end,
})

-- Call another mod's remote interface
if remote.interfaces["space-age"] then
  local result = remote.call("space-age", "get_planet_info", "vulcanus")
end
```

---

## LuaSurface — Surface Operations

```lua
local surface = game.surfaces["nauvis"]

-- Chunk operations
surface.get_chunk_count()
surface.get_chunks()  -- returns LuaChunkIterator

for chunk in surface.get_chunks() do
  game.print("Chunk at " .. chunk.x .. "," .. chunk.y)
end

-- Tile operations
surface.get_tile(10, 10)  -- returns LuaTile
surface.set_tiles({{name = "grass-1", position = {0, 0}}})

-- Decorative operations
surface.create_decoratives({check_collision = true, decoratives = {
  {name = "tree-01", position = {5, 5}, amount = 3},
}})
surface.destroy_decoratives({position = {5, 5}, name = "tree-01"})

-- Chart/Visibility
surface.set_force_visible("player", true)  -- reveal the whole surface to a force
surface.get_hidden_chunk_count()

-- Pollution
surface.get_pollution({x = 0, y = 0})
surface.pollute({x = 0, y = 0}, 100)  -- add pollution

-- Entity creation helpers
surface.create_entity({
  name = "flying-text",
  position = {x = 0, y = 0},
  text = "Hello!",
  color = {r = 1, g = 1, b = 1},
})

-- Entity destruction
surface.destroy_entity(entity)  -- same as entity.destroy()
```

---

## LuaEntity — Entity Operations

> **Stand: Factorio 2.1.11 experimental.** Verify at [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/).

```lua
-- Common properties
entity.name             -- string
entity.type             -- string ("assembling-machine", "inserter", etc.)
entity.position         -- {x, y}
entity.surface          -- LuaSurface
entity.force            -- LuaForce
entity.health           -- number
entity.max_health       -- number
entity.quality          -- string (Space Age)
entity.valid            -- boolean (always check before using a stored reference!)
entity.unit_number      -- unique number (use for storage, not the entity itself)

-- 2.1 additions
entity.flip             -- read (2.1.0+) — entity flip state
entity.protected        -- read/write (2.1.0+) — entity protection flag
entity.disabled_by_script  -- read/write — replaces entity.active write
entity.minable_flag     -- read/write — replaces entity.minable write
entity.script_reservations_count  -- read/write (2.1.0+)
entity.train_reservations_count   -- read (2.1.0+)
entity.input_flow_limit    -- read/write (2.1.0+)
entity.output_flow_limit   -- read/write (2.1.0+)
entity.electric_interface_mode  -- read/write (2.1.0+)
entity.override_logistic_mode   -- read/write (2.1.0+)
entity.autopilot_patrol_size    -- read/write (2.1.0+) — spidertron patrol
entity.request_missing_construction_materials  -- read/write (2.1.10+)
entity.providing_to_other_platforms            -- read/write (2.1.10+)

-- Inventory access (for machines)
local inventory = entity.get_inventory(defines.inventory.crafter_input)
if inventory then
  for i = 1, #inventory do
    local stack = inventory[i]
    if stack.valid_for_read then
      game.print(stack.name .. ": " .. stack.count)
    end
  end
end

-- Fluid access (2.0+ — LuaFluidBox removed!)
entity.get_fluid_count("water")
entity.add_fluid({name = "water", amount = 100, temperature = 15})
entity.remove_fluid({name = "water", amount = 50})  -- new semantics in 2.0+
entity.extract_fluid(...)  -- replaces old remove_fluid behavior
entity.clear_fluids()
entity.get_fluid_filter(index)
entity.set_fluid_filter(index, name)
entity.get_fluid_capacity(index)
entity.get_fluid_box_prototype()
entity.get_fluid_box_neighbours(index)
entity.get_fluid_box_pipe_connections(index)

-- Fluid segment operations (2.1.0+)
entity.has_fluid_segment()
entity.get_fluid_segment_fluid()
entity.set_fluid_segment_fluid(name)
entity.add_fluid_segment_fluid(name, amount)
entity.clear_fluid_segment_fluid()
entity.remove_fluid_segment_fluid(name, amount)
entity.get_fluid_segment_filter()
entity.get_fluid_segment_capacity()
entity.get_fluid_segment_extent_bounding_box()
entity.get_fluid_segment_id()

-- Durability operations (2.1.0+)
entity.clear_stored_durability()
entity.get_stored_durability()
entity.set_stored_durability(value)

-- Tooltip field operations (2.1.0+)
entity.clear_tooltip_fields()
entity.get_tooltip_fields()
entity.clear_tooltip_field(key)
entity.get_tooltip_field(key)
entity.set_tooltip_field(key, value)

-- Deconstruction/Upgrade
entity.order_deconstruction("player")
entity.cancel_deconstruction("player")
entity.order_upgrade({target = "assembling-machine-3", force = "player"})
entity.apply_upgrade()  -- 2.1.10+: can directly upgrade without marking first
entity.to_be_deconstructed()  -- boolean
entity.to_be_upgraded()  -- boolean

-- Cloning
local clone = entity.clone({
  position = {x = 10, y = 10},
  surface = game.surfaces["nauvis"],
  force = "player",
})

-- Destruction
entity.destroy()  -- returns boolean (true if destroyed)
entity.die()      -- kills it with death effects

-- Neighbours (2.0+ — entity.neighbors removed!)
entity.fluidbox_neighbours
entity.underground_belt_neighbour
entity.wall_neighbours
entity.cliff_neighbours
entity.neighbour_connectable_connections

-- Building state
entity.is_crafting()  -- boolean (for assembling machines, furnaces)
entity.crafting_progress  -- 0-1
entity.get_recipe()  -- LuaRecipePrototype or nil
entity.set_recipe("my-recipe")  -- for machines with recipe support

-- Circuit connections
entity.get_circuit_network(defines.wire_type.red, 1)  -- wire type + connector ID

-- Control behavior (2.1+)
local behavior = entity.get_control_behavior()
if behavior then
  behavior.input_networks   -- read/write (2.1.0+)
  behavior.output_networks  -- read/write (2.1.0+)
end

-- Logistics
entity.get_logistic_network()  -- for roboport entities

-- Script mining (2.0+)
entity.mine({player = player, force = true, raise_destroyed = true})
  -- Mines the entity as if a player mined it; returns boolean
  -- player: optional LuaPlayer (for undo support)
  -- force: force mining even if not normally minable
  -- raise_destroyed: raise on_object_destroyed event

-- Display panel (2.0+ record-based, 2.1: string only!)
entity.add_record({text = "Status: OK"})
entity.remove_record(1)
entity.set_record(1, {text = "Warning!"})
entity.records  -- read current records
-- ⚠️ BREAKING 2.1: display_panel_text now accepts string ONLY, not LocalisedString!

-- Cargo pod creation (2.1+ with optional entity spec)
entity.create_cargo_pod({...})  -- can now specify target entity (2.1+)

-- Send to orbit
entity.send_to_orbit_automatically  -- read/write (2.0+)
```

---

## `prototypes` — Read-Only Prototype Access at Runtime

> **2.0+ feature.** Verify at [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/).

```lua
-- Access item prototypes
local item_proto = prototypes.item["iron-plate"]
item_proto.name          -- "iron-plate"
item_proto.stack_size    -- 100
item_proto.weight        -- number (Space Age)
item_proto.place_result  -- entity name or nil
item_proto.fuel_value    -- number or nil
item_proto.localised_name  -- LocalisedString

-- Access entity prototypes
local entity_proto = prototypes.entity["assembling-machine-3"]
entity_proto.name              -- "assembling-machine-3"
entity_proto.crafting_speed    -- 1.25
entity_proto.max_health        -- 300
entity_proto.module_slots      -- 4
entity_proto.collision_box     -- {{left, top}, {right, bottom}}
-- 2.1+ additional methods:
entity_proto.get_max_speed()         -- replaces removed max_speed read
entity_proto.get_duration()          -- replaces removed duration read
entity_proto.get_inventory_size_bonus()  -- quality-based inventory bonus
entity_proto.get_fluid_usage_per_tick()  -- replaces removed fluid_usage_per_tick read
entity_proto.get_max_power_output()      -- replaces removed max_power_output read
entity_proto.get_pumping_speed()         -- replaces removed pumping_speed read

-- Access recipe prototypes
local recipe_proto = prototypes.recipe["iron-gear-wheel"]
recipe_proto.name
recipe_proto.energy        -- crafting time
recipe_proto.ingredients   -- array
recipe_proto.results       -- array

-- Access fluid prototypes
local fluid_proto = prototypes.fluid["water"]
fluid_proto.name
fluid_proto.default_temperature
fluid_proto.heat_capacity

-- Access technology prototypes
local tech_proto = prototypes.technology["automation"]
tech_proto.name
tech_proto.effects          -- array of effects
tech_proto.prerequisites    -- array

-- Access quality prototypes (Space Age)
local quality_proto = prototypes.quality["rare"]
quality_proto.name
quality_proto.level         -- 2
quality_proto.order         -- "c"

-- Iterate all prototypes of a type
for name, proto in pairs(prototypes.item) do
  log("Item: " .. name)
end
```

---

## LuaPlayer — Player Operations (2.1 Additions)

> **Stand: Factorio 2.1.11 experimental.** Verify at [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/).

```lua
local player = game.get_player(1)

-- Standard properties
player.name
player.index
player.online
player.force           -- LuaForce
player.surface         -- LuaSurface
player.position        -- {x, y}
player.character       -- LuaEntity (or nil)

-- 2.0+ additions
player.physical_surface          -- actual surface player is viewing (remote view aware)
player.physical_surface_index    -- index of physical surface
player.physical_vehicle          -- vehicle entity if in one
player.physical_position         -- position in physical surface

-- 2.1.9+ additions
player.toggle_menu_leaves_remote_view  -- read/write: if true, Escape leaves remote view instead of opening menu
player.hide_locked_prototypes_in_factoriopedia  -- read/write: hide unresearched in Factoriopedia

-- 2.1.10+ Pin system
player.add_pin({
  icon = {type = "item", name = "iron-plate"},
  position = {0, 0},
  surface = game.surfaces["nauvis"],
})  -- now returns LuaPin (2.1.10+)

player.get_pins()     -- returns array of LuaPin objects
player.clear_pins()   -- removes all pins

-- Inventory
player.get_main_inventory()  -- LuaInventory
player.cursor_stack    -- LuaItemStack (item in hand)
```

---

## LuaItemStack — Item Operations

```lua
local stack = player.get_main_inventory()[1]

if stack.valid_for_read then
  stack.name          -- "iron-plate"
  stack.count         -- number
  stack.quality       -- string (Space Age)
  stack.durability    -- number (for tools/weapons)
  stack.is_blueprint  -- boolean
  stack.is_blueprint_book  -- boolean
  stack.is_item_with_label  -- boolean
  stack.is_item_with_inventory  -- boolean
  stack.is_item_with_tags  -- boolean
end

-- Operations
stack.set_stack({name = "iron-plate", count = 100})
stack.clear()
stack.transfer_to(target_inventory, target_index)
stack.can_set_stack({name = "iron-plate", count = 50})  -- boolean
```

---

## LuaInventory — Inventory Operations

```lua
local inv = player.get_main_inventory()

-- Access slots (1-indexed)
local stack = inv[1]

-- Count items
inv.get_item_count("iron-plate")

-- Find items
local slot = inv.find_item_stack("iron-plate")  -- first slot index with this item

-- Insert/remove
inv.insert({name = "iron-plate", count = 10})
inv.remove({name = "iron-plate", count = 5})

-- Clear
inv.clear()

-- Properties
inv.is_empty()  -- boolean
inv.get_item_count()  -- total items (all types)
#inv  -- number of slots
inv.supports_bar()  -- boolean (can set a bar/limit)
inv.get_bar()  -- number (the bar slot)
inv.set_bar(50)

-- 2.1: get_contents() returns array with quality
local contents = inv.get_contents()
-- Returns: { { name = "iron-plate", count = 100, quality = "normal" }, ... }
```

---

## LuaTechnology — Research

```lua
local tech = game.forces["player"].technologies["automation"]

tech.name           -- "automation"
tech.researched     -- boolean
tech.enabled        -- boolean (can be researched)
tech.level          -- number (for infinite techs)
tech.prototype      -- LuaTechnologyPrototype
tech.price_multiplier  -- number (can be modified)

-- Research operations
tech.researched = true   -- instantly complete
tech.enabled = false     -- disable (grey out)
```

---

## LuaRecipe — Recipes

```lua
local recipe = game.forces["player"].recipes["iron-gear-wheel"]

recipe.name           -- "iron-gear-wheel"
recipe.enabled        -- boolean
recipe.prototype      -- LuaRecipePrototype
recipe.product_count  -- number (result amount)
recipe.energy         -- number (crafting time in seconds)

-- Modify at runtime
recipe.enabled = true  -- unlock recipe
```

---

## LuaForce — Faction/Team

```lua
local force = game.forces["player"]

-- Chart operations
force.chart(surface, {{left_top = {0, 0}, right_bottom = {100, 100}}})
force.clear_chart(surface)  -- un-explore

-- Research
force.research("automation")  -- set current research
force.research_progress  -- 0-1

-- Technologies
force.technologies["automation"].researched  -- boolean

-- Recipes
force.recipes["my-recipe"].enabled  -- boolean

-- Friends/Enemies
force.get_friend("enemy")  -- boolean
force.set_friend("enemy", false)

-- Kill statistics
force.get_kill_count("big-biter")

-- Share character logistics
force.character_logistic_requests = true
force.logistic_slot_count = 10  -- number of logistic slots

-- 2.1 additions
force.is_visible()                 -- check force visibility (2.1+)
force.set_script_visible(true)     -- set script visibility (2.1+)
force.get_script_visible()         -- get script visibility (2.1+)
force.add_alert(...)               -- add standard alert (2.1+)
force.add_custom_alert(...)        -- add custom alert (2.1+)
force.remove_alert(...)            -- remove alerts (2.1+)
force.unlock_logistic_network      -- read/write (2.1+)
force.unlock_travel_to_space_platforms  -- read/write (2.1+)
force.cargo_landing_pad_limit      -- read/write (2.1+)
force.max_cargo_bay_unloading_distance  -- read/write (2.1+)
```

---

## LuaTile — Tile Operations

```lua
local tile = surface.get_tile(10, 10)

tile.name           -- "grass-1", "water", etc.
tile.position       -- {x, y} (chunk-aligned)
tile.surface        -- LuaSurface
tile.collision_mask -- table of collision layers

-- Change tile
tile.set("refined-hazard-concrete-left", player)  -- with player for undo
```

---

## LuaChunkIterator — Iterate Chunks

```lua
local surface = game.surfaces["nauvis"]
local chunks = surface.get_chunks()

for chunk in chunks do
  local left_top = {x = chunk.x * 32, y = chunk.y * 32}
  local right_bottom = {x = (chunk.x + 1) * 32, y = (chunk.y + 1) * 32}
  game.print("Chunk " .. chunk.x .. "," .. chunk.y)
end

-- With area restriction
local iter = surface.get_chunks({
  left_top_chunk = {-10, -10},
  right_bottom_chunk = {10, 10},
})
```

---

## LuaRendering — Draw Things

```lua
-- Draw a line
rendering.draw_line({
  color = {r = 1, g = 0, b = 0},
  width = 2,
  from = {x = 0, y = 0},
  to = {x = 100, y = 100},
  surface = "nauvis",
  time_to_live = 300,  -- ticks (5 seconds)
})

-- Draw a circle
rendering.draw_circle({
  color = {r = 0, g = 1, b = 0},
  radius = 5,
  target = {x = 0, y = 0},
  surface = "nauvis",
  time_to_live = 600,
})

-- Draw text (flying text)
rendering.draw_text({
  text = "Hello!",
  target = {x = 0, y = 0},
  surface = "nauvis",
  color = {r = 1, g = 1, b = 1},
  scale = 1.5,
  time_to_live = 120,
})

-- Draw sprite
rendering.draw_sprite({
  sprite = "utility/warning_icon",
  target = {x = 0, y = 0},
  surface = "nauvis",
  time_to_live = 180,
})

-- Create persistent rendering object
local obj = rendering.draw_line({
  color = {r = 1, g = 0, b = 0, a = 0.5},
  width = 3,
  from = {x = 0, y = 0},
  to = {x = 50, y = 50},
  surface = "nauvis",
  draw_on_ground = true,  -- draws on the ground, not above entities
})
obj.destroy()  -- to remove it later
```

### ⚠️ Factorio 2.1 Fluid & Fluid Box Overhaul
In Factorio 2.1, **`LuaEntity::fluidbox` and the `LuaFluidBox` class have been completely removed!**
All fluid interaction is now done directly through `LuaEntity`.
- Do NOT use `entity.fluidbox[1]`.
- Instead, use new direct methods:
  - `entity.clear_fluids()`
  - `entity.add_fluid({name = "water", amount = 100, temperature = 15})`
  - `entity.get_fluid_filter(index)`
  - `entity.set_fluid_filter(index, name)`
  - `entity.get_fluid_capacity(index)`
  - `entity.extract_fluid(...)` (replaces old `remove_fluid` behavior)
  - `entity.remove_fluid(...)` (now removes specific amounts of fluids with different arguments)
  - `entity.has_fluid_segment()`, `entity.get_fluid_segment_fluid()`, etc. (2.1.0+)

### ⚠️ Writable property updates in 2.1
- **`entity.active` is no longer writable!** Use `entity.disabled_by_script = true` instead.
- **`entity.minable` is no longer writable!** Use `entity.minable_flag = false` instead.
- **`entity.neighbors` is removed!** Use specific properties: `fluidbox_neighbours`, `underground_belt_neighbour`, `wall_neighbours`, `cliff_neighbours`, or `neighbour_connectable_connections`.

### ⚠️ Programmable Speaker (2.1.10+)
- **`Global` playback mode renamed to `Universe`!** Use `Universe` instead of `Global`.

### ⚠️ Display Panel (2.1 breaking)
- **`display_panel_text` now accepts `string` ONLY** — `LocalisedString` no longer works. Use `add_record()`, `set_record()`, `records` instead.

---

## Common Runtime Mistakes

1. **Writing to `entity.active`** — Use `entity.disabled_by_script = true/false` instead. `entity.active` is read-only since 2.0.

2. **Writing to `entity.minable`** — Use `entity.minable_flag = false/true` instead. `entity.minable` write removed since 2.0.

3. **Using `entity.fluidbox`** — Completely removed. Use `entity.add_fluid()`, `entity.get_fluid_count()`, `entity.extract_fluid()`, etc.

4. **Using `entity.neighbors`** — Removed. Use `entity.fluidbox_neighbours`, `entity.wall_neighbours`, etc.

5. **Storing Lua objects in `storage`** — Only serializable data! Use `entity.unit_number` instead of entity references.

6. **Writing to `storage` in `on_load()`** — Read-only! Only re-register event handlers or re-setup metatables.

7. **Accessing `game` in `on_load()`** — Not available! Only `script`, `storage` (read), `settings`, `mods` available.

8. **Setting `circuit_condition_satisfied`** — This is read-only. Use `entity.disabled_by_script` to control entity state based on circuit conditions.

9. **Using `"Global"` for Programmable Speaker** — Renamed to `"Universe"` in 2.1.10.

10. **Using `display_panel_text` with LocalisedString** — Only plain `string` works in 2.1+. Use record-based API instead.

11. **Not checking `entity.valid`** — Always check before accessing a stored entity reference.

12. **Using `global` instead of `storage`** — `global` was removed in 2.0. Use `storage`.

13. **Using `category` on recipes** — Use `categories = {"crafting"}` array instead. `category` crashes on load in 2.0+.
