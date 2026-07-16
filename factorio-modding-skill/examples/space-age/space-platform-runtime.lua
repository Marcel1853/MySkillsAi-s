-- ============================================================
-- EXAMPLE: Space Platform — Runtime Control Script
-- ============================================================
-- Shows how to manage a space platform: cargo delivery,
-- thruster control, asteroid collection, and platform inventory.
--
-- This is a control.lua example for a space platform management mod.
-- ============================================================

-- ===== CONFIGURATION =====

local config = {
  -- Minimum fuel to keep thrusters running
  min_fuel_threshold = 100,
  -- Auto-send cargo pods when inventory is full
  auto_send_threshold = 80,
  -- Alert players when platform health is low
  health_alert_threshold = 500,
}

-- ===== STORAGE INITIALIZATION =====

script.on_init(function()
  storage.platforms = storage.platforms or {}
  storage.cargo_log = storage.cargo_log or {}
  config.min_fuel_threshold = config.min_fuel_threshold or 100
end)

-- ===== SPACE PLATFORM LIFECYCLE =====

-- When a space platform hub is built, track it
script.on_event(defines.events.on_built_entity, function(event)
  local entity = event.entity
  if entity.name ~= "space-platform-hub" then return end

  storage.platforms[entity.unit_number] = {
    hub_unit_number = entity.unit_number,
    surface = entity.surface.name,
    position = {x = entity.position.x, y = entity.position.y},
    created_tick = game.tick,
    cargo_sent = 0,
    cargo_received = 0,
  }

  local player = game.get_player(event.player_index)
  if player then
    player.print("🚀 Space Platform Hub created on " .. entity.surface.name .. "!")
  end
end, {{filter = "name", name = "space-platform-hub"}})

-- When a platform hub is destroyed, clean up tracking
script.on_event(defines.events.on_entity_died, function(event)
  if event.entity.name ~= "space-platform-hub" then return end
  storage.platforms[event.entity.unit_number] = nil
end, {{filter = "name", name = "space-platform-hub"}})

-- ===== CARGO POD EVENTS =====

