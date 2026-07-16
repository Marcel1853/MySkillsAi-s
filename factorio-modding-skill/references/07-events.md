# Events Reference (Factorio 2.1)

> **⚠️ Version-Hinweis:** Stand Factorio 2.1.11 experimental. Bei Unsicherheit über aktuelle Events IMMER gegen die offizielle Doku verifizieren: [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/). Factorio 2.1 (experimental) ändert sich wöchentlich. Wichtige 2.1-Neuerung: `on_gui_inventory_action` Event für neue `"inventory"` GUI-Elemente.

Events are the primary way mods react to game actions. Register handlers with `script.on_event()`.

## Event Registration

```lua
-- Single event
script.on_event(defines.events.on_built_entity, function(event)
  -- handle it
end)

-- Multiple events
script.on_event({
  defines.events.on_player_mined_entity,
  defines.events.on_robot_mined_entity,
}, function(event)
  -- handle both
end)

-- String event name (2.0 feature)
script.on_event("on_built_entity", function(event)
  -- same as above, using string name
end)

-- Nth tick
script.on_nth_tick(60, function(event)
  -- runs every 60 ticks
end)

-- Custom event
local my_event = script.generate_event_name()
script.on_event(my_event, function(event)
  -- custom event handler
end)
script.raise_event(my_event, {data = "payload"})
```

## Key Events

### Player Events

| Event | Description | Key Fields |
|-------|-------------|------------|
| `on_player_created` | New player joins the game | `player_index` |
| `on_player_joined_game` | Player loads into a save | `player_index` |
| `on_player_left_game` | Player disconnects | `player_index` |
| `on_player_died` | Player character dies | `player_index`, `cause` |
| `on_player_respawned` | Player respawns | `player_index` |
| `on_player_changed_position` | Player moves | `player_index`, `old_position`, `new_position` |
| `on_player_changed_surface` | Player changes surface | `player_index`, `old_surface_index`, `new_surface_index` |
| `on_player_driving_changed_state` | Player enters/exits vehicle | `player_index`, `entity`, `entered` |
| `on_player_crafted_item` | Player crafts something | `player_index`, `item`, `recipe`, `crafting_machine` |
| `on_player_mined_item` | Player mines an item (pickup) | `player_index`, `item`, `entity` |
| `on_player_quickbar_moved` | Quickbar slot changed | `player_index`, `slot_index`, `item` |
| `on_player_main_inventory_changed` | Inventory changed | `player_index` |
| `on_player_selected_area` | Player selects an area | `player_index`, `item`, `entities` |
| `on_player_dropped_item` | Player drops items | `player_index`, `item`, `position` |
| `on_player_picked_up_item` | Player picks up items | `player_index`, `item`, `inventory` |
| `on_player_ammo_inventory_changed` | Ammo inventory changed | `player_index` |
| `on_player_armor_inventory_changed` | Armor inventory changed | `player_index` |
| `on_player_gun_inventory_changed` | Gun inventory changed | `player_index` |

### Build/Mine Events

| Event | Description | Key Fields |
|-------|-------------|------------|
| `on_built_entity` | Player builds an entity | `entity`, `player_index`, `item`, `tags` |
| `on_pre_player_mined_item` | Player is about to mine | `entity`, `player_index`, `item` |
| `on_player_mined_entity` | Player mined an entity | `entity`, `player_index`, `item` |
| `on_player_mined_item` | Player picked up a mined item | `item`, `player_index` |
| `on_robot_built_entity` | Construction robot built | `entity`, `robot`, `player_index` |
| `on_robot_mined_entity` | Construction robot mined | `entity`, `robot`, `player_index` |
| `on_script_built_entity` | Script built entity | `entity` |
| `on_pre_entity_settings_pasted` | Before settings paste | `source`, `destination`, `player_index` |
| `on_entity_settings_pasted` | After settings paste | `source`, `destination`, `player_index` |
| `on_cancelled_deconstruction` | Deconstruction cancelled | `entity`, `player_index` |
| `on_cancelled_upgrade` | Upgrade cancelled | `entity`, `player_index` |

### Entity Events

