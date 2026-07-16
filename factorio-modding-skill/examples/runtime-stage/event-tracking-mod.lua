-- ============================================================
-- EXAMPLE: Runtime Event Handling
-- ============================================================
-- Demonstrates key runtime patterns: event handling, storage,
-- entity tracking, tick-based operations, and player interaction.
-- ============================================================

-- ===== STORAGE INITIALIZATION =====

script.on_init(function()
  storage.events_processed = 0
  storage.player_activity = {}  -- player_index → {last_seen, actions}
  storage.tracked_entities = {}  -- unit_number → {name, tick_placed}
  storage.config = {
    announce_builds = true,
    track_machines = true,
    tick_interval = 60,
  }
end)

-- ===== PLAYER JOINED =====

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  -- Initialize player tracking
  storage.player_activity[player.index] = {
    last_seen = game.tick,
    actions = 0,
    name = player.name,
  }

  -- Welcome message
  player.print("Welcome, " .. player.name .. "! This mod is tracking your activity.")

  -- Give starting items (example)
  if player.character then
    player.insert({name = "iron-plate", count = 50})
    player.insert({name = "copper-plate", count = 50})
  end
end)

-- ===== PLAYER LEFT =====

script.on_event(defines.events.on_player_left_game, function(event)
  local activity = storage.player_activity[event.player_index]
  if activity then
    activity.last_seen = game.tick
  end
end)

-- ===== BUILD TRACKING =====

script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.entity
  if not entity or not entity.valid then return end

  storage.events_processed = storage.events_processed + 1

  -- Update player activity
  local activity = storage.player_activity[event.player_index]
  if activity then
    activity.last_seen = game.tick
    activity.actions = activity.actions + 1
  end

  -- Track machines
  if storage.config.track_machines then
    local machine_types = {
      "assembling-machine", "furnace", "boiler", "generator",
      "mining-drill", "chemical-plant", "oil-refinery",
    }
    for _, mtype in ipairs(machine_types) do
      if entity.type == mtype then
        storage.tracked_entities[entity.unit_number] = {
          name = entity.name,
          type = mtype,
          tick_placed = game.tick,
          surface = entity.surface.name,
        }
        break
      end
    end
  end

  -- Announce builds (only for certain machines)
  if storage.config.announce_builds then
    local important_machines = {
      ["rocket-silo"] = "Rocket Silo",
      ["space-platform-hub"] = "Space Platform Hub",
      ["nuclear-reactor"] = "Nuclear Reactor",
    }
    local display_name = important_machines[entity.name]
    if display_name then
      for _, player in pairs(game.connected_players) do
        player.print("⚠ " .. player.name .. " built a " .. display_name .. "!")
      end
    end
  end
end, {
  {filter = "type", type = "assembling-machine"},
  {filter = "type", type = "furnace"},
  {filter = "type", type = "boiler"},
  {filter = "type", type = "generator"},
  {filter = "type", type = "mining-drill"},
  {filter = "type", type = "chemical-plant"},
  {filter = "type", type = "oil-refinery"},
  {filter = "type", type = "rocket-silo"},
  {filter = "type", type = "space-platform-hub"},
  {filter = "type", type = "nuclear-reactor"},
})

-- ===== MINE TRACKING =====

script.on_event(defines.events.on_player_mined_entity, function(event)
  local entity = event.entity
  if not entity or not entity.valid then return end

  -- Remove from tracking
  storage.tracked_entities[entity.unit_number] = nil

  local activity = storage.player_activity[event.player_index]
  if activity then
    activity.actions = activity.actions + 1
  end
end)

-- ===== ENTITY DIED (BITER ATTACKS) =====

script.on_event(defines.events.on_entity_died, function(event)
  local entity = event.entity
  local cause = event.cause

  -- Track biter kills
  if cause and cause.valid and cause.type == "unit" then
    local activity = storage.player_activity[event.player_index]
    if activity then
      activity.actions = activity.actions + 1
    end
  end

  -- Announce important entity deaths
  if entity.type == "rocket-silo" or entity.type == "space-platform-hub" then
    for _, player in pairs(game.connected_players) do
      player.print("💥 " .. entity.name .. " was destroyed!")
    end
  end
end, {
  {filter = "type", type = "rocket-silo"},
  {filter = "type", type = "space-platform-hub"},
  {filter = "type", type = "unit"},
})

-- ===== TICK-BASED OPERATIONS =====

script.on_nth_tick(60, function(event)
  -- Print summary every second
  storage.events_processed = storage.events_processed + 1

  -- Clean up invalid tracked entities
  local to_remove = {}
  for unit_number, info in pairs(storage.tracked_entities) do
    local surface = game.surfaces[info.surface]
    if surface then
      local entity = surface.get_entity(unit_number)
      if not entity or not entity.valid then
        table.insert(to_remove, unit_number)
      end
    end
  end
  for _, un in ipairs(to_remove) do
    storage.tracked_entities[un] = nil
  end
end)

-- ===== PLAYER CHAT COMMANDS =====

script.on_event(defines.events.on_console_chat, function(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  local message = event.message
  if message == "/status" then
    player.print("Events processed: " .. storage.events_processed)
    player.print("Tracked entities: " .. serpent.line(storage.tracked_entities))
    player.print("Player activity:")
    for idx, act in pairs(storage.player_activity) do
      player.print("  " .. act.name .. ": " .. act.actions .. " actions")
    end
  elseif message == "/clear" then
    storage.tracked_entities = {}
    storage.events_processed = 0
    player.print("Storage cleared!")
  end
end)

-- ===== CUSTOM CONSOLE COMMAND =====

commands.add_command("runtime-stats", "Show runtime statistics", function(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  player.print("=== Runtime Statistics ===")
  player.print("Events processed: " .. storage.events_processed)
  player.print("Tracked entities: " .. #serpent.keys(storage.tracked_entities))
  player.print("Current tick: " .. game.tick)
  player.print("Surface count: " .. #serpent.keys(game.surfaces))
end)

-- ===== CONFIGURATION CHANGED =====

script.on_configuration_changed(function(event)
  if event.mod_changes["runtime-examples"] then
    game.print("Runtime Examples mod configuration changed!")
  end
end)
