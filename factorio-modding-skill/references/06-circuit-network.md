# Circuit Network API Reference

> **⚠️ Version-Hinweis:** Stand Factorio 2.1.11 experimental. Bei Unsicherheit über aktuelle Circuit-APIs IMMER gegen die offizielle Doku verifizieren: [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/). Factorio 2.1 (experimental) ändert sich wöchentlich. Wichtige 2.1-Änderungen: `circuit_exclusive_mode_of_operation` ENTFERNT — nutze `set_requests` + `read_contents`; Labs, Pipes, Boilers, Heat Exchangers jetzt Circuit-verbindbar (2.1.7+); `LuaControlBehavior::input_networks` / `output_networks` read/write (2.1+); "Universe" Mode für Radar (2.1.7+); Selector Combinator "Time" Mode (2.1.7+).

Factorio's circuit network connects entities via wires, allowing mods to read and write signals, and control behavior.

## Wire Types

```lua
defines.wire_type.red    -- red wire
defines.wire_type.green  -- green wire
```

## Reading Circuit Networks

### From an Entity

```lua
local entity = game.surfaces["nauvis"].find_entity("constant-combinator", {10, 10})
if entity then
  local network = entity.get_circuit_network(defines.wire_type.red, 1)
  -- connector_id is 1 for main, 2 for secondary
  if network then
    for signal_id, count in pairs(network.signals) do
      local signal = signal_id.signal
      game.print(signal.type .. " " .. signal.name .. ": " .. count)
    end
  end
end
```

### LuaCircuitNetwork Properties

```lua
network.signals     -- dictionary: {signal={signal.type, signal.name}, count=10}
network.color       -- {r, g, b} wire color
network.connected_entities  -- array of entity.unit_number
```

### Signal Types

Signals use a `SignalID` structure:
```lua
{type = "item",      name = "iron-plate"}
{type = "fluid",     name = "water"}
{type = "virtual",   name = "signal-A"}
{type = "entity",    name = "assembling-machine-2"}
```

## Writing to Circuit Networks

### Constant Combinator

```lua
-- Set signals on a constant combinator
local cc = entity  -- a constant-combinator entity
local behavior = cc.get_control_behavior()

if behavior then
  -- Set section 1, slot 1
  behavior.set_slot(1, {
    signal = {type: "item", name = "iron-plate"},
    count = 100,
    index = 1,  -- slot index (1-20 for constant combinator)
  })
  
  -- Clear a slot
  behavior.set_slot(2, nil)
end
```

### Decider Combinator

```lua
local dc = entity  -- a decider-combinator
local behavior = dc.get_control_behavior()

if behavior then
  behavior.conditions = {
    {
      first_signal = {type = "item", name = "iron-plate"},
      second_signal = {type = "virtual", name = "signal-A"},
      comparator = ">",  -- "<", ">", "=", "≥", "≤", "≠"
      constant = 100,
    }
  }
  behavior.first_signal = {type = "item", name = "copper-cable"}
  behavior.second_signal = nil
  behavior.output_signal = {type = "virtual", name = "signal-X"}
  behavior.copy_count_from_input = false
end
```

### Arithmetic Combinator

```lua
local ac = entity  -- an arithmetic-combinator
local behavior = ac.get_control_behavior()

if behavior then
  behavior.first_signal = {type = "item", name = "iron-plate"}
  behavior.second_signal = {type = "virtual", name = "signal-A"}
  operation = "*"  -- "+", "-", "*", "/", "%", "^", "<<", ">>", "&", "|", "^"
  output_signal = {type = "virtual", name = "signal-X"}
end
```

### Selector Combinator

```lua
local sc = entity  -- a selector-combinator
local behavior = sc.get_control_behavior()

if behavior then
  behavior.selector = "pick-first"  -- "pick-first", "pick-last", "pick-random", "count"
  behavior.index_signal = {type = "virtual", name = "signal-A"}
end
```

## Reading from Control Behavior

```lua
local behavior = entity.get_control_behavior()
if behavior and behavior.circuit_condition then
  local condition = behavior.circuit_condition
  game.print("First signal: " .. condition.first_signal.name)
  game.print("Comparator: " .. condition.comparator)
  game.print("Constant: " .. tostring(condition.constant))
end
```

## Circuit Connection Events

