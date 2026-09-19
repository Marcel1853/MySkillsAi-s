# Factorio API: defines (aus der offiziellen Doku erzeugt)

> **Automatisch erzeugt** mit `scripts/gen_defines_reference.py` aus https://lua-api.factorio.com/latest/defines.html
> (API-Version 2.1.19, Stand 2026-09-19). Nicht von Hand ergänzen – neu erzeugen.
> Hinweise zu oft falsch benutzten Tabellen stehen jeweils direkt unter der Überschrift.

## Häufig erfunden – gibt es NICHT als defines

| Oft geschrieben | Richtig |
|---|---|
| `defines.comparator.less` usw. | Vergleiche sind Text: `"<"`, `">"`, `"="`, `"≥"`/`">="`, `"≤"`/`"<="`, `"≠"`/`"!="` (ComparatorString) |
| `defines.quality.*` | Qualitäten sind Prototypen: `prototypes.quality["rare"]`, in Signalen/Items per Name `quality = "rare"` |
| `defines.surface_property.*` | Oberflächen-Eigenschaften sind Prototypen: `prototypes.surface_property["gravity"]`, Wert: `surface.get_property("gravity")` |
| `defines.circuit_connector.*` | `defines.wire_connector_id.*` |
| `defines.events.on_script_raised_built` | `defines.events.script_raised_built` |
| `defines.inventory.assembling_machine_input`, `furnace_source` | `defines.inventory.crafter_input` usw. |
| `defines.train_state.path_lost` | `defines.train_state.no_path` |

## Inhalt

