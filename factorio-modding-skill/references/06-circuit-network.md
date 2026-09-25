# Circuit Network API Reference

> **⚠️ Version-Hinweis:** Stand Factorio 2.1.11 experimental. Bei Unsicherheit über aktuelle Circuit-APIs IMMER gegen die offizielle Doku verifizieren: [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/). Factorio 2.1 (experimental) ändert sich wöchentlich. Wichtige 2.1-Änderungen: `circuit_exclusive_mode_of_operation` ENTFERNT — nutze `set_requests` + `read_contents`; Labs, Pipes, Boilers, Heat Exchangers jetzt Circuit-verbindbar (2.1.7+); `LuaControlBehavior::input_networks` / `output_networks` read/write (2.1+); "Universe" Mode für Radar (2.1.7+); Selector Combinator "Time" Mode (2.1.7+).

Factorio's circuit network connects entities via wires, allowing mods to read and write signals, and control behavior.

## Wire Connectors (2.x)

`get_circuit_network` nimmt **eine** `defines.wire_connector_id` (geprüft 2.1.19):

```lua
defines.wire_connector_id.circuit_red         -- normale Entities (Kisten, Haltestellen, Konstanten-Combinator …)
defines.wire_connector_id.circuit_green
defines.wire_connector_id.combinator_input_red   -- Eingang von Rechen-/Entscheider-/Wähler-Combinator
defines.wire_connector_id.combinator_input_green
defines.wire_connector_id.combinator_output_red  -- Ausgang
defines.wire_connector_id.combinator_output_green
```

`defines.wire_type` (red/green/copper) gibt es weiter, z. B. als Eigenschaft `network.wire_type` –
aber nicht mehr als Parameter von `get_circuit_network`.

Kabel verbinden: `a.get_wire_connector(id_a, true).connect_to(b.get_wire_connector(id_b, true))`
(liefert `false`, wenn zu weit – Standardreichweite 9 Felder).

## Reading Circuit Networks

### From an Entity

```lua
local entity = game.surfaces["nauvis"].find_entity("constant-combinator", {10, 10})
if entity then
  local network = entity.get_circuit_network(defines.wire_connector_id.circuit_red)
  if network then
    -- signals: array von { signal = SignalID, count = n } (nil, wenn leer)
    for _, s in pairs(network.signals or {}) do
      game.print((s.signal.type or "item") .. " " .. s.signal.name .. ": " .. s.count)
    end
    -- einzelnes Signal:
    local a = network.get_signal({ type = "virtual", name = "signal-A" })
  end
end
```

### LuaCircuitNetwork Properties

```lua
network.signals                -- array[Signal]? : { {signal = SignalID, count = 10}, … } (Stand letzter Tick)
network.get_signal(signal_id)  -- Wert eines Signals (0, wenn nicht da)
network.network_id             -- ID des Netzes
network.wire_type              -- defines.wire_type
network.wire_connector_id      -- defines.wire_connector_id, über den das Netz geholt wurde
network.connected_circuit_count
network.entity                 -- Entity, von dem das Netz geholt wurde
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

Since 2.0 the signals live in **logistic sections**, not directly on the control behavior:
`behavior.get_section(n)` / `add_section()` → `LuaLogisticSection.set_slot(index, LogisticFilter)`.
A `LogisticFilter` is `{value = SignalFilter, min = count}` — there is no `signal`/`count` pair.

```lua
-- Set signals on a constant combinator
local cc = entity  -- a constant-combinator entity
local behavior = cc.get_or_create_control_behavior()
local section = behavior.get_section(1) or behavior.add_section()

if section then
  section.filters = {}  -- clear the whole section

  -- Item, with quality
  section.set_slot(1, {
    value = {type = "item", name = "iron-plate", quality = "normal", comparator = "="},
    min = 100,
  })

  -- Own virtual signal: with min ~= 0 the filter must be "trivial", i.e. quality AND
  -- comparator set — otherwise: "Can't specify non zero request with non trivial item
  -- filter condition".
  section.set_slot(2, {
    value = {type = "virtual", name = "signal-A", quality = "normal", comparator = "="},
    min = -400,  -- negative values are allowed
  })

  section.clear_slot(3)
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
-- Monitor a circuit signal and disable/enable entity via script
script.on_event(defines.events.on_tick, function(event)
  if event.tick % 60 ~= 0 then return end  -- check every second
  
  for _, surface in pairs(game.surfaces) do
    local machines = surface.find_entities_filtered({
      type = "assembling-machine",
      force = "player",
    })
    
    for _, machine in ipairs(machines) do
      local behavior = machine.get_control_behavior()
      if behavior then
        -- Read the circuit condition result (read-only!)
        -- circuit_condition_satisfied tells you if the condition is met
        local satisfied = behavior.circuit_condition_satisfied
        -- Use disabled_by_script to control the entity (NOT entity.active write!)
        machine.disabled_by_script = not satisfied
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
  for _, signal_data in pairs(network.signals or {}) do
    total = total + signal_data.count
  end
  return total
end

-- Example usage
local entity = game.surfaces["nauvis"].find_entity("constant-combinator", {0, 0})
if entity then
  local network = entity.get_circuit_network(defines.wire_connector_id.circuit_red)
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
-- LuaAccumulatorControlBehavior (geprüft 2.1.19): Ladestand als Signal ausgeben
behavior.read_charge = true
behavior.output_signal = {type = "virtual", name = "signal-A"}
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
In Factorio 2.x, **`circuit_exclusive_mode_of_operation` and the old logistic-container exclusive mode no longer exist.**
Requester and buffer chests can now set requests and read contents at the same time.
Use `set_requests` and `read_contents` together directly:
```lua
local behavior = requester_chest.get_control_behavior()
behavior.set_requests = true
behavior.read_contents = true
```