```lua
script.on_event(defines.events.on_entity_settings_pasted, function(event)
  -- When circuit settings are copy-pasted between entities
  local source = event.source
  local destination = event.destination
end)
```

## Example: Circuit-Controlled Assembling Machine

```lua
-- Check circuit condition before crafting
script.on_event(defines.events.on_tick, function(event)
  if event.tick % 60 ~= 0 then return end  -- check every second
  
  for _, surface in pairs(game.surfaces) do
    local machines = surface.find_entities_filtered({
      type = "assembling-machine",
      force = "player",
    })
    
    for _, machine in ipairs(machines) do
      local network = machine.get_circuit_network(defines.wire_type.red)
      if network then
        local signal = network.signals[{type = "virtual", name = "signal-A"}]
        if signal and signal.count > 0 then
          machine.get_control_behavior().circuit_condition_satisfied = true
        else
          machine.get_control_behavior().circuit_condition_satisfied = false
        end
      end
    end
  end
end)
```

## Example: Signal Counter

```lua
-- Count total signals on a network
local function count_signals(network)
  local total = 0
  for _, signal_data in pairs(network.signals) do
    total = total + signal_data.count
  end
  return total
end

-- Example usage
local entity = game.surfaces["nauvis"].find_entity("constant-combinator", {0, 0})
if entity then
  local network = entity.get_circuit_network(defines.wire_type.red)
  if network then
    local total = count_signals(network)
    game.print("Total signal count: " .. total)
  end
end
```

## Circuit Condition Format

Conditions use the `CircuitCondition` structure:

```lua
{
  first_signal = {type = "item", name = "iron-plate"},
  second_signal = {type = "virtual", name = "signal-A"},
  comparator = ">",
  constant = 100,
  -- OR (for decider combinators):
  first_signal = {type = "item", name = "iron-plate"},
  second_constant = 50,
  comparator = "<",
}
```

## LuaAccumulatorControlBehavior

```lua
local behavior = accumulator.get_control_behavior()
behavior.circuit_mode_of_operation = defines.control_behavior.accumulator.read  -- read or charge/discharge
behavior.circuit_condition = {
  first_signal = {type = "virtual", name = "signal-A"},
  comparator = ">",
  constant = 5000,
}
```

## LuaLogisticContainerControlBehavior

```lua
local behavior = requester_chest.get_control_behavior()

-- ⚠️ 2.1: circuit_exclusive_mode_of_operation is REMOVED!
-- Use set_requests and read_contents together directly:
behavior.set_requests = true    -- 2.1+: direct read/write property
behavior.read_contents = true   -- 2.1+: direct read/write property
behavior.circuit_read_logistics = true
behavior.circuit_read_contents = true
```

## 2.1.7+ New Circuit-Connectable Entities

> **New in 2.1.7:** The following entities can now be connected to the circuit network:
> - **Labs** — Read contents, read current research cost, read technology level, set current research via conditions
> - **Pipes & Pipes-to-Ground** — Read pipeline contents and fluid temperature
> - **Storage Tanks** — Read pipeline contents and fluid temperature
> - **Boilers & Heat Exchangers** — Circuit-connectable
> - **Land Mines** — Circuit-connectable
> - **Heat Pipes** — Circuit-connectable
> - **Radar** — "Universe" mode of operation for cross-surface signal transfer (2.1.7+)
>
> Verify full control behavior properties at [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/).

## Selector Combinator — "Time" Mode (2.1.7+)

```lua
local sc = entity  -- a selector-combinator
local behavior = sc.get_control_behavior()

if behavior then
  behavior.selector = "time"  -- "pick-first", "pick-last", "pick-random", "count", "time" (2.1.7+)
  -- "time" mode reads: game tick, time of day, duration of a day
end
```

## LuaArtilleryTurretControlBehavior

```lua
local behavior = artillery.get_control_behavior()
behavior.circuit_set_target = true
behavior.circuit_target = {
  position = {x = 100, y = 200},
  surface = "nauvis",
}
```

### ⚠️ Factorio 2.1 Logistic Control Behavior Update
In Factorio 2.1, **`circuit_exclusive_mode_of_operation` and `defines.control_behavior.logistic_container.exclusive_mode` have been removed!**
Requester and buffer chests can now set requests and read contents at the same time.
Use `set_requests` and `read_contents` together directly:
```lua
local behavior = requester_chest.get_control_behavior()
behavior.set_requests = true
behavior.read_contents = true
```
