# Additional Runtime API Reference

> **⚠️ Version-Hinweis:** Stand Factorio 2.1.11 experimental. Bei Unsicherheit über aktuelle Methoden/Signaturen IMMER gegen die offizielle Doku verifizieren: [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/). Factorio 2.1 ist experimental und ändert sich wöchentlich. Eigenschaften ohne expliziten Versionshinweis gelten seit 2.0+.

## Table of Contents

- [LuaForce — Team / Faction](#luaforce-—-team-/-faction)
- [LuaTechnology — Research](#luatechnology-—-research)
- [LuaRecipe — Crafting Recipe](#luarecipe-—-crafting-recipe)
- [LuaItemPrototype — Item Definition Read-only at runtime](#luaitemprototype-—-item-definition-read-only-at-runtime)
- [LuaEntityPrototype — Entity Definition Read-only](#luaentityprototype-—-entity-definition-read-only)
- [LuaTrain — Train Operations](#luatrain-—-train-operations)
- [LuaLogisticNetwork](#lualogisticnetwork)
- [LuaCircuitNetwork](#luacircuitnetwork)
- [LuaControl — Base class for Players and Entities](#luacontrol-—-base-class-for-players-and-entities)
- [LuaEquipment & LuaEquipmentGrid](#luaequipment-&-luaequipmentgrid)
- [LuaCommandable — AI-Controllable Units](#luacommandable-—-ai-controllable-units)
- [LuaAISettings — Biter AI 2.0 change](#luaaisettings-—-biter-ai-2.0-change)
- [LuaCommandProcessor — Custom Commands](#luacommandprocessor-—-custom-commands)
- [LuaRemote — Cross-Mod Communication](#luaremote-—-cross-mod-communication)
- [LuaRendering — Visual Drawing](#luarendering-—-visual-drawing)
- [LuaChunkIterator — Iterate Chunks](#luachunkiterator-—-iterate-chunks)
- [LuaItemStack — Item Stack Operations](#luaitemstack-—-item-stack-operations)
- [LuaNotificationQueue — Notifications 2.1+](#luanotificationqueue-—-notifications-21)
- [LuaPin — Map Pins 2.1.10+](#luapin-—-map-pins-2110)
- [LuaControlBehavior — Circuit Control 2.1+](#luacontrolbehavior-—-circuit-control-21)

This covers remaining important runtime classes and concepts not detailed in `04-runtime-api.md`.

## LuaForce — Team / Faction

```lua
local force = game.forces["player"]

-- Properties
force.name                   -- string
force.friendly_fire          -- boolean
force.chart_tags             -- dictionary of chart tags
force.character_logistic_requests  -- boolean
force.logistic_slot_count    -- number
force.research_queue_enabled -- boolean (can queue research)
force.research_queue         -- array of LuaTechnology
force.print_queue_enabled    -- boolean

-- Research
force.research_progress       -- 0-1, current research progress
force.technologies            -- dictionary: name → LuaTechnology
force.recipes                 -- dictionary: name → LuaRecipe

-- Chart/Map
force.chart(surface, area)            -- reveal area
force.clear_chart(surface)            -- un-reveal
force.force_cease_fire(other_force)   -- stop fighting
force.set_friend(other_force, true)   -- make friendly
force.get_friend(other_force)         -- check friend status

-- Statistics
force.get_kill_count(entity_name)     -- total kills of this entity type
force.get_item_production_statistics(flow_precision_index)
force.get_item_consumption_statistics(flow_precision_index)

-- Evolution
force.evolution_factor              -- 0-1, biter evolution level
force.evolution_factor_by_pollution -- contribution from pollution
force.evolution_factor_by_time      -- contribution from time
force.evolution_factor_by_spawner_kills -- contribution from killing spawners

-- Flow statistics (2.1+ extended)
local flow = force.get_item_production_statistics(surface)  -- je Oberfläche; Genauigkeit erst in flow.get_flow_count{…, precision_index = defines.flow_precision_index.one_hour}
flow.get_current_input_sample()       -- get current tick input sample (2.1+)
flow.set_current_input_sample(value)  -- set current tick input sample (2.1+)
flow.get_current_output_sample()      -- get current tick output sample (2.1+)
flow.set_current_output_sample(value) -- set current tick output sample (2.1+)
flow.input_quality_counts             -- per-quality input counts (2.1+)
flow.current_input_quality_samples    -- per-quality current input samples (2.1+)
flow.output_quality_counts            -- per-quality output counts (2.1+)
flow.current_output_quality_samples   -- per-quality current output samples (2.1+)

-- 2.1 additions
force.is_visible()                  -- check if force is visible to scripts (2.1+)
force.set_script_visible(true)      -- set script visibility (2.1+)
force.get_script_visible()          -- get script visibility (2.1+)
force.add_alert(...)                -- add standard alert (2.1+)
force.add_custom_alert(...)         -- add custom alert with custom icon (2.1+)
force.remove_alert(...)             -- remove alerts (2.1+)
force.unlock_logistic_network       -- read/write: unlock logistic network (2.1+)
force.unlock_travel_to_space_platforms  -- read/write: unlock space travel (2.1+)
force.cargo_landing_pad_limit       -- read/write: max cargo landing pads (2.1+)
force.max_cargo_bay_unloading_distance  -- read/write (2.1+)
```

## LuaTechnology — Research

```lua
local tech = force.technologies["automation"]

tech.name           -- string
tech.researched     -- boolean
tech.enabled        -- boolean
tech.level          -- number (for infinite techs, >= 1)
tech.prototype      -- LuaTechnologyPrototype
tech.price_multiplier  -- number
tech.research_unit_ingredients  -- array of {name, amount}
tech.research_unit_count        -- number (or formula for infinite)
tech.research_unit_energy       -- number (seconds)

-- Methods
tech.research()              -- start researching
tech.research_recursively()  -- auto-queue prerequisites
```

## LuaRecipe — Crafting Recipe

```lua
local recipe = force.recipes["iron-gear-wheel"]

recipe.name            -- string
recipe.enabled         -- boolean
recipe.category        -- string (e.g., "crafting", "smelting")
recipe.energy          -- number (seconds)
recipe.prototype       -- LuaRecipePrototype
recipe.product_count   -- number (base output amount)
recipe.ingredients     -- array
recipe.results         -- array

-- Check if recipe is available
if recipe.enabled and force.technologies["automation"].researched then
  -- recipe can be used
end
```

## LuaItemPrototype — Item Definition (Read-only at runtime)

```lua
local proto = prototypes.item["iron-plate"]

proto.name              -- string
proto.type              -- string ("item", "tool", "ammo", etc.)
proto.stack_size        -- number
proto.weight            -- number (grams, Space Age)
proto.place_result      -- string (entity name if placeable)
proto.fuel_category     -- string or nil
proto.fuel_value        -- number (Joules)
proto.burnt_result      -- string or nil (what it becomes after burning)
proto.quality           -- string (Space Age)
proto.default_import_location  -- string (Space Age)
proto.localised_name    -- LocalisedString
proto.localised_description -- LocalisedString
```

## LuaEntityPrototype — Entity Definition (Read-only)

> **Stand: Factorio 2.1.11 experimental.** Verify at [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/).

```lua
local proto = prototypes.entity["assembling-machine-3"]

proto.name              -- string
proto.type              -- string
proto.max_health        -- number
proto.crafting_speed    -- number
proto.energy_usage      -- string (e.g., "150kW")
proto.module_slots      -- number
proto.allowed_effects   -- array of strings
proto.minable           -- table (mining_time, result)
proto.collision_box     -- {{left, top}, {right, bottom}}
proto.selection_box     -- {{left, top}, {right, bottom}}

-- 2.1 additions
proto.get_max_speed()        -- method replacing max_speed (2.1+)
proto.get_duration()         -- method replacing duration read (2.1+)
proto.get_inventory_size_bonus()  -- quality-based inventory bonus (2.1+)
proto.show_fluid_visualization_when_in_cursor  -- read (2.1.10+)
proto.fixed_quality          -- read (2.1+)
proto.platform_weight        -- read (2.1+)
proto.platform_repair_speed_modifier  -- read (2.1+)
proto.lift_weight            -- read (2.1+)
proto.use_mirroring          -- read (2.1+)
proto.attack_target_mask     -- read (2.1+)
proto.ignore_target_mask     -- read (2.1+)
-- Removed: fluid_usage_per_tick (use get_fluid_usage_per_tick())
-- Removed: max_power_output (use get_max_power_output())
-- Removed: pumping_speed (use get_pumping_speed())
-- Removed: build_base_evolution_requirement
```

## LuaTrain — Train Operations

```lua
-- Get trains on a surface
local trains = surface.get_trains()
for _, train in pairs(trains) do
  game.print("Train ID: " .. train.id)
  game.print("Locomotives: " .. #train.locomotives)
  game.print("Cargo wagons: " .. #train.cargo_wagons)
  game.print("State: " .. train.state)
  game.print("Speed: " .. train.speed)
  game.print("Max forward speed: " .. train.max_forward_speed)
  game.print("Max backward speed: " .. train.max_backward_speed)

  -- Set schedule (use LuaSchedule API instead)
  local schedule = train.get_schedule()
  -- See references/10-trains.md for full LuaSchedule API
end
```

## LuaLogisticNetwork

```lua
local entity = surface.find_entity("roboport", {0, 0})
if entity then
  local network = entity.logistic_network
  if network then
    game.print("Logistic robots: " .. network.logistic_robot_count)
    game.print("Construction robots: " .. network.construction_robot_count)
    game.print("All logistic members: " .. #network.members)
    game.print("Red circuit network: " .. tostring(network.red_network ~= nil))
  end
end
```

## LuaCircuitNetwork

```lua
local entity = surface.find_entity("constant-combinator", {0, 0})
if entity then
  local network = entity.get_circuit_network(defines.wire_connector_id.circuit_red)
  if network then
    for _, s in pairs(network.signals or {}) do -- { signal = SignalID, count = n }
      game.print((s.signal.type or "item") .. " " .. s.signal.name .. ": " .. s.count)
    end
  end
end
```

## LuaControl — Base class for Players and Entities

```lua
local control = player  -- or an entity
control.force           -- LuaForce
control.surface         -- LuaSurface
control.position        -- {x, y}
control.valid           -- boolean
control.health          -- number
control.max_health      -- number
control.shield          -- number
control.max_shield      -- number

-- 2.1: mining_progress moved here from LuaEntity, now read/write
control.mining_progress  -- read/write (2.1+)
```

## LuaEquipment & LuaEquipmentGrid

```lua
-- Get player's equipment grid
local player = game.get_player(1)
if player.character then
  local grid = player.character.grid
  if grid then
    for _, equipment in pairs(grid.equipment) do
      game.print(equipment.type .. ": " .. equipment.name)
      game.print("Energy: " .. equipment.energy)
      game.print("Max energy: " .. equipment.max_energy)
      game.print("Shape: " .. equipment.shape.width .. "x" .. equipment.shape.height)
    end
  end
end

-- Insert equipment
grid.put({name = "personal-roboport-equipment"})

-- 2.1 additions
equipment.power_production   -- read/write (2.1+)
equipment.power_usage        -- read/write (2.1+)
equipment.electric_buffer_size  -- read/write (2.1+)
```

## LuaCommandable — AI-Controllable Units

```lua
-- Order a unit to go somewhere
local unit = surface.find_entity("unit", {0, 0})
if unit and unit.valid then
  local commandable = unit.commandable  -- 2.0+: use .commandable
  if commandable then
    commandable.set_command({
      type = defines.command.go_to_location,
      destination = {x = 100, y = 100},
      pathfind_flags = {
        allow_destroy_friendly_entities = false,
        prefer_straight_paths = false,
      },
      distraction = defines.distraction.by_anything,
    })
  end
end
```

## LuaAISettings — Biter AI (2.0 change)

> In 2.0, `biter_ai_settings` is no longer a global. Use `require` instead:

```lua
-- WRONG (old way):
-- local settings = biter_ai_settings

-- CORRECT (2.0+):
local biter_ai_settings = require("biter-ai-settings")
-- Now use biter_ai_settings as a local table
```

## LuaCommandProcessor — Custom Commands

```lua
-- Register a command
commands.add_command("my-command", "Description of my command", function(event)
  local player = game.get_player(event.player_index)
  local parameter = event.parameter  -- string after command name

  if player then
    player.print("You ran: /my-command " .. (parameter or ""))
  end
end)

-- Register with localised description
commands.add_command("my-cmd", {"command-description.my-cmd"}, function(event)
  -- handler
end)
```

## LuaRemote — Cross-Mod Communication

```lua
-- Provide an interface
remote.add_interface("my-mod", {
  get_data = function()
    return storage.my_data
  end,
  set_data = function(data)
    storage.my_data = data
  end,
  do_action = function(action_name)
    if action_name == "reset" then
      storage.my_data = {}
    end
  end,
})

-- Call another mod's interface
if remote.interfaces["other-mod"] and remote.interfaces["other-mod"]["get_info"] then
  local info = remote.call("other-mod", "get_info")
end
```

## LuaRendering — Visual Drawing

```lua
-- Draw shapes (temporary or persistent)
local line = rendering.draw_line({
  color = {r = 1, g = 0, b = 0},
  width = 2,
  from = {x = 0, y = 0},
  to = {x = 100, y = 100},
  surface = "nauvis",
  time_to_live = 300,  -- ticks (remove after this many ticks)
})

local circle = rendering.draw_circle({
  color = {r = 0, g = 1, b = 0, a = 0.3},
  radius = 5,
  target = {x = 0, y = 0},
  surface = "nauvis",
  time_to_live = 600,
})

-- Persistent rendering (no time_to_live)
local persistent = rendering.draw_line({
  color = {r = 1, g = 1, b = 0, a = 0.5},
  width = 1,
  from = {x = 0, y = 0},
  to = {x = 50, y = 50},
  surface = "nauvis",
  draw_on_ground = true,
})

-- Destroy persistent rendering
persistent.destroy()

-- Get all rendering objects of this mod
local all_objects = rendering.get_all_objects(script.mod_name)
```

## LuaChunkIterator — Iterate Chunks

```lua
local surface = game.surfaces["nauvis"]
local chunks = surface.get_chunks()

for chunk in chunks do
  game.print("Chunk: " .. chunk.x .. ", " .. chunk.y)
  game.print("Last user: " .. chunk.last_user)
  game.print("Generated: " .. tostring(chunk.generated))
end

-- Filtered chunk iteration
local filtered = surface.get_chunks({
  area = {{0, 0}, {100, 100}},
})
```

## LuaItemStack — Item Stack Operations

```lua
local stack = player.get_main_inventory()[1]

-- Properties
stack.valid_for_read      -- boolean (is there something in this slot?)
stack.name                -- string
stack.count               -- number
stack.quality             -- string (Space Age)
stack.durability          -- number (for tools)
stack.ammo                -- number (for ammo items)
stack.health              -- number (for items with health)
stack.is_blueprint        -- boolean
stack.is_blueprint_book   -- boolean
stack.is_item_with_label  -- boolean
stack.is_item_with_tags   -- boolean
stack.is_item_with_inventory -- boolean

-- Operations
stack.set_stack({name = "iron-plate", count = 100})
stack.transfer_to(target_inventory, slot_index)
stack.can_set_stack({name = "iron-plate", count = 50})
stack.clear()
stack.peek()  -- returns stack without removing
```

## LuaNotificationQueue — Notifications (2.1+)

```lua
-- Create a notification queue (2.1+)
local queue = script.new_notification_queue()

-- Use to manage custom player notifications
-- See LuaNotificationQueue in official docs for full API
-- Verify at: https://lua-api.factorio.com/latest/
```

## LuaPin — Map Pins (2.1.10+)

```lua
-- Add a pin (now returns LuaPin since 2.1.10)
local pin = player.add_pin({
  icon = {type = "item", name = "iron-plate"},
  position = {x = 100, y = 200},
  surface = game.surfaces["nauvis"],
})

-- Get all pins
local pins = player.get_pins()  -- returns array of LuaPin

-- Clear all pins
player.clear_pins()

-- LuaPin properties and methods — see official docs
-- Verify at: https://lua-api.factorio.com/latest/
```

## LuaControlBehavior — Circuit Control (2.1+)

```lua
local behavior = entity.get_control_behavior()
if behavior then
  -- 2.1 additions
  behavior.input_networks   -- read/write: input circuit networks (2.1+)
  behavior.output_networks  -- read/write: output circuit networks (2.1+)

  -- Logistic container (2.1+ — circuit_exclusive_mode_of_operation REMOVED)
  -- Use set_requests and read_contents together:
  behavior.set_requests = true
  behavior.read_contents = true
end
```
