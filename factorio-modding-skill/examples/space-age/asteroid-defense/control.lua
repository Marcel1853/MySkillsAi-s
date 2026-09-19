-- ============================================================
-- Asteroid Defense — Space Age, Factorio 2.1
-- ============================================================
-- Zeigt: Asteroiden (Entities vom Typ "asteroid") und Asteroiden-Brocken
-- (KEINE Entities, sondern AsteroidChunk-Daten über LuaSpacePlatform),
-- Kollektoren und Triebwerke per Bau-Event erfassen statt jede Oberfläche
-- zu durchsuchen. API geprüft gegen lua-api.factorio.com (2.1.19).
--
-- Hinweis: Ein Event „on_asteroid_created“ gibt es nicht. Neue Asteroiden
-- lassen sich nur durch Abfragen finden (sparsam, mit on_nth_tick).
-- ============================================================

local TRACKED = { ["asteroid-collector"] = "collectors", ["thruster"] = "thrusters" }

script.on_init(function()
  storage.asteroid_defense = {
    enabled = true,
    collectors = {}, -- [unit_number] = LuaEntity (Referenzen dürfen in storage stehen)
    thrusters = {},
  }
end)

-- Kollektoren/Triebwerke beim Bau erfassen (auf Plattformen: on_space_platform_built_entity)
local function on_built(event)
  local entity = event.entity
  local list = entity and entity.valid and TRACKED[entity.type]
  if list then storage.asteroid_defense[list][entity.unit_number] = entity end
end
local filter = { { filter = "type", type = "asteroid-collector" }, { filter = "type", type = "thruster" } }
script.on_event(defines.events.on_built_entity, on_built, filter)
script.on_event(defines.events.on_robot_built_entity, on_built, filter)
script.on_event(defines.events.on_space_platform_built_entity, on_built, filter)
script.on_event(defines.events.script_raised_built, on_built, filter)

local function count_valid(list)
  local count = 0
  for unit, entity in pairs(list) do
    if entity.valid then count = count + 1 else list[unit] = nil end
  end
  return count
end

-- Übersicht je Plattform: Asteroiden (Entities) und Brocken (AsteroidChunk)
local function platform_report(platform)
  local surface = platform.surface
  local asteroids = surface.count_entities_filtered({ type = "asteroid" })
  local chunks = platform.find_asteroid_chunks_filtered({}) -- array[AsteroidChunk]: { name, position, … }
  return ("%s: %d asteroids, %d chunks"):format(platform.name, asteroids, #chunks)
end

commands.add_command("asteroid-status", "Show asteroid defense status", function(command)
  local player = game.get_player(command.player_index)
  if not player then return end
  local stats = storage.asteroid_defense
  player.print("=== Asteroid Defense Status ===")
  player.print("Collectors: " .. count_valid(stats.collectors) .. ", thrusters: " .. count_valid(stats.thrusters))
  for _, platform in pairs(player.force.platforms) do
    if platform.valid and platform.surface then player.print("  " .. platform_report(platform)) end
  end
end)
