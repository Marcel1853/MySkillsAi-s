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
        local network = cc.get_circuit_network(defines.wire_type.red)
        if network and network.signals then
          -- Check for our control signal
          local control_signal = network.signals[{type = "virtual", name = "signal-A"}]
          if control_signal and control_signal.count > 0 then
            -- Signal-A is positive: enable all nearby assemblers
            local assemblers = surface.find_entities_filtered({
              area = {
                {cc.position.x - 20, cc.position.y - 20},
                {cc.position.x + 20, cc.position.y + 20},
              },
              type = "assembling-machine",
            })
            for _, assembler in ipairs(assemblers) do
              -- assembler.crafting_active = true  -- if supported
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
      local network = chest.get_circuit_network(defines.wire_type.red)
      if network and network.signals then
        -- Check all signals
        for signal_id, data in pairs(network.signals) do
          if data.count >= threshold then
            -- Threshold reached! Alert nearby players
            for _, player in pairs(game.connected_players) do
              local dist = player.position.x - chest.position.x
              if math.abs(dist) < 100 then
                player.add_custom_alert(
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
  local network = entity.get_circuit_network(defines.wire_type.red)
  if network then
    -- Process network signals
  end
end
