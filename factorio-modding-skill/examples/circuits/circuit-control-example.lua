-- ============================================================
-- EXAMPLE: Circuit Network Integration
-- ============================================================
-- Demonstrates reading and writing circuit signals, controlling
-- entities via combinators, and responding to circuit changes.
-- ============================================================

-- ===== CIRCUIT CONTROLLED MACHINE =====

local function setup_circuit_monitoring()
  -- Monitor for circuit network changes every 60 ticks
  script.on_nth_tick(60, function(event)
    for _, surface in pairs(game.surfaces) do
      -- Find all constant combinators with our signal
      local combinators = surface.find_entities_filtered({
        name = "constant-combinator",
      })

      for _, cc in ipairs(combinators) do
        local network = cc.get_circuit_network(defines.wire_connector_id.circuit_red)
        if network then
          -- Check for our control signal (get_signal returns 0 if absent)
          if network.get_signal({type = "virtual", name = "signal-A"}) > 0 then
            -- Signal-A is positive: enable all nearby assemblers
            local assemblers = surface.find_entities_filtered({
              area = {
                {cc.position.x - 20, cc.position.y - 20},
                {cc.position.x + 20, cc.position.y + 20},
              },
              type = "assembling-machine",
            })
            for _, assembler in ipairs(assemblers) do
              assembler.disabled_by_script = false  -- 2.1 way to enable entity (NOT entity.active write!)
            end
          end
        end
      end
    end
  end)
end

-- ===== SIGNAL COUNTER DISPLAY =====

-- Write the current production count to a constant combinator
local function update_production_display()
  if not storage.production_counts then
    storage.production_counts = {}
  end

  for _, surface in pairs(game.surfaces) do
    local assemblers = surface.find_entities_filtered({type = "assembling-machine"})
    for _, assembler in ipairs(assemblers) do
      if assembler.get_recipe() then
        local recipe_name = assembler.get_recipe().name
        storage.production_counts[recipe_name] = (storage.production_counts[recipe_name] or 0) + 1

        -- Find the display combinator (placed near the assembler)
        local nearby = surface.find_entities_filtered({
          name = "constant-combinator",
          position = assembler.position,
          radius = 5,
        })
        if #nearby > 0 then
          local cc = nearby[1]
          local behavior = cc.get_control_behavior()
          if behavior then
            behavior.set_slot(1, {
              signal = {type = "virtual", name = "signal-X"},
              count = storage.production_counts[recipe_name],
              index = 1,
            })
          end
        end
      end
    end
  end
end

-- ===== ALERT ON THRESHOLD =====

-- Check if any entity exceeds a circuit-defined threshold
local function check_thresholds()
  local threshold = storage.alert_threshold or 1000

  for _, surface in pairs(game.surfaces) do
    local chests = surface.find_entities_filtered({name = "storage-chest"})
    for _, chest in ipairs(chests) do
      local network = chest.get_circuit_network(defines.wire_connector_id.circuit_red)
      if network and network.signals then
        -- Check all signals: array of { signal = SignalID, count = n }
        for _, data in pairs(network.signals) do
          local signal_id = data.signal
          if data.count >= threshold then
            -- Threshold reached! Alert the force that owns the chest
            chest.force.add_custom_alert(
              chest,
              {type = "virtual", name = "signal-A"},
              {"", "Alert: ", signal_id.name, " exceeded threshold (", data.count, ")"},
              true
            )
          end
        end
      end
    end
  end
end

-- ===== DECIDER COMBINATOR AUTOMATION =====

-- Set up a decider combinator to trigger when iron-plate count > 1000
local function setup_decider_combinator(entity)
  local behavior = entity.get_control_behavior()
  if behavior then
    behavior.conditions = {
      {
        first_signal = {type = "item", name = "iron-plate"},
        second_signal = {type = "virtual", name = "signal-A"},
        comparator = ">",
        constant = 1000,
      }
    }
    behavior.first_signal = {type = "item", name = "copper-cable"}
    behavior.second_signal = nil
    behavior.output_signal = {type = "virtual", name = "signal-X"}
    behavior.copy_count_from_input = false
  end
end

-- ===== INITIALIZATION =====

script.on_init(function()
  storage.production_counts = {}
  storage.alert_threshold = 1000
  setup_circuit_monitoring()
end)

-- Update production every 5 seconds
script.on_nth_tick(300, function(event)
  update_production_display()
end)

-- Check thresholds every second
script.on_nth_tick(60, function(event)
  check_thresholds()
end)

-- ===== ENTITY VALIDATION PATTERN =====

-- When working with circuit-controlled entities, always check .valid:
local function safely_control_entity(unit_number)
  -- Retrieve entity from storage reference
  local surface = game.surfaces["nauvis"]
  if not surface then return end

  local entity = surface.get_entity(unit_number)
  if not entity or not entity.valid then
    -- Entity was destroyed or mined — clean up
    storage.circuit_monitored[unit_number] = nil
    return
  end

  -- Safe to use entity here
  local network = entity.get_circuit_network(defines.wire_connector_id.circuit_red)
  if network then
    -- Process network signals
  end
end
