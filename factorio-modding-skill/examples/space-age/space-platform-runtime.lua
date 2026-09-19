-- ============================================================
-- EXAMPLE: Space Platform — Runtime Control Script (Space Age, Factorio 2.1)
-- ============================================================
-- Zeigt: Plattformen über LuaForce.platforms verwalten, Hub-Zustand prüfen,
-- Triebwerk-Treibstoff (Flüssigkeiten!), Cargo-Pods und Raketenstarts.
-- API geprüft gegen lua-api.factorio.com (2.1.19, Sept. 2026).
--
-- Stolperfallen, die hier vermieden werden:
--   * Plattformen holt man über force.platforms / force.get_space_platforms(location),
--     nicht über game.* und nicht über „gebaute Hubs“ (den Hub baut das Spiel).
--   * Jeder on_nth_tick-Intervall hat genau EINEN Handler – ein zweiter Aufruf mit
--     demselben Intervall ersetzt den ersten. Arbeit daher in einem Handler bündeln.
--   * Triebwerke verbrauchen Flüssigkeiten (thruster-fuel, thruster-oxidizer),
--     kein Brennstoff-Inventar.
--   * on_rocket_launched liefert rocket und rocket_silo (kein player_index).
-- ============================================================

local config = {
  min_thruster_fluid = 100,   -- Warnung unter dieser Menge
  hub_health_alert = 0.5,     -- Anteil der maximalen Gesundheit
}

script.on_init(function()
  storage.platform_stats = {} -- [platform.index] = { launches = n, pods_landed = n }
end)

local function stats_of(platform)
  local s = storage.platform_stats[platform.index]
  if not s then
    s = { launches = 0, pods_landed = 0 }
    storage.platform_stats[platform.index] = s
  end
  return s
end

-- ===== EIN Handler für alle Minuten-Prüfungen =====
script.on_nth_tick(3600, function()
  for _, force in pairs(game.forces) do
    for _, platform in pairs(force.platforms) do
      if platform.valid and platform.surface then
        -- Hub-Zustand
        local hub = platform.hub
        if hub and hub.valid and hub.max_health > 0 and hub.health / hub.max_health < config.hub_health_alert then
          force.add_custom_alert(hub, { type = "item", name = "space-platform-hub" },
            { "", "Platform hub of ", platform.name, " is damaged" }, true)
        end
        -- Triebwerke: Treibstoff und Oxidationsmittel sind Flüssigkeiten
        for _, thruster in pairs(platform.surface.find_entities_filtered({ type = "thruster" })) do
          local fuel = thruster.get_fluid_count("thruster-fuel")
          local oxidizer = thruster.get_fluid_count("thruster-oxidizer")
          if fuel < config.min_thruster_fluid or oxidizer < config.min_thruster_fluid then
            force.add_custom_alert(thruster, { type = "fluid", name = "thruster-fuel" },
              { "", "Thruster on ", platform.name, " is low on fluid" }, true)
          end
        end
      end
    end
  end
end)

-- ===== Raketenstart (Event-Daten: rocket, rocket_silo) =====
script.on_event(defines.events.on_rocket_launched, function(event)
  local silo = event.rocket_silo
  if silo and silo.valid then
    log("[Platform] Rocket launched from " .. silo.surface.name)
  end
end)

-- ===== Cargo-Pods (Event-Daten: cargo_pod, launched_by_rocket, player_index?) =====
script.on_event(defines.events.on_cargo_pod_finished_descending, function(event)
  local pod = event.cargo_pod
  if not (pod and pod.valid) then return end
  local platform = pod.surface.platform -- nil, wenn auf einem Planeten gelandet
  if platform then stats_of(platform).pods_landed = stats_of(platform).pods_landed + 1 end
end)

-- ===== Befehl: Übersicht =====
commands.add_command("platform-status", "Show the space platforms of your force", function(command)
  local player = game.get_player(command.player_index)
  if not player then return end
  local count = 0
  for _, platform in pairs(player.force.platforms) do
    if platform.valid then
      count = count + 1
      local where = platform.space_location and platform.space_location.name or "in transit"
      local s = stats_of(platform)
      player.print(("%s: %s, speed %.1f, pods landed %d"):format(platform.name, where, platform.speed, s.pods_landed))
    end
  end
  if count == 0 then player.print("No space platforms.") end
end)
