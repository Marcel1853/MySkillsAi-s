-- ============================================================
-- EXAMPLE: Train Dispatcher — Full 2.0 LuaSchedule API
-- ============================================================
-- Demonstrates the new Factorio 2.1 train system:
--   - LuaSchedule API (not the deprecated table assignment)
--   - Schedule interrupts (refuel, emergency)
--   - Train groups
--   - Wait conditions (full, empty, time, inactivity, circuit)
--   - Train state monitoring
--   - Train stop circuit integration
--   - Automatic dispatch system
-- ============================================================

-- ===== STORAGE INITIALIZATION =====

script.on_init(function()
  storage.train_registry = storage.train_registry or {}
  -- { train_id -> { group, created_tick, route, state } }
  storage.station_index = storage.station_index or {}
  -- { surface_name -> { station_name -> unit_number } }
  storage.config = storage.config or {
    auto_dispatch = true,
    fuel_threshold = 20,
    alert_on_stuck = true,
    stuck_threshold_ticks = 18000,  -- 5 minutes at 60 UPS
  }
end)

-- ===== STATION INDEXING =====

-- Index all train stops on a surface
local function index_stations(surface)
  storage.station_index[surface.name] = storage.station_index[surface.name] or {}
  for _, stop in pairs(surface.find_entities_filtered({ type = "train-stop" })) do
    storage.station_index[surface.name][stop.backer_name] = stop.unit_number
  end
end

-- Find a station by name
local function find_station(surface_name, station_name)
  local stations = storage.station_index[surface_name]
  if not stations then return nil end
  local unit_number = stations[station_name]
  if not unit_number then return nil end
  local surface = game.surfaces[surface_name]
  if not surface then return nil end
  return surface.get_entity(unit_number)
end

-- ===== TRAIN DISPATCHER =====

