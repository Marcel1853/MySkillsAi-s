local util = require("util")
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
    icon = "__base__/graphics/icons/uranium-235.png",
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
      { type = "item", name = "iron-plate", amount = 1 },
      { type = "item", name = "copper-plate", amount = 1 },
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
    icon = "__quality__/graphics/technology/quality-module-1.png",
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
  -- Vom echten Sammler kopiert: Grafiken, Greifarme und Pflichtfelder kommen vollständig mit
  (function()
    local collector = util.table.deepcopy(data.raw["asteroid-collector"]["asteroid-collector"])
    collector.name = "advanced-asteroid-collector"
    collector.minable = { mining_time = 0.5, result = "advanced-asteroid-collector" }
    collector.max_health = 300
    return collector
  end)(),
  {
    type = "item",
    name = "advanced-asteroid-collector",
    icon = "__space-age__/graphics/icons/asteroid-collector.png",
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
      { type = "item", name = "steel-plate", amount = 10 },
      { type = "item", name = "processing-unit", amount = 5 },
      { type = "item", name = "quantum-crystal", amount = 2 },
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
    icon = "__space-age__/graphics/icons/metallic-asteroid-chunk.png",
    icon_size = 64,
    map_color = {r = 0.5, g = 0.0, b = 1.0},
  },
  {
    type = "asteroid",
    name = "quantum-asteroid",
    icon = "__space-age__/graphics/icons/metallic-asteroid-chunk.png",
    icon_size = 64,
    subgroup = "space-environment",
  },
})

-- ===== CARGO LANDING PAD WITH QUALITY =====

-- Eigenen Typ nie von Grund auf bauen, wenn das Spiel einen passenden hat: Pflichtfelder
-- (inventory_size, Grafiken, Andock-Punkte …) kommen so vollständig mit.
local pad = util.table.deepcopy(data.raw["cargo-landing-pad"]["cargo-landing-pad"])
pad.name = "advanced-cargo-landing-pad"
pad.max_health = 1000
pad.minable = { mining_time = 1.0, result = "advanced-cargo-landing-pad" }
data:extend({
  pad,
  {
    type = "item",
    name = "advanced-cargo-landing-pad",
    icon = "__base__/graphics/icons/cargo-landing-pad.png",
    icon_size = 64,
    subgroup = "space-interactors",
    order = "c[cargo-landing-pad]-b[advanced]",
    place_result = "advanced-cargo-landing-pad",
    stack_size = 1,
  },
})
