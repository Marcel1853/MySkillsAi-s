# Train API Reference (Factorio 2.1)

> **⚠️ Version-Hinweis:** Stand Factorio 2.1.11 experimental. Bei Unsicherheit über aktuelle Methoden/Signaturen IMMER gegen die offizielle Doku verifizieren: [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/). Factorio 2.1 ist experimental und ändert sich wöchentlich. Eigenschaften ohne expliziten Versionshinweis gelten seit 2.0+.

## Table of Contents

- [Key Concepts](#key-concepts)
  - [LuaTrain](#luatrain)
  - [LuaSchedule NEW in 2.0](#luaschedule-new-in-2.0)
  - [Schedule Interrupts NEW in 2.0](#schedule-interrupts-new-in-2.0)
  - [Train Groups NEW in 2.0](#train-groups-new-in-2.0)
- [LuaTrain — Properties](#luatrain-—-properties)
- [LuaTrain — Inventory Operations](#luatrain-—-inventory-operations)
  - [Items](#items)
  - [Fluids](#fluids)
- [LuaTrain — Movement Control](#luatrain-—-movement-control)
- [LuaSchedule — The New 2.0 Schedule API](#luaschedule-—-the-new-2.0-schedule-api)
  - [Getting the Schedule](#getting-the-schedule)
  - [Records](#records)
  - [Record Position Format](#record-position-format)
- [Wait Conditions](#wait-conditions)
  - [Wait Condition Types](#wait-condition-types)
  - [Comparators](#comparators)
  - [Adding Wait Conditions](#adding-wait-conditions)
  - [Wait Condition Logic DNF](#wait-condition-logic-dnf)
- [Schedule Interrupts NEW in 2.0](#schedule-interrupts-new-in-2.0)
  - [Interrupt Structure](#interrupt-structure)
  - [Adding Interrupts](#adding-interrupts)
  - [Managing Interrupts](#managing-interrupts)
  - [Interrupt Trigger Conditions](#interrupt-trigger-conditions)
- [Train Groups NEW in 2.0](#train-groups-new-in-2.0)
- [Train States defines.train_state](#train-states-defines.train_state)
- [Train Events](#train-events)
- [Train Stop Control Behavior](#train-stop-control-behavior)
- [LuaRailEnd](#luarailend)
- [Best Practices](#best-practices)


- [Key Concepts](#)
- [LuaTrain — Properties](#)
- [LuaTrain — Inventory Operations](#)
- [LuaTrain — Movement Control](#)
- [LuaSchedule — The New 2.0 Schedule API](#)
- [Wait Conditions](#)
- [Schedule Interrupts (NEW in 2.0)](#)
- [Train Groups (NEW in 2.0)](#)
- [Train States (defines.train_state)](#)
- [Train Events](#)
- [Train Stop Control Behavior](#)
- [LuaRailEnd](#)
- [Best Practices](#)



Factorio 2.0 introduced a completely new train schedule API (`LuaSchedule`), schedule interrupts, train groups, and programmatic train management.

---

## Key Concepts

### LuaTrain

A `LuaTrain` is a connected sequence of rolling stock (locomotives + wagons). Access it from any carriage:

```lua
local loco = surface.find_entity("locomotive", {0, 0})
if loco and loco.valid then
  local train = loco.train  -- This is a LuaTrain
end
```

### LuaSchedule (NEW in 2.0)

The schedule is no longer a plain table — it's now a `LuaSchedule` object with methods to manipulate records, wait conditions, and interrupts independently.

> **⚠️ Important**: The old `train.schedule = { current = 1, records = {...} }` pattern still works but **overwrites all interrupts** and is considered deprecated. Use the new `LuaSchedule` API instead.

### Schedule Interrupts (NEW in 2.0)

Interrupts allow a train to deviate from its normal schedule when a condition is met (e.g., "low on fuel" → go to refueling station). Interrupts can be shared across trains in the same group.

### Train Groups (NEW in 2.0)

Trains in the same group share schedules and interrupts. Changing one train's schedule changes all trains in the group.

---

## LuaTrain — Properties

```lua
local train = loco.train

train.valid                          -- boolean
train.id                             -- unique train ID (number)
train.manual_mode                    -- boolean: true = player/script controlled
train.speed                          -- current speed (m/s)
train.max_forward_speed              -- max speed forward (depends on locomotive + fuel)
train.max_backward_speed             -- max speed backward
train.weight                         -- total weight in kg
train.state                          -- defines.train_state
train.path                           -- LuaPath object (or nil)
train.carriages                      -- array of LuaEntity (all rolling stock)
train.locomotives                    -- table: { front_movers = {...}, back_movers = {...} }
train.cargo_wagons                   -- array of LuaEntity (cargo wagons only)
train.fluid_wagons                   -- array of LuaEntity (fluid wagons only)
```

---

## LuaTrain — Inventory Operations

### Items

```lua
-- Get total count of an item across all cargo wagons
local iron_count = train.get_item_count("iron-plate")

-- Get all items and their counts
local contents = train.get_contents()
-- Returns: { { name = "iron-plate", count = 500, quality = "normal" }, ... }

-- Insert items into the train
train.insert({ name = "iron-plate", count = 100 })

-- Remove items from the train
train.remove_item({ name = "iron-plate", count = 50 })

-- Clear all items
train.clear_items_inside()
```

### Fluids

```lua
-- Get total amount of a fluid across all fluid wagons
local water_count = train.get_fluid_count("water")

-- Get all fluids and their amounts
local fluid_contents = train.get_fluid_contents()
-- Returns: { ["water"] = 5000, ["crude-oil"] = 3000 }

-- Insert fluid
train.insert_fluid({ name = "water", amount = 1000 })

-- Remove fluid
train.remove_fluid({ name = "water", amount = 500 })

-- Clear all fluids
train.clear_fluids_inside()
```

---

## LuaTrain — Movement Control

```lua
-- Set manual mode (stops automatic schedule following)
train.manual_mode = true

-- Set speed directly (only works in manual mode)
train.speed = 0.5  -- 50% of max speed

-- Go to a specific station in the schedule
local schedule = train.get_schedule()
if schedule then
  schedule.go_to_station(1)  -- Go to first station in schedule
end

-- Force recalculate path
train.recalculate_path()  -- Returns boolean (true if path found)

-- Get all rails currently under the train
local rails = train.get_rails()

-- Get rail ends
local front_rail_end = train.get_rail_end(defines.rail_direction.front)
local back_rail_end = train.get_rail_end(defines.rail_direction.back)
```

---

## LuaSchedule — The New 2.0 Schedule API

### Getting the Schedule

```lua
local train = loco.train
local schedule = train.get_schedule()  -- Returns LuaSchedule or nil
```

### Records

```lua
-- Get all records (returns array of ScheduleRecord tables)
local records = schedule.get_records()
-- Returns: {
--   { station = "Iron Mine", temporary = false, allows_unloading = true, wait_conditions = {...} },
--   { station = "Smelter", temporary = false, allows_unloading = true, wait_conditions = {...} },
-- }

-- Get a specific record
local record = schedule.get_record({ schedule_index = 1 })

-- Get the number of records
local count = schedule.get_record_count()

-- Add a new record at the end
schedule.add_record({
  station = "Refueling Station",
  temporary = false,
  allows_unloading = true,
  rail_direction = defines.rail_connection_direction.left,  -- optional
  wait_conditions = {
    { type = "time", compare_type = "and", ticks = 60 },
  },
})

-- Add a record at a specific position (index starts at 1)
schedule.add_record({
  station = "Temporary Stop",
  temporary = true,  -- Temporary stops are removed after the train leaves
}, { schedule_index = 2 })

-- Remove a record
schedule.remove_record({ schedule_index = 3 })

-- Copy a record from another schedule
local other_schedule = other_train.get_schedule()
schedule.copy_record(other_schedule, 1, 2)  -- Copy record 1 from other to index 2 here

-- Clear all records
schedule.clear_records()

-- Replace all records at once
schedule.set_records({
  { station = "A", temporary = false, wait_conditions = { ... } },
  { station = "B", temporary = false, wait_conditions = { ... } },
})
```

### Record Position Format

```lua
-- A record position identifies a specific record in the schedule
local record_position = { schedule_index = 1 }  -- 1-based index

-- For temporary records inserted by interrupts, you may need:
local record_position = { schedule_index = 3, interrupt_index = 1 }
```

---

## Wait Conditions

Wait conditions determine when a train leaves a station. They are evaluated in **disjunctive normal form (DNF)**: OR groups of AND conditions.

### Wait Condition Types

| Type | Fields | Description |
|------|--------|-------------|
| `"time"` | `ticks` | Wait for N ticks (60 ticks = 1 second) |
| `"inactivity"` | `ticks` | Wait for N seconds with no loading/unloading |
| `"empty"` | — | Wait until cargo is empty |
| `"full"` | — | Wait until cargo is full |
| `"not_empty"` | — | Wait until there is any cargo |
| `"item_count"` | `condition = { first_signal, comparator, constant }` | Wait until item count meets condition |
| `"fluid_count"` | `condition = { first_signal, comparator, constant }` | Wait until fluid amount meets condition |
| `"circuit"` | `condition = { first_signal, comparator, constant \| second_signal }` | Wait until circuit signal meets condition |
| `"passenger_present"` / `"passenger_not_present"` | — | Passenger on board / not on board |
| `"fuel_item_count_all"` / `"fuel_item_count_any"` | `condition` (fuel item) | Fuel of all / any locomotive meets condition |
| `"fuel_full"` | — | Wait until all locomotives are full |
| `"robots_inactive"`, `"destination_full_or_no_path"`, `"at_station"`, `"not_at_station"`, `"damage_taken"`, … | | see [WaitConditionType](https://lua-api.factorio.com/latest/concepts/WaitConditionType.html) (checked 2.1.19) |

> `"fuel"` and `"no_fuel"` do **not** exist.

### Comparators

Comparators are **strings** (ComparatorString) – there is no `defines.comparator`:

```lua
"<"   "≤" or "<="   "="   "≥" or ">="   ">"   "≠" or "!="
```

### Adding Wait Conditions

```lua
local schedule = train.get_schedule()

-- Add a record first
schedule.add_record({
  station = "Iron Mine",
  temporary = false,
  allows_unloading = true,
})

-- Add wait condition at the record (record_position, condition_index, type)
schedule.add_wait_condition({ schedule_index = 1 }, 1, "time")

-- Configure the wait condition
schedule.change_wait_condition({ schedule_index = 1 }, 1, {
  type = "time",
  compare_type = "and",
  ticks = 120,  -- Wait 2 seconds
})

-- Add an item count wait condition
schedule.add_wait_condition({ schedule_index = 1 }, 2, "item_count")
schedule.change_wait_condition({ schedule_index = 1 }, 2, {
  type = "item_count",
  compare_type = "and",
  condition = {
    first_signal = { type = "item", name = "iron-ore" },
    comparator = ">=",
    constant = 1000,
  },
})

-- Add a circuit wait condition
schedule.add_wait_condition({ schedule_index = 1 }, 3, "circuit")
schedule.change_wait_condition({ schedule_index = 1 }, 3, {
  type = "circuit",
  compare_type = "or",  -- This creates an OR group
  condition = {
    first_signal = { type = "virtual", name = "signal-green" },
    comparator = ">",
    constant = 0,
  },
})

-- Remove a wait condition
schedule.remove_wait_condition({ schedule_index = 1 }, 2)

-- Get wait conditions
local conditions = schedule.get_wait_conditions({ schedule_index = 1 })
local count = schedule.get_wait_condition_count({ schedule_index = 1 })
```

### Wait Condition Logic (DNF)

```
Wait until (iron-ore < 500 AND 30 seconds passed) OR (copper-ore < 500 AND 30 seconds passed)

This is DNF: (A AND B) OR (C AND B)
In Factorio, this is written as:
  Condition 1: iron-ore < 500, compare_type = "and"
  Condition 2: 30 seconds, compare_type = "or"   ← starts new OR group
  Condition 3: copper-ore < 500, compare_type = "and"
  Condition 4: 30 seconds, compare_type = "and"
```

---

## Schedule Interrupts (NEW in 2.0)

Interrupts allow a train to temporarily deviate from its schedule when a condition is met.

### Interrupt Structure

An interrupt has:
- **Name** — unique identifier, shared across trains
- **Trigger conditions** — when the interrupt activates
- **Target stations** — where the train goes when triggered
- **Can be inside other interrupts** — nesting support

### Adding Interrupts

```lua
local schedule = train.get_schedule()

-- Add an interrupt: "Go refuel when fuel is low"
schedule.add_interrupt({
  name = "Refuel When Low",
  conditions = {
    {
      type = "fuel_item_count_any",
      compare_type = "and",
      condition = {
        first_signal = { type = "item", name = "nuclear-fuel" },  -- or "rocket-fuel", etc.
        comparator = "<",
        constant = 10,
      },
    },
  },
  targets = {
    {
      station = "Refueling Station",
      temporary = true,
      allows_unloading = false,
      wait_conditions = {
        {
          type = "fuel_full",
          compare_type = "and",
        },
      },
    },
  },
})

-- Add another interrupt: "Deliver urgent items"
schedule.add_interrupt({
  name = "Urgent Delivery",
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
      station = "Emergency Dropoff",
      temporary = true,
      allows_unloading = true,
      wait_conditions = {
        { type = "empty", compare_type = "and" },
      },
    },
  },
})
```

### Managing Interrupts

```lua
local schedule = train.get_schedule()

-- Get all interrupts
local interrupts = schedule.get_interrupts()
-- Returns: { { name = "Refuel When Low", ... }, { name = "Urgent Delivery", ... } }

-- Get a specific interrupt
local interrupt = schedule.get_interrupt(1)  -- 1-based index

-- Get the number of interrupts
local count = schedule.interrupt_count

-- Remove an interrupt
schedule.remove_interrupt(2)

-- Change an interrupt
schedule.change_interrupt(1, {
  name = "Refuel When Low",
  conditions = {
    {
      type = "fuel_item_count_any",
      compare_type = "and",
      condition = {
        first_signal = { type = "item", name = "solid-fuel" },
        comparator = "<",
        constant = 50,
      },
    },
  },
  targets = {
    { station = "Coal Station", temporary = true },
  },
})

-- Rename an interrupt (affects all trains using it)
schedule.rename_interrupt("Refuel When Low", "Low Fuel Interrupt")

-- Activate an interrupt manually
schedule.activate_interrupt(1)

-- Clear all interrupts
schedule.clear_interrupts()

-- Set if an interrupt can trigger inside another interrupt
schedule.set_inside_interrupt(1, true)

-- Get if an interrupt can trigger inside another
local can_nest = schedule.get_inside_interrupt(1)
```

### Interrupt Trigger Conditions

Interrupt conditions use the same `WaitConditionType` values as wait conditions
([WaitConditionType](https://lua-api.factorio.com/latest/concepts/WaitConditionType.html), checked 2.1.19):

| Condition Type | Description |
|---------------|-------------|
| `"time"`, `"inactivity"` | ticks (`ticks = …`) |
| `"full"`, `"empty"`, `"not_empty"` | cargo state |
| `"item_count"`, `"fluid_count"`, `"circuit"` | `condition = { first_signal, comparator, constant }` |
| `"fuel_item_count_any"`, `"fuel_item_count_all"` | fuel of any / all locomotives meets `condition` |
| `"fuel_full"` | all locomotives full |
| `"passenger_present"`, `"passenger_not_present"` | passengers |
| `"destination_full_or_no_path"` | destination full or unreachable |
| `"specific_destination_full"`, `"specific_destination_not_full"` | a named stop is full / not full |
| `"at_station"`, `"not_at_station"` | train is (not) at a given station |
| `"robots_inactive"`, `"damage_taken"` | robots idle / train damaged |
| `"request_satisfied"`, `"request_not_satisfied"`, `"all_requests_satisfied"`, `"any_request_not_satisfied"`, `"any_request_zero"`, `"any_planet_import_zero"` | mainly for space platforms |

> `"fuel"`, `"no_fuel"`, `"passenger_absent"`, `"any_item"`, `"any_fluid"`, `"any_fuel"`, `"any_signal"` do **not** exist.

---

## Train Groups (NEW in 2.0)

Trains in the same group share schedules and interrupts.

```lua
local schedule = train.get_schedule()

-- Get the group this train belongs to (or nil)
local group = schedule.group

-- Set the group
schedule.group = "My Train Group"  -- Creates group if it doesn't exist

-- All trains in the same group will have their schedules updated
-- when you modify one train's schedule
```

---

## Train States (defines.train_state)

```lua
defines.train_state.on_the_path            -- Train is moving along its path
defines.train_state.wait_station           -- Train is waiting at a station
defines.train_state.manual_control         -- Train is in manual mode, player controlled
defines.train_state.manual_control_stop    -- Train is stopped in manual mode
defines.train_state.no_path                -- Train cannot reach its destination
defines.train_state.no_schedule            -- Train has no schedule
defines.train_state.arrive_signal          -- Train is arriving at a signal
defines.train_state.wait_signal            -- Train is waiting at a red signal
defines.train_state.destination_full       -- Station is full (train limit reached)
```

---

## Train Events

```lua
-- Train created (when a new train is assembled)
script.on_event(defines.events.on_train_created, function(event)
  local train = event.train
  game.print("New train created! ID: " .. train.id)
  game.print("Locomotives: " .. #train.locomotives.front_movers)
  game.print("Cargo wagons: " .. #train.cargo_wagons)
end)

-- Train changed state
script.on_event(defines.events.on_train_changed_state, function(event)
  local train = event.train
  local old_state = event.old_state
  local new_state = train.state -- das Event liefert nur old_state

  -- Map state numbers to names
  local state_names = {
    [defines.train_state.on_the_path] = "on_the_path",
    [defines.train_state.wait_station] = "wait_station",
    [defines.train_state.manual_control] = "manual_control",
    [defines.train_state.no_path] = "no_path",
    [defines.train_state.no_schedule] = "no_schedule",
  }

  game.print("Train " .. train.id .. " changed from " ..
    (state_names[old_state] or old_state) .. " to " ..
    (state_names[new_state] or new_state))
end)

-- Train schedule changed
script.on_event(defines.events.on_train_schedule_changed, function(event)
  local train = event.train
  local player = game.get_player(event.player_index)

  game.print("Train " .. train.id .. " schedule changed" ..
    (player and (" by " .. player.name) or ""))
end)
```

---

## Train Stop Control Behavior

```lua
local stop = surface.find_entity("train-stop", {0, 0})
if stop then
  local behavior = stop.get_control_behavior()

  -- Read train stop signals to circuit network
  behavior.read_train_stops = true

  -- Read train contents to circuit network
  behavior.read_trains_count = true
  behavior.read_train_contents = true

  -- Set train limit (max trains at this stop)
  behavior.set_train_limit(5)

  -- Enable/disable the stop
  behavior.disable_count_to_read_train_stops = false

  -- Open/close the stop (prevents trains from entering)
  -- This is done via the circuit network or directly:
  -- (The stop is disabled when it receives a red signal)
end
```

---

## LuaRailEnd

A `LuaRailEnd` is one end of a rail, pointing in a direction of travel. Get one from a rail
(`rail.get_rail_end(defines.rail_direction.front)`) or from a train
(`train.get_rail_end(direction)`, `train.front_end`, `train.back_end` – pointing away from the train).

```lua
local rail_end = train.front_end
rail_end.rail          -- LuaEntity: the rail this end belongs to
rail_end.direction     -- defines.rail_direction (front/back of that rail)
rail_end.location      -- RailLocation of the end
rail_end.out_signal_location  -- where an outgoing signal would sit (right of travel)
local walker = rail_end.make_copy()
walker.move_natural()         -- one rail forward the way a train would go; false at a dead end
walker.move_to_segment_end()  -- forward to the next segment boundary (switch, signal, stop)
```

---

## Building trains and loading bays by script (checked in-game, 2.1.19)

```lua
-- A train that must NOT couple to whatever stands nearby: build every carriage with
-- auto_connect = false and couple them yourself.
local parts = {}
for i, name in ipairs({"locomotive", "cargo-wagon", "locomotive"}) do
  local part = surface.create_entity({
    name = name, position = {x, y + 7 * (i - 1)}, direction = defines.direction.north,
    force = force, auto_connect = false,
  })
  if not part then return end                              -- no rail here (or an elevated rail above)
  parts[i] = part
  if i > 1 and not part.connect_rolling_stock(defines.rail_direction.front) then return end
end
local train = parts[1].train
if #train.carriages ~= #parts then return end              -- safety net: something coupled anyway

parts[1].insert({name = "coal", count = 200})
local schedule = train.get_schedule()
schedule.add_record({station = "Depot", wait_conditions = {{type = "inactivity", ticks = 300}}})
schedule.go_to_station(1)
train.manual_mode = false                                  -- a scripted train starts in manual mode
```

**Positions:** the front locomotive stops 3 tiles behind the stop, every further carriage 7 tiles
behind the previous one. Take the rail from `stop.connected_rail` instead of computing it — the
stop sits 2 tiles to the right of its rail, and computed points quickly end up on the track.

**Cargo wagon filters** (useful to load only what a delivery asks for):

```lua
local inventory = wagon.get_inventory(defines.inventory.cargo_wagon)
if inventory.supports_filters() and not inventory.is_filtered() then
  inventory.sort_and_merge()
  -- false when that slot is still occupied → try again later
  inventory.set_filter(1, {name = "iron-plate", quality = "normal", comparator = "="})
  inventory.set_bar(2)          -- everything from slot 2 on is blocked for machines
end
-- undo
inventory.set_filter(1, nil)
inventory.set_bar()
```

Inserters respect both the filters and the bar, so a plain inserter at a mixed chest loads only
the filtered goods. Leave wagons alone where the player set filters (`is_filtered()`) or a bar
(`get_bar() <= #inventory`).

**Elevated rails (2.1):** signals belonging to an elevated track need
`rail_layer = defines.rail_layer.elevated` in `create_entity`, otherwise they are placed on the
ground layer and the whole elevated track becomes one block. Rolling stock cannot be placed at a
position that lies under an elevated rail — `create_entity` simply returns `nil`.

---

## Signals, blocks and train lengths (checked in-game, 2.1.20)

**Rules** (what players expect from a scripted network, and what keeps it free of deadlocks):

1. **Chain signal in, rail signal out.** Every entry into a junction (switch, merge, crossing,
   the merge of a station siding) gets a chain signal; every exit a normal rail signal. One entry
   with two exits: a chain signal before the switch, a rail signal behind each exit.
2. **A block behind a rail signal holds the longest train.** A train that stops at the next signal
   must not stick out into the junction behind it. Rule of thumb: 7 tiles per carriage
   (locomotive + 4 wagons ≈ 35). Only where the geometry does not allow it, shorter.
3. **No signals right behind each other** (no carriage fits in between) – they only cost UPS.
4. **Do not rebuild junctions that come from a player's blueprint** – protect them when thinning.

**Train length** = `#train.carriages` ("parts": locomotives + wagons). A station that only takes
one length (`min = max`) should also only have that many wagon bays, so players can see it; its
waiting spots and the blocks leading to it are sized for that length.

**Checking by script** – the rail segment API (`LuaEntity`, rails and signals):

```lua
-- A signal sits between two segments. get_connected_rails() returns either the rail in front of
-- it (there the signal is the segment's exit) or the rail behind it (the segment's entrance).
local function start_of(sig)
  for _, rail in pairs(sig.get_connected_rails()) do
    for _, d in ipairs({defines.rail_direction.front, defines.rail_direction.back}) do
      local entrance = rail.get_rail_segment_signal(d, true)
      if entrance and entrance.unit_number == sig.unit_number then return rail, d, true end
      local exit = rail.get_rail_segment_signal(d, false)
      if exit and exit.unit_number == sig.unit_number then return rail, d, false end
    end
  end
end
-- segment length: rail.get_rail_segment_length(); next rail: rail.get_rail_segment_end(dir), then
-- end_rail.get_connected_rail{rail_direction = end_dir, rail_connection_direction = ...}
-- switch: more than one connected rail at one end; crossing: #rail.get_rail_segment_overlaps() > 0
-- signals guarding a block: rail.get_inbound_signals() / rail.get_outbound_signals()
```

A segment ends at switches, signals **and train stops**; a block only at signals – walk segments
until `get_rail_segment_signal(dir, false)` returns a signal.

**Tools in this skill:** `scripts/signal-audit.sh SAVE.zip [MIN_LENGTH] [SURFACE]` loads a save
headless and lists rail signals in front of junctions, blocks shorter than `MIN_LENGTH` and
double signals, each as `[gps=x,y,surface]` (paste into the game chat to jump there). The library
`scripts/templates/signal-audit-mod/signal-blocks.lua` has `audit()` and `fit()` – `fit()` merges
too short blocks when a mod or scenario builds tracks by script: from the start of each signal
row **in direction of travel** (thinning in arbitrary order leaves one direction with too few
signals), never removing exits, with `keep(sig)` to protect blueprint junctions.

---

## Best Practices

1. **Always use `LuaSchedule` API** — Don't assign `train.schedule = {}` directly, it overwrites interrupts
2. **Check `train.valid`** — Trains can be destroyed (crashed, deconstructed)
3. **Use train groups** — When multiple trains share routes, groups make management easier
4. **Use interrupts for exceptions** — Don't hardcode every possible destination; use interrupts for fuel, maintenance, emergencies
5. **Index stations by name** — Store `stop.backer_name` → `stop.unit_number` for quick lookup
6. **Handle `no_path` state** — Trains can get stuck if tracks are removed; monitor and alert
7. **Use `temporary = true`** for dynamically added stops — They're removed after the train leaves
8. **Circuit network integration** — Use train stops to read/write signals for automated logistics
9. **Quality affects trains (2.1.7+)** — Locomotive power/max speed, cargo wagon inventory size increase with quality tier
10. **Rolling stock can be upgraded** — with upgrade planner; robots only dispatched to trains in manual mode or waiting at a stop
