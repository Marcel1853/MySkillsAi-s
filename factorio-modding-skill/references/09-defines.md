# Defines Reference (Factorio 2.1)

> **⚠️ Version-Hinweis:** Stand Factorio 2.1.11 experimental. Bei Unsicherheit über aktuelle defines IMMER gegen die offizielle Doku verifizieren: [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/). Factorio 2.1 ist experimental und ändert sich wöchentlich. Insbesondere `defines.control_behavior` und `defines.entity_status` wurden in 2.1 stark erweitert.

## Table of Contents

- [defines.events](#defines.events)
  - [Player](#player)
  - [Build / Mine](#build-/-mine)
  - [Entity](#entity)
  - [Chunk / Surface](#chunk-/-surface)
  - [Space Space Age](#space-space-age)
  - [GUI](#gui)
  - [Combat / AI](#combat-/-ai)
  - [Research / Technology](#research-/-technology)
  - [Rocket](#rocket)
  - [Train](#train)
  - [Equipment](#equipment)
  - [Chart / Map](#chart-/-map)
  - [Other](#other)
- [defines.direction](#defines.direction)
- [defines.inventory](#defines.inventory)
- [defines.wire_type](#defines.wire_type)
- [defines.control_behavior](#defines.control_behavior)
- [defines.logistic_mode](#defines.logistic_mode)
- [defines.build_check_type](#defines.build_check_type)
- [defines.train_state](#defines.train_state)
- [defines.difficulty](#defines.difficulty)
- [defines.command](#defines.command)
- [defines.distraction](#defines.distraction)
- [defines.entity_status](#defines.entity_status)
- [defines.alert_type](#defines.alert_type)
- [defines.prototypes](#defines.prototypes)
- [defines.quality](#defines.quality)
- [defines.surface_property](#defines.surface_property)
- [defines.circuit_connector](#defines.circuit_connector)
- [defines.comparator](#defines.comparator)
- [Commonly Used Utility Constants](#commonly-used-utility-constants)

This document lists the most commonly used `defines.*` constants and enums in the Factorio 2.1 API.

## defines.events

All events that can be registered with `script.on_event()`.

### Player
```lua
defines.events.on_player_created
defines.events.on_player_joined_game
defines.events.on_player_left_game
defines.events.on_player_died
defines.events.on_player_respawned
defines.events.on_player_changed_position
defines.events.on_player_changed_surface
defines.events.on_player_driving_changed_state
defines.events.on_player_crafted_item
defines.events.on_player_mined_item
defines.events.on_player_mined_entity
defines.events.on_player_prepared_to_craft
defines.events.on_player_crafted_item
defines.events.on_player_quickbar_moved
defines.events.on_player_main_inventory_changed
defines.events.on_player_cursor_stack_changed
defines.events.on_player_ammo_inventory_changed
defines.events.on_player_armor_inventory_changed
defines.events.on_player_gun_inventory_changed
defines.events.on_player_selected_area
defines.events.on_player_dropped_item
defines.events.on_player_picked_up_item
defines.events.on_player_display_resolution_changed
defines.events.on_player_display_scale_changed
defines.events.on_runtime_mod_setting_changed
```

### Build / Mine
```lua
defines.events.on_built_entity
defines.events.on_pre_player_mined_item
defines.events.on_player_mined_entity
defines.events.on_player_mined_item
defines.events.on_robot_built_entity
defines.events.on_robot_mined_entity
defines.events.on_script_built_entity
defines.events.on_pre_entity_settings_pasted
defines.events.on_entity_settings_pasted
defines.events.on_cancelled_deconstruction
defines.events.on_cancelled_upgrade
```

### Entity
```lua
defines.events.on_entity_died
defines.events.on_entity_damaged
defines.events.on_entity_cloned
defines.events.on_entity_renamed
defines.events.on_entity_color_changed
defines.events.on_entity_spawned
defines.events.on_pre_entity_cloned
defines.events.on_pre_entity_destroyed
defines.events.on_entity_logistic_slot_changed
```

### Chunk / Surface
```lua
defines.events.on_chunk_generated
defines.events.on_chunk_deleted
defines.events.on_chunk_charted
defines.events.on_brush_cloned
defines.events.on_area_cloned
defines.events.on_surface_created
defines.events.on_surface_deleted
defines.events.on_surface_cleared
defines.events.on_surface_renamed
```

### Space (Space Age)
```lua
defines.events.on_cargo_pod_delivered_cargo
defines.events.on_cargo_pod_finished_ascending
defines.events.on_cargo_pod_finished_descending
defines.events.on_cargo_pod_started_ascending
defines.events.on_space_platform_changed_state
```

### GUI
```lua
defines.events.on_gui_click
defines.events.on_gui_text_changed
defines.events.on_gui_selection_state_changed
defines.events.on_gui_checked_state_changed
defines.events.on_gui_value_changed
defines.events.on_gui_confirmed
defines.events.on_gui_switched_tab
defines.events.on_gui_location_changed
defines.events.on_gui_elem_changed
defines.events.on_gui_opened
defines.events.on_gui_closed
defines.events.on_gui_hover
defines.events.on_gui_leave
defines.events.on_gui_selected_tab_changed
defines.events.on_gui_inventory_action  -- 2.1: new inventory GUI element event
```

### Combat / AI
```lua
defines.events.on_unit_added_to_group
defines.events.on_unit_group_created
defines.events.on_unit_removed_from_group
defines.events.on_unit_group_finished_gathering
defines.events.on_unit_attacked
defines.events.on_ai_command_completed
defines.events.on_biter_base_built
```

### Research / Technology
```lua
defines.events.on_research_started
defines.events.on_research_finished
defines.events.on_research_reversed
```

### Rocket
```lua
defines.events.on_rocket_launch_ordered
defines.events.on_rocket_launched
```

### Train
```lua
defines.events.on_train_created
defines.events.on_train_changed_state
defines.events.on_train_schedule_changed
```

### Equipment
```lua
defines.events.on_equipment_inserted
defines.events.on_equipment_removed
```

### Chart / Map
```lua
defines.events.on_chart_tag_added
defines.events.on_chart_tag_modified
defines.events.on_chart_tag_removed
```

### Other
```lua
defines.events.on_tick
defines.events.on_console_chat
defines.events.on_console_command
defines.events.on_cutscene_started
defines.events.on_cutscene_finished
defines.events.on_cutscene_cancelled
defines.events.on_cutscene_waypoint_reached
defines.events.on_market_item_purchased
defines.events.on_character_corpse_expired
defines.events.on_achievement_gained
defines.events.on_undo_applied
defines.events.on_script_trigger_effect
defines.events.on_script_raised_revive
defines.events.on_script_raised_built
defines.events.on_script_raised_destroy
defines.events.on_script_raised_set_tiles
defines.events.on_script_destroy_segmented_unit
defines.events.on_object_destroyed
```

---

## defines.direction

```lua
defines.direction.north      -- 0
defines.direction.northeast  -- 1  -- 2.0+: 8 directions now available
defines.direction.east       -- 2
defines.direction.southeast  -- 3
defines.direction.south      -- 4
defines.direction.southwest  -- 5
defines.direction.west       -- 6
defines.direction.northwest  -- 7
```

> **Migration note (2.0):** If mods stored direction values in storage before 2.0, they need to multiply by 2 to convert to the new 8-direction system.

---

## defines.inventory

> **⚠️ Stand: Factorio 2.1.11 experimental.** The `assembling_machine_*` and `furnace_*` values were replaced by unified `crafter_*` values in 2.0. Verify at [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/).

```lua
-- Character inventories
defines.inventory.character_main          -- Main character inventory
defines.inventory.character_guns          -- Gun slots
defines.inventory.character_ammo          -- Ammo slots
defines.inventory.character_armor         -- Armor slots
defines.inventory.character_trash         -- Trash slots
defines.inventory.character_vehicle       -- Vehicle slots

-- Unified crafter inventories (2.0+ — replaces assembling_machine_* and furnace_*)
defines.inventory.crafter_input           -- Input slots (assemblers, furnaces, etc.)
defines.inventory.crafter_output          -- Output slots
defines.inventory.crafter_modules         -- Module slots
defines.inventory.crafter_trash           -- Crafter trash slots (2.0+)

-- Lab inventories
defines.inventory.lab_input               -- Lab input (science packs)
defines.inventory.lab_modules             -- Lab module slots
defines.inventory.lab_trash               -- Lab trash slots (2.0+)

-- Fuel inventories
defines.inventory.fuel                    -- Fuel inventory (burner entities)
defines.inventory.burnt_result            -- Burnt fuel result

-- Chest/Container inventories
defines.inventory.chest                   -- Main chest inventory

-- Roboport inventories
defines.inventory.roboport_robot          -- Stationed robots
defines.inventory.roboport_material       -- Repair packs/materials

-- Robot inventories
defines.inventory.robot_cargo             -- Logistic/construction robot cargo
defines.inventory.robot_repair            -- Robot repair packs

-- Vehicle inventories
defines.inventory.car_trunk               -- Car storage
defines.inventory.car_ammo                -- Car ammo
defines.inventory.cargo_wagon             -- Cargo wagon

-- Other inventories
defines.inventory.beacon_modules          -- Beacon module slots
defines.inventory.turret_ammo             -- Turret ammo
defines.inventory.mining_drill_modules    -- Mining drill module slots
defines.inventory.rocket_silo_rocket      -- Rocket cargo
defines.inventory.rocket_silo_result      -- Rocket result
defines.inventory.item_main               -- Item-with-inventory main

-- Space Age inventories (2.0+)
defines.inventory.asteroid_collector_output  -- Asteroid collector (2.0+)
defines.inventory.linked_container_main      -- Linked container (2.0+)
defines.inventory.agricultural_tower_input   -- Agricultural tower input (2.0+)
defines.inventory.agricultural_tower_output  -- Agricultural tower output (2.0+)

-- ⚠️ REMOVED in 2.0+ (use crafter_* instead):
-- defines.inventory.assembling_machine_input   → crafter_input
-- defines.inventory.assembling_machine_output  → crafter_output
-- defines.inventory.assembling_machine_modules → crafter_modules
-- defines.inventory.furnace_source             → crafter_input
-- defines.inventory.furnace_result             → crafter_output
-- defines.inventory.furnace_modules            → crafter_modules
```

---

## defines.wire_type

```lua
defines.wire_type.red     -- Red wire
defines.wire_type.green   -- Green wire
```

---

## defines.control_behavior

> **⚠️ Stand: Factorio 2.1.11 experimental.** This section was significantly expanded in 2.1. Verify at [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/).

```lua
defines.control_behavior.disabled
defines.control_behavior.enable_disable
defines.control_behavior.set_threshold
defines.control_behavior.set_bar
defines.control_behavior.set_requests

-- ⚠️ REMOVED in 2.1:
-- defines.control_behavior.logistic_container.exclusive_mode
-- Use set_requests and read_contents on LuaLogisticContainerControlBehavior instead

-- 2.1: New circuit connection types for labs, pipes, boilers, etc.
-- See LuaControlBehavior::input_networks / output_networks in official docs
```

---

## defines.logistic_mode

```lua
defines.logistic_mode.none
defines.logistic_mode.storage
defines.logistic_mode.requester
defines.logistic_mode.active_provider
defines.logistic_mode.passive_provider
defines.logistic_mode.buffer
```

---

## defines.build_check_type

```lua
defines.build_check_type.manual_build
defines.build_check_type.ghost_build
defines.build_check_type.script_build
defines.build_check_type.robot_build
defines.build_check_type.script_build_ignore_ghost
```

---

## defines.train_state

```lua
defines.train_state.on_the_path
defines.train_state.wait_station
defines.train_state.manual_control
defines.train_state.manual_control_stop
defines.train_state.no_path
defines.train_state.no_schedule
defines.train_state.arrive_signal
defines.train_state.wait_signal
defines.train_state.path_lost
defines.train_state.destination_full  -- Station is full (train limit reached)
```

---

## defines.difficulty

```lua
defines.difficulty.easy
defines.difficulty.normal
defines.difficulty.hard
```

---

## defines.command

```lua
defines.command.compound
defines.command.attack
defines.command.build_base
defines.command.group
defines.command.wander
defines.command.go_to_location
defines.command.retreat
defines.command.stop
```

---

## defines.distraction

```lua
defines.distraction.none
defines.distraction.by_anything
defines.distraction.by_damage
defines.distraction.by_enemy
```

---

## defines.entity_status

> **⚠️ Stand: Factorio 2.1.11 experimental.** New statuses added in 2.1.0+.

```lua
defines.entity_status.working
defines.entity_status.normal
defines.entity_status.no_power
defines.entity_status.low_input
defines.entity_status.no_fuel
defines.entity_status.no_ammo
defines.entity_status.no_recipe
defines.entity_status.no_ingredients
defines.entity_status.disabled_by_control_behavior
defines.entity_status.disabled_by_script

-- 2.1 additions:
defines.entity_status.waiting_to_clear_drop_slots   -- 2.1.0+
defines.entity_status.too_far_from_pad_to_unload     -- 2.1.0+
defines.entity_status.waiting_for_upgrade            -- 2.1.0+
defines.entity_status.armed                          -- 2.1.0+ (land mines)
```

---

## defines.alert_type

```lua
defines.alert_type.entity_destroyed
defines.alert_type.train_destination_unreachable
defines.alert_type.no_material_for_construction
defines.alert_type.killed_enemy
defines.alert_type.turret_fire
defines.alert_type.robot_completed
```

---

## defines.prototypes

```lua
defines.prototypes.achievement
defines.prototypes.accumulator
defines.prototypes.ammo_category
defines.prototypes.ammo_turret
defines.prototypes.arithmetic_combinator
defines.prototypes.armor
defines.prototypes.assembling_machine
defines.prototypes.asteroid_chunk
defines.prototypes.asteroid
defines.prototypes.battery_equipment
defines.prototypes.beacon
defines.prototypes.beam
defines.prototypes.boiler
defines.prototypes.cargo_bay
defines.prototypes.cargo_landing_pad
defines.prototypes.character
defines.prototypes.combinator
defines.prototypes.container
defines.prototypes.custom_input
defines.prototypes.damage_type
defines.prototypes.decorative
defines.prototypes.entity_type
defines.prototypes.equipment_grid
defines.prototypes.fire
defines.prototypes.fluid
defines.prototypes.furnace
defines.prototypes.generator
defines.prototypes.gun
defines.prototypes.inserter
defines.prototypes.item
defines.prototypes.lab
defines.prototypes.logistic_container
defines.prototypes.mining_drill
defines.prototypes.module
defines.prototypes.planet
defines.prototypes.quality
defines.prototypes.radar
defines.prototypes.recipe
defines.prototypes.rocket_silo
defines.prototypes.space_connection
defines.prototypes.space_location
defines.prototypes.space_platform_hub
defines.prototypes.surface
defines.prototypes.surface_property
defines.prototypes.technology
defines.prototypes.thruster
defines.prototypes.tile
defines.prototypes.tool
defines.prototypes.turret
```

---

## defines.quality

```lua
defines.quality.normal       -- Level 0
defines.quality.uncommon     -- Level 1
defines.quality.rare         -- Level 2
defines.quality.epic         -- Level 3
defines.quality.legendary    -- Level 4
```

---

## defines.surface_property

```lua
defines.surface_property.day_night_cycle
defines.surface_property.magnetic_field
defines.surface_property.solar_power
defines.surface_property.pressure
defines.surface_property.gravity
```

---

## defines.circuit_connector

```lua
defines.circuit_connector.combinator_input
defines.circuit_connector.combinator_output
defines.circuit_connector.constant_combinator
```

---

## defines.comparator

```lua
defines.comparator.less              -- <
defines.comparator.less_or_equal     -- <=
defines.comparator.equal             -- =
defines.comparator.greater_or_equal  -- >=
defines.comparator.greater           -- >
defines.comparator.not_equal         -- ≠ (2.0+)
```

---

## Programmable Speaker Playback Mode Change (2.1.10)

> **⚠️ BREAKING RENAME in 2.1.10:** The Programmable Speaker playback mode `Global` has been renamed to `Universe`. If your mod references `"Global"` for programmable speaker playback, update it to `"Universe"`.

---

## Commonly Used Utility Constants

```lua
-- Time
tick = game.tick
minute = 60  -- ticks
second = 60  -- ticks

-- Position format
position = {x = 10, y = 20}
area = {{left_top_x, left_top_y}, {right_bottom_x, right_bottom_y}}

-- Color format
color = {r = 1, g = 0, b = 0, a = 1}  -- RGB(A) 0-1
color = {1, 0, 0}  -- RGB 0-1 shorthand

-- Signal format
signal = {type = "item", name = "iron-plate"}
signal = {type = "fluid", name = "water"}
signal = {type = "virtual", name = "signal-A"}
signal = {type = "entity", name = "assembling-machine-2"}
-- 2.1: additional signal types available (quality, airborne-pollutant, etc.)

-- Quality in signal (2.1+)
signal = {type = "item", name = "iron-plate", quality = "rare"}
```
