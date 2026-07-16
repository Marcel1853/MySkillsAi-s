-- ============================================================
-- Asteroid Defense — Space Age Factorio 2.1 mod
-- ============================================================
-- Demonstrates: LuaAsteroidCollector, LuaThruster, LuaPlanet,
-- asteroid events, LuaSurface, LuaSpacePlatform surface interaction
-- ============================================================

script.on_init(function()
  storage.asteroid_defense = {
    enabled = true,
    auto_collect = true,
    alert_on_impact = true,
    total_collected = 0,
    total_impacts = 0,
    collectors = {},  -- entity_index → true
    thrusters = {}    -- entity_index → true
  }
end)

-- Track asteroid creation
script.on_event(defines.events.on_asteroid_created, function(event)
  if not storage.asteroid_defense or not storage.asteroid_defense.enabled then return end

  local asteroid = event.asteroid
  if not asteroid or not asteroid.valid then return end

  log(string.format(
    "[Asteroid Defense] Asteroid '%s' appeared at (%.1f, %.1f) on '%s'",
    asteroid.name,
    asteroid.position.x,
    asteroid.position.y,
    asteroid.surface and asteroid.surface.name or "unknown"
  ))
end)

-- Periodic scan of asteroid collectors and thrusters
script.on_nth_tick(300, function(event)
  if not storage.asteroid_defense or not storage.asteroid_defense.enabled then return end

  for _, surface in pairs(game.surfaces) do
    if surface.valid then
      -- Find all asteroid collectors on this surface
      local collectors = surface.find_entities_filtered{type = "asteroid-collector"}
      for _, collector in ipairs(collectors) do
        if collector.valid and not storage.asteroid_defense.collectors[collector.unit_number] then
          storage.asteroid_defense.collectors[collector.unit_number] = true
          log("[Asteroid Defense] New collector: " .. collector.name .. " on " .. surface.name)
        end
      end

      -- Find all thrusters on this surface
      local thrusters = surface.find_entities_filtered{type = "thruster"}
      for _, thruster in ipairs(thrusters) do
        if thruster.valid and not storage.asteroid_defense.thrusters[thruster.unit_number] then
          storage.asteroid_defense.thrusters[thruster.unit_number] = true
          log("[Asteroid Defense] New thruster: " .. thruster.name .. " on " .. surface.name)
        end
      end

      -- Find asteroid chunks (collectible but not yet collected)
      local chunks = surface.find_entities_filtered{type = "asteroid-chunk"}
      if #chunks > 0 and storage.asteroid_defense.auto_collect then
        storage.asteroid_defense.total_collected = storage.asteroid_defense.total_collected + #chunks
      end
    end
  end
end)

-- Custom command: asteroid status
commands.add_command("asteroid-status", "Show asteroid defense status", function(command)
  local player = game.get_player(command.player_index)
  if not player then return end

  local stats = storage.asteroid_defense
  player.print("=== Asteroid Defense Status ===")
  player.print("Enabled: " .. tostring(stats.enabled))
  player.print("Collectors: " .. count_valid_entities(stats.collectors))
  player.print("Thrusters: " .. count_valid_entities(stats.thrusters))
  player.print("Total collected: " .. stats.total_collected)
  player.print("Total impacts: " .. stats.total_impacts)

  -- Surface breakdown
  for _, surface in pairs(game.surfaces) do
    if surface.valid then
      local chunk_count = surface.count_entities_filtered{type = "asteroid-chunk"}
      if chunk_count > 0 then
        player.print("  " .. surface.name .. ": " .. chunk_count .. " asteroid chunks")
      end
    end
  end
end)

function count_valid_entities(entity_table)
  local count = 0
  for unit_number, _ in pairs(entity_table) do
    -- In a real mod, you'd look up the entity
    count = count + 1
  end
  return count
end