-- Set up a complete route for a train using the new 2.0 LuaSchedule API
local function setup_train_route(train, route_name, station_names)
  local schedule = train.get_schedule()
  if not schedule then
    game.print("Zug " .. train.id .. ": Kein Fahrplan verfügbar.")
    return false
  end

  -- Bestehende Einträge löschen
  schedule.clear_records()

  -- Jede Station als Eintrag hinzufügen
  for i, station_name in ipairs(station_names) do
    local is_last = (i == #station_names)
    schedule.add_record({
      station = station_name,
      temporary = false,
      allows_unloading = not is_last,  -- Letzte Station = nur umdrehen
      wait_conditions = {
        {
          type = is_last and "time" or "full",
          compare_type = "and",
          ticks = is_last and 60 or nil,  -- 1 Sekunde Pause am Wendepunkt
        },
      },
    })
  end

  -- Gruppe zuweisen — alle Züge in derselben Gruppe teilen sich den Fahrplan
  schedule.group = route_name

  -- Auf Automatikmodus stellen
  train.manual_mode = false

  -- Registrierung für Tracking
  storage.train_registry[train.id] = {
    group = route_name,
    route = station_names,
    created_tick = game.tick,
    last_active_tick = game.tick,
    stuck = false,
  }

  return true
end

-- ===== SCHEDULE INTERRUPTS =====

-- Häufige Interrupts zu einem Fahrplan hinzufügen
local function add_interrupts(schedule, train_id)
  if not schedule then return end

  -- Interrupt 1: Nachtanken wenn wenig Treibstoff
  schedule.add_interrupt({
    name = "Nachtanken",
    conditions = {
      {
        -- Brennstoff in irgendeiner Lok unter der Grenze (WaitConditionType, geprüft 2.1.19)
        type = "fuel_item_count_any",
        compare_type = "and",
        condition = {
          first_signal = { type = "item", name = "solid-fuel" },
          comparator = "<", -- ComparatorString; ein defines.comparator gibt es nicht
          constant = storage.config.fuel_threshold,
        },
      },
    },
    targets = {
      {
        station = "Tankstelle",
        temporary = true,
        allows_unloading = false,
        wait_conditions = {
          { type = "fuel_full", compare_type = "and" },  -- Warten bis voll
        },
      },
    },
  })

  -- Interrupt 2: Notfallstopp bei Schaltsignal
  schedule.add_interrupt({
    name = "Notfallstopp",
    conditions = {
      {
        type = "circuit",
        compare_type = "and",
        condition = {
          first_signal = { type = "virtual", name = "signal-red" },
          comparator = ">",
          constant = 0,
        },
      },
    },
    targets = {
      {
        station = "Notfall-Bucht",
        temporary = true,
        allows_unloading = true,
        wait_conditions = {
          {
            type = "circuit",
            compare_type = "and",
            condition = {
              first_signal = { type = "virtual", name = "signal-red" },
              comparator = "=",
              constant = 0,
            },
          },
        },
      },
    },
  })
end

-- ===== TRAIN CREATED EVENT =====

script.on_event(defines.events.on_train_created, function(event)
  local train = event.train
  local surface = train.front_stock.surface

  index_stations(surface)

  -- Lokomotive finden
  local loco = train.locomotives.front_movers[1]
  if not loco then
    loco = train.locomotives.back_movers[1]
  end
  if not loco then return end

  -- Route basierend auf Loktyp zuweisen
  local route_map = {
    ["locomotive"] = { "Eisenmine", "Schmelze", "Eisenmine" },
    ["nuclear-locomotive"] = { "Uranmine", "Reaktor", "Uranmine" },
  }

  local route = route_map[loco.name]
  if route then
    local route_name = loco.name .. "-route"
    if setup_train_route(train, route_name, route) then
      local schedule = train.get_schedule()
      add_interrupts(schedule, train.id)
      game.print("Zug " .. train.id .. " Route zugewiesen: " .. route_name)
    end
  end
end)

-- ===== TRAIN STATE MONITORING =====

script.on_event(defines.events.on_train_changed_state, function(event)
  local train = event.train
  local old_state = event.old_state
  local new_state = train.state -- das Event liefert nur old_state
  local registry = storage.train_registry[train.id]

  if registry then
    registry.last_active_tick = game.tick
  end

  -- Problemzustände behandeln
  if new_state == defines.train_state.no_path then
    if storage.config.alert_on_stuck then
      game.print("Zug " .. train.id .. " hat keine Route! Gleise prüfen.")
      -- Use train.front_stock.force.add_custom_alert instead of per-player loop
      local front = train.front_stock
      if front and front.valid then
        front.force.add_custom_alert(
          front,
          { type = "item", name = "locomotive" },
          { "", "Zug ", tostring(train.id), " hat den Weg verloren!" }, ---@diagnostic disable-line: assign-type-mismatch
          true
        )
      end
    end

    -- Route neu berechnen
    train.recalculate_path()

    if registry then
      registry.stuck = true
    end

  elseif new_state == defines.train_state.destination_full then
    -- Zielbahnhof ist voll — Zug wartet bis Platz ist
    if registry then
      game.print("Zug " .. train.id .. " wartet: Zielbahnhof voll")
    end

  elseif new_state == defines.train_state.wait_station then
    -- Zug am Bahnhof angekommen
    if registry then
      registry.stuck = false  -- Entfesten falls er feststeckte
    end
  end
end)

-- ===== TRAIN SCHEDULE CHANGED =====

script.on_event(defines.events.on_train_schedule_changed, function(event)
  local train = event.train
  local player = game.get_player(event.player_index)
  local schedule = train.get_schedule()

  if player and schedule then
    local record_count = schedule.get_record_count()
    local interrupt_count = schedule.interrupt_count
    player.print("Zug " .. train.id .. " Fahrplan aktualisiert: " .. record_count .. " Halte, " .. interrupt_count .. " Interrupts")
  end
end)

-- ===== FESTGEFAHRENE ZUEGE ERKENNEN =====

-- Alle 60 Sekunden prüfen ob ein Zug feststeckt
script.on_nth_tick(36000, function(event)
  if not storage.config.alert_on_stuck then return end

  for train_id, registry in pairs(storage.train_registry) do
    if registry.stuck then
      local stuck_duration = event.tick - registry.last_active_tick
      if stuck_duration > storage.config.stuck_threshold_ticks then
        for _, player in pairs(game.connected_players) do
          player.print("Zug " .. train_id .. " seit " .. math.floor(stuck_duration / 60) .. " Sekunden fest!")
        end
      end
    end
  end
end)

-- ===== BAHNHOF SCHALTNETZ-INTEGRATION =====

-- Bahnhöfe über Schaltsignale steuern
script.on_nth_tick(600, function(event)
  for _, surface in pairs(game.surfaces) do
    local stops = surface.find_entities_filtered({ type = "train-stop" })
    for _, stop in ipairs(stops) do
      local behavior = stop.get_control_behavior()
      if behavior then
        -- Schaltsignale aktivieren (LuaTrainStopControlBehavior, geprüft 2.1.19)
        behavior.read_from_train = true      -- Inhalt des haltenden Zugs ausgeben
        behavior.read_stopped_train = true   -- ID des haltenden Zugs ausgeben
        behavior.read_trains_count = true    -- Anzahl Züge auf dem Weg ausgeben

        -- Dynamisches Zuglimit per Schaltsignal: entweder die Haltestelle selbst lesen lassen …
        -- behavior.set_trains_limit = true
        -- behavior.trains_limit_signal = { type = "virtual", name = "signal-L" }
        -- … oder per Script aus einem Signal setzen:
        local network = stop.get_circuit_network(defines.wire_connector_id.circuit_green)
        if network then
          local limit = network.get_signal({ type = "virtual", name = "signal-A" })
          if limit > 0 then stop.trains_limit = limit end
        end
      end
    end
  end
end)

-- ===== AUTO-VERLADUNG =====

-- Züge automatisch beladen wenn sie am Bahnhof warten
local function get_train_contents(train)
  return train.get_contents()
end

-- Alle 10 Sekunden prüfen
script.on_nth_tick(600, function(event)
  if not storage.config.auto_dispatch then return end

  for _, surface in pairs(game.surfaces) do
    local trains = surface.get_trains()
    for _, train in pairs(trains) do
      -- Prüfen ob Zug am Bahnhof wartet
      if train.state == defines.train_state.wait_station then
        local contents = train.get_contents()
        -- Wenn Zug leer und an Ladestation, bereit zum Abfahren
        if #contents == 0 then
          -- Hier könnte Beladungslogik stehen
        end
      end
    end
  end
end)

-- ===== KONSOLENBEFEHLE =====

commands.add_command("zug-liste", "Alle registrierten Züge auflisten", function(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  player.print("=== Registrierte Züge ===")
  for train_id, registry in pairs(storage.train_registry) do
    local status = registry.stuck and "FESTGEFAHREN" or "OK"
    player.print("Zug " .. train_id .. " [" .. registry.group .. "] " .. status)
    player.print("  Route: " .. table.concat(registry.route, " -> "))
  end
end)

commands.add_command("zug-bahnhoefe", "Alle indexierten Bahnhöfe auflisten", function(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  player.print("=== Indexierte Bahnhöfe ===")
  for surface_name, stations in pairs(storage.station_index) do
    player.print("Oberfläche: " .. surface_name)
    for name, _ in pairs(stations) do
      player.print("  - " .. name)
    end
  end
end)

commands.add_command("zug-fest", "Zug als festgefahren markieren (Test)", function(event)
  local player = game.get_player(event.player_index)
  if not player then return end

  local param = event.parameter
  if not param then
    player.print("Benutzung: /zug-fest <zug_id>")
    return
  end

  local train_id = tonumber(param)
  if train_id and storage.train_registry[train_id] then
    storage.train_registry[train_id].stuck = true
    player.print("Zug " .. train_id .. " als festgefahren markiert")
  else
    player.print("Zug " .. (train_id or param) .. " nicht gefunden")
  end
end)

-- ===== OBERFLAECHE ERSTELLT/GELOESCHT =====

script.on_event(defines.events.on_surface_created, function(event)
  local surface = game.surfaces[event.surface_index]
  if surface then
    index_stations(surface)
  end
end)

-- ===== BAHNHOEFE PERIODISCH NEU INDEXIEREN =====

-- Neue Bahnhöfe können gebaut werden; alle 5 Minuten neu indexieren
script.on_nth_tick(18000, function(event)
  for _, surface in pairs(game.surfaces) do
    index_stations(surface)
  end
end)