[alert_type](#definesalert_type) · [behavior_result](#definesbehavior_result) · [build_check_type](#definesbuild_check_type) · [build_mode](#definesbuild_mode) · [cargo_destination](#definescargo_destination) · [chain_signal_state](#defineschain_signal_state) · [chunk_generated_status](#defineschunk_generated_status) · [command](#definescommand) · [compound_command](#definescompound_command) · [constant](#definesconstant) · [control_behavior](#definescontrol_behavior) · [controllers](#definescontrollers) · [deconstruction_item](#definesdeconstruction_item) · [difficulty](#definesdifficulty) · [direction](#definesdirection) · [disconnect_reason](#definesdisconnect_reason) · [distraction](#definesdistraction) · [electric_interface_mode](#defineselectric_interface_mode) · [entity_status](#definesentity_status) · [entity_status_diode](#definesentity_status_diode) · [events](#definesevents) · [flow_precision_index](#definesflow_precision_index) · [game_controller_interaction](#definesgame_controller_interaction) · [group_state](#definesgroup_state) · [gui_type](#definesgui_type) · [input_action](#definesinput_action) · [input_method](#definesinput_method) · [inventory](#definesinventory) · [inventory_actions](#definesinventory_actions) · [logistic_group_type](#defineslogistic_group_type) · [logistic_member_index](#defineslogistic_member_index) · [logistic_mode](#defineslogistic_mode) · [logistic_section_type](#defineslogistic_section_type) · [mouse_button_type](#definesmouse_button_type) · [moving_state](#definesmoving_state) · [print_skip](#definesprint_skip) · [print_sound](#definesprint_sound) · [prototypes](#definesprototypes) · [rail_connection_direction](#definesrail_connection_direction) · [rail_direction](#definesrail_direction) · [rail_layer](#definesrail_layer) · [relative_gui_position](#definesrelative_gui_position) · [relative_gui_type](#definesrelative_gui_type) · [render_mode](#definesrender_mode) · [rich_text_setting](#definesrich_text_setting) · [riding](#definesriding) · [robot_order_type](#definesrobot_order_type) · [rocket_silo_status](#definesrocket_silo_status) · [segmented_unit_activity_mode](#definessegmented_unit_activity_mode) · [segmented_unit_ai_state](#definessegmented_unit_ai_state) · [segmented_unit_created_cause](#definessegmented_unit_created_cause) · [selection_mode](#definesselection_mode) · [shooting](#definesshooting) · [signal_state](#definessignal_state) · [space_platform_state](#definesspace_platform_state) · [target_type](#definestarget_type) · [territory_created_cause](#definesterritory_created_cause) · [train_state](#definestrain_state) · [transport_line](#definestransport_line) · [wire_connector_id](#defineswire_connector_id) · [wire_origin](#defineswire_origin) · [wire_type](#defineswire_type)

## defines.alert_type

| Wert | Bedeutung |
|---|---|
| `defines.alert_type.collector_path_blocked` |  |
| `defines.alert_type.custom` |  |
| `defines.alert_type.entity_destroyed` |  |
| `defines.alert_type.entity_under_attack` |  |
| `defines.alert_type.expansion_base_built` |  |
| `defines.alert_type.fluid_mixing` |  |
| `defines.alert_type.no_material_for_construction` |  |
| `defines.alert_type.no_platform_storage` |  |
| `defines.alert_type.no_roboport_storage` |  |
| `defines.alert_type.no_storage` |  |
| `defines.alert_type.not_enough_construction_robots` |  |
| `defines.alert_type.not_enough_repair_packs` |  |
| `defines.alert_type.pipeline_overextended` |  |
| `defines.alert_type.platform_tile_building_blocked` |  |
| `defines.alert_type.train_no_path` |  |
| `defines.alert_type.train_out_of_fuel` |  |
| `defines.alert_type.turret_fire` |  |
| `defines.alert_type.turret_out_of_ammo` |  |
| `defines.alert_type.unclaimed_cargo` |  |

## defines.behavior_result

| Wert | Bedeutung |
|---|---|
| `defines.behavior_result.in_progress` |  |
| `defines.behavior_result.fail` |  |
| `defines.behavior_result.success` |  |
| `defines.behavior_result.deleted` |  |

## defines.build_check_type

| Wert | Bedeutung |
|---|---|
| `defines.build_check_type.script` |  |
| `defines.build_check_type.manual` |  |
| `defines.build_check_type.manual_ghost` |  |
| `defines.build_check_type.script_ghost` |  |
| `defines.build_check_type.blueprint_ghost` |  |
| `defines.build_check_type.ghost_revive` |  |

## defines.build_mode

| Wert | Bedeutung |
|---|---|
| `defines.build_mode.normal` |  |
| `defines.build_mode.forced` |  |
| `defines.build_mode.superforced` |  |

## defines.cargo_destination

| Wert | Bedeutung |
|---|---|
| `defines.cargo_destination.invalid` | The default destination type of a cargo pod when created runtime. |
| `defines.cargo_destination.orbit` | Cargo pods with orbit destination are destroyed when ascent is completed. |
| `defines.cargo_destination.station` | Any cargo landing pad or space platform hub. |
| `defines.cargo_destination.surface` | Cargo pods will switch destination type from surface to station before starting descent if there is a station available and CargoDestination::position has not been specified. |
| `defines.cargo_destination.space_platform` | Only used for sending a space platform starter pack to a platform that is waiting for one. |

## defines.chain_signal_state

| Wert | Bedeutung |
|---|---|
| `defines.chain_signal_state.none` |  |
| `defines.chain_signal_state.all_open` |  |
| `defines.chain_signal_state.partially_open` |  |
| `defines.chain_signal_state.none_open` |  |

## defines.chunk_generated_status

| Wert | Bedeutung |
|---|---|
| `defines.chunk_generated_status.nothing` |  |
| `defines.chunk_generated_status.custom_tiles` |  |
| `defines.chunk_generated_status.basic_tiles` |  |
| `defines.chunk_generated_status.corrected_tiles` |  |
| `defines.chunk_generated_status.tiles` |  |
| `defines.chunk_generated_status.entities` |  |

## defines.command

| Wert | Bedeutung |
|---|---|
| `defines.command.attack` | Attack another entity. |
| `defines.command.go_to_location` | Go to a specific position. |
| `defines.command.compound` | Chain commands together, see defines.compound_command . |
| `defines.command.group` | Do what your group wants you to do. |
| `defines.command.attack_area` | Go to a place and attack what you see. |
| `defines.command.wander` | Chill. |
| `defines.command.flee` | Flee from another entity. |
| `defines.command.stop` | Stop moving and stay where you are. |
| `defines.command.build_base` | Go to a position and build a base there. |

## defines.compound_command

| Wert | Bedeutung |
|---|---|
| `defines.compound_command.logical_and` | Fail on first failure. |
| `defines.compound_command.logical_or` | Succeed on first success. |
| `defines.compound_command.return_last` | Execute all commands in sequence and fail or succeed depending on the return status of the last command. |

## defines.constant

| Wert | Bedeutung |
|---|---|
| `defines.constant.default_icon_size` |  |

## defines.control_behavior

> Enthält nur Unter-Tabellen für einzelne Entity-Typen; Einstellungen wie „aktivieren/deaktivieren“ stehen am jeweiligen `Lua*ControlBehavior`-Objekt, nicht in defines.

| Wert | Bedeutung |
|---|---|
| `defines.control_behavior.inserter.hand_read_mode.hold` |  |
| `defines.control_behavior.inserter.hand_read_mode.pulse` |  |
| `defines.control_behavior.lamp.color_mode.color_mapping` |  |
| `defines.control_behavior.lamp.color_mode.components` |  |
| `defines.control_behavior.lamp.color_mode.packed_rgb` |  |
| `defines.control_behavior.mining_drill.resource_read_mode.this_miner` |  |
| `defines.control_behavior.mining_drill.resource_read_mode.entire_patch` |  |
| `defines.control_behavior.transport_belt.content_read_mode.pulse` |  |
| `defines.control_behavior.transport_belt.content_read_mode.hold` |  |
| `defines.control_behavior.transport_belt.content_read_mode.entire_belt_hold` |  |
| `defines.control_behavior.rocket_silo.read_mode.none` |  |
| `defines.control_behavior.rocket_silo.read_mode.logistic_inventory` |  |
| `defines.control_behavior.rocket_silo.read_mode.orbital_requests` |  |
| `defines.control_behavior.roboport.read_items_mode.none` |  |
| `defines.control_behavior.roboport.read_items_mode.logistics` |  |
| `defines.control_behavior.roboport.read_items_mode.missing_requests` |  |
| `defines.control_behavior.single_fluid_box.exclusive_mode.none` |  |
| `defines.control_behavior.single_fluid_box.exclusive_mode.send_contents` |  |
| `defines.control_behavior.single_fluid_box.exclusive_mode.send_segment_contents` |  |
| `defines.control_behavior.radar.mode.surface` |  |
| `defines.control_behavior.radar.mode.universe` |  |
| `defines.control_behavior.type.container` | LuaContainerControlBehavior |
| `defines.control_behavior.type.generic_on_off` | LuaGenericOnOffControlBehavior |
| `defines.control_behavior.type.inserter` | LuaInserterControlBehavior |
| `defines.control_behavior.type.lamp` | LuaLampControlBehavior |
| `defines.control_behavior.type.logistic_container` | LuaLogisticContainerControlBehavior |
| `defines.control_behavior.type.roboport` | LuaRoboportControlBehavior |
| `defines.control_behavior.type.single_fluid_box` | LuaSingleFluidBoxControlBehavior |
| `defines.control_behavior.type.train_stop` | LuaTrainStopControlBehavior |
| `defines.control_behavior.type.decider_combinator` | LuaDeciderCombinatorControlBehavior |
| `defines.control_behavior.type.arithmetic_combinator` | LuaArithmeticCombinatorControlBehavior |
| `defines.control_behavior.type.constant_combinator` | LuaConstantCombinatorControlBehavior |
| `defines.control_behavior.type.transport_belt` | LuaTransportBeltControlBehavior |
| `defines.control_behavior.type.accumulator` | LuaAccumulatorControlBehavior |
| `defines.control_behavior.type.rail_signal` | LuaRailSignalBaseControlBehavior |
| `defines.control_behavior.type.rail_chain_signal` | LuaRailSignalBaseControlBehavior |
| `defines.control_behavior.type.wall` | LuaWallControlBehavior |
| `defines.control_behavior.type.mining_drill` | LuaMiningDrillControlBehavior |
| `defines.control_behavior.type.programmable_speaker` | LuaProgrammableSpeakerControlBehavior |
| `defines.control_behavior.type.assembling_machine` | LuaAssemblingMachineControlBehavior |
| `defines.control_behavior.type.pump` | LuaPumpControlBehavior |
| `defines.control_behavior.type.selector_combinator` | LuaSelectorCombinatorControlBehavior |
| `defines.control_behavior.type.rocket_silo` | LuaRocketSiloControlBehavior |
| `defines.control_behavior.type.turret` | LuaTurretControlBehavior |
| `defines.control_behavior.type.reactor` | LuaReactorControlBehavior |
| `defines.control_behavior.type.space_platform_hub` | LuaSpacePlatformHubControlBehavior |
| `defines.control_behavior.type.artillery_turret` | LuaArtilleryTurretControlBehavior |
| `defines.control_behavior.type.asteroid_collector` | LuaAsteroidCollectorControlBehavior |
| `defines.control_behavior.type.radar` | LuaRadarControlBehavior |
| `defines.control_behavior.type.display_panel` | LuaDisplayPanelControlBehavior |
| `defines.control_behavior.type.loader` | LuaLoaderControlBehavior |
| `defines.control_behavior.type.cargo_landing_pad` | LuaCargoLandingPadControlBehavior |
| `defines.control_behavior.type.agricultural_tower` | LuaAgriculturalTowerControlBehavior |
| `defines.control_behavior.type.furnace` | LuaFurnaceControlBehavior |
| `defines.control_behavior.type.proxy_container` | LuaProxyContainerControlBehavior |
| `defines.control_behavior.type.splitter` | LuaSplitterControlBehavior |
| `defines.control_behavior.type.lab` | LuaLabControlBehavior |
| `defines.control_behavior.type.heat_pipe` | LuaHeatPipeControlBehavior |
| `defines.control_behavior.type.boiler` | LuaBoilerControlBehavior |
| `defines.control_behavior.type.land_mine` | LuaLandMineControlBehavior |

## defines.controllers

| Wert | Bedeutung |
|---|---|
| `defines.controllers.ghost` | Can't interact with the world, can only observe. |
| `defines.controllers.character` | The controller controls a character. |
| `defines.controllers.god` | The controller isn't tied to a character. |
| `defines.controllers.editor` | The Editor Controller near ultimate power to do almost anything in the game. |
| `defines.controllers.cutscene` | The player can't interact with the world, and the camera pans around in a predefined manner. |
| `defines.controllers.spectator` | Can't change anything in the world but can view anything. |
| `defines.controllers.remote` | Can't move/change items but can build ghosts/change settings. |

## defines.deconstruction_item

| Wert | Bedeutung |
|---|---|
| `defines.deconstruction_item.entity_filter_mode.whitelist` |  |
| `defines.deconstruction_item.entity_filter_mode.blacklist` |  |
| `defines.deconstruction_item.tile_filter_mode.whitelist` |  |
| `defines.deconstruction_item.tile_filter_mode.blacklist` |  |
| `defines.deconstruction_item.tile_selection_mode.normal` |  |
| `defines.deconstruction_item.tile_selection_mode.always` |  |
| `defines.deconstruction_item.tile_selection_mode.never` |  |
| `defines.deconstruction_item.tile_selection_mode.only` |  |

## defines.difficulty

| Wert | Bedeutung |
|---|---|
| `defines.difficulty.easy` |  |
| `defines.difficulty.normal` |  |
| `defines.difficulty.hard` |  |

## defines.direction

| Wert | Bedeutung |
|---|---|
| `defines.direction.north` |  |
| `defines.direction.northnortheast` |  |
| `defines.direction.northeast` |  |
| `defines.direction.eastnortheast` |  |
| `defines.direction.east` |  |
| `defines.direction.eastsoutheast` |  |
| `defines.direction.southeast` |  |
| `defines.direction.southsoutheast` |  |
| `defines.direction.south` |  |
| `defines.direction.southsouthwest` |  |
| `defines.direction.southwest` |  |
| `defines.direction.westsouthwest` |  |
| `defines.direction.west` |  |
| `defines.direction.westnorthwest` |  |
| `defines.direction.northwest` |  |
| `defines.direction.northnorthwest` |  |

## defines.disconnect_reason

| Wert | Bedeutung |
|---|---|
| `defines.disconnect_reason.quit` |  |
| `defines.disconnect_reason.dropped` |  |
| `defines.disconnect_reason.reconnect` |  |
| `defines.disconnect_reason.wrong_input` |  |
| `defines.disconnect_reason.desync_limit_reached` |  |
| `defines.disconnect_reason.cannot_keep_up` |  |
| `defines.disconnect_reason.afk` |  |
| `defines.disconnect_reason.kicked` |  |
| `defines.disconnect_reason.kicked_and_deleted` |  |
| `defines.disconnect_reason.banned` |  |
| `defines.disconnect_reason.switching_servers` |  |

## defines.distraction

| Wert | Bedeutung |
|---|---|
| `defines.distraction.none` | Perform command even if someone attacks the unit. |
| `defines.distraction.by_enemy` | Attack closer enemy entities with force. |
| `defines.distraction.by_anything` | Attack closer enemy entities, including entities "built" by player (belts, inserters, chests). |
| `defines.distraction.by_damage` | Attack when attacked. |

## defines.electric_interface_mode

| Wert | Bedeutung |
|---|---|
| `defines.electric_interface_mode.solar_output` |  |
| `defines.electric_interface_mode.primary_output` |  |
| `defines.electric_interface_mode.secondary_output` |  |
| `defines.electric_interface_mode.tertiary_output` |  |
| `defines.electric_interface_mode.primary_input` |  |
| `defines.electric_interface_mode.secondary_input` |  |
| `defines.electric_interface_mode.tertiary_input` |  |
| `defines.electric_interface_mode.tertiary_input_output` |  |
| `defines.electric_interface_mode.accumulator` |  |

## defines.entity_status

| Wert | Bedeutung |
|---|---|
| `defines.entity_status.working` |  |
| `defines.entity_status.normal` |  |
| `defines.entity_status.ghost` | Used by ghosts. |
| `defines.entity_status.broken` | Only used if set through ContainerPrototype::default_status . |
| `defines.entity_status.no_power` |  |
| `defines.entity_status.low_power` |  |
| `defines.entity_status.no_fuel` |  |
| `defines.entity_status.frozen` |  |
| `defines.entity_status.disabled_by_control_behavior` |  |
| `defines.entity_status.opened_by_circuit_network` |  |
| `defines.entity_status.closed_by_circuit_network` |  |
| `defines.entity_status.disabled_by_script` |  |
| `defines.entity_status.marked_for_deconstruction` |  |
| `defines.entity_status.paused` | Used by space platform hubs. |
| `defines.entity_status.not_plugged_in_electric_network` | Used by generators and solar panels. |
| `defines.entity_status.networks_connected` | Used by power switches. |
| `defines.entity_status.networks_disconnected` | Used by power switches. |
| `defines.entity_status.charging` | Used by accumulators. |
| `defines.entity_status.discharging` | Used by accumulators. |
| `defines.entity_status.fully_charged` | Used by accumulators. |
| `defines.entity_status.out_of_logistic_network` | Used by logistic containers. |
| `defines.entity_status.no_recipe` | Used by assembling machines. |
| `defines.entity_status.no_ingredients` | Used by furnaces. |
| `defines.entity_status.no_input_fluid` | Used by boilers, fluid turrets, and fluid energy sources: Boiler has no fluid to work with. |
| `defines.entity_status.no_research_in_progress` | Used by labs. |
| `defines.entity_status.no_minable_resources` | Used by mining drills. |
| `defines.entity_status.hatches_blocked_by_elevated_rail` | Used by cargo bays. |
| `defines.entity_status.not_connected_to_hub_or_pad` | Used by cargo bays. |
| `defines.entity_status.too_far_from_pad_to_unload` | Used by some cargo bays. |
| `defines.entity_status.low_input_fluid` | Used by boilers and fluid turrets: Boiler still has some fluid but is about to run out. |
| `defines.entity_status.fluid_ingredient_shortage` | Used by crafting machines. |
| `defines.entity_status.full_output` | Used by crafting machines, boilers, burner energy sources, and reactors: Reactor/burner has full burnt result inventory, boiler has full output fluidbox. |
| `defines.entity_status.not_enough_space_in_output` | Used by agricultural towers. |
| `defines.entity_status.full_burnt_result_output` | Used by burner energy sources. |
| `defines.entity_status.item_ingredient_shortage` | Used by crafting machines. |
| `defines.entity_status.missing_required_fluid` | Used by mining drills when the mining fluid is missing. |
| `defines.entity_status.missing_science_packs` | Used by labs. |
| `defines.entity_status.waiting_for_source_items` | Used by inserters. |
| `defines.entity_status.waiting_for_more_items` | Used by inserters when wait_for_full_hand is set. |
| `defines.entity_status.waiting_for_space_in_destination` | Used by inserters, mining drills, and crafting machines using vector_to_place_result. |
| `defines.entity_status.preparing_rocket_for_launch` | Used by the rocket silo. |
| `defines.entity_status.waiting_to_launch_rocket` | Used by the rocket silo. |
| `defines.entity_status.waiting_for_space_in_platform_hub` | Used by the rocket silo. |
| `defines.entity_status.launching_rocket` | Used by the rocket silo. |
| `defines.entity_status.thrust_not_required` | Used by thrusters. |
| `defines.entity_status.on_the_way` | Used by space platform hubs. |
| `defines.entity_status.waiting_in_orbit` | Used by space platform hubs. |
| `defines.entity_status.waiting_at_stop` | Used by trains. |
| `defines.entity_status.waiting_for_upgrade` | Used by trains. |
| `defines.entity_status.waiting_for_rockets_to_arrive` | Used by space platform hubs. |
| `defines.entity_status.waiting_to_clear_drop_slots` | Used by space platform hubs. |
| `defines.entity_status.not_enough_thrust` | Used by space platform hubs. |
| `defines.entity_status.destination_stop_full` | Used by trains. |
| `defines.entity_status.no_path` | Used by trains and space platform hubs. |
| `defines.entity_status.no_modules_to_transmit` | Used by beacons. |
| `defines.entity_status.recharging_after_power_outage` | Used by roboports. |
| `defines.entity_status.waiting_for_target_to_be_built` | Used by inserters targeting entity ghosts. |
| `defines.entity_status.waiting_for_train` | Used by inserters targeting rails. |
| `defines.entity_status.no_ammo` | Used by ammo turrets. |
| `defines.entity_status.low_temperature` | Used by heat energy sources. |
| `defines.entity_status.disabled` | Used by constant combinators: Combinator is turned off via switch in GUI. |
| `defines.entity_status.turned_off_during_daytime` | Used by lamps. |
| `defines.entity_status.not_connected_to_rail` | Used by rail signals. |
| `defines.entity_status.cant_divide_segments` | Used by rail signals. |
| `defines.entity_status.no_filter` | Used by filter inserters. |
| `defines.entity_status.no_spot_seedable_by_inputs` | Used by agricultural towers. |
| `defines.entity_status.waiting_for_plants_to_grow` | Used by agricultural towers. |
| `defines.entity_status.computing_navigation` | Used by asteroid collectors. |
| `defines.entity_status.pipeline_overextended` | Used by pipes, pipes to ground, and storage tanks. |
| `defines.entity_status.recipe_not_researched` | Used by assembling machines. |
| `defines.entity_status.recipe_is_parameter` | Used by assembling machines. |
| `defines.entity_status.armed` | Used by land mines. |

## defines.entity_status_diode

| Wert | Bedeutung |
|---|---|
| `defines.entity_status_diode.green` |  |
| `defines.entity_status_diode.red` |  |
| `defines.entity_status_diode.yellow` |  |

## defines.events

> Build/Remove per Script heißen `script_raised_built`, `script_raised_destroy`, `script_raised_revive`, `script_raised_set_tiles` (ohne `on_`). Event-Daten stehen je Event auf https://lua-api.factorio.com/latest/events.html – z. B. liefert `on_train_changed_state` nur `train` und `old_state` (neuer Zustand = `train.state`).

| Wert | Bedeutung |
|---|---|
| `defines.events.on_achievement_gained` |  |
| `defines.events.on_ai_command_completed` |  |
| `defines.events.on_area_cloned` |  |
| `defines.events.on_biter_base_built` |  |
| `defines.events.on_blueprint_settings_pasted` |  |
| `defines.events.on_brush_cloned` |  |
| `defines.events.on_build_base_arrived` |  |
| `defines.events.on_built_entity` |  |
| `defines.events.on_cancelled_deconstruction` |  |
| `defines.events.on_cancelled_upgrade` |  |
| `defines.events.on_cargo_pod_delivered_cargo` |  |
| `defines.events.on_cargo_pod_finished_ascending` |  |
| `defines.events.on_cargo_pod_finished_descending` |  |
| `defines.events.on_cargo_pod_started_ascending` |  |
| `defines.events.on_character_corpse_expired` |  |
| `defines.events.on_chart_tag_added` |  |
| `defines.events.on_chart_tag_modified` |  |
| `defines.events.on_chart_tag_removed` |  |
| `defines.events.on_chunk_charted` |  |
| `defines.events.on_chunk_deleted` |  |
| `defines.events.on_chunk_generated` |  |
| `defines.events.on_combat_robot_expired` |  |
| `defines.events.on_console_chat` |  |
| `defines.events.on_console_command` |  |
| `defines.events.on_cutscene_cancelled` |  |
| `defines.events.on_cutscene_finished` |  |
| `defines.events.on_cutscene_started` |  |
| `defines.events.on_cutscene_waypoint_reached` |  |
| `defines.events.on_entity_cloned` |  |
| `defines.events.on_entity_color_changed` |  |
| `defines.events.on_entity_damaged` |  |
| `defines.events.on_entity_died` |  |
| `defines.events.on_entity_logistic_slot_changed` |  |
| `defines.events.on_entity_renamed` |  |
| `defines.events.on_entity_settings_pasted` |  |
| `defines.events.on_entity_spawned` |  |
| `defines.events.on_equipment_inserted` |  |
| `defines.events.on_equipment_removed` |  |
| `defines.events.on_force_cease_fire_changed` |  |
| `defines.events.on_force_created` |  |
| `defines.events.on_force_friends_changed` |  |
| `defines.events.on_force_reset` |  |
| `defines.events.on_forces_merged` |  |
| `defines.events.on_forces_merging` |  |
| `defines.events.on_game_created_from_scenario` |  |
| `defines.events.on_gui_checked_state_changed` |  |
| `defines.events.on_gui_click` |  |
| `defines.events.on_gui_closed` |  |
| `defines.events.on_gui_confirmed` |  |
| `defines.events.on_gui_elem_changed` |  |
| `defines.events.on_gui_hover` |  |
| `defines.events.on_gui_inventory_action` |  |
| `defines.events.on_gui_leave` |  |
| `defines.events.on_gui_location_changed` |  |
| `defines.events.on_gui_opened` |  |
| `defines.events.on_gui_selected_tab_changed` |  |
| `defines.events.on_gui_selection_state_changed` |  |
| `defines.events.on_gui_switch_state_changed` |  |
| `defines.events.on_gui_text_changed` |  |
| `defines.events.on_gui_value_changed` |  |
| `defines.events.on_land_mine_armed` |  |
| `defines.events.on_lua_shortcut` |  |
| `defines.events.on_marked_for_deconstruction` |  |
| `defines.events.on_marked_for_upgrade` |  |
| `defines.events.on_market_item_purchased` |  |
| `defines.events.on_mod_item_opened` |  |
| `defines.events.on_multiplayer_init` |  |
| `defines.events.on_next_day_started` |  |
| `defines.events.on_object_destroyed` |  |
| `defines.events.on_permission_group_added` |  |
| `defines.events.on_permission_group_deleted` |  |
| `defines.events.on_permission_group_edited` |  |
| `defines.events.on_permission_string_imported` |  |
| `defines.events.on_picked_up_item` |  |
| `defines.events.on_player_alt_reverse_selected_area` |  |
| `defines.events.on_player_alt_selected_area` |  |
| `defines.events.on_player_ammo_inventory_changed` |  |
| `defines.events.on_player_armor_inventory_changed` |  |
| `defines.events.on_player_banned` |  |
| `defines.events.on_player_built_tile` |  |
| `defines.events.on_player_cancelled_crafting` |  |
| `defines.events.on_player_changed_force` |  |
| `defines.events.on_player_changed_position` |  |
| `defines.events.on_player_changed_surface` |  |
| `defines.events.on_player_cheat_mode_disabled` |  |
| `defines.events.on_player_cheat_mode_enabled` |  |
| `defines.events.on_player_clicked_gps_tag` |  |
| `defines.events.on_player_color_changed` |  |
| `defines.events.on_player_configured_blueprint` |  |
| `defines.events.on_player_controller_changed` |  |
| `defines.events.on_player_crafted_item` |  |
| `defines.events.on_player_created` |  |
| `defines.events.on_player_cursor_stack_changed` |  |
| `defines.events.on_player_deconstructed_area` |  |
| `defines.events.on_player_demoted` |  |
| `defines.events.on_player_died` |  |
| `defines.events.on_player_display_density_scale_changed` |  |
| `defines.events.on_player_display_resolution_changed` |  |
| `defines.events.on_player_display_scale_changed` |  |
| `defines.events.on_player_driving_changed_state` |  |
| `defines.events.on_player_dropped_item` |  |
| `defines.events.on_player_dropped_item_into_entity` |  |
| `defines.events.on_player_fast_transferred` |  |
| `defines.events.on_player_flipped_entity` |  |
| `defines.events.on_player_flushed_fluid` |  |
| `defines.events.on_player_gun_inventory_changed` |  |
| `defines.events.on_player_input_method_changed` |  |
| `defines.events.on_player_joined_game` |  |
| `defines.events.on_player_kicked` |  |
| `defines.events.on_player_left_game` |  |
| `defines.events.on_player_locale_changed` |  |
| `defines.events.on_player_main_inventory_changed` |  |
| `defines.events.on_player_mined_entity` |  |
| `defines.events.on_player_mined_item` |  |
| `defines.events.on_player_mined_tile` |  |
| `defines.events.on_player_music_changed` |  |
| `defines.events.on_player_muted` |  |
| `defines.events.on_player_pipette` |  |
| `defines.events.on_player_placed_equipment` |  |
| `defines.events.on_player_promoted` |  |
| `defines.events.on_player_removed` |  |
| `defines.events.on_player_removed_equipment` |  |
| `defines.events.on_player_repaired_entity` |  |
| `defines.events.on_player_respawned` |  |
| `defines.events.on_player_reverse_selected_area` |  |
| `defines.events.on_player_rotated_entity` |  |
| `defines.events.on_player_selected_area` |  |
| `defines.events.on_player_set_quick_bar_slot` |  |
| `defines.events.on_player_setup_blueprint` |  |
| `defines.events.on_player_super_forced_selected_area` |  |
| `defines.events.on_player_toggled_alt_mode` |  |
| `defines.events.on_player_toggled_map_editor` |  |
| `defines.events.on_player_trash_inventory_changed` |  |
| `defines.events.on_player_unbanned` |  |
| `defines.events.on_player_unmuted` |  |
| `defines.events.on_player_used_capsule` |  |
| `defines.events.on_player_used_spidertron_remote` |  |
| `defines.events.on_post_entity_died` |  |
| `defines.events.on_post_segmented_unit_died` |  |
| `defines.events.on_pre_build` |  |
| `defines.events.on_pre_chunk_deleted` |  |
| `defines.events.on_pre_entity_settings_pasted` |  |
| `defines.events.on_pre_ghost_deconstructed` |  |
| `defines.events.on_pre_ghost_upgraded` |  |
| `defines.events.on_pre_permission_group_deleted` |  |
| `defines.events.on_pre_permission_string_imported` |  |
| `defines.events.on_pre_player_crafted_item` |  |
| `defines.events.on_pre_player_died` |  |
| `defines.events.on_pre_player_left_game` |  |
| `defines.events.on_pre_player_mined_item` |  |
| `defines.events.on_pre_player_removed` |  |
| `defines.events.on_pre_player_toggled_map_editor` |  |
| `defines.events.on_pre_robot_exploded_cliff` |  |
| `defines.events.on_pre_scenario_finished` |  |
| `defines.events.on_pre_script_inventory_resized` |  |
| `defines.events.on_pre_surface_cleared` |  |
| `defines.events.on_pre_surface_deleted` |  |
| `defines.events.on_redo_applied` |  |
| `defines.events.on_research_cancelled` |  |
| `defines.events.on_research_finished` |  |
| `defines.events.on_research_moved` |  |
| `defines.events.on_research_queued` |  |
| `defines.events.on_research_reversed` |  |
| `defines.events.on_research_started` |  |
| `defines.events.on_resource_depleted` |  |
| `defines.events.on_robot_built_entity` |  |
| `defines.events.on_robot_built_tile` |  |
| `defines.events.on_robot_exploded_cliff` |  |
| `defines.events.on_robot_mined` |  |
| `defines.events.on_robot_mined_entity` |  |
| `defines.events.on_robot_mined_tile` |  |
| `defines.events.on_robot_pre_mined` |  |
| `defines.events.on_rocket_launch_ordered` |  |
| `defines.events.on_rocket_launched` |  |
| `defines.events.on_runtime_mod_setting_changed` |  |
| `defines.events.on_script_inventory_resized` |  |
| `defines.events.on_script_path_request_finished` |  |
| `defines.events.on_script_trigger_effect` |  |
| `defines.events.on_sector_scanned` |  |
| `defines.events.on_segment_entity_created` |  |
| `defines.events.on_segmented_unit_created` |  |
| `defines.events.on_segmented_unit_damaged` |  |
| `defines.events.on_segmented_unit_died` |  |
| `defines.events.on_selected_entity_changed` |  |
| `defines.events.on_singleplayer_init` |  |
| `defines.events.on_space_platform_built_entity` |  |
| `defines.events.on_space_platform_built_tile` |  |
| `defines.events.on_space_platform_changed_state` |  |
| `defines.events.on_space_platform_mined_entity` |  |
| `defines.events.on_space_platform_mined_item` |  |
| `defines.events.on_space_platform_mined_tile` |  |
| `defines.events.on_space_platform_pre_mined` |  |
| `defines.events.on_spider_command_completed` |  |
| `defines.events.on_string_translated` |  |
| `defines.events.on_surface_cleared` |  |
| `defines.events.on_surface_created` |  |
| `defines.events.on_surface_deleted` |  |
| `defines.events.on_surface_imported` |  |
| `defines.events.on_surface_renamed` |  |
| `defines.events.on_technology_effects_reset` |  |
| `defines.events.on_territory_created` |  |
| `defines.events.on_territory_destroyed` |  |
| `defines.events.on_tick` |  |
| `defines.events.on_tower_mined_plant` |  |
| `defines.events.on_tower_planted_seed` |  |
| `defines.events.on_tower_pre_mined_plant` |  |
| `defines.events.on_train_changed_state` |  |
| `defines.events.on_train_created` |  |
| `defines.events.on_train_schedule_changed` |  |
| `defines.events.on_trigger_created_entity` |  |
| `defines.events.on_trigger_fired_artillery` |  |
| `defines.events.on_udp_packet_received` |  |
| `defines.events.on_undo_applied` |  |
| `defines.events.on_unit_added_to_group` |  |
| `defines.events.on_unit_group_created` |  |
| `defines.events.on_unit_group_finished_gathering` |  |
| `defines.events.on_unit_removed_from_group` |  |
| `defines.events.on_worker_robot_expired` |  |
| `defines.events.script_raised_built` |  |
| `defines.events.script_raised_destroy` |  |
| `defines.events.script_raised_destroy_segmented_unit` |  |
| `defines.events.script_raised_revive` |  |
| `defines.events.script_raised_set_tiles` |  |
| `defines.events.script_raised_teleported` |  |

## defines.flow_precision_index

| Wert | Bedeutung |
|---|---|
| `defines.flow_precision_index.five_seconds` |  |
| `defines.flow_precision_index.one_minute` |  |
| `defines.flow_precision_index.ten_minutes` |  |
| `defines.flow_precision_index.one_hour` |  |
| `defines.flow_precision_index.ten_hours` |  |
| `defines.flow_precision_index.fifty_hours` |  |
| `defines.flow_precision_index.two_hundred_fifty_hours` |  |
| `defines.flow_precision_index.one_thousand_hours` |  |

## defines.game_controller_interaction

| Wert | Bedeutung |
|---|---|
| `defines.game_controller_interaction.always` | Game controller will always hover this element regardless of type or state. |
| `defines.game_controller_interaction.never` | Never hover this element with a game controller. |
| `defines.game_controller_interaction.normal` | Hover according to the element type and implementation. |

## defines.group_state

| Wert | Bedeutung |
|---|---|
| `defines.group_state.gathering` |  |
| `defines.group_state.moving` |  |
| `defines.group_state.attacking_distraction` |  |
| `defines.group_state.attacking_target` |  |
| `defines.group_state.finished` |  |
| `defines.group_state.pathfinding` |  |
| `defines.group_state.wander_in_group` |  |

## defines.gui_type

| Wert | Bedeutung |
|---|---|
| `defines.gui_type.achievement` |  |
| `defines.gui_type.alerts_config` |  |
| `defines.gui_type.blueprint_library` |  |
| `defines.gui_type.bonus` |  |
| `defines.gui_type.controller` |  |
| `defines.gui_type.custom` |  |
| `defines.gui_type.entity` |  |
| `defines.gui_type.equipment` |  |
| `defines.gui_type.global_electric_network` |  |
| `defines.gui_type.item` |  |
| `defines.gui_type.logistic` |  |
| `defines.gui_type.none` |  |
| `defines.gui_type.opened_entity_grid` |  |
| `defines.gui_type.other_player` |  |
| `defines.gui_type.permissions` |  |
| `defines.gui_type.player_management` |  |
| `defines.gui_type.production` |  |
| `defines.gui_type.script_inventory` |  |
| `defines.gui_type.server_management` |  |
| `defines.gui_type.tile` |  |
| `defines.gui_type.trains` |  |

## defines.input_action

| Wert | Bedeutung |
|---|---|
| `defines.input_action.activate_interrupt` |  |
| `defines.input_action.activate_paste` |  |
| `defines.input_action.add_decider_combinator_condition` |  |
| `defines.input_action.add_decider_combinator_else_output` |  |
| `defines.input_action.add_decider_combinator_output` |  |
| `defines.input_action.add_logistic_section` |  |
| `defines.input_action.add_permission_group` |  |
| `defines.input_action.add_pin` |  |
| `defines.input_action.add_train_interrupt` |  |
| `defines.input_action.add_train_station` |  |
| `defines.input_action.adjust_blueprint_snapping` |  |
| `defines.input_action.admin_action` |  |
| `defines.input_action.alt_reverse_select_area` |  |
| `defines.input_action.alt_select_area` |  |
| `defines.input_action.alt_select_blueprint_entities` |  |
| `defines.input_action.alternative_copy` |  |
| `defines.input_action.begin_mining` |  |
| `defines.input_action.begin_mining_terrain` |  |
| `defines.input_action.build` |  |
| `defines.input_action.build_rail` |  |
| `defines.input_action.build_terrain` |  |
| `defines.input_action.cancel_craft` |  |
| `defines.input_action.cancel_deconstruct` |  |
| `defines.input_action.cancel_delete_space_platform` |  |
| `defines.input_action.cancel_new_blueprint` |  |
| `defines.input_action.cancel_research` |  |
| `defines.input_action.cancel_upgrade` |  |
| `defines.input_action.change_active_character_tab` |  |
| `defines.input_action.change_active_item_group_for_crafting` |  |
| `defines.input_action.change_active_item_group_for_filters` |  |
| `defines.input_action.change_active_quick_bar` |  |
| `defines.input_action.change_arithmetic_combinator_parameters` |  |
| `defines.input_action.change_entity_label` |  |
| `defines.input_action.change_heading_riding_state` |  |
| `defines.input_action.change_item_label` |  |
| `defines.input_action.change_logistic_point_group` |  |
| `defines.input_action.change_multiplayer_config` |  |
| `defines.input_action.change_picking_state` |  |
| `defines.input_action.change_programmable_speaker_alert_parameters` |  |
| `defines.input_action.change_programmable_speaker_circuit_parameters` |  |
| `defines.input_action.change_programmable_speaker_parameters` |  |
| `defines.input_action.change_research_condition` |  |
| `defines.input_action.change_riding_state` |  |
| `defines.input_action.change_selector_combinator_parameters` |  |
| `defines.input_action.change_shooting_state` |  |
| `defines.input_action.change_train_name` |  |
| `defines.input_action.change_train_station` |  |
| `defines.input_action.change_train_stop_station` |  |
| `defines.input_action.change_train_wait_condition` |  |
| `defines.input_action.change_train_wait_condition_data` |  |
| `defines.input_action.cheat` |  |
| `defines.input_action.clear_cursor` |  |
| `defines.input_action.connect_rolling_stock` |  |
| `defines.input_action.copy` |  |
| `defines.input_action.copy_entity_settings` |  |
| `defines.input_action.copy_large_opened_blueprint` |  |
| `defines.input_action.copy_large_opened_item` |  |
| `defines.input_action.copy_opened_blueprint` |  |
| `defines.input_action.copy_opened_item` |  |
| `defines.input_action.craft` |  |
| `defines.input_action.create_space_platform` |  |
| `defines.input_action.cursor_split` |  |
| `defines.input_action.cursor_transfer` |  |
| `defines.input_action.custom_input` |  |
| `defines.input_action.cycle_blueprint_book_backwards` |  |
| `defines.input_action.cycle_blueprint_book_forwards` |  |
| `defines.input_action.cycle_quality_down` |  |
| `defines.input_action.cycle_quality_up` |  |
| `defines.input_action.deconstruct` |  |
| `defines.input_action.delete_blueprint_library` |  |
| `defines.input_action.delete_blueprint_record` |  |
| `defines.input_action.delete_custom_tag` |  |
| `defines.input_action.delete_logistic_group` |  |
| `defines.input_action.delete_permission_group` |  |
| `defines.input_action.delete_space_platform` |  |
| `defines.input_action.destroy_item` |  |
| `defines.input_action.destroy_opened_item` |  |
| `defines.input_action.disconnect_rolling_stock` |  |
| `defines.input_action.drag_decider_combinator_condition` |  |
| `defines.input_action.drag_decider_combinator_else_output` |  |
| `defines.input_action.drag_decider_combinator_output` |  |
| `defines.input_action.drag_research_condition` |  |
| `defines.input_action.drag_train_schedule` |  |
| `defines.input_action.drag_train_schedule_interrupt` |  |
| `defines.input_action.drag_train_wait_condition` |  |
| `defines.input_action.drop_blueprint_record` |  |
| `defines.input_action.drop_item` |  |
| `defines.input_action.edit_blueprint_tool_preview` |  |
| `defines.input_action.edit_custom_tag` |  |
| `defines.input_action.edit_display_panel` |  |
| `defines.input_action.edit_display_panel_always_show` |  |
| `defines.input_action.edit_display_panel_icon` |  |
| `defines.input_action.edit_display_panel_parameters` |  |
| `defines.input_action.edit_display_panel_show_in_chart` |  |
| `defines.input_action.edit_display_panel_single_entry` |  |
| `defines.input_action.edit_interrupt` |  |
| `defines.input_action.edit_permission_group` |  |
| `defines.input_action.edit_pin` |  |
| `defines.input_action.export_blueprint` |  |
| `defines.input_action.fast_entity_split` |  |
| `defines.input_action.fast_entity_transfer` |  |
| `defines.input_action.flip_entity` |  |
| `defines.input_action.flush_opened_entity_fluid` |  |
| `defines.input_action.flush_opened_entity_specific_fluid` |  |
| `defines.input_action.go_to_train_station` |  |
| `defines.input_action.grab_blueprint_record` |  |
| `defines.input_action.gui_checked_state_changed` |  |
| `defines.input_action.gui_click` |  |
| `defines.input_action.gui_confirmed` |  |
| `defines.input_action.gui_elem_changed` |  |
| `defines.input_action.gui_hover` |  |
| `defines.input_action.gui_inventory_action` |  |
| `defines.input_action.gui_inventory_bar_changed` |  |
| `defines.input_action.gui_inventory_filter_changed` |  |
| `defines.input_action.gui_leave` |  |
| `defines.input_action.gui_location_changed` |  |
| `defines.input_action.gui_selected_tab_changed` |  |
| `defines.input_action.gui_selection_state_changed` |  |
| `defines.input_action.gui_switch_state_changed` |  |
| `defines.input_action.gui_text_changed` |  |
| `defines.input_action.gui_value_changed` |  |
| `defines.input_action.import_blueprint` |  |
| `defines.input_action.import_blueprint_string` |  |
| `defines.input_action.import_blueprints_filtered` |  |
| `defines.input_action.import_permissions_string` |  |
| `defines.input_action.instantly_create_space_platform` |  |
| `defines.input_action.inventory_split` |  |
| `defines.input_action.inventory_transfer` |  |
| `defines.input_action.land_at_planet` |  |
| `defines.input_action.launch_rocket` |  |
| `defines.input_action.lua_shortcut` |  |
| `defines.input_action.map_editor_action` |  |
| `defines.input_action.market_offer` |  |
| `defines.input_action.mod_settings_changed` |  |
| `defines.input_action.modify_decider_combinator_condition` |  |
| `defines.input_action.modify_decider_combinator_else_output` |  |
| `defines.input_action.modify_decider_combinator_output` |  |
| `defines.input_action.move_pin` |  |
| `defines.input_action.move_research` |  |
| `defines.input_action.open_achievements_gui` |  |
| `defines.input_action.open_alerts_config_gui` |  |
| `defines.input_action.open_blueprint_library_gui` |  |
| `defines.input_action.open_blueprint_record` |  |
| `defines.input_action.open_bonus_gui` |  |
| `defines.input_action.open_character_gui` |  |
| `defines.input_action.open_current_vehicle_gui` |  |
| `defines.input_action.open_equipment` |  |
| `defines.input_action.open_global_electric_network_gui` |  |
| `defines.input_action.open_gui` |  |
| `defines.input_action.open_item` |  |
| `defines.input_action.open_logistics_gui` |  |
| `defines.input_action.open_mod_item` |  |
| `defines.input_action.open_new_platform_button_from_rocket_silo` |  |
| `defines.input_action.open_opened_entity_grid` |  |
| `defines.input_action.open_parent_of_opened_item` |  |
| `defines.input_action.open_production_gui` |  |
| `defines.input_action.open_train_gui` |  |
| `defines.input_action.open_train_station_gui` |  |
| `defines.input_action.open_trains_gui` |  |
| `defines.input_action.parametrise_blueprint` |  |
| `defines.input_action.paste_entity_settings` |  |
| `defines.input_action.pin_alert_group` |  |
| `defines.input_action.pin_custom_alert` |  |
| `defines.input_action.pin_search_result` |  |
| `defines.input_action.pipette` |  |
| `defines.input_action.place_equipment` |  |
| `defines.input_action.providing_to_other_platforms` |  |
| `defines.input_action.quick_bar_pick_slot` |  |
| `defines.input_action.quick_bar_set_selected_page` |  |
| `defines.input_action.quick_bar_set_slot` |  |
| `defines.input_action.reassign_blueprint` |  |
| `defines.input_action.redo` |  |
| `defines.input_action.remote_view_entity` |  |
| `defines.input_action.remote_view_surface` |  |
| `defines.input_action.remove_cables` |  |
| `defines.input_action.remove_decider_combinator_condition` |  |
| `defines.input_action.remove_decider_combinator_else_output` |  |
| `defines.input_action.remove_decider_combinator_output` |  |
| `defines.input_action.remove_logistic_section` |  |
| `defines.input_action.remove_pin` |  |
| `defines.input_action.remove_train_interrupt` |  |
| `defines.input_action.remove_train_station` |  |
| `defines.input_action.rename_interrupt` |  |
| `defines.input_action.rename_space_platform` |  |
| `defines.input_action.reorder_logistic_section` |  |
| `defines.input_action.request_missing_construction_materials` |  |
| `defines.input_action.reset_assembling_machine` |  |
| `defines.input_action.reverse_select_area` |  |
| `defines.input_action.rotate_entity` |  |
| `defines.input_action.select_area` |  |
| `defines.input_action.select_asteroid_chunk_slot` |  |
| `defines.input_action.select_blueprint_entities` |  |
| `defines.input_action.select_entity_filter_slot` |  |
| `defines.input_action.select_entity_slot` |  |
| `defines.input_action.select_item_filter` |  |
| `defines.input_action.select_mapper_slot_from` |  |
| `defines.input_action.select_mapper_slot_to` |  |
| `defines.input_action.select_next_valid_gun` |  |
| `defines.input_action.select_tile_slot` |  |
| `defines.input_action.send_spidertron` |  |
| `defines.input_action.send_stack_to_trash` |  |
| `defines.input_action.send_stacks_to_trash` |  |
| `defines.input_action.send_train_to_pin_target` |  |
| `defines.input_action.set_behavior_mode` |  |
| `defines.input_action.set_car_weapons_control` |  |
| `defines.input_action.set_cheat_mode_quality` |  |
| `defines.input_action.set_circuit_condition` |  |
| `defines.input_action.set_circuit_mode_of_operation` |  |
| `defines.input_action.set_combinator_description` |  |
| `defines.input_action.set_control_behavior_input_networks` |  |
| `defines.input_action.set_control_behavior_output_networks` |  |
| `defines.input_action.set_copy_color_from_train_stop` |  |
| `defines.input_action.set_deconstruction_item_tile_selection_mode` |  |
| `defines.input_action.set_deconstruction_item_trees_and_rocks_only` |  |
| `defines.input_action.set_entity_color` |  |
| `defines.input_action.set_entity_energy_property` |  |
| `defines.input_action.set_equipment_energy_property` |  |
| `defines.input_action.set_filter` |  |
| `defines.input_action.set_ghost_cursor` |  |
| `defines.input_action.set_heat_interface_mode` |  |
| `defines.input_action.set_heat_interface_temperature` |  |
| `defines.input_action.set_infinity_container_filter_item` |  |
| `defines.input_action.set_infinity_container_logistic_mode` |  |
| `defines.input_action.set_infinity_container_remove_unfiltered_items` |  |
| `defines.input_action.set_infinity_pipe_filter` |  |
| `defines.input_action.set_inserter_max_stack_size` |  |
| `defines.input_action.set_inventory_bar` |  |
| `defines.input_action.set_lamp_always_on` |  |
| `defines.input_action.set_linked_container_link_i_d` |  |
| `defines.input_action.set_loader_belt_stack_size_override` |  |
| `defines.input_action.set_logistic_filter_item` |  |
| `defines.input_action.set_logistic_network_name` |  |
| `defines.input_action.set_logistic_section_active` |  |
| `defines.input_action.set_player_color` |  |
| `defines.input_action.set_pump_fluid_filter` |  |
| `defines.input_action.set_request_from_buffers` |  |
| `defines.input_action.set_research_finished_stops_game` |  |
| `defines.input_action.set_rocket_silo_send_to_orbit_automated_mode` |  |
| `defines.input_action.set_schedule_record_allow_unloading` |  |
| `defines.input_action.set_signal` |  |
| `defines.input_action.set_splitter_priority` |  |
| `defines.input_action.set_spoil_priority` |  |
| `defines.input_action.set_train_stop_priority` |  |
| `defines.input_action.set_train_stopped` |  |
| `defines.input_action.set_trains_limit` |  |
| `defines.input_action.set_turret_ignore_unlisted` |  |
| `defines.input_action.set_use_inserter_filters` |  |
| `defines.input_action.set_vehicle_automatic_targeting_parameters` |  |
| `defines.input_action.setup_assembling_machine` |  |
| `defines.input_action.setup_blueprint` |  |
| `defines.input_action.setup_single_blueprint_record` |  |
| `defines.input_action.spawn_item` |  |
| `defines.input_action.spectator_change_surface` |  |
| `defines.input_action.stack_split` |  |
| `defines.input_action.stack_transfer` |  |
| `defines.input_action.start_repair` |  |
| `defines.input_action.start_research` |  |
| `defines.input_action.start_walking` |  |
| `defines.input_action.stop_drag_build` |  |
| `defines.input_action.super_forced_select_area` |  |
| `defines.input_action.swap_asteroid_chunk_slots` |  |
| `defines.input_action.swap_entity_filter_slots` |  |
| `defines.input_action.swap_entity_slots` |  |
| `defines.input_action.swap_infinity_container_filter_items` |  |
| `defines.input_action.swap_item_filters` |  |
| `defines.input_action.swap_logistic_filter_items` |  |
| `defines.input_action.swap_mappers` |  |
| `defines.input_action.swap_tile_slots` |  |
| `defines.input_action.switch_connect_to_logistic_network` |  |
| `defines.input_action.switch_constant_combinator_state` |  |
| `defines.input_action.switch_inserter_filter_mode_state` |  |
| `defines.input_action.switch_loader_filter_mode` |  |
| `defines.input_action.switch_mining_drill_filter_mode_state` |  |
| `defines.input_action.switch_power_switch_state` |  |
| `defines.input_action.take_equipment` |  |
| `defines.input_action.toggle_artillery_auto_targeting` |  |
| `defines.input_action.toggle_blueprint_snap_to_grid` |  |
| `defines.input_action.toggle_deconstruction_item_entity_filter_mode` |  |
| `defines.input_action.toggle_deconstruction_item_tile_filter_mode` |  |
| `defines.input_action.toggle_driving` |  |
| `defines.input_action.toggle_enable_vehicle_logistics_while_moving` |  |
| `defines.input_action.toggle_entity_logistic_requests` |  |
| `defines.input_action.toggle_equipment_movement_bonus` |  |
| `defines.input_action.toggle_map_editor` |  |
| `defines.input_action.toggle_personal_logistic_requests` |  |
| `defines.input_action.toggle_personal_roboport` |  |
| `defines.input_action.toggle_selected_entity` |  |
| `defines.input_action.toggle_show_entity_info` |  |
| `defines.input_action.toggle_tall_entity_visibility` |  |
| `defines.input_action.trash_not_requested_items` |  |
| `defines.input_action.undo` |  |
| `defines.input_action.upgrade` |  |
| `defines.input_action.upgrade_opened_blueprint_by_item` |  |
| `defines.input_action.upgrade_opened_blueprint_by_record` |  |
| `defines.input_action.use_item` |  |
| `defines.input_action.wire_dragging` |  |
| `defines.input_action.write_to_console` |  |

## defines.input_method

| Wert | Bedeutung |
|---|---|
| `defines.input_method.keyboard_and_mouse` |  |
| `defines.input_method.game_controller` |  |

## defines.inventory

> Maschinen nutzen seit 2.0 die gemeinsamen `crafter_*`-Inventare (`crafter_input`, `crafter_output`, `crafter_modules`, `crafter_trash`) – die alten `assembling_machine_*`/`furnace_*` gibt es nicht mehr.

| Wert | Bedeutung |
|---|---|
| `defines.inventory.fuel` |  |
| `defines.inventory.burnt_result` |  |
| `defines.inventory.chest` |  |
| `defines.inventory.logistic_container_trash` |  |
| `defines.inventory.character_main` |  |
| `defines.inventory.character_guns` |  |
| `defines.inventory.character_ammo` |  |
| `defines.inventory.character_armor` |  |
| `defines.inventory.character_vehicle` |  |
| `defines.inventory.character_trash` |  |
| `defines.inventory.god_main` |  |
| `defines.inventory.editor_main` |  |
| `defines.inventory.editor_guns` |  |
| `defines.inventory.editor_ammo` |  |
| `defines.inventory.editor_armor` |  |
| `defines.inventory.roboport_robot` |  |
| `defines.inventory.roboport_material` |  |
| `defines.inventory.robot_cargo` |  |
| `defines.inventory.robot_repair` |  |
| `defines.inventory.assembling_machine_dump` | Used for ejected items, or items held by inserters that can't be inserted due the recipe being changed with the circuit network. |
| `defines.inventory.lab_input` |  |
| `defines.inventory.lab_modules` |  |
| `defines.inventory.lab_trash` |  |
| `defines.inventory.mining_drill_modules` |  |
| `defines.inventory.item_main` |  |
| `defines.inventory.rocket_silo_rocket` |  |
| `defines.inventory.rocket_silo_trash` |  |
| `defines.inventory.rocket_silo_attached_cargo_unit` |  |
| `defines.inventory.cargo_unit` | Inventory of cargo pod. |
| `defines.inventory.car_trunk` |  |
| `defines.inventory.car_ammo` |  |
| `defines.inventory.car_trash` |  |
| `defines.inventory.cargo_wagon` |  |
| `defines.inventory.turret_ammo` |  |
| `defines.inventory.beacon_modules` |  |
| `defines.inventory.character_corpse` |  |
| `defines.inventory.artillery_turret_ammo` |  |
| `defines.inventory.artillery_wagon_ammo` |  |
| `defines.inventory.spider_trunk` |  |
| `defines.inventory.spider_ammo` |  |
| `defines.inventory.spider_trash` |  |
| `defines.inventory.hub_main` |  |
| `defines.inventory.hub_trash` |  |
| `defines.inventory.cargo_landing_pad_main` |  |
| `defines.inventory.cargo_landing_pad_trash` |  |
| `defines.inventory.proxy_main` |  |
| `defines.inventory.agricultural_tower_input` |  |
| `defines.inventory.agricultural_tower_output` |  |
| `defines.inventory.agricultural_tower_modules` |  |
| `defines.inventory.linked_container_main` |  |
| `defines.inventory.crafter_input` |  |
| `defines.inventory.crafter_output` |  |
| `defines.inventory.crafter_modules` |  |
| `defines.inventory.crafter_trash` | Used for spoil result items that do not fit into the recipe slots, and for items that are ejected when changing the recipe via remote view. |
| `defines.inventory.asteroid_collector_output` |  |
| `defines.inventory.asteroid_collector_arm` |  |

## defines.inventory_actions

| Wert | Bedeutung |
|---|---|
| `defines.inventory_actions.cursor_transfer` |  |
| `defines.inventory_actions.cursor_split` |  |
| `defines.inventory_actions.stack_transfer` |  |
| `defines.inventory_actions.stack_split` |  |
| `defines.inventory_actions.inventory_transfer` |  |
| `defines.inventory_actions.inventory_split` |  |
| `defines.inventory_actions.open_item` |  |
| `defines.inventory_actions.open_mod_item` |  |
| `defines.inventory_actions.send_stack_to_trash` |  |
| `defines.inventory_actions.send_stacks_to_trash` |  |

## defines.logistic_group_type

| Wert | Bedeutung |
|---|---|
| `defines.logistic_group_type.with_trash` |  |
| `defines.logistic_group_type.roboport` |  |

## defines.logistic_member_index

| Wert | Bedeutung |
|---|---|
| `defines.logistic_member_index.logistic_container` |  |
| `defines.logistic_member_index.logistic_container_trash_provider` |  |
| `defines.logistic_member_index.vehicle_storage` |  |
| `defines.logistic_member_index.character_requester` |  |
| `defines.logistic_member_index.character_storage` |  |
| `defines.logistic_member_index.character_provider` |  |
| `defines.logistic_member_index.generic_on_off_behavior` |  |
| `defines.logistic_member_index.spidertron_requester` |  |
| `defines.logistic_member_index.spidertron_provider` |  |
| `defines.logistic_member_index.car_requester` |  |
| `defines.logistic_member_index.car_provider` |  |
| `defines.logistic_member_index.roboport_provider` |  |
| `defines.logistic_member_index.roboport_requester` |  |
| `defines.logistic_member_index.rocket_silo_provider` |  |
| `defines.logistic_member_index.rocket_silo_requester` |  |
| `defines.logistic_member_index.rocket_silo_trash_provider` |  |
| `defines.logistic_member_index.space_platform_hub_requester` |  |
| `defines.logistic_member_index.space_platform_hub_provider` |  |
| `defines.logistic_member_index.cargo_landing_pad_requester` |  |
| `defines.logistic_member_index.cargo_landing_pad_provider` |  |
| `defines.logistic_member_index.cargo_landing_pad_trash_provider` |  |

## defines.logistic_mode

| Wert | Bedeutung |
|---|---|
| `defines.logistic_mode.none` |  |
| `defines.logistic_mode.active_provider` |  |
| `defines.logistic_mode.storage` |  |
| `defines.logistic_mode.requester` |  |
| `defines.logistic_mode.passive_provider` |  |
| `defines.logistic_mode.buffer` |  |

## defines.logistic_section_type

| Wert | Bedeutung |
|---|---|
| `defines.logistic_section_type.manual` |  |
| `defines.logistic_section_type.circuit_controlled` |  |
| `defines.logistic_section_type.transitional_request_controlled` | Used by rocket silos. |
| `defines.logistic_section_type.request_missing_materials_controlled` | Used by space platform hubs. |

## defines.mouse_button_type

| Wert | Bedeutung |
|---|---|
| `defines.mouse_button_type.none` |  |
| `defines.mouse_button_type.left` |  |
| `defines.mouse_button_type.right` |  |
| `defines.mouse_button_type.middle` |  |

## defines.moving_state

| Wert | Bedeutung |
|---|---|
| `defines.moving_state.stale` |  |
| `defines.moving_state.moving` |  |
| `defines.moving_state.adaptive` |  |
| `defines.moving_state.stuck` |  |

## defines.print_skip

| Wert | Bedeutung |
|---|---|
| `defines.print_skip.never` | Print will not be skipped. |
| `defines.print_skip.if_redundant` | Print will be skipped if same text was recently printed (within last 60 ticks). |
| `defines.print_skip.if_visible` | Print will be skipped if same text is still visible (printed within last 1152 ticks). |

## defines.print_sound

| Wert | Bedeutung |
|---|---|
| `defines.print_sound.always` |  |
| `defines.print_sound.never` |  |
| `defines.print_sound.use_player_settings` |  |

## defines.prototypes

| Wert | Bedeutung |
|---|---|
| `defines.prototypes.achievement.achievement` |  |
| `defines.prototypes.animation.animation` |  |
| `defines.prototypes.entity.accumulator` |  |
| `defines.prototypes.entity.arrow` |  |
| `defines.prototypes.entity.asteroid` |  |
| `defines.prototypes.entity.beacon` |  |
| `defines.prototypes.entity.beam` |  |
| `defines.prototypes.entity.boiler` |  |
| `defines.prototypes.entity.car` |  |
| `defines.prototypes.entity.character` |  |
| `defines.prototypes.entity.cliff` |  |
| `defines.prototypes.entity.container` |  |
| `defines.prototypes.entity.corpse` |  |
| `defines.prototypes.entity.explosion` |  |
| `defines.prototypes.entity.fire` |  |
| `defines.prototypes.entity.fish` |  |
| `defines.prototypes.entity.furnace` |  |
| `defines.prototypes.entity.gate` |  |
| `defines.prototypes.entity.generator` |  |
| `defines.prototypes.entity.inserter` |  |
| `defines.prototypes.entity.lab` |  |
| `defines.prototypes.entity.lamp` |  |
| `defines.prototypes.entity.lightning` |  |
| `defines.prototypes.entity.loader` |  |
| `defines.prototypes.entity.locomotive` |  |
| `defines.prototypes.entity.market` |  |
| `defines.prototypes.entity.pipe` |  |
| `defines.prototypes.entity.plant` |  |
| `defines.prototypes.entity.projectile` |  |
| `defines.prototypes.entity.pump` |  |
| `defines.prototypes.entity.radar` |  |
| `defines.prototypes.entity.reactor` |  |
| `defines.prototypes.entity.resource` |  |
| `defines.prototypes.entity.roboport` |  |
| `defines.prototypes.entity.segment` |  |
| `defines.prototypes.entity.splitter` |  |
| `defines.prototypes.entity.sticker` |  |
| `defines.prototypes.entity.stream` |  |
| `defines.prototypes.entity.thruster` |  |
| `defines.prototypes.entity.tree` |  |
| `defines.prototypes.entity.turret` |  |
| `defines.prototypes.entity.unit` |  |
| `defines.prototypes.entity.valve` |  |
| `defines.prototypes.entity.wall` |  |
| `defines.prototypes.fluid.fluid` |  |
| `defines.prototypes.font.font` |  |
| `defines.prototypes.item.ammo` |  |
| `defines.prototypes.item.armor` |  |
| `defines.prototypes.item.blueprint` |  |
| `defines.prototypes.item.capsule` |  |
| `defines.prototypes.item.gun` |  |
| `defines.prototypes.item.item` |  |
| `defines.prototypes.item.module` |  |
| `defines.prototypes.item.tool` |  |
| `defines.prototypes.procession.procession` |  |
| `defines.prototypes.quality.quality` |  |
| `defines.prototypes.recipe.recipe` |  |
| `defines.prototypes.shortcut.shortcut` |  |
| `defines.prototypes.sound.sound` |  |
| `defines.prototypes.sprite.sprite` |  |
| `defines.prototypes.surface.surface` |  |
| `defines.prototypes.technology.technology` |  |
| `defines.prototypes.tile.tile` |  |
| `defines.prototypes.tutorial.tutorial` |  |

## defines.rail_connection_direction

| Wert | Bedeutung |
|---|---|
| `defines.rail_connection_direction.left` |  |
| `defines.rail_connection_direction.straight` |  |
| `defines.rail_connection_direction.right` |  |
| `defines.rail_connection_direction.none` |  |

## defines.rail_direction

| Wert | Bedeutung |
|---|---|
| `defines.rail_direction.front` |  |
| `defines.rail_direction.back` |  |

## defines.rail_layer

| Wert | Bedeutung |
|---|---|
| `defines.rail_layer.ground` |  |
| `defines.rail_layer.elevated` |  |

## defines.relative_gui_position

| Wert | Bedeutung |
|---|---|
| `defines.relative_gui_position.top` |  |
| `defines.relative_gui_position.bottom` |  |
| `defines.relative_gui_position.left` |  |
| `defines.relative_gui_position.right` |  |

## defines.relative_gui_type

| Wert | Bedeutung |
|---|---|
| `defines.relative_gui_type.accumulator_gui` |  |
| `defines.relative_gui_type.achievement_gui` |  |
| `defines.relative_gui_type.additional_entity_info_gui` |  |
| `defines.relative_gui_type.admin_gui` |  |
| `defines.relative_gui_type.agriculture_tower_gui` |  |
| `defines.relative_gui_type.alerts_config_gui` |  |
| `defines.relative_gui_type.arithmetic_combinator_gui` |  |
| `defines.relative_gui_type.armor_gui` |  |
| `defines.relative_gui_type.assembling_machine_gui` |  |
| `defines.relative_gui_type.assembling_machine_select_recipe_gui` |  |
| `defines.relative_gui_type.asteroid_collector_gui` |  |
| `defines.relative_gui_type.beacon_gui` |  |
| `defines.relative_gui_type.blueprint_book_gui` |  |
| `defines.relative_gui_type.blueprint_library_gui` |  |
| `defines.relative_gui_type.blueprint_setup_gui` |  |
| `defines.relative_gui_type.boiler_gui` |  |
| `defines.relative_gui_type.bonus_gui` |  |
| `defines.relative_gui_type.burner_equipment_gui` |  |
| `defines.relative_gui_type.car_gui` |  |
| `defines.relative_gui_type.cargo_landing_pad_gui` |  |
| `defines.relative_gui_type.constant_combinator_gui` |  |
| `defines.relative_gui_type.container_gui` |  |
| `defines.relative_gui_type.controller_gui` |  |
| `defines.relative_gui_type.decider_combinator_gui` |  |
| `defines.relative_gui_type.deconstruction_item_gui` |  |
| `defines.relative_gui_type.display_panel_gui` |  |
| `defines.relative_gui_type.electric_energy_interface_equipment_gui` |  |
| `defines.relative_gui_type.electric_energy_interface_gui` |  |
| `defines.relative_gui_type.electric_network_gui` |  |
| `defines.relative_gui_type.entity_variations_gui` |  |
| `defines.relative_gui_type.entity_with_energy_source_gui` |  |
| `defines.relative_gui_type.equipment_grid_gui` |  |
| `defines.relative_gui_type.furnace_gui` |  |
| `defines.relative_gui_type.generic_on_off_entity_gui` |  |
| `defines.relative_gui_type.ghost_picker_gui` |  |
| `defines.relative_gui_type.global_electric_network_gui` |  |
| `defines.relative_gui_type.heat_interface_gui` |  |
| `defines.relative_gui_type.heat_pipe_gui` |  |
| `defines.relative_gui_type.infinity_pipe_gui` |  |
| `defines.relative_gui_type.inserter_gui` |  |
| `defines.relative_gui_type.item_with_inventory_gui` |  |
| `defines.relative_gui_type.lab_gui` |  |
| `defines.relative_gui_type.lamp_gui` |  |
| `defines.relative_gui_type.linked_container_gui` |  |
| `defines.relative_gui_type.loader_gui` |  |
| `defines.relative_gui_type.logistic_gui` |  |
| `defines.relative_gui_type.market_gui` |  |
| `defines.relative_gui_type.mining_drill_gui` |  |
| `defines.relative_gui_type.other_player_gui` |  |
| `defines.relative_gui_type.permissions_gui` |  |
| `defines.relative_gui_type.pick_stop_gui` |  |
| `defines.relative_gui_type.pipe_gui` |  |
| `defines.relative_gui_type.power_switch_gui` |  |
| `defines.relative_gui_type.production_gui` |  |
| `defines.relative_gui_type.programmable_speaker_gui` |  |
| `defines.relative_gui_type.proxy_container_gui` |  |
| `defines.relative_gui_type.pump_gui` |  |
| `defines.relative_gui_type.radar_gui` |  |
| `defines.relative_gui_type.rail_signal_base_gui` |  |
| `defines.relative_gui_type.reactor_gui` |  |
| `defines.relative_gui_type.resource_entity_gui` |  |
| `defines.relative_gui_type.roboport_gui` |  |
| `defines.relative_gui_type.rocket_silo_gui` |  |
| `defines.relative_gui_type.script_inventory_gui` |  |
| `defines.relative_gui_type.selector_combinator_gui` |  |
| `defines.relative_gui_type.server_config_gui` |  |
| `defines.relative_gui_type.space_platform_hub_gui` |  |
| `defines.relative_gui_type.spider_vehicle_gui` |  |
| `defines.relative_gui_type.splitter_gui` |  |
| `defines.relative_gui_type.standalone_character_gui` |  |
| `defines.relative_gui_type.tile_variations_gui` |  |
| `defines.relative_gui_type.tips_and_tricks_gui` |  |
| `defines.relative_gui_type.train_gui` |  |
| `defines.relative_gui_type.train_stop_gui` |  |
| `defines.relative_gui_type.trains_gui` |  |
| `defines.relative_gui_type.transport_belt_gui` |  |
| `defines.relative_gui_type.turret_gui` |  |
| `defines.relative_gui_type.upgrade_item_gui` |  |
| `defines.relative_gui_type.wall_gui` |  |

## defines.render_mode

| Wert | Bedeutung |
|---|---|
| `defines.render_mode.game` |  |
| `defines.render_mode.chart` |  |
| `defines.render_mode.chart_zoomed_in` |  |

## defines.rich_text_setting

| Wert | Bedeutung |
|---|---|
| `defines.rich_text_setting.enabled` |  |
| `defines.rich_text_setting.disabled` |  |
| `defines.rich_text_setting.highlight` |  |

## defines.riding

| Wert | Bedeutung |
|---|---|
| `defines.riding.acceleration.nothing` |  |
| `defines.riding.acceleration.accelerating` |  |
| `defines.riding.acceleration.braking` |  |
| `defines.riding.acceleration.reversing` |  |
| `defines.riding.direction.left` |  |
| `defines.riding.direction.straight` |  |
| `defines.riding.direction.right` |  |

## defines.robot_order_type

| Wert | Bedeutung |
|---|---|
| `defines.robot_order_type.construct` | Construct a ghost. |
| `defines.robot_order_type.pickup` | Pickup an item. |
| `defines.robot_order_type.deliver` | Deliver an item. |
| `defines.robot_order_type.repair` | Repair an entity. |
| `defines.robot_order_type.deconstruct` | Deconstruct an entity. |
| `defines.robot_order_type.deliver_items` | Deliver specific items to an entity (item request proxy). |
| `defines.robot_order_type.upgrade` | Upgrade an entity. |
| `defines.robot_order_type.explode_cliff` | Explode a cliff. |
| `defines.robot_order_type.pickup_items` | Pickup items from an entity (item request proxy). |

## defines.rocket_silo_status

| Wert | Bedeutung |
|---|---|
| `defines.rocket_silo_status.building_rocket` | The rocket silo is crafting rocket parts. |
| `defines.rocket_silo_status.create_rocket` | The next state is lights_blinking_open . |
| `defines.rocket_silo_status.lights_blinking_open` | The next state is doors_opening . |
| `defines.rocket_silo_status.doors_opening` | The next state is doors_opened . |
| `defines.rocket_silo_status.doors_opened` | The next state is rocket_rising or if the rocket is destroyed in this state then the next state will be lights_blinking_close . |
| `defines.rocket_silo_status.rocket_rising` | The next state is arms_advance or if the rocket is destroyed in this state then the next state will be lights_blinking_close . |
| `defines.rocket_silo_status.arms_advance` | The next state is rocket_ready or if the rocket is destroyed in this state then the next state will be lights_blinking_close . |
| `defines.rocket_silo_status.rocket_ready` | The rocket launch can be started by the player. |
| `defines.rocket_silo_status.launch_starting` | The next state is launch_started . |
| `defines.rocket_silo_status.engine_starting` | The next state is arms_retract or if the rocket is destroyed in this state then the next state will be lights_blinking_close . |
| `defines.rocket_silo_status.arms_retract` | The next state is rocket_flying or if the rocket is destroyed in this state then the next state will be lights_blinking_close . |
| `defines.rocket_silo_status.rocket_flying` | The next state is lights_blinking_close . |
| `defines.rocket_silo_status.lights_blinking_close` | The next state is doors_closing . |
| `defines.rocket_silo_status.doors_closing` | The next state is building_rocket . |
| `defines.rocket_silo_status.launch_started` | The next state is engine_starting or if the rocket is destroyed in this state then the next state will be lights_blinking_close . |

## defines.segmented_unit_activity_mode

| Wert | Bedeutung |
|---|---|
| `defines.segmented_unit_activity_mode.asleep` | The segmented unit is completely asleep, only performing the bare minimum checks to wake up if needed. |
| `defines.segmented_unit_activity_mode.minimal` | The segmented unit is minimally active, reducing unnecessary entity movement and trigger effects while continuing to patrol around its territory. |
| `defines.segmented_unit_activity_mode.full` | The segmented unit is fully active and simulated as if it is being observed by a player. |

## defines.segmented_unit_ai_state

| Wert | Bedeutung |
|---|---|
| `defines.segmented_unit_ai_state.patrolling` | The segmented unit is navigating its territory's patrol path. |
| `defines.segmented_unit_ai_state.investigating` | The segmented unit is investigating a location where it detected a disturbance. |
| `defines.segmented_unit_ai_state.attacking` | The segmented unit is attacking an entity that is trespassing on its territory, but the segmented unit is not using its full strength. |
| `defines.segmented_unit_ai_state.enraged_at_target` | The segmented unit is angry because it was attacked and is aggressively attacking an entity with its full strength. |
| `defines.segmented_unit_ai_state.enraged_at_nothing` | The segmented unit is angry because it was attacked but it does not have a valid attack target, so it is wandering around trying to find a valid attack target. |

## defines.segmented_unit_created_cause

| Wert | Bedeutung |
|---|---|
| `defines.segmented_unit_created_cause.map_generated` | The segmented unit was spawned naturally by the map generator. |
| `defines.segmented_unit_created_cause.script_created` | The segmented unit was created manually via script. |
| `defines.segmented_unit_created_cause.script_cloned` | The segmented unit was cloned from an existing segmented unit via script. |

## defines.selection_mode

| Wert | Bedeutung |
|---|---|
| `defines.selection_mode.select` |  |
| `defines.selection_mode.alt_select` |  |
| `defines.selection_mode.super_forced_select` |  |
| `defines.selection_mode.reverse_select` |  |
| `defines.selection_mode.alt_reverse_select` |  |

## defines.shooting

| Wert | Bedeutung |
|---|---|
| `defines.shooting.not_shooting` |  |
| `defines.shooting.shooting_enemies` |  |
| `defines.shooting.shooting_selected` |  |

## defines.signal_state

| Wert | Bedeutung |
|---|---|
| `defines.signal_state.open` | Green. |
| `defines.signal_state.closed` | Red. |
| `defines.signal_state.reserved` | Orange. |
| `defines.signal_state.reserved_by_circuit_network` | Red - From circuit network. |

## defines.space_platform_state

> Angekommen = `waiting_at_station`, unterwegs = `on_the_path`.

| Wert | Bedeutung |
|---|---|
| `defines.space_platform_state.waiting_for_starter_pack` | Waiting for a starter pack. |
| `defines.space_platform_state.starter_pack_requested` | Starter pack was requested from the logistics system. |
| `defines.space_platform_state.starter_pack_on_the_way` | Starter pack is on the way. |
| `defines.space_platform_state.on_the_path` | Following the path. |
| `defines.space_platform_state.waiting_for_departure` | Platform is ready to leave this planet and does not accept deliveries. |
| `defines.space_platform_state.no_schedule` | Doesn't have any stations in schedule. |
| `defines.space_platform_state.no_path` | Doesn't have anywhere to go. |
| `defines.space_platform_state.waiting_at_station` | Waiting at a station. |
| `defines.space_platform_state.paused` | Paused. |

## defines.target_type

| Wert | Bedeutung |
|---|---|
| `defines.target_type.entity` |  |
| `defines.target_type.equipment` |  |
| `defines.target_type.equipment_grid` |  |
| `defines.target_type.item` |  |
| `defines.target_type.logistic_cell` |  |
| `defines.target_type.logistic_network` |  |
| `defines.target_type.logistic_section` |  |
| `defines.target_type.permission_group` |  |
| `defines.target_type.planet` |  |
| `defines.target_type.player` |  |
| `defines.target_type.rail_path` |  |
| `defines.target_type.render_object` |  |
| `defines.target_type.space_platform` |  |
| `defines.target_type.surface` |  |
| `defines.target_type.train` |  |
| `defines.target_type.commandable` |  |
| `defines.target_type.custom_chart_tag` |  |
| `defines.target_type.gui_element` |  |
| `defines.target_type.cargo_hatch` |  |
| `defines.target_type.schedule` |  |
| `defines.target_type.territory` |  |
| `defines.target_type.segmented_unit` |  |
| `defines.target_type.electric_network` |  |
| `defines.target_type.electric_sub_network` |  |
| `defines.target_type.force` |  |

## defines.territory_created_cause

| Wert | Bedeutung |
|---|---|
| `defines.territory_created_cause.map_generated` | The territory was spawned naturally by the map generator. |
| `defines.territory_created_cause.script_created` | The territory was created manually via script. |

## defines.train_state

> Ein `path_lost` gibt es nicht; „kein Weg“ ist `no_path`.

| Wert | Bedeutung |
|---|---|
| `defines.train_state.on_the_path` | Normal state -- following the path. |
| `defines.train_state.no_schedule` | Doesn't have anywhere to go. |
| `defines.train_state.no_path` | Has no path and is stopped. |
| `defines.train_state.arrive_signal` | Braking before a rail signal. |
| `defines.train_state.wait_signal` | Waiting at a signal. |
| `defines.train_state.arrive_station` | Braking before a station. |
| `defines.train_state.manual_control_stop` | Switched to manual control and has to stop. |
| `defines.train_state.manual_control` | Can move if user explicitly sits in and rides the train. |
| `defines.train_state.wait_station` | Waiting at a station. |
| `defines.train_state.destination_full` | Same as no_path but all candidate train stops are full |

## defines.transport_line

| Wert | Bedeutung |
|---|---|
| `defines.transport_line.left_line` |  |
| `defines.transport_line.right_line` |  |
| `defines.transport_line.left_underground_line` |  |
| `defines.transport_line.right_underground_line` |  |
| `defines.transport_line.secondary_left_line` |  |
| `defines.transport_line.secondary_right_line` |  |
| `defines.transport_line.left_split_line` |  |
| `defines.transport_line.right_split_line` |  |
| `defines.transport_line.secondary_left_split_line` |  |
| `defines.transport_line.secondary_right_split_line` |  |

## defines.wire_connector_id

> Damit holt man Netze (`entity.get_circuit_network(id)`) und verbindet Kabel (`entity.get_wire_connector(id, true).connect_to(...)`). Ein `defines.circuit_connector` gibt es nicht.

| Wert | Bedeutung |
|---|---|
| `defines.wire_connector_id.circuit_red` |  |
| `defines.wire_connector_id.circuit_green` |  |
| `defines.wire_connector_id.combinator_input_red` |  |
| `defines.wire_connector_id.combinator_input_green` |  |
| `defines.wire_connector_id.combinator_output_red` |  |
| `defines.wire_connector_id.combinator_output_green` |  |
| `defines.wire_connector_id.pole_copper` |  |
| `defines.wire_connector_id.power_switch_left_copper` |  |
| `defines.wire_connector_id.power_switch_right_copper` |  |

## defines.wire_origin

| Wert | Bedeutung |
|---|---|
| `defines.wire_origin.player` | These wires can be modified by players, scripts, and the game. |
| `defines.wire_origin.script` | These wires can be modified by scripts and the game. |
| `defines.wire_origin.radars` | These wires can only be modified by the game. |

## defines.wire_type

> Nur noch als Eigenschaft (z. B. `LuaCircuitNetwork.wire_type`), nicht als Parameter von `get_circuit_network`.

| Wert | Bedeutung |
|---|---|
| `defines.wire_type.red` |  |
| `defines.wire_type.green` |  |
| `defines.wire_type.copper` |  |
