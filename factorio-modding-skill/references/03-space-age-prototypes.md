# Space Age Prototype Extensions (Factorio 2.1 DLC)

> **⚠️ Version-Hinweis:** Stand Factorio 2.1.11 experimental. Bei Unsicherheit über aktuelle Prototype-Properties IMMER gegen die offizielle Doku verifizieren: [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/). Factorio 2.1 (experimental) ändert sich wöchentlich. Wichtige 2.1-Änderungen: Storage Tank Quality-Skalierung (2.1.7+), Cargo Wagon Quality (2.1.7+), Locomotive Quality (2.1.7+), Space Platform Hub Health (5000 statt 1000), Asteroid Collector Circuit Connection, Lab Circuit Connection.

## Table of Contents

- [New Prototype Types](#new-prototype-types)
  - [Planet Prototype](#planet-prototype)
  - [Space Location Prototype](#space-location-prototype)
  - [Space Connection Prototype](#space-connection-prototype)
  - [Surface Prototype New in 2.0](#surface-prototype-new-in-2.0)
  - [Surface Property Prototype](#surface-property-prototype)
- [Space Age Entities](#space-age-entities)
  - [Space Platform Hub](#space-platform-hub)
  - [Cargo Bay](#cargo-bay)
  - [Thruster](#thruster)
  - [Asteroid Collector](#asteroid-collector)
  - [Cargo Landing Pad](#cargo-landing-pad)
- [Asteroid Prototypes](#asteroid-prototypes)
  - [Asteroid Chunk](#asteroid-chunk)
  - [Asteroid flying through space](#asteroid-flying-through-space)
  - [Asteroid Spawn Definitions](#asteroid-spawn-definitions)
- [Quality System Space Age](#quality-system-space-age)
  - [Quality Prototypes](#quality-prototypes)
  - [Quality-Aware Prototypes](#quality-aware-prototypes)
- [Active Triggers & Chain Active Triggers](#active-triggers-&-chain-active-triggers)
- [Rocket Silo Extensions Space Age](#rocket-silo-extensions-space-age)
- [Agricultural Tower Space Age — Gleba](#agricultural-tower-space-age-—-gleba)
- [Beam & Crafting Machine Graphics Set 2.0 Refactor](#beam-&-crafting-machine-graphics-set-2.0-refactor)
  - [Beam with Graphics Set](#beam-with-graphics-set)
  - [Crafting Machine with Graphics Set](#crafting-machine-with-graphics-set)
  - [Accumulator with Chargable Graphics](#accumulator-with-chargable-graphics)
- [Space Platform Management](#space-platform-management)
  - [LuaSpacePlatform Runtime](#luaspaceplatform-runtime)
  - [Space Platform States](#space-platform-states)
- [Cargo Pod System](#cargo-pod-system)
  - [Cargo Landing Pad Runtime](#cargo-landing-pad-runtime)
  - [Cargo Pod Events](#cargo-pod-events)
- [Space-Age Specific Events](#space-age-specific-events)
- [Space-Age Defines](#space-age-defines)


- [New Prototype Types](#)
- [Space Age Entities](#)
- [Asteroid Prototypes](#)
- [Quality System (Space Age)](#)
- [Active Triggers & Chain Active Triggers](#)
- [Rocket Silo Extensions (Space Age)](#)
- [Agricultural Tower (Space Age — Gleba)](#)
- [Beam & Crafting Machine Graphics Set (2.0 Refactor)](#)
- [Space Platform Management](#)
- [Cargo Pod System](#)
- [Space-Age Specific Events](#)
- [Space-Age Defines](#)



Space Age adds entirely new concepts to Factorio: planets, space platforms, asteroids, quality tiers, and more. This document covers the new prototype types and properties.

## New Prototype Types

### Planet Prototype

```lua
data:extend({
  {
    type = "planet",
    name = "my-planet",
    icon = "__my-mod__/graphics/icons/planet-my.png",
    icon_size = 256,
    starmap_icon = "__my-mod__/graphics/icons/starmap-planet-my.png",
    starmap_icon_size = 512,
    gravity_pull = 10,
    distance = 15,
    orientation = 0.5,  -- position on orbital ring
    magnitude = 1.0,    -- visual size on starmap
    order = "d[my-planet]",
    subgroup = "planets",
    map_gen_settings = {
      -- Standard map generation settings
      terrain_segmentation = 1,
      water = 0,
      width = 1000,
      height = 1000,
      starting_area = 1.0,
      autoplace_controls = {},
      autoplace_settings = {
        ["tile"] = {settings = {}},
        ["decorative"] = {settings = {}},
        ["entity"] = {settings = {}},
      },
    },
    pollutant_type = nil,  -- or a pollutant prototype name
    solar_power_in_space = 300,
    surface_properties = {
      ["day-night-cycle"] = 5 * minute,  -- in ticks (minute = 3600 ticks)
      ["magnetic-field"] = 12,
      ["solar-power"] = 100,
      pressure = 1000,     -- in hPa (affects rocket fuel)
      gravity = 10,        -- affects rocket fuel needed
    },
    platform_procession_set = {
      arrival = {"planet-to-platform-b"},
      departure = {"platform-to-planet-a"},
    },
    planet_procession_set = {
      arrival = {"platform-to-planet-b"},
      departure = {"planet-to-platform-a"},
    },
    procession_graphic_catalogue = catalogue_vulcanus,
    asteroid_spawn_influence = 1.0,
    asteroid_spawn_definitions = {
      -- Defines which asteroid chunks spawn near this planet
      {probability = 0.3, asteroid = "asteroid-chunk-iron"},
      {probability = 0.3, asteroid = "asteroid-chunk-copper"},
      {probability = 0.2, asteroid = "asteroid-chunk-stone"},
      {probability = 0.2, asteroid = "asteroid-chunk-carbon"},
    },
    persistent_ambient_sounds = {
      base_ambience = {filename = "__my-mod__/sound/wind.ogg", volume = 0.8},
      wind = {filename = "__my-mod__/sound/wind-variant.ogg", volume = 0.8},
      crossfade = {
        order = {"wind", "base_ambience"},
        curve_type = "cosine",
        from = {control = 0.35, volume_percentage = 0.0},
        to = {control = 2, volume_percentage = 100.0},
      },
    },
    surface_render_parameters = {
      fog = {
        -- fog effect properties
      },
      day_night_cycle_color_lookup = {
        {0.0, "__my-mod__/graphics/lut/planet-day.png"},
        {0.25, "__my-mod__/graphics/lut/planet-sunset.png"},
        {0.50, "__my-mod__/graphics/lut/planet-night.png"},
        {0.75, "__my-mod__/graphics/lut/planet-sunrise.png"},
      },
    },
  }
})
```

### Space Location Prototype

```lua
data:extend({
  {
    type = "space-location",
    name = "my-space-location",
    icon = "__my-mod__/graphics/icons/space-location.png",
    icon_size = 256,
    starmap_icon = "__my-mod__/graphics/icons/starmap-location.png",
    starmap_icon_size = 128,
    gravity_pull = 0,
    distance = 20,
    orientation = 0.75,
    magnitude = 0.8,
    order = "e[my-location]",
    subgroup = "space-locations",
    asteroid_spawn_influence = 1.5,
    asteroid_spawn_definitions = {
      {probability = 0.5, asteroid = "asteroid-chunk-iron"},
    },
    -- Space locations without a planet surface are just waypoints
    -- Add surface_properties to make it an actual planet
  }
})
```

### Space Connection Prototype

```lua
data:extend({
  {
    type = "space-connection",
    name = "nauvis-to-my-planet",
    from = "nauvis",
    to = "my-planet",
    -- or between space locations
    -- from = "space-location-1",
    -- to = "space-location-2",
    order = "a",
    asteroid_spawn_definitions = {
      {probability = 0.1, asteroid = "asteroid-chunk-iron"},
      {probability = 0.05, asteroid = "asteroid-chunk-ice"},
    },
  }
})
```

### Surface Prototype (New in 2.0)

```lua
data:extend({
  {
    type = "surface",
    name = "my-surface",
    surface_properties = {
      ["day-night-cycle"] = 3 * minute,
      ["magnetic-field"] = 56,
      ["solar-power"] = 150,
      pressure = 4000,
      gravity = 40,
    },
  }
})
```

### Surface Property Prototype

```lua
data:extend({
  {
    type = "surface-property",
    name = "my-property",
    default_value = 100,
    min_value = 0,
    max_value = 10000,
  }
})
```

> Built-in surface properties: `day-night-cycle`, `magnetic-field`, `solar-power`, `pressure`, `gravity`

---

## Space Age Entities

### Space Platform Hub

```lua
-- This entity creates a space platform when launched via rocket
data:extend({
  {
    type = "space-platform-hub",
    name = "my-space-platform-hub",
    icon = "__my-mod__/graphics/icons/space-hub.png",
    icon_size = 64,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "my-space-platform-hub"},
    max_health = 1000,
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    -- The platform has an inventory (accessible by scripts)
    -- and can store rocket parts, fuel, etc.
  }
})
```

### Cargo Bay

```lua
data:extend({
  {
    type = "cargo-bay",
    name = "my-cargo-bay",
    icon = "__my-mod__/graphics/icons/cargo-bay.png",
    icon_size = 64,
    inventory_size = 20,  -- additional slots on the space platform
    -- connects to the space platform hub
  }
})
```

### Thruster

```lua
data:extend({
  {
    type = "thruster",
    name = "my-thruster",
    icon = "__my-mod__/graphics/icons/thruster.png",
    icon_size = 64,
    fuel_categories = {"thruster-fuel"},
    fluid_box = {
      volume = 200,
      pipe_connections = {
        {flow_direction = "input", direction = defines.direction.north, position = {0, -1}},
      },
    },
    -- Produces thrust when connected to a space platform hub  --
  }
})
```

### Asteroid Collector

```lua
data:extend({
  {
    type = "asteroid-collector",
    name = "my-asteroid-collector",
    icon = "__my-mod__/graphics/icons/asteroid-collector.png",
    icon_size = 64,
    collecting_time = 10,  -- seconds between collections
    -- Automatically collects asteroids as the platform moves
  }
})
```

### Cargo Landing Pad

```lua
data:extend({
  {
    type = "cargo-landing-pad",
    name = "my-cargo-landing-pad",
    icon = "__my-mod__/graphics/icons/cargo-pad.png",
    icon_size = 64,
    -- Receives cargo pods launched from space platforms
  }
})
```

---

## Asteroid Prototypes

### Asteroid Chunk

```lua
data:extend({
  {
    type = "asteroid-chunk",
    name = "my-asteroid-chunk",
    icon = "__my-mod__/graphics/icons/asteroid-chunk.png",
    icon_size = 64,
    map_color = {r = 0.5, g = 0.3, b = 0.2},
    -- This defines the visual asteroid chunk seen in space
  }
})
```

### Asteroid (flying through space)

```lua
data:extend({
  {
    type = "asteroid",
    name = "my-asteroid",
    icon = "__my-mod__/graphics/icons/asteroid.png",
    icon_size = 64,
    subgroup = "asteroids",
    -- The asteroid that moves through space and can be collected
    -- or destroyed
  }
})
```

### Asteroid Spawn Definitions

```lua
-- In space-connection prototypes:
asteroid_spawn_definitions = {
  {probability = 0.3, asteroid = "asteroid-chunk-iron"},
  {probability = 0.2, asteroid = "asteroid-chunk-copper"},
  {probability = 0.1, asteroid = "asteroid-chunk-rare"},
}
```

---

## Quality System (Space Age)

### Quality Prototypes

The built-in quality tiers are:

| Quality | Level | Order |
|---------|-------|-------|
| Normal | 0 | "a" |
| Uncommon | 1 | "b" |
| Rare | 2 | "c" |
| Epic | 3 | "d" |
| Legendary | 4 | "e" |

```lua
data:extend({
  {
    type = "quality",
    name = "my-custom-quality",
    order = "f",
    level = 5,
    icon = "__my-mod__/graphics/icons/quality-my-quality.png",
    icon_size = 64,
    localised_name = {"quality-name.my-custom-quality"},
  }
})
```

### Quality-Aware Prototypes

Any prototype that supports quality can use:
```lua
random_quality_on_item_creation = "always",  -- "always" | "never" | "script"
default_import_location = "vulcanus",  -- which planet it comes from
```

---

## Active Triggers & Chain Active Triggers

```lua
data:extend({
  {
    type = "active-trigger",
    name = "my-trigger",
    action = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "create-entity",
            entity_name = "explosion",
          },
        },
      },
    },
  },
  {
    type = "chain-active-trigger",
    name = "my-chain-trigger",
    actions = {
      {action = {type = "direct", action_delivery = {type = "instant"}}},
      {action = {type = "direct", action_delivery = {type = "instant"}}},
    },
  }
})
```

---

## Rocket Silo Extensions (Space Age)

```lua
data:extend({
  {
    type = "rocket-silo",
    name = "my-rocket-silo",
    rocket_quick_relaunch_start_offset = 0,  -- 0 = regular start, 1 = end of animation
    rocket_parts_storage_cap = 500,  -- when silo is "full" for crafting rocket parts
    rocket_parts_required = 100,  -- parts needed per launch
    -- ... rest of rocket-silo prototype
  }
})
```

---

## Agricultural Tower (Space Age — Gleba)

```lua
data:extend({
  {
    type = "agricultural-tower",
    name = "my-agricultural-tower",
    icon = "__my-mod__/graphics/icons/agri-tower.png",
    icon_size = 64,
    -- Grows plants automatically on the surface
    -- Used for farming mechanics on Gleba-like planets
  }
})
```

---

## Beam & Crafting Machine Graphics Set (2.0 Refactor)

### Beam with Graphics Set
```lua
data:extend({
  {
    type = "beam",
    name = "my-beam",
    graphics_set = {
      -- All graphics moved here in 2.0
    },
  }
})
```

### Crafting Machine with Graphics Set
```lua
data:extend({
  {
    type = "assembling-machine",
    name = "my-machine",
    graphics_set = {
      animation = {
        filename = "__my-mod__/graphics/my-machine.png",
        width = 128,
        height = 128,
        frame_count = 1,
      },
    },
  }
})
```

### Accumulator with Chargable Graphics
```lua
data:extend({
  {
    type = "accumulator",
    name = "my-accumulator",
    chargable_graphics = {
      picture = {
        filename = "__my-mod__/graphics/accumulator.png",
        width = 64,
        height = 64,
      },
      charge_animation = { ... },
      discharge_animation = { ... },
    },
    energy_source = {
      type = "electric",
      buffer_capacity = "5MJ",
      input_flow_limit = "300kW",
      output_flow_limit = "300kW",
    },
  }
})
```

---

## Space Platform Management

### LuaSpacePlatform (Runtime)

```lua
-- Alle Plattformen einer Force (es gibt kein game.get_space_platforms):
--   force.platforms (index → LuaSpacePlatform) oder force.get_space_platforms(location)
local state_names = {}
for name, value in pairs(defines.space_platform_state) do state_names[value] = name end
for _, platform in pairs(game.forces["player"].platforms) do
  log("Platform: " .. platform.name)
  log("  State: " .. state_names[platform.state])
  log("  Weight: " .. (platform.weight or 0))
  log("  Speed: " .. (platform.speed or 0))
  log("  Location: " .. (platform.space_location and platform.space_location.name or "in transit"))
  log("  Paused: " .. tostring(platform.paused))
  
  -- Get the platform's schedule (LuaSchedule)
  local schedule = platform.get_schedule()
  if schedule then
    log("  Records: " .. schedule.get_record_count())
    log("  Interrupts: " .. schedule.interrupt_count)
  end
  
  -- Platform inventory
  -- Plattform-Inventar = Inventar des Hubs
  local hub = platform.hub
  local inv = hub and hub.valid and hub.get_inventory(defines.inventory.hub_main)
  if inv then
    log("  Cargo items: " .. inv.get_item_count())
  end
end

-- Eine bestimmte Plattform per Name suchen (keine eigene Such-Funktion in der API)
local function find_platform(force, name)
  for _, platform in pairs(force.platforms) do
    if platform.valid and platform.name == name then return platform end
  end
end
local platform = find_platform(game.forces["player"], "My Platform")
if platform then
  platform.paused = true                    -- anhalten
  local ok = platform.can_leave_current_location() -- LuaObject-Methoden mit Punkt, nicht mit Doppelpunkt
end
```

### Space Platform States

```lua
-- geprüft 2.1.19 – alle Werte in references/09-defines.md
defines.space_platform_state.waiting_at_station     -- steht über einem Planeten / Ort
defines.space_platform_state.on_the_path            -- unterwegs
defines.space_platform_state.waiting_for_departure  -- wartet auf Abflug
defines.space_platform_state.no_path
defines.space_platform_state.no_schedule
defines.space_platform_state.paused
```

## Cargo Pod System

### Cargo Landing Pad Runtime

```lua
local pad = surface.find_entity("cargo-landing-pad", {0, 0})
if pad and pad.valid then
  local behavior = pad.get_control_behavior()
  if behavior then
    -- Set item request slots
    behavior.set_request_slot({item = "iron-plate", count = 100}, 1)
    behavior.set_request_slot({item = "copper-plate", count = 50}, 2)
    
    -- Read current requests
    local slot = behavior.get_request_slot(1)
    if slot then
      log("Requesting: " .. slot.name .. " x" .. slot.count)
    end
  end
end
```

### Cargo Pod Events

```lua
-- Event-Daten laut API 2.1.19 (https://lua-api.factorio.com/latest/events.html)
-- Cargo pod launched (cargo_pod, player_index?)
script.on_event(defines.events.on_cargo_pod_started_ascending, function(event)
  local pod = event.cargo_pod
  if pod and pod.valid then log("Cargo pod ascending from " .. pod.surface.name) end
end)

-- Cargo pod landed (cargo_pod, launched_by_rocket, player_index?)
script.on_event(defines.events.on_cargo_pod_finished_descending, function(event)
  local pod = event.cargo_pod
  if pod and pod.valid then log("Cargo pod landed on " .. pod.surface.name) end
end)

-- Cargo delivered without landing pad (cargo_pod, spawned_container)
script.on_event(defines.events.on_cargo_pod_delivered_cargo, function(event)
  local container = event.spawned_container
  if container and container.valid then
    local inv = container.get_inventory(defines.inventory.chest)
    log("Delivered " .. (inv and inv.get_item_count() or 0) .. " items on " .. container.surface.name)
  end
end)
```

## Space-Age Specific Events

| Event | Description | Key Fields |
|-------|-------------|------------|
| `on_space_platform_changed_state` | Platform state changed | `platform`, `old_state` (new state = `platform.state`) |
| `on_cargo_pod_started_ascending` | Cargo pod launched | `cargo_pod`, `player_index?` |
| `on_cargo_pod_finished_descending` | Cargo pod landed | `cargo_pod`, `launched_by_rocket`, `player_index?` |
| `on_cargo_pod_delivered_cargo` | Cargo delivered (no landing pad) | `cargo_pod`, `spawned_container` |
| `on_cargo_pod_finished_ascending` | Cargo pod departed | `cargo_pod`, `launched_by_rocket`, `player_index?` |

(Felder geprüft gegen API 2.1.19.)

## Space-Age Defines

```lua
-- Space platform states (geprüft 2.1.19)
defines.space_platform_state.waiting_at_station
defines.space_platform_state.on_the_path
defines.space_platform_state.waiting_for_departure
defines.space_platform_state.no_path

-- Rocket silo status (Auswahl; alle Werte in references/09-defines.md)
defines.rocket_silo_status.building_rocket
defines.rocket_silo_status.rocket_ready
defines.rocket_silo_status.launch_started
defines.rocket_silo_status.rocket_flying
```