| Event | Description | Key Fields |
|-------|-------------|------------|
| `on_entity_died` | Entity died | `entity`, `cause`, `damage_type` |
| `on_entity_damaged` | Entity took damage | `entity`, `damage`, `damage_type`, `source`, `cause` |
| `on_entity_cloned` | Entity was cloned | `source`, `destination`, `old_surface`, `new_surface` |
| `on_entity_renamed` | Entity renamed | `entity`, `player_index`, `old_name`, `new_name` |
| `on_entity_color_changed` | Entity recolored | `entity`, `player_index` |
| `on_entity_spawned` | Enemy spawned | `entity`, `spawner` |
| `on_pre_entity_cloned` | Before entity clone | `source` |
| `on_pre_entity_destroyed` | Before entity destroyed | `entity` |
| `on_entity_logistic_slot_changed` | Logistic slot changed | `entity`, `slot_index` |

### Chunk/Tile Events

| Event | Description | Key Fields |
|-------|-------------|------------|
| `on_chunk_generated` | New chunk created | `surface_index`, `position`, `area` |
| `on_chunk_deleted` | Chunk deleted | `surface_index`, `position`, `area` |
| `on_chunk_charted` | Chunk revealed on map | `surface_index`, `position`, `force` |
| `on_brush_cloned` | Area brush cloned | `source_surface`, `destination_surface`, `area` |
| `on_area_cloned` | Area cloned | `source`, `destination` |
| `on_surface_created` | New surface created | `surface_index` |
| `on_surface_deleted` | Surface deleted | `surface_index` |
| `on_surface_cleared` | Surface cleared (all removed) | `surface_index` |
| `on_surface_renamed` | Surface renamed | `surface_index`, `old_name`, `new_name` |
| `on_tile_built` | Tile placed | `tile`, `player_index`, `old_tile` |
| `on_tiles_destroyed` | Tiles destroyed | `surface_index`, `tiles` |

### Combat Events

| Event | Description | Key Fields |
|-------|-------------|------------|
| `on_entity_damaged` | Entity damaged | `entity`, `damage`, `source`, `cause` |
| `on_entity_died` | Entity died | `entity`, `cause` |
| `on_biter_base_built` | Enemy base built | `entity` |
| `on_unit_added_to_group` | Unit joined group | `unit_number`, `group_id` |
| `on_unit_group_created` | New unit group | `group_id` |
| `on_unit_removed_from_group` | Unit left group | `unit_number`, `group_id` |
| `on_unit_group_finished_gathering` | Group finished gathering | `group_id` |
| `on_unit_attacked` | Unit attacked | `unit_number`, `target` |

### Logistics Events

| Event | Description | Key Fields |
|-------|-------------|------------|
| `on_logistic_section_changed` | Logistic network changed | `logistic_section` |
| `on_entity_logistic_slot_changed` | Container slot changed | `entity`, `slot_index` |
| `on_item_imported` | Item imported via cargo pod | `item_stack`, `cargo_pod`, `surface_index` |

### Space Events (Space Age)

| Event | Description | Key Fields |
|-------|-------------|------------|
| `on_cargo_pod_delivered_cargo` | Cargo pod delivered | `cargo_pod`, `cargo_items`, `surface_index` |
| `on_cargo_pod_finished_ascending` | Cargo pod left surface | `cargo_pod`, `surface_index` |
| `on_cargo_pod_finished_descending` | Cargo pod landed | `cargo_pod`, `surface_index`, `target` |
| `on_cargo_pod_started_ascending` | Cargo pod departed | `cargo_pod`, `surface_index` |
| `on_space_platform_changed_state` | Platform state changed | `space_platform`, `old_state`, `new_state` |

### Rocket Events

| Event | Description | Key Fields |
|-------|-------------|------------|
| `on_rocket_launch_ordered` | Rocket launch initiated | `rocket_silo_entity`, `player_index` |
| `on_rocket_launched` | Rocket actually launched | `rocket_silo_entity`, `rocket`, `player_index` |

### Train Events

| Event | Description | Key Fields |
|-------|-------------|------------|
| `on_train_created` | New train assembled | `train`, `old_train_id_1`, `old_train_id_2` |
| `on_train_changed_state` | Train state changed | `train`, `old_state`, `new_state` |
| `on_train_schedule_changed` | Schedule modified | `train`, `player_index` |

### GUI Events

