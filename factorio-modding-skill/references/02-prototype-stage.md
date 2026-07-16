# Prototype Stage (Data Stage) API Reference

> **⚠️ Version-Hinweis:** Stand Factorio 2.1.11 experimental. Bei Unsicherheit über aktuelle Prototype-Properties IMMER gegen die offizielle Doku verifizieren: [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/) (Prototype Definitions). Factorio 2.1 (experimental) ändert sich wöchentlich. Neue Properties in 2.1: `use_mirroring`, `radius_quality_scaling`, `dynamic` ElectricUsagePriority, etc.

## Table of Contents

- [Files Executed in order](#files-executed-in-order)
- [Available Globals](#available-globals)
- [Core Function: data:extend{}](#core-function:-data:extend{})
- [Prototype Categories](#prototype-categories)
  - [Entity Prototypes](#entity-prototypes)
  - [Item Prototypes](#item-prototypes)
  - [Recipe Prototypes](#recipe-prototypes)
  - [Technology Prototypes](#technology-prototypes)
  - [Fluid Prototypes](#fluid-prototypes)
  - [Equipment Prototypes](#equipment-prototypes)
  - [Quality Prototype Space Age](#quality-prototype-space-age)
- [Modifying Existing Prototypes](#modifying-existing-prototypes)
- [Checking for Other Mods](#checking-for-other-mods)
- [Prototype Inheritance](#prototype-inheritance)
- [Tile Prototypes](#tile-prototypes)
- [Common Mod Settings Pattern](#common-mod-settings-pattern)
- [Modding Utilities data stage](#modding-utilities-data-stage)


- [Files Executed (in order)](#)
- [Available Globals](#)
- [Core Function: `data:extend{}`](#)
- [Prototype Categories](#)
- [Modifying Existing Prototypes](#)
- [Checking for Other Mods](#)
- [Prototype Inheritance](#)
- [Tile Prototypes](#)
- [Common Mod Settings Pattern](#)
- [Modding Utilities (data stage)](#)



The prototype stage runs at game startup after the settings stage. This is where you define all game objects: entities, items, recipes, technologies, fluids, and much more.

## Files Executed (in order)

1. `data.lua` — Define your prototypes
2. `data-updates.lua` — Modify existing prototypes (yours and other mods')
3. `data-final-fixes.lua` — Last chance corrections

## Available Globals

| Global | Type | Description |
|--------|------|-------------|
| `data` | LuaData | Registry for all prototypes via `data:extend{}` |
| `data.raw` | table | Table of all prototypes indexed by type then name |
| `data:is_dirty()` | function | Returns true if `data:extend()` was called since last check |
| `mods` | table | Active mod names → versions |
| `settings` | table | Access to startup settings resolved at end of settings stage |

## Core Function: `data:extend{}`

All prototypes are registered through this function:
```lua
data:extend({
  { type = "item", name = "my-item", ... },
  { type = "recipe", name = "my-recipe", ... },
  { type = "technology", name = "my-tech", ... },
})
```

## Prototype Categories

### Entity Prototypes

#### Assembling Machine
```lua
data:extend({
  {
    type = "assembling-machine",
    name = "my-assembling-machine",
    icon = "__my-mod__/graphics/icons/my-machine.png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = "my-assembling-machine"},
    max_health = 300,
    corpse = "medium-remnants",
    crafting_speed = 1.5,
    crafting_categories = {"crafting", "advanced-crafting"},
    energy_source = { type = "electric", usage_priority = "secondary-input" },
    energy_usage = "150kW",
    module_slots = 4,
    allowed_effects = {"speed", "productivity", "consumption", "pollution"},
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    graphics_set = {
      animation = {
        filename = "__my-mod__/graphics/entity/my-machine.png",
        width = 128,
        height = 128,
        frame_count = 32,
        line_length = 8,
      },
    },
    fast_replaceable_group = "my-assembling-machine",
    next_upgrade = "my-assembling-machine-2",
  }
})
```

#### Mining Drill
```lua
data:extend({
  {
    type = "mining-drill",
    name = "my-mining-drill",
    mining_speed = 1.0,
    resource_searching_radius = 2.5,
    vector_to_place_result = {0, -0.5},
    module_slots = 2,
    allowed_effects = {"speed", "productivity", "consumption"},
    -- inherits from burner or electric entity prototype
    energy_source = { type = "electric", usage_priority = "primary-input" },
    energy_usage = "90kW",
    input_fluid_box = nil,  -- can mine fluids if set
  }
})
```

#### Furnace
```lua
data:extend({
  {
    type = "furnace",
    name = "my-furnace",
    crafting_speed = 2.0,
    energy_usage = "180kW",
    energy_source = { type = "electric" },
    result_inventory_size = 1,
    source_inventory_size = 0,
    crafting_categories = {"smelting"},
    module_slots = 2,
    allowed_effects = {"speed", "productivity", "consumption"},
  }
})
```

#### Boiler
```lua
data:extend({
  {
    type = "boiler",
    name = "my-boiler",
    energy_consumption = "1.8MW",
    target_temperature = 165,
    fluid_box = {
      volume = 100,
      pipe_connections = {
        {flow_direction = "input",  direction = defines.direction.north, position = {0, -1}},
        {flow_direction = "output", direction = defines.direction.south, position = {0, 1}},
      },
    },
  }
})
```

#### Generator
```lua
data:extend({
  {
    type = "generator",
    name = "my-generator",
    effectivity = 1,  -- MW per unit of fluid
    fluid_box = {
      volume = 100,
      pipe_connections = {
        {flow_direction = "input-output", direction = defines.direction.south, position = {0, 0}},
      },
    },
    burning_cooldown = 20,
  }
})
```

#### Burner Generator
```lua
data:extend({
  {
    type = "burner-generator",
    name = "my-burner-generator",
    effectivity = 0.5,
    fuel_categories = {"chemical"},
    max_temperature = 1000,
    energy_per_fuel_unit = 10000,  -- J
    burner_usage_priority = "generators",
  }
})
```

#### Lab
```lua
data:extend({
  {
    type = "lab",
    name = "my-lab",
    researching_speed = 2.0,
    inputs = {"automation-science-pack", "logistic-science-pack"},
    energy_source = { type = "electric", usage_priority = "secondary-input" },
    energy_usage = "60kW",
    module_slots = 2,  -- Space Age addition
    allowed_module_categories = {"speed", "productivity"},  -- Space Age
  }
})
```

#### Storage / Logistic Chests

> **Note**: In 2.0, logistic chest prototype names changed:
> - `logistic-chest-requester` → `requester-chest`
> - `logistic-chest-storage` → `storage-chest`
> - `logistic-chest-buffer` → `buffer-chest`
> - `logistic-chest-active-provider` → `active-provider-chest`
> - `logistic-chest-passive-provider` → `passive-provider-chest`

```lua
data:extend({
  {
    type = "container",
    name = "my-container",
    inventory_size = 50,
    -- or for logistics:
    -- type = "logistic-container",
    -- logistic_mode = "requester",  -- "requester", "storage", "buffer"
  }
})
```

#### Turret
```lua
data:extend({
  {
    type = "ammo-turret",
    name = "my-turret",
    attack_parameters = {
      type = "projectile",
      ammo_category = "bullet",
      cooldown = 15,
      range = 20,
      shell_particle = { ... },
    },
    folded_animation = { ... },
    prepared_animation = { ... },
  }
})
```

#### Electric Energy Interface
```lua
data:extend({
  {
    type = "electric-energy-interface",
    name = "my-energy-interface",
    energy_source = { type = "electric", usage_priority = "primary-output" },
    relation_with_energy_source = "nothing",
  }
})
```

### Item Prototypes

#### Basic Item
```lua
data:extend({
  {
    type = "item",
    name = "my-item",
    icon = "__my-mod__/graphics/icons/my-item.png",
    icon_size = 64,
    subgroup = "raw-material",
    order = "a[my-item]",
    stack_size = 100,
    weight = 1000,  -- in grams (Space Age)
    place_result = "my-entity",  -- if this item places an entity
  }
})
```

#### Item with Quality (Space Age)
```lua
data:extend({
  {
    type = "item",
    name = "my-quality-item",
    icon = "__my-mod__/graphics/icons/my-item.png",
    icon_size = 64,
    stack_size = 50,
    default_import_location = "vulcanus",  -- Space Age: planet origin
    random_quality_on_item_creation = "always",  -- "always", "never", "script"
  }
})
```

#### Tool Item
```lua
data:extend({
  {
    type = "tool",
    name = "my-tool",
    icon = "__my-mod__/graphics/icons/my-tool.png",
    icon_size = 64,
    stack_size = 50,
    durability = 100,  -- number of uses
    durability_description_key = "description.tool-discharge-defense-remaining",
  }
})
```

#### Ammo Item
```lua
data:extend({
  {
    type = "ammo",
    name = "my-ammo",
    icon = "__my-mod__/graphics/icons/my-ammo.png",
    icon_size = 64,
    ammo_category = "bullet",
    ammo_type = {
      category = "bullet",
      target_type = "entity",
      action = {
        type = "direct",
        action_delivery = {
          type = "instant",
          source_effects = {
            type = "create-entity",
            entity_name = "explosion",
          },
        },
      },
    },
    stack_size = 200,
    magazine_size = 10,  -- how many fit in a magazine
  }
})
```

#### Capsule (consumable / grenade-like)
```lua
data:extend({
  {
    type = "capsule",
    name = "my-capsule",
    icon = "__my-mod__/graphics/icons/my-capsule.png",
    icon_size = 64,
    stack_size = 20,
    capsule_action = {
      type = "throw",
      attack_parameters = {
        type = "projectile",
        ammo_category = "grenade",
        cooldown = 30,
        range = 15,
      },
    },
  }
})
```

#### Item with Equipment Grid (Armor)
```lua
data:extend({
  {
    type = "armor",
    name = "my-armor",
    icon = "__my-mod__/graphics/icons/my-armor.png",
    icon_size = 64,
    stack_size = 1,
    infinite = false,
    resistances = {
      {type = "physical", decrease = 5, percent = 10},
      {type = "explosion", decrease = 10, percent = 20},
    },
    equipment_grid = "my-equipment-grid",
    inventory_size_bonus = 20,
  }
})
```

### Recipe Prototypes

#### Basic Recipe
```lua
data:extend({
  {
    type = "recipe",
    name = "my-recipe",
    enabled = false,
    energy_required = 5.0,
    categories = {"crafting"},
    ingredients = {
      {"iron-plate", 2},
      {type = "fluid", name = "water", amount = 50},
    },
    results = {
      {type = "item", name = "my-item", amount = 1},
    },
    allow_decomposition = true,
    allow_productivity = true,  -- Can productivity modules affect this?
    main_product = "my-item",
    subgroup = "my-mod-production",
    order = "a",
  }
})
```

#### Recipe with Multiple Outputs
```lua
data:extend({
  {
    type = "recipe",
    name = "my-complex-recipe",
    enabled = true,
    energy_required = 10.0,
    categories = {"chemistry"},
    ingredients = {
      {type = "item", name = "coal", amount = 5},
      {type = "fluid", name = "sulfuric-acid", amount = 100},
    },
    results = {
      {type = "item", name = "plastic-bar",        amount = 2},
      {type = "item", name = "byproduct",          amount = 1, probability = 0.3},
      {type = "fluid", name = "waste-water",       amount = 50},
    },
    crafting_machine_tint = {
      primary   = {r = 0.5, g = 0.2, b = 0.1, a = 1.0},
      secondary = {r = 0.3, g = 0.3, b = 0.5, a = 1.0},
    },
  }
})
```

#### Recipe with Quality Output (Space Age)
```lua
data:extend({
  {
    type = "recipe",
    name = "my-quality-recipe",
    ingredients = {{"iron-plate", 1}},
    results = {
      {type = "item", name = "iron-gear-wheel", amount = 1,
       ignored_by_quality = {"quality"},  -- quality doesn't affect output count
      },
    },
    allow_quality = true,
  }
})
```

### Technology Prototypes

```lua
data:extend({
  {
    type = "technology",
    name = "my-technology",
    icon = "__my-mod__/graphics/technology/my-tech.png",
    icon_size = 256,
    effects = {
      {type = "unlock-recipe", recipe = "my-recipe"},
      {type = "unlock-recipe", recipe = "my-other-recipe"},
      {type = "nothing-effect", effect_description = {"", "Unlocks ", {"item-name.my-item"}}},
      -- Space Age: unlock a space location (planet)
      {type = "unlock-space-location", space_location = "my-planet", use_icon_overlay = true},
    },
    prerequisites = {"automation", "logistics"},
    unit = {
      count = 200,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30,
    },
    -- Alternative: infinite technology (repeatable)
    -- unit = {
    --   count_formula = "1.5^L*200",  -- L = level
    --   ingredients = {{"automation-science-pack", 1}},
    --   time = 60,
    -- },
    -- max_level = "infinite",
    order = "e-a",
  }
})
```

### Fluid Prototypes

```lua
data:extend({
  {
    type = "fluid",
    name = "my-fluid",
    default_temperature = 25,
    max_temperature = 100,
    heat_capacity = "0.2kJ",
    base_color = {r = 0.5, g = 0.8, b = 0.2},
    flow_color = {r = 0.7, g = 1.0, b = 0.5},
    icon = "__my-mod__/graphics/icons/my-fluid.png",
    icon_size = 64,
    order = "a[my-fluid]",
  }
})
```

### Equipment Prototypes

```lua
-- Equipment Grid
data:extend({
  {
    type = "equipment-grid",
    name = "my-equipment-grid",
    width = 5,
    height = 5,
    equipment_categories = {"armor"},
  }
})

-- Energy Equipment
data:extend({
  {
    type = "energy-shield-equipment",
    name = "my-shield",
    sprite = {
      filename = "__my-mod__/graphics/equipment/my-shield.png",
      width = 64, height = 64,
    },
    shape = {width = 2, height = 2, type = "full"},
    max_shield_value = 50,
    energy_source = {type = "electric", buffer_capacity = "100MJ"},
    energy_per_shield = "20kJ",
    categories = {"armor"},
  }
})

-- Movement Equipment
data:extend({
  {
    type = "movement-bonus-equipment",
    name = "my-exoskeleton",
    sprite = {filename = "__my-mod__/graphics/equipment/exo.png", width = 64, height = 64},
    shape = {width = 2, height = 2, type = "full"},
    movement_bonus = 0.3,  -- +30% speed
    energy_source = {type = "electric", buffer_capacity = "100MJ"},
    categories = {"armor"},
  }
})
```

### Quality Prototype (Space Age)

```lua
data:extend({
  {
    type = "quality",
    name = "my-quality",
    order = "z",
    level = 5,  -- Higher = better. Normal=0, Uncommon=1, Rare=2, Epic=3, Legendary=4
    icon = "__my-mod__/graphics/icons/quality-my-quality.png",
    icon_size = 64,
    localised_name = {"quality-name.my-quality"},
  }
})
```

## Modifying Existing Prototypes

```lua
-- data-updates.lua

-- Make an existing recipe available from the start
if data.raw.recipe["advanced-circuit"] then
  data.raw.recipe["advanced-circuit"].enabled = true
end

-- Add a new ingredient to an existing recipe
if data.raw.recipe["low-density-structure"] then
  table.insert(data.raw.recipe["low-density-structure"].ingredients, {"my-item", 5})
end

-- Increase assembler speed
if data.raw["assembling-machine"]["assembling-machine-3"] then
  data.raw["assembling-machine"]["assembling-machine-3"].crafting_speed = 2.0
end

-- Add module slots to a lab (Space Age)
if data.raw.lab["lab"] then
  data.raw.lab["lab"].module_slots = 2
  data.raw.lab["lab"].allowed_module_categories = {"speed", "productivity"}
end
```

## Checking for Other Mods

```lua
-- data.lua
if mods["space-age"] then
  -- Add Space Age specific content
  require("__my-mod__/prototypes/space-age-content")
end

if mods["quality"] then
  -- quality mod is active (if running separately from Space Age)
end
```

## Prototype Inheritance

All prototypes inherit from `PrototypeBase`, which provides:
- `type` — required string identifier
- `name` — required unique name within type
- `localised_name` — optional display name (uses locale)
- `localised_description` — optional description
- `icon` — path to icon image
- `icon_size` — size in pixels
- `icon_mipmaps` — number of icon mipmaps
- `order` — sorting string (e.g., "a-b-c")
- `subgroup` — which GUI subgroup
- `hidden` — if true, not shown in GUI
- `hidden_in_factoriopedia` — if true, excluded from Factoriopedia

---

## Tile Prototypes

```lua
data:extend({
  {
    type = "tile",
    name = "my-tile",
    order = "z[my-tile]",
    subgroup = "artificial-tiles",
    needs_correction = false,
    minable = {mining_time = 0.1, result = "my-tile"},
    mined_sound = {filename = "__base__/sound/deconstruct-bricks.ogg"},
    collision_mask = {layers = {ground_tile = true}},
    layer = 60,
    layer_group = "ground-artificial",
    variants = {
      main = {
        {
          picture = "__my-mod__/graphics/tiles/my-tile.png",
          count = 16,
          size = 1,
          scale = 0.5,
        },
      },
      inner_corner = {
        picture = "__my-mod__/graphics/tiles/my-tile-inner-corner.png",
        count = 8,
      },
      outer_corner = {
        picture = "__my-mod__/graphics/tiles/my-tile-outer-corner.png",
        count = 8,
      },
      side = {
        picture = "__my-mod__/graphics/tiles/my-tile-side.png",
        count = 8,
      },
      u_transition = {
        picture = "__my-mod__/graphics/tiles/my-tile-u-transition.png",
        count = 8,
      },
      o_transition = {
        picture = "__my-mod__/graphics/tiles/my-tile-o-transition.png",
        count = 4,
      },
    },
    walking_speed_modifier = 1.5,
    vehicle_friction_modifier = 1.0,
    decorative_removal_probability = 0.8,
    map_color = {r = 0.5, g = 0.5, b = 0.5},
    scorch_mark_color = {r = 0.2, g = 0.1, b = 0.05, a = 0.5},
  },
})
```

## Common Mod Settings Pattern

```lua
-- In settings.lua, use consistent ordering and grouping
data:extend({
  -- Section A: Core feature toggles
  {
    type = "bool-setting",
    name = "my-mod-enable-core",
    setting_type = "startup",
    default_value = true,
    order = "a",
  },
  -- Section B: Numeric parameters
  {
    type = "double-setting",
    name = "my-mod-multiplier",
    setting_type = "startup",
    default_value = 1.0,
    minimum_value = 0.1,
    maximum_value = 100.0,
    order = "b",
  },
  -- Section C: Runtime adjustments
  {
    type = "int-setting",
    name = "my-mod-threshold",
    setting_type = "runtime",
    default_value = 100,
    minimum_value = 0,
    maximum_value = 10000,
    order = "c",
  },
})
```

## Modding Utilities (data stage)

```lua
-- Deep copy a prototype for modification
local base_assembler = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"])
base_assembler.name = "my-assembler"
base_assembler.crafting_speed = 1.5
data:extend({base_assembler})

-- Check if a prototype exists before modifying
if data.raw["recipe"]["my-recipe"] then
  -- recipe exists
end

-- Iterate all prototypes of a type
for name, proto in pairs(data.raw["item"]) do
  log("Item: " .. name)
end

-- Add a prototype conditionally based on another mod
if mods["space-age"] then
  require("__my-mod__/prototypes/space-content")
end

-- Use data:is_dirty() to check if prototypes were added
local was_dirty = data:is_dirty()
data:extend({{type = "item", name = "test", stack_size = 1}})
local is_now_dirty = data:is_dirty()  -- true
```
