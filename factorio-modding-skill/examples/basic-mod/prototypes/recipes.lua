-- prototypes/recipes.lua
-- Recipe prototypes for the crystal-tech mod

data:extend({
  -- Smelt ore into refined crystal
  {
    type = "recipe",
    name = "refine-crystal",
    categories = {"smelting"},
    enabled = true,
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
    enabled = false,
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