| Event | Description | Key Fields |
|-------|-------------|------------|
| `on_gui_click` | GUI element clicked | `element`, `player_index` |
| `on_gui_text_changed` | Text changed in input | `element`, `player_index`, `text` |
| `on_gui_selection_state_changed` | Selection changed | `element`, `player_index` |
| `on_gui_checked_state_changed` | Checkbox changed | `element`, `player_index` |
| `on_gui_value_changed` | Slider/progress changed | `element`, `player_index` |
| `on_gui_confirmed` | Enter pressed in textfield | `element`, `player_index` |
| `on_gui_switched_tab` | Tab changed | `element`, `player_index`, `tab` |
| `on_gui_location_changed` | Scroll/camera moved | `element`, `player_index` |
| `on_gui_elem_changed` | Element picker changed | `element`, `player_index` |
| `on_gui_opened` | Custom GUI opened | `element`, `player_index` |
| `on_gui_closed` | Custom GUI closed | `element`, `player_index` |
| `on_gui_hover` | Mouse entered element | `element`, `player_index` |
| `on_gui_leave` | Mouse left element | `element`, `player_index` |
| `on_gui_selected_tab_changed` | Tab selected | `element`, `player_index` |
| `on_gui_inventory_action` | Inventory GUI interaction (2.1+) | `element`, `player_index` |

### Research Events

| Event | Description | Key Fields |
|-------|-------------|------------|
| `on_research_started` | Research began | `force`, `technology` |
| `on_research_finished` | Research completed | `force`, `technology`, `player_index` |
| `on_research_reversed` | Research undone | `force`, `technology` |

### Script Events

| Event | Description | Key Fields |
|-------|-------------|------------|
| `on_script_trigger_effect` | Script triggered effect | `effect_id`, `source_entity` |
| `on_script_raised_revive` | Script revived entity | `entity`, `tags` |
| `on_script_raised_built` | Script built entity | `entity`, `player_index` |
| `on_script_raised_destroy` | Script destroyed entity | `entity` |
| `on_script_raised_set_tiles` | Script set tiles | `tiles`, `surface_index` |
| `on_script_destroy_segmented_unit` | Segmented unit destroyed | `segmented_unit` |

### Other Events

| Event | Description | Key Fields |
|-------|-------------|------------|
| `on_tick` | Every game tick (60/sec) | `tick` |
| `on_console_command` | Console command entered | `player_index`, `command`, `parameters` |
| `on_console_chat` | Chat message | `player_index`, `message` |
| `on_cutscene_started` | Cutscene began | `player_index` |
| `on_cutscene_finished` | Cutscene ended | `player_index` |
| `on_cutscene_cancelled` | Cutscene cancelled | `player_index` |
| `on_cutscene_waypoint_reached` | Cutscene waypoint hit | `player_index` |
| `on_player_display_resolution_changed` | Resolution changed | `player_index` |
| `on_player_display_scale_changed` | UI scale changed | `player_index` |
| `on_runtime_mod_setting_changed` | Setting changed | `player_index`, `setting` |
| `on_market_item_purchased` | Market purchase | `player_index`, `market`, `item`, `count` |
| `on_chart_tag_added` | Map tag added | `player_index`, `tag` |
| `on_chart_tag_modified` | Map tag changed | `player_index`, `tag` |
| `on_chart_tag_removed` | Map tag removed | `player_index`, `tag` |
| `on_equipment_inserted` | Equipment added | `equipment`, `player_index`, `grid` |
| `on_equipment_removed` | Equipment removed | `equipment`, `player_index`, `grid` |
| `on_character_corpse_expired` | Corpse expired | `character_corpse` |
| `on_achievement_gained` | Achievement earned | `player_index`, `achievement` |
| `on_undo_applied` | Undo performed | `player_index` |
| `on_player_cursor_stack_changed` | Cursor item changed | `player_index`, `item` |
| `on_object_destroyed` | Tracked object destroyed | `object_id`, `cause` |

## Event Filters

```lua
-- Filter on_built_entity to only specific entity names
script.on_event(defines.events.on_built_entity, function(event)
  -- handler
end, {{filter = "name", name = "assembling-machine-3"}})

-- Filter on_entity_damaged to only specific damage types
script.on_event(defines.events.on_entity_damaged, function(event)
  -- handler
end, {{filter = "damage_type", damage_type = "fire"}})

-- Filter on_player_crafted_item to specific items
script.on_event(defines.events.on_player_crafted_item, function(event)
  -- handler
end, {{filter = "item", name = "my-item"}})
```

## Custom Events

```lua
-- Generate a unique event name
local my_event = script.generate_event_name()

-- Register handler
script.on_event(my_event, function(event)
  game.print("Custom event received: " .. serpent.block(event))
end)

-- Raise the event
script.raise_event(my_event, {
  player_index = 1,
  custom_data = "hello",
})

-- Raise using string name (2.0)
script.raise_event("my-custom-event", {data = "payload"})
```
