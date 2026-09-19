-- ============================================================
-- Space Platform Monitor — Space Age, Factorio 2.1
-- ============================================================
-- Zeigt: on_space_platform_changed_state, defines.space_platform_state,
-- LuaForce.platforms / get_space_platforms, LuaSpacePlatform (state, hub,
-- space_location, can_leave_current_location), Cargo-Pod-Events.
-- API geprüft gegen lua-api.factorio.com (2.1.19, Sept. 2026).
-- ============================================================

-- defines.space_platform_state → lesbarer Name
local STATE_NAMES = {}
for name, value in pairs(defines.space_platform_state) do STATE_NAMES[value] = name end

local function state_name(state) return STATE_NAMES[state] or tostring(state) end

script.on_init(function()
  storage.sp_monitor = { alert_on_arrival = true, platforms = {} } -- [platform.index] = { last_state }
end)

-- Plattform wechselt den Zustand. Event-Daten: platform, old_state (neuer Zustand = platform.state)
script.on_event(defines.events.on_space_platform_changed_state, function(event)
  local platform = event.platform
  if not (platform and platform.valid) then return end
  local new_state = platform.state

  log(("[SP Monitor] '%s': %s → %s"):format(platform.name, state_name(event.old_state), state_name(new_state)))

  -- Angekommen: wartet an einer Station (über einem Planeten)
  if new_state == defines.space_platform_state.waiting_at_station and storage.sp_monitor.alert_on_arrival then
    local hub = platform.hub
    if hub and hub.valid then
      local where = platform.space_location and platform.space_location.name or "?"
      hub.force.add_custom_alert(hub, { type = "item", name = "space-platform-starter-pack" },
        { "", "Platform ", platform.name, " arrived at ", where }, true) ---@diagnostic disable-line: assign-type-mismatch
    end
  end

  storage.sp_monitor.platforms[platform.index] = { last_state = new_state }
end)

-- Cargo-Pod-Events. Event-Daten laut API:
--   on_cargo_pod_delivered_cargo:      cargo_pod, spawned_container
--   on_cargo_pod_started_ascending:    cargo_pod, player_index?
--   on_cargo_pod_finished_descending:  cargo_pod, launched_by_rocket, player_index?
script.on_event(defines.events.on_cargo_pod_delivered_cargo, function(event)
  local container = event.spawned_container -- Kiste, die am Boden entsteht (falls kein Landeplatz)
  if container and container.valid then
    log("[SP Monitor] Cargo pod dropped a container on " .. container.surface.name)
  end
end)

script.on_event(defines.events.on_cargo_pod_finished_descending, function(event)
  local pod = event.cargo_pod
  if pod and pod.valid then
    log(("[SP Monitor] Cargo pod landed on %s (launched by rocket: %s)")
      :format(pod.surface.name, tostring(event.launched_by_rocket)))
  end
end)

-- Alle Plattformen einer Force: LuaForce.platforms (index → LuaSpacePlatform)
local function list_platforms(player)
  local count = 0
  for _, platform in pairs(player.force.platforms) do
    if platform.valid then
      count = count + 1
      local where = platform.space_location and platform.space_location.name or "unterwegs"
      player.print(("%s – %s – %s – kann los: %s"):format(platform.name, state_name(platform.state), where,
        tostring(platform.can_leave_current_location())))
    end
  end
  if count == 0 then player.print("No space platforms found.") end
end

commands.add_command("list-platforms", "List the space platforms of your force", function(command)
  local player = game.get_player(command.player_index)
  if player then list_platforms(player) end
end)

-- Plattformen über einem bestimmten Ort: LuaForce.get_space_platforms(location)
commands.add_command("platforms-at", "List platforms above a planet, e.g. /platforms-at nauvis", function(command)
  local player = game.get_player(command.player_index)
  if not (player and command.parameter) then return end
  local ok, platforms = pcall(player.force.get_space_platforms, command.parameter)
  if not ok then
    player.print("Unknown location: " .. command.parameter)
    return
  end
  for _, platform in pairs(platforms) do player.print(platform.name) end
end)
