-- ============================================================
-- EXAMPLE: Prototype Stage — Custom Entity with Full Chain
-- ============================================================
-- This example shows a complete entity → item → recipe → technology chain,
-- plus a fluid and a custom fuel category.
-- ============================================================

-- ===== ITEMS =====

data:extend({
  -- Raw material item
  {
    type = "item",
    name = "crystal-ore",
    icon = "__prototype-examples__/graphics/icons/crystal-ore.png",
    icon_size = 64,
    subgroup = "raw-resource",
    order = "z[crystal-ore]",
    stack_size = 50,
    weight = 500,
  },

  -- Processed material
  {
    type = "item",
    name = "refined-crystal",
    icon = "__prototype-examples__/graphics/icons/refined-crystal.png",
    icon_size = 64,
    subgroup = "raw-material",
    order = "z[refined-crystal]",
    stack_size = 100,
    weight = 200,
  },

  -- Final product
  {
    type = "item",
    name = "crystal-processor",
    icon = "__prototype-examples__/graphics/icons/crystal-processor.png",
    icon_size = 64,
    subgroup = "intermediate-product",
    order = "z[crystal-processor]",
    stack_size = 50,
    weight = 100,
  },

  -- Placeable entity item
  {
    type = "item",
    name = "crystal-furnace",
    icon = "__prototype-examples__/graphics/icons/crystal-furnace.png",
    icon_size = 64,
    subgroup = "smelting-machine",
    order = "z[crystal-furnace]",
    place_result = "crystal-furnace",
    stack_size = 10,
  },
})

-- ===== FLUIDS =====

data:extend({
  {
    type = "fluid",
    name = "molten-crystal",
    icon = "__prototype-examples__/graphics/icons/molten-crystal.png",
    icon_size = 64,
    default_temperature = 500,
    max_temperature = 1000,
    heat_capacity = "0.5kJ",
    base_color = {r = 0.8, g = 0.2, b = 1.0},
    flow_color = {r = 1.0, g = 0.5, b = 1.0},
    order = "z[molten-crystal]",
  },
})

-- ===== RECIPES =====

data:extend({
  -- Smelt ore into refined crystal
  {
    type = "recipe",
    name = "refine-crystal",
    categories = {"smelting"},
    enabled = true,  -- available from start
    energy_required = 3.0,
    ingredients = {
      {type = "item", name = "crystal-ore", amount = 2},
    },
    results = {
      {type = "item", name = "refined-crystal", amount = 1},
    },
    allow_productivity = true,
    main_product = "refined-crystal",
  },

  -- Craft the processor
  {
    type = "recipe",
    name = "crystal-processor-recipe",
    categories = {"crafting"},
    enabled = false,  -- unlocked by tech
    energy_required = 5.0,
    ingredients = {
      {"refined-crystal", 5},
      {"copper-cable", 10},
      {type = "fluid", name = "water", amount = 20},
    },
    results = {
      {type = "item", name = "crystal-processor", amount = 1},
    },
    allow_productivity = true,
  },

  -- Smelt ore into fluid
  {
    type = "recipe",
    name = "melt-crystal",
    categories = {"chemistry"},
    enabled = false,
    energy_required = 4.0,
    ingredients = {
      {"crystal-ore", 1},
    },
    results = {
      {type = "fluid", name = "molten-crystal", amount = 50},
    },
    allow_productivity = false,
    crafting_machine_tint = {
      primary = {r = 0.8, g = 0.2, b = 1.0, a = 1.0},
    },
  },

  -- Craft the furnace
  {
    type = "recipe",
    name = "crystal-furnace-recipe",
    categories = {"crafting"},
    enabled = false,
    energy_required = 10.0,
    ingredients = {
      {"stone-furnace", 1},
      {"refined-crystal", 10},
      {"steel-plate", 5},
    },
    results = {
      {type = "item", name = "crystal-furnace", amount = 1},
    },
  },
})

-- ===== ENTITY: Crystal Furnace =====

data:extend({
  {
    type = "furnace",
    name = "crystal-furnace",
    icon = "__prototype-examples__/graphics/icons/crystal-furnace.png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = "crystal-furnace"},
    max_health = 200,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-1.0, -1.0}, {1.0, 1.0}},
    crafting_speed = 2.0,
    energy_usage = "360kW",
    energy_source = {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = {pollution = 2},
    },
    crafting_categories = {"smelting"},
    result_inventory_size = 2,
    source_inventory_size = 1,
    module_slots = 2,
    allowed_effects = {"speed", "productivity", "consumption"},
    graphics_set = {
      working_visualisations = {
        {
          always_draw = true,
          animation = {
            filename = "__prototype-examples__/graphics/entity/crystal-furnace-working.png",
            width = 87,
            height = 99,
            frame_count = 12,
            line_length = 12,
            animation_speed = 0.5,
          },
        },
      },
      animation = {
        layers = {
          {
            filename = "__prototype-examples__/graphics/entity/crystal-furnace.png",
            width = 87,
            height = 99,
            frame_count = 1,
            shift = {0, 0},
          },
          {
            filename = "__prototype-examples__/graphics/entity/crystal-furnace-shadow.png",
            width = 111,
            height = 62,
            frame_count = 1,
            shift = {0.8, 0.5},
            draw_as_shadow = true,
          },
        },
      },
      fire_glow_flicker_enabled = true,
    },
    working_sound = {
      sound = {filename = "__base__/sound/electric-furnace.ogg", volume = 0.5},
      audible_distance_modifier = 0.5,
      max_sounds_per_type = 3,
    },
    fast_replaceable_group = "furnace",
    next_upgrade = "electric-furnace",
  },
})

-- ===== TECHNOLOGY =====

data:extend({
  {
    type = "technology",
    name = "crystal-processing",
    icon = "__prototype-examples__/graphics/technology/crystal-processing.png",
    icon_size = 256,
    effects = {
      {type = "unlock-recipe", recipe = "crystal-processor-recipe"},
      {type = "unlock-recipe", recipe = "melt-crystal"},
      {type = "unlock-recipe", recipe = "crystal-furnace-recipe"},
    },
    prerequisites = {"metallurgy", "automation"},
    unit = {
      count = 100,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
      },
      time = 30,
    },
    order = "z[crystal-processing]",
  },
})
