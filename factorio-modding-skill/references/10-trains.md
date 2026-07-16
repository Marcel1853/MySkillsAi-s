# Train API Reference (Factorio 2.1)

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
| `"item_count"` | `condition: { comparator, count }` | Wait until item count meets condition |
| `"fluid_count"` | `condition: { comparator, count }` | Wait until fluid amount meets condition |
| `"circuit"` | `condition: { comparator, count }` | Wait until circuit signal meets condition |
| `"passenger_present"` | — | Wait until all passengers have boarded |
| `"passenger_absent"` | — | Wait until all passengers have disembarked |
| `"fuel"` | — | Wait until fuel is full (locomotives) |
| `"no_fuel"` | — | Wait until no fuel is left |

### Comparators

```lua
defines.comparator.less              -- <
defines.comparator.less_or_equal     -- <=
defines.comparator.equal             -- =
defines.comparator.greater_or_equal  -- >=
defines.comparator.greater           -- >
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
    comparator = defines.comparator.greater_or_equal,
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
    comparator = defines.comparator.greater,
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
      type = "fuel",
      compare_type = "and",
      condition = {
        first_signal = { type = "item", name = "nuclear-fuel" },  -- or "rocket-fuel", etc.
        comparator = defines.comparator.less,
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
          type = "fuel",
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
        comparator = defines.comparator.greater,
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
      type = "fuel",
      compare_type = "and",
      condition = {
        first_signal = { type = "item", name = "solid-fuel" },
        comparator = defines.comparator.less,
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

| Condition Type | Description |
|---------------|-------------|
| `"time"` | Wait for N ticks at current station |
| `"fuel"` | Train is low on fuel |
| `"no_fuel"` | Train has run out of fuel |
| `"item_count"` | Specific item count condition |
| `"fluid_count"` | Specific fluid count condition |
| `"circuit"` | Circuit network signal condition |
| `"empty"` | Train cargo is empty |
| `"full"` | Train cargo is full |
| `"passenger_present"` | Passengers are waiting |
| `"passenger_absent"` | All passengers boarded |
| `"destination_full_or_no_path"` | Train can't reach destination |
| `"any_item"` | Any item in cargo matches condition |
| `"any_fluid"` | Any fluid in cargo matches condition |
| `"any_fuel"` | Any fuel type matches condition |
| `"any_signal"` | Any circuit signal matches condition |

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
defines.train_state.path_lost              -- Train lost its path (track removed)
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
  local new_state = event.new_state

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

```lua
local rail_end = train.get_rail_end(defines.rail_direction.front)

rail_end.rail              -- LuaEntity (the rail at this end)
rail_end.direction         -- defines.direction
rail_end.connected_rail    -- LuaEntity (the next rail)
```

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