-- Cargo pod delivered items to surface
script.on_event(defines.events.on_cargo_pod_delivered_cargo, function(event)
  local surface = event.surface_index
  local items = event.cargo_items or {}

  -- Log delivery
  for _, item_data in pairs(items) do
    local log_key = surface .. "_" .. item_data.name
    storage.cargo_log[log_key] = (storage.cargo_log[log_key] or 0) + item_data.count
  end

  -- Notify players on this surface
  local surface_obj = game.surfaces[surface]
  if surface_obj then
    for _, player in pairs(surface_obj.players) do
      player.print("📦 Cargo pod delivered " .. #items .. " item types to " .. surface_obj.name)
    end
  end
end)

-- Cargo pod finished ascending (left surface)
script.on_event(defines.events.on_cargo_pod_finished_ascending, function(event)
  -- Track that cargo left this surface
  local platform = storage.platforms[event.surface_index]
  if platform then
    platform.cargo_sent = platform.cargo_sent + 1
  end
end)

-- Cargo pod finished descending (landed on surface)
script.on_event(defines.events.on_cargo_pod_finished_descending, function(event)
  -- Track cargo received
  local surface = game.surfaces[event.surface_index]
  if surface then
    for _, player in pairs(surface.players) do
      player.print("🛬 Cargo pod landed on " .. surface.name)
    end
  end
end)

-- ===== ASTEROID COLLECTION =====

-- Monitor asteroid collectors on platforms
script.on_nth_tick(600, function(event)
  -- Every 10 seconds, check all asteroid collectors
  for _, surface in pairs(game.surfaces) do
    local collectors = surface.find_entities_filtered({
      type = "asteroid-collector",
      force = "player",
    })

    for _, collector in ipairs(collectors) do
      -- Check if collector is on a space platform
      local platform_info = storage.platforms[collector.surface.name]
      if platform_info then
        -- Process collected asteroids
        -- This is where you'd handle the collected asteroid chunks
      end
    end
  end
end)

-- ===== PLATFORM HEALTH MONITORING =====

script.on_nth_tick(3600, function(event)
  -- Every minute, check platform hub health
  for unit_number, platform in pairs(storage.platforms) do
    local surface = game.surfaces[platform.surface]
    if surface then
      local hub = surface.get_entity(platform.hub_unit_number)
      if hub and hub.valid then
        if hub.health < config.health_alert_threshold then
          -- Alert all players
          for _, player in pairs(game.connected_players) do
            player.add_custom_alert(
              hub,
              {type = "item", name = "space-platform-hub"},
              {"", "⚠️ Platform hub on ", platform.surface, " is damaged! Health: ", hub.health},
              true
            )
          end
        end
      else
        -- Hub was destroyed, clean up
        storage.platforms[unit_number] = nil
      end
    end
  end
end)

-- ===== CUSTOM CONSOLE COMMANDS =====

commands.add_command("platform-status", "Show space platform status", function(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  player.print("=== Space Platform Status ===")
  local count = 0
  for unit_number, platform in pairs(storage.platforms) do
    count = count + 1
    player.print("Platform #" .. count .. ": " .. platform.surface)
    player.print("  Created: tick " .. platform.created_tick)
    player.print("  Cargo sent: " .. platform.cargo_sent)
    player.print("  Cargo received: " .. platform.cargo_received)
  end
  if count == 0 then
    player.print("No active space platforms.")
  end
end)

commands.add_command("platform-cargo-log", "Show cargo delivery log", function(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  player.print("=== Cargo Delivery Log ===")
  for key, amount in pairs(storage.cargo_log) do
    player.print(key .. ": " .. amount .. " items")
  end
end)

-- ===== ROCKET SILO INTEGRATION =====

-- When a rocket is launched with a space platform hub
script.on_event(defines.events.on_rocket_launched, function(event)
  local silo = event.rocket_silo_entity
  local rocket = event.rocket
  local player = game.get_player(event.player_index)

  -- Log the launch
  if player then
    player.print("🚀 Rocket launched from " .. silo.surface.name)
  end

  -- Check if the rocket carries a space platform hub
  local cargo = rocket.get_inventory(defines.inventory.rocket)
  if cargo then
    for i = 1, #cargo do
      local stack = cargo[i]
      if stack.valid_for_read and stack.name == "space-platform-hub" then
        -- A space platform hub is being launched!
        if player then
          player.print("🌌 Space platform hub detected in cargo!")
        end
      end
    end
  end
end)

-- ===== THRUSTER FUEL MANAGEMENT =====

-- Check thruster fuel levels periodically
script.on_nth_tick(1800, function(event)
  for _, surface in pairs(game.surfaces) do
    local thrusters = surface.find_entities_filtered({
      type = "thruster",
      force = "player",
    })

    for _, thruster in ipairs(thrusters) do
      local fuel = thruster.get_fuel_inventory()
      if fuel and fuel.get_item_count("thruster-fuel") < config.min_fuel_threshold then
        -- Low fuel warning
        local platform_info = storage.platforms[surface.name]
        if platform_info then
          for _, player in pairs(surface.players) do
            player.print("⚠️ Thruster on " .. surface.name .. " is low on fuel!")
          end
        end
      end
    end
  end
end)

-- ===== SURFACE-CONDITIONAL BEHAVIOR =====

-- Different behavior based on which surface the platform is on
local function get_surface_bonus(surface_name)
  local bonuses = {
    ["nauvis"] = {solar_power = 1.0, asteroid_rate = 1.0},
    ["vulcanus"] = {solar_power = 1.2, asteroid_rate = 0.8},
    ["gleba"] = {solar_power = 0.8, asteroid_rate = 1.5},
    ["fulgora"] = {solar_power = 1.5, asteroid_rate = 1.2},
    -- Add custom planet bonuses here
  }
  return bonuses[surface_name] or {solar_power = 1.0, asteroid_rate = 1.0}
end

-- Apply surface bonuses to platform operations
script.on_nth_tick(3600, function(event)
  for _, surface in pairs(game.surfaces) do
    local bonus = get_surface_bonus(surface.name)
    -- Could adjust platform behavior based on bonus
    -- e.g., solar panel efficiency, asteroid collection rate
  end
end)
