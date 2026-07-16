-- ============================================================
-- EXAMPLE: Space Age — Quality System & Asteroids
-- ============================================================
-- Demonstrates quality tiers, quality-aware items/recipes,
-- and asteroid collection mechanics.
-- ============================================================

-- ===== QUALITY-AWARE ITEM =====

data:extend({
  {
    type = "item",
    name = "quantum-crystal",
    icon = "__quality-examples__/graphics/icons/quantum-crystal.png",
    icon_size = 64,
    subgroup = "intermediate-product",
    order = "a[quantum-crystal]",
    stack_size = 50,
    weight = 100,
    -- Quality settings (Space Age)
    random_quality_on_item_creation = "always",  -- Always roll for quality
    default_import_location = "fulgora",  -- Shows origin on tooltip
  },
})

-- ===== QUALITY-AWARE RECIPE =====

data:extend({
  {
    type = "recipe",
    name = "quantum-crystal-recipe",
    categories = {"crafting"},
    enabled = true,
    energy_required = 5.0,
    ingredients = {
      {"iron-plate", 1},
      {"copper-plate", 1},
    },
    results = {
      {
        type = "item",
        name = "quantum-crystal",
        amount = 1,
        ignored_by_quality = {"quality"},  -- quality doesn't affect output count
      },
    },
    allow_productivity = true,
    allow_quality = true,  -- Quality modules can affect this recipe
  },
})

-- ===== QUALITY-BASED TECHNOLOGY =====

data:extend({
  {
    type = "technology",
    name = "quality-processing",
    icon = "__quality-examples__/graphics/technology/quality-processing.png",
    icon_size = 256,
    effects = {
      {type = "unlock-recipe", recipe = "quantum-crystal-recipe"},
      -- Quality modules can now be placed on labs
      {type = "change-recipe-productivity", recipe = "quantum-crystal-recipe", change = 0.1},
    },
    prerequisites = {"automation"},
    unit = {
      count = 50,
      ingredients = {{"automation-science-pack", 1}},
      time = 30,
    },
    order = "z[quality]",
  },
})

-- ===== ASTEROID COLLECTOR =====

-- A custom asteroid collector that works more efficiently
data:extend({
  {
    type = "asteroid-collector",
    name = "advanced-asteroid-collector",
    icon = "__quality-examples__/graphics/icons/adv-asteroid-collector.png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.5, result = "advanced-asteroid-collector"},
    max_health = 300,
    corpse = "medium-remnants",
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    collecting_time = 5,  -- Faster than default (default is 10)
    -- The entity is placed on a space platform
    -- and collects asteroids as the platform travels
  },
  {
    type = "item",
    name = "advanced-asteroid-collector",
    icon = "__quality-examples__/graphics/icons/adv-asteroid-collector.png",
    icon_size = 64,
    subgroup = "space-related",
    order = "a[advanced-asteroid-collector]",
    place_result = "advanced-asteroid-collector",
    stack_size = 10,
    random_quality_on_item_creation = "always",
  },
  {
    type = "recipe",
    name = "advanced-asteroid-collector-recipe",
    enabled = false,
    energy_required = 10.0,
    categories = {"crafting"},
    ingredients = {
      {"steel-plate", 10},
      {"processing-unit", 5},
      {"quantum-crystal", 2},
    },
    results = {
      {type = "item", name = "advanced-asteroid-collector", amount = 1},
    },
    allow_productivity = true,
    allow_quality = true,
  },
})

-- ===== ASTEROID CHUNK TYPES =====

data:extend({
  -- A rare asteroid type that spawns near our quality planet
  {
    type = "asteroid-chunk",
    name = "quantum-asteroid-chunk",
    icon = "__quality-examples__/graphics/icons/quantum-asteroid.png",
    icon_size = 64,
    map_color = {r = 0.5, g = 0.0, b = 1.0},
  },
  {
    type = "asteroid",
    name = "quantum-asteroid",
    icon = "__quality-examples__/graphics/icons/quantum-asteroid.png",
    icon_size = 64,
    subgroup = "asteroids",
  },
})

-- ===== CARGO LANDING PAD WITH QUALITY =====

data:extend({
  {
    type = "cargo-landing-pad",
    name = "advanced-cargo-landing-pad",
    icon = "__quality-examples__/graphics/icons/adv-cargo-pad.png",
    icon_size = 64,
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 1.0, result = "advanced-cargo-landing-pad"},
    max_health = 1000,
    collision_box = {{-2.4, -2.4}, {2.4, 2.4}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    -- Receives cargo pods from space platforms
  },
})
