-- ============================================================
-- Space Platform Monitor — Space Age Factorio 2.1 mod
-- ============================================================
-- Demonstrates: LuaSpacePlatform, LuaCargoLandingPad,
-- cargo pod events, space platform events, platform management
-- ============================================================

script.on_init(function()
  storage.sp_monitor = {
    enabled = true,
    alert_on_landing = true,
    auto_request = true,
    monitored_platforms = {},
    last_scan_tick = 0
  }
end)

-- Track when space platforms change state
script.on_event(defines.events.on_space_platform_changed_state, function(event)
  local platform = event.space_platform
  if not platform or not platform.valid then return end

  log(string.format(
    "[SP Monitor] Platform '%s' changed state: %s → %s",
    platform.name,
    event.old_state,
    event.new_state
  ))

  -- Alert players when platform arrives
  -- Use platform.hub.force.add_custom_alert instead of per-player loop
  if event.new_state == "arrived" and storage.sp_monitor.alert_on_landing then
    local hub = platform.hub
    if hub and hub.valid then
      hub.force.add_custom_alert(
        hub,
        {type = "item", name = "space-platform-starter-pack"},
        {"", "Platform '", platform.name, "' has arrived!"},
        true  -- show on map
      )
    end
  end

  -- Update monitored platforms
  if storage.sp_monitor.monitored_platforms[platform.index] then
    storage.sp_monitor.monitored_platforms[platform.index].last_state = event.new_state
  end
end)

-- Track cargo pod deliveries
script.on_event(defines.events.on_cargo_pod_delivered_cargo, function(event)
  local pad = event.cargo_landing_pad
  if not pad or not pad.valid then return end

  log(string.format(
    "[SP Monitor] Cargo delivered to pad '%s' on surface '%s'",
    pad.name,
    pad.surface and pad.surface.name or "unknown"
  ))

  -- Log delivered items
  if event.items then
    for _, item in ipairs(event.items) do
      log(string.format(
        "  → %s x%d [%s]",
        item.name,
        item.count,
        item.quality or "normal"
      ))
    end
  end

  -- Auto-request next delivery if enabled
  if storage.sp_monitor.auto_request then
    auto_request_delivery(pad)
  end
end)

-- Track when cargo pods start ascending (launching)
script.on_event(defines.events.on_cargo_pod_started_ascending, function(event)
  log("[SP Monitor] Cargo pod ascending from " ..
    (event.cargo_landing_pad and event.cargo_landing_pad.name or "unknown"))
end)

-- Track when cargo pods finish descending (landing)
script.on_event(defines.events.on_cargo_pod_finished_descending, function(event)
  local pad = event.cargo_landing_pad
  if pad and pad.valid then
    log("[SP Monitor] Cargo pod landed at " .. pad.name)
  end
end)

-- Periodic scan of all space platforms
script.on_nth_tick(600, function(event)  -- Every 10 seconds
  if not storage.sp_monitor or not storage.sp_monitor.enabled then return end

  local platforms = game.get_space_platforms()

  for _, platform in ipairs(platforms) do
    if platform.valid then
      -- Register platform if not already monitored
      if not storage.sp_monitor.monitored_platforms[platform.index] then
        storage.sp_monitor.monitored_platforms[platform.index] = {
          name = platform.name,
          first_seen_tick = event.tick,
          last_state = platform.state
        }
        log(string.format(
          "[SP Monitor] New platform discovered: '%s'",
          platform.name
        ))
      end

      -- Log platform status summary
      local location_name = "unknown"
      if platform.space_location then
        location_name = platform.space_location.name
      elseif platform.last_visited_space_location then
        location_name = platform.last_visited_space_location.name .. " (transit)"
      end

      log(string.format(
        "[SP Monitor] Platform '%s': state=%s, location=%s, weight=%.1f, speed=%.2f",
        platform.name,
        platform.state,
        location_name,
        platform.weight or 0,
        platform.speed or 0
      ))

      -- Check if platform is paused
      if platform.paused then
        for _, player in pairs(game.connected_players) do
          player.print(string.format(
            "⚠ Platform '%s' is PAUSED at %s",
            platform.name, location_name
          ))
        end
      end
    end
  end

  storage.sp_monitor.last_scan_tick = event.tick
end)

-- Custom command: list all platforms
commands.add_command("list-platforms", "List all space platforms", function(command)
  local player = game.get_player(command.player_index)
  if not player then return end

  local platforms = game.get_space_platforms()
  if #platforms == 0 then
    player.print("No space platforms found.")
    return
  end

  player.print("=== Space Platforms ===")
  for _, platform in ipairs(platforms) do
    if platform.valid then
      local location = platform.space_location and platform.space_location.name or "in transit"
      player.print(string.format(
        "  %s — State: %s | Location: %s | Weight: %.1f | Speed: %.2f",
        platform.name, platform.state, location, platform.weight or 0, platform.speed or 0
      ))
    end
  end
end)

-- Custom command: toggle platform monitoring
commands.add_command("toggle-monitor", "Toggle space platform monitoring on/off", function(command)
  if not storage.sp_monitor then return end
  storage.sp_monitor.enabled = not storage.sp_monitor.enabled
  local player = game.get_player(command.player_index)
  if player then
    player.print("Space platform monitoring: " .. (storage.sp_monitor.enabled and "ON" or "OFF"))
  end
end)

-- Auto-request delivery to a cargo pad
function auto_request_delivery(pad)
  if not pad or not pad.valid then return end

  local behavior = pad.get_control_behavior()
  if not behavior then return end

  -- Example: request iron plates and copper plates
  local requests = {
    {item = "iron-plate", count = 200, quality = "normal"},
    {item = "copper-plate", count = 100, quality = "normal"},
  }

  for i, req in ipairs(requests) do
    behavior.set_request_slot(req, i)
  end

  log(string.format(
    "[SP Monitor] Auto-requested delivery to %s: %d items",
    pad.name, #requests
  ))
end

-- Check if a platform can leave its current location
commands.add_command("can-leave", "Check if a platform can leave its current location", function(command)
  local player = game.get_player(command.player_index)
  if not player then return end

  local param = command.parameter
  if not param then
    player.print("Usage: /can-leave <platform-name>")
    return
  end

  local platform = game.get_space_platform(param)
  if not platform or not platform.valid then
    player.print("Platform not found: " .. param)
    return
  end

  if platform:can_leave_current_location() then
    player.print(platform.name .. " CAN leave " .. (platform.space_location and platform.space_location.name or "current location"))
  else
    player.print(platform.name .. " CANNOT leave yet (waiting on deliveries)")
  end
end)
